// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3Optimism_RemoveEmissionAdmins_20261029} from './AaveV3Optimism_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3Optimism_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3Optimism_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3Optimism_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3Optimism_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 158829722);
    proposal = new AaveV3Optimism_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Optimism_RemoveEmissionAdmins_20261029',
      AaveV3Optimism.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Optimism.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3Optimism.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3Optimism.EMISSION_MANAGER, pools);
  }

  function test_accruedRewardsStillClaimable() public {
    Claim[] memory claims = new Claim[](1);
    claims[0].user = 0x820E07d8949cB295f80540f1A566edf55b41f4fA;
    claims[0].reward = AaveV3OptimismAssets.OP_UNDERLYING;
    claims[0].assets = new address[](14);
    claims[0].assets[0] = AaveV3OptimismAssets.DAI_A_TOKEN;
    claims[0].assets[1] = AaveV3OptimismAssets.DAI_V_TOKEN;
    claims[0].assets[2] = AaveV3OptimismAssets.USDCe_A_TOKEN;
    claims[0].assets[3] = AaveV3OptimismAssets.USDCe_V_TOKEN;
    claims[0].assets[4] = AaveV3OptimismAssets.WBTC_A_TOKEN;
    claims[0].assets[5] = AaveV3OptimismAssets.WBTC_V_TOKEN;
    claims[0].assets[6] = AaveV3OptimismAssets.WETH_A_TOKEN;
    claims[0].assets[7] = AaveV3OptimismAssets.WETH_V_TOKEN;
    claims[0].assets[8] = AaveV3OptimismAssets.USDT_A_TOKEN;
    claims[0].assets[9] = AaveV3OptimismAssets.USDT_V_TOKEN;
    claims[0].assets[10] = AaveV3OptimismAssets.AAVE_A_TOKEN;
    claims[0].assets[11] = AaveV3OptimismAssets.sUSD_A_TOKEN;
    claims[0].assets[12] = AaveV3OptimismAssets.sUSD_V_TOKEN;
    claims[0].assets[13] = AaveV3OptimismAssets.USDCn_A_TOKEN;
    _checkClaims(address(proposal), AaveV3Optimism.DEFAULT_INCENTIVES_CONTROLLER, claims);
  }
}
