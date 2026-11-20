// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV2Avalanche, AaveV2AvalancheAssets} from 'aave-address-book/AaveV2Avalanche.sol';

/**
 * @title Reserve Factor Updates Across Aave V3 and V2 Markets
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249
 */
contract AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 is
  IProposalGenericExecutor
{
  uint256 public constant DAIe_RF = 99_99;
  uint256 public constant USDCe_RF = 99_99;
  uint256 public constant USDTe_RF = 99_99;
  uint256 public constant WETHe_RF = 99_99;
  uint256 public constant WAVAX_RF = 99_99;
  uint256 public constant AAVEe_RF = 99_99;

  function execute() external {
    AaveV2Avalanche.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2AvalancheAssets.DAIe_UNDERLYING,
      DAIe_RF
    );
    AaveV2Avalanche.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2AvalancheAssets.USDCe_UNDERLYING,
      USDCe_RF
    );
    AaveV2Avalanche.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2AvalancheAssets.USDTe_UNDERLYING,
      USDTe_RF
    );
    AaveV2Avalanche.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2AvalancheAssets.WETHe_UNDERLYING,
      WETHe_RF
    );
    AaveV2Avalanche.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2AvalancheAssets.WAVAX_UNDERLYING,
      WAVAX_RF
    );
    AaveV2Avalanche.POOL_CONFIGURATOR.setReserveFactor(
      AaveV2AvalancheAssets.AAVEe_UNDERLYING,
      AAVEe_RF
    );
  }
}
