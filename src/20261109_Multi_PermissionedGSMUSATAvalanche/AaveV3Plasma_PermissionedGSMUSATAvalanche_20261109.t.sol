// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {AaveV3Plasma} from 'aave-address-book/AaveV3Plasma.sol';

import {AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109} from './AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109.sol';
import {PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest} from './setup/PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109.t.sol -vv
 */
contract AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109_Test is
  PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest
{
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 37617800);
    proposal = new AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109();
    chainSelector = CCIPChainSelectors.PLASMA;
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109',
      AaveV3Plasma.POOL,
      address(proposal)
    );
  }
}
