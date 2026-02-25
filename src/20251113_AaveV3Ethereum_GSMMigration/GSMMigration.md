---
title: "GSM Migration"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/arfc-launch-gho-on-plasma-set-aci-as-emissions-manager-for-rewards/22994/8"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0xeb3572580924976867073ad9c8012cb9e52093c76dafebd7d3aebf318f2576fb"
---

## Simple Summary

With the launch of what is known as the new Remote GSM, this publication updates the existing Mainnet GSMs to the new version.

## Motivation

To create a unified GSM paradigm for both mainnet and L2s, a newer version of the GSM has been developed. The new GSMs use and restore GHO to a DAO controlled GhoReserve that holds a predefined amount of GHO and the DAO allows entities (such as the GSMs) to draw GHO up to a predefined amount.

## Specification

- Deploy GhoDirectFacilitator to mint GHO for GSMs
- Deploy GhoReserve to hold GHO to be used by GSMs
- Deploy new stataUSDC and stataUSDT GSM4626 from the Gho-Core repository with their respective Oracles
- Grant the Executor the `'LIQUIDATOR_ROLE'` to be able to seize the existing GSMs
- Grant the RiskCouncil the `LIMIT_MANAGER_ROLE` on the GhoReserve and `MINTER_ROLE` on the GhoDirectFacilitator to manage capacity
- Seize the current USDC and USDT GSMs by calling the `seize()` function.
  - This freezes actions on them and transfers the underlying tokens to the collector
- Add the `GhoDirectFacilitator` as a facilitator on the GHO token contract
- Add the `GhoDirectFacilitator` as a controlled facilitator on the`GhoBucketSteward`
- Add new GSMs to the GSMRegistry
- Update the FeeStrategy of the new GSMs:
  - USDC: [`0xF009Ce2453884712707DcED6e5eA16F3e6f515E0`](https://etherscan.io/address/0xF009Ce2453884712707DcED6e5eA16F3e6f515E0)
  - USDT: [`0x06fbDE909B43f01202E3C6207De1D27cC208AcC1`](https://etherscan.io/address/0x06fbDE909B43f01202E3C6207De1D27cC208AcC1)
- Register new swap freeze oracles
- Transfer stataUSDC and stataUSDT from the Collector to the proposal contract
- With the obtained stataUSDC and stataUSDT, exchange for GHO on the new respective GSMs
- Use the obtained GHO to `burnAfterSeize()` on the current USDC and USDT GSMs. If there are any discrepancies in the amount of GHO, use GHO from the treasury to bring the minted GHO by the GSMs to zero
- Remove existing GSMs as facilitators of the GHO token
- Remove existing GSMs from the GSMRegistry
- Remove existing USDC and USDT GSMs from being a controlled facilitator on the GhoBucketSteward
- Revoke roles assigned to EXECUTOR and old GSMs

The below details the configuration of the stataUSDC GSM.

| Parameter                |  Value  |
| ------------------------ | :-----: |
| Draw Limit (GHO)         | 110.00M |
| Exposure Capacity (USDC) | 87.00M  |
| Price Strategy           |   1:1   |
| Freeze Lower Bound       | $0.990  |
| Freeze Upper Bound       | $1.010  |
| Unfreeze Lower Bound     | $0.995  |
| Unfreeze Upper Bound     | $1.005  |
| Mint GHO Fee             |  0.00%  |
| Burn GHO Fee             |  0.08%  |

The below details the configuration of the stataUSDT GSM.

| Parameter                | Value  |
| ------------------------ | :----: |
| Draw Limit (GHO)         | 70.00M |
| Exposure Capacity (USDT) | 55.00M |
| Price Strategy           |  1:1   |
| Freeze Lower Bound       | $0.990 |
| Freeze Upper Bound       | $1.010 |
| Unfreeze Lower Bound     | $0.995 |
| Unfreeze Upper Bound     | $1.005 |
| Mint GHO Fee             | 0.00%  |
| Burn GHO Fee             | 0.10%  |

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/549ea8de0f75f94af1d5961ad6c9d98577c225f9/src/20251113_AaveV3Ethereum_GSMMigration/AaveV3Ethereum_GSMMigration_20251113.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/549ea8de0f75f94af1d5961ad6c9d98577c225f9/src/20251113_AaveV3Ethereum_GSMMigration/AaveV3Ethereum_GSMMigration_20251113.t.sol)
- [Snapshot](https://snapshot.box/#/s:aavedao.eth/proposal/0xeb3572580924976867073ad9c8012cb9e52093c76dafebd7d3aebf318f2576fb)
- [Discussion](https://governance.aave.com/t/arfc-launch-gho-on-plasma-set-aci-as-emissions-manager-for-rewards/22994/8)
- [Audit](https://github.com/aave-dao/aave-proposals-v3/blob/549ea8de0f75f94af1d5961ad6c9d98577c225f9/src/20250930_Multi_LaunchGHOOnPlasmaSetACIAsEmissionsManagerForRewards/TokenLogic-security-review_2025-05-05.pdf)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
