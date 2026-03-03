// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
/**
 * @title ACI Is Leaving Aave
 * @author Aavechan Initiative @aci
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-aci-stream-settlement/24206
 */
contract AaveV3Ethereum_ACIIsLeavingAave_20260302 is IProposalGenericExecutor {
  address public constant ACI = 0x55Ac902cb75cC15288D473ed8E3E185a75b3f330; //treasury.aci.eth
  uint256 public constant PREVIOUS_STREAM = 100070;
  uint256 public constant BULK_AMOUNT = 986_301 ether; // 3M * 120 / 365 rounded down

  function execute() external {
    // cancel stream (and withdraw unclaimed balance)
    AaveV3EthereumLido.COLLECTOR.cancelStream(PREVIOUS_STREAM);
    // bulk transfer
    AaveV3EthereumLido.COLLECTOR.transfer(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN),
      ACI,
      BULK_AMOUNT
    );
  }
}
