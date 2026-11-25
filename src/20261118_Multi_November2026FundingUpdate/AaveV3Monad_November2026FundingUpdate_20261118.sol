// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Monad, AaveV3MonadAssets} from 'aave-address-book/AaveV3Monad.sol';
import {GovernanceV3Monad} from 'aave-address-book/GovernanceV3Monad.sol';
import {GhoMonad} from 'aave-address-book/GhoMonad.sol';
import {MiscMonad} from 'aave-address-book/MiscMonad.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {IGsm} from 'src/interfaces/IGsm.sol';

/**
 * @title November 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312
 */
contract AaveV3Monad_November2026FundingUpdate_20261118 is IProposalGenericExecutor {
  // https://monadscan.com/address/0x3bd359C1119dA7Da1D913D1C4D2B7c461115433A
  address public constant WMON = 0x3bd359C1119dA7Da1D913D1C4D2B7c461115433A;

  uint256 public constant AFC_GHO_ALLOWANCE = 300_000 ether;
  uint256 public constant AFC_AGHO_ALLOWANCE = 300_000 ether;

  function execute() external {
    _afcAllowances();
    _rescueGsmRewards();
  }

  function _afcAllowances() internal {
    AaveV3Monad.COLLECTOR.approve(
      IERC20(AaveV3MonadAssets.GHO_UNDERLYING),
      MiscMonad.AFC_SAFE,
      AFC_GHO_ALLOWANCE
    );
    AaveV3Monad.COLLECTOR.approve(
      IERC20(AaveV3MonadAssets.GHO_A_TOKEN),
      MiscMonad.AFC_SAFE,
      AFC_AGHO_ALLOWANCE
    );
  }

  function _rescueGsmRewards() internal {
    IGsm gsm = IGsm(GhoMonad.GSM_USDC);
    uint256 amount = IERC20(WMON).balanceOf(address(gsm));

    bytes32 rescuerRole = gsm.TOKEN_RESCUER_ROLE();
    IAccessControl(address(gsm)).grantRole(rescuerRole, GovernanceV3Monad.EXECUTOR_LVL_1);
    gsm.rescueTokens(WMON, MiscMonad.AFC_SAFE, amount);
    IAccessControl(address(gsm)).revokeRole(rescuerRole, GovernanceV3Monad.EXECUTOR_LVL_1);
  }
}
