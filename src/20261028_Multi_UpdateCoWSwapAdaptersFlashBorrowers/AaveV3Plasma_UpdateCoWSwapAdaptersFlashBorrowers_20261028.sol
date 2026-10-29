// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma} from 'aave-address-book/AaveV3Plasma.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Update CoW Swap Adapters flashBorrowers
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931
 */
contract AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028 is IProposalGenericExecutor {
  // https://plasmascan.to/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83
  address public constant COW_V3_ADAPTER_FACTORY = 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83;

  // https://plasmascan.to/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192
  address public constant DEPRECATED_COW_ADAPTER_FACTORY =
    0xdeCC46a4b09162F5369c5C80383AAa9159bCf192;

  function execute() external {
    AaveV3Plasma.ACL_MANAGER.addFlashBorrower(COW_V3_ADAPTER_FACTORY);
    AaveV3Plasma.ACL_MANAGER.removeFlashBorrower(DEPRECATED_COW_ADAPTER_FACTORY);
  }
}
