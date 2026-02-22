// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Soneium, AaveV3SoneiumAssets} from 'aave-address-book/AaveV3Soneium.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Focussing the Aave V3 Multichain Strategy - Phase 1
 * @author Aavechan Initiative @aci
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x62340121a7428f902f3232030350eb2d2bb753dc10ab0657a16ffd4d85cb530b
 * - Discussion: https://governance.aave.com/t/arfc-focussing-the-aave-v3-multichain-strategy-phase-1/23954
 */
contract AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209 is
  IProposalGenericExecutor
{
  function execute() external {
    AaveV3Soneium.POOL_CONFIGURATOR.setReserveFreeze(AaveV3SoneiumAssets.WETH_UNDERLYING, true);
    AaveV3Soneium.POOL_CONFIGURATOR.setReserveFreeze(AaveV3SoneiumAssets.USDCe_UNDERLYING, true);
    AaveV3Soneium.POOL_CONFIGURATOR.setReserveFreeze(AaveV3SoneiumAssets.USDT_UNDERLYING, true);
  }
}
