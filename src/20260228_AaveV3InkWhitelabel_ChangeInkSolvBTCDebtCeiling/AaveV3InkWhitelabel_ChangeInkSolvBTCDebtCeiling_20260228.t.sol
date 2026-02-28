// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228} from './AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260228_AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling/AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228.t.sol -vv
 */
contract AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228_Test is ProtocolV3TestBase {
  AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228 internal proposal;
  address internal solBTCHolder = address(0x6CBAF2ae5a1034757DC6F77B42873e9580f211f6);
  address internal aWETHHolder = address(0xFe4841A4615b8132E6E116A033cA39333c63d121);
  address solvBTC_underlying = address(0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3); // Ink SolvBTC update with import from address-book when available

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 38737734);
    proposal = new AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228();
  }

  /**
   * @notice Tests that borrowing with SolvBTC as collateral before debt ceiling change must fail.
   */
  function test_beforeChangeBorrowWithSolvBTCAsCollateralMustFail() public {
    vm.startPrank(solBTCHolder);
    vm.expectRevert();
    AaveV3InkWhitelabel.POOL.borrow(
      AaveV3InkWhitelabelAssets.GHO_UNDERLYING,
      100 ether,
      2,
      0,
      solBTCHolder
    );
    vm.stopPrank();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      true,
      true
    );
  }

  /**
   * @notice Tests that borrowing with SolvBTC as collateral after debt ceiling change succeeds.
   */
  function test_afterChangeBorrowWithSolvBTCAsCollateralSucceeds() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    skip(3600);
    assertEq(IERC20(AaveV3InkWhitelabelAssets.GHO_V_TOKEN).balanceOf(solBTCHolder), 0);
    vm.startPrank(solBTCHolder);
    AaveV3InkWhitelabel.POOL.setUserUseReserveAsCollateral(solvBTC_underlying, true);
    AaveV3InkWhitelabel.POOL.borrow(
      AaveV3InkWhitelabelAssets.GHO_UNDERLYING,
      100 ether,
      2,
      0,
      solBTCHolder
    );
    assertApproxEqAbs(
      IERC20(AaveV3InkWhitelabelAssets.GHO_V_TOKEN).balanceOf(solBTCHolder),
      100 ether,
      0.1 ether
    );
    vm.stopPrank();
  }

  /**
   * @notice Tests that borrowing with SolvBTC + WETH as collateral to verify that asset is not in isolation anymore
   after debt ceiling change succeeds.
   */
  function test_afterChangeBorrowWithSolvBTCAndWETHAsCollateralSucceeds() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    skip(3600);

    uint256 aWETHBalance = IERC20(AaveV3InkWhitelabelAssets.WETH_A_TOKEN).balanceOf(aWETHHolder);
    vm.prank(aWETHHolder);
    IERC20(AaveV3InkWhitelabelAssets.WETH_A_TOKEN).transfer(solBTCHolder, aWETHBalance); // User aWETHHolder can a current market condition transfer all their awETH keeping hf over 4 so low risk of revert

    assertEq(IERC20(AaveV3InkWhitelabelAssets.GHO_V_TOKEN).balanceOf(solBTCHolder), 0);
    vm.startPrank(solBTCHolder);
    AaveV3InkWhitelabel.POOL.setUserUseReserveAsCollateral(solvBTC_underlying, true);
    AaveV3InkWhitelabel.POOL.setUserUseReserveAsCollateral(
      AaveV3InkWhitelabelAssets.WETH_UNDERLYING,
      true
    );
    AaveV3InkWhitelabel.POOL.borrow(
      AaveV3InkWhitelabelAssets.GHO_UNDERLYING,
      100 ether,
      2,
      0,
      solBTCHolder
    );
    assertApproxEqAbs(
      IERC20(AaveV3InkWhitelabelAssets.GHO_V_TOKEN).balanceOf(solBTCHolder),
      100 ether,
      0.1 ether
    );
    vm.stopPrank();
  }
}
