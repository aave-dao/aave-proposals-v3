// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title August/September 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597
 */
contract AaveV3Base_AugustSeptember2026FundingUpdate_20260907 is IProposalGenericExecutor {
  uint256 public constant AFC_USDC_ALLOWANCE = 443_000e6;

  function execute() external {
    AaveV3Base.COLLECTOR.approve(
      IERC20(AaveV3BaseAssets.USDC_A_TOKEN),
      MiscBase.AFC_SAFE,
      AFC_USDC_ALLOWANCE
    );
  }
}
