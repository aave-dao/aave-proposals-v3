// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Low Adoption Asset Deprecation on Aave V3
 * @author Llama Risk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7
 * - Discussion: https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401
 * @dev Split in two payloads to stay within the payload execution gas ceiling: this payload
 * freezes the 15 matured Pendle PT reserves (their caps are already at 1); the remaining
 * changes are executed by AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826.
 */
contract AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826 is
  IProposalGenericExecutor
{
  function execute() external {
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_eUSDE_29MAY2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_sUSDE_31JUL2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_USDe_31JUL2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_eUSDE_14AUG2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_sUSDE_25SEP2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_USDe_25SEP2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_sUSDE_27NOV2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_USDe_27NOV2025_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_USDe_5FEB2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_sUSDE_5FEB2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_srUSDe_2APR2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_USDe_7MAY2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_sUSDE_7MAY2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_USDG_28MAY2026_UNDERLYING,
      true
    );
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumAssets.PT_srUSDe_25JUN2026_UNDERLYING,
      true
    );
  }
}
