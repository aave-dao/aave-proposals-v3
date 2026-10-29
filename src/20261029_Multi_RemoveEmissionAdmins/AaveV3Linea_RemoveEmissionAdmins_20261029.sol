// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Linea, AaveV3LineaAssets} from 'aave-address-book/AaveV3Linea.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Linea_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Linea.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Linea EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](16);
    rewards[0] = AaveV3LineaAssets.ezETH_A_TOKEN;
    rewards[1] = AaveV3LineaAssets.USDC_A_TOKEN;
    rewards[2] = AaveV3LineaAssets.USDT_A_TOKEN;
    rewards[3] = AaveV3LineaAssets.WBTC_A_TOKEN;
    rewards[4] = AaveV3LineaAssets.weETH_A_TOKEN;
    rewards[5] = AaveV3LineaAssets.WETH_A_TOKEN;
    rewards[6] = AaveV3LineaAssets.wrsETH_A_TOKEN;
    rewards[7] = AaveV3LineaAssets.wstETH_A_TOKEN;
    rewards[8] = AaveV3LineaAssets.ezETH_UNDERLYING;
    rewards[9] = AaveV3LineaAssets.USDC_UNDERLYING;
    rewards[10] = AaveV3LineaAssets.USDT_UNDERLYING;
    rewards[11] = AaveV3LineaAssets.WBTC_UNDERLYING;
    rewards[12] = AaveV3LineaAssets.weETH_UNDERLYING;
    rewards[13] = AaveV3LineaAssets.WETH_UNDERLYING;
    rewards[14] = AaveV3LineaAssets.wrsETH_UNDERLYING;
    rewards[15] = AaveV3LineaAssets.wstETH_UNDERLYING;
    return rewards;
  }
}
