// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Celo, AaveV3CeloAssets} from 'aave-address-book/AaveV3Celo.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Celo_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Celo.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Celo EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](12);
    rewards[0] = AaveV3CeloAssets.CELO_A_TOKEN;
    rewards[1] = AaveV3CeloAssets.EURm_A_TOKEN;
    rewards[2] = AaveV3CeloAssets.USDm_A_TOKEN;
    rewards[3] = AaveV3CeloAssets.USDC_A_TOKEN;
    rewards[4] = AaveV3CeloAssets.USDT_A_TOKEN;
    rewards[5] = AaveV3CeloAssets.WETH_A_TOKEN;
    rewards[6] = AaveV3CeloAssets.CELO_UNDERLYING;
    rewards[7] = AaveV3CeloAssets.EURm_UNDERLYING;
    rewards[8] = AaveV3CeloAssets.USDC_UNDERLYING;
    rewards[9] = AaveV3CeloAssets.USDm_UNDERLYING;
    rewards[10] = AaveV3CeloAssets.USDT_UNDERLYING;
    rewards[11] = AaveV3CeloAssets.WETH_UNDERLYING;
    return rewards;
  }
}
