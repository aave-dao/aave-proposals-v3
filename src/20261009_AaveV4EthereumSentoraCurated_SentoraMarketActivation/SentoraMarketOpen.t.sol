// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IHub, ISpoke, INativeTokenGateway} from 'aave-address-book/AaveV4.sol';
import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets, AaveV4EthereumSentoraCuratedPositionManagers} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';
import {IMidasToken, IMidasAccessControl} from './SentoraInterfaces.sol';

/// @dev The market once the activation payload has unhalted it: parameters against the ARFC, and
/// every reserve exercised by a user.
contract SentoraMarketOpen_Test is SentoraTestBase {
  struct ReserveSpec {
    ISpoke spoke;
    address underlying;
    uint16 collateralFactor;
    uint32 maxLiquidationBonus;
    uint16 liquidationFee;
    uint24 collateralRisk;
    bool borrowable;
    uint40 addCap;
    uint40 drawCap;
  }

  INativeTokenGateway internal constant NATIVE_GATEWAY =
    AaveV4EthereumSentoraCuratedPositionManagers.NATIVE_TOKEN_GATEWAY;

  /// @dev Holds DEFAULT_ADMIN_ROLE, the admin of the mWIN greenlist and min-balance exempt roles, on
  /// the Midas access control; it granted the existing mWIN greenlist entries.
  address internal constant MIDAS_ADMIN = 0xd4195CF4df289a4748C1A7B6dDBE770e27bA1227;

  address internal lender = makeAddr('lender');
  address internal borrower = makeAddr('borrower');

  function test_haltedBeforeActivation() public {
    uint256 reserveId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    uint256 amount = 1_000e18;
    deal2(Assets.USDe_UNDERLYING, lender, amount);
    vm.startPrank(lender);
    IERC20(Assets.USDe_UNDERLYING).approve(address(RLUSD_YIELD), amount);
    vm.expectRevert(IHub.SpokeHalted.selector);
    RLUSD_YIELD.supply(reserveId, amount, lender);
    vm.stopPrank();
  }

  function test_parametersMatchSpec() public activated {
    ReserveSpec[] memory specs = _specs();
    for (uint256 i; i < specs.length; ++i) {
      ReserveSpec memory spec = specs[i];
      uint256 assetId = HUB.getAssetId(spec.underlying);
      uint256 reserveId = _reserveId(spec.spoke, spec.underlying);
      ISpoke.Reserve memory reserve = spec.spoke.getReserve(reserveId);
      ISpoke.ReserveConfig memory config = spec.spoke.getReserveConfig(reserveId);
      ISpoke.DynamicReserveConfig memory dynamicConfig = spec.spoke.getDynamicReserveConfig(
        reserveId,
        reserve.dynamicConfigKey
      );
      assertEq(dynamicConfig.collateralFactor, spec.collateralFactor, 'collateral factor');
      assertEq(dynamicConfig.maxLiquidationBonus, spec.maxLiquidationBonus, 'max bonus');
      assertEq(dynamicConfig.liquidationFee, spec.liquidationFee, 'liquidation fee');
      assertEq(config.collateralRisk, spec.collateralRisk, 'collateral risk');
      assertEq(config.borrowable, spec.borrowable, 'borrowable');
      (uint256 addCap, uint256 drawCap, bool active, bool paused) = _launchState(spec);
      assertEq(config.paused, paused, 'paused');
      assertFalse(config.frozen, 'frozen');
      // ARFC silent (D17): every reserve lets liquidators receive shares, as on chain
      assertTrue(config.receiveSharesEnabled, 'receive shares');

      IHub.SpokeConfig memory spokeConfig = HUB.getSpokeConfig(assetId, address(spec.spoke));
      assertEq(spokeConfig.addCap, addCap, 'add cap');
      assertEq(spokeConfig.drawCap, drawCap, 'draw cap');
      // ARFC silent (D17): borrowables carry no premium ceiling (uint24 max), as on chain
      assertEq(
        spokeConfig.riskPremiumThreshold,
        spec.borrowable ? type(uint24).max : 0,
        'risk premium threshold'
      );
      assertEq(spokeConfig.active, active, 'active');
      assertFalse(spokeConfig.halted, 'halted');
    }

    for (uint256 assetId; assetId < ASSET_COUNT; ++assetId) {
      IHub.AssetConfig memory assetConfig = HUB.getAssetConfig(assetId);
      (address underlying, ) = HUB.getAssetUnderlyingAndDecimals(assetId);
      bool borrowable = underlying == Assets.RLUSD_UNDERLYING ||
        underlying == Assets.PYUSD_UNDERLYING ||
        underlying == Assets.OUSD_UNDERLYING;
      assertEq(assetConfig.feeReceiver, address(TREASURY_SPOKE), 'fee receiver');
      assertEq(assetConfig.liquidityFee, borrowable ? 20_00 : 0, 'liquidity fee');
      IAssetInterestRateStrategy.InterestRateData memory rates = IAssetInterestRateStrategy(
        assetConfig.irStrategy
      ).getInterestRateData(assetId);
      assertEq(rates.optimalUsageRatio, 90_00, 'optimal usage');
      assertEq(rates.baseDrawnRate, borrowable ? 50 : 0, 'base rate');
      assertEq(rates.rateGrowthBeforeOptimal, borrowable ? 3_50 : 0, 'slope 1');
      assertEq(rates.rateGrowthAfterOptimal, borrowable ? 12_00 : 0, 'slope 2');

      IHub.SpokeConfig memory treasury = HUB.getSpokeConfig(assetId, address(TREASURY_SPOKE));
      bool mWin = underlying == Assets.mWIN_UNDERLYING;
      assertEq(treasury.addCap, mWin ? 0 : HUB.MAX_ALLOWED_SPOKE_CAP(), 'treasury add cap');
      assertEq(treasury.drawCap, 0, 'treasury draw cap');
      assertEq(treasury.active, !mWin, 'treasury active');
      assertFalse(treasury.halted, 'treasury halted');
    }

    // STATE.md pre-launch config (D15)
    _assertLiquidationConfig(RLUSD_YIELD, 1.047e18);
    _assertLiquidationConfig(OUSD_YIELD, 1.047e18);
    _assertLiquidationConfig(BLUECHIP, 1.143e18);
  }

  function _assertLiquidationConfig(ISpoke spoke, uint256 targetHealthFactor) internal view {
    ISpoke.LiquidationConfig memory liquidation = spoke.getLiquidationConfig();
    assertEq(liquidation.targetHealthFactor, targetHealthFactor, 'target health factor');
    assertEq(liquidation.healthFactorForMaxBonus, 0.99e18, 'health factor for max bonus');
    assertEq(liquidation.liquidationBonusFactor, 100_00, 'liquidation bonus factor');
  }

  /// @dev STATE.md pre-launch config: mWIN is closed (D18) and PST and PRIME launch with 0 caps
  /// (D19); every other pair keeps its ARFC caps.
  function _launchState(
    ReserveSpec memory spec
  ) internal pure returns (uint256 addCap, uint256 drawCap, bool active, bool paused) {
    if (spec.underlying == Assets.mWIN_UNDERLYING) return (0, 0, false, true);
    if (spec.underlying == Assets.PST_UNDERLYING || spec.underlying == Assets.PRIME_UNDERLYING) {
      return (0, 0, true, false);
    }
    return (spec.addCap, spec.drawCap, true, false);
  }

  function test_collateralsSupplyAndWithdraw() public activated {
    _raisePstPrimeCapsThroughSentora();
    ReserveSpec[] memory specs = _specs();
    for (uint256 i; i < specs.length; ++i) {
      if (specs[i].borrowable || specs[i].underlying == Assets.mWIN_UNDERLYING) continue;
      uint256 snapshot = vm.snapshotState();
      ISpoke spoke = specs[i].spoke;
      uint256 reserveId = _reserveId(spoke, specs[i].underlying);
      uint256 amount = _units(spoke, reserveId, specs[i].addCap) / 100;

      _supplyCollateralAs(spoke, reserveId, lender, amount);
      uint256 kept = IERC20(specs[i].underlying).balanceOf(lender);
      assertEq(spoke.getUserSuppliedAssets(reserveId, lender), amount, 'supplied');
      (bool usingAsCollateral, ) = spoke.getUserReserveStatus(reserveId, lender);
      assertTrue(usingAsCollateral, 'collateral');
      assertGt(spoke.getUserAccountData(lender).totalCollateralValue, 0, 'collateral value');

      vm.prank(lender);
      vm.expectRevert(ISpoke.ReserveNotBorrowable.selector);
      spoke.borrow(reserveId, 1, lender);

      vm.prank(lender);
      spoke.withdraw(reserveId, type(uint256).max, lender);
      assertEq(spoke.getUserSuppliedAssets(reserveId, lender), 0, 'withdrawn');
      assertEq(IERC20(specs[i].underlying).balanceOf(lender), kept + amount, 'balance');
      vm.revertToState(snapshot);
    }
  }

  function test_borrowablesSupplyBorrowRepayWithdraw() public activated {
    ReserveSpec[] memory specs = _specs();
    for (uint256 i; i < specs.length; ++i) {
      if (!specs[i].borrowable) continue;
      uint256 snapshot = vm.snapshotState();
      ISpoke spoke = specs[i].spoke;
      address underlying = specs[i].underlying;
      uint256 reserveId = _reserveId(spoke, underlying);
      uint256 supplied = _units(spoke, reserveId, 100_000);
      uint256 borrowed = _units(spoke, reserveId, 50_000);

      _supplyAs(spoke, reserveId, lender, supplied);
      assertEq(spoke.getUserSuppliedAssets(reserveId, lender), supplied, 'supplied');

      (address collateral, uint256 collateralAmount) = spoke == BLUECHIP
        ? (Assets.kBTC_UNDERLYING, 2e8)
        : (Assets.USDe_UNDERLYING, 100_000e18);
      uint256 collateralId = _reserveId(spoke, collateral);
      _supplyCollateralAs(spoke, collateralId, borrower, collateralAmount);

      _borrowAs(spoke, reserveId, borrower, borrowed);
      assertEq(IERC20(underlying).balanceOf(borrower), borrowed, 'borrowed');
      assertEq(spoke.getUserTotalDebt(reserveId, borrower), borrowed, 'debt');

      vm.warp(block.timestamp + 30 days);
      uint256 debt = spoke.getUserTotalDebt(reserveId, borrower);
      assertGt(debt, borrowed, 'interest');
      deal2(underlying, borrower, debt);
      vm.startPrank(borrower);
      IERC20(underlying).approve(address(spoke), debt);
      spoke.repay(reserveId, type(uint256).max, borrower);
      spoke.withdraw(collateralId, type(uint256).max, borrower);
      vm.stopPrank();
      assertEq(spoke.getUserTotalDebt(reserveId, borrower), 0, 'repaid');
      assertEq(IERC20(underlying).balanceOf(borrower), 0, 'repay pulled the debt');
      assertEq(IERC20(collateral).balanceOf(borrower), collateralAmount, 'collateral back');

      uint256 lenderAssets = spoke.getUserSuppliedAssets(reserveId, lender);
      assertGt(lenderAssets, supplied, 'lender earned');
      vm.prank(lender);
      spoke.withdraw(reserveId, type(uint256).max, lender);
      assertEq(IERC20(underlying).balanceOf(lender), lenderAssets, 'lender withdrew');
      vm.revertToState(snapshot);
    }
  }

  function test_borrowablesAreNotCollateral() public activated {
    ReserveSpec[] memory specs = _specs();
    for (uint256 i; i < specs.length; ++i) {
      if (!specs[i].borrowable) continue;
      uint256 snapshot = vm.snapshotState();
      ISpoke spoke = specs[i].spoke;
      uint256 reserveId = _reserveId(spoke, specs[i].underlying);
      _supplyCollateralAs(spoke, reserveId, borrower, _units(spoke, reserveId, 10_000));
      assertEq(spoke.getUserAccountData(borrower).totalCollateralValue, 0, 'collateral value');

      vm.prank(borrower);
      vm.expectRevert(ISpoke.HealthFactorBelowThreshold.selector);
      spoke.borrow(reserveId, 1, borrower);
      vm.revertToState(snapshot);
    }
  }

  function test_nativeGatewayRejectsEveryReserve() public activated {
    vm.expectRevert(IHub.AssetNotListed.selector);
    HUB.getAssetId(AaveV3EthereumAssets.WETH_UNDERLYING);

    vm.deal(borrower, 1 ether);
    ISpoke[] memory spokes = _spokes();
    for (uint256 i; i < spokes.length; ++i) {
      address spoke = address(spokes[i]);
      uint256 reserveCount = spokes[i].getReserveCount();
      for (uint256 reserveId; reserveId < reserveCount; ++reserveId) {
        vm.startPrank(borrower);
        vm.expectRevert(INativeTokenGateway.NotNativeWrappedAsset.selector);
        NATIVE_GATEWAY.supplyNative{value: 1 ether}(spoke, reserveId, 1 ether);
        vm.expectRevert(INativeTokenGateway.NotNativeWrappedAsset.selector);
        NATIVE_GATEWAY.supplyAsCollateralNative{value: 1 ether}(spoke, reserveId, 1 ether);
        vm.expectRevert(INativeTokenGateway.NotNativeWrappedAsset.selector);
        NATIVE_GATEWAY.withdrawNative(spoke, reserveId, 1 ether);
        vm.expectRevert(INativeTokenGateway.NotNativeWrappedAsset.selector);
        NATIVE_GATEWAY.borrowNative(spoke, reserveId, 1 ether);
        vm.expectRevert(INativeTokenGateway.NotNativeWrappedAsset.selector);
        NATIVE_GATEWAY.repayNative{value: 1 ether}(spoke, reserveId, 1 ether);
        vm.stopPrank();
      }
    }
  }

  /// @dev Midas onboarding of the Hub and the lender is simulated so the mWIN transfer clears the
  /// token's greenlist and the Hub's inactive check is reached once the Spoke pause is lifted.
  function test_mWinClosed() public activated {
    uint256 assetId = HUB.getAssetId(Assets.mWIN_UNDERLYING);
    uint256 spokeCount = HUB.getSpokeCount(assetId);
    assertEq(spokeCount, 3, 'mWIN pairs');
    for (uint256 i; i < spokeCount; ++i) {
      IHub.SpokeConfig memory config = HUB.getSpokeConfig(assetId, HUB.getSpokeAddress(assetId, i));
      assertFalse(config.active, 'active');
      assertEq(config.addCap, 0, 'add cap');
      assertEq(config.drawCap, 0, 'draw cap');
    }

    IMidasToken mWin = IMidasToken(Assets.mWIN_UNDERLYING);
    IMidasAccessControl midas = IMidasAccessControl(mWin.accessControl());
    bytes32 greenlisted = mWin.M_WIN_GREENLISTED_ROLE();
    vm.startPrank(MIDAS_ADMIN);
    midas.grantRole(greenlisted, address(HUB));
    midas.grantRole(mWin.M_WIN_MIN_BALANCE_EXEMPT_ROLE(), address(HUB));
    midas.grantRole(greenlisted, lender);
    vm.stopPrank();

    ISpoke[2] memory spokes = [RLUSD_YIELD, OUSD_YIELD];
    for (uint256 i; i < spokes.length; ++i) {
      uint256 reserveId = _reserveId(spokes[i], Assets.mWIN_UNDERLYING);
      assertTrue(spokes[i].getReserveConfig(reserveId).paused, 'paused');
      deal(Assets.mWIN_UNDERLYING, lender, 1e18);
      vm.startPrank(lender);
      IERC20(Assets.mWIN_UNDERLYING).approve(address(spokes[i]), 1e18);
      vm.expectRevert(ISpoke.ReservePaused.selector);
      spokes[i].supply(reserveId, 1e18, lender);
      vm.expectRevert(ISpoke.ReservePaused.selector);
      spokes[i].setUsingAsCollateral(reserveId, true, lender);
      vm.expectRevert(ISpoke.ReservePaused.selector);
      spokes[i].withdraw(reserveId, 1e18, lender);
      vm.expectRevert(ISpoke.ReservePaused.selector);
      spokes[i].borrow(reserveId, 1e18, lender);
      vm.stopPrank();

      vm.prank(COUNCIL_EXECUTOR);
      SPOKE_CONFIGURATOR.updatePaused(address(spokes[i]), reserveId, false);
      vm.prank(lender);
      vm.expectRevert(IHub.SpokeNotActive.selector);
      spokes[i].supply(reserveId, 1e18, lender);
    }
  }

  function test_pstPrimeCapsClosed() public activated {
    address[2] memory underlyings = [Assets.PST_UNDERLYING, Assets.PRIME_UNDERLYING];
    ISpoke[2] memory spokes = [RLUSD_YIELD, OUSD_YIELD];
    for (uint256 u; u < underlyings.length; ++u) {
      for (uint256 i; i < spokes.length; ++i) {
        uint256 reserveId = _reserveId(spokes[i], underlyings[u]);
        uint256 amount = _units(spokes[i], reserveId, 1);
        deal2(underlyings[u], lender, amount);
        vm.startPrank(lender);
        IERC20(underlyings[u]).approve(address(spokes[i]), amount);
        vm.expectRevert(abi.encodeWithSelector(IHub.AddCapExceeded.selector, 0));
        spokes[i].supply(reserveId, amount, lender);
        vm.stopPrank();
      }
    }
  }

  /// @dev ARFC "Spoke Parameters" and "Add & Draw Caps" tables; borrowables carry no collateral
  /// config in the ARFC, so their 0 collateral factor, 100.00% bonus and 0 fee are as on chain.
  function _specs() internal pure returns (ReserveSpec[] memory s) {
    s = new ReserveSpec[](14);
    s[0] = _borrowable(RLUSD_YIELD, Assets.RLUSD_UNDERLYING, 100_000_000, 90_000_000);
    s[1] = _usde(RLUSD_YIELD, 50_000_000);
    s[2] = _prime(RLUSD_YIELD, 15_000_000);
    s[3] = _mWin(RLUSD_YIELD, 75);
    s[4] = _pst(RLUSD_YIELD, 20_000_000);
    s[5] = _borrowable(OUSD_YIELD, Assets.OUSD_UNDERLYING, 10_000_000, 9_000_000);
    s[6] = _usde(OUSD_YIELD, 5_000_000);
    s[7] = _prime(OUSD_YIELD, 1_500_000);
    s[8] = _mWin(OUSD_YIELD, 7);
    s[9] = _pst(OUSD_YIELD, 2_000_000);
    s[10] = _borrowable(BLUECHIP, Assets.RLUSD_UNDERLYING, 33_300_000, 30_000_000);
    s[11] = _borrowable(BLUECHIP, Assets.PYUSD_UNDERLYING, 33_300_000, 30_000_000);
    s[12] = _borrowable(BLUECHIP, Assets.OUSD_UNDERLYING, 5_000_000, 4_500_000);
    s[13] = ReserveSpec(BLUECHIP, Assets.kBTC_UNDERLYING, 86_00, 104_50, 4_50, 0, false, 580, 0);
  }

  function _borrowable(
    ISpoke spoke,
    address underlying,
    uint40 addCap,
    uint40 drawCap
  ) internal pure returns (ReserveSpec memory) {
    return ReserveSpec(spoke, underlying, 0, 100_00, 0, 0, true, addCap, drawCap);
  }

  function _usde(ISpoke spoke, uint40 addCap) internal pure returns (ReserveSpec memory) {
    return ReserveSpec(spoke, Assets.USDe_UNDERLYING, 91_50, 103_50, 3_50, 6_25, false, addCap, 0);
  }

  function _prime(ISpoke spoke, uint40 addCap) internal pure returns (ReserveSpec memory) {
    return
      ReserveSpec(spoke, Assets.PRIME_UNDERLYING, 89_50, 105_00, 5_00, 18_75, false, addCap, 0);
  }

  function _mWin(ISpoke spoke, uint40 addCap) internal pure returns (ReserveSpec memory) {
    return ReserveSpec(spoke, Assets.mWIN_UNDERLYING, 84_60, 107_50, 7_50, 0, false, addCap, 0);
  }

  function _pst(ISpoke spoke, uint40 addCap) internal pure returns (ReserveSpec memory) {
    return ReserveSpec(spoke, Assets.PST_UNDERLYING, 87_50, 105_00, 5_00, 75_00, false, addCap, 0);
  }
}
