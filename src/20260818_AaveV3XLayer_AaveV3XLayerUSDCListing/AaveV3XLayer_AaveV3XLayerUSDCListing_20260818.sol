// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3XLayer, AaveV3XLayerEModes} from 'aave-address-book/AaveV3XLayer.sol';
import {AaveV3PayloadXLayer} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadXLayer.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title Onboard USDC to Aave V3 X Layer
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-asset-listing-usdc-x-layer/25467
 */
contract AaveV3XLayer_AaveV3XLayerUSDCListing_20260818 is AaveV3PayloadXLayer {
  using SafeERC20 for IERC20;

  // https://www.oklink.com/xlayer/address/0xB6CEceAB302E2E4948951eE7843FC24E92933061
  address public constant USDC = 0xB6CEceAB302E2E4948951eE7843FC24E92933061;
  uint256 public constant USDC_SEED_AMOUNT = 100e6;
  // https://www.oklink.com/xlayer/address/0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC
  address public constant USDC_PRICE_FEED = 0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC;

  function _postExecute() internal override {
    IERC20(USDC).forceApprove(address(AaveV3XLayer.POOL), USDC_SEED_AMOUNT);
    AaveV3XLayer.POOL.supply(USDC, USDC_SEED_AMOUNT, address(AaveV3XLayer.DUST_BIN), 0);
  }

  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](1);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: USDC,
      assetSymbol: 'USDC',
      priceFeed: USDC_PRICE_FEED,
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
    });

    return listings;
  }

  function assetsEModeUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.AssetEModeUpdate[] memory)
  {
    IAaveV3ConfigEngine.AssetEModeUpdate[]
      memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](5);

    assetEModeUpdates[0] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: USDC,
      eModeCategory: AaveV3XLayerEModes.xBTC__USDT_USDG_GHO,
      borrowable: EngineFlags.ENABLED,
      collateral: EngineFlags.DISABLED,
      ltvzero: EngineFlags.DISABLED
    });
    assetEModeUpdates[1] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: USDC,
      eModeCategory: AaveV3XLayerEModes.xETH__USDT_USDG_GHO,
      borrowable: EngineFlags.ENABLED,
      collateral: EngineFlags.DISABLED,
      ltvzero: EngineFlags.DISABLED
    });
    assetEModeUpdates[2] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: USDC,
      eModeCategory: AaveV3XLayerEModes.xSOL__USDT_USDG_GHO,
      borrowable: EngineFlags.ENABLED,
      collateral: EngineFlags.DISABLED,
      ltvzero: EngineFlags.DISABLED
    });
    assetEModeUpdates[3] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: USDC,
      eModeCategory: AaveV3XLayerEModes.WOKB__USDT_USDG_GHO,
      borrowable: EngineFlags.ENABLED,
      collateral: EngineFlags.DISABLED,
      ltvzero: EngineFlags.DISABLED
    });
    assetEModeUpdates[4] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: USDC,
      // PT_USDG__Stablecoins, constant not yet published in aave-address-book
      eModeCategory: 7,
      borrowable: EngineFlags.ENABLED,
      collateral: EngineFlags.DISABLED,
      ltvzero: EngineFlags.DISABLED
    });

    return assetEModeUpdates;
  }
}
