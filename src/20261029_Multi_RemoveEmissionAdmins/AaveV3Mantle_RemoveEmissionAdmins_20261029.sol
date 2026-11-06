// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Mantle, AaveV3MantleAssets} from 'aave-address-book/AaveV3Mantle.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Mantle_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Mantle.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Mantle EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](20);
    rewards[0] = AaveV3MantleAssets.FBTC_A_TOKEN;
    rewards[1] = AaveV3MantleAssets.GHO_A_TOKEN;
    rewards[2] = AaveV3MantleAssets.sUSDe_A_TOKEN;
    rewards[3] = AaveV3MantleAssets.syrupUSDT_A_TOKEN;
    rewards[4] = AaveV3MantleAssets.USDC_A_TOKEN;
    rewards[5] = AaveV3MantleAssets.USDe_A_TOKEN;
    rewards[6] = AaveV3MantleAssets.USDT0_A_TOKEN;
    rewards[7] = AaveV3MantleAssets.WETH_A_TOKEN;
    rewards[8] = AaveV3MantleAssets.WMNT_A_TOKEN;
    rewards[9] = AaveV3MantleAssets.wrsETH_A_TOKEN;
    rewards[10] = AaveV3MantleAssets.FBTC_UNDERLYING;
    rewards[11] = AaveV3MantleAssets.GHO_UNDERLYING;
    rewards[12] = AaveV3MantleAssets.sUSDe_UNDERLYING;
    rewards[13] = AaveV3MantleAssets.syrupUSDT_UNDERLYING;
    rewards[14] = AaveV3MantleAssets.USDC_UNDERLYING;
    rewards[15] = AaveV3MantleAssets.USDe_UNDERLYING;
    rewards[16] = AaveV3MantleAssets.USDT0_UNDERLYING;
    rewards[17] = AaveV3MantleAssets.WETH_UNDERLYING;
    rewards[18] = AaveV3MantleAssets.WMNT_UNDERLYING;
    rewards[19] = AaveV3MantleAssets.wrsETH_UNDERLYING;
    return rewards;
  }
}
