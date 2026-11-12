// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumLido} from 'aave-address-book/AaveV3EthereumLido.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Update CoW Swap Adapters flashBorrowers
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931
 */
contract AaveV3EthereumLido_UpdateCoWSwapAdaptersFlashBorrowers_20261028 is
  IProposalGenericExecutor
{
  // https://etherscan.io/address/0xFdFA036213C375808135744E865767FD90897F0A
  address public constant COW_V3_ADAPTER_FACTORY = 0xFdFA036213C375808135744E865767FD90897F0A;

  function execute() external {
    AaveV3EthereumLido.ACL_MANAGER.addFlashBorrower(COW_V3_ADAPTER_FACTORY);
  }
}
