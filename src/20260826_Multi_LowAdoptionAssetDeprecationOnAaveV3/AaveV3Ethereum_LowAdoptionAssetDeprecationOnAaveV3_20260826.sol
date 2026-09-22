// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3PayloadEthereum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Low Adoption Asset Deprecation on Aave V3
 * @author Llama Risk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7
 * - Discussion: https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401
 * @dev Split in two payloads to stay within the payload execution gas ceiling: this payload
 * covers the non-PT reserves; the matured Pendle PT freezes are executed by
 * AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826.
 */
contract AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826 is AaveV3PayloadEthereum {
  function _postExecute() internal override {
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.FBTC_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.ezETH_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.eUSDe_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.ETHx_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.CRV_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.UNI_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.ONE_INCH_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.crvUSD_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.ENS_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.SNX_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.sDAI_UNDERLYING, true);
  }

  function capsUpdates() public pure override returns (IAaveV3ConfigEngine.CapsUpdate[] memory) {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](7);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.ezETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.CRV_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[3] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.UNI_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[4] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.ONE_INCH_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[5] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.ENS_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[6] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.sDAI_UNDERLYING,
      supplyCap: EngineFlags.KEEP_CURRENT,
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
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](9);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 75_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.ETHx_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.CRV_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.UNI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.ONE_INCH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.crvUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.MKR_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[7] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.ENS_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[8] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.SNX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });

    return borrowUpdates;
  }
}
