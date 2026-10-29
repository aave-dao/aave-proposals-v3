// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3BNB, AaveV3BNBAssets} from 'aave-address-book/AaveV3BNB.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3BNB_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3BNB.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3BNB EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](3);
    rewards[0] = AaveV3BNBAssets.wstETH_A_TOKEN;
    rewards[1] = AaveV3BNBAssets.FDUSD_UNDERLYING;
    rewards[2] = AaveV3BNBAssets.wstETH_UNDERLYING;
    return rewards;
  }
}
