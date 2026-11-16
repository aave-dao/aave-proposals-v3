---
title: "Asset Listing - Pendle PT-sUSDe-28JAN2027 Plasma"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902"
---

## Simple Summary

This proposal lists PT-sUSDe-28JAN2027 on Aave V3 Plasma through the Direct-to-AIP process. It provides a rollover destination for users of PT-sUSDe-22OCT2026, which matured on 22 October 2026. The January PT launches with the parameters recommended by LlamaRisk, with borrowing disabled and collateral use limited to a dedicated stablecoin eMode.

## Motivation

PT-sUSDe-22OCT2026 matured on 22 October 2026. Its supply cap is now 1, and 69,406 PT remain supplied to Aave V3 Plasma, down from a peak of about 153.6M on 4 August 2026. This listing allows holders to roll into the next maturity and continue using PT-sUSDe as collateral on the instance.

The rollover follows the established sequence of sUSDe PT listings on Plasma, covering the January, April, June and October 2026 maturities.

As of 13 November 2026, the January PT has 76 days remaining until maturity. The shorter remaining term reduces the PT's price sensitivity to changes in implied yield.

## Specification

List PT-sUSDe-28JAN2027 on Aave V3 Plasma with the following asset details:

| Field              | Value                                                                                                                  |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| Asset              | PT-sUSDe-28JAN2027                                                                                                     |
| Network            | Plasma                                                                                                                 |
| PT token           | [0x257561233419039BeC3a28be717d14B4f490883D](https://plasmascan.to/address/0x257561233419039BeC3a28be717d14B4f490883D) |
| Pendle market      | [0xdb96b529d19ff4a7d711e6e082172c77cfe88ed8](https://plasmascan.to/address/0xdb96b529d19ff4a7d711e6e082172c77cfe88ed8) |
| SY token           | [0x9838B0450e311962Aed969BA7d0fe0BB9D8620eB](https://plasmascan.to/address/0x9838B0450e311962Aed969BA7d0fe0BB9D8620eB) |
| YT token           | [0x40Eb4A62ACf1Fa0676732B62C4E55548Ee7B819F](https://plasmascan.to/address/0x40Eb4A62ACf1Fa0676732B62C4E55548Ee7B819F) |
| Underlying (sUSDe) | [0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2](https://plasmascan.to/address/0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2) |
| Decimals           | 18                                                                                                                     |
| Maturity           | 28 January 2027                                                                                                        |

### eMode

A dedicated eMode allows users to supply PT-sUSDe-28JAN2027 or sUSDe as collateral and borrow USDT0, USDe or GHO. PT-sUSDe-22OCT2026 is added with the same parameters as PT-sUSDe-28JAN2027, so existing positions can roll over without unwinding.

| eMode ID | eMode                                   | Collateral                                    | Borrowable       | LTV | LT  | Liq. Bonus | Isolated |
| -------- | --------------------------------------- | --------------------------------------------- | ---------------- | --- | --- | ---------- | -------- |
| 27       | sUSDe_PT_sUSDe_28JAN2027\_\_Stablecoins | PT-sUSDe-28JAN2027, sUSDe, PT-sUSDe-22OCT2026 | USDT0, USDe, GHO | 90% | 92% | 4.95%      | No       |

### Reserve Parameters

| Parameter                 | PT-sUSDe-28JAN2027                                                                                                             |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Isolation Mode            | No                                                                                                                             |
| Borrowable                | No                                                                                                                             |
| Collateral Enabled        | No (eMode only)                                                                                                                |
| Supply Cap                | 25,000,000                                                                                                                     |
| Borrow Cap                | 1                                                                                                                              |
| Debt Ceiling              | N/A                                                                                                                            |
| LTV                       | 0%                                                                                                                             |
| Liquidation Threshold     | 0%                                                                                                                             |
| Liquidation Bonus         | 0%                                                                                                                             |
| Liquidation Protocol Fee  | 10%                                                                                                                            |
| Reserve Factor            | 45%                                                                                                                            |
| Base Variable Borrow Rate | 0%                                                                                                                             |
| Variable Rate Slope 1     | 10%                                                                                                                            |
| Variable Rate Slope 2     | 300%                                                                                                                           |
| Optimal Utilization       | 45%                                                                                                                            |
| Flashloanable             | No                                                                                                                             |
| Oracle                    | [PT Capped sUSDe USDT/USD linear discount 28JAN2027](https://plasmascan.to/address/0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f) |

### Oracle

A new linear discount oracle is deployed for the 28 January 2027 maturity. It prices the PT from the Capped USDT/USD feed, the same base feed as the October PT.

| Parameter                  | Value                                                                                                                  |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| initialDiscountRatePerYear | 4.399%                                                                                                                 |
| maxDiscountRatePerYear     | 9.047%                                                                                                                 |
| Oracle                     | [0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f](https://plasmascan.to/address/0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f) |

### Seed

100 `PT-sUSDe-28JAN2027` are held by the Plasma executor and supplied to the `DustBin` on execution.

### Useful links:

- [Pendle market](https://app.pendle.finance/trade/markets/0xdb96b529d19ff4a7d711e6e082172c77cfe88ed8/swap?view=pt&chain=plasma)
- [LlamaRisk recommendation](https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902/2)

## Next Steps

1. Submit the AIP for a governance vote.
2. If approved, execute the payload to list `PT-sUSDe-28JAN2027` on Aave V3 Plasma.

## References

- Implementation: [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261022_AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma/AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022.sol)
- Tests: [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261022_AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma/AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902)
- [LlamaRisk recommendation](https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902/2)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
