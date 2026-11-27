// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Gnosis, AaveV3GnosisAssets} from 'aave-address-book/AaveV3Gnosis.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title November 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312
 */
contract AaveV3Gnosis_November2026FundingUpdate_20261118 is IProposalGenericExecutor {
  uint256 public constant AFC_WXDAI_ALLOWANCE = 305_000 ether;
  uint256 public constant AFC_USDC_ALLOWANCE = 90_000e6;
  uint256 public constant AFC_USDCE_ALLOWANCE = 41_000e6;

  function execute() external {
    AaveV3Gnosis.COLLECTOR.approve(
      IERC20(AaveV3GnosisAssets.WXDAI_A_TOKEN),
      MiscGnosis.AFC_SAFE,
      AFC_WXDAI_ALLOWANCE
    );
    AaveV3Gnosis.COLLECTOR.approve(
      IERC20(AaveV3GnosisAssets.USDC_A_TOKEN),
      MiscGnosis.AFC_SAFE,
      AFC_USDC_ALLOWANCE
    );
    AaveV3Gnosis.COLLECTOR.approve(
      IERC20(AaveV3GnosisAssets.USDCe_A_TOKEN),
      MiscGnosis.AFC_SAFE,
      AFC_USDCE_ALLOWANCE
    );
  }
}
