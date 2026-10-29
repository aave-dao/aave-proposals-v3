// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Gnosis, AaveV3GnosisAssets} from 'aave-address-book/AaveV3Gnosis.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Gnosis_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Gnosis.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return rewards every reward token with a non-zero emission admin on the AaveV3Gnosis EmissionManager
  function getRewards() public pure returns (address[] memory rewards) {
    rewards = new address[](3);
    rewards[0] = AaveV3GnosisAssets.GHO_A_TOKEN;
    rewards[1] = AaveV3GnosisAssets.EURe_UNDERLYING;
    rewards[2] = AaveV3GnosisAssets.GHO_UNDERLYING;
  }
}
