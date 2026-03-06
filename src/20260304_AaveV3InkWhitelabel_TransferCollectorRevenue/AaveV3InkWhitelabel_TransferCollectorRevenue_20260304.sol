// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3InkWhitelabel} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

/**
 * @title Transfer Collector Revenue
 * @author ACI
 */
contract AaveV3InkWhitelabel_TransferCollectorRevenue_20260304 is IProposalGenericExecutor {
  address public constant INK_TYDRO_TEAM_SAFE = 0x82d7d57C22F56d5f7dE062CbcA9783001f885302;

  function execute() external {
    address[] memory reserves = AaveV3InkWhitelabel.POOL.getReservesList();

    for (uint256 i = 0; i < reserves.length; i++) {
      address aToken = AaveV3InkWhitelabel.POOL.getReserveAToken(reserves[i]);
      uint256 balance = IERC20(aToken).balanceOf(address(AaveV3InkWhitelabel.COLLECTOR));
      if (balance > 0) {
        AaveV3InkWhitelabel.COLLECTOR.transfer(IERC20(aToken), INK_TYDRO_TEAM_SAFE, balance);
      }
    }
  }
}
