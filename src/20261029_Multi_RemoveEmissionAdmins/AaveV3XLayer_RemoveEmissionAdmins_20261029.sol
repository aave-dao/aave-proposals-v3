// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3XLayer, AaveV3XLayerAssets} from 'aave-address-book/AaveV3XLayer.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3XLayer_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3XLayer.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3XLayer EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](18);
    rewards[0] = AaveV3XLayerAssets.GHO_A_TOKEN;
    rewards[1] = AaveV3XLayerAssets.USDG_A_TOKEN;
    rewards[2] = AaveV3XLayerAssets.USDT_A_TOKEN;
    rewards[3] = AaveV3XLayerAssets.WOKB_A_TOKEN;
    rewards[4] = AaveV3XLayerAssets.xBETH_A_TOKEN;
    rewards[5] = AaveV3XLayerAssets.xBTC_A_TOKEN;
    rewards[6] = AaveV3XLayerAssets.xETH_A_TOKEN;
    rewards[7] = AaveV3XLayerAssets.xOKSOL_A_TOKEN;
    rewards[8] = AaveV3XLayerAssets.xSOL_A_TOKEN;
    rewards[9] = AaveV3XLayerAssets.GHO_UNDERLYING;
    rewards[10] = AaveV3XLayerAssets.USDG_UNDERLYING;
    rewards[11] = AaveV3XLayerAssets.USDT_UNDERLYING;
    rewards[12] = AaveV3XLayerAssets.WOKB_UNDERLYING;
    rewards[13] = AaveV3XLayerAssets.xBETH_UNDERLYING;
    rewards[14] = AaveV3XLayerAssets.xBTC_UNDERLYING;
    rewards[15] = AaveV3XLayerAssets.xETH_UNDERLYING;
    rewards[16] = AaveV3XLayerAssets.xOKSOL_UNDERLYING;
    rewards[17] = AaveV3XLayerAssets.xSOL_UNDERLYING;
    return rewards;
  }
}
