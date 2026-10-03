// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Plasma} from 'aave-address-book/AaveV3Plasma.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title August/September 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597
 */
contract AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907 is IProposalGenericExecutor {
  // https://plasmascan.to/address/0xB5c5D35553826d681F3f3CC5Bae6cfA0446dE706
  address public constant POOL_EXPOSURE_STEWARD = 0xB5c5D35553826d681F3f3CC5Bae6cfA0446dE706;

  function execute() external {
    IAccessControl(address(AaveV3Plasma.COLLECTOR)).grantRole(
      AaveV3Plasma.COLLECTOR.FUNDS_ADMIN_ROLE(),
      POOL_EXPOSURE_STEWARD
    );
  }
}
