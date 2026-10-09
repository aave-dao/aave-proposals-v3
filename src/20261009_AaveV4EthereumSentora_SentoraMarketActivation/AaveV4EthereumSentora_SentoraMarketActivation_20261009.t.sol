// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IHub} from 'aave-address-book/AaveV4.sol';
import {IOwnable2Step} from 'src/interfaces/IOwnable2Step.sol';
import {AaveV4EthereumSentora, AaveV4EthereumSentoraHubs, AaveV4EthereumSentoraPositionManagers} from 'aave-address-book/AaveV4EthereumSentora.sol';
import {ProtocolV4TestBaseEthereumSentora} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereumSentora.sol';
import {AaveV4EthereumSentora_SentoraMarketActivation_20261009} from './AaveV4EthereumSentora_SentoraMarketActivation_20261009.sol';

/**
 * @dev Test for AaveV4EthereumSentora_SentoraMarketActivation_20261009. Skipped until the Sentora
 *      market is deployed and the address-book placeholders are replaced.
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261009_AaveV4EthereumSentora_SentoraMarketActivation/AaveV4EthereumSentora_SentoraMarketActivation_20261009.t.sol -vv
 */
contract AaveV4EthereumSentora_SentoraMarketActivation_20261009_Test is
  ProtocolV4TestBaseEthereumSentora
{
  IHub internal constant SENTORA_HUB = AaveV4EthereumSentoraHubs.SENTORA_HUB;
  address internal constant SENTORA_EXECUTOR =
    AaveV4EthereumSentora.PERMISSIONED_PAYLOADS_CONTROLLER_EXECUTOR;

  AaveV4EthereumSentora_SentoraMarketActivation_20261009 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26155605);
    vm.skip(address(SENTORA_HUB).code.length == 0);
    proposal = new AaveV4EthereumSentora_SentoraMarketActivation_20261009();
  }

  modifier activated() {
    _executePayload();
    _;
  }

  /// @dev executes the generic test suite including e2e and config snapshots
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4EthereumSentora_SentoraMarketActivation_20261009',
      payload: address(proposal),
      runE2E: true,
      testPositionManagers: true
    });
  }

  function test_preconditions() public view {
    address[] memory owned = _ownedByExecutor();
    for (uint256 i; i < owned.length; ++i) {
      assertEq(IOwnable2Step(owned[i]).pendingOwner(), SENTORA_EXECUTOR, 'pending owner');
    }
    _assertAllHalted(true);
  }

  function test_ownershipsAccepted() public activated {
    address[] memory owned = _ownedByExecutor();
    for (uint256 i; i < owned.length; ++i) {
      assertEq(IOwnable2Step(owned[i]).owner(), SENTORA_EXECUTOR, 'owner');
      assertEq(IOwnable2Step(owned[i]).pendingOwner(), address(0), 'pending owner');
    }
  }

  function test_marketUnhalted() public activated {
    _assertAllHalted(false);
  }

  /// @dev Executes through the Sentora PermissionedPayloadsController instead of the Aave one.
  function _executePayloadWithRecording(
    address payload
  ) internal override returns (string memory rawDiff, string memory logsJson) {
    vm.startStateDiffRecording();
    vm.recordLogs();
    GovV3Helpers.executePayload(
      vm,
      payload,
      AaveV4EthereumSentora.PERMISSIONED_PAYLOADS_CONTROLLER
    );
    rawDiff = vm.getStateDiffJson();
    logsJson = vm.getRecordedLogsJson();
  }

  function _executePayload() internal {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      AaveV4EthereumSentora.PERMISSIONED_PAYLOADS_CONTROLLER
    );
  }

  function _assertAllHalted(bool halted) internal view {
    uint256 assetCount = SENTORA_HUB.getAssetCount();
    assertGt(assetCount, 0, 'no assets');
    for (uint256 assetId; assetId < assetCount; ++assetId) {
      uint256 spokeCount = SENTORA_HUB.getSpokeCount(assetId);
      for (uint256 i; i < spokeCount; ++i) {
        address spoke = SENTORA_HUB.getSpokeAddress(assetId, i);
        assertEq(SENTORA_HUB.getSpokeConfig(assetId, spoke).halted, halted, 'halted');
      }
    }
  }

  function _ownedByExecutor() internal pure returns (address[] memory owned) {
    owned = new address[](5);
    owned[0] = address(AaveV4EthereumSentoraPositionManagers.GIVER_POSITION_MANAGER);
    owned[1] = address(AaveV4EthereumSentoraPositionManagers.TAKER_POSITION_MANAGER);
    owned[2] = address(AaveV4EthereumSentoraPositionManagers.CONFIG_POSITION_MANAGER);
    owned[3] = address(AaveV4EthereumSentoraPositionManagers.NATIVE_TOKEN_GATEWAY);
    owned[4] = address(AaveV4EthereumSentoraPositionManagers.SIGNATURE_GATEWAY);
  }
}
