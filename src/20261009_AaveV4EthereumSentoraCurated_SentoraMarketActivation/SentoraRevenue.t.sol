// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IHub} from 'aave-address-book/AaveV4.sol';
import {IAccessManager} from 'aave-v4/dependencies/openzeppelin/IAccessManager.sol';
import {WadRayMath} from 'aave-v4/libraries/math/WadRayMath.sol';
import {PercentageMath} from 'aave-v4/libraries/math/PercentageMath.sol';
import {MathUtils} from 'aave-v4/libraries/math/MathUtils.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';

/// @dev Revenue flows to the TreasurySpoke, the fee receiver of every asset, owned by the Fee Admin.
contract SentoraRevenue_Test is SentoraTestBase {
  using WadRayMath for uint256;
  using PercentageMath for uint256;
  using MathUtils for uint256;

  address internal borrower = makeAddr('borrower');

  uint256 internal rlusdId;
  uint256 internal rlusdAssetId;

  function setUp() public override {
    super.setUp();
    _acceptTreasurySpokeOwnership();
    _activate();
    rlusdId = _reserveId(RLUSD_YIELD, Assets.RLUSD_UNDERLYING);
    rlusdAssetId = HUB.getAssetId(Assets.RLUSD_UNDERLYING);
    _supplyAs(RLUSD_YIELD, rlusdId, makeAddr('lender'), 1_000_000e18);
  }

  function test_liquidityFeeAccrues() public {
    uint256 fees = _accrueOneYear();
    assertEq(HUB.getAssetAccruedFees(rlusdAssetId), fees, 'liquidity fee is 20% of interest');
  }

  /// @dev Accrued liquidity fees only become TreasurySpoke shares through `mintFeeShares`, which is
  /// wired to role 102, and role 102 has no member at launch.
  function test_liquidityFeesNotMintableAtLaunch() public {
    uint256 fees = _accrueOneYear();
    assertEq(HUB.getAssetAccruedFees(rlusdAssetId), fees, 'fees accrued');
    assertEq(
      ACCESS_MANAGER.getTargetFunctionRole(address(HUB), IHub.mintFeeShares.selector),
      HUB_FEE_MINTER_ROLE,
      'mintFeeShares role'
    );
    assertEq(ACCESS_MANAGER.getRoleMemberCount(HUB_FEE_MINTER_ROLE), 0, 'fee minters');

    address[6] memory callers = [
      EXECUTOR,
      SECURITY_COUNCIL,
      FEE_ADMIN,
      EMERGENCY_ADMIN,
      DEPLOYER,
      address(TREASURY_SPOKE)
    ];
    for (uint256 i; i < callers.length; ++i) {
      vm.prank(callers[i]);
      _expectUnauthorized(callers[i]);
      HUB.mintFeeShares(rlusdAssetId);
    }
    assertEq(TREASURY_SPOKE.getSuppliedShares(address(HUB), Assets.RLUSD_UNDERLYING), 0, 'none');
  }

  /// @dev Grants role 102 to a test account, which no part of the spec does, to show the rest of
  /// the path: minted fee shares land on the TreasurySpoke and only the Fee Admin can withdraw.
  function test_feeAdminWithdrawsMintedLiquidityFees() public {
    uint256 fees = _accrueOneYear();
    address feeMinter = makeAddr('feeMinter');
    vm.prank(SECURITY_COUNCIL);
    IAccessManager(address(ACCESS_MANAGER)).grantRole(HUB_FEE_MINTER_ROLE, feeMinter, 0);

    uint256 expectedShares = HUB.previewAddByAssets(rlusdAssetId, fees);
    vm.prank(feeMinter);
    uint256 shares = HUB.mintFeeShares(rlusdAssetId);
    assertEq(shares, expectedShares, 'minted shares');
    assertEq(HUB.getAssetAccruedFees(rlusdAssetId), 0, 'fees minted');
    assertEq(
      TREASURY_SPOKE.getSuppliedShares(address(HUB), Assets.RLUSD_UNDERLYING),
      shares,
      'treasury shares'
    );
    uint256 assets = TREASURY_SPOKE.getSuppliedAssets(address(HUB), Assets.RLUSD_UNDERLYING);
    assertEq(assets, HUB.previewRemoveByShares(rlusdAssetId, shares), 'treasury assets');

    _assertOnlyFeeAdminWithdraws(Assets.RLUSD_UNDERLYING, assets);
  }

  function test_feeAdminWithdrawsLiquidationFee() public {
    uint256 usdeId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    _supplyCollateralAs(RLUSD_YIELD, usdeId, borrower, 10_000e18);
    _borrowAs(RLUSD_YIELD, rlusdId, borrower, 9_000e18);
    _mockSourcePrice(RLUSD_YIELD, usdeId, 0.85e8);
    uint256 usdeAssetId = HUB.getAssetId(Assets.USDe_UNDERLYING);
    uint256 seized = RLUSD_YIELD.getUserSuppliedShares(usdeId, borrower);
    // below the 0.99 health factor for max bonus the full USDe position goes at the 103.50% max bonus, 3.50% fee
    uint256 feeShares = seized.mulDivUp(3_50 * (103_50 - 100_00), 103_50 * 100_00);

    address liquidator = makeAddr('liquidator');
    deal2(Assets.RLUSD_UNDERLYING, liquidator, 20_000e18);
    vm.startPrank(liquidator);
    IERC20(Assets.RLUSD_UNDERLYING).approve(address(RLUSD_YIELD), 20_000e18);
    RLUSD_YIELD.liquidationCall(usdeId, rlusdId, borrower, type(uint256).max, false);
    vm.stopPrank();

    assertEq(RLUSD_YIELD.getUserSuppliedShares(usdeId, borrower), 0, 'all collateral seized');
    assertEq(
      TREASURY_SPOKE.getSuppliedShares(address(HUB), Assets.USDe_UNDERLYING),
      feeShares,
      'fee shares'
    );
    uint256 assets = TREASURY_SPOKE.getSuppliedAssets(address(HUB), Assets.USDe_UNDERLYING);
    assertEq(assets, HUB.previewRemoveByShares(usdeAssetId, feeShares), 'fee assets');
    _assertOnlyFeeAdminWithdraws(Assets.USDe_UNDERLYING, assets);
  }

  function _assertOnlyFeeAdminWithdraws(address underlying, uint256 assets) internal {
    address[4] memory callers = [EXECUTOR, SECURITY_COUNCIL, DEPLOYER, EMERGENCY_ADMIN];
    for (uint256 i; i < callers.length; ++i) {
      vm.prank(callers[i]);
      vm.expectRevert(abi.encodeWithSignature('OwnableUnauthorizedAccount(address)', callers[i]));
      TREASURY_SPOKE.withdraw(address(HUB), underlying, type(uint256).max);
    }

    uint256 balanceBefore = IERC20(underlying).balanceOf(FEE_ADMIN);
    vm.prank(FEE_ADMIN);
    TREASURY_SPOKE.withdraw(address(HUB), underlying, type(uint256).max);
    assertEq(IERC20(underlying).balanceOf(FEE_ADMIN) - balanceBefore, assets, 'withdrawn');
    assertEq(TREASURY_SPOKE.getSuppliedShares(address(HUB), underlying), 0, 'treasury emptied');
  }

  /// @dev Opens a 500k RLUSD borrow, waits a year and returns the fee the Hub derives: the liquidity
  /// fee share of the growth in drawn plus premium owed.
  function _accrueOneYear() internal returns (uint256) {
    _openBorrow();
    assertEq(HUB.getAssetAccruedFees(rlusdAssetId), 0, 'no fees at borrow');
    uint256 owedRayBefore = _aggregatedOwedRay();
    vm.warp(block.timestamp + 365 days);
    uint256 interest = _aggregatedOwedRay().fromRayUp() - owedRayBefore.fromRayUp();
    assertGt(interest, 0, 'interest');
    return interest.percentMulDown(20_00);
  }

  function _openBorrow() internal {
    uint256 usdeId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    _supplyCollateralAs(RLUSD_YIELD, usdeId, borrower, 1_000_000e18);
    _borrowAs(RLUSD_YIELD, rlusdId, borrower, 500_000e18);
  }

  /// @dev Same aggregate the Hub derives fees from: drawn plus premium (no deficit here), in RAY.
  function _aggregatedOwedRay() internal view returns (uint256) {
    assertEq(HUB.getAssetDeficitRay(rlusdAssetId), 0, 'no deficit');
    return
      HUB.getAssetDrawnShares(rlusdAssetId) *
      HUB.getAssetDrawnIndex(rlusdAssetId) +
      HUB.getAssetPremiumRay(rlusdAssetId);
  }
}
