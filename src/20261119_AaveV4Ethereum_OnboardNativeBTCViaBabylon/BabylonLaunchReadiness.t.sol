// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

interface ISafe {
  function getOwners() external view returns (address[] memory);

  function getThreshold() external view returns (uint256);

  function isOwner(address owner) external view returns (bool);
}

interface IAccessControl {
  function hasRole(bytes32 role, address account) external view returns (bool);

  function grantRole(bytes32 role, address account) external;
}

interface ITimelock {
  event CallScheduled(
    bytes32 indexed id,
    uint256 indexed index,
    address target,
    uint256 value,
    bytes data,
    bytes32 predecessor,
    uint256 delay
  );

  function isOperationPending(bytes32 id) external view returns (bool);

  function isOperationDone(bytes32 id) external view returns (bool);

  function getTimestamp(bytes32 id) external view returns (uint256);

  function getMinDelay() external view returns (uint256);
}

/**
 * @dev Checks Babylon's side of the launch on the latest mainnet block. It depends on actions
 * Babylon has not taken yet, so it only runs with BABYLON_READINESS=true and is expected to fail
 * until they are done. Before the proposal is submitted, these checks move into the proposal test
 * at a pinned block.
 * command: BABYLON_READINESS=true FOUNDRY_PROFILE=test forge test --match-path=src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/BabylonLaunchReadiness.t.sol -vv
 */
contract BabylonLaunchReadinessTest is Test {
  // aave-address-book MiscEthereum
  address internal constant V4_SECURITY_COUNCIL = 0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9;
  // Aave Labs seat on Babylon's Emergency Guardian
  address internal constant AAVE_LABS_SAFE = 0x4Ab2Bed1d667260dB34244Ba412817651C2dD52b;

  // Babylon's deployment
  address internal constant AAVE_ADAPTER = 0xadca531564f3B26d0aAF48a044d741fD6cD571Ea;
  address internal constant AAVE_ADAPTER_CONFIG = 0xaB6900Dee104781ADFdEa151ccFf8acE47E33C54;
  address internal constant AAVE_ADAPTER_PROXY_MANAGER = 0xd73AcD95867c775Bc48979E5DB4E8ED63F9C78DB;
  address internal constant BTC_VAULT_SWAP = 0xFe354b6A67E9a308B600d35B0b3e2e6F33f3c6d9;
  address internal constant VAULT_BTC = 0x69712D713FD30aBEF48b5D14eC2a9FB834D2c341;
  address internal constant APPLICATION_TIMELOCK = 0x0a575185163a2446F7A0433f48B0395ca4A9fBb0;
  address internal constant PROTOCOL_TIMELOCK = 0xDeC656861922d11A3F08e8ba3631cCdeA877D9d3;
  address internal constant INTERIM_GOVERNANCE = 0xcd9e54acA1B7fb9BcE10208201b01559A6B01949;
  address internal constant EMERGENCY_GUARDIAN = 0xbd8AEfA24Bd875c6a36C4Dc3be818059372dF2B0;
  address internal constant FEE_RECIPIENT = 0x5b1AdCC0330c8c1D5A70302E657174416a25Ba8C;
  // the two owners of every Babylon Safe at deployment
  address internal constant PLACEHOLDER_OWNER_1 = 0xF6D401E079F53Fb7dDB8bC759Fb9a53E5B4b26EF;
  address internal constant PLACEHOLDER_OWNER_2 = 0x270C35Ee0b78C25869a9734caF77da96383b1b1a;

  // block of the first timelock deployment
  uint256 internal constant TIMELOCKS_DEPLOY_BLOCK = 26_399_880;

  bytes32 internal constant APPLICATION_PAUSE_GUARDIAN = keccak256('APPLICATION_PAUSE_GUARDIAN');
  bytes32 internal constant APPLICATION_FREEZE_GUARDIAN = keccak256('APPLICATION_FREEZE_GUARDIAN');

  function setUp() public {
    if (!vm.envOr('BABYLON_READINESS', false)) {
      vm.skip(true);
    }
    vm.createSelectFork(vm.rpcUrl('mainnet'));
  }

  function test_safesHaveRealOwners() public view {
    address[3] memory safes = [INTERIM_GOVERNANCE, EMERGENCY_GUARDIAN, FEE_RECIPIENT];
    string[3] memory names = ['Interim Governance', 'Emergency Guardian', 'fee recipient'];
    for (uint256 i; i < safes.length; ++i) {
      address[] memory owners = ISafe(safes[i]).getOwners();
      uint256 threshold = ISafe(safes[i]).getThreshold();
      console.log(names[i], 'threshold', threshold);
      for (uint256 j; j < owners.length; ++j) {
        console.log('  owner', owners[j]);
        assertTrue(
          owners[j] != PLACEHOLDER_OWNER_1 && owners[j] != PLACEHOLDER_OWNER_2,
          string.concat(names[i], ' has a placeholder owner')
        );
      }
      assertGt(threshold, 1, string.concat(names[i], ' threshold'));
    }
  }

  function test_aaveLabsSitsOnTheEmergencyGuardian() public view {
    assertTrue(ISafe(EMERGENCY_GUARDIAN).isOwner(AAVE_LABS_SAFE), 'Aave Labs seat');
  }

  /// @dev Each role is granted, or the grant is queued on the application timelock.
  function test_securityCouncilGuardianRoles() public {
    bytes32[2] memory roles = [APPLICATION_PAUSE_GUARDIAN, APPLICATION_FREEZE_GUARDIAN];
    string[2] memory names = ['APPLICATION_PAUSE_GUARDIAN', 'APPLICATION_FREEZE_GUARDIAN'];
    for (uint256 i; i < roles.length; ++i) {
      if (IAccessControl(AAVE_ADAPTER).hasRole(roles[i], V4_SECURITY_COUNCIL)) {
        console.log(names[i], 'granted');
        continue;
      }
      uint256 executableAt = _pendingGrant(roles[i]);
      assertGt(executableAt, 0, string.concat(names[i], ' neither granted nor queued'));
      console.log(names[i], 'queued, executable at', executableAt);
    }
  }

  /// @dev Prints every operation queued on either timelock. Any call to an Aave integration
  /// contract other than the two guardian grants fails and needs a manual review.
  function test_queuedOperationsOnAaveIntegrationContracts() public {
    address[2] memory timelocks = [APPLICATION_TIMELOCK, PROTOCOL_TIMELOCK];
    for (uint256 i; i < timelocks.length; ++i) {
      Vm.EthGetLogs[] memory logs = _scheduled(timelocks[i]);
      console.log('timelock', timelocks[i]);
      console.log('  scheduled calls', logs.length);
      for (uint256 j; j < logs.length; ++j) {
        (address target, , bytes memory data, , ) = abi.decode(
          logs[j].data,
          (address, uint256, bytes, bytes32, uint256)
        );
        bytes32 id = logs[j].topics[1];
        console.log('  target', target);
        console.logBytes(data);
        if (!ITimelock(timelocks[i]).isOperationPending(id)) {
          console.log('  no longer pending');
          continue;
        }
        if (!_isAaveIntegrationContract(target)) continue;
        assertTrue(
          keccak256(data) == keccak256(_grant(APPLICATION_PAUSE_GUARDIAN)) ||
            keccak256(data) == keccak256(_grant(APPLICATION_FREEZE_GUARDIAN)),
          'unexpected operation queued on an Aave integration contract'
        );
      }
    }
  }

  function test_timelockDelays() public view {
    assertEq(ITimelock(APPLICATION_TIMELOCK).getMinDelay(), 5 days, 'application timelock delay');
    assertEq(ITimelock(PROTOCOL_TIMELOCK).getMinDelay(), 5 days, 'protocol timelock delay');
  }

  /// @dev Returns when the queued grant of `role` becomes executable, zero if none is pending.
  function _pendingGrant(bytes32 role) internal returns (uint256) {
    Vm.EthGetLogs[] memory logs = _scheduled(APPLICATION_TIMELOCK);
    for (uint256 i; i < logs.length; ++i) {
      (address target, uint256 value, bytes memory data, , ) = abi.decode(
        logs[i].data,
        (address, uint256, bytes, bytes32, uint256)
      );
      bytes32 id = logs[i].topics[1];
      if (
        target == AAVE_ADAPTER &&
        value == 0 &&
        keccak256(data) == keccak256(_grant(role)) &&
        ITimelock(APPLICATION_TIMELOCK).isOperationPending(id)
      ) {
        return ITimelock(APPLICATION_TIMELOCK).getTimestamp(id);
      }
    }
    return 0;
  }

  function _scheduled(address timelock) internal returns (Vm.EthGetLogs[] memory) {
    bytes32[] memory topics = new bytes32[](1);
    topics[0] = ITimelock.CallScheduled.selector;
    return vm.eth_getLogs(TIMELOCKS_DEPLOY_BLOCK, block.number, timelock, topics);
  }

  function _grant(bytes32 role) internal pure returns (bytes memory) {
    return abi.encodeCall(IAccessControl.grantRole, (role, V4_SECURITY_COUNCIL));
  }

  function _isAaveIntegrationContract(address target) internal pure returns (bool) {
    return
      target == AAVE_ADAPTER ||
      target == AAVE_ADAPTER_CONFIG ||
      target == AAVE_ADAPTER_PROXY_MANAGER ||
      target == BTC_VAULT_SWAP ||
      target == VAULT_BTC;
  }
}
