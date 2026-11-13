// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumHorizon} from 'aave-address-book/AaveV3EthereumHorizon.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV3HorizonTestBase} from '../../tests/utils/horizon/ProtocolV3HorizonTestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029} from './AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3HorizonTestBase,
  EmissionAdminRemovalChecks
{
  AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26296844);
    proposal = new AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the Horizon test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest_v3_3(
      'AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029',
      AaveV3EthereumHorizon.POOL,
      _executeProposal
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3EthereumHorizon.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3EthereumHorizon.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3EthereumHorizon.EMISSION_MANAGER, pools);
  }

  // the EmissionManager is owned by the DAO Executor Lvl1, not the Horizon executor
  function _executeProposal() internal {
    GovV3Helpers.executePayload(vm, address(proposal));
  }
}
