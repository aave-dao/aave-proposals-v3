// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {ISpoke, IAaveOracle} from 'aave-address-book/AaveV4.sol';
import {Math} from 'aave-v4/dependencies/openzeppelin/Math.sol';
import {MathUtils} from 'aave-v4/libraries/math/MathUtils.sol';
import {WadRayMath} from 'aave-v4/libraries/math/WadRayMath.sol';
import {PercentageMath} from 'aave-v4/libraries/math/PercentageMath.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';

/// @dev Liquidations on RLUSD Yield against RLUSD debt, with the collateral price mocked down.
/// Expected amounts replay the Spoke's LiquidationLogic arithmetic on the pre-liquidation state;
/// everything runs in one block, so the borrower carries no premium debt.
contract SentoraLiquidation_Test is SentoraTestBase {
  using MathUtils for uint256;
  using WadRayMath for uint256;
  using PercentageMath for uint256;

  struct State {
    uint256 collateralShares;
    uint256 drawnShares;
    uint256 drawnIndex;
    uint256 collateralPrice;
    uint256 debtPrice;
    uint256 treasuryShares;
    uint256 healthFactor;
    uint256 bonus;
  }

  uint256 internal constant PERCENTAGE_FACTOR = 100_00;

  address internal borrower = makeAddr('borrower');
  address internal liquidator = makeAddr('liquidator');

  uint256 internal debtId;
  uint256 internal debtAssetId;

  function setUp() public override {
    super.setUp();
    _activate();
    debtId = _reserveId(RLUSD_YIELD, Assets.RLUSD_UNDERLYING);
    debtAssetId = HUB.getAssetId(Assets.RLUSD_UNDERLYING);
    _supplyAs(RLUSD_YIELD, debtId, makeAddr('lender'), 1_000_000e18);
  }

  /// @dev Below the 0.99 health factor for max bonus the USDe bonus is the full 103.50%. The ~0.864
  /// health factor is under 91.50% x 103.50% = 94.70%, so the collateral cannot cover the debt plus
  /// bonus: all collateral is seized and the remaining debt is reported as deficit.
  function test_liquidation_usdeMaxBonus() public {
    uint256 collateralId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    uint256 collateralAssetId = HUB.getAssetId(Assets.USDe_UNDERLYING);
    _supplyCollateralAs(RLUSD_YIELD, collateralId, borrower, 10_000e18);
    _borrowAs(RLUSD_YIELD, debtId, borrower, 9_000e18);
    _mockSourcePrice(RLUSD_YIELD, collateralId, 0.85e8);

    State memory s = _state(collateralId, collateralAssetId);
    assertLe(s.healthFactor, 0.99e18, 'max bonus zone');
    assertEq(s.bonus, 103_50, 'max liquidation bonus');

    uint256 debtRay = Math.mulDiv(
      HUB.previewAddByShares(collateralAssetId, s.collateralShares),
      s.collateralPrice * 1e18 * PERCENTAGE_FACTOR * WadRayMath.RAY,
      s.debtPrice * 1e18 * s.bonus,
      Math.Rounding.Ceil
    );
    uint256 drawnSharesLiquidated = debtRay.divUp(s.drawnIndex);
    uint256 repaid = drawnSharesLiquidated.rayMulUp(s.drawnIndex);
    uint256 feeShares = _feeShares(s.collateralShares, 3_50, s.bonus);
    uint256 toLiquidator = HUB.previewRemoveByShares(
      collateralAssetId,
      s.collateralShares - feeShares
    );
    uint256 deficitRay = HUB.getAssetDeficitRay(debtAssetId);

    uint256 paid = _liquidate(collateralId);

    assertEq(paid, repaid, 'debt repaid');
    assertEq(RLUSD_YIELD.getUserSuppliedShares(collateralId, borrower), 0, 'collateral seized');
    assertEq(
      IERC20(Assets.USDe_UNDERLYING).balanceOf(liquidator),
      toLiquidator,
      'collateral to liquidator'
    );
    assertEq(
      HUB.getSpokeAddedShares(collateralAssetId, address(TREASURY_SPOKE)) - s.treasuryShares,
      feeShares,
      'protocol fee to treasury'
    );
    assertEq(RLUSD_YIELD.getUserTotalDebt(debtId, borrower), 0, 'debt cleared');
    assertEq(
      HUB.getAssetDeficitRay(debtAssetId) - deficitRay,
      (s.drawnShares - drawnSharesLiquidated) * s.drawnIndex,
      'deficit'
    );
  }

  /// @dev Between the 0.99 health factor for max bonus and 1, the 100% liquidation bonus factor makes
  /// the min bonus equal the max, so the USDe max bonus still applies and the liquidation restores
  /// the target health factor.
  function test_liquidation_usdeMaxBonusAboveHealthFactorForMaxBonus() public {
    uint256 collateralId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    uint256 collateralAssetId = HUB.getAssetId(Assets.USDe_UNDERLYING);
    _supplyCollateralAs(RLUSD_YIELD, collateralId, borrower, 10_000e18);
    _borrowAs(RLUSD_YIELD, debtId, borrower, 9_000e18);
    _mockSourcePrice(RLUSD_YIELD, collateralId, 0.9787e8);

    State memory s = _state(collateralId, collateralAssetId);
    ISpoke.LiquidationConfig memory liquidationConfig = RLUSD_YIELD.getLiquidationConfig();
    ISpoke.DynamicReserveConfig memory collateralConfig = RLUSD_YIELD.getDynamicReserveConfig(
      collateralId,
      RLUSD_YIELD.getUserPosition(collateralId, borrower).dynamicConfigKey
    );
    assertGt(s.healthFactor, liquidationConfig.healthFactorForMaxBonus, 'above max bonus zone');
    assertLt(s.healthFactor, 1e18, 'liquidatable');
    assertEq(s.bonus, collateralConfig.maxLiquidationBonus, 'max liquidation bonus');

    uint256 debtRayToTarget = Math.mulDiv(
      RLUSD_YIELD.getUserAccountData(borrower).totalDebtValueRay,
      1e18 * (liquidationConfig.targetHealthFactor - s.healthFactor),
      (liquidationConfig.targetHealthFactor -
        s.bonus.bpsToWad().percentMulUp(collateralConfig.collateralFactor)) * s.debtPrice.toWad(),
      Math.Rounding.Ceil
    );
    uint256 drawnSharesLiquidated = debtRayToTarget.divUp(s.drawnIndex);
    uint256 collateralShares = HUB.previewAddByAssets(
      collateralAssetId,
      Math.mulDiv(
        drawnSharesLiquidated * s.drawnIndex,
        s.debtPrice * 1e18 * s.bonus,
        1e18 * s.collateralPrice * PERCENTAGE_FACTOR * WadRayMath.RAY,
        Math.Rounding.Floor
      )
    );
    uint256 feeShares = _feeShares(collateralShares, collateralConfig.liquidationFee, s.bonus);

    uint256 paid = _liquidate(collateralId);

    assertEq(paid, drawnSharesLiquidated.rayMulUp(s.drawnIndex), 'debt repaid');
    assertEq(
      RLUSD_YIELD.getUserPosition(debtId, borrower).drawnShares,
      s.drawnShares - drawnSharesLiquidated,
      'drawn shares left'
    );
    assertEq(
      s.collateralShares - RLUSD_YIELD.getUserSuppliedShares(collateralId, borrower),
      collateralShares,
      'collateral seized'
    );
    assertEq(
      IERC20(Assets.USDe_UNDERLYING).balanceOf(liquidator),
      HUB.previewRemoveByShares(collateralAssetId, collateralShares - feeShares),
      'collateral to liquidator'
    );
    assertEq(
      HUB.getSpokeAddedShares(collateralAssetId, address(TREASURY_SPOKE)) - s.treasuryShares,
      feeShares,
      'protocol fee to treasury'
    );
    assertGe(
      RLUSD_YIELD.getUserAccountData(borrower).healthFactor,
      liquidationConfig.targetHealthFactor,
      'target health factor'
    );
  }

  /// @dev PST launches with 0 caps, so a Sentora payload raises them first. With a 100% liquidation
  /// bonus factor the bonus is the 105.00% max at any health factor below 1, and the liquidation
  /// stops at the 1.047 target health factor.
  function test_liquidation_pstPartial() public {
    _raisePstPrimeCapsThroughSentora();
    uint256 collateralId = _reserveId(RLUSD_YIELD, Assets.PST_UNDERLYING);
    uint256 collateralAssetId = HUB.getAssetId(Assets.PST_UNDERLYING);
    _supplyCollateralAs(RLUSD_YIELD, collateralId, borrower, 100_000e6);
    _borrowAs(RLUSD_YIELD, debtId, borrower, 90_000e18);
    _mockSourcePrice(RLUSD_YIELD, collateralId, 0.977e8);

    State memory s = _state(collateralId, collateralAssetId);
    assertLt(s.healthFactor, 1e18, 'liquidatable');
    uint256 minBonus = (105_00 - PERCENTAGE_FACTOR).percentMulDown(100_00) + PERCENTAGE_FACTOR;
    assertEq(minBonus, 105_00, 'min bonus is the max bonus');
    assertEq(s.bonus, 105_00, 'bonus');

    uint256 paid = _liquidate(collateralId);

    uint256 drawnSharesLiquidated = s.drawnShares -
      RLUSD_YIELD.getUserPosition(debtId, borrower).drawnShares;
    assertEq(paid, drawnSharesLiquidated.rayMulUp(s.drawnIndex), 'debt repaid');
    uint256 collateralShares = HUB.previewAddByAssets(
      collateralAssetId,
      Math.mulDiv(
        drawnSharesLiquidated * s.drawnIndex,
        s.debtPrice * 1e6 * s.bonus,
        1e18 * s.collateralPrice * PERCENTAGE_FACTOR * WadRayMath.RAY,
        Math.Rounding.Floor
      )
    );
    uint256 feeShares = _feeShares(collateralShares, 5_00, s.bonus);
    assertEq(
      s.collateralShares - RLUSD_YIELD.getUserSuppliedShares(collateralId, borrower),
      collateralShares,
      'collateral seized'
    );
    assertEq(
      IERC20(Assets.PST_UNDERLYING).balanceOf(liquidator),
      HUB.previewRemoveByShares(collateralAssetId, collateralShares - feeShares),
      'collateral to liquidator'
    );
    assertEq(
      HUB.getSpokeAddedShares(collateralAssetId, address(TREASURY_SPOKE)) - s.treasuryShares,
      feeShares,
      'protocol fee to treasury'
    );
    assertGe(
      RLUSD_YIELD.getUserAccountData(borrower).healthFactor,
      RLUSD_YIELD.getLiquidationConfig().targetHealthFactor,
      'target health factor'
    );
  }

  function test_liquidation_revertsWhenHealthy() public {
    uint256 collateralId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    _supplyCollateralAs(RLUSD_YIELD, collateralId, borrower, 10_000e18);
    _borrowAs(RLUSD_YIELD, debtId, borrower, 9_000e18);

    deal2(Assets.RLUSD_UNDERLYING, liquidator, 10_000e18);
    vm.startPrank(liquidator);
    IERC20(Assets.RLUSD_UNDERLYING).approve(address(RLUSD_YIELD), 10_000e18);
    vm.expectRevert(ISpoke.HealthFactorNotBelowThreshold.selector);
    RLUSD_YIELD.liquidationCall(collateralId, debtId, borrower, type(uint256).max, false);
    vm.stopPrank();
  }

  function _state(
    uint256 collateralId,
    uint256 collateralAssetId
  ) internal view returns (State memory s) {
    IAaveOracle oracle = IAaveOracle(RLUSD_YIELD.ORACLE());
    (, uint256 premiumDebt) = RLUSD_YIELD.getUserDebt(debtId, borrower);
    assertEq(premiumDebt, 0, 'no premium debt');
    s.collateralShares = RLUSD_YIELD.getUserSuppliedShares(collateralId, borrower);
    s.drawnShares = RLUSD_YIELD.getUserPosition(debtId, borrower).drawnShares;
    s.drawnIndex = HUB.getAssetDrawnIndex(debtAssetId);
    s.collateralPrice = oracle.getReservePrice(collateralId);
    s.debtPrice = oracle.getReservePrice(debtId);
    s.treasuryShares = HUB.getSpokeAddedShares(collateralAssetId, address(TREASURY_SPOKE));
    s.healthFactor = RLUSD_YIELD.getUserAccountData(borrower).healthFactor;
    s.bonus = RLUSD_YIELD.getLiquidationBonus(collateralId, borrower, s.healthFactor);
  }

  function _liquidate(uint256 collateralId) internal returns (uint256 paid) {
    uint256 budget = 200_000e18;
    deal2(Assets.RLUSD_UNDERLYING, liquidator, budget);
    vm.startPrank(liquidator);
    IERC20(Assets.RLUSD_UNDERLYING).approve(address(RLUSD_YIELD), budget);
    RLUSD_YIELD.liquidationCall(collateralId, debtId, borrower, type(uint256).max, false);
    vm.stopPrank();
    paid = budget - IERC20(Assets.RLUSD_UNDERLYING).balanceOf(liquidator);
  }

  /// @dev The protocol keeps `liquidationFee` of the bonus portion of the seized collateral.
  function _feeShares(
    uint256 seizedShares,
    uint256 liquidationFee,
    uint256 bonus
  ) internal pure returns (uint256) {
    return
      seizedShares.mulDivUp(
        liquidationFee * (bonus - PERCENTAGE_FACTOR),
        bonus * PERCENTAGE_FACTOR
      );
  }
}
