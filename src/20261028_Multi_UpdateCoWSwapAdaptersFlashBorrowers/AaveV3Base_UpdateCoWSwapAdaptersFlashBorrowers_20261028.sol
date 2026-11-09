// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Update CoW Swap Adapters flashBorrowers
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931
 */
contract AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028 is IProposalGenericExecutor {
  // https://basescan.org/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83
  address public constant COW_V3_ADAPTER_FACTORY = 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83;

  // https://basescan.org/address/0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14
  address public constant COW_V4_ADAPTER_FACTORY = 0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14;

  // https://basescan.org/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192
  address public constant DEPRECATED_COW_ADAPTER_FACTORY =
    0xdeCC46a4b09162F5369c5C80383AAa9159bCf192;

  function execute() external {
    AaveV3Base.ACL_MANAGER.addFlashBorrower(COW_V3_ADAPTER_FACTORY);
    AaveV3Base.ACL_MANAGER.addFlashBorrower(COW_V4_ADAPTER_FACTORY);
    AaveV3Base.ACL_MANAGER.removeFlashBorrower(DEPRECATED_COW_ADAPTER_FACTORY);
  }
}
