// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {AaveV3PayloadBase} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadBase.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Enhancing Market Granularity in Aave 3.6: part 2
 * @author ChaosLabs (implemented by Aavechan Initiative @aci via Skyward)
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-enhancing-market-granularity-in-aave-v3-6-restricting-borrowability-and-collateralization-outside-of-liquid-emodes/23592
 */
contract AaveV3Base_EnhancingMarketGranularityInAave36Part2_20260127 is AaveV3PayloadBase {
  function collateralsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[]
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](7);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.USDbC_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.ezETH_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[2] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.wrsETH_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[3] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.LBTC_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[4] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.EURC_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[5] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.AAVE_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[6] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.tBTC_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });

    return collateralUpdate;
  }
  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](5);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BaseAssets.cbETH_UNDERLYING,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.KEEP_CURRENT,
      borrowableInIsolation: EngineFlags.KEEP_CURRENT,
      withSiloedBorrowing: EngineFlags.KEEP_CURRENT,
      reserveFactor: EngineFlags.KEEP_CURRENT
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BaseAssets.USDbC_UNDERLYING,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.KEEP_CURRENT,
      borrowableInIsolation: EngineFlags.KEEP_CURRENT,
      withSiloedBorrowing: EngineFlags.KEEP_CURRENT,
      reserveFactor: EngineFlags.KEEP_CURRENT
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BaseAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.KEEP_CURRENT,
      borrowableInIsolation: EngineFlags.KEEP_CURRENT,
      withSiloedBorrowing: EngineFlags.KEEP_CURRENT,
      reserveFactor: EngineFlags.KEEP_CURRENT
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BaseAssets.weETH_UNDERLYING,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.KEEP_CURRENT,
      borrowableInIsolation: EngineFlags.KEEP_CURRENT,
      withSiloedBorrowing: EngineFlags.KEEP_CURRENT,
      reserveFactor: EngineFlags.KEEP_CURRENT
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BaseAssets.tBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.KEEP_CURRENT,
      borrowableInIsolation: EngineFlags.KEEP_CURRENT,
      withSiloedBorrowing: EngineFlags.KEEP_CURRENT,
      reserveFactor: EngineFlags.KEEP_CURRENT
    });

    return borrowUpdates;
  }
  function eModeCategoryCreations()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryCreation[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryCreation[]
      memory eModeCreations = new IAaveV3ConfigEngine.EModeCategoryCreation[](4);

    address[] memory collateralAssets_AAVE__USDC_GHO = new address[](1);
    address[] memory borrowableAssets_AAVE__USDC_GHO = new address[](2);

    collateralAssets_AAVE__USDC_GHO[0] = AaveV3BaseAssets.AAVE_UNDERLYING;
    borrowableAssets_AAVE__USDC_GHO[0] = AaveV3BaseAssets.USDC_UNDERLYING;
    borrowableAssets_AAVE__USDC_GHO[1] = AaveV3BaseAssets.GHO_UNDERLYING;

    eModeCreations[0] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 63_00,
      liqThreshold: 70_00,
      liqBonus: 10_00,
      label: 'AAVE__USDC_GHO',
      collaterals: collateralAssets_AAVE__USDC_GHO,
      borrowables: borrowableAssets_AAVE__USDC_GHO
    });

    address[] memory collateralAssets_EURC__USDC_GHO = new address[](1);
    address[] memory borrowableAssets_EURC__USDC_GHO = new address[](2);

    collateralAssets_EURC__USDC_GHO[0] = AaveV3BaseAssets.EURC_UNDERLYING;
    borrowableAssets_EURC__USDC_GHO[0] = AaveV3BaseAssets.USDC_UNDERLYING;
    borrowableAssets_EURC__USDC_GHO[1] = AaveV3BaseAssets.GHO_UNDERLYING;

    eModeCreations[1] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 75_00,
      liqThreshold: 78_00,
      liqBonus: 5_00,
      label: 'EURC__USDC_GHO',
      collaterals: collateralAssets_EURC__USDC_GHO,
      borrowables: borrowableAssets_EURC__USDC_GHO
    });

    address[] memory collateralAssets_LBTC__USDC_GHO = new address[](1);
    address[] memory borrowableAssets_LBTC__USDC_GHO = new address[](2);

    collateralAssets_LBTC__USDC_GHO[0] = AaveV3BaseAssets.LBTC_UNDERLYING;
    borrowableAssets_LBTC__USDC_GHO[0] = AaveV3BaseAssets.USDC_UNDERLYING;
    borrowableAssets_LBTC__USDC_GHO[1] = AaveV3BaseAssets.GHO_UNDERLYING;

    eModeCreations[2] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 75_00,
      liqThreshold: 78_00,
      liqBonus: 5_00,
      label: 'LBTC__USDC_GHO',
      collaterals: collateralAssets_LBTC__USDC_GHO,
      borrowables: borrowableAssets_LBTC__USDC_GHO
    });

    address[] memory collateralAssets_TBTC__USDC_GHO = new address[](1);
    address[] memory borrowableAssets_TBTC__USDC_GHO = new address[](2);

    collateralAssets_TBTC__USDC_GHO[0] = AaveV3BaseAssets.tBTC_UNDERLYING;
    borrowableAssets_TBTC__USDC_GHO[0] = AaveV3BaseAssets.USDC_UNDERLYING;
    borrowableAssets_TBTC__USDC_GHO[1] = AaveV3BaseAssets.GHO_UNDERLYING;

    eModeCreations[3] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 72_00,
      liqThreshold: 75_00,
      liqBonus: 7_50,
      label: 'tBTC__USDC_GHO',
      collaterals: collateralAssets_TBTC__USDC_GHO,
      borrowables: borrowableAssets_TBTC__USDC_GHO
    });

    return eModeCreations;
  }
}
