---
title: "Ethena E-Mode Consolidation on Aave V3"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304"
---

## Simple Summary

This AIP sets a common set of reference e-modes for Ethena collateral on Aave V3 Core, Plasma, Mantle, Monad and Avalanche: 91% LTV and 93% LT for USDe against stablecoins, and 90% LTV and 92% LT for sUSDe against stablecoins.

Legacy collateral on Core and Plasma is retired through per-asset LTV-zero flags while keeping existing LTs, except Plasma #21, whose LT returns from 93.1% to 93%, and Plasma #23, which is aligned to the sUSDe reference parameters. The AIP also retires the matured PTs on Monad and in X Layer #7 and #8, and removes USDe borrowing from Avalanche #4.

## Motivation

Several legacy Ethena PT e-modes continue to accept USDe or sUSDe after their PTs have matured. Their parameters and borrowable assets differ from the reference e-modes, so users with similar collateral can face different parameters. Across Core #10, #29 and #34 and Plasma #13 and #21, legacy USDe e-modes account for approximately $709M of collateral and $637M of debt. A common reference configuration reduces the number of categories used for these positions.

Per-asset LTV-zero flags stop legacy collateral from supporting new borrowing while each category keeps its LT, so existing health factors are unchanged, except for the Plasma #21 and #23 changes below. A position borrowing USDC, USDT or USDT0 that wants to keep borrowing moves to the reference e-mode in a single transaction; USDe and USDtb debt is not permitted there.

Plasma #23 moves from 90.1% / 92.1% to 90% / 92%, in line with the sUSDe reference mode Plasma #2. This lowers health factors by about 0.001 and liquidates no positions at the snapshot. The LT of legacy Plasma #21 returns from 93.1% to 93%, in line with the reference mode Plasma #1. The lowest resulting health factor at the snapshot is 1.008, so no position is liquidated.

The retirement list includes Core and Plasma categories that permit USDe borrowing against USDe, sUSDe or their matured PTs, with LTs of up to 96%. USDe is also removed from the borrowable assets of Avalanche #4, where about $1.4k of USDe is borrowed in total.

## Specification

### Part A: Reference E-Mode Parameters

Liquidation bonuses, collateral membership, borrowable assets, and isolation flags remain unchanged, except that USDe is removed from Avalanche #4's borrowable assets.

| Market    | E-mode              | Current LTV / LT | Proposed LTV / LT | Liquidation Bonus | Borrowable Assets              |
| --------- | ------------------- | ---------------- | ----------------- | ----------------- | ------------------------------ |
| Core      | 11: USDe Stablecoin | 90% / 93%        | 91% / 93%         | 2%                | USDC, USDT                     |
| Plasma    | 1: USDe Stablecoins | 90% / 93%        | 91% / 93%         | 2%                | USDT0                          |
| Mantle    | 2: USDe Stablecoins | 90% / 93%        | 91% / 93%         | 2%                | USDT0, USDC, GHO               |
| Avalanche | 3: USDe/Stablecoin  | 89% / 92%        | 91% / 93%         | 2%                | USDC, USDt, GHO                |
| Avalanche | 4: sUSDe/Stablecoin | 89% / 91%        | 90% / 92%         | 4%                | USDC, USDt, GHO (USDe removed) |
| Plasma    | 21: legacy USDe     | 91.1% / 93.1%    | 91.1% / 93%       | unchanged         | unchanged                      |
| Plasma    | 23: legacy sUSDe    | 90.1% / 92.1%    | 90% / 92%         | unchanged         | unchanged                      |

Core #2, Plasma #2, Mantle #1 and Monad #2 already provide 90% LTV and 92% LT for their sUSDe reference configurations and require no parameter changes.

### New Monad USDe Reference E-Mode

| Parameter             | Configuration          |
| --------------------- | ---------------------- |
| Label                 | USDe Stablecoins       |
| Collateral            | USDe                   |
| LTV                   | 91%                    |
| Liquidation Threshold | 93%                    |
| Liquidation Bonus     | 2%                     |
| Borrowable Assets     | USDT0, USDC, AUSD, GHO |
| Isolated              | No                     |

### Part B: Legacy Collateral Retirement

Each entry sets the asset's per-asset LTV-zero flag in the listed categories. Membership and isolation are unchanged, and category parameters are unchanged except for Plasma #21 and #23 (Part A).

| Market | Asset               | E-Mode Categories                                 |
| ------ | ------------------- | ------------------------------------------------- |
| Core   | USDe                | 10, 12, 19, 20, 29, 30, 34, 35                    |
| Core   | sUSDe               | 8, 17, 24, 31, 32, 36, 37, 38, 39, 44, 45, 47, 48 |
| Core   | PT-srUSDe-22OCT2026 | 47, 48                                            |
| Plasma | USDe                | 13, 14, 21, 22                                    |
| Plasma | sUSDe               | 15, 16, 23, 24, 25, 26                            |
| Plasma | PT-sUSDe-22OCT2026  | 25, 26                                            |

### Part C: Other Legacy Collateral

| Market  | Asset             | E-Mode Categories | Treatment                                                    |
| ------- | ----------------- | ----------------- | ------------------------------------------------------------ |
| Monad   | PT-AUSD-8OCT2026  | 5                 | LTV-zero flag set; expired at 00:00 UTC on October 8, 2026.  |
| X Layer | PT-USDG-29OCT2026 | 7, 8              | LTV-zero flag set; expired at 00:00 UTC on October 29, 2026. |

X Layer #9 is left unchanged so October PT positions can roll into the February PT. Together, Parts B and C set 38 per-asset LTV-zero flags.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111.t.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
