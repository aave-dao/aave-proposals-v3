// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV4TestBaseBase} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseBase.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';
import {AaveV4Base, AaveV4BaseSpokePriceFeeds, AaveV4BaseAssets} from 'aave-address-book/AaveV4Base.sol';
import {RiskStewardV4Config} from 'src/helpers/risk-stewards/RiskStewardV4Config.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {AaveV4Base_AaveV4RiskStewardsActivation_20260807} from './AaveV4Base_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Base_AaveV4RiskStewardsActivation_20260807
 *      Runs on forge's Base EVM (nightly), which executes the B20 equity precompiles. The fork block is
 *      on the Beryl upgrade; switch to base:cobalt if the fork moves past 1790791200 (2026-09-30T10:00Z).
 *      Isolation is off because isolated top-level calls are charged the L1 data fee and revert for
 *      0-ETH pranked callers (foundry-rs/foundry#17010).
 * forge-config: default.networks.network = "base"
 * forge-config: default.hardfork = "base:beryl"
 * forge-config: default.isolate = false
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Base_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Base_AaveV4RiskStewardsActivation_20260807_Test is ProtocolV4TestBaseBase {
  /// @dev The Base market is deployed halted until this activation payload (Security Council) executes
  address internal constant BASE_ACTIVATION_PAYLOAD = 0x6BDf957Ff2AE324fe23911f549aff9b5621b198E;

  AaveV4Base_AaveV4RiskStewardsActivation_20260807 internal proposal;
  IRiskStewardV4 internal steward = IRiskStewardV4(AaveV4Base.RISK_STEWARD);
  IPriceCapAdapterStable internal stableAdapter =
    IPriceCapAdapterStable(AaveV4BaseSpokePriceFeeds.MAG7_SPOKE_USDC_PRICE_FEED);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 51698800);
    proposal = new AaveV4Base_AaveV4RiskStewardsActivation_20260807();
  }

  /// @dev executes the payload with config snapshots and diff; the e2e runs in `test_e2e`
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4Base_AaveV4RiskStewardsActivation_20260807',
      payload: address(proposal),
      runE2E: false,
      testPositionManagers: false,
      runSeatbelt: false
    });
  }

  /// @dev The equities are B20 tokens (node-native, code 0xef): only forge's Base EVM executes them, so
  /// this test is skipped, not passed, anywhere else. See `_requireB20Semantics`.
  function test_e2e() public {
    _requireB20Semantics();
    GovV3Helpers.executePayload(vm, BASE_ACTIVATION_PAYLOAD);
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestAllSpokes({spokes: _getSpokes(), testPositionManagers: true});
    e2eTestAllTokenizationSpokes(_getTokenizationSpokes());
  }

  function test_ownershipAccepted() public {
    assertEq(steward.pendingOwner(), GovernanceV3Base.EXECUTOR_LVL_1, 'pending owner mismatch');
    assertNotEq(steward.owner(), GovernanceV3Base.EXECUTOR_LVL_1, 'owned before activation');

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(steward.owner(), GovernanceV3Base.EXECUTOR_LVL_1, 'owner mismatch');
    assertEq(steward.pendingOwner(), address(0), 'pending owner not cleared');
  }

  function test_configUnchanged() public {
    IRiskStewardV4.Config memory expected = RiskStewardV4Config.defaultConfig(
      AaveV4Base.HUB_CONFIGURATOR,
      AaveV4Base.SPOKE_CONFIGURATOR
    );
    expected.hub.cap.addCap.minDelay = 12 hours;
    expected.hub.cap.drawCap.minDelay = 12 hours;
    expected.spoke.dynamicUpdate.collateralFactor.minDelay = 36 hours;
    expected.spoke.dynamicUpdate.maxLiquidationBonus.minDelay = 36 hours;
    expected.spoke.dynamicAdd.collateralFactor.minDelay = 36 hours;
    expected.spoke.dynamicAdd.maxLiquidationBonus.minDelay = 36 hours;
    expected.spoke.liquidation.targetHealthFactor.minDelay = 36 hours;
    expected.spoke.liquidation.healthFactorForMaxBonus.minDelay = 36 hours;
    expected.spoke.liquidation.liquidationBonusFactor.minDelay = 36 hours;
    assertEq(abi.encode(steward.getConfig()), abi.encode(expected), 'config mismatch');

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(abi.encode(steward.getConfig()), abi.encode(expected), 'config changed');
  }

  function test_riskAdminGranted() public {
    assertFalse(
      AaveV3Base.ACL_MANAGER.isRiskAdmin(address(steward)),
      'risk admin held before activation'
    );

    GovV3Helpers.executePayload(vm, address(proposal));

    assertTrue(AaveV3Base.ACL_MANAGER.isRiskAdmin(address(steward)), 'risk admin not granted');
    assertFalse(AaveV3Base.ACL_MANAGER.isPoolAdmin(address(steward)), 'pool admin granted');
    assertFalse(
      AaveV3Base.ACL_MANAGER.isEmergencyAdmin(address(steward)),
      'emergency admin granted'
    );
    assertFalse(
      AaveV3Base.ACL_MANAGER.isAssetListingAdmin(address(steward)),
      'asset listing admin granted'
    );
    assertFalse(AaveV3Base.ACL_MANAGER.isBridge(address(steward)), 'bridge granted');
    assertFalse(AaveV3Base.ACL_MANAGER.isFlashBorrower(address(steward)), 'flash borrower granted');
  }

  function test_riskCouncilCanUpdateStablePriceCap() public {
    uint256 priceCapBefore = uint256(stableAdapter.getPriceCap());
    IRiskStewardV4.PriceCapStableUpdate[]
      memory updates = new IRiskStewardV4.PriceCapStableUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapStableUpdate({
      oracle: address(stableAdapter),
      priceCap: priceCapBefore + (priceCapBefore * 50) / 100_00
    });
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert();
    vm.prank(riskCouncil);
    steward.updateStablePriceCaps(updates);

    GovV3Helpers.executePayload(vm, address(proposal));

    vm.prank(riskCouncil);
    steward.updateStablePriceCaps(updates);
    assertEq(uint256(stableAdapter.getPriceCap()), updates[0].priceCap, 'priceCap not updated');
  }

  /// @dev Without the Base EVM, forge burns all forwarded gas on a B20 token. Probe it and skip rather
  /// than pass.
  function _requireB20Semantics() internal {
    (bool ok, ) = AaveV4BaseAssets.AAPLc_UNDERLYING.staticcall{gas: 100_000}(
      abi.encodeWithSignature('symbol()')
    );
    vm.skip(!ok, 'requires forge with the Base EVM for the B20 equity precompiles');
  }
}
