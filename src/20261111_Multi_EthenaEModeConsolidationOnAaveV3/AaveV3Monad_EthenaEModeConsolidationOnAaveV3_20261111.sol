// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3MonadAssets, AaveV3MonadEModes} from 'aave-address-book/AaveV3Monad.sol';
import {AaveV3PayloadMonad} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadMonad.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Ethena E-Mode Consolidation on Aave V3
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304
 */
contract AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111 is AaveV3PayloadMonad {
  function eModeCategoryCreations()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryCreation[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryCreation[]
      memory eModeCreations = new IAaveV3ConfigEngine.EModeCategoryCreation[](1);

    address[] memory collateralAssets_USDeStablecoins = new address[](1);
    address[] memory borrowableAssets_USDeStablecoins = new address[](4);

    collateralAssets_USDeStablecoins[0] = AaveV3MonadAssets.USDe_UNDERLYING;
    borrowableAssets_USDeStablecoins[0] = AaveV3MonadAssets.USDT0_UNDERLYING;
    borrowableAssets_USDeStablecoins[1] = AaveV3MonadAssets.USDC_UNDERLYING;
    borrowableAssets_USDeStablecoins[2] = AaveV3MonadAssets.AUSD_UNDERLYING;
    borrowableAssets_USDeStablecoins[3] = AaveV3MonadAssets.GHO_UNDERLYING;

    eModeCreations[0] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 91_00,
      liqThreshold: 93_00,
      liqBonus: 2_00,
      label: 'USDe Stablecoins',
      isolated: false,
      collaterals: collateralAssets_USDeStablecoins,
      borrowables: borrowableAssets_USDeStablecoins
    });

    return eModeCreations;
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
      asset: AaveV3MonadAssets.PT_AUSD_8OCT2026_UNDERLYING,
      eModeCategory: AaveV3MonadEModes.PT_AUSD_8OCT2026__USDT0_USDC_USDe_GHO,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.KEEP_CURRENT,
      ltvzero: EngineFlags.ENABLED
    });

    return assetEModeUpdates;
  }
}
