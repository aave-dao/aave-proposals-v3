// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3Avalanche_RemoveEmissionAdmins_20261029} from './AaveV3Avalanche_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3Avalanche_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3Avalanche_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3Avalanche_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3Avalanche_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 98844668);
    proposal = new AaveV3Avalanche_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Avalanche_RemoveEmissionAdmins_20261029',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Avalanche.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](1);
    pools[0] = AaveV3Avalanche.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3Avalanche.EMISSION_MANAGER, pools);
  }

  function test_accruedRewardsStillClaimable() public {
    Claim[] memory claims = new Claim[](2);
    claims[0].user = 0xEc7C2bC82795bbD3641E5dAFc37196a51292D438;
    claims[0].reward = AaveV3AvalancheAssets.WAVAX_UNDERLYING;
    claims[0].assets = new address[](19);
    claims[0].assets[0] = AaveV3AvalancheAssets.DAIe_A_TOKEN;
    claims[0].assets[1] = AaveV3AvalancheAssets.DAIe_V_TOKEN;
    claims[0].assets[2] = AaveV3AvalancheAssets.LINKe_A_TOKEN;
    claims[0].assets[3] = AaveV3AvalancheAssets.LINKe_V_TOKEN;
    claims[0].assets[4] = AaveV3AvalancheAssets.USDC_A_TOKEN;
    claims[0].assets[5] = AaveV3AvalancheAssets.USDC_V_TOKEN;
    claims[0].assets[6] = AaveV3AvalancheAssets.WBTCe_A_TOKEN;
    claims[0].assets[7] = AaveV3AvalancheAssets.WBTCe_V_TOKEN;
    claims[0].assets[8] = AaveV3AvalancheAssets.WETHe_A_TOKEN;
    claims[0].assets[9] = AaveV3AvalancheAssets.WETHe_V_TOKEN;
    claims[0].assets[10] = AaveV3AvalancheAssets.USDt_A_TOKEN;
    claims[0].assets[11] = AaveV3AvalancheAssets.USDt_V_TOKEN;
    claims[0].assets[12] = AaveV3AvalancheAssets.AAVEe_A_TOKEN;
    claims[0].assets[13] = AaveV3AvalancheAssets.AAVEe_V_TOKEN;
    claims[0].assets[14] = AaveV3AvalancheAssets.WAVAX_A_TOKEN;
    claims[0].assets[15] = AaveV3AvalancheAssets.WAVAX_V_TOKEN;
    claims[0].assets[16] = AaveV3AvalancheAssets.sAVAX_A_TOKEN;
    claims[0].assets[17] = AaveV3AvalancheAssets.BTCb_A_TOKEN;
    claims[0].assets[18] = AaveV3AvalancheAssets.BTCb_V_TOKEN;
    claims[1].user = 0x7bcB0CC7ee1158827a1e29254E83Bd55799855C5;
    claims[1].reward = AaveV3AvalancheAssets.sAVAX_UNDERLYING;
    claims[1].assets = new address[](6);
    claims[1].assets[0] = AaveV3AvalancheAssets.USDC_A_TOKEN;
    claims[1].assets[1] = AaveV3AvalancheAssets.USDC_V_TOKEN;
    claims[1].assets[2] = AaveV3AvalancheAssets.USDt_A_TOKEN;
    claims[1].assets[3] = AaveV3AvalancheAssets.WAVAX_V_TOKEN;
    claims[1].assets[4] = AaveV3AvalancheAssets.sAVAX_A_TOKEN;
    claims[1].assets[5] = AaveV3AvalancheAssets.BTCb_A_TOKEN;
    _checkClaims(address(proposal), AaveV3Avalanche.DEFAULT_INCENTIVES_CONTROLLER, claims);
  }
}
