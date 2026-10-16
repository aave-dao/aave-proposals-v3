// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';

import {AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729} from './AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729.sol';
import {RemoteGSMLaunchXLayerFacilitatorProposalBaseTest} from './setup/RemoteGSMLaunchXLayerFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729.t.sol -vv
 */
contract AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729_Test is
  RemoteGSMLaunchXLayerFacilitatorProposalBaseTest
{
  function CURRENT_CHAIN_SELECTOR() public pure override returns (uint64) {
    return CCIPChainSelectors.AVALANCHE;
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 92551188);
    proposal = new AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
  }
}
