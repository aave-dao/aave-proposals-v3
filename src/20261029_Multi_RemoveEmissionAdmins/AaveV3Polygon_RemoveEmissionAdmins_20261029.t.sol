// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3Polygon_RemoveEmissionAdmins_20261029} from './AaveV3Polygon_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3Polygon_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3Polygon_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3Polygon_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3Polygon_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 96368562);
    proposal = new AaveV3Polygon_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Polygon_RemoveEmissionAdmins_20261029',
      AaveV3Polygon.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Polygon.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3Polygon.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3Polygon.EMISSION_MANAGER, pools);
  }

  function test_accruedRewardsStillClaimable() public {
    Claim[] memory claims = new Claim[](2);
    claims[0].user = 0x329c54289Ff5D6B7b7daE13592C6B1EDA1543eD4;
    claims[0].reward = 0x1d734A02eF1e1f5886e66b0673b71Af5B53ffA94; // SD
    claims[0].assets = new address[](1);
    claims[0].assets[0] = AaveV3PolygonAssets.MaticX_A_TOKEN;
    claims[1].user = 0x3707Ad3Fb74eD4C87A795894a3DE890C2bE5a9FC;
    claims[1].reward = 0xC3C7d422809852031b44ab29EEC9F1EfF2A58756; // LDO
    claims[1].assets = new address[](1);
    claims[1].assets[0] = AaveV3PolygonAssets.stMATIC_A_TOKEN;
    _checkClaims(address(proposal), AaveV3Polygon.DEFAULT_INCENTIVES_CONTROLLER, claims);
  }
}
