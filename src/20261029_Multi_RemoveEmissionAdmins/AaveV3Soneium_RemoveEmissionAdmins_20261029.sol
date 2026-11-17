// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Soneium, AaveV3SoneiumAssets} from 'aave-address-book/AaveV3Soneium.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/technical-maintenance-proposals/26300/2
 */
contract AaveV3Soneium_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Soneium.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Soneium EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](6);
    rewards[0] = AaveV3SoneiumAssets.USDCe_A_TOKEN;
    rewards[1] = AaveV3SoneiumAssets.USDT_A_TOKEN;
    rewards[2] = AaveV3SoneiumAssets.WETH_A_TOKEN;
    rewards[3] = AaveV3SoneiumAssets.USDCe_UNDERLYING;
    rewards[4] = AaveV3SoneiumAssets.USDT_UNDERLYING;
    rewards[5] = AaveV3SoneiumAssets.WETH_UNDERLYING;
    return rewards;
  }
}
