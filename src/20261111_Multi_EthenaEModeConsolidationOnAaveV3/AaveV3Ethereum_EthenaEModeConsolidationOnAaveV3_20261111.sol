// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumEModes, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3PayloadEthereum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Ethena E-Mode Consolidation on Aave V3
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304
 */
contract AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111 is AaveV3PayloadEthereum {
  function eModeCategoriesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryUpdate[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryUpdate[]
      memory eModeUpdates = new IAaveV3ConfigEngine.EModeCategoryUpdate[](1);

    eModeUpdates[0] = IAaveV3ConfigEngine.EModeCategoryUpdate({
      eModeCategory: AaveV3EthereumEModes.USDe__USDC_USDT,
      ltv: 91_00,
      liqThreshold: 93_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      label: EngineFlags.KEEP_CURRENT_STRING,
      isolated: EngineFlags.KEEP_CURRENT
    });

    return eModeUpdates;
  }

  function assetsEModeUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.AssetEModeUpdate[] memory)
  {
    IAaveV3ConfigEngine.AssetEModeUpdate[]
      memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](23);

    assetEModeUpdates[0] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025__USDC_USDT,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[1] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[2] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      // PT-USDe Stablecoins September 2025, no address book constant
      eModeCategory: 19,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[3] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .USDe_PT_USDe_31JUL2025_PT_eUSDE_14AUG2025_PT_USDe_25SEP2025__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[4] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .USDe_PT_USDe_27NOV2025_PT_USDe_5FEB2026__USDC_USDT_USDe_USDtb,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[5] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.USDe_PT_USDe_27NOV2025_PT_USDe_5FEB2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[6] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .USDe_PT_USDe_5FEB2026_PT_USDe_7MAY2026__USDC_USDT_USDe_USDtb,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[7] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.USDe_PT_USDe_5FEB2026_PT_USDe_7MAY2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[8] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_sUSDE_31JUL2025__USDC_USDT,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[9] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .sUSDe_PT_sUSDE_31JUL2025_PT_sUSDE_25SEP2025__USDC_USDT_USDe_USDtb,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[10] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .sUSDe_PT_sUSDE_25SEP2025_PT_sUSDE_27NOV2025__USDC_USDT_USDe_USDtb,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[11] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .sUSDe_PT_sUSDE_27NOV2025_PT_sUSDE_5FEB2026__USDC_USDT_USDe_USDtb,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[12] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_sUSDE_27NOV2025_PT_sUSDE_5FEB2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[13] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .sUSDe_PT_sUSDE_5FEB2026_PT_sUSDE_7MAY2026__USDC_USDT_USDe_USDtb,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[14] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_sUSDE_5FEB2026_PT_sUSDE_7MAY2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[15] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026__USDC_USDT_USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[16] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[17] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes
        .sUSDe_PT_srUSDe_2APR2026_PT_srUSDe_25JUN2026__USDC_USDT_USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[18] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026_PT_srUSDe_25JUN2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[19] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[20] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[21] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[22] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });

    return assetEModeUpdates;
  }
}
