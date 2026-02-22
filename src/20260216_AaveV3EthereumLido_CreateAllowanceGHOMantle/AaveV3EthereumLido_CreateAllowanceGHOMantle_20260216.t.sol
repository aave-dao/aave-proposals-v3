// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216} from './AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216.sol';

/**
 * @dev Test for AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260216_AaveV3EthereumLido_CreateAllowanceGHOMantle/AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216.t.sol -vv
 */
contract AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216_Test is ProtocolV3TestBase {
  AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 24467369);
    proposal = new AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216',
      AaveV3EthereumLido.POOL,
      address(proposal)
    );
  }

  function test_allowanceIsSetCorrectly() public {
    uint256 allowanceBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3EthereumLido.COLLECTOR),
      GhoEthereum.GHO_LIQUIDITY_COMMITTEE
    );
    assertEq(allowanceBefore, 0);

    executePayload(vm, address(proposal));

    uint256 allowanceAfter = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3EthereumLido.COLLECTOR),
      GhoEthereum.GHO_LIQUIDITY_COMMITTEE
    );
    assertEq(allowanceAfter, proposal.GHO_ALLOWANCE());
  }

  function test_alcCanTransferFromCollector() public {
    executePayload(vm, address(proposal));

    uint256 ghoAllowance = proposal.GHO_ALLOWANCE();
    uint256 alcBalanceBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).balanceOf(
      GhoEthereum.GHO_LIQUIDITY_COMMITTEE
    );

    vm.prank(GhoEthereum.GHO_LIQUIDITY_COMMITTEE);
    IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).transferFrom(
      address(AaveV3EthereumLido.COLLECTOR),
      GhoEthereum.GHO_LIQUIDITY_COMMITTEE,
      ghoAllowance
    );

    assertGe(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).balanceOf(GhoEthereum.GHO_LIQUIDITY_COMMITTEE),
      alcBalanceBefore + ghoAllowance
    );
  }
}
