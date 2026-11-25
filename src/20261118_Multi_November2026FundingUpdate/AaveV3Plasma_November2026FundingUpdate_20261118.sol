// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GhoPlasma} from 'aave-address-book/GhoPlasma.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {IGsm} from 'src/interfaces/IGsm.sol';

/**
 * @title November 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312
 */
contract AaveV3Plasma_November2026FundingUpdate_20261118 is IProposalGenericExecutor {
  uint256 public constant AFC_GHO_ALLOWANCE = 1_100_000 ether;
  uint256 public constant AFC_AGHO_ALLOWANCE = 1_100_000 ether;

  function execute() external {
    _afcAllowances();
    _rescueGsmRewards();
  }

  function _afcAllowances() internal {
    AaveV3Plasma.COLLECTOR.approve(
      IERC20(AaveV3PlasmaAssets.GHO_UNDERLYING),
      MiscPlasma.AFC_SAFE,
      AFC_GHO_ALLOWANCE
    );
    AaveV3Plasma.COLLECTOR.approve(
      IERC20(AaveV3PlasmaAssets.GHO_A_TOKEN),
      MiscPlasma.AFC_SAFE,
      AFC_AGHO_ALLOWANCE
    );
  }

  function _rescueGsmRewards() internal {
    IGsm gsm = IGsm(GhoPlasma.GSM_USDT);
    uint256 amount = IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(address(gsm));

    bytes32 rescuerRole = gsm.TOKEN_RESCUER_ROLE();
    IAccessControl(address(gsm)).grantRole(rescuerRole, GovernanceV3Plasma.EXECUTOR_LVL_1);
    gsm.rescueTokens(AaveV3PlasmaAssets.WXPL_UNDERLYING, MiscPlasma.AFC_SAFE, amount);
    IAccessControl(address(gsm)).revokeRole(rescuerRole, GovernanceV3Plasma.EXECUTOR_LVL_1);
  }
}
