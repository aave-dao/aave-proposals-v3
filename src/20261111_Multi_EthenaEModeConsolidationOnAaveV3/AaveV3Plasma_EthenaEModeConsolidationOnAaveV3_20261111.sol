// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3PlasmaEModes, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {AaveV3PayloadPlasma} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadPlasma.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Ethena E-Mode Consolidation on Aave V3
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304
 */
contract AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111 is AaveV3PayloadPlasma {
  function eModeCategoriesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryUpdate[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryUpdate[]
      memory eModeUpdates = new IAaveV3ConfigEngine.EModeCategoryUpdate[](3);

    eModeUpdates[0] = IAaveV3ConfigEngine.EModeCategoryUpdate({
      eModeCategory: AaveV3PlasmaEModes.USDe__USDT0,
      ltv: 91_00,
      liqThreshold: 93_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      label: EngineFlags.KEEP_CURRENT_STRING,
      isolated: EngineFlags.KEEP_CURRENT
    });
    eModeUpdates[1] = IAaveV3ConfigEngine.EModeCategoryUpdate({
      eModeCategory: AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO,
      ltv: EngineFlags.KEEP_CURRENT,
      liqThreshold: 93_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      label: EngineFlags.KEEP_CURRENT_STRING,
      isolated: EngineFlags.KEEP_CURRENT
    });
    eModeUpdates[2] = IAaveV3ConfigEngine.EModeCategoryUpdate({
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO,
      ltv: 90_00,
      liqThreshold: 92_00,
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
      memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](12);

    assetEModeUpdates[0] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.USDe_PT_USDe_15JAN2026_PT_USDe_9APR2026__USDT0_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[1] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.USDe_PT_USDe_15JAN2026_PT_USDe_9APR2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[2] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[3] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[4] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_15JAN2026_PT_sUSDE_9APR2026__USDT0_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[5] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_15JAN2026_PT_sUSDE_9APR2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[6] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[7] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[8] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[9] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[10] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[11] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING,
      eModeCategory: AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });

    return assetEModeUpdates;
  }
}
