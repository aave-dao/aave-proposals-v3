// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV4TestBaseBase} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseBase.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';
import {AaveV4Base, AaveV4BaseHubs, AaveV4BaseSpokes, AaveV4BaseSpokePriceFeeds, AaveV4BaseAssets} from 'aave-address-book/AaveV4Base.sol';
import {GhoBase} from 'aave-address-book/GhoBase.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {AaveV4Base_AaveV4RiskStewardsActivation_20260807} from './AaveV4Base_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Base_AaveV4RiskStewardsActivation_20260807
 *      The e2e suite only runs under a forge that can execute the B20 equities (`--network base`).
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Base_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Base_AaveV4RiskStewardsActivation_20260807_Test is ProtocolV4TestBaseBase {
  AaveV4Base_AaveV4RiskStewardsActivation_20260807 internal proposal;
  IRiskStewardV4 internal steward = IRiskStewardV4(AaveV4Base.RISK_STEWARD);
  IPriceCapAdapterStable internal stableAdapter =
    IPriceCapAdapterStable(AaveV4BaseSpokePriceFeeds.MAG7_SPOKE_USDC_PRICE_FEED);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 51698800);
    proposal = new AaveV4Base_AaveV4RiskStewardsActivation_20260807();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4Base_AaveV4RiskStewardsActivation_20260807',
      payload: address(proposal),
      runE2E: _canExecuteB20(),
      testPositionManagers: false,
      runSeatbelt: false
    });
  }

  function test_ownershipAccepted() public {
    assertEq(steward.pendingOwner(), GovernanceV3Base.EXECUTOR_LVL_1, 'pending owner mismatch');
    assertNotEq(steward.owner(), GovernanceV3Base.EXECUTOR_LVL_1, 'owned before activation');

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(steward.owner(), GovernanceV3Base.EXECUTOR_LVL_1, 'owner mismatch');
    assertEq(steward.pendingOwner(), address(0), 'pending owner not cleared');
  }

  function test_configUnchanged() public {
    bytes memory configBefore = abi.encode(steward.getConfig());

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(abi.encode(steward.getConfig()), configBefore, 'config changed');
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

  function test_ghoRestricted() public {
    assertFalse(steward.isAddressRestricted(GhoBase.GHO_TOKEN), 'gho restricted before activation');

    GovV3Helpers.executePayload(vm, address(proposal));

    assertTrue(steward.isAddressRestricted(GhoBase.GHO_TOKEN), 'gho not restricted');
  }

  function test_riskCouncilCannotUpdateGho() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    IConfigEngine.SpokeConfigUpdate[] memory updates = new IConfigEngine.SpokeConfigUpdate[](1);
    updates[0] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: AaveV4Base.HUB_CONFIGURATOR,
      hub: address(AaveV4BaseHubs.EQUITIES_HUB),
      underlying: GhoBase.GHO_TOKEN,
      spoke: address(AaveV4BaseSpokes.MAG7_SPOKE),
      addCap: EngineFlags.KEEP_CURRENT,
      drawCap: EngineFlags.KEEP_CURRENT,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(
      abi.encodeWithSelector(IRiskStewardV4.RestrictedAddress.selector, GhoBase.GHO_TOKEN)
    );
    vm.prank(riskCouncil);
    steward.updateHubSpokeCaps(updates);
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

  /// @dev B20 equities are node-native (code 0xef): upstream forge burns all forwarded gas on them
  function _canExecuteB20() internal view returns (bool ok) {
    (ok, ) = AaveV4BaseAssets.AAPLc_UNDERLYING.staticcall{gas: 100_000}(
      abi.encodeWithSignature('symbol()')
    );
  }
}
