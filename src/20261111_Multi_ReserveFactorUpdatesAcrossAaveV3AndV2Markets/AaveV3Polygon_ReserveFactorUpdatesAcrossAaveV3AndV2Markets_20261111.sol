// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3PayloadPolygon} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadPolygon.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

uint256 constant USDT0_RF = 30_00;
uint256 constant USDCn_RF = 25_00;
uint256 constant DAI_RF = 70_00;
uint256 constant WETH_RF = 25_00;
uint256 constant WPOL_RF = 50_00;
uint256 constant WBTC_RF = 100_00;
uint256 constant wstETH_RF = 100_00;

/**
 * @title Reserve Factor Updates Across Aave V3 and V2 Markets
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249
 */
contract AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 is
  AaveV3PayloadPolygon
{
  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](7);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.USDT0_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: USDT0_RF
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.USDCn_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: USDCn_RF
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.DAI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: DAI_RF
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WETH_RF
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.WPOL_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WPOL_RF
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.WBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WBTC_RF
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: wstETH_RF
    });

    return borrowUpdates;
  }
}
