---
title: "Asset Listing - Pendle PT-USDG-25FEB2027 X Layer"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733"
---

## Simple Summary

This AIP lists PT-USDG-25FEB2027, the Pendle Principal Token for USDG maturing on 25 February 2027, on the Aave V3 X Layer instance as a non-borrowable asset, and creates a new PT_USDG_25FEB2027\_\_Stablecoins eMode with PT-USDG-25FEB2027 and PT-USDG-29OCT2026 as collateral.

## Motivation

PT-USDG-29OCT2026 matures on 29 October 2026. Pendle has launched a new USDG PT maturing on 25 February 2027, which lets users continue using fixed-yield USDG positions as collateral on Aave.

Most PT-USDG positions on X Layer borrow stablecoins such as USDT0 against their PT collateral. Having both maturities as collateral in the same eMode during the rollover period lets OKX build a rollover flow that moves users to the new PT in a single transaction while keeping their stablecoin borrowing position. This proposal covers the Aave listing and eMode configuration needed for that flow; OKX develops the rollover integration separately.

Final risk parameters were provided by [LlamaRisk in the discussion thread](https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733/2). Following their recommendation, PT-USDG-25FEB2027 is not added to the existing PT_USDG\_\_Stablecoins eMode, whose 94.66% liquidation threshold is above the level recommended for the longer maturity. A new eMode (id 9) is created instead, with PT-USDG-29OCT2026 also enabled as collateral so users can migrate without closing their positions.

The PT is priced via the deployed linear discount oracle [0xB81f0B2cCAC262288fED924DA750CFc7CC450530](https://www.oklink.com/x-layer/address/0xB81f0B2cCAC262288fED924DA750CFc7CC450530) (`PT Capped USDG USDG/USD linear discount 25FEB2027`), with the rates recommended by LlamaRisk: `initialDiscountRatePerYear` 2.953% and `maxDiscountRatePerYear` 7.910%.

PT-USDG-29OCT2026 keeps its existing parameters and eMode configurations during the migration period; its LTV will be reduced to 0% after maturity in a separate proposal.

## Specification

| Field             | Value                                                                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Asset             | [PT-USDG-25FEB2027](https://www.oklink.com/x-layer/address/0x5eA1F184af5Ced57725213D8267B5c4C834557D4)                          |
| PT token          | [0x5eA1F184af5Ced57725213D8267B5c4C834557D4](https://www.oklink.com/x-layer/address/0x5eA1F184af5Ced57725213D8267B5c4C834557D4) |
| Pendle market     | [0xb70BE417526707C8EBf5f1a79E4876557639B01d](https://www.oklink.com/x-layer/address/0xb70BE417526707C8EBf5f1a79E4876557639B01d) |
| SY token          | [0x1F336F899f77B084133bc14a81170837ED618D1b](https://www.oklink.com/x-layer/address/0x1F336F899f77B084133bc14a81170837ED618D1b) |
| YT token          | [0x5b4308e22aB59AAE80CBf37089C528A125d2a34d](https://www.oklink.com/x-layer/address/0x5b4308e22aB59AAE80CBf37089C528A125d2a34d) |
| Underlying (USDG) | [0x4ae46a509F6b1D9056937BA4500cb143933D2dc8](https://www.oklink.com/x-layer/address/0x4ae46a509F6b1D9056937BA4500cb143933D2dc8) |
| Maturity          | 25 February 2027                                                                                                                |

**New eMode** (per LlamaRisk's final recommendation). The existing PT_USDG\_\_Stablecoins and PT_USDG\_\_USDG eModes are not modified.

| eMode                            | Collateral                           | Borrowable       | LTV    | LT     | Liq. Bonus | Isolated |
| -------------------------------- | ------------------------------------ | ---------------- | ------ | ------ | ---------- | -------- |
| PT_USDG_25FEB2027\_\_Stablecoins | PT-USDG-25FEB2027, PT-USDG-29OCT2026 | USDT0, GHO, USDC | 91.48% | 93.48% | 2.62%      | No       |

The table below illustrates the configured risk parameters for **PT_USDG_25FEB2027**

| Parameter                 |                                                                                                               PT-USDG-25FEB2027 |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------: |
| Isolation Mode            |                                                                                                                              No |
| Borrowable                |                                                                                                                              No |
| Collateral Enabled        |                                                                                                                No (E-Mode only) |
| Supply Cap                |                                                                                                                      35,000,000 |
| Borrow Cap                |                                                                                                                               1 |
| Debt Ceiling              |                                                                                                                             N/A |
| LTV                       |                                                                                                                              0% |
| Liquidation Threshold     |                                                                                                                              0% |
| Liquidation Bonus         |                                                                                                                              0% |
| Liquidation Protocol Fee  |                                                                                                                             10% |
| Reserve Factor            |                                                                                                                             20% |
| Base Variable Borrow Rate |                                                                                                                              0% |
| Variable Rate Slope 1     |                                                                                                                             10% |
| Variable Rate Slope 2     |                                                                                                                            300% |
| Optimal Utilization       |                                                                                                                             45% |
| Flashloanable             |                                                                                                                             Yes |
| Oracle                    | [0xB81f0B2cCAC262288fED924DA750CFc7CC450530](https://www.oklink.com/x-layer/address/0xB81f0B2cCAC262288fED924DA750CFc7CC450530) |

**Linear Discount Rate Oracle**

The price feed applies a linear discount, decreasing to zero at maturity, on top of the Capped USDG/USD feed.

| Parameter                  | Value                                                                                                                           |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| initialDiscountRatePerYear | 2.953%                                                                                                                          |
| maxDiscountRatePerYear     | 7.910%                                                                                                                          |
| Underlying feed            | [Capped USDG/USD](https://www.oklink.com/x-layer/address/0xe00B2732396a1f047d4A00e0165025A9cF400245)                            |
| Oracle                     | [0xB81f0B2cCAC262288fED924DA750CFc7CC450530](https://www.oklink.com/x-layer/address/0xB81f0B2cCAC262288fED924DA750CFc7CC450530) |

## References

- Implementation: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260930_AaveV3XLayer_AssetListingPendlePTUSDG25FEB2027XLayer/AaveV3XLayer_AssetListingPendlePTUSDG25FEB2027XLayer_20260930.sol)
- Tests: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260930_AaveV3XLayer_AssetListingPendlePTUSDG25FEB2027XLayer/AaveV3XLayer_AssetListingPendlePTUSDG25FEB2027XLayer_20260930.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
