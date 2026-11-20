// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {AaveV3InkWhitelabel} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {GovernanceV3Ink} from 'aave-address-book/GovernanceV3Ink.sol';

import {AaveV3Ink_PermissionedGSMUSATAvalanche_20261109} from './AaveV3Ink_PermissionedGSMUSATAvalanche_20261109.sol';
import {PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest} from './setup/PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Ink_PermissionedGSMUSATAvalanche_20261109
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ink_PermissionedGSMUSATAvalanche_20261109.t.sol -vv
 */
contract AaveV3Ink_PermissionedGSMUSATAvalanche_20261109_Test is
  PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest
{
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 61062800);
    proposal = new AaveV3Ink_PermissionedGSMUSATAvalanche_20261109();
    chainSelector = CCIPChainSelectors.INK;
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ink_PermissionedGSMUSATAvalanche_20261109',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      GovernanceV3Ink.PAYLOADS_CONTROLLER
    );
  }
}
