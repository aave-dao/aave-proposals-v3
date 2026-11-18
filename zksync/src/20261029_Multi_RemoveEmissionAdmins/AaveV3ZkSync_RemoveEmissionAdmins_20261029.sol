// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3ZkSync, AaveV3ZkSyncAssets} from 'aave-address-book/AaveV3ZkSync.sol';

/**
 * @title Aave V3. Deprecation of Liquidity Mining: Removal of Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/technical-maintenance-proposals/26300/2
 */
contract AaveV3ZkSync_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3ZkSync.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3ZkSync EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](7);
    rewards[0] = AaveV3ZkSyncAssets.sUSDe_A_TOKEN;
    rewards[1] = AaveV3ZkSyncAssets.weETH_A_TOKEN;
    rewards[2] = AaveV3ZkSyncAssets.wrsETH_A_TOKEN;
    rewards[3] = AaveV3ZkSyncAssets.sUSDe_UNDERLYING;
    rewards[4] = AaveV3ZkSyncAssets.weETH_UNDERLYING;
    rewards[5] = AaveV3ZkSyncAssets.wrsETH_UNDERLYING;
    rewards[6] = AaveV3ZkSyncAssets.ZK_UNDERLYING;
    return rewards;
  }
}
