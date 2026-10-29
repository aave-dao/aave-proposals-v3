// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Polygon_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Polygon.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return rewards every reward token with a non-zero emission admin on the AaveV3Polygon EmissionManager
  function getRewards() public pure returns (address[] memory rewards) {
    rewards = new address[](7);
    rewards[0] = AaveV3PolygonAssets.AAVE_UNDERLYING;
    rewards[1] = 0xC3C7d422809852031b44ab29EEC9F1EfF2A58756; // LDO
    rewards[2] = AaveV3PolygonAssets.MaticX_UNDERLYING;
    rewards[3] = 0x1d734A02eF1e1f5886e66b0673b71Af5B53ffA94; // SD
    rewards[4] = AaveV3PolygonAssets.stMATIC_UNDERLYING;
    rewards[5] = AaveV3PolygonAssets.WPOL_UNDERLYING;
    rewards[6] = AaveV3PolygonAssets.wstETH_UNDERLYING;
  }
}
