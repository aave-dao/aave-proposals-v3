// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Arbitrum_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Arbitrum.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return rewards every reward token with a non-zero emission admin on the AaveV3Arbitrum EmissionManager
  function getRewards() public pure returns (address[] memory rewards) {
    rewards = new address[](10);
    rewards[0] = AaveV3ArbitrumAssets.ezETH_A_TOKEN;
    rewards[1] = AaveV3ArbitrumAssets.rsETH_A_TOKEN;
    rewards[2] = AaveV3ArbitrumAssets.tBTC_A_TOKEN;
    rewards[3] = AaveV3ArbitrumAssets.AAVE_UNDERLYING;
    rewards[4] = AaveV3ArbitrumAssets.ARB_UNDERLYING;
    rewards[5] = AaveV3ArbitrumAssets.ezETH_UNDERLYING;
    rewards[6] = 0x13Ad51ed4F1B7e9Dc168d8a00cB3f4dDD85EfA60; // LDO
    rewards[7] = AaveV3ArbitrumAssets.rsETH_UNDERLYING;
    rewards[8] = AaveV3ArbitrumAssets.tBTC_UNDERLYING;
    rewards[9] = AaveV3ArbitrumAssets.wstETH_UNDERLYING;
  }
}
