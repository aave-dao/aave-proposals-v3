// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {GhoAvalanche} from 'aave-address-book/GhoAvalanche.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IPermissionedGsm} from 'src/interfaces/IPermissionedGsm.sol';

import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';

/**
 * @title Permissioned GSM: USAT on Aave V4 Avalanche
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2
 * - Discussion: https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852
 *
 * @dev Reverts until the bridged GHO has reached the Avalanche Collector.
 * The GSM is deployed with its GhoReserve and the 20M exposure cap already set, and with no fee
 * strategy: fees are 0/0 and FixedFeeStrategy rejects 0/0. No oracle swap freezer: the Aave V3
 * Avalanche oracle has no USAT source.
 */
contract AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2 is IProposalGenericExecutor {
  // https://snowscan.xyz/address/0x15f22f39FD7b3612840cF0De49b6f9C4879Aa642
  IGhoReserve public constant GHO_RESERVE = IGhoReserve(0x15f22f39FD7b3612840cF0De49b6f9C4879Aa642);

  // https://snowscan.xyz/address/0x07ad9BEA5626ceAbcf857aaB1e398dd2327C901b
  address public constant GHO_GSM_STEWARD = 0x07ad9BEA5626ceAbcf857aaB1e398dd2327C901b;

  // https://snowscan.xyz/address/0x0a0dFf46122dFdc2aF0D5D66f23BA8f78bf17edF
  address public constant GSM_REGISTRY = 0x0a0dFf46122dFdc2aF0D5D66f23BA8f78bf17edF;

  // PermissionedGsm4626, underlying waCoreUSAT
  // https://snowscan.xyz/address/0xF6b70344b92cAb2D23c96eA834bbb45ADbdd6c40
  IPermissionedGsm public constant GSM_USAT =
    IPermissionedGsm(0xF6b70344b92cAb2D23c96eA834bbb45ADbdd6c40);

  function execute() external {
    GHO_RESERVE.grantRole(GHO_RESERVE.LIMIT_MANAGER_ROLE(), GhoAvalanche.RISK_COUNCIL);
    GHO_RESERVE.addEntity(address(GSM_USAT));
    GHO_RESERVE.setLimit(address(GSM_USAT), Setup.GSM_RESERVE_LIMIT);

    GSM_USAT.grantRole(GSM_USAT.SWAP_FREEZER_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1);

    IGsmRegistry(GSM_REGISTRY).addGsm(address(GSM_USAT));

    GSM_USAT.grantRole(GSM_USAT.CONFIGURATOR_ROLE(), GHO_GSM_STEWARD);

    // SWAP_ACCESS_MANAGER_ROLE administers BUY_ASSET_ROLE and SELL_ASSET_ROLE; the executor needs it to grant them
    bytes32 accessManagerRole = GSM_USAT.SWAP_ACCESS_MANAGER_ROLE();
    GSM_USAT.grantRole(accessManagerRole, GovernanceV3Avalanche.EXECUTOR_LVL_1);
    GSM_USAT.grantRole(accessManagerRole, GhoAvalanche.RISK_COUNCIL);
    // Aave DAO Safe controlled by the Aave Finance Committee, the only swapper at launch
    GSM_USAT.grantRole(GSM_USAT.BUY_ASSET_ROLE(), MiscAvalanche.AFC_SAFE);
    GSM_USAT.grantRole(GSM_USAT.SELL_ASSET_ROLE(), MiscAvalanche.AFC_SAFE);

    AaveV3Avalanche.COLLECTOR.transfer({
      token: IERC20(GhoAvalanche.GHO_TOKEN),
      recipient: address(GHO_RESERVE),
      amount: Setup.GHO_BRIDGE_AMOUNT
    });

    Setup.restoreLaneRateLimitConfig(GhoAvalanche.GHO_CCIP_TOKEN_POOL, CCIPChainSelectors.ETHEREUM);
  }
}
