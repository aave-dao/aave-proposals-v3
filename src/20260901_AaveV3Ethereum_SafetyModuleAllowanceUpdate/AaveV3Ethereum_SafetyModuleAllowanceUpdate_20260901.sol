// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveSafetyModule} from 'aave-address-book/AaveSafetyModule.sol';
import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IStakeToken} from 'aave-address-book/common/IStakeToken.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

/**
 * @title Safety Module August 2026 - Allowance Update
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-safety-module-august-2026-allowance-update/25550
 */
contract AaveV3Ethereum_SafetyModuleAllowanceUpdate_20260901 is IProposalGenericExecutor {
  // Claimable backlog not covered by the stkAAVE allowance at the snapshot, rounded up.
  // Claims after the snapshot reduce the backlog and the live allowance by the same amount,
  // so adding this constant to the allowance read at execution time remains exact.
  uint256 public constant STK_AAVE_BACKLOG_GAP = 50_500 ether;
  // 2026-08-27 00:45:23 UTC, block 25843055
  uint256 public constant SNAPSHOT_TIMESTAMP = 1_787_791_523;
  uint256 public constant FORWARD_EMISSIONS_PERIOD = 90 days;

  uint256 public constant STK_ABPT_V1_ABSOLUTE_ALLOWANCE = 1_250 ether;
  uint256 public constant STK_GHO_ABSOLUTE_ALLOWANCE = 1_200 ether;
  uint256 public constant STK_AAVE_WSTETH_BPTV2_ABSOLUTE_ALLOWANCE = 2_500 ether;

  function execute() external override {
    (uint128 emissionPerSecond, , ) = IStakeToken(AaveSafetyModule.STK_AAVE).assets(
      AaveSafetyModule.STK_AAVE
    );
    uint256 currentAllowance = IERC20(AaveV3EthereumAssets.AAVE_UNDERLYING).allowance(
      MiscEthereum.ECOSYSTEM_RESERVE,
      AaveSafetyModule.STK_AAVE
    );
    uint256 newStkAaveAllowance = currentAllowance +
      STK_AAVE_BACKLOG_GAP +
      emissionPerSecond *
      (block.timestamp - SNAPSHOT_TIMESTAMP + FORWARD_EMISSIONS_PERIOD);

    _setAllowance(AaveSafetyModule.STK_AAVE, newStkAaveAllowance);
    _setAllowance(AaveSafetyModule.STK_ABPT, STK_ABPT_V1_ABSOLUTE_ALLOWANCE);
    _setAllowance(AaveSafetyModule.STK_GHO, STK_GHO_ABSOLUTE_ALLOWANCE);
    _setAllowance(AaveSafetyModule.STK_AAVE_WSTETH_BPTV2, STK_AAVE_WSTETH_BPTV2_ABSOLUTE_ALLOWANCE);
  }

  function _setAllowance(address module, uint256 amount) internal {
    MiscEthereum.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
      MiscEthereum.ECOSYSTEM_RESERVE,
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      module,
      0
    );
    MiscEthereum.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
      MiscEthereum.ECOSYSTEM_RESERVE,
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      module,
      amount
    );
  }
}
