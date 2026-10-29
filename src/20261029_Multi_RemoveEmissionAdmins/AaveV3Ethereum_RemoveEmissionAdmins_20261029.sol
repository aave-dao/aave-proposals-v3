// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';

/**
 * @title Remove Emission Admins
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: TODO
 */
contract AaveV3Ethereum_RemoveEmissionAdmins_20261029 is IProposalGenericExecutor {
  function execute() external {
    address[] memory rewards = getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      IEmissionManager(AaveV3Ethereum.EMISSION_MANAGER).setEmissionAdmin(rewards[i], address(0));
    }
  }

  /// @return every reward token with a non-zero emission admin on the AaveV3Ethereum EmissionManager
  function getRewards() public pure returns (address[] memory) {
    address[] memory rewards = new address[](81);
    rewards[0] = AaveV3EthereumAssets.BTCb_A_TOKEN;
    rewards[1] = AaveV3EthereumAssets.eBTC_A_TOKEN;
    rewards[2] = AaveV3EthereumAssets.EURC_A_TOKEN;
    rewards[3] = AaveV3EthereumAssets.eUSDe_A_TOKEN;
    rewards[4] = AaveV3EthereumAssets.FBTC_A_TOKEN;
    rewards[5] = AaveV3EthereumAssets.LBTC_A_TOKEN;
    rewards[6] = AaveV3EthereumLidoAssets.ezETH_A_TOKEN;
    rewards[7] = AaveV3EthereumLidoAssets.rsETH_A_TOKEN;
    rewards[8] = AaveV3EthereumLidoAssets.sUSDe_A_TOKEN;
    rewards[9] = AaveV3EthereumLidoAssets.tETH_A_TOKEN;
    rewards[10] = AaveV3EthereumLidoAssets.USDS_A_TOKEN;
    rewards[11] = AaveV3EthereumLidoAssets.WETH_A_TOKEN;
    rewards[12] = AaveV3EthereumLidoAssets.wstETH_A_TOKEN;
    rewards[13] = AaveV3EthereumAssets.PT_eUSDE_14AUG2025_A_TOKEN;
    rewards[14] = AaveV3EthereumAssets.PT_eUSDE_29MAY2025_A_TOKEN;
    rewards[15] = AaveV3EthereumAssets.PT_srUSDe_25JUN2026_A_TOKEN;
    rewards[16] = AaveV3EthereumAssets.PT_srUSDe_2APR2026_A_TOKEN;
    rewards[17] = AaveV3EthereumAssets.PT_sUSDE_25SEP2025_A_TOKEN;
    rewards[18] = AaveV3EthereumAssets.PT_sUSDE_27NOV2025_A_TOKEN;
    rewards[19] = AaveV3EthereumAssets.PT_sUSDE_31JUL2025_A_TOKEN;
    rewards[20] = AaveV3EthereumAssets.PT_sUSDE_5FEB2026_A_TOKEN;
    rewards[21] = AaveV3EthereumAssets.PT_sUSDE_7MAY2026_A_TOKEN;
    rewards[22] = AaveV3EthereumAssets.PT_USDe_25SEP2025_A_TOKEN;
    rewards[23] = AaveV3EthereumAssets.PT_USDe_27NOV2025_A_TOKEN;
    rewards[24] = AaveV3EthereumAssets.PT_USDe_31JUL2025_A_TOKEN;
    rewards[25] = AaveV3EthereumAssets.PT_USDe_5FEB2026_A_TOKEN;
    rewards[26] = AaveV3EthereumAssets.PT_USDe_7MAY2026_A_TOKEN;
    rewards[27] = AaveV3EthereumAssets.PT_USDG_28MAY2026_A_TOKEN;
    rewards[28] = AaveV3EthereumAssets.PYUSD_A_TOKEN;
    rewards[29] = AaveV3EthereumAssets.RLUSD_A_TOKEN;
    rewards[30] = AaveV3EthereumAssets.rsETH_A_TOKEN;
    rewards[31] = AaveV3EthereumAssets.syrupUSDT_A_TOKEN;
    rewards[32] = AaveV3EthereumAssets.USDG_A_TOKEN;
    rewards[33] = AaveV3EthereumAssets.USDS_A_TOKEN;
    rewards[34] = AaveV3EthereumAssets.USDtb_A_TOKEN;
    rewards[35] = AaveV3EthereumAssets.XAUt_A_TOKEN;
    rewards[36] = AaveV3EthereumAssets.BTCb_UNDERLYING;
    rewards[37] = AaveV3EthereumAssets.eBTC_UNDERLYING;
    rewards[38] = AaveV3EthereumAssets.ETHx_UNDERLYING;
    rewards[39] = AaveV3EthereumAssets.EURC_UNDERLYING;
    rewards[40] = AaveV3EthereumAssets.eUSDe_UNDERLYING;
    rewards[41] = AaveV3EthereumAssets.ezETH_UNDERLYING;
    rewards[42] = AaveV3EthereumAssets.FBTC_UNDERLYING;
    rewards[43] = 0x3f80B1c54Ae920Be41a77f8B902259D48cf24cCf; // KERNEL
    rewards[44] = AaveV3EthereumAssets.LBTC_UNDERLYING;
    rewards[45] = AaveV3EthereumAssets.LDO_UNDERLYING;
    rewards[46] = AaveV3EthereumAssets.osETH_UNDERLYING;
    rewards[47] = AaveV3EthereumAssets.PT_eUSDE_14AUG2025_UNDERLYING;
    rewards[48] = AaveV3EthereumAssets.PT_eUSDE_29MAY2025_UNDERLYING;
    rewards[49] = AaveV3EthereumAssets.PT_srUSDe_25JUN2026_UNDERLYING;
    rewards[50] = AaveV3EthereumAssets.PT_srUSDe_2APR2026_UNDERLYING;
    rewards[51] = AaveV3EthereumAssets.PT_sUSDE_25SEP2025_UNDERLYING;
    rewards[52] = AaveV3EthereumAssets.PT_sUSDE_27NOV2025_UNDERLYING;
    rewards[53] = AaveV3EthereumAssets.PT_sUSDE_31JUL2025_UNDERLYING;
    rewards[54] = AaveV3EthereumAssets.PT_sUSDE_5FEB2026_UNDERLYING;
    rewards[55] = AaveV3EthereumAssets.PT_sUSDE_7MAY2026_UNDERLYING;
    rewards[56] = AaveV3EthereumAssets.PT_USDe_25SEP2025_UNDERLYING;
    rewards[57] = AaveV3EthereumAssets.PT_USDe_27NOV2025_UNDERLYING;
    rewards[58] = AaveV3EthereumAssets.PT_USDe_31JUL2025_UNDERLYING;
    rewards[59] = AaveV3EthereumAssets.PT_USDe_5FEB2026_UNDERLYING;
    rewards[60] = AaveV3EthereumAssets.PT_USDe_7MAY2026_UNDERLYING;
    rewards[61] = AaveV3EthereumAssets.PT_USDG_28MAY2026_UNDERLYING;
    rewards[62] = AaveV3EthereumAssets.PYUSD_UNDERLYING;
    rewards[63] = 0x3B50805453023a91a8bf641e279401a0b23FA6F9; // REZ
    rewards[64] = AaveV3EthereumAssets.RLUSD_UNDERLYING;
    rewards[65] = AaveV3EthereumAssets.rsETH_UNDERLYING;
    rewards[66] = 0x30D20208d987713f46DFD34EF128Bb16C404D10f; // SD
    rewards[67] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    rewards[68] = 0x48C3399719B582dD63eB5AADf12A40B4C3f52FA2; // SWISE
    rewards[69] = AaveV3EthereumAssets.syrupUSDT_UNDERLYING;
    rewards[70] = AaveV3EthereumAssets.tBTC_UNDERLYING;
    rewards[71] = AaveV3EthereumAssets.tETH_UNDERLYING;
    rewards[72] = AaveV3EthereumAssets.USDG_UNDERLYING;
    rewards[73] = AaveV3EthereumAssets.USDS_UNDERLYING;
    rewards[74] = AaveV3EthereumAssets.USDtb_UNDERLYING;
    rewards[75] = AaveV3EthereumAssets.BTCb_V_TOKEN;
    rewards[76] = AaveV3EthereumAssets.PT_srUSDe_25JUN2026_V_TOKEN;
    rewards[77] = AaveV3EthereumAssets.PT_USDG_28MAY2026_V_TOKEN;
    rewards[78] = AaveV3EthereumAssets.WETH_UNDERLYING;
    rewards[79] = AaveV3EthereumAssets.wstETH_UNDERLYING;
    rewards[80] = AaveV3EthereumAssets.XAUt_UNDERLYING;
    return rewards;
  }
}
