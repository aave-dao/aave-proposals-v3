---
title: "Onboard USDC to Aave V3 X Layer"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-asset-listing-usdc-x-layer/25467"
---

## Simple Summary

This AIP lists native USDC on the Aave V3 X Layer instance as a borrowable asset and collateral, and enables USDC as a borrowable asset within the existing xBTC, xETH, xSOL, wOKB and PT-USDG stablecoin eModes.

## Motivation

On 6 August 2026, Circle launched native USDC and the Cross-Chain Transfer Protocol (CCTP) on X Layer. Native USDC is issued by Circle, fully reserved, and redeemable 1:1 for US dollars. Onboarding it to Aave V3 X Layer expands the range of high-quality stablecoins available to users alongside USDT0, USDG and GHO, and increases the stablecoin borrowing liquidity available to the existing xBTC, xETH, xSOL, wOKB and PT-USDG eMode categories. The risk parameters below follow the revised LlamaRisk recommendation in the discussion thread.

## Specification

The table below illustrates the configured risk parameters for **USDC** ([0xB6CEceAB302E2E4948951eE7843FC24E92933061](https://www.oklink.com/x-layer/address/0xB6CEceAB302E2E4948951eE7843FC24E92933061)).

| Parameter                 |                                                                                                                            USDC |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------: |
| Isolation Mode            |                                                                                                                              No |
| Borrowable                |                                                                                                                             Yes |
| Collateral Enabled        |                                                                                                                             Yes |
| Supply Cap                |                                                                                                                      35,000,000 |
| Borrow Cap                |                                                                                                                      32,000,000 |
| Debt Ceiling              |                                                                                                                             N/A |
| LTV                       |                                                                                                                             75% |
| Liquidation Threshold     |                                                                                                                             78% |
| Liquidation Bonus         |                                                                                                                            7.5% |
| Liquidation Protocol Fee  |                                                                                                                             10% |
| Reserve Factor            |                                                                                                                             10% |
| Base Variable Borrow Rate |                                                                                                                              0% |
| Variable Rate Slope 1     |                                                                                                                              4% |
| Variable Rate Slope 2     |                                                                                                                             40% |
| Optimal Utilization       |                                                                                                                             90% |
| Flashloanable             |                                                                                                                             Yes |
| Oracle                    | [0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC](https://www.oklink.com/x-layer/address/0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC) |

**Price Cap Adapter**

USDC is priced through a `PriceCapAdapterStable` (`Capped USDC / USD`), following the same configuration as the existing USDT0 and USDG stable oracles on X Layer.

| Parameter       | Value                                                                                                                                                |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Adapter         | [0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC](https://www.oklink.com/x-layer/address/0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC)                      |
| Underlying feed | [0xB8a08c178D96C315FbFB5661ABD208477391BC40](https://www.oklink.com/x-layer/address/0xB8a08c178D96C315FbFB5661ABD208477391BC40) (Chainlink USDC/USD) |
| Price cap       | 1.04 USD                                                                                                                                             |

**eMode updates:** USDC is enabled as a borrowable asset (not collateral) within the existing stablecoin eMode categories, alongside USDT0, USDG and GHO.

| eMode                      | Collateral        | USDC Borrowable |
| -------------------------- | ----------------- | --------------- |
| xBTC Stablecoins (1)       | xBTC              | Yes             |
| xETH Stablecoins (2)       | xETH              | Yes             |
| xSOL Stablecoins (3)       | xSOL              | Yes             |
| wOKB Stablecoins (4)       | wOKB              | Yes             |
| PT_USDG\_\_Stablecoins (7) | PT-USDG-29OCT2026 | Yes             |

## References

- Implementation: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260818_AaveV3XLayer_AaveV3XLayerUSDCListing/AaveV3XLayer_AaveV3XLayerUSDCListing_20260818.sol)
- Tests: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260818_AaveV3XLayer_AaveV3XLayerUSDCListing/AaveV3XLayer_AaveV3XLayerUSDCListing_20260818.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-asset-listing-usdc-x-layer/25467)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
