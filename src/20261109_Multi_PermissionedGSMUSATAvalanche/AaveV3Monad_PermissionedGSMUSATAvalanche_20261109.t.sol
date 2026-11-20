// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {AaveV3Monad} from 'aave-address-book/AaveV3Monad.sol';

import {AaveV3Monad_PermissionedGSMUSATAvalanche_20261109} from './AaveV3Monad_PermissionedGSMUSATAvalanche_20261109.sol';
import {PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest} from './setup/PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Monad_PermissionedGSMUSATAvalanche_20261109
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Monad_PermissionedGSMUSATAvalanche_20261109.t.sol -vv
 * forge-config: default.networks.network = "monad"
 * forge-config: default.hardfork = "monad:MonadTen"
 */
contract AaveV3Monad_PermissionedGSMUSATAvalanche_20261109_Test is
  PermissionedGSMUSATAvalancheFacilitatorProposalBaseTest
{
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('monad'), 121848000);
    proposal = new AaveV3Monad_PermissionedGSMUSATAvalanche_20261109();
    chainSelector = CCIPChainSelectors.MONAD;
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Monad_PermissionedGSMUSATAvalanche_20261109',
      AaveV3Monad.POOL,
      address(proposal)
    );
  }
}
