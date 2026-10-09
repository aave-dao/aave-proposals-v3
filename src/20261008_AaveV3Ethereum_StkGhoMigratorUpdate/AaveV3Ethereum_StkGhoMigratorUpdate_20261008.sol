// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IStkGhoMigrator} from '../interfaces/IStkGhoMigrator.sol';

/**
 * @title Move stkGHO Claim Helper Role to Updated StkGhoMigrator
 * @author Aave Labs
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/technical-maintenance-proposals/15274/138
 */
contract AaveV3Ethereum_StkGhoMigratorUpdate_20261008 is IProposalGenericExecutor {
  // https://etherscan.io/address/0xC836143e39201698e7d543bCf21AfF3415aE4697
  address public constant STK_GHO_MIGRATOR = 0xC836143e39201698e7d543bCf21AfF3415aE4697;

  // https://etherscan.io/address/0x4C728397b9d5C8071d46229DF8823Ea2782124fb
  address public constant NEW_STK_GHO_MIGRATOR = 0x4C728397b9d5C8071d46229DF8823Ea2782124fb;

  function execute() external {
    IStkGhoMigrator(STK_GHO_MIGRATOR).setClaimHelperPendingAdmin(NEW_STK_GHO_MIGRATOR);
    IStkGhoMigrator(NEW_STK_GHO_MIGRATOR).claimHelperRole();
    IStkGhoMigrator(STK_GHO_MIGRATOR).pause();
  }
}
