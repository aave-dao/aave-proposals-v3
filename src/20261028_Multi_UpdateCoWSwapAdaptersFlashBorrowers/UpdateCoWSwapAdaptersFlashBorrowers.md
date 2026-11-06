---
title: "Update CoW Swap Adapters flashBorrowers"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931"
---

## Simple Summary

This proposal seeks to register the new Aave Swap Adapter factories as approved flash borrowers across relevant Aave V3 instances, enabling them to access flash liquidity with zero flash loan fees. The new factories serve the collateral swap, debt swap, repay with collateral, and leverage adapters. The previous CoW Swap Adapter contract would be removed from the approved flash borrowers on the same instances.

This change improves execution quality for users interacting through Aave's swap and leverage flows by removing an internal protocol fee that currently adds avoidable cost to adapter-based routing.

## Motivation

Aave swap adapters support collateral swaps, debt swaps, repayments with collateral, and leverage inside the Aave experience. When a route requires flash liquidity, the flash loan premium is embedded directly in execution. That reduces output on collateral and debt swaps, increases the cost of opening leveraged positions, and prolongs the payback period of debt swaps, which weakens the Aave route against external alternatives.

Whitelisting the new CoW Swap Adapter factories removes that cost across the covered Aave V3 instances, and extends it to the new leverage adapter. CoW Swap Adapter routes that rely on flash liquidity will execute without a flash loan fee. Users will experience improved collateral swap, debt swap, and leverage pricing on Aave V3. With better pricing, the Aave interface should retain more of this flow within the Aave experience. Under the [Aave Will Win Framework](https://governance.aave.com/t/routing-swap-and-horizon-fees-to-dao-collector-addresses/24462), the DAO is positioned to capture all revenue from that activity.

## Specification

The Aave DAO would authorize the registration of the new Aave swap adapter factory contracts as approved flash borrowers through the `ACLManager.addFlashBorrower` function on the applicable Aave V3 deployments, and the removal of the previous CoW Swap Adapter contract through the `ACLManager.removeFlashBorrower` function on the same deployments.

Once registered, these factories would be exempt from flash loan fees when using flash liquidity through the approved path.

The proposal payload would:

- identify the swap adapter factory contract addresses to be registered
- call `addFlashBorrower` for each factory on the relevant markets
- call `removeFlashBorrower` for the previous adapter contract on the relevant markets

**CoW Swap Adapter Factories**

Two factory versions are in scope, `AaveV3AdapterV3Factory` and `AaveV3AdapterV4Factory`. Each serves its own set of `CollateralSwap`, `DebtSwap`, `RepayWithCollateral`, and `Leverage` adapters.

**Aave V3 instances included in scope**

The payload will register the following factories as approved flash borrowers on the following Aave V3 instances:

| Market         | `AaveV3AdapterV3Factory`                                                                                                 | `AaveV3AdapterV4Factory`                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| Ethereum Core  | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://etherscan.io/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)    | [0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14](https://etherscan.io/address/0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14) |
| Ethereum Prime | [0xFdFA036213C375808135744E865767FD90897F0A](https://etherscan.io/address/0xFdFA036213C375808135744E865767FD90897F0A)    | -                                                                                                                     |
| Base           | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://basescan.org/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)    | [0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14](https://basescan.org/address/0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14) |
| Arbitrum       | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://arbiscan.io/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)     | -                                                                                                                     |
| Gnosis         | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://gnosisscan.io/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)   | -                                                                                                                     |
| Avalanche      | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://snowtrace.io/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)    | [0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14](https://snowtrace.io/address/0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14) |
| BNB Chain      | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://bscscan.com/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)     | -                                                                                                                     |
| Polygon        | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://polygonscan.com/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83) | -                                                                                                                     |
| Linea          | [0x3171FC716942a40DEDe8dD0B7885dd9f44eca176](https://lineascan.build/address/0x3171FC716942a40DEDe8dD0B7885dd9f44eca176) | -                                                                                                                     |
| Plasma         | [0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83](https://plasmascan.to/address/0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83)   | -                                                                                                                     |

**Previous CoW Swap Adapter to be removed**

The payload will remove the following contract from the approved flash borrowers on the following Aave V3 instances:

| Market        | Previous adapter                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Ethereum Core | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://etherscan.io/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)    |
| Base          | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://basescan.org/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)    |
| Arbitrum      | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://arbiscan.io/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)     |
| Gnosis        | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://gnosisscan.io/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)   |
| Avalanche     | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://snowtrace.io/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)    |
| BNB Chain     | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://bscscan.com/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)     |
| Polygon       | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://polygonscan.com/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192) |
| Linea         | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://lineascan.build/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192) |
| Plasma        | [0xdeCC46a4b09162F5369c5C80383AAa9159bCf192](https://plasmascan.to/address/0xdeCC46a4b09162F5369c5C80383AAa9159bCf192)   |

**Payload actions**

For each Aave V3 instance listed in the factory table, the governance payload will execute `ACLManager.addFlashBorrower` once for every factory address listed in its row. For each Aave V3 instance listed in the previous adapter table, it will execute `ACLManager.removeFlashBorrower` for the previous adapter address.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Ethereum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3EthereumLido_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Polygon_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Arbitrum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Gnosis_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3BNB_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Ethereum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3EthereumLido_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Polygon_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Arbitrum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Gnosis_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3BNB_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/ae80c398e1c56da20b3af12677ebf673de0917f6/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
