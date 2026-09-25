// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Monad} from 'aave-address-book/AaveV3Monad.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title August/September 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597
 */
contract AaveV3Monad_AugustSeptember2026FundingUpdate_20260907 is IProposalGenericExecutor {
  // https://monadscan.com/address/0x72EAfbD4331dD482f5c8135fF0452d97da6F77B0
  address public constant POOL_EXPOSURE_STEWARD = 0x72EAfbD4331dD482f5c8135fF0452d97da6F77B0;

  function execute() external {
    IAccessControl(address(AaveV3Monad.COLLECTOR)).grantRole(
      AaveV3Monad.COLLECTOR.FUNDS_ADMIN_ROLE(),
      POOL_EXPOSURE_STEWARD
    );
  }
}
