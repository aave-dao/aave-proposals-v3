// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3EthereumHorizon, AaveV3EthereumHorizonAssets} from 'aave-address-book/AaveV3EthereumHorizon.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3EthereumHorizon.EMISSION_MANAGER).setEmissionAdmin(
        rewards[i],
        address(0)
      );
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3EthereumHorizon EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](11);
    rewards[0] = AaveV3EthereumHorizonAssets.GHO_UNDERLYING;
    rewards[1] = AaveV3EthereumHorizonAssets.GHO_A_TOKEN;
    rewards[2] = AaveV3EthereumHorizonAssets.JAAA_UNDERLYING;
    rewards[3] = AaveV3EthereumHorizonAssets.JTRSY_UNDERLYING;
    rewards[4] = AaveV3EthereumHorizonAssets.RLUSD_UNDERLYING;
    rewards[5] = AaveV3EthereumHorizonAssets.RLUSD_A_TOKEN;
    rewards[6] = AaveV3EthereumHorizonAssets.USCC_UNDERLYING;
    rewards[7] = AaveV3EthereumHorizonAssets.USDC_UNDERLYING;
    rewards[8] = AaveV3EthereumHorizonAssets.USDC_A_TOKEN;
    rewards[9] = AaveV3EthereumHorizonAssets.USTB_UNDERLYING;
    rewards[10] = AaveV3EthereumHorizonAssets.USYC_UNDERLYING;
    return rewards;
  }
}
