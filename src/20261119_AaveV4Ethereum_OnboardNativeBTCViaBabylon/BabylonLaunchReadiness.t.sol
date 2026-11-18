// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {ISafe} from 'src/interfaces/ISafe.sol';
import {IBabylonTimelockController} from 'src/interfaces/babylon/IBabylonTimelockController.sol';
import {AaveAdapterRoles} from 'src/interfaces/babylon/AaveAdapterRoles.sol';
import {BabylonMainnet} from './BabylonMainnet.sol';

/**
 * @dev Checks Babylon's side of the launch on the latest mainnet block. It depends on actions
 * Babylon has not taken yet, so it only runs with BABYLON_READINESS=true and is expected to fail
 * until they are done. Before the proposal is submitted, these checks move into the proposal test
 * at a pinned block.
 * command: BABYLON_READINESS=true FOUNDRY_PROFILE=test forge test --match-path=src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/BabylonLaunchReadiness.t.sol -vv
 */
contract BabylonLaunchReadinessTest is Test {
  address internal constant V4_SECURITY_COUNCIL = MiscEthereum.V4_SECURITY_COUNCIL;
  // Aave Labs seat on Babylon's Emergency Guardian
  address internal constant AAVE_LABS_SAFE = 0x4Ab2Bed1d667260dB34244Ba412817651C2dD52b;

  address internal constant BABYLON_AAVE_ADAPTER = BabylonMainnet.AAVE_ADAPTER;
  address internal constant BABYLON_AAVE_ADAPTER_CONFIG = BabylonMainnet.AAVE_ADAPTER_CONFIG;
  address internal constant BABYLON_AAVE_ADAPTER_PROXY_MANAGER =
    BabylonMainnet.AAVE_ADAPTER_PROXY_MANAGER;
  address internal constant BABYLON_BTC_VAULT_SWAP_SPOKE = BabylonMainnet.BTC_VAULT_SWAP_SPOKE;
  address internal constant VAULT_BTC = BabylonMainnet.VAULT_BTC;
  address internal constant APPLICATION_TIMELOCK = BabylonMainnet.APPLICATION_TIMELOCK;
  address internal constant PROTOCOL_TIMELOCK = BabylonMainnet.PROTOCOL_TIMELOCK;
  address internal constant INTERIM_GOVERNANCE = BabylonMainnet.INTERIM_GOVERNANCE;
  address internal constant EMERGENCY_GUARDIAN = BabylonMainnet.EMERGENCY_GUARDIAN;
  address internal constant FEE_RECIPIENT = BabylonMainnet.FEE_RECIPIENT;
  // the two owners of every Babylon Safe at deployment
  address internal constant PLACEHOLDER_OWNER_1 = 0xF6D401E079F53Fb7dDB8bC759Fb9a53E5B4b26EF;
  address internal constant PLACEHOLDER_OWNER_2 = 0x270C35Ee0b78C25869a9734caF77da96383b1b1a;

  // block of the first timelock deployment
  uint256 internal constant TIMELOCKS_DEPLOY_BLOCK = 26_399_880;

  bytes32 internal constant BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE =
    AaveAdapterRoles.APPLICATION_PAUSE_GUARDIAN_ROLE;
  bytes32 internal constant BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE =
    AaveAdapterRoles.APPLICATION_FREEZE_GUARDIAN_ROLE;

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
    bytes32[2] memory roles = [
      BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE,
      BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE
    ];
    string[2] memory names = ['APPLICATION_PAUSE_GUARDIAN', 'APPLICATION_FREEZE_GUARDIAN'];
    for (uint256 i; i < roles.length; ++i) {
      if (IAccessControl(BABYLON_AAVE_ADAPTER).hasRole(roles[i], V4_SECURITY_COUNCIL)) {
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
        if (!IBabylonTimelockController(timelocks[i]).isOperationPending(id)) {
          console.log('  no longer pending');
          continue;
        }
        if (!_isAaveIntegrationContract(target)) continue;
        assertTrue(
          keccak256(data) == keccak256(_grant(BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE)) ||
            keccak256(data) == keccak256(_grant(BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE)),
          'unexpected operation queued on an Aave integration contract'
        );
      }
    }
  }

  function test_timelockDelays() public view {
    assertEq(
      IBabylonTimelockController(APPLICATION_TIMELOCK).getMinDelay(),
      5 days,
      'application timelock delay'
    );
    assertEq(
      IBabylonTimelockController(PROTOCOL_TIMELOCK).getMinDelay(),
      5 days,
      'protocol timelock delay'
    );
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
        target == BABYLON_AAVE_ADAPTER &&
        value == 0 &&
        keccak256(data) == keccak256(_grant(role)) &&
        IBabylonTimelockController(APPLICATION_TIMELOCK).isOperationPending(id)
      ) {
        return IBabylonTimelockController(APPLICATION_TIMELOCK).getTimestamp(id);
      }
    }
    return 0;
  }

  function _scheduled(address timelock) internal returns (Vm.EthGetLogs[] memory) {
    bytes32[] memory topics = new bytes32[](1);
    topics[0] = IBabylonTimelockController.CallScheduled.selector;
    return vm.eth_getLogs(TIMELOCKS_DEPLOY_BLOCK, block.number, timelock, topics);
  }

  function _grant(bytes32 role) internal pure returns (bytes memory) {
    return abi.encodeCall(IAccessControl.grantRole, (role, V4_SECURITY_COUNCIL));
  }

  function _isAaveIntegrationContract(address target) internal pure returns (bool) {
    return
      target == BABYLON_AAVE_ADAPTER ||
      target == BABYLON_AAVE_ADAPTER_CONFIG ||
      target == BABYLON_AAVE_ADAPTER_PROXY_MANAGER ||
      target == BABYLON_BTC_VAULT_SWAP_SPOKE ||
      target == VAULT_BTC;
  }
}
