// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3AvalancheEModes, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV3PayloadAvalanche} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadAvalanche.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Ethena E-Mode Consolidation on Aave V3
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304
 */
contract AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111 is AaveV3PayloadAvalanche {
  function eModeCategoriesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryUpdate[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryUpdate[]
      memory eModeUpdates = new IAaveV3ConfigEngine.EModeCategoryUpdate[](2);

    eModeUpdates[0] = IAaveV3ConfigEngine.EModeCategoryUpdate({
      eModeCategory: AaveV3AvalancheEModes.USDe__USDC_USDt_GHO,
      ltv: 91_00,
      liqThreshold: 93_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      label: EngineFlags.KEEP_CURRENT_STRING,
      isolated: EngineFlags.KEEP_CURRENT
    });
    eModeUpdates[1] = IAaveV3ConfigEngine.EModeCategoryUpdate({
      eModeCategory: AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe,
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
      memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](1);

    assetEModeUpdates[0] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3AvalancheAssets.USDe_UNDERLYING,
      eModeCategory: AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe,
      borrowable: EngineFlags.DISABLED,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.KEEP_CURRENT
    });

    return assetEModeUpdates;
  }
}
