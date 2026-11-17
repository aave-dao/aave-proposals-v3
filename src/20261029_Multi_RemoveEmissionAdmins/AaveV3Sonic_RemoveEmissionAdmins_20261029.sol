// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Sonic, AaveV3SonicAssets} from 'aave-address-book/AaveV3Sonic.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/technical-maintenance-proposals/26300/2
 */
contract AaveV3Sonic_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Sonic.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Sonic EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](8);
    rewards[0] = AaveV3SonicAssets.stS_A_TOKEN;
    rewards[1] = AaveV3SonicAssets.USDC_A_TOKEN;
    rewards[2] = AaveV3SonicAssets.WETH_A_TOKEN;
    rewards[3] = AaveV3SonicAssets.wS_A_TOKEN;
    rewards[4] = AaveV3SonicAssets.stS_UNDERLYING;
    rewards[5] = AaveV3SonicAssets.USDC_UNDERLYING;
    rewards[6] = AaveV3SonicAssets.WETH_UNDERLYING;
    rewards[7] = AaveV3SonicAssets.wS_UNDERLYING;
    return rewards;
  }
}
