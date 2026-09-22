// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {AaveV4Base, AaveV4BaseHubs, AaveV4BaseSpokes, AaveV4BaseSpokePriceFeeds, AaveV4BaseAssets} from 'aave-address-book/AaveV4Base.sol';
import {IAaveV4ConfigEngine as IConfigEngine, IHub, ISpoke} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskSteward} from 'src/interfaces/IRiskSteward.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {ProtocolV4TestBaseBase} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseBase.sol';
import {AaveV4Base_AaveV4RiskStewardsActivation_20260807} from './AaveV4Base_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Base_AaveV4RiskStewardsActivation_20260807
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Base_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Base_AaveV4RiskStewardsActivation_20260807_Test is ProtocolV4TestBaseBase {
  IHub internal constant EQUITIES_HUB = AaveV4BaseHubs.EQUITIES_HUB;
  ISpoke internal constant MAG7_SPOKE = AaveV4BaseSpokes.MAG7_SPOKE;
  address internal constant AAPLc = AaveV4BaseAssets.AAPLc_UNDERLYING;
  // v4 Base lists no LST, so the lst bound is exercised on the v3 wstETH adapter, which the same
  // risk admin role unlocks
  IPriceCapAdapter internal constant wstETH_CAPO_ADAPTER =
    IPriceCapAdapter(AaveV3BaseAssets.wstETH_ORACLE);
  IPriceCapAdapterStable internal constant USDC_CAPO_ADAPTER =
    IPriceCapAdapterStable(AaveV4BaseSpokePriceFeeds.MAG7_SPOKE_USDC_PRICE_FEED);

  AaveV4Base_AaveV4RiskStewardsActivation_20260807 internal proposal;
  IRiskStewardV4 internal steward;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 51642134);
    proposal = new AaveV4Base_AaveV4RiskStewardsActivation_20260807();
    steward = IRiskStewardV4(AaveV4Base.RISK_STEWARD);
  }

  modifier activated() {
    GovV3Helpers.executePayload(vm, address(proposal));
    _;
  }

  /**
   * @dev executes the payload with config snapshots and diff; the e2e runs in `test_e2e`
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4Base_AaveV4RiskStewardsActivation_20260807',
      payload: address(proposal),
      runE2E: false,
      testPositionManagers: false
    });
  }

  /// @dev The generic e2e suite over every spoke and tokenization spoke. The seven equities are B20
  /// tokens (node-native, code 0xef, balances outside EVM storage): stable forge cannot execute
  /// them, so this test only runs under a forge that selects the Base EVM (`--network base`) and is
  /// skipped, not passed, anywhere else. See `_requireB20Semantics`.
  function test_e2e() public {
    _requireB20Semantics();
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestAllSpokes({spokes: _getSpokes(), testPositionManagers: false});
    e2eTestAllTokenizationSpokes(_getTokenizationSpokes());
  }

  function _requireB20Semantics() internal {
    (bool ok, ) = AAPLc.staticcall(abi.encodeWithSignature('decimals()'));
    vm.skip(!ok, 'requires forge with --network base for the B20 equity precompiles');
  }

  function test_stewardOwnerAndCouncil() public view {
    assertEq(steward.owner(), GovernanceV3Base.EXECUTOR_LVL_1, 'owner mismatch');
    assertEq(
      steward.RISK_COUNCIL(),
      IRiskSteward(AaveV3Base.RISK_STEWARD).RISK_COUNCIL(),
      'council diverges from the v3 risk steward'
    );
  }

  function test_rolesGranted() public activated {
    uint64[] memory granted = new uint64[](2);
    granted[0] = Roles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
    granted[1] = Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE;

    for (uint256 i; i < granted.length; ++i) {
      (bool hasRole, uint32 delay) = AaveV4Base.ACCESS_MANAGER.hasRole(
        granted[i],
        AaveV4Base.RISK_STEWARD
      );
      assertTrue(hasRole, string.concat('role not granted: ', vm.toString(granted[i])));
      assertEq(uint256(delay), 0, string.concat('role delay: ', vm.toString(granted[i])));
    }

    assertTrue(
      AaveV3Base.ACL_MANAGER.isRiskAdmin(AaveV4Base.RISK_STEWARD),
      'risk admin role not granted'
    );
  }

  function test_riskCouncilCanUpdateLstPriceCap() public activated {
    uint16 growthBefore = uint16(wstETH_CAPO_ADAPTER.getMaxYearlyGrowthRatePercent());
    uint16 growthAfter = growthBefore + growthBefore / 20;
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(growthAfter);
    address riskCouncil = steward.RISK_COUNCIL();

    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);

    assertEq(
      wstETH_CAPO_ADAPTER.getMaxYearlyGrowthRatePercent(),
      growthAfter,
      'maxYearlyGrowthRatePercent not updated'
    );
  }

  function test_riskCouncilCannotUpdateLstPriceCapAboveBound() public activated {
    uint16 growthBefore = uint16(wstETH_CAPO_ADAPTER.getMaxYearlyGrowthRatePercent());
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(
      growthBefore + growthBefore / 20 + 1
    );
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);
  }

  function _lstPriceCapUpdate(
    uint16 maxYearlyRatioGrowthPercent
  ) internal view returns (IRiskStewardV4.PriceCapLstUpdate[] memory) {
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = new IRiskStewardV4.PriceCapLstUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapLstUpdate({
      oracle: address(wstETH_CAPO_ADAPTER),
      priceCapUpdateParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: uint104(uint256(wstETH_CAPO_ADAPTER.getRatio())),
        snapshotTimestamp: uint48(block.timestamp - wstETH_CAPO_ADAPTER.MINIMUM_SNAPSHOT_DELAY()),
        maxYearlyRatioGrowthPercent: maxYearlyRatioGrowthPercent
      })
    });
    return updates;
  }

  function test_riskStewardConfig() public activated {
    _assertConfig(steward.getConfig());
  }

  /// @dev Covers the bounds LlamaRisk carried over from the v3 Risk Steward unchanged. The params
  /// they widened (baseDrawnRate, rateGrowthBeforeOptimal, collateralRisk, the dynamicAdd bounds)
  /// and those with no v3 counterpart are asserted in `_assertConfig` only.
  function test_boundsMatchV3RiskSteward() public activated {
    IRiskSteward.Config memory v3 = IRiskSteward(AaveV3Base.RISK_STEWARD).getRiskConfig();
    IRiskStewardV4.Config memory v4 = steward.getConfig();

    assertEq(
      uint256(v4.hub.rate.optimalUsageRatio.maxPercentChange),
      v3.rateConfig.optimalUsageRatio.maxPercentChange,
      'optimalUsageRatio bound'
    );
    assertEq(
      uint256(v4.hub.rate.rateGrowthAfterOptimal.maxPercentChange),
      v3.rateConfig.variableRateSlope2.maxPercentChange,
      'rateGrowthAfterOptimal bound'
    );
    assertEq(
      uint256(v4.hub.cap.addCap.maxPercentChange),
      v3.capConfig.supplyCap.maxPercentChange,
      'addCap bound'
    );
    assertEq(
      uint256(v4.hub.cap.drawCap.maxPercentChange),
      v3.capConfig.borrowCap.maxPercentChange,
      'drawCap bound'
    );
    assertEq(
      uint256(v4.spoke.dynamicUpdate.collateralFactor.maxPercentChange),
      v3.collateralConfig.ltv.maxPercentChange,
      'collateralFactor bound'
    );
    assertEq(
      uint256(v4.spoke.dynamicUpdate.maxLiquidationBonus.maxPercentChange),
      v3.collateralConfig.liquidationBonus.maxPercentChange,
      'maxLiquidationBonus bound'
    );
    assertEq(
      uint256(v4.oracle.priceCapLst.maxPercentChange),
      v3.priceCapConfig.priceCapLst.maxPercentChange,
      'priceCapLst bound'
    );
    assertEq(
      uint256(v4.oracle.priceCapStable.maxPercentChange),
      v3.priceCapConfig.priceCapStable.maxPercentChange,
      'priceCapStable bound'
    );
    assertEq(
      uint256(v4.oracle.discountRatePendle.maxPercentChange),
      v3.priceCapConfig.discountRatePendle.maxPercentChange,
      'discountRatePendle bound'
    );
    assertEq(
      uint256(v4.oracle.discountRatePendle.minDelay),
      uint256(v3.priceCapConfig.discountRatePendle.minDelay),
      'discountRatePendle cooldown'
    );
  }

  function test_riskCouncilCanUpdateHubAssetIRs() public activated {
    IAssetInterestRateStrategy.InterestRateData memory expected = _currentIrData();
    expected.optimalUsageRatio += 3_00;
    expected.baseDrawnRate += 3_00;
    expected.rateGrowthBeforeOptimal += 3_00;
    expected.rateGrowthAfterOptimal += 20_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateHubAssetIRs(_irUpdate(expected));

    IAssetInterestRateStrategy.InterestRateData memory current = _currentIrData();
    assertEq(
      current.optimalUsageRatio,
      expected.optimalUsageRatio,
      'optimalUsageRatio not updated'
    );
    assertEq(current.baseDrawnRate, expected.baseDrawnRate, 'baseDrawnRate not updated');
    assertEq(
      current.rateGrowthBeforeOptimal,
      expected.rateGrowthBeforeOptimal,
      'rateGrowthBeforeOptimal not updated'
    );
    assertEq(
      current.rateGrowthAfterOptimal,
      expected.rateGrowthAfterOptimal,
      'rateGrowthAfterOptimal not updated'
    );
  }

  function test_riskCouncilCannotUpdateHubAssetIRsAboveBound() public activated {
    IAssetInterestRateStrategy.InterestRateData memory outOfRange = _currentIrData();
    outOfRange.optimalUsageRatio += 3_00 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateHubAssetIRs(_irUpdate(outOfRange));
  }

  function test_riskCouncilCanUpdateHubSpokeCaps() public activated {
    uint256 assetId = EQUITIES_HUB.getAssetId(AAPLc);
    IHub.SpokeConfig memory before = EQUITIES_HUB.getSpokeConfig(assetId, address(MAG7_SPOKE));
    uint256 addCap = 2 * uint256(before.addCap);
    uint256 drawCap = 2 * uint256(before.drawCap);

    vm.prank(steward.RISK_COUNCIL());
    steward.updateHubSpokeCaps(_capsUpdate(addCap, drawCap));

    IHub.SpokeConfig memory current = EQUITIES_HUB.getSpokeConfig(assetId, address(MAG7_SPOKE));
    assertEq(uint256(current.addCap), addCap, 'addCap not updated');
    assertEq(uint256(current.drawCap), drawCap, 'drawCap not updated');
  }

  function test_riskCouncilCannotUpdateHubSpokeCapsAboveBound() public activated {
    uint256 assetId = EQUITIES_HUB.getAssetId(AAPLc);
    uint256 addCapBefore = EQUITIES_HUB.getSpokeConfig(assetId, address(MAG7_SPOKE)).addCap;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateHubSpokeCaps(_capsUpdate(2 * addCapBefore + 1, EngineFlags.KEEP_CURRENT));
  }

  function test_riskCouncilCanUpdateReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint256 collateralRisk = uint256(MAG7_SPOKE.getReserveConfig(reserveId).collateralRisk) +
      300_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateReserveConfigs(_reserveConfigUpdate(collateralRisk));

    assertEq(
      uint256(MAG7_SPOKE.getReserveConfig(reserveId).collateralRisk),
      collateralRisk,
      'collateralRisk not updated'
    );
  }

  function test_riskCouncilCannotUpdateReserveConfigsAboveBound() public activated {
    uint256 collateralRisk = uint256(MAG7_SPOKE.getReserveConfig(_reserveId()).collateralRisk) +
      300_00 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateReserveConfigs(_reserveConfigUpdate(collateralRisk));
  }

  function test_riskCouncilCanUpdateDynamicReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = MAG7_SPOKE.getReserve(reserveId).dynamicConfigKey;
    ISpoke.DynamicReserveConfig memory before = MAG7_SPOKE.getDynamicReserveConfig(reserveId, key);
    uint256 collateralFactor = uint256(before.collateralFactor) + 50;
    uint256 maxLiquidationBonus = uint256(before.maxLiquidationBonus) + 50;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateDynamicReserveConfigs(
      _dynamicReserveConfigUpdate(key, collateralFactor, maxLiquidationBonus)
    );

    ISpoke.DynamicReserveConfig memory current = MAG7_SPOKE.getDynamicReserveConfig(reserveId, key);
    assertEq(uint256(current.collateralFactor), collateralFactor, 'collateralFactor not updated');
    assertEq(
      uint256(current.maxLiquidationBonus),
      maxLiquidationBonus,
      'maxLiquidationBonus not updated'
    );
  }

  function test_riskCouncilCannotUpdateDynamicReserveConfigsAboveBound() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = MAG7_SPOKE.getReserve(reserveId).dynamicConfigKey;
    uint256 collateralFactor = uint256(
      MAG7_SPOKE.getDynamicReserveConfig(reserveId, key).collateralFactor
    ) +
      50 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateDynamicReserveConfigs(
      _dynamicReserveConfigUpdate(key, collateralFactor, EngineFlags.KEEP_CURRENT)
    );
  }

  function test_riskCouncilCanAddDynamicReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint32 keyBefore = MAG7_SPOKE.getReserve(reserveId).dynamicConfigKey;
    ISpoke.DynamicReserveConfig memory added = MAG7_SPOKE.getDynamicReserveConfig(
      reserveId,
      keyBefore
    );
    added.collateralFactor += 5_00;
    added.maxLiquidationBonus += 50;

    vm.prank(steward.RISK_COUNCIL());
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(added));

    uint32 keyAfter = MAG7_SPOKE.getReserve(reserveId).dynamicConfigKey;
    assertEq(uint256(keyAfter), uint256(keyBefore) + 1, 'dynamic config key not bumped');

    ISpoke.DynamicReserveConfig memory current = MAG7_SPOKE.getDynamicReserveConfig(
      reserveId,
      keyAfter
    );
    assertEq(
      uint256(current.collateralFactor),
      uint256(added.collateralFactor),
      'collateralFactor not added'
    );
    assertEq(
      uint256(current.maxLiquidationBonus),
      uint256(added.maxLiquidationBonus),
      'maxLiquidationBonus not added'
    );
  }

  function test_riskCouncilCannotAddDynamicReserveConfigsAboveBound() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = MAG7_SPOKE.getReserve(reserveId).dynamicConfigKey;
    address riskCouncil = steward.RISK_COUNCIL();

    ISpoke.DynamicReserveConfig memory outOfRange = MAG7_SPOKE.getDynamicReserveConfig(
      reserveId,
      key
    );
    outOfRange.collateralFactor += 5_00 + 1;

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(outOfRange));

    outOfRange = MAG7_SPOKE.getDynamicReserveConfig(reserveId, key);
    outOfRange.maxLiquidationBonus += 50 + 1;

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(outOfRange));
  }

  function test_riskCouncilCanUpdateSpokeLiquidationConfigs() public activated {
    ISpoke.LiquidationConfig memory before = MAG7_SPOKE.getLiquidationConfig();
    uint256 targetHealthFactor = uint256(before.targetHealthFactor) +
      (uint256(before.targetHealthFactor) * 5_00) /
      100_00;
    uint256 healthFactorForMaxBonus = uint256(before.healthFactorForMaxBonus) +
      (uint256(before.healthFactorForMaxBonus) * 5_00) /
      100_00;
    uint256 liquidationBonusFactor = uint256(before.liquidationBonusFactor) + 5_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateSpokeLiquidationConfigs(
      _liquidationConfigUpdate(targetHealthFactor, healthFactorForMaxBonus, liquidationBonusFactor)
    );

    ISpoke.LiquidationConfig memory current = MAG7_SPOKE.getLiquidationConfig();
    assertEq(
      uint256(current.targetHealthFactor),
      targetHealthFactor,
      'targetHealthFactor not updated'
    );
    assertEq(
      uint256(current.healthFactorForMaxBonus),
      healthFactorForMaxBonus,
      'healthFactorForMaxBonus not updated'
    );
    assertEq(
      uint256(current.liquidationBonusFactor),
      liquidationBonusFactor,
      'liquidationBonusFactor not updated'
    );
  }

  function test_riskCouncilCannotUpdateSpokeLiquidationConfigsAboveBound() public activated {
    uint256 targetHealthFactorBefore = MAG7_SPOKE.getLiquidationConfig().targetHealthFactor;
    uint256 targetHealthFactor = targetHealthFactorBefore +
      (targetHealthFactorBefore * 5_00) /
      100_00 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateSpokeLiquidationConfigs(
      _liquidationConfigUpdate(
        targetHealthFactor,
        EngineFlags.KEEP_CURRENT,
        EngineFlags.KEEP_CURRENT
      )
    );
  }

  function test_riskCouncilCanUpdateStablePriceCap() public activated {
    uint256 priceCapBefore = uint256(USDC_CAPO_ADAPTER.getPriceCap());
    uint256 priceCap = priceCapBefore + (priceCapBefore * 50) / 100_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateStablePriceCaps(_stablePriceCapUpdate(priceCap));

    assertEq(uint256(USDC_CAPO_ADAPTER.getPriceCap()), priceCap, 'priceCap not updated');
  }

  function test_riskCouncilCannotUpdateStablePriceCapAboveBound() public activated {
    uint256 priceCapBefore = uint256(USDC_CAPO_ADAPTER.getPriceCap());
    uint256 priceCap = priceCapBefore + (priceCapBefore * 50) / 100_00 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateStablePriceCaps(_stablePriceCapUpdate(priceCap));
  }

  function _reserveId() internal view returns (uint256) {
    return MAG7_SPOKE.getReserveId(address(EQUITIES_HUB), EQUITIES_HUB.getAssetId(AAPLc));
  }

  function _currentIrData()
    internal
    view
    returns (IAssetInterestRateStrategy.InterestRateData memory)
  {
    uint256 assetId = EQUITIES_HUB.getAssetId(AAPLc);
    return
      IAssetInterestRateStrategy(EQUITIES_HUB.getAssetConfig(assetId).irStrategy)
        .getInterestRateData(assetId);
  }

  function _irUpdate(
    IAssetInterestRateStrategy.InterestRateData memory irData
  ) internal pure returns (IConfigEngine.AssetConfigUpdate[] memory) {
    IConfigEngine.AssetConfigUpdate[] memory updates = new IConfigEngine.AssetConfigUpdate[](1);
    updates[0] = IConfigEngine.AssetConfigUpdate({
      hubConfigurator: AaveV4Base.HUB_CONFIGURATOR,
      hub: address(EQUITIES_HUB),
      underlying: AAPLc,
      liquidityFee: EngineFlags.KEEP_CURRENT,
      feeReceiver: EngineFlags.KEEP_CURRENT_ADDRESS,
      irStrategy: EngineFlags.KEEP_CURRENT_ADDRESS,
      irData: irData,
      reinvestmentController: EngineFlags.KEEP_CURRENT_ADDRESS
    });
    return updates;
  }

  function _capsUpdate(
    uint256 addCap,
    uint256 drawCap
  ) internal pure returns (IConfigEngine.SpokeConfigUpdate[] memory) {
    IConfigEngine.SpokeConfigUpdate[] memory updates = new IConfigEngine.SpokeConfigUpdate[](1);
    updates[0] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: AaveV4Base.HUB_CONFIGURATOR,
      hub: address(EQUITIES_HUB),
      underlying: AAPLc,
      spoke: address(MAG7_SPOKE),
      addCap: addCap,
      drawCap: drawCap,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _reserveConfigUpdate(
    uint256 collateralRisk
  ) internal pure returns (IConfigEngine.ReserveConfigUpdate[] memory) {
    IConfigEngine.ReserveConfigUpdate[] memory updates = new IConfigEngine.ReserveConfigUpdate[](1);
    updates[0] = IConfigEngine.ReserveConfigUpdate({
      spokeConfigurator: AaveV4Base.SPOKE_CONFIGURATOR,
      spoke: address(MAG7_SPOKE),
      hub: address(EQUITIES_HUB),
      underlying: AAPLc,
      priceSource: EngineFlags.KEEP_CURRENT_ADDRESS,
      collateralRisk: collateralRisk,
      paused: EngineFlags.KEEP_CURRENT,
      frozen: EngineFlags.KEEP_CURRENT,
      borrowable: EngineFlags.KEEP_CURRENT,
      receiveSharesEnabled: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _dynamicReserveConfigUpdate(
    uint32 dynamicConfigKey,
    uint256 collateralFactor,
    uint256 maxLiquidationBonus
  ) internal pure returns (IConfigEngine.DynamicReserveConfigUpdate[] memory) {
    IConfigEngine.DynamicReserveConfigUpdate[]
      memory updates = new IConfigEngine.DynamicReserveConfigUpdate[](1);
    updates[0] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Base.SPOKE_CONFIGURATOR,
      spoke: address(MAG7_SPOKE),
      hub: address(EQUITIES_HUB),
      underlying: AAPLc,
      dynamicConfigKey: dynamicConfigKey,
      collateralFactor: collateralFactor,
      maxLiquidationBonus: maxLiquidationBonus,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _dynamicReserveConfigAddition(
    ISpoke.DynamicReserveConfig memory dynamicConfig
  ) internal pure returns (IConfigEngine.DynamicReserveConfigAddition[] memory) {
    IConfigEngine.DynamicReserveConfigAddition[]
      memory additions = new IConfigEngine.DynamicReserveConfigAddition[](1);
    additions[0] = IConfigEngine.DynamicReserveConfigAddition({
      spokeConfigurator: AaveV4Base.SPOKE_CONFIGURATOR,
      spoke: address(MAG7_SPOKE),
      hub: address(EQUITIES_HUB),
      underlying: AAPLc,
      dynamicConfig: dynamicConfig
    });
    return additions;
  }

  function _liquidationConfigUpdate(
    uint256 targetHealthFactor,
    uint256 healthFactorForMaxBonus,
    uint256 liquidationBonusFactor
  ) internal pure returns (IConfigEngine.LiquidationConfigUpdate[] memory) {
    IConfigEngine.LiquidationConfigUpdate[]
      memory updates = new IConfigEngine.LiquidationConfigUpdate[](1);
    updates[0] = IConfigEngine.LiquidationConfigUpdate({
      spokeConfigurator: AaveV4Base.SPOKE_CONFIGURATOR,
      spoke: address(MAG7_SPOKE),
      targetHealthFactor: targetHealthFactor,
      healthFactorForMaxBonus: healthFactorForMaxBonus,
      liquidationBonusFactor: liquidationBonusFactor
    });
    return updates;
  }

  function _stablePriceCapUpdate(
    uint256 priceCap
  ) internal pure returns (IRiskStewardV4.PriceCapStableUpdate[] memory) {
    IRiskStewardV4.PriceCapStableUpdate[]
      memory updates = new IRiskStewardV4.PriceCapStableUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapStableUpdate({
      oracle: address(USDC_CAPO_ADAPTER),
      priceCap: priceCap
    });
    return updates;
  }

  function _assertConfig(IRiskStewardV4.Config memory config) internal pure {
    assertEq(
      address(config.hub.configurator),
      address(AaveV4Base.HUB_CONFIGURATOR),
      'hub configurator mismatch'
    );
    assertEq(
      address(config.spoke.configurator),
      address(AaveV4Base.SPOKE_CONFIGURATOR),
      'spoke configurator mismatch'
    );

    // prettier-ignore
    {
      //           param                                           minDelay  maxChange   relative  label
      _assertParam(config.hub.rate.optimalUsageRatio,               36 hours, 3_00,       false,    'optimalUsageRatio');
      _assertParam(config.hub.rate.baseDrawnRate,                   36 hours, 3_00,       false,    'baseDrawnRate');
      _assertParam(config.hub.rate.rateGrowthBeforeOptimal,         36 hours, 3_00,       false,    'rateGrowthBeforeOptimal');
      _assertParam(config.hub.rate.rateGrowthAfterOptimal,          36 hours, 20_00,      false,    'rateGrowthAfterOptimal');
      _assertParam(config.hub.cap.addCap,                           36 hours, 100_00,     true,     'addCap');
      _assertParam(config.hub.cap.drawCap,                          36 hours, 100_00,     true,     'drawCap');
      _assertParam(config.spoke.collateralRisk,                     36 hours, 300_00,     false,    'collateralRisk');
      _assertParam(config.spoke.dynamicUpdate.collateralFactor,     72 hours, 50,         false,    'dynamicUpdate collateralFactor');
      _assertParam(config.spoke.dynamicUpdate.maxLiquidationBonus,  72 hours, 50,         false,    'dynamicUpdate maxLiquidationBonus');
      _assertParam(config.spoke.dynamicAdd.collateralFactor,        72 hours, 5_00,       false,    'dynamicAdd collateralFactor');
      _assertParam(config.spoke.dynamicAdd.maxLiquidationBonus,     72 hours, 50,         false,    'dynamicAdd maxLiquidationBonus');
      _assertParam(config.spoke.liquidation.targetHealthFactor,     72 hours, 5_00,       true,     'targetHealthFactor');
      _assertParam(config.spoke.liquidation.healthFactorForMaxBonus,72 hours, 5_00,       true,     'healthFactorForMaxBonus');
      _assertParam(config.spoke.liquidation.liquidationBonusFactor, 72 hours, 5_00,       false,    'liquidationBonusFactor');
      _assertParam(config.oracle.priceCapLst,                       72 hours, 5_00,       true,     'priceCapLst');
      _assertParam(config.oracle.priceCapStable,                    72 hours, 50,         true,     'priceCapStable');
      _assertParam(config.oracle.discountRatePendle,                48 hours, 0.025e18,   false,    'discountRatePendle');
    }
  }

  function _assertParam(
    IRiskStewardV4.RiskParamConfig memory param,
    uint256 minDelay,
    uint256 maxPercentChange,
    bool isChangeRelative,
    string memory label
  ) internal pure {
    assertEq(uint256(param.minDelay), minDelay, string.concat(label, ' minDelay'));
    assertEq(
      uint256(param.maxPercentChange),
      maxPercentChange,
      string.concat(label, ' maxPercentChange')
    );
    assertEq(param.isChangeRelative, isChangeRelative, string.concat(label, ' isChangeRelative'));
  }
}
