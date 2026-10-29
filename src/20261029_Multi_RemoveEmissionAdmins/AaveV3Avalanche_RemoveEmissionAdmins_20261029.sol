// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Avalanche_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Avalanche.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Avalanche EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](16);
    rewards[0] = AaveV3AvalancheAssets.AUSD_A_TOKEN;
    rewards[1] = AaveV3AvalancheAssets.EURC_A_TOKEN;
    rewards[2] = AaveV3AvalancheAssets.GHO_A_TOKEN;
    rewards[3] = AaveV3AvalancheAssets.sUSDe_A_TOKEN;
    rewards[4] = AaveV3AvalancheAssets.USDe_A_TOKEN;
    rewards[5] = AaveV3AvalancheAssets.wrsETH_A_TOKEN;
    rewards[6] = AaveV3AvalancheAssets.AAVEe_UNDERLYING;
    rewards[7] = AaveV3AvalancheAssets.AUSD_UNDERLYING;
    rewards[8] = AaveV3AvalancheAssets.EURC_UNDERLYING;
    rewards[9] = AaveV3AvalancheAssets.GHO_UNDERLYING;
    rewards[10] = AaveV3AvalancheAssets.sAVAX_UNDERLYING;
    rewards[11] = 0xA25EaF2906FA1a3a13EdAc9B9657108Af7B703e3; // stAVAX
    rewards[12] = AaveV3AvalancheAssets.sUSDe_UNDERLYING;
    rewards[13] = AaveV3AvalancheAssets.USDe_UNDERLYING;
    rewards[14] = AaveV3AvalancheAssets.WAVAX_UNDERLYING;
    rewards[15] = AaveV3AvalancheAssets.wrsETH_UNDERLYING;
    return rewards;
  }
}
