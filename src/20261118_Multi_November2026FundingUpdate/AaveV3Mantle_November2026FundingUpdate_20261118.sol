// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Mantle, AaveV3MantleAssets} from 'aave-address-book/AaveV3Mantle.sol';
import {MiscMantle} from 'aave-address-book/MiscMantle.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title November 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312
 */
contract AaveV3Mantle_November2026FundingUpdate_20261118 is IProposalGenericExecutor {
  uint256 public constant AFC_USDT0_ALLOWANCE = 570_000e6;
  uint256 public constant AFC_WETH_ALLOWANCE = 59 ether;

  function execute() external {
    AaveV3Mantle.COLLECTOR.approve(
      IERC20(AaveV3MantleAssets.USDT0_A_TOKEN),
      MiscMantle.AFC_SAFE,
      AFC_USDT0_ALLOWANCE
    );
    AaveV3Mantle.COLLECTOR.approve(
      IERC20(AaveV3MantleAssets.WETH_A_TOKEN),
      MiscMantle.AFC_SAFE,
      AFC_WETH_ALLOWANCE
    );
  }
}
