// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {ISvrOracleSteward} from '../interfaces/ISvrOracleSteward.sol';
import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224} from './AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224.sol';

/**
 * @dev Test for AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260224_Multi_EnableSVROnBaseAndArbitrum/AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224.t.sol -vv
 */
contract AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 436476086);
    proposal = new AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  function test_activation() public {
    ISvrOracleSteward.AssetOracle[] memory cfg = proposal.getSvrOracles();

    for (uint256 i = 0; i < cfg.length; i++) {
      assertNotEq(AaveV3Arbitrum.ORACLE.getSourceOfAsset(cfg[i].asset), cfg[i].svrOracle);
    }

    executePayload(vm, address(proposal), AaveV3Arbitrum.POOL);

    for (uint256 i = 0; i < cfg.length; i++) {
      assertEq(AaveV3Arbitrum.ORACLE.getSourceOfAsset(cfg[i].asset), cfg[i].svrOracle);
    }
  }
}
