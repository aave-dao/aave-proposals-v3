// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';

/**
 * @title Remove Emission Admins from Aave V3 Instances
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/technical-maintenance-proposals/26300/2
 */
contract AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).setEmissionAdmin(
        rewards[i],
        address(0)
      );
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3InkWhitelabel EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](28);
    rewards[0] = AaveV3InkWhitelabelAssets.ezETH_A_TOKEN;
    rewards[1] = AaveV3InkWhitelabelAssets.GHO_A_TOKEN;
    rewards[2] = AaveV3InkWhitelabelAssets.kBTC_A_TOKEN;
    rewards[3] = AaveV3InkWhitelabelAssets.SolvBTC_A_TOKEN;
    rewards[4] = AaveV3InkWhitelabelAssets.sUSDe_A_TOKEN;
    rewards[5] = AaveV3InkWhitelabelAssets.syrupUSDT_A_TOKEN;
    rewards[6] = AaveV3InkWhitelabelAssets.USDC_A_TOKEN;
    rewards[7] = AaveV3InkWhitelabelAssets.USDe_A_TOKEN;
    rewards[8] = AaveV3InkWhitelabelAssets.USDG_A_TOKEN;
    rewards[9] = AaveV3InkWhitelabelAssets.USDT_A_TOKEN;
    rewards[10] = AaveV3InkWhitelabelAssets.weETH_A_TOKEN;
    rewards[11] = AaveV3InkWhitelabelAssets.WETH_A_TOKEN;
    rewards[12] = AaveV3InkWhitelabelAssets.wrsETH_A_TOKEN;
    rewards[13] = AaveV3InkWhitelabelAssets.ezETH_UNDERLYING;
    rewards[14] = AaveV3InkWhitelabelAssets.GHO_UNDERLYING;
    rewards[15] = AaveV3InkWhitelabelAssets.kBTC_UNDERLYING;
    rewards[16] = AaveV3InkWhitelabelAssets.SolvBTC_UNDERLYING;
    rewards[17] = AaveV3InkWhitelabelAssets.sUSDe_UNDERLYING;
    rewards[18] = AaveV3InkWhitelabelAssets.syrupUSDT_UNDERLYING;
    rewards[19] = AaveV3InkWhitelabelAssets.USDC_UNDERLYING;
    rewards[20] = AaveV3InkWhitelabelAssets.USDe_UNDERLYING;
    rewards[21] = AaveV3InkWhitelabelAssets.USDG_UNDERLYING;
    rewards[22] = AaveV3InkWhitelabelAssets.USDT_UNDERLYING;
    rewards[23] = AaveV3InkWhitelabelAssets.weETH_UNDERLYING;
    rewards[24] = AaveV3InkWhitelabelAssets.WETH_UNDERLYING;
    rewards[25] = AaveV3InkWhitelabelAssets.wrsETH_UNDERLYING;
    rewards[26] = AaveV3InkWhitelabelAssets.SolvBTC_V_TOKEN;
    rewards[27] = AaveV3InkWhitelabelAssets.syrupUSDT_V_TOKEN;
    return rewards;
  }
}
