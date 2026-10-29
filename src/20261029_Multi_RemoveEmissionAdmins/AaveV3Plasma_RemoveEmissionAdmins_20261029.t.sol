// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma} from 'aave-address-book/AaveV3Plasma.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3Plasma_RemoveEmissionAdmins_20261029} from './AaveV3Plasma_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3Plasma_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3Plasma_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3Plasma_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3Plasma_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 36316814);
    proposal = new AaveV3Plasma_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV3Plasma_RemoveEmissionAdmins_20261029', AaveV3Plasma.POOL, address(proposal));
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Plasma.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3Plasma.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3Plasma.EMISSION_MANAGER, pools);
  }
}
