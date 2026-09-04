// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3XLayer, AaveV3XLayerEModes} from 'aave-address-book/AaveV3XLayer.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig, ExpectedListing} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3XLayer_AaveV3XLayerUSDCListing_20260818} from './AaveV3XLayer_AaveV3XLayerUSDCListing_20260818.sol';
import {IPriceCapAdapterStable} from '../interfaces/IPriceCapAdapterStable.sol';

/**
 * @dev Test for AaveV3XLayer_AaveV3XLayerUSDCListing_20260818
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260818_AaveV3XLayer_AaveV3XLayerUSDCListing/AaveV3XLayer_AaveV3XLayerUSDCListing_20260818.t.sol -vv
 */
contract AaveV3XLayer_AaveV3XLayerUSDCListing_20260818_Test is ProtocolV3TestBase {
  AaveV3XLayer_AaveV3XLayerUSDCListing_20260818 internal proposal;

  // https://www.oklink.com/xlayer/address/0x9a09a9E491DB3dd8Ada5B1B889991AC9Ad5fd362
  address internal constant PT_USDG_29OCT2026 = 0x9a09a9E491DB3dd8Ada5B1B889991AC9Ad5fd362;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('xlayer'), 69442624);
    proposal = new AaveV3XLayer_AaveV3XLayerUSDCListing_20260818();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3XLayer_AaveV3XLayerUSDCListing_20260818',
      AaveV3XLayer.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3XLayer.POOL, address(proposal), updatedAssets);
  }

  function test_dustBinHasUSDCFunds() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address aTokenAddress = AaveV3XLayer.POOL.getReserveAToken(proposal.USDC());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3XLayer.DUST_BIN)),
      proposal.USDC_SEED_AMOUNT(),
      'dust bin should hold at least the seeded aUSDC amount'
    );
  }

  function test_priceFeedReturnsSanePrice() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3XLayer.ORACLE.getSourceOfAsset(proposal.USDC()),
      proposal.USDC_PRICE_FEED(),
      'USDC should be priced by the configured feed'
    );
    uint256 price = AaveV3XLayer.ORACLE.getAssetPrice(proposal.USDC());
    assertGt(price, 0.95e8, 'USDC price should trade near 1 USD');
    assertLt(price, 1.05e8, 'USDC price should trade near 1 USD');

    IPriceCapAdapterStable adapter = IPriceCapAdapterStable(proposal.USDC_PRICE_FEED());
    assertEq(adapter.getPriceCap(), 1.04e8, 'price cap should be 1.04 USD');
    assertEq(
      adapter.ASSET_TO_USD_AGGREGATOR(),
      0xB8a08c178D96C315FbFB5661ABD208477391BC40,
      'underlying aggregator should be the Chainlink USDC/USD feed'
    );
    assertEq(adapter.isCapped(), false, 'USDC price should not be capped at the fork block');
  }

  function test_usdcBorrowableInStablecoinEModes() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 usdcReserveId = AaveV3XLayer.POOL.getReserveData(proposal.USDC()).id;

    uint8[5] memory eModeIds = [
      AaveV3XLayerEModes.xBTC__USDT_USDG_GHO,
      AaveV3XLayerEModes.xETH__USDT_USDG_GHO,
      AaveV3XLayerEModes.xSOL__USDT_USDG_GHO,
      AaveV3XLayerEModes.WOKB__USDT_USDG_GHO,
      _findEModeCategoryId('PT_USDG__Stablecoins')
    ];

    for (uint256 i = 0; i < eModeIds.length; i++) {
      uint128 borrowableBitmap = AaveV3XLayer.POOL.getEModeCategoryBorrowableBitmap(eModeIds[i]);
      uint128 collateralBitmap = AaveV3XLayer.POOL.getEModeCategoryCollateralBitmap(eModeIds[i]);
      assertEq(
        (borrowableBitmap >> usdcReserveId) & 1,
        1,
        'USDC should be borrowable in the stablecoin eMode'
      );
      assertEq(
        (collateralBitmap >> usdcReserveId) & 1,
        0,
        'USDC should not be collateral in the stablecoin eMode'
      );
    }
  }

  function _expectedListings() internal pure override returns (ExpectedListing[] memory listings) {
    listings = new ExpectedListing[](1);

    listings[0] = ExpectedListing({
      listing: IAaveV3ConfigEngine.Listing({
        asset: 0xB6CEceAB302E2E4948951eE7843FC24E92933061,
        assetSymbol: 'USDC',
        priceFeed: 0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC,
        enabledToBorrow: EngineFlags.ENABLED,
        flashloanable: EngineFlags.ENABLED,
        ltv: 75_00,
        liqThreshold: 78_00,
        liqBonus: 7_50,
        reserveFactor: 10_00,
        supplyCap: 35_000_000,
        borrowCap: 32_000_000,
        liqProtocolFee: 10_00,
        rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
          optimalUsageRatio: 90_00,
          baseVariableBorrowRate: 0,
          variableRateSlope1: 4_00,
          variableRateSlope2: 40_00
        })
      }),
      decimals: 6
    });
  }

  function test_eModeBorrowUsdc() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    uint8 eModeId = _findEModeCategoryId('PT_USDG__Stablecoins');
    assertEq(eModeId, 7, 'hardcoded eMode id should match the PT_USDG__Stablecoins label');

    address user = makeAddr('eModeBorrower');
    address collateral = PT_USDG_29OCT2026;
    uint256 supplyAmount = 1_000e6;
    deal(collateral, user, supplyAmount);

    vm.startPrank(user);
    AaveV3XLayer.POOL.setUserEMode(eModeId);
    IERC20(collateral).approve(address(AaveV3XLayer.POOL), supplyAmount);
    AaveV3XLayer.POOL.supply(collateral, supplyAmount, user, 0);

    uint256 borrowAmount = 100e6;
    AaveV3XLayer.POOL.borrow(proposal.USDC(), borrowAmount, 2, 0, user);

    address vToken = AaveV3XLayer.POOL.getReserveVariableDebtToken(proposal.USDC());
    assertApproxEqAbs(
      IERC20(vToken).balanceOf(user),
      borrowAmount,
      1,
      'borrowed USDC amount mismatch'
    );

    IERC20(proposal.USDC()).approve(address(AaveV3XLayer.POOL), borrowAmount);
    AaveV3XLayer.POOL.repay(proposal.USDC(), borrowAmount, 2, user);
    AaveV3XLayer.POOL.withdraw(collateral, supplyAmount / 2, user);
    vm.stopPrank();
  }

  function _findEModeCategoryId(string memory label) internal view returns (uint8) {
    for (uint8 i = 1; i < 255; i++) {
      if (keccak256(bytes(AaveV3XLayer.POOL.getEModeCategoryLabel(i))) == keccak256(bytes(label))) {
        return i;
      }
    }
    revert('eMode category not found');
  }
}
