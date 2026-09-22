// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GhoArbitrum} from 'aave-address-book/GhoArbitrum.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';

import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title USDC GSM Arbitrum
 * @author @TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xf24321514fb593af9e5082d26a1358819ec0f648db8fdb5c2b083f53ef785793
 * - Discussion: https://governance.aave.com/t/arfc-launch-remotegsm-on-arbitrum/24986/5
 */
contract AaveV3Arbitrum_USDCGSMArbitrum_20260806 is IProposalGenericExecutor {
  // https://arbiscan.io/address/0x1aEe7A618B0CC687cCED9aB796e464062f1508CA
  address public constant NEW_GSM_USDC = 0x1aEe7A618B0CC687cCED9aB796e464062f1508CA;

  // https://arbiscan.io/address/0x2Be58aD215AA8552CB5BD038a88d0dE39d2427BB
  address public constant GSM_REGISTRY = 0x2Be58aD215AA8552CB5BD038a88d0dE39d2427BB;

  // https://arbiscan.io/address/0x4daF7FCe9EfcA48e9274b35b5A7B4639b0DdFCCa
  address public constant USDC_ORACLE_SWAP_FREEZER = 0x4daF7FCe9EfcA48e9274b35b5A7B4639b0DdFCCa;

  uint128 public constant RESERVE_LIMIT_GSM = 25_000_000 ether;

  bytes32 public immutable LIQUIDATOR_ROLE = IGsm(GhoArbitrum.GSM_USDC).LIQUIDATOR_ROLE();
  bytes32 public immutable SWAP_FREEZER_ROLE = IGsm(GhoArbitrum.GSM_USDC).SWAP_FREEZER_ROLE();

  function execute() external {
    _seize();
    _grantAccess();
    _updateFeeStrategy();
    _revokeAccess();
  }

  function _seize() internal {
    // Technically not needed but for completeness will perform
    // Current GSM has not used any GHO and does not hold any USDC.e
    IGsm(GhoArbitrum.GSM_USDC).distributeFeesToTreasury();
    IGsm(GhoArbitrum.GSM_USDC).grantRole(LIQUIDATOR_ROLE, GovernanceV3Arbitrum.EXECUTOR_LVL_1);
    IGsm(GhoArbitrum.GSM_USDC).seize();
  }

  function _grantAccess() internal {
    // Enroll GSMs as entities and set limit
    IGhoReserve(GhoArbitrum.GHO_RESERVE).addEntity(NEW_GSM_USDC);

    IGhoReserve(GhoArbitrum.GHO_RESERVE).setLimit(NEW_GSM_USDC, RESERVE_LIMIT_GSM);

    // Add GSM Swap Freezer role to OracleSwapFreezers
    IGsm(NEW_GSM_USDC).grantRole(SWAP_FREEZER_ROLE, USDC_ORACLE_SWAP_FREEZER);
    IGsm(NEW_GSM_USDC).grantRole(SWAP_FREEZER_ROLE, GovernanceV3Arbitrum.EXECUTOR_LVL_1);

    // Add GSMs to GSM Registry
    IGsmRegistry(GSM_REGISTRY).addGsm(NEW_GSM_USDC);

    // GHO GSM Steward
    IGsm(NEW_GSM_USDC).grantRole(
      IGsm(NEW_GSM_USDC).CONFIGURATOR_ROLE(),
      GhoArbitrum.GHO_GSM_STEWARD
    );
  }

  function _updateFeeStrategy() internal {
    IGsm(NEW_GSM_USDC).updateFeeStrategy(IGsm(GhoArbitrum.GSM_USDC).getFeeStrategy());
  }

  function _revokeAccess() internal {
    // Remove existing GSMs from Registry and Reserve
    IGhoReserve(GhoArbitrum.GHO_RESERVE).setLimit(GhoArbitrum.GSM_USDC, 0);
    IGsmRegistry(GSM_REGISTRY).removeGsm(GhoArbitrum.GSM_USDC);
    IGhoReserve(GhoArbitrum.GHO_RESERVE).removeEntity(GhoArbitrum.GSM_USDC);

    // Revoke Roles
    IGsm(GhoArbitrum.GSM_USDC).revokeRole(
      SWAP_FREEZER_ROLE,
      GhoArbitrum.GSM_USDC_ORACLE_SWAP_FREEZER
    );

    IGsm(GhoArbitrum.GSM_USDC).revokeRole(SWAP_FREEZER_ROLE, GovernanceV3Arbitrum.EXECUTOR_LVL_1);
    IGsm(GhoArbitrum.GSM_USDC).revokeRole(LIQUIDATOR_ROLE, GovernanceV3Arbitrum.EXECUTOR_LVL_1);

    // GHO GSM Steward
    IGsm(GhoArbitrum.GSM_USDC).revokeRole(
      IGsm(GhoArbitrum.GSM_USDC).CONFIGURATOR_ROLE(),
      GhoArbitrum.GHO_GSM_STEWARD
    );
  }
}
