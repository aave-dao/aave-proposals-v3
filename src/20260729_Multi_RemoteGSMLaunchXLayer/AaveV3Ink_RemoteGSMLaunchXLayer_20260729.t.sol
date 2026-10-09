// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {GovernanceV3Ink} from 'aave-address-book/GovernanceV3Ink.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';

import {AaveV3Ink_RemoteGSMLaunchXLayer_20260729} from './AaveV3Ink_RemoteGSMLaunchXLayer_20260729.sol';
import {RemoteGSMLaunchXLayerFacilitatorProposalBaseTest} from './setup/RemoteGSMLaunchXLayerFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Ink_RemoteGSMLaunchXLayer_20260729
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ink_RemoteGSMLaunchXLayer_20260729.t.sol -vv
 */
contract AaveV3Ink_RemoteGSMLaunchXLayer_20260729_Test is
  RemoteGSMLaunchXLayerFacilitatorProposalBaseTest
{
  function CURRENT_CHAIN_SELECTOR() public pure override returns (uint64) {
    return CCIPChainSelectors.INK;
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 52945574);
    proposal = new AaveV3Ink_RemoteGSMLaunchXLayer_20260729();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ink_RemoteGSMLaunchXLayer_20260729',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      GovernanceV3Ink.PAYLOADS_CONTROLLER
    );
  }
}
