// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3PayloadEthereum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

uint256 constant DAI_RF = 30_00;
uint256 constant WBTC_RF = 100_00;
uint256 constant cbBTC_RF = 100_00;
uint256 constant wstETH_RF = 100_00;
uint256 constant LINK_RF = 50_00;
uint256 constant weETH_RF = 100_00;
uint256 constant tBTC_RF = 100_00;
uint256 constant FBTC_RF = 100_00;
uint256 constant cbETH_RF = 100_00;
uint256 constant rETH_RF = 100_00;

/**
 * @title Reserve Factor Updates Across Aave V3 and V2 Markets
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249
 */
contract AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 is
  AaveV3PayloadEthereum
{
  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](10);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.DAI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: DAI_RF
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.WBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WBTC_RF
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.cbBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: cbBTC_RF
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: wstETH_RF
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.LINK_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: LINK_RF
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.weETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: weETH_RF
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.tBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: tBTC_RF
    });
    borrowUpdates[7] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: FBTC_RF
    });
    borrowUpdates[8] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.cbETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: cbETH_RF
    });
    borrowUpdates[9] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.rETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: rETH_RF
    });

    return borrowUpdates;
  }
}
