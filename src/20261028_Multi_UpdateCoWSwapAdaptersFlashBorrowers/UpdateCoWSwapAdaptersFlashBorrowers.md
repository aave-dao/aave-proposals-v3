---
title: "Update CoW Swap Adapters flashBorrowers"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931"
---

## Simple Summary

This proposal registers the new Aave Swap Adapter factories as approved flash borrowers on the relevant Aave V3 instances, so they can access flash liquidity with zero flash loan fees, and removes the previous factory from the flash borrower list.

The new factories serve the collateral swap, debt swap, repay-with-collateral and leverage adapters, for both Aave V3 and Aave V4 positions.

## Motivation

Aave swap adapters power collateral swaps, debt swaps, repay-with-collateral and leverage flows inside the Aave experience. When a route needs flash liquidity, the flash loan premium is paid inside the execution. It lowers output on collateral and debt swaps, lengthens the payback period of debt swaps, and raises the cost of opening leveraged positions, which weakens the Aave route against external alternatives.

A new generation of the CoW Swap Adapter factories adds the leverage adapter and support for Aave V4 positions. Whitelisting these factories keeps adapter routes free of the flash loan fee on the covered Aave V3 instances. The previous factory, `0xdeCC46a4b09162F5369c5C80383AAa9159bCf192`, whitelisted through [Add CoW Swap Adapters to flashBorrowers](https://github.com/aave-dao/aave-proposals-v3/tree/fbb90bac5436f5e69a03b605fd3465eb7182b133/src/20260506_Multi_AddCoWFactoriesToFlashBorrowers), is superseded and is removed from the list.

## Specification

On each market below, the payload calls `ACLManager.addFlashBorrower` for every new factory and, where listed, `ACLManager.removeFlashBorrower` for the previous factory.

| Market         | AaveV3AdapterV3Factory (added)             | AaveV3AdapterV4Factory (added)             | Previous factory (removed)                 |
| -------------- | ------------------------------------------ | ------------------------------------------ | ------------------------------------------ |
| Ethereum Core  | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | 0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14 | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Ethereum Prime | 0xFdFA036213C375808135744E865767FD90897F0A | -                                          | -                                          |
| Base           | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | 0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14 | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Avalanche      | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | 0x0C6F0D008B5Ee6CdFbb8BF1CFB0148052e96ac14 | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Arbitrum       | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | -                                          | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Gnosis         | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | -                                          | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| BNB Chain      | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | -                                          | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Polygon        | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | -                                          | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Linea          | 0x3171FC716942a40DEDe8dD0B7885dd9f44eca176 | -                                          | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |
| Plasma         | 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83 | -                                          | 0xdeCC46a4b09162F5369c5C80383AAa9159bCf192 |

The `AaveV3AdapterV4Factory` serves Aave V4 positions and sources its flash liquidity from the Aave V3 Pool of the same network.

The new factories are upgradeable proxies. Each factory and its ProxyAdmin are owned by `0xA043B0EaD753d15fe6830d7be57f24432Dd773d1`.

| Factory                                                  | ProxyAdmin                                 |
| -------------------------------------------------------- | ------------------------------------------ |
| AaveV3AdapterV3Factory (all markets except Prime, Linea) | 0x509Df56B5Aceb01674cC5506CA63bf41A4d68E8E |
| AaveV3AdapterV3Factory (Ethereum Prime)                  | 0xd4eDBfecd76c636a1313E057fF3f5cdFD6728649 |
| AaveV3AdapterV3Factory (Linea)                           | 0xF6F22052Df7AE7c899178770075B6b2C3d700667 |
| AaveV3AdapterV4Factory                                   | 0xD7ef5094E88cE0f7f89bB6e5b3E3123aE3DF77Fa |

Orders signed for the previous factory assume a zero flash loan fee. Once it is removed, those orders can no longer be settled and need to be signed again through the new factories.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Ethereum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3EthereumLido_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Polygon_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Arbitrum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Gnosis_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3BNB_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Ethereum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3EthereumLido_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Polygon_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Arbitrum_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Gnosis_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3BNB_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
