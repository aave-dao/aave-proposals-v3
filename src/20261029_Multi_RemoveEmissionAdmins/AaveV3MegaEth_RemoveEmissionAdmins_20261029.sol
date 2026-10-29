// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3MegaEth, AaveV3MegaEthAssets} from 'aave-address-book/AaveV3MegaEth.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3MegaEth_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3MegaEth.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3MegaEth EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](17);
    rewards[0] = AaveV3MegaEthAssets.BTCb_A_TOKEN;
    rewards[1] = AaveV3MegaEthAssets.ezETH_A_TOKEN;
    rewards[2] = AaveV3MegaEthAssets.USDe_A_TOKEN;
    rewards[3] = AaveV3MegaEthAssets.USDm_A_TOKEN;
    rewards[4] = AaveV3MegaEthAssets.USDT0_A_TOKEN;
    rewards[5] = AaveV3MegaEthAssets.WETH_A_TOKEN;
    rewards[6] = AaveV3MegaEthAssets.wrsETH_A_TOKEN;
    rewards[7] = AaveV3MegaEthAssets.wstETH_A_TOKEN;
    rewards[8] = AaveV3MegaEthAssets.BTCb_UNDERLYING;
    rewards[9] = AaveV3MegaEthAssets.ezETH_UNDERLYING;
    rewards[10] = AaveV3MegaEthAssets.USDe_UNDERLYING;
    rewards[11] = AaveV3MegaEthAssets.USDm_UNDERLYING;
    rewards[12] = AaveV3MegaEthAssets.USDT0_UNDERLYING;
    rewards[13] = AaveV3MegaEthAssets.USDe_V_TOKEN;
    rewards[14] = AaveV3MegaEthAssets.WETH_UNDERLYING;
    rewards[15] = AaveV3MegaEthAssets.wrsETH_UNDERLYING;
    rewards[16] = AaveV3MegaEthAssets.wstETH_UNDERLYING;
    return rewards;
  }
}
