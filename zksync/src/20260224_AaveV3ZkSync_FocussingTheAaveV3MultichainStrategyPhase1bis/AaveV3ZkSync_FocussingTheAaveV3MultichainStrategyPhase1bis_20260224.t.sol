// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ZkSync} from 'aave-address-book/AaveV3ZkSync.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/zksync/src/ProtocolV3TestBase.sol';
import {AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224} from './AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224.sol';

/**
 * @dev Test for AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224
 * command: FOUNDRY_PROFILE=zksync forge test --zksync --match-path=zksync/src/20260224_AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis/AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224.t.sol -vv
 */
contract AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224_Test is
  ProtocolV3TestBase
{
  function setUp() public override {
    vm.createSelectFork(vm.rpcUrl('zksync'), 68739788);

    super.setUp();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224',
      AaveV3ZkSync.POOL,
      address(0x58eA48D4dB13ae318a30D65875F063e4CfE66371) // https://zksync.blockscout.com/tx/0xfb9dc7d8307cf7a45b916107f0471488d869bdf2760eb0fbcc061b499f46bd4a?tab=index
    );
  }
}
