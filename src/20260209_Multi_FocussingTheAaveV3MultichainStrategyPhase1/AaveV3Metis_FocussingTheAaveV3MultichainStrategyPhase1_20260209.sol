// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Metis, AaveV3MetisAssets} from 'aave-address-book/AaveV3Metis.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Focussing the Aave V3 Multichain Strategy - Phase 1
 * @author Aavechan Initiative @aci
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x62340121a7428f902f3232030350eb2d2bb753dc10ab0657a16ffd4d85cb530b
 * - Discussion: https://governance.aave.com/t/arfc-focussing-the-aave-v3-multichain-strategy-phase-1/23954
 */
contract AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209 is
  IProposalGenericExecutor
{
  function execute() external {
    AaveV3Metis.POOL_CONFIGURATOR.setReserveFreeze(AaveV3MetisAssets.mDAI_UNDERLYING, true);
    AaveV3Metis.POOL_CONFIGURATOR.setReserveFreeze(AaveV3MetisAssets.Metis_UNDERLYING, true);
    AaveV3Metis.POOL_CONFIGURATOR.setReserveFreeze(AaveV3MetisAssets.mUSDC_UNDERLYING, true);
    AaveV3Metis.POOL_CONFIGURATOR.setReserveFreeze(AaveV3MetisAssets.mUSDT_UNDERLYING, true);
    AaveV3Metis.POOL_CONFIGURATOR.setReserveFreeze(AaveV3MetisAssets.WETH_UNDERLYING, true);
  }
}
