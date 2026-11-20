// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';

import {AaveV3Base_PermissionedGSMUSATAvalanche_20261109} from './AaveV3Base_PermissionedGSMUSATAvalanche_20261109.sol';
import {PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest} from './setup/PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Base_PermissionedGSMUSATAvalanche_20261109
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Base_PermissionedGSMUSATAvalanche_20261109.t.sol -vv
 */
contract AaveV3Base_PermissionedGSMUSATAvalanche_20261109_Test is
  PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest
{
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 56854300);
    proposal = new AaveV3Base_PermissionedGSMUSATAvalanche_20261109();
    chainSelector = CCIPChainSelectors.BASE;
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Base_PermissionedGSMUSATAvalanche_20261109',
      AaveV3Base.POOL,
      address(proposal)
    );
  }
}
