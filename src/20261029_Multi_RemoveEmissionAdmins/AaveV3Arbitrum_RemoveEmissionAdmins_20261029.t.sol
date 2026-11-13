// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3Arbitrum_RemoveEmissionAdmins_20261029} from './AaveV3Arbitrum_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3Arbitrum_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3Arbitrum_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3Arbitrum_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3Arbitrum_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 519290896);
    proposal = new AaveV3Arbitrum_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_RemoveEmissionAdmins_20261029',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3Arbitrum.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3Arbitrum.EMISSION_MANAGER, pools);
  }

  function test_accruedRewardsStillClaimable() public {
    Claim[] memory claims = new Claim[](1);
    claims[0].user = 0x50288c30c37FA1Ec6167a31E575EA8632645dE20;
    claims[0].reward = AaveV3ArbitrumAssets.ARB_UNDERLYING;
    claims[0].assets = new address[](3);
    claims[0].assets[0] = AaveV3ArbitrumAssets.USDCn_A_TOKEN;
    claims[0].assets[1] = AaveV3ArbitrumAssets.GHO_A_TOKEN;
    claims[0].assets[2] = AaveV3ArbitrumAssets.GHO_V_TOKEN;
    _checkClaims(address(proposal), AaveV3Arbitrum.DEFAULT_INCENTIVES_CONTROLLER, claims);
  }
}
