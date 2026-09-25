// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';

import {AaveV3Base_RemoteGSMLaunchXLayer_20260729} from './AaveV3Base_RemoteGSMLaunchXLayer_20260729.sol';
import {RemoteGSMLaunchXLayerFacilitatorProposalBaseTest} from './setup/RemoteGSMLaunchXLayerFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Base_RemoteGSMLaunchXLayer_20260729
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Base_RemoteGSMLaunchXLayer_20260729.t.sol -vv
 */
contract AaveV3Base_RemoteGSMLaunchXLayer_20260729_Test is
  RemoteGSMLaunchXLayerFacilitatorProposalBaseTest
{
  function CURRENT_CHAIN_SELECTOR() public pure override returns (uint64) {
    return CCIPChainSelectors.BASE;
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 49827271);
    proposal = new AaveV3Base_RemoteGSMLaunchXLayer_20260729();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest('AaveV3Base_RemoteGSMLaunchXLayer_20260729', AaveV3Base.POOL, address(proposal));
  }
}
