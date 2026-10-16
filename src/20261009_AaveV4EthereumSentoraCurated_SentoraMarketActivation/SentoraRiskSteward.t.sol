// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IHub, ISpoke, IAaveV4ConfigEngine as IEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets, AaveV4EthereumSentoraCuratedSpokePriceFeeds as Feeds} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';
import {IReduceRiskStewardWrapper, IRiskStewardErrors} from './SentoraInterfaces.sol';

/// @dev Risk-reducing path: Emergency Admin -> ReduceRiskStewardWrapper -> RiskSteward (role 1000).
contract SentoraRiskSteward_Test is SentoraTestBase {
  struct Pair {
    ISpoke spoke;
    address underlying;
  }

  function setUp() public override {
    super.setUp();
    _activate();
    _raisePstPrimeCapsThroughSentora();
  }

  function test_stewardConfig() public view {
    IRiskStewardV4.Config memory config = RISK_STEWARD.getConfig();
    assertEq(address(config.hub.configurator), address(HUB_CONFIGURATOR), 'hub configurator');
    assertEq(address(config.spoke.configurator), address(SPOKE_CONFIGURATOR), 'spoke configurator');

    _assertParam(config.hub.rate.optimalUsageRatio, 0, false);
    _assertParam(config.hub.rate.baseDrawnRate, 0, false);
    _assertParam(config.hub.rate.rateGrowthBeforeOptimal, 0, false);
    _assertParam(config.hub.rate.rateGrowthAfterOptimal, 0, false);
    _assertParam(config.hub.cap.addCap, 300_00, true);
    _assertParam(config.hub.cap.drawCap, 300_00, true);

    _assertParam(config.spoke.collateralRisk, 0, false);
    _assertParam(config.spoke.dynamicUpdate.collateralFactor, 0, false);
    _assertParam(config.spoke.dynamicUpdate.maxLiquidationBonus, 0, false);
    _assertParam(config.spoke.dynamicAdd.collateralFactor, 100_00, false);
    _assertParam(config.spoke.dynamicAdd.maxLiquidationBonus, 50_00, false);
    _assertParam(config.spoke.liquidation.targetHealthFactor, 0, true);
    _assertParam(config.spoke.liquidation.healthFactorForMaxBonus, 0, true);
    _assertParam(config.spoke.liquidation.liquidationBonusFactor, 0, false);

    _assertParam(config.oracle.priceCapLst, 0, true);
    _assertParam(config.oracle.priceCapStable, 0, true);
    _assertParam(config.oracle.discountRatePendle, 0, false);
  }

  /// @dev Selectors from the aave-v4-risk-stewards build, so the mirrored interfaces cannot drift.
  function test_interfaceSelectors() public pure {
    assertEq(IReduceRiskStewardWrapper.reduceHubSpokeCaps.selector, bytes4(0xbd3d43ff));
    assertEq(
      IReduceRiskStewardWrapper.addReducedDynamicReserveConfigs.selector,
      bytes4(0xdca9dfa8)
    );
    assertEq(IRiskStewardV4.updateHubSpokeCaps.selector, bytes4(0xd3e6db1b));
    assertEq(IRiskStewardV4.addDynamicReserveConfigs.selector, bytes4(0xde807f64));
    assertEq(IRiskStewardV4.updateDynamicReserveConfigs.selector, bytes4(0xba58d41a));
    assertEq(IRiskStewardV4.updateReserveConfigs.selector, bytes4(0x7fbdbc72));
    assertEq(IRiskStewardV4.updateHubAssetIRs.selector, bytes4(0x2cd0fd70));
    assertEq(IRiskStewardV4.updateSpokeLiquidationConfigs.selector, bytes4(0xdae0f901));
    assertEq(IRiskStewardV4.updateStablePriceCaps.selector, bytes4(0xec3b79aa));
    assertEq(IRiskStewardV4.setConfig.selector, bytes4(0xddc81878));
  }

  /// @dev mWIN pairs are closed at 0 caps, so there is nothing left to reduce on them.
  function test_reduceCaps_everyPair() public {
    Pair[] memory pairs = _pairs();
    for (uint256 i; i < pairs.length; ++i) {
      IHub.SpokeConfig memory current = _spokeConfig(pairs[i]);
      if (pairs[i].underlying == Assets.mWIN_UNDERLYING) {
        assertEq(current.addCap, 0, 'mWIN add cap');
        _expectReduceCapsRevert(pairs[i], 0, EngineFlags.KEEP_CURRENT);
        continue;
      }
      uint256 drawCap = current.drawCap == 0 ? EngineFlags.KEEP_CURRENT : current.drawCap / 2;
      _reduceCaps(pairs[i], current.addCap / 2, drawCap);

      IHub.SpokeConfig memory halved = _spokeConfig(pairs[i]);
      assertEq(halved.addCap, current.addCap / 2, 'add cap halved');
      assertEq(halved.drawCap, current.drawCap / 2, 'draw cap halved');

      _reduceCaps(pairs[i], 0, current.drawCap == 0 ? EngineFlags.KEEP_CURRENT : 0);
      IHub.SpokeConfig memory zeroed = _spokeConfig(pairs[i]);
      assertEq(zeroed.addCap, 0, 'add cap zero');
      assertEq(zeroed.drawCap, 0, 'draw cap zero');
      assertEq(zeroed.riskPremiumThreshold, current.riskPremiumThreshold, 'threshold kept');
      assertFalse(zeroed.halted, 'halted kept');
    }
  }

  function test_reduceCaps_zeroAddCapBlocksSupply() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    _reduceCaps(pair, 0, EngineFlags.KEEP_CURRENT);

    address user = makeAddr('user');
    uint256 reserveId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    deal2(Assets.USDe_UNDERLYING, user, 1e18);
    vm.startPrank(user);
    IERC20(Assets.USDe_UNDERLYING).approve(address(RLUSD_YIELD), 1e18);
    vm.expectRevert(abi.encodeWithSelector(IHub.AddCapExceeded.selector, 0));
    RLUSD_YIELD.supply(reserveId, 1e18, user);
    vm.stopPrank();
  }

  function test_reduceCaps_rejectsIncreaseOrEqual() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.RLUSD_UNDERLYING);
    IHub.SpokeConfig memory current = _spokeConfig(pair);

    _expectReduceCapsRevert(pair, current.addCap, EngineFlags.KEEP_CURRENT);
    _expectReduceCapsRevert(pair, uint256(current.addCap) + 1, EngineFlags.KEEP_CURRENT);
    _expectReduceCapsRevert(pair, EngineFlags.KEEP_CURRENT, current.drawCap);
    _expectReduceCapsRevert(pair, EngineFlags.KEEP_CURRENT, uint256(current.drawCap) + 1);
    // a 0 draw cap cannot be reduced further
    _expectReduceCapsRevert(Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING), EngineFlags.KEEP_CURRENT, 0);
  }

  function test_reduceCaps_rejectsFrozenFields() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.RLUSD_UNDERLYING);
    IEngine.SpokeConfigUpdate[] memory updates = _capUpdate(pair, 1, EngineFlags.KEEP_CURRENT);

    updates[0].riskPremiumThreshold = 0;
    _expectWrapperCapsRevert(updates, IRiskStewardErrors.ParamChangeNotAllowed.selector);

    updates[0].riskPremiumThreshold = EngineFlags.KEEP_CURRENT;
    updates[0].active = 0;
    _expectWrapperCapsRevert(updates, IRiskStewardErrors.ParamChangeNotAllowed.selector);

    updates[0].active = EngineFlags.KEEP_CURRENT;
    updates[0].halted = 1;
    _expectWrapperCapsRevert(updates, IRiskStewardErrors.ParamChangeNotAllowed.selector);
  }

  function test_reduceCollateralFactor_everyCollateral() public {
    Pair[] memory pairs = _collateralPairs();
    for (uint256 i; i < pairs.length; ++i) {
      uint256 reserveId = _reserveId(pairs[i].spoke, pairs[i].underlying);
      uint32 oldKey = pairs[i].spoke.getReserve(reserveId).dynamicConfigKey;
      ISpoke.DynamicReserveConfig memory current = pairs[i].spoke.getDynamicReserveConfig(
        reserveId,
        oldKey
      );

      _addReducedConfig(
        pairs[i],
        ISpoke.DynamicReserveConfig({
          collateralFactor: current.collateralFactor - 1_00,
          maxLiquidationBonus: current.maxLiquidationBonus,
          liquidationFee: current.liquidationFee
        })
      );

      uint32 newKey = pairs[i].spoke.getReserve(reserveId).dynamicConfigKey;
      assertEq(newKey, oldKey + 1, 'new key');
      ISpoke.DynamicReserveConfig memory latest = pairs[i].spoke.getDynamicReserveConfig(
        reserveId,
        newKey
      );
      assertEq(latest.collateralFactor, current.collateralFactor - 1_00, 'collateral factor');
      assertEq(latest.maxLiquidationBonus, current.maxLiquidationBonus, 'bonus');
      assertEq(latest.liquidationFee, current.liquidationFee, 'fee');
      assertEq(
        pairs[i].spoke.getDynamicReserveConfig(reserveId, oldKey).collateralFactor,
        current.collateralFactor,
        'old key kept'
      );
    }
  }

  function test_reduceCollateralFactor_rejectsIncreaseOrEqual() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    ISpoke.DynamicReserveConfig memory current = _latestConfig(pair);

    _expectAddRevert(pair, current, IReduceRiskStewardWrapper.UpdateNotReducing.selector);
    current.collateralFactor += 1;
    _expectAddRevert(pair, current, IReduceRiskStewardWrapper.UpdateNotReducing.selector);
  }

  function test_reduceCollateralFactor_bonusMayRiseWithinProduct() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    ISpoke.DynamicReserveConfig memory current = _latestConfig(pair);
    assertEq(current.collateralFactor, 91_50, 'collateral factor');
    assertEq(current.maxLiquidationBonus, 103_50, 'bonus');

    ISpoke.DynamicReserveConfig memory next = ISpoke.DynamicReserveConfig({
      collateralFactor: 90_00,
      // floor(103_50 * 91_50 / 90_00): the largest bonus keeping bonus x CF at or under today's
      maxLiquidationBonus: 105_22,
      liquidationFee: current.liquidationFee
    });

    next.maxLiquidationBonus = 105_23;
    _expectAddRevert(pair, next, IReduceRiskStewardWrapper.InvalidLiquidationBonus.selector);
    next.maxLiquidationBonus = 103_49;
    _expectAddRevert(pair, next, IReduceRiskStewardWrapper.InvalidLiquidationBonus.selector);

    next.maxLiquidationBonus = 105_22;
    _addReducedConfig(pair, next);
    ISpoke.DynamicReserveConfig memory latest = _latestConfig(pair);
    assertEq(latest.collateralFactor, 90_00, 'collateral factor');
    assertEq(latest.maxLiquidationBonus, 105_22, 'bonus');
  }

  function test_reduceCollateralFactor_rejectsLiquidationFeeChange() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    ISpoke.DynamicReserveConfig memory next = _latestConfig(pair);
    next.collateralFactor -= 1_00;
    next.liquidationFee -= 1;
    _expectAddRevert(pair, next, IRiskStewardErrors.ParamChangeNotAllowed.selector);
    next.liquidationFee += 2;
    _expectAddRevert(pair, next, IRiskStewardErrors.ParamChangeNotAllowed.selector);
  }

  /// @dev A position keeps the dynamic config key it was opened on until the user's next
  /// health-checked action, so a CF cut does not reach existing borrowers by itself.
  function test_reduceCollateralFactor_reachesPositionsOnRefresh() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    uint256 collateralId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    uint256 debtId = _reserveId(RLUSD_YIELD, Assets.RLUSD_UNDERLYING);
    address user = makeAddr('user');
    _supplyAs(RLUSD_YIELD, debtId, makeAddr('lender'), 100_000e18);
    _supplyCollateralAs(RLUSD_YIELD, collateralId, user, 10_000e18);
    _borrowAs(RLUSD_YIELD, debtId, user, 1_000e18);
    uint256 avgCollateralFactor = RLUSD_YIELD.getUserAccountData(user).avgCollateralFactor;

    ISpoke.DynamicReserveConfig memory next = _latestConfig(pair);
    next.collateralFactor = 80_00;
    _addReducedConfig(pair, next);

    assertEq(RLUSD_YIELD.getUserPosition(collateralId, user).dynamicConfigKey, 0, 'old key');
    assertEq(
      RLUSD_YIELD.getUserAccountData(user).avgCollateralFactor,
      avgCollateralFactor,
      'old collateral factor'
    );

    _borrowAs(RLUSD_YIELD, debtId, user, 1e18);
    assertEq(RLUSD_YIELD.getUserPosition(collateralId, user).dynamicConfigKey, 1, 'new key');
    assertLt(
      RLUSD_YIELD.getUserAccountData(user).avgCollateralFactor,
      avgCollateralFactor,
      'new collateral factor'
    );
  }

  function test_wrapperOnlyEmergencyAdmin() public {
    address[6] memory callers = [
      EXECUTOR,
      SECURITY_COUNCIL,
      DEPLOYER,
      OPERATOR,
      FEE_ADMIN,
      makeAddr('random')
    ];
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    IEngine.SpokeConfigUpdate[] memory caps = _capUpdate(pair, 1, EngineFlags.KEEP_CURRENT);
    ISpoke.DynamicReserveConfig memory reduced = _latestConfig(pair);
    reduced.collateralFactor -= 1_00;
    IEngine.DynamicReserveConfigAddition[] memory additions = _addition(pair, reduced);

    for (uint256 i; i < callers.length; ++i) {
      vm.startPrank(callers[i]);
      vm.expectRevert(IReduceRiskStewardWrapper.InvalidCaller.selector);
      WRAPPER.reduceHubSpokeCaps(caps);
      vm.expectRevert(IReduceRiskStewardWrapper.InvalidCaller.selector);
      WRAPPER.addReducedDynamicReserveConfigs(additions);
      vm.stopPrank();
    }
  }

  function test_stewardOnlyCallableByWrapper() public {
    address[6] memory callers = [
      EMERGENCY_ADMIN,
      EXECUTOR,
      SECURITY_COUNCIL,
      DEPLOYER,
      OPERATOR,
      makeAddr('random')
    ];
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    IEngine.SpokeConfigUpdate[] memory caps = _capUpdate(pair, 1, EngineFlags.KEEP_CURRENT);
    ISpoke.DynamicReserveConfig memory reduced = _latestConfig(pair);
    reduced.collateralFactor -= 1_00;
    IEngine.DynamicReserveConfigAddition[] memory additions = _addition(pair, reduced);

    for (uint256 i; i < callers.length; ++i) {
      vm.startPrank(callers[i]);
      vm.expectRevert(IRiskStewardErrors.InvalidCaller.selector);
      RISK_STEWARD.updateHubSpokeCaps(caps);
      vm.expectRevert(IRiskStewardErrors.InvalidCaller.selector);
      RISK_STEWARD.addDynamicReserveConfigs(additions);
      vm.expectRevert(IRiskStewardErrors.InvalidCaller.selector);
      RISK_STEWARD.updateReserveConfigs(_collateralRiskUpdate(pair, 0));
      vm.expectRevert(IRiskStewardErrors.InvalidCaller.selector);
      RISK_STEWARD.updateDynamicReserveConfigs(_dynamicUpdate(pair, 80_00));
      vm.expectRevert(IRiskStewardErrors.InvalidCaller.selector);
      RISK_STEWARD.updateHubAssetIRs(_rateUpdate(Assets.RLUSD_UNDERLYING, 40));
      vm.expectRevert(IRiskStewardErrors.InvalidCaller.selector);
      RISK_STEWARD.updateSpokeLiquidationConfigs(_liquidationUpdate(RLUSD_YIELD, 1.2e18));
      vm.stopPrank();
    }
  }

  /// @dev The wrapper only exposes caps and dynamic additions; every other steward entrypoint is
  /// frozen by the Sentora config even for the wrapper itself.
  function test_frozenParamsRevertOnSteward() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    vm.startPrank(address(WRAPPER));

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    RISK_STEWARD.updateReserveConfigs(_collateralRiskUpdate(pair, 6_24));
    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    RISK_STEWARD.updateDynamicReserveConfigs(_dynamicUpdate(pair, 91_49));
    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    RISK_STEWARD.updateHubAssetIRs(_rateUpdate(Assets.RLUSD_UNDERLYING, 49));
    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    RISK_STEWARD.updateSpokeLiquidationConfigs(_liquidationUpdate(RLUSD_YIELD, 1.23e18));

    IRiskStewardV4.PriceCapStableUpdate[]
      memory priceCaps = new IRiskStewardV4.PriceCapStableUpdate[](1);
    address rlusdFeed = Feeds.RLUSD_YIELD_SPOKE_RLUSD_PRICE_FEED;
    priceCaps[0] = IRiskStewardV4.PriceCapStableUpdate({
      oracle: rlusdFeed,
      priceCap: uint256(IPriceCapAdapterStable(rlusdFeed).getPriceCap()) - 1
    });
    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    RISK_STEWARD.updateStablePriceCaps(priceCaps);
    vm.stopPrank();
  }

  /// @dev The steward bounds alone let caps rise by up to 300% and the collateral factor move by
  /// any amount: only the wrapper enforces the risk-reducing direction.
  function test_stewardBoundsAloneAllowIncreases() public {
    Pair memory pair = Pair(RLUSD_YIELD, Assets.RLUSD_UNDERLYING);
    IHub.SpokeConfig memory current = _spokeConfig(pair);
    vm.startPrank(address(WRAPPER));

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    RISK_STEWARD.updateHubSpokeCaps(
      _capUpdate(pair, uint256(current.addCap) * 4 + 1, EngineFlags.KEEP_CURRENT)
    );
    RISK_STEWARD.updateHubSpokeCaps(
      _capUpdate(pair, uint256(current.addCap) * 4, EngineFlags.KEEP_CURRENT)
    );
    assertEq(_spokeConfig(pair).addCap, uint256(current.addCap) * 4, 'add cap raised');

    Pair memory collateral = Pair(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    ISpoke.DynamicReserveConfig memory raised = _latestConfig(collateral);
    raised.collateralFactor = 96_00;
    RISK_STEWARD.addDynamicReserveConfigs(_addition(collateral, raised));
    vm.stopPrank();
    assertEq(_latestConfig(collateral).collateralFactor, 96_00, 'collateral factor raised');
  }

  function test_securityCouncilSetsConfig() public {
    IRiskStewardV4.Config memory config = RISK_STEWARD.getConfig();
    config.hub.cap.addCap.maxPercentChange = 50_00;

    address[4] memory callers = [EMERGENCY_ADMIN, EXECUTOR, DEPLOYER, address(WRAPPER)];
    for (uint256 i; i < callers.length; ++i) {
      vm.prank(callers[i]);
      vm.expectRevert(
        abi.encodeWithSelector(IRiskStewardErrors.OwnableUnauthorizedAccount.selector, callers[i])
      );
      RISK_STEWARD.setConfig(config);
    }

    vm.prank(SECURITY_COUNCIL);
    RISK_STEWARD.setConfig(config);
    assertEq(RISK_STEWARD.getConfig().hub.cap.addCap.maxPercentChange, 50_00, 'config set');
  }

  function _assertParam(
    IRiskStewardV4.RiskParamConfig memory param,
    uint256 maxPercentChange,
    bool isChangeRelative
  ) internal pure {
    assertEq(param.minDelay, 0, 'min delay');
    assertEq(param.maxPercentChange, maxPercentChange, 'max change');
    assertEq(param.isChangeRelative, isChangeRelative, 'relative');
  }

  function _reduceCaps(Pair memory pair, uint256 addCap, uint256 drawCap) internal {
    vm.prank(EMERGENCY_ADMIN);
    WRAPPER.reduceHubSpokeCaps(_capUpdate(pair, addCap, drawCap));
  }

  function _expectReduceCapsRevert(Pair memory pair, uint256 addCap, uint256 drawCap) internal {
    _expectWrapperCapsRevert(
      _capUpdate(pair, addCap, drawCap),
      IReduceRiskStewardWrapper.UpdateNotReducing.selector
    );
  }

  function _expectWrapperCapsRevert(
    IEngine.SpokeConfigUpdate[] memory updates,
    bytes4 error_
  ) internal {
    vm.prank(EMERGENCY_ADMIN);
    vm.expectRevert(error_);
    WRAPPER.reduceHubSpokeCaps(updates);
  }

  function _addReducedConfig(Pair memory pair, ISpoke.DynamicReserveConfig memory config) internal {
    vm.prank(EMERGENCY_ADMIN);
    WRAPPER.addReducedDynamicReserveConfigs(_addition(pair, config));
  }

  function _expectAddRevert(
    Pair memory pair,
    ISpoke.DynamicReserveConfig memory config,
    bytes4 error_
  ) internal {
    IEngine.DynamicReserveConfigAddition[] memory additions = _addition(pair, config);
    vm.prank(EMERGENCY_ADMIN);
    vm.expectRevert(error_);
    WRAPPER.addReducedDynamicReserveConfigs(additions);
  }

  function _spokeConfig(Pair memory pair) internal view returns (IHub.SpokeConfig memory) {
    return HUB.getSpokeConfig(HUB.getAssetId(pair.underlying), address(pair.spoke));
  }

  function _latestConfig(
    Pair memory pair
  ) internal view returns (ISpoke.DynamicReserveConfig memory) {
    uint256 reserveId = _reserveId(pair.spoke, pair.underlying);
    return
      pair.spoke.getDynamicReserveConfig(
        reserveId,
        pair.spoke.getReserve(reserveId).dynamicConfigKey
      );
  }

  function _capUpdate(
    Pair memory pair,
    uint256 addCap,
    uint256 drawCap
  ) internal pure returns (IEngine.SpokeConfigUpdate[] memory updates) {
    updates = new IEngine.SpokeConfigUpdate[](1);
    updates[0] = IEngine.SpokeConfigUpdate({
      hubConfigurator: HUB_CONFIGURATOR,
      hub: address(HUB),
      underlying: pair.underlying,
      spoke: address(pair.spoke),
      addCap: addCap,
      drawCap: drawCap,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
  }

  function _addition(
    Pair memory pair,
    ISpoke.DynamicReserveConfig memory config
  ) internal pure returns (IEngine.DynamicReserveConfigAddition[] memory additions) {
    additions = new IEngine.DynamicReserveConfigAddition[](1);
    additions[0] = IEngine.DynamicReserveConfigAddition({
      spokeConfigurator: SPOKE_CONFIGURATOR,
      spoke: address(pair.spoke),
      hub: address(HUB),
      underlying: pair.underlying,
      dynamicConfig: config
    });
  }

  function _collateralRiskUpdate(
    Pair memory pair,
    uint256 collateralRisk
  ) internal pure returns (IEngine.ReserveConfigUpdate[] memory updates) {
    updates = new IEngine.ReserveConfigUpdate[](1);
    updates[0] = IEngine.ReserveConfigUpdate({
      spokeConfigurator: SPOKE_CONFIGURATOR,
      spoke: address(pair.spoke),
      hub: address(HUB),
      underlying: pair.underlying,
      priceSource: EngineFlags.KEEP_CURRENT_ADDRESS,
      collateralRisk: collateralRisk,
      paused: EngineFlags.KEEP_CURRENT,
      frozen: EngineFlags.KEEP_CURRENT,
      borrowable: EngineFlags.KEEP_CURRENT,
      receiveSharesEnabled: EngineFlags.KEEP_CURRENT
    });
  }

  function _dynamicUpdate(
    Pair memory pair,
    uint256 collateralFactor
  ) internal pure returns (IEngine.DynamicReserveConfigUpdate[] memory updates) {
    updates = new IEngine.DynamicReserveConfigUpdate[](1);
    updates[0] = IEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: SPOKE_CONFIGURATOR,
      spoke: address(pair.spoke),
      hub: address(HUB),
      underlying: pair.underlying,
      dynamicConfigKey: 0,
      collateralFactor: collateralFactor,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
  }

  function _rateUpdate(
    address underlying,
    uint32 baseDrawnRate
  ) internal pure returns (IEngine.AssetConfigUpdate[] memory updates) {
    updates = new IEngine.AssetConfigUpdate[](1);
    updates[0] = IEngine.AssetConfigUpdate({
      hubConfigurator: HUB_CONFIGURATOR,
      hub: address(HUB),
      underlying: underlying,
      liquidityFee: EngineFlags.KEEP_CURRENT,
      feeReceiver: EngineFlags.KEEP_CURRENT_ADDRESS,
      irStrategy: EngineFlags.KEEP_CURRENT_ADDRESS,
      irData: IAssetInterestRateStrategy.InterestRateData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT_UINT16,
        baseDrawnRate: baseDrawnRate,
        rateGrowthBeforeOptimal: EngineFlags.KEEP_CURRENT_UINT32,
        rateGrowthAfterOptimal: EngineFlags.KEEP_CURRENT_UINT32
      }),
      reinvestmentController: EngineFlags.KEEP_CURRENT_ADDRESS
    });
  }

  function _liquidationUpdate(
    ISpoke spoke,
    uint256 targetHealthFactor
  ) internal pure returns (IEngine.LiquidationConfigUpdate[] memory updates) {
    updates = new IEngine.LiquidationConfigUpdate[](1);
    updates[0] = IEngine.LiquidationConfigUpdate({
      spokeConfigurator: SPOKE_CONFIGURATOR,
      spoke: address(spoke),
      targetHealthFactor: targetHealthFactor,
      healthFactorForMaxBonus: EngineFlags.KEEP_CURRENT,
      liquidationBonusFactor: EngineFlags.KEEP_CURRENT
    });
  }

  function _pairs() internal view returns (Pair[] memory pairs) {
    ISpoke[] memory spokes = _spokes();
    pairs = new Pair[](14);
    uint256 count;
    for (uint256 i; i < spokes.length; ++i) {
      uint256 reserveCount = spokes[i].getReserveCount();
      for (uint256 reserveId; reserveId < reserveCount; ++reserveId) {
        pairs[count++] = Pair(spokes[i], _underlying(spokes[i], reserveId));
      }
    }
    assertEq(count, 14, 'pairs');
  }

  function _collateralPairs() internal view returns (Pair[] memory pairs) {
    Pair[] memory all = _pairs();
    pairs = new Pair[](9);
    uint256 count;
    for (uint256 i; i < all.length; ++i) {
      if (!all[i].spoke.getReserveConfig(_reserveId(all[i].spoke, all[i].underlying)).borrowable) {
        pairs[count++] = all[i];
      }
    }
    assertEq(count, 9, 'collateral pairs');
  }
}
