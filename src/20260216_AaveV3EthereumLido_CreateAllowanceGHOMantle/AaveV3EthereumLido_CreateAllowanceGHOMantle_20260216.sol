// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

/**
 * @title Create Allowance GHO Mantle
 * @author @TokenLogic
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x2f9378770f1838f0ea8d483239af1530c9fbea98d648e0b11e4647dcb722d119
 * - Discussion: https://governance.aave.com/t/arfc-deploy-aave-v3-on-mantle/20542#p-51955-budget-15
 */
contract AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216 is IProposalGenericExecutor {
  uint256 public constant GHO_ALLOWANCE = 1_500_000 ether;

  function execute() external {
    AaveV3EthereumLido.COLLECTOR.approve(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN),
      GhoEthereum.GHO_LIQUIDITY_COMMITTEE,
      GHO_ALLOWANCE
    );
  }
}
