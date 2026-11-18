// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Sonic, AaveV3SonicAssets} from 'aave-address-book/AaveV3Sonic.sol';
import {MiscSonic} from 'aave-address-book/MiscSonic.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title November 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312
 */
contract AaveV3Sonic_November2026FundingUpdate_20261118 is IProposalGenericExecutor {
  uint256 public constant AFC_USDC_ALLOWANCE = 100_000e6;

  function execute() external {
    _afcAllowances();
  }

  function _afcAllowances() internal {
    AaveV3Sonic.COLLECTOR.approve(
      IERC20(AaveV3SonicAssets.USDC_A_TOKEN),
      MiscSonic.AFC_SAFE,
      AFC_USDC_ALLOWANCE
    );
  }
}
