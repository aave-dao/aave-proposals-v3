// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {UmbrellaEthereum, UmbrellaEthereumAssets} from 'aave-address-book/UmbrellaEthereum.sol';
import {EngineFlags} from 'aave-umbrella/payloads/EngineFlags.sol';
import {IUmbrellaEngineStructs} from 'aave-umbrella/payloads/IUmbrellaEngineStructs.sol';
import {UmbrellaBasePayload} from 'aave-umbrella/payloads/UmbrellaBasePayload.sol';
import {IRewardsStructs} from 'aave-umbrella/rewards/interfaces/IRewardsStructs.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

/**
 * @title Umbrella Reward Renewal and Parameter Update on Aave V3 Core
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-umbrella-reward-renewal-and-parameter-update-on-aave-v3-core/26462
 */
contract AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124 is
  UmbrellaBasePayload
{
  uint256 public constant SECONDS_PER_YEAR = 365 days;
  uint256 public constant DISTRIBUTION_END = 1806624000; // 2027-04-02 00:00:00 UTC

  uint256 public constant STATA_USDC_TARGET_LIQUIDITY = 38_345_557e6; // 38.35M waEthUSDC, 6 decimals
  uint256 public constant STATA_USDT_TARGET_LIQUIDITY = 38_194_079e6; // 38.19M waEthUSDT, 6 decimals

  uint256 public constant USDC_EMISSION_PER_YEAR = 1_145_000e6; // 1.145M aEthUSDC, 6 decimals
  uint256 public constant USDT_EMISSION_PER_YEAR = 1_130_000e6; // 1.13M aEthUSDT, 6 decimals
  // hard-coded, not KEEP_CURRENT: getRewardData reports 0 once the old distributionEnd is reached
  uint256 public constant WETH_EMISSION_PER_YEAR = 470e18; // 470 aEthWETH, 18 decimals

  uint256 public constant USDC_ABSOLUTE_ALLOWANCE = 700_000e6; // 700k aEthUSDC, 6 decimals
  uint256 public constant USDT_ABSOLUTE_ALLOWANCE = 655_000e6; // 655k aEthUSDT, 6 decimals
  uint256 public constant WETH_ABSOLUTE_ALLOWANCE = 270e18; // 270 aEthWETH, 18 decimals

  constructor() UmbrellaBasePayload(UmbrellaEthereum.UMBRELLA_CONFIG_ENGINE) {}

  function _postExecute() internal override {
    address rewardsController = UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER;

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDC_A_TOKEN),
      rewardsController,
      USDC_ABSOLUTE_ALLOWANCE
    );
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDT_A_TOKEN),
      rewardsController,
      USDT_ABSOLUTE_ALLOWANCE
    );
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN),
      rewardsController,
      WETH_ABSOLUTE_ALLOWANCE
    );
  }

  function configureStakeAndRewards()
    public
    pure
    override
    returns (IUmbrellaEngineStructs.ConfigureStakeAndRewardsConfig[] memory)
  {
    IUmbrellaEngineStructs.ConfigureStakeAndRewardsConfig[]
      memory configs = new IUmbrellaEngineStructs.ConfigureStakeAndRewardsConfig[](3);

    configs[0] = _buildConfig(
      address(UmbrellaEthereumAssets.STK_WA_USDC_V1),
      AaveV3EthereumAssets.USDC_A_TOKEN,
      STATA_USDC_TARGET_LIQUIDITY,
      USDC_EMISSION_PER_YEAR / SECONDS_PER_YEAR
    );
    configs[1] = _buildConfig(
      address(UmbrellaEthereumAssets.STK_WA_USDT_V1),
      AaveV3EthereumAssets.USDT_A_TOKEN,
      STATA_USDT_TARGET_LIQUIDITY,
      USDT_EMISSION_PER_YEAR / SECONDS_PER_YEAR
    );
    configs[2] = _buildConfig(
      address(UmbrellaEthereumAssets.STK_WA_WETH_V1),
      AaveV3EthereumAssets.WETH_A_TOKEN,
      EngineFlags.KEEP_CURRENT,
      WETH_EMISSION_PER_YEAR / SECONDS_PER_YEAR
    );

    return configs;
  }

  function _buildConfig(
    address stakeToken,
    address reward,
    uint256 targetLiquidity,
    uint256 maxEmissionPerSecond
  ) internal pure returns (IUmbrellaEngineStructs.ConfigureStakeAndRewardsConfig memory) {
    IRewardsStructs.RewardSetupConfig[]
      memory rewardConfigs = new IRewardsStructs.RewardSetupConfig[](1);
    rewardConfigs[0] = IRewardsStructs.RewardSetupConfig({
      reward: reward,
      rewardPayer: address(AaveV3Ethereum.COLLECTOR),
      maxEmissionPerSecond: maxEmissionPerSecond,
      distributionEnd: DISTRIBUTION_END
    });

    return
      IUmbrellaEngineStructs.ConfigureStakeAndRewardsConfig({
        umbrellaStake: stakeToken,
        targetLiquidity: targetLiquidity,
        rewardConfigs: rewardConfigs
      });
  }
}
