// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3XLayerAssets, AaveV3XLayerEModes} from 'aave-address-book/AaveV3XLayer.sol';
import {AaveV3PayloadXLayer} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadXLayer.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Ethena E-Mode Consolidation on Aave V3
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304
 */
contract AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111 is AaveV3PayloadXLayer {
  function assetsEModeUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.AssetEModeUpdate[] memory)
  {
    IAaveV3ConfigEngine.AssetEModeUpdate[]
      memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](2);

    assetEModeUpdates[0] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3XLayerAssets.PT_USDG_29OCT2026_UNDERLYING,
      eModeCategory: AaveV3XLayerEModes.PT_USDG_29OCT2026__USDT_USDG_GHO_USDC,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });
    assetEModeUpdates[1] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3XLayerAssets.PT_USDG_29OCT2026_UNDERLYING,
      eModeCategory: AaveV3XLayerEModes.PT_USDG_29OCT2026__USDG,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });

    return assetEModeUpdates;
  }
}
