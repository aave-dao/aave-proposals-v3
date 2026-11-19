// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets, AaveV3EthereumEModes} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3PayloadEthereum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Repositioning Aave V3 Core Around Established & Liquid Collateral
 * @author LlamaRisk
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x7ed3e17373060128618599b425fd0b4312bea86fcd903a1aa99c2622403f7f98
 * - Discussion: https://governance.aave.com/t/arfc-repositioning-aave-v3-core-around-established-liquid-collateral/26191
 */
contract AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119 is
  AaveV3PayloadEthereum
{
  function _postExecute() internal override {
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.osETH_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.LBTC_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.rETH_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.eBTC_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.BTCb_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.tETH_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.LDO_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.mUSD_UNDERLYING, true);
  }

  function assetsEModeUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.AssetEModeUpdate[] memory)
  {
    IAaveV3ConfigEngine.AssetEModeUpdate[]
      memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](3);

    assetEModeUpdates[0] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.wstETH_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx,
      borrowable: EngineFlags.DISABLED,
      collateral: EngineFlags.ENABLED,
      ltvzero: EngineFlags.KEEP_CURRENT
    });
    assetEModeUpdates[1] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.weETH_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.ENABLED,
      ltvzero: EngineFlags.KEEP_CURRENT
    });
    assetEModeUpdates[2] = IAaveV3ConfigEngine.AssetEModeUpdate({
      asset: AaveV3EthereumAssets.cbETH_UNDERLYING,
      eModeCategory: AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx,
      borrowable: EngineFlags.KEEP_CURRENT,
      collateral: EngineFlags.ENABLED,
      ltvzero: EngineFlags.KEEP_CURRENT
    });

    return assetEModeUpdates;
  }

  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](7);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.CRV_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.tBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.rETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.crvUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.UNI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.mUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });

    return borrowUpdates;
  }
}
