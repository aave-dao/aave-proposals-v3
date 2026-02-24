// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ZkSync} from 'aave-address-book/AaveV3ZkSync.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/zksync/src/ProtocolV3TestBase.sol';
import {AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209} from './AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol';

/**
 * @dev Test for AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209
 * command: FOUNDRY_PROFILE=zksync forge test --zksync --match-path=zksync/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209.t.sol -vv
 */
contract AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209_Test is
  ProtocolV3TestBase
{
  AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209 internal proposal;

  function setUp() public override {
    vm.createSelectFork(vm.rpcUrl('zksync'), 68460116);
    proposal = new AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209();

    super.setUp();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209',
      AaveV3ZkSync.POOL,
      address(proposal),
      false,
      false
    );
  }
  /**
   * @dev check instance is deprecated
   */
  function test_isDeprecated() public {
    executePayload(vm, address(proposal), AaveV3ZkSync.POOL);
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3ZkSync.POOL);
    for (uint256 i = 0; i < configs.length; i++) {
      assertTrue(configs[i].isFrozen, "a reserve isn't frozen");
    }
  }
}
