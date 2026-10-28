---
title: "Onboard USAT to Aave V4 Core Instance on Avalanche"
author: "@AaveLabs"
date: "2026-10-28"
discussions: "https://governance.aave.com/t/direct-to-aip-onboard-usat-to-aave-v4-core-instance-on-avalanche/25880"
---

## Simple Summary

This proposal onboards USAT to the Aave V4 Core Instance on Avalanche. USAT is listed on the Core Hub and becomes borrowable, but not collateral, on the Main Spoke and the Ethena Ecosystem Spoke. A Tokenization Spoke for USAT is deployed with a 1,500,000 USAT add cap.

## Motivation

USAT (Tether America USD) is a dollar stablecoin issued by Anchorage Digital Bank, N.A., a federally chartered national trust bank supervised by the Office of the Comptroller of the Currency (OCC). USAT is subject to the GENIUS Act and is redeemable 1:1 for U.S. dollars.

Onboarding USAT to the Aave V4 Core Hub on Avalanche:

- Adds a stablecoin issued by a bank under federal supervision in the United States to the Aave V4 Core Instance on Avalanche.
- Supports demand from institutional participants for a stablecoin issued under the federal stablecoin framework of the United States.
- Broadens the range of regulated dollar assets available across Aave deployments.

## Specification

This proposal lists USAT on the Core Hub of the Aave V4 Core Instance on Avalanche, deploys its Tokenization Spoke, and configures USAT as a borrow-only reserve on the Main Spoke and the Ethena Ecosystem Spoke.

**USAT**: [`0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b`](https://snowscan.xyz/address/0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b)

USAT is listed on the Core Hub [`0xd07369fAE4A5BB13c9Ce446B052c7867B1AbDf6e`](https://snowscan.xyz/address/0xd07369fAE4A5BB13c9Ce446B052c7867B1AbDf6e) with the Core Hub's interest rate strategy [`0x446eb3913b3fd3a9219A07B0f6AbE98BD0fAeed4`](https://snowscan.xyz/address/0x446eb3913b3fd3a9219A07B0f6AbE98BD0fAeed4). The liquidity fee accrues to the Treasury Spoke [`0x2C4Aea1A5F000889c6DfFE8f52377aFc2CB113a6`](https://snowscan.xyz/address/0x2C4Aea1A5F000889c6DfFE8f52377aFc2CB113a6).

The payload deploys the USAT Tokenization Spoke, Wrapped Aave Core USAT (`waCoreUSAT`), and registers it on the Core Hub. Its proxy admin is owned by the Aave V4 Security Council on Avalanche [`0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9`](https://snowscan.xyz/address/0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9).

Main Spoke: [`0x435272CefF93a1E657E8ABfdf0A13e95900A3a56`](https://snowscan.xyz/address/0x435272CefF93a1E657E8ABfdf0A13e95900A3a56)

Ethena Ecosystem Spoke: [`0xaf22446124e566e54845f65b722E4dCbf12b650A`](https://snowscan.xyz/address/0xaf22446124e566e54845f65b722E4dCbf12b650A)

**Spoke configuration**

| Hub  | Spoke                  | Reserve | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee | Risk Premium Threshold | Receive Shares |
| ---- | ---------------------- | ------- | ----------------: | --------------------: | ---------- | --------------: | --------------: | ---------------------: | -------------- |
| Core | Main Spoke             | USAT    |             0.00% |                     - | TRUE       |               - |               - |                  1100% | TRUE           |
| Core | Ethena Ecosystem Spoke | USAT    |             0.00% |                     - | TRUE       |               - |               - |                  1100% | TRUE           |

**Caps**

| Hub  | Spoke                  | Reserve |    Add Cap |   Draw Cap |
| ---- | ---------------------- | ------- | ---------: | ---------: |
| Core | Main Spoke             | USAT    | 60,000,000 |  5,000,000 |
| Core | Ethena Ecosystem Spoke | USAT    |          0 | 50,000,000 |
| Core | Tokenization Spoke     | USAT    |  1,500,000 |          0 |

**Interest rate configuration**

| Hub  | Reserve | Optimal Usage Ratio | Base Drawn Rate | Rate Growth Before Optimal | Rate Growth After Optimal | Liquidity Fee |
| ---- | ------- | ------------------: | --------------: | -------------------------: | ------------------------: | ------------: |
| Core | USAT    |              94.00% |           0.00% |                      4.90% |                    20.00% |        10.00% |

**Oracle configuration**

USAT is priced with a fixed price adapter returning 1 USD, with 8 decimals, on both spokes:

| Hub  | Spoke                  | Reserve | Price Feed                                                                                                              |
| ---- | ---------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------- |
| Core | Main Spoke             | USAT    | [`0xCcE4d712CA51098e89F26f79F114132942DE9134`](https://snowscan.xyz/address/0xCcE4d712CA51098e89F26f79F114132942DE9134) |
| Core | Ethena Ecosystem Spoke | USAT    | [`0xCcE4d712CA51098e89F26f79F114132942DE9134`](https://snowscan.xyz/address/0xCcE4d712CA51098e89F26f79F114132942DE9134) |

Chainlink publishes no USAT/USD aggregator on Avalanche, and as a borrow-only reserve USAT enters health factors only as debt.

## Disclaimer

This proposal was prepared by Aave Labs in its capacity as a contributor to the Aave ecosystem. Aave Labs has no direct financial relationship with Anchorage Digital Bank, N.A., Tether, or their affiliates and has not received compensation from any of these parties in connection with this proposal.

## References

- Implementation: [AaveV4Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/AaveV4Avalanche_OnboardUSATCoreHub_20261028.sol)
- Tests: [AaveV4Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/AaveV4Avalanche_OnboardUSATCoreHub_20261028.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-onboard-usat-to-aave-v4-core-instance-on-avalanche/25880)
