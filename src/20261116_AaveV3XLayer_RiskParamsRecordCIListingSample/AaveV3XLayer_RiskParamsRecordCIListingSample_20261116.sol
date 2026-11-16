// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3XLayer, AaveV3XLayerAssets} from 'aave-address-book/AaveV3XLayer.sol';
import {AaveV3PayloadXLayer} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadXLayer.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title Risk Params Record CI Listing Sample
 * @author Aave Labs
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733
 */
contract AaveV3XLayer_RiskParamsRecordCIListingSample_20261116 is AaveV3PayloadXLayer {
  using SafeERC20 for IERC20;

  // https://www.oklink.com/xlayer/address/0x5eA1F184af5Ced57725213D8267B5c4C834557D4
  address public constant PT_USDG_25FEB2027 = 0x5eA1F184af5Ced57725213D8267B5c4C834557D4;
  uint256 public constant PT_USDG_25FEB2027_SEED_AMOUNT = 100e6;
  // https://www.oklink.com/xlayer/address/0xB81f0B2cCAC262288fED924DA750CFc7CC450530
  address public constant PT_USDG_25FEB2027_PRICE_FEED = 0xB81f0B2cCAC262288fED924DA750CFc7CC450530;

  function _postExecute() internal override {
    IERC20(PT_USDG_25FEB2027).forceApprove(
      address(AaveV3XLayer.POOL),
      PT_USDG_25FEB2027_SEED_AMOUNT
    );
    AaveV3XLayer.POOL.supply({
      asset: PT_USDG_25FEB2027,
      amount: PT_USDG_25FEB2027_SEED_AMOUNT,
      onBehalfOf: AaveV3XLayer.DUST_BIN,
      referralCode: 0
    });
  }

  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](1);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: PT_USDG_25FEB2027,
      assetSymbol: 'PT_USDG_25FEB2027',
      priceFeed: PT_USDG_25FEB2027_PRICE_FEED,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.ENABLED,
      ltv: 0,
      liqThreshold: 0,
      liqBonus: 0,
      reserveFactor: 20_00,
      supplyCap: 30_000_000,
      borrowCap: 1,
      liqProtocolFee: 10_00,
      rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: 45_00,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 10_00,
        variableRateSlope2: 300_00
      })
    });

    return listings;
  }

  function eModeCategoryCreations()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryCreation[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryCreation[]
      memory eModeCreations = new IAaveV3ConfigEngine.EModeCategoryCreation[](1);

    address[] memory collateralAssets_PT_USDG_25FEB2027__Stablecoins = new address[](2);
    address[] memory borrowableAssets_PT_USDG_25FEB2027__Stablecoins = new address[](3);

    collateralAssets_PT_USDG_25FEB2027__Stablecoins[0] = PT_USDG_25FEB2027;
    collateralAssets_PT_USDG_25FEB2027__Stablecoins[1] = AaveV3XLayerAssets
      .PT_USDG_29OCT2026_UNDERLYING;
    borrowableAssets_PT_USDG_25FEB2027__Stablecoins[0] = AaveV3XLayerAssets.USDT_UNDERLYING;
    borrowableAssets_PT_USDG_25FEB2027__Stablecoins[1] = AaveV3XLayerAssets.GHO_UNDERLYING;
    borrowableAssets_PT_USDG_25FEB2027__Stablecoins[2] = AaveV3XLayerAssets.USDC_UNDERLYING;

    eModeCreations[0] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 91_00,
      liqThreshold: 93_00,
      liqBonus: 2_50,
      label: 'PT_USDG_25FEB2027__Stablecoins',
      isolated: false,
      collaterals: collateralAssets_PT_USDG_25FEB2027__Stablecoins,
      borrowables: borrowableAssets_PT_USDG_25FEB2027__Stablecoins
    });

    return eModeCreations;
  }
}
