// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {EmissionAdminRemovalChecks} from './EmissionAdminRemovalChecks.sol';
import {AaveV3Ethereum_RemoveEmissionAdmins_20261029} from './AaveV3Ethereum_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Test for AaveV3Ethereum_RemoveEmissionAdmins_20261029
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261029_Multi_RemoveEmissionAdmins/AaveV3Ethereum_RemoveEmissionAdmins_20261029.t.sol -vv
 */
contract AaveV3Ethereum_RemoveEmissionAdmins_20261029_Test is
  ProtocolV3TestBase,
  EmissionAdminRemovalChecks
{
  AaveV3Ethereum_RemoveEmissionAdmins_20261029 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26296844);
    proposal = new AaveV3Ethereum_RemoveEmissionAdmins_20261029();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_RemoveEmissionAdmins_20261029',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function test_emissionAdminsRemoved() public {
    IPool[] memory pools = new IPool[](2);
    pools[0] = AaveV3Ethereum.POOL;
    pools[1] = AaveV3EthereumLido.POOL;
    _checkAdminsRemoved(address(proposal), AaveV3Ethereum.EMISSION_MANAGER, pools);
  }

  function test_accruedRewardsStillClaimable() public {
    Claim[] memory claims = new Claim[](4);
    claims[0].user = 0x15B5c61a18746637516828020563C3FC6066fBFB;
    claims[0].reward = AaveV3EthereumAssets.USDS_A_TOKEN;
    claims[0].assets = new address[](1);
    claims[0].assets[0] = AaveV3EthereumAssets.USDS_A_TOKEN;
    claims[1].user = 0x9600A48ed0f931d0c422D574e3275a90D8b22745;
    claims[1].reward = AaveV3EthereumAssets.wstETH_UNDERLYING;
    claims[1].assets = new address[](1);
    claims[1].assets[0] = AaveV3EthereumLidoAssets.wstETH_A_TOKEN;
    claims[2].user = 0xe6D791d815b74162fDd0B09ce58f0de9A7Bb8ab3;
    claims[2].reward = AaveV3EthereumLidoAssets.WETH_A_TOKEN;
    claims[2].assets = new address[](1);
    claims[2].assets[0] = AaveV3EthereumLidoAssets.WETH_A_TOKEN;
    claims[3].user = 0x9600A48ed0f931d0c422D574e3275a90D8b22745;
    claims[3].reward = AaveV3EthereumLidoAssets.wstETH_A_TOKEN;
    claims[3].assets = new address[](2);
    claims[3].assets[0] = AaveV3EthereumLidoAssets.wstETH_A_TOKEN;
    claims[3].assets[1] = AaveV3EthereumLidoAssets.USDC_A_TOKEN;
    _checkClaims(address(proposal), AaveV3Ethereum.DEFAULT_INCENTIVES_CONTROLLER, claims);
  }
}
