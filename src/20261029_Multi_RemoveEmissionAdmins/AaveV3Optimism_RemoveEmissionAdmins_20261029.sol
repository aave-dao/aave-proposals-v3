// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Optimism_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Optimism.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Optimism EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](5);
    rewards[0] = AaveV3OptimismAssets.AAVE_UNDERLYING;
    rewards[1] = 0xFdb794692724153d1488CcdBE0C56c252596735F; // LDO
    rewards[2] = AaveV3OptimismAssets.OP_UNDERLYING;
    rewards[3] = AaveV3OptimismAssets.sUSD_UNDERLYING;
    rewards[4] = AaveV3OptimismAssets.wstETH_UNDERLYING;
    return rewards;
  }
}
