// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Plasma} from 'aave-address-book/AaveV3Plasma.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907.sol';

/**
 * @dev Test for AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907.t.sol -vv
 */
contract AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907_Test is ProtocolV3TestBase {
  AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 32456523);
    proposal = new AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907',
      AaveV3Plasma.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Plasma.POOL, address(proposal), updatedAssets);
  }

  function test_fundsAdminRoleGranted() public {
    assertFalse(
      IAccessControl(address(AaveV3Plasma.COLLECTOR)).hasRole(
        AaveV3Plasma.COLLECTOR.FUNDS_ADMIN_ROLE(),
        proposal.POOL_EXPOSURE_STEWARD()
      ),
      'steward should not have the funds admin role before execution'
    );

    executePayload(vm, address(proposal));

    assertTrue(
      IAccessControl(address(AaveV3Plasma.COLLECTOR)).hasRole(
        AaveV3Plasma.COLLECTOR.FUNDS_ADMIN_ROLE(),
        proposal.POOL_EXPOSURE_STEWARD()
      ),
      'steward should have the funds admin role after execution'
    );
  }
}
