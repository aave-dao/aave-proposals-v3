---
title: "Safety Module August 2026 - Allowance Update"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-safety-module-august-2026-allowance-update/25550"
---

## Simple Summary

This AIP tops up the AAVE allowance funding stkAAVE rewards so that it covers everything stakers have already earned plus 90 days of future emissions at the unchanged rate of 150 AAVE per day, and resizes the allowances of the three sunset Safety Module tokens (stkABPT v1, stkGHO, stkAAVEwstETHBPTv2) so that each one matches its residual claimable rewards. These modules have been updated to have no emissions, so the values are absolute. No emission rate, cooldown or slashing parameter is modified.

## Motivation

Every Safety Module stake token pays its AAVE rewards out of the Ecosystem Reserve through an ERC20 allowance. Rewards accrue to stakers continuously, but the allowance is only consumed when a staker claims. Once the allowance is exhausted, every claim reverts until governance tops it up.

At the snapshot (block 25843055, 2026-08-27), the stkAAVE allowance covered only 8.4% of what stakers had already earned. This proposal closes the backlog and moves allowance management to a quarterly cadence: keep 90 days of emissions funded ahead of the backlog. The three sunset modules emit nothing, so their allowances are set to absolute values slightly above their residual claimable rewards; in particular, stkAAVEwstETHBPTv2 holds 7.4 times what it can ever owe, and reducing it releases roughly 14,400 AAVE of standing approval without affecting any claimant.

## Specification

The payload calls `AaveEcosystemReserveController.approve(ECOSYSTEM_RESERVE, AAVE, module, amount)` for each of the four modules, resetting the allowance to 0 before setting the new value (same pattern as AIP 439).

| Module             | Address                                                                                                               | New allowance (AAVE)                                                                   |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| stkAAVE            | [0x4da27a545c0c5B758a6BA100e3a049001de870f5](https://etherscan.io/address/0x4da27a545c0c5B758a6BA100e3a049001de870f5) | currentAllowance + 50,500 + emissionPerSecond x (block.timestamp - snapshot + 90 days) |
| stkABPT v1         | [0xa1116930326D21fB917d5A27F1E9943A9595fb47](https://etherscan.io/address/0xa1116930326D21fB917d5A27F1E9943A9595fb47) | 1,250 (absolute)                                                                       |
| stkGHO             | [0x1a88Df1cFe15Af22B3c4c783D4e6F7F9e0C1885d](https://etherscan.io/address/0x1a88Df1cFe15Af22B3c4c783D4e6F7F9e0C1885d) | 1,200 (absolute)                                                                       |
| stkAAVEwstETHBPTv2 | [0x9eDA81C21C273a82BE9Bbc19B6A6182212068101](https://etherscan.io/address/0x9eDA81C21C273a82BE9Bbc19B6A6182212068101) | 2,500 (absolute)                                                                       |

The new stkAAVE allowance is computed at execution time as the sum of the allowance read at execution, the 50,500 AAVE backlog gap measured at the snapshot (claims between snapshot and execution reduce the backlog and the live allowance by the same amount, so the sum remains exact), the accrual since the snapshot timestamp (1787791523) and 90 days of forward emissions, both read on-chain from the stkAAVE emission configuration.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260901_AaveV3Ethereum_SafetyModuleAllowanceUpdate/AaveV3Ethereum_SafetyModuleAllowanceUpdate_20260901.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260901_AaveV3Ethereum_SafetyModuleAllowanceUpdate/AaveV3Ethereum_SafetyModuleAllowanceUpdate_20260901.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-safety-module-august-2026-allowance-update/25550)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
