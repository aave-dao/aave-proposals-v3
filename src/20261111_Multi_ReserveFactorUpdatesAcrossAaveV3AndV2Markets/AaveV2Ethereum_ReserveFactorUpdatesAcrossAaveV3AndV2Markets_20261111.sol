// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';

/**
 * @title Reserve Factor Updates Across Aave V3 and V2 Markets
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249
 */
contract AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 is
  IProposalGenericExecutor
{
  uint256 public constant USDC_RF = 99_99;
  uint256 public constant DAI_RF = 99_99;
  uint256 public constant WETH_RF = 99_99;
  uint256 public constant USDT_RF = 99_99;
  uint256 public constant WBTC_RF = 99_99;

  function execute() external {
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2EthereumAssets.USDC_UNDERLYING,
      USDC_RF
    );
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(AaveV2EthereumAssets.DAI_UNDERLYING, DAI_RF);
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2EthereumAssets.WETH_UNDERLYING,
      WETH_RF
    );
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2EthereumAssets.USDT_UNDERLYING,
      USDT_RF
    );
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2EthereumAssets.WBTC_UNDERLYING,
      WBTC_RF
    );
  }
}
