// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {AaveV3PayloadPlasma} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadPlasma.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Low Adoption Asset Deprecation on Aave V3
 * @author Llama Risk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7
 * - Discussion: https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401
 */
contract AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826 is AaveV3PayloadPlasma {
  function _postExecute() internal override {
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(AaveV3PlasmaAssets.WETH_UNDERLYING, true);
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(AaveV3PlasmaAssets.weETH_UNDERLYING, true);
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3PlasmaAssets.PT_USDe_15JAN2026_UNDERLYING,
      true
    );
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_UNDERLYING,
      true
    );
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3PlasmaAssets.PT_sUSDE_9APR2026_UNDERLYING,
      true
    );
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3PlasmaAssets.PT_USDe_9APR2026_UNDERLYING,
      true
    );
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3PlasmaAssets.PT_USDe_18JUN2026_UNDERLYING,
      true
    );
    AaveV3Plasma.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_UNDERLYING,
      true
    );
  }

  function capsUpdates() public pure override returns (IAaveV3ConfigEngine.CapsUpdate[] memory) {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](2);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PlasmaAssets.weETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PlasmaAssets.wstETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });

    return capsUpdate;
  }

  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](2);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PlasmaAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PlasmaAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });

    return borrowUpdates;
  }
}
