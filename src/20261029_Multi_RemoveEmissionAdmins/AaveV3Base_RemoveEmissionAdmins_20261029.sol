// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Base_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Base.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Base EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](19);
    rewards[0] = AaveV3BaseAssets.AAVE_UNDERLYING;
    rewards[1] = AaveV3BaseAssets.AAVE_A_TOKEN;
    rewards[2] = AaveV3BaseAssets.EURC_A_TOKEN;
    rewards[3] = AaveV3BaseAssets.ezETH_A_TOKEN;
    rewards[4] = AaveV3BaseAssets.GHO_A_TOKEN;
    rewards[5] = AaveV3BaseAssets.syrupUSDC_A_TOKEN;
    rewards[6] = AaveV3BaseAssets.tBTC_A_TOKEN;
    rewards[7] = AaveV3BaseAssets.USDC_A_TOKEN;
    rewards[8] = AaveV3BaseAssets.WETH_A_TOKEN;
    rewards[9] = AaveV3BaseAssets.wrsETH_A_TOKEN;
    rewards[10] = AaveV3BaseAssets.EURC_UNDERLYING;
    rewards[11] = AaveV3BaseAssets.ezETH_UNDERLYING;
    rewards[12] = AaveV3BaseAssets.GHO_UNDERLYING;
    rewards[13] = AaveV3BaseAssets.syrupUSDC_UNDERLYING;
    rewards[14] = AaveV3BaseAssets.tBTC_UNDERLYING;
    rewards[15] = AaveV3BaseAssets.USDC_UNDERLYING;
    rewards[16] = AaveV3BaseAssets.WETH_UNDERLYING;
    rewards[17] = AaveV3BaseAssets.wrsETH_UNDERLYING;
    rewards[18] = AaveV3BaseAssets.wstETH_UNDERLYING;
    return rewards;
  }
}
