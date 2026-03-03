// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_ACIIsLeavingAave_20260302} from './AaveV3Ethereum_ACIIsLeavingAave_20260302.sol';

/**
 * @dev Test for AaveV3Ethereum_ACIIsLeavingAave_20260302
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260302_AaveV3Ethereum_ACIIsLeavingAave/AaveV3Ethereum_ACIIsLeavingAave_20260302.t.sol -vv
 */
contract AaveV3Ethereum_ACIIsLeavingAave_20260302_Test is ProtocolV3TestBase {
  AaveV3Ethereum_ACIIsLeavingAave_20260302 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 24572457);
    proposal = new AaveV3Ethereum_ACIIsLeavingAave_20260302();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_ACIIsLeavingAave_20260302',
      AaveV3EthereumLido.POOL,
      address(proposal)
    );
  }

  function test_streamCanceled() public {
    uint256 streamID = proposal.PREVIOUS_STREAM();
    AaveV3EthereumLido.COLLECTOR.getStream(streamID);
    executePayload(vm, address(proposal));
    vm.expectRevert();
    AaveV3EthereumLido.COLLECTOR.getStream(streamID);
  }

  function test_transfer() public {
    uint256 ghoBalancesBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).balanceOf(
      proposal.ACI()
    );
    executePayload(vm, address(proposal));
    uint256 ghoBalancesAfter = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).balanceOf(
      proposal.ACI()
    );
    assertGe(ghoBalancesAfter - ghoBalancesBefore, proposal.BULK_AMOUNT());
  }
}
