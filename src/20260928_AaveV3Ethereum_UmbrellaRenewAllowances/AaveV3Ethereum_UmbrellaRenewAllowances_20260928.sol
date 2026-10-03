// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {UmbrellaEthereum} from 'aave-address-book/UmbrellaEthereum.sol';

/**
 * @title Umbrella - Renew Allowances
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-umbrella-renew-allowances/25700
 * @notice Payload that renews the Umbrella reward allowances from the Aave Ethereum
 *         Collector to the Umbrella Rewards Controller, so that emissions can
 *         continue at the current rate without interruption.
 */
contract AaveV3Ethereum_UmbrellaRenewAllowances_20260928 is IProposalGenericExecutor {
  /// @notice Absolute allowance for stkwaEthUSDT.v1 rewards (USDT, 6 decimals).
  uint256 public constant USDT_ABSOLUTE_ALLOWANCE = 500_000e6;

  /// @notice Absolute allowance for stkwaEthUSDC.v1 rewards (USDC, 6 decimals).
  uint256 public constant USDC_ABSOLUTE_ALLOWANCE = 475_000e6;

  /// @notice Absolute allowance for stkwaEthWETH.v1 rewards (WETH, 18 decimals).
  uint256 public constant WETH_ABSOLUTE_ALLOWANCE = 160 ether;

  /// @notice Renews the Collector -> Umbrella Rewards Controller allowances
  ///         by setting them to the absolute targets stated in the forum post,
  ///         replacing the remaining allowance for each reward asset.
  function execute() external override {
    address rewardsController = UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER;

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDT_A_TOKEN),
      rewardsController,
      USDT_ABSOLUTE_ALLOWANCE
    );

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDC_A_TOKEN),
      rewardsController,
      USDC_ABSOLUTE_ALLOWANCE
    );

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN),
      rewardsController,
      WETH_ABSOLUTE_ALLOWANCE
    );
  }
}
