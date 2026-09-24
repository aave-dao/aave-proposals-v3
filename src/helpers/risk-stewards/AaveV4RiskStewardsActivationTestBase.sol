// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {ProtocolV4TestBase} from 'aave-helpers/src/ProtocolV4TestBase.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IAaveV4ConfigEngine as IConfigEngine, IAccessManagerEnumerable, IHub, IHubConfigurator, ISpoke} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';
import {RiskStewardV4Config} from 'src/helpers/risk-stewards/RiskStewardV4Config.sol';
import {IPendlePriceCapAdapter} from 'src/interfaces/IPendlePriceCapAdapter.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskSteward} from 'src/interfaces/IRiskSteward.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';

/**
 * @dev Common base for the per-network "Aave V4 Risk Stewards Activation" proposal tests.
 *      Each network only provides its addresses (via the internal getters below), the fork, the
 *      proposal deployment and its own `test_defaultProposalExecution`; every assertion lives here
 *      so the three networks stay in sync.
 */
abstract contract AaveV4RiskStewardsActivationTestBase is ProtocolV4TestBase {
  IProposalGenericExecutor internal proposal;
  IRiskStewardV4 internal steward;

  function _createFork() internal virtual;

  function _deployProposal() internal virtual returns (IProposalGenericExecutor);

  function _executor() internal view virtual returns (address);

  function _riskSteward() internal view virtual returns (address);

  function _v3RiskSteward() internal view virtual returns (IRiskSteward);

  function _aclManager() internal view virtual returns (IACLManager);

  function _hubConfigurator() internal view virtual returns (IHubConfigurator);

  function _hub() internal view virtual returns (IHub);

  function _spoke() internal view virtual returns (ISpoke);

  function _asset() internal view virtual returns (address);

  function _lstAdapter() internal view virtual returns (IPriceCapAdapter);

  function _stableAdapter() internal view virtual returns (IPriceCapAdapterStable);

  /// @dev networks with no Pendle price source leave this at zero, which skips the Pendle tests
  function _pendleAdapter() internal view virtual returns (IPendlePriceCapAdapter) {
    return IPendlePriceCapAdapter(address(0));
  }

  function setUp() public virtual {
    _createFork();
    proposal = _deployProposal();
    steward = IRiskStewardV4(_riskSteward());
  }

  modifier activated() {
    _activate();
    _;
  }

  function _activate() internal {
    GovV3Helpers.executePayload(vm, address(proposal));
  }

  function test_stewardOwnerAndCouncil() public view {
    assertEq(steward.owner(), _executor(), 'owner mismatch');
    assertEq(
      steward.RISK_COUNCIL(),
      _v3RiskSteward().RISK_COUNCIL(),
      'council diverges from the v3 risk steward'
    );
  }

  function test_rolesGranted() public {
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(_accessManager());
    uint64[] memory allRoles = _allRoles();

    for (uint256 i; i < allRoles.length; ++i) {
      (bool hasRole, ) = accessManager.hasRole(allRoles[i], _riskSteward());
      assertFalse(
        hasRole,
        string.concat('role held before activation: ', vm.toString(allRoles[i]))
      );
    }
    assertFalse(_aclManager().isRiskAdmin(_riskSteward()), 'risk admin held before activation');

    _activate();

    for (uint256 i; i < allRoles.length; ++i) {
      bool expected = allRoles[i] == Roles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE ||
        allRoles[i] == Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
      (bool hasRole, uint32 delay) = accessManager.hasRole(allRoles[i], _riskSteward());
      assertEq(hasRole, expected, string.concat('unexpected role: ', vm.toString(allRoles[i])));
      if (expected) {
        assertEq(uint256(delay), 0, string.concat('role delay: ', vm.toString(allRoles[i])));
      }
    }

    assertTrue(_aclManager().isRiskAdmin(_riskSteward()), 'risk admin role not granted');
    assertFalse(_aclManager().isPoolAdmin(_riskSteward()), 'pool admin granted');
    assertFalse(_aclManager().isEmergencyAdmin(_riskSteward()), 'emergency admin granted');
    assertFalse(_aclManager().isAssetListingAdmin(_riskSteward()), 'asset listing admin granted');
    assertFalse(_aclManager().isBridge(_riskSteward()), 'bridge granted');
    assertFalse(_aclManager().isFlashBorrower(_riskSteward()), 'flash borrower granted');
  }

  function test_allRolesMatchesAccessManager() public view {
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(_accessManager());
    uint64[] memory onchainRoles = accessManager.getRoles(0, accessManager.getRoleCount());
    uint64[] memory allRoles = _allRoles();

    // the AccessManager does not enumerate ACCESS_MANAGER_ADMIN_ROLE
    assertEq(allRoles[0], Roles.ACCESS_MANAGER_ADMIN_ROLE, 'admin role not first');
    assertEq(onchainRoles.length, allRoles.length - 1, 'role count mismatch');
    for (uint256 i; i < onchainRoles.length; ++i) {
      bool listed;
      for (uint256 j = 1; j < allRoles.length; ++j) {
        listed = listed || allRoles[j] == onchainRoles[i];
      }
      assertTrue(listed, string.concat('role not listed: ', vm.toString(onchainRoles[i])));
    }
  }

  /// @dev `Roles` exposes no enumeration, so this mirrors every id it defines. PUBLIC_ROLE is left
  /// out: the AccessManager holds it for every address by construction.
  function _allRoles() internal pure returns (uint64[] memory) {
    uint64[] memory roles = new uint64[](10);
    roles[0] = Roles.ACCESS_MANAGER_ADMIN_ROLE;
    roles[1] = Roles.HUB_DOMAIN_ADMIN_ROLE;
    roles[2] = Roles.HUB_CONFIGURATOR_ROLE;
    roles[3] = Roles.HUB_FEE_MINTER_ROLE;
    roles[4] = Roles.HUB_DEFICIT_ELIMINATOR_ROLE;
    roles[5] = Roles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
    roles[6] = Roles.SPOKE_DOMAIN_ADMIN_ROLE;
    roles[7] = Roles.SPOKE_CONFIGURATOR_ROLE;
    roles[8] = Roles.SPOKE_USER_POSITION_UPDATER_ROLE;
    roles[9] = Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
    return roles;
  }

  function test_riskStewardConfig() public {
    IRiskStewardV4.Config memory empty;
    assertEq(abi.encode(steward.getConfig()), abi.encode(empty), 'config set before activation');

    _activate();

    _assertConfig(steward.getConfig());
    assertEq(
      abi.encode(steward.getConfig()),
      abi.encode(RiskStewardV4Config.defaultConfig(_hubConfigurator(), _spokeConfigurator())),
      'config diverges from the shared configuration'
    );
  }

  /// @dev Covers the bounds LlamaRisk carried over from the v3 Risk Steward unchanged. The params
  /// they widened (baseDrawnRate, rateGrowthBeforeOptimal, collateralRisk, the dynamicAdd bounds)
  /// and those with no v3 counterpart are asserted in `_assertConfig` only.
  function test_boundsMatchV3RiskSteward() public activated {
    IRiskSteward.Config memory v3 = _v3RiskSteward().getRiskConfig();
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

    IRiskStewardV4.HubAssetDebounce memory debounce = steward.getHubAssetDebounce(
      address(_hub()),
      _asset()
    );
    assertEq(uint256(debounce.optimalUsageRatio), block.timestamp, 'optimalUsageRatio debounce');
    assertEq(uint256(debounce.baseDrawnRate), block.timestamp, 'baseDrawnRate debounce');
    assertEq(
      uint256(debounce.rateGrowthBeforeOptimal),
      block.timestamp,
      'rateGrowthBeforeOptimal debounce'
    );
    assertEq(
      uint256(debounce.rateGrowthAfterOptimal),
      block.timestamp,
      'rateGrowthAfterOptimal debounce'
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
    uint256 assetId = _hub().getAssetId(_asset());
    IHub.SpokeConfig memory before = _hub().getSpokeConfig(assetId, address(_spoke()));
    uint256 addCap = 2 * uint256(before.addCap);
    uint256 drawCap = 2 * uint256(before.drawCap);

    vm.prank(steward.RISK_COUNCIL());
    steward.updateHubSpokeCaps(_capsUpdate(addCap, drawCap));

    IHub.SpokeConfig memory current = _hub().getSpokeConfig(assetId, address(_spoke()));
    assertEq(uint256(current.addCap), addCap, 'addCap not updated');
    assertEq(uint256(current.drawCap), drawCap, 'drawCap not updated');

    IRiskStewardV4.HubSpokeAssetDebounce memory debounce = steward.getHubSpokeAssetDebounce(
      address(_hub()),
      address(_spoke()),
      _asset()
    );
    assertEq(uint256(debounce.addCap), block.timestamp, 'addCap debounce');
    assertEq(uint256(debounce.drawCap), block.timestamp, 'drawCap debounce');
  }

  function test_riskCouncilCannotUpdateHubSpokeCapsAboveBound() public activated {
    uint256 assetId = _hub().getAssetId(_asset());
    uint256 addCapBefore = _hub().getSpokeConfig(assetId, address(_spoke())).addCap;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateHubSpokeCaps(_capsUpdate(2 * addCapBefore + 1, EngineFlags.KEEP_CURRENT));
  }

  function test_riskCouncilCanUpdateReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint256 collateralRisk = uint256(_spoke().getReserveConfig(reserveId).collateralRisk) + 300_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateReserveConfigs(_reserveConfigUpdate(collateralRisk));

    assertEq(
      uint256(_spoke().getReserveConfig(reserveId).collateralRisk),
      collateralRisk,
      'collateralRisk not updated'
    );
    assertEq(
      uint256(
        steward.getSpokeReserveDebounce(address(_spoke()), address(_hub()), _asset()).collateralRisk
      ),
      block.timestamp,
      'collateralRisk debounce'
    );
  }

  function test_riskCouncilCannotUpdateReserveConfigsAboveBound() public activated {
    uint256 collateralRisk = uint256(_spoke().getReserveConfig(_reserveId()).collateralRisk) +
      300_00 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateReserveConfigs(_reserveConfigUpdate(collateralRisk));
  }

  function test_riskCouncilCanUpdateDynamicReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = _spoke().getReserve(reserveId).dynamicConfigKey;
    ISpoke.DynamicReserveConfig memory before = _spoke().getDynamicReserveConfig(reserveId, key);
    uint256 collateralFactor = uint256(before.collateralFactor) + 50;
    uint256 maxLiquidationBonus = uint256(before.maxLiquidationBonus) + 50;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateDynamicReserveConfigs(
      _dynamicReserveConfigUpdate(key, collateralFactor, maxLiquidationBonus)
    );

    ISpoke.DynamicReserveConfig memory current = _spoke().getDynamicReserveConfig(reserveId, key);
    assertEq(uint256(current.collateralFactor), collateralFactor, 'collateralFactor not updated');
    assertEq(
      uint256(current.maxLiquidationBonus),
      maxLiquidationBonus,
      'maxLiquidationBonus not updated'
    );

    IRiskStewardV4.SpokeDynamicDebounce memory debounce = steward.getSpokeDynamicDebounce(
      address(_spoke()),
      address(_hub()),
      _asset()
    );
    assertEq(uint256(debounce.collateralFactor), block.timestamp, 'collateralFactor debounce');
    assertEq(
      uint256(debounce.maxLiquidationBonus),
      block.timestamp,
      'maxLiquidationBonus debounce'
    );
  }

  function test_riskCouncilCannotUpdateDynamicReserveConfigsAboveBound() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = _spoke().getReserve(reserveId).dynamicConfigKey;
    uint256 collateralFactor = uint256(
      _spoke().getDynamicReserveConfig(reserveId, key).collateralFactor
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
    uint32 keyBefore = _spoke().getReserve(reserveId).dynamicConfigKey;
    ISpoke.DynamicReserveConfig memory added = _spoke().getDynamicReserveConfig(
      reserveId,
      keyBefore
    );
    added.collateralFactor += 5_00;
    added.maxLiquidationBonus += 50;

    vm.prank(steward.RISK_COUNCIL());
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(added));

    uint32 keyAfter = _spoke().getReserve(reserveId).dynamicConfigKey;
    assertEq(uint256(keyAfter), uint256(keyBefore) + 1, 'dynamic config key not bumped');

    ISpoke.DynamicReserveConfig memory current = _spoke().getDynamicReserveConfig(
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

    IRiskStewardV4.SpokeDynamicDebounce memory debounce = steward.getSpokeDynamicDebounce(
      address(_spoke()),
      address(_hub()),
      _asset()
    );
    assertEq(uint256(debounce.collateralFactor), block.timestamp, 'collateralFactor debounce');
    assertEq(
      uint256(debounce.maxLiquidationBonus),
      block.timestamp,
      'maxLiquidationBonus debounce'
    );
  }

  function test_riskCouncilCannotAddDynamicReserveConfigsAboveBound() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = _spoke().getReserve(reserveId).dynamicConfigKey;
    address riskCouncil = steward.RISK_COUNCIL();

    ISpoke.DynamicReserveConfig memory outOfRange = _spoke().getDynamicReserveConfig(
      reserveId,
      key
    );
    outOfRange.collateralFactor += 5_00 + 1;

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(outOfRange));

    outOfRange = _spoke().getDynamicReserveConfig(reserveId, key);
    outOfRange.maxLiquidationBonus += 50 + 1;

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(outOfRange));
  }

  function test_riskCouncilCanUpdateSpokeLiquidationConfigs() public activated {
    ISpoke.LiquidationConfig memory before = _spoke().getLiquidationConfig();
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

    ISpoke.LiquidationConfig memory current = _spoke().getLiquidationConfig();
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

    IRiskStewardV4.SpokeLiquidationDebounce memory debounce = steward.getSpokeLiquidationDebounce(
      address(_spoke())
    );
    assertEq(uint256(debounce.targetHealthFactor), block.timestamp, 'targetHealthFactor debounce');
    assertEq(
      uint256(debounce.healthFactorForMaxBonus),
      block.timestamp,
      'healthFactorForMaxBonus debounce'
    );
    assertEq(
      uint256(debounce.liquidationBonusFactor),
      block.timestamp,
      'liquidationBonusFactor debounce'
    );
  }

  function test_riskCouncilCannotUpdateSpokeLiquidationConfigsAboveBound() public activated {
    uint256 targetHealthFactorBefore = _spoke().getLiquidationConfig().targetHealthFactor;
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

  function test_riskCouncilCanUpdateLstPriceCap() public activated {
    uint16 growthAfter = _lstGrowthWithinBound();
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(growthAfter);
    address riskCouncil = steward.RISK_COUNCIL();

    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);

    assertEq(
      _lstAdapter().getMaxYearlyGrowthRatePercent(),
      growthAfter,
      'maxYearlyGrowthRatePercent not updated'
    );
    assertEq(
      uint256(steward.getOracleDebounce(address(_lstAdapter()))),
      block.timestamp,
      'lst oracle debounce'
    );
  }

  function test_riskCouncilCannotUpdateLstPriceCapAboveBound() public activated {
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(
      _lstGrowthWithinBound() + 1
    );
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);
  }

  /// @dev the whole cooldown cycle on the lst price cap, whose bound carries the 72 hour delay
  function test_riskCouncilCannotUpdateLstPriceCapBeforeCooldown() public activated {
    address riskCouncil = steward.RISK_COUNCIL();
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(_lstGrowthWithinBound());

    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);
    uint256 firstUpdate = block.timestamp;

    skip(72 hours - 1);
    updates = _lstPriceCapUpdate(_lstGrowthWithinBound());
    vm.expectRevert(IRiskStewardV4.DebounceNotRespected.selector);
    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);
    assertEq(
      uint256(steward.getOracleDebounce(address(_lstAdapter()))),
      firstUpdate,
      'debounce moved on a reverted update'
    );

    skip(1);
    uint16 growthAfter = _lstGrowthWithinBound();
    updates = _lstPriceCapUpdate(growthAfter);
    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);

    assertEq(
      _lstAdapter().getMaxYearlyGrowthRatePercent(),
      growthAfter,
      'maxYearlyGrowthRatePercent not updated after the cooldown'
    );
    assertEq(
      uint256(steward.getOracleDebounce(address(_lstAdapter()))),
      block.timestamp,
      'lst oracle debounce not refreshed'
    );
  }

  function test_riskCouncilCanUpdateStablePriceCap() public activated {
    uint256 priceCapBefore = uint256(_stableAdapter().getPriceCap());
    uint256 priceCap = priceCapBefore + (priceCapBefore * 50) / 100_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateStablePriceCaps(_stablePriceCapUpdate(priceCap));

    assertEq(uint256(_stableAdapter().getPriceCap()), priceCap, 'priceCap not updated');
    assertEq(
      uint256(steward.getOracleDebounce(address(_stableAdapter()))),
      block.timestamp,
      'stable oracle debounce'
    );
  }

  function test_riskCouncilCannotUpdateStablePriceCapAboveBound() public activated {
    uint256 priceCapBefore = uint256(_stableAdapter().getPriceCap());
    uint256 priceCap = priceCapBefore + (priceCapBefore * 50) / 100_00 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateStablePriceCaps(_stablePriceCapUpdate(priceCap));
  }

  function test_riskCouncilCanUpdatePendleDiscountRate() public {
    vm.skip(address(_pendleAdapter()) == address(0), 'no pendle price source on this market');
    _activate();
    uint256 discountRate = _pendleAdapter().discountRatePerYear() + 0.025e18;

    vm.prank(steward.RISK_COUNCIL());
    steward.updatePendleDiscountRates(_pendleDiscountRateUpdate(discountRate));

    assertEq(
      uint256(_pendleAdapter().discountRatePerYear()),
      discountRate,
      'discountRate not updated'
    );
    assertEq(
      uint256(steward.getOracleDebounce(address(_pendleAdapter()))),
      block.timestamp,
      'pendle oracle debounce'
    );
  }

  function test_riskCouncilCannotUpdatePendleDiscountRateAboveBound() public {
    vm.skip(address(_pendleAdapter()) == address(0), 'no pendle price source on this market');
    _activate();
    uint256 discountRate = _pendleAdapter().discountRatePerYear() + 0.025e18 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updatePendleDiscountRates(_pendleDiscountRateUpdate(discountRate));
  }

  function _reserveId() internal view returns (uint256) {
    return _spoke().getReserveId(address(_hub()), _hub().getAssetId(_asset()));
  }

  function _currentIrData()
    internal
    view
    returns (IAssetInterestRateStrategy.InterestRateData memory)
  {
    uint256 assetId = _hub().getAssetId(_asset());
    return
      IAssetInterestRateStrategy(_hub().getAssetConfig(assetId).irStrategy).getInterestRateData(
        assetId
      );
  }

  function _lstGrowthWithinBound() internal view returns (uint16) {
    uint16 growth = uint16(_lstAdapter().getMaxYearlyGrowthRatePercent());
    return growth + growth / 20;
  }

  function _irUpdate(
    IAssetInterestRateStrategy.InterestRateData memory irData
  ) internal view returns (IConfigEngine.AssetConfigUpdate[] memory) {
    IConfigEngine.AssetConfigUpdate[] memory updates = new IConfigEngine.AssetConfigUpdate[](1);
    updates[0] = IConfigEngine.AssetConfigUpdate({
      hubConfigurator: _hubConfigurator(),
      hub: address(_hub()),
      underlying: _asset(),
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
  ) internal view returns (IConfigEngine.SpokeConfigUpdate[] memory) {
    IConfigEngine.SpokeConfigUpdate[] memory updates = new IConfigEngine.SpokeConfigUpdate[](1);
    updates[0] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: _hubConfigurator(),
      hub: address(_hub()),
      underlying: _asset(),
      spoke: address(_spoke()),
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
  ) internal view returns (IConfigEngine.ReserveConfigUpdate[] memory) {
    IConfigEngine.ReserveConfigUpdate[] memory updates = new IConfigEngine.ReserveConfigUpdate[](1);
    updates[0] = IConfigEngine.ReserveConfigUpdate({
      spokeConfigurator: _spokeConfigurator(),
      spoke: address(_spoke()),
      hub: address(_hub()),
      underlying: _asset(),
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
  ) internal view returns (IConfigEngine.DynamicReserveConfigUpdate[] memory) {
    IConfigEngine.DynamicReserveConfigUpdate[]
      memory updates = new IConfigEngine.DynamicReserveConfigUpdate[](1);
    updates[0] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: _spokeConfigurator(),
      spoke: address(_spoke()),
      hub: address(_hub()),
      underlying: _asset(),
      dynamicConfigKey: dynamicConfigKey,
      collateralFactor: collateralFactor,
      maxLiquidationBonus: maxLiquidationBonus,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _dynamicReserveConfigAddition(
    ISpoke.DynamicReserveConfig memory dynamicConfig
  ) internal view returns (IConfigEngine.DynamicReserveConfigAddition[] memory) {
    IConfigEngine.DynamicReserveConfigAddition[]
      memory additions = new IConfigEngine.DynamicReserveConfigAddition[](1);
    additions[0] = IConfigEngine.DynamicReserveConfigAddition({
      spokeConfigurator: _spokeConfigurator(),
      spoke: address(_spoke()),
      hub: address(_hub()),
      underlying: _asset(),
      dynamicConfig: dynamicConfig
    });
    return additions;
  }

  function _liquidationConfigUpdate(
    uint256 targetHealthFactor,
    uint256 healthFactorForMaxBonus,
    uint256 liquidationBonusFactor
  ) internal view returns (IConfigEngine.LiquidationConfigUpdate[] memory) {
    IConfigEngine.LiquidationConfigUpdate[]
      memory updates = new IConfigEngine.LiquidationConfigUpdate[](1);
    updates[0] = IConfigEngine.LiquidationConfigUpdate({
      spokeConfigurator: _spokeConfigurator(),
      spoke: address(_spoke()),
      targetHealthFactor: targetHealthFactor,
      healthFactorForMaxBonus: healthFactorForMaxBonus,
      liquidationBonusFactor: liquidationBonusFactor
    });
    return updates;
  }

  function _lstPriceCapUpdate(
    uint16 maxYearlyRatioGrowthPercent
  ) internal view returns (IRiskStewardV4.PriceCapLstUpdate[] memory) {
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = new IRiskStewardV4.PriceCapLstUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapLstUpdate({
      oracle: address(_lstAdapter()),
      priceCapUpdateParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: uint104(uint256(_lstAdapter().getRatio())),
        snapshotTimestamp: uint48(block.timestamp - _lstAdapter().MINIMUM_SNAPSHOT_DELAY()),
        maxYearlyRatioGrowthPercent: maxYearlyRatioGrowthPercent
      })
    });
    return updates;
  }

  function _stablePriceCapUpdate(
    uint256 priceCap
  ) internal view returns (IRiskStewardV4.PriceCapStableUpdate[] memory) {
    IRiskStewardV4.PriceCapStableUpdate[]
      memory updates = new IRiskStewardV4.PriceCapStableUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapStableUpdate({
      oracle: address(_stableAdapter()),
      priceCap: priceCap
    });
    return updates;
  }

  function _pendleDiscountRateUpdate(
    uint256 discountRate
  ) internal view returns (IRiskStewardV4.DiscountRatePendleUpdate[] memory) {
    IRiskStewardV4.DiscountRatePendleUpdate[]
      memory updates = new IRiskStewardV4.DiscountRatePendleUpdate[](1);
    updates[0] = IRiskStewardV4.DiscountRatePendleUpdate({
      oracle: address(_pendleAdapter()),
      discountRate: discountRate
    });
    return updates;
  }

  function _assertConfig(IRiskStewardV4.Config memory config) internal view {
    assertEq(
      address(config.hub.configurator),
      address(_hubConfigurator()),
      'hub configurator mismatch'
    );
    assertEq(
      address(config.spoke.configurator),
      address(_spokeConfigurator()),
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
