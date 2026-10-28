// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Linea} from 'aave-address-book/AaveV3Linea.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Update CoW Swap Adapters flashBorrowers
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931
 */
contract AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028 is IProposalGenericExecutor {
  // https://lineascan.build/address/0x3171FC716942a40DEDe8dD0B7885dd9f44eca176
  address public constant COW_V3_ADAPTER_FACTORY = 0x3171FC716942a40DEDe8dD0B7885dd9f44eca176;

  // https://lineascan.build/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192
  address public constant DEPRECATED_COW_ADAPTER_FACTORY =
    0xdeCC46a4b09162F5369c5C80383AAa9159bCf192;

  function execute() external {
    AaveV3Linea.ACL_MANAGER.addFlashBorrower(COW_V3_ADAPTER_FACTORY);
    AaveV3Linea.ACL_MANAGER.removeFlashBorrower(DEPRECATED_COW_ADAPTER_FACTORY);
  }
}
