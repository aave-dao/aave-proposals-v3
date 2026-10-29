// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Plasma_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Plasma.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Plasma EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](37);
    rewards[0] = AaveV3PlasmaAssets.GHO_A_TOKEN;
    rewards[1] = AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_A_TOKEN;
    rewards[2] = AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_A_TOKEN;
    rewards[3] = AaveV3PlasmaAssets.PT_sUSDE_9APR2026_A_TOKEN;
    rewards[4] = AaveV3PlasmaAssets.PT_USDe_15JAN2026_A_TOKEN;
    rewards[5] = AaveV3PlasmaAssets.PT_USDe_18JUN2026_A_TOKEN;
    rewards[6] = AaveV3PlasmaAssets.PT_USDe_9APR2026_A_TOKEN;
    rewards[7] = AaveV3PlasmaAssets.sUSDe_A_TOKEN;
    rewards[8] = AaveV3PlasmaAssets.syrupUSDT_A_TOKEN;
    rewards[9] = AaveV3PlasmaAssets.USDe_A_TOKEN;
    rewards[10] = AaveV3PlasmaAssets.USDT0_A_TOKEN;
    rewards[11] = AaveV3PlasmaAssets.weETH_A_TOKEN;
    rewards[12] = AaveV3PlasmaAssets.WETH_A_TOKEN;
    rewards[13] = AaveV3PlasmaAssets.wrsETH_A_TOKEN;
    rewards[14] = AaveV3PlasmaAssets.wstETH_A_TOKEN;
    rewards[15] = AaveV3PlasmaAssets.WXPL_A_TOKEN;
    rewards[16] = AaveV3PlasmaAssets.XAUt0_A_TOKEN;
    rewards[17] = AaveV3PlasmaAssets.GHO_UNDERLYING;
    rewards[18] = AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_UNDERLYING;
    rewards[19] = AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_UNDERLYING;
    rewards[20] = AaveV3PlasmaAssets.PT_sUSDE_9APR2026_UNDERLYING;
    rewards[21] = AaveV3PlasmaAssets.PT_USDe_15JAN2026_UNDERLYING;
    rewards[22] = AaveV3PlasmaAssets.PT_USDe_18JUN2026_UNDERLYING;
    rewards[23] = AaveV3PlasmaAssets.PT_USDe_9APR2026_UNDERLYING;
    rewards[24] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    rewards[25] = AaveV3PlasmaAssets.syrupUSDT_UNDERLYING;
    rewards[26] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    rewards[27] = AaveV3PlasmaAssets.USDT0_UNDERLYING;
    rewards[28] = AaveV3PlasmaAssets.GHO_V_TOKEN;
    rewards[29] = AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_V_TOKEN;
    rewards[30] = AaveV3PlasmaAssets.PT_USDe_18JUN2026_V_TOKEN;
    rewards[31] = AaveV3PlasmaAssets.weETH_UNDERLYING;
    rewards[32] = AaveV3PlasmaAssets.WETH_UNDERLYING;
    rewards[33] = AaveV3PlasmaAssets.wrsETH_UNDERLYING;
    rewards[34] = AaveV3PlasmaAssets.wstETH_UNDERLYING;
    rewards[35] = AaveV3PlasmaAssets.WXPL_UNDERLYING;
    rewards[36] = AaveV3PlasmaAssets.XAUt0_UNDERLYING;
    return rewards;
  }
}
