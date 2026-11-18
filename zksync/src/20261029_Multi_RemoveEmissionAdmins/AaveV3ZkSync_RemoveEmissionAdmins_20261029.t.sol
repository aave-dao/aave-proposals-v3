// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ZkSync} from 'aave-address-book/AaveV3ZkSync.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import {ProtocolV3TestBase} from 'aave-helpers/zksync/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from '../../../src/20261029_Multi_RemoveEmissionAdmins/EmissionAdminRemovalChecks.sol';
import {AaveV3ZkSync_RemoveEmissionAdmins_20261029} from './AaveV3ZkSync_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3ZkSync_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=zksync forge test --zksync --match-path=zksync/src/20261029_Multi_RemoveEmissionAdmins/AaveV3ZkSync_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3ZkSync_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3ZkSync_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public override {
    vm.createSelectFork(vm.rpcUrl('zksync'), 72988525);
    proposal = new AaveV3ZkSync_RemoveEmissionAdmins_20261029();

    super.setUp();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    // e2e off: every reserve is frozen, so the e2e collateral picker finds nothing to supply
    defaultTest({
      reportName: 'AaveV3ZkSync_RemoveEmissionAdmins_20261029',
      pool: AaveV3ZkSync.POOL,
      payload: address(proposal),
      runE2E: false,
      runSeatbelt: false
    });
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3ZkSync.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3ZkSync.EMISSION_MANAGER, pools);
  }
}
