// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Metis} from 'aave-address-book/AaveV3Metis.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209} from './AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol';

/**
 * @dev Test for AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209.t.sol -vv
 */
contract AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209_Test is
  ProtocolV3TestBase
{
  AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('metis'), 22138489);
    proposal = new AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209',
      AaveV3Metis.POOL,
      address(proposal),
      false,
      false
    );
  }
  /**
   * @dev check instance is deprecated
   */
  function test_isDeprecated() public {
    executePayload(vm, address(proposal), AaveV3Metis.POOL);
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Metis.POOL);
    for (uint256 i = 0; i < configs.length; i++) {
      assertTrue(configs[i].isFrozen, "a reserve isn't frozen");
    }
  }
}
