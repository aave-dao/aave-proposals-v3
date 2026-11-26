// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {GovernanceV3InkWhitelabel} from 'aave-address-book/GovernanceV3InkWhitelabel.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029} from './AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 61499000);
    proposal = new AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3InkWhitelabel_RemoveEmissionAdmins_20261029',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      true,
      true
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3InkWhitelabel.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3InkWhitelabel.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3InkWhitelabel.EMISSION_MANAGER, pools);
  }

  // the EmissionManager is owned by the whitelabel executor, not the Ink a.DI Executor Lvl1
  function _executeRemovalPayload(address payload) internal override {
    GovV3Helpers.executePayload(
      vm,
      payload,
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );
  }
}
