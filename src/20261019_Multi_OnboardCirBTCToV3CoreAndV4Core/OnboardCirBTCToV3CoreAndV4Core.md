---
title: "Onboard cirBTC on Aave V3 Core and Aave V4 Core"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/arfc-onboard-cirbtc-on-aave-v3-core-and-aave-v4-core/25128"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0xe7ce2a6c2c3f8ea303351a12ea0e991815b3944bd44af4fd2890cadc2ff19881"
---

## Simple Summary

This proposal seeks to onboard Circle Wrapped Bitcoin (cirBTC) to the Aave V3 Core Instance and the Aave V4 Core Instance on Ethereum, with collateral functionality enabled.

## Motivation

cirBTC is an ERC-20 representation of native BTC issued by Circle, launched on Ethereum mainnet on June 8, 2026. Each unit is backed 1:1 by Bitcoin custodied at a regulated Circle entity and segregated from Circle's corporate assets.

Onboarding cirBTC as a collateral asset is aligned with the DAO's long-term objectives in several ways:

- It broadens the set of BTC denominated collateral available on Aave, complementing existing wrapped Bitcoin exposures already present on the Core instances.
- It enables users to borrow against a regulated, BTC backed wrapped representation, supporting demand from institutional participants and DeFi protocols.
- It strengthens the Core instances' position as a venue for BTC denominated leverage and liquidity strategies.

## Specification

**cirBTC**: [`0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E`](https://etherscan.io/address/0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E)

### Aave V3 Specific Parameters

**Instance:** Ethereum Core

| Parameter                 | Recommendation |
| ------------------------- | -------------- |
| Borrowable                | Yes            |
| Collateral Enabled        | Yes            |
| Supply Cap                | 250            |
| Borrow Cap                | 20             |
| LTV                       | 73%            |
| LT                        | 78%            |
| Liquidation Bonus         | 5%             |
| Liquidation Protocol Fee  | 20%            |
| Reserve Factor            | 50%            |
| Base Variable Borrow Rate | 0.25%          |
| Variable Slope 1          | 4%             |
| Variable Slope 2          | 60%            |
| Uoptimal                  | 80%            |
| Flashloan Enabled         | Yes            |

A seed amount of 0.001 cirBTC is supplied to the Dust Bin on behalf of the protocol.

### Aave V4 Specific Parameters

cirBTC is listed on the Core Hub with the Core Hub's interest rate strategy [`0xAD88791B0F81D1FA242f637eB05bee0cbc53fe2f`](https://etherscan.io/address/0xAD88791B0F81D1FA242f637eB05bee0cbc53fe2f) and a Core cirBTC Tokenization Spoke (Wrapped Aave Core cirBTC, `waCorecirBTC`), and is added as a reserve on the existing Main Spoke.

#### Spoke Parameters

| Chain    | Hub      | Spoke      | Reserve | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee | Risk Premium Threshold | Receive Shares |
| -------- | -------- | ---------- | ------- | ----------------- | --------------------- | ---------- | --------------- | --------------- | ---------------------- | -------------- |
| Ethereum | Core Hub | Main Spoke | cirBTC  | 78%               | 5.55%                 | TRUE       | 0               | 10%             | 0                      | TRUE           |

#### Add and Draw Caps

| Chain    | Hub      | Spoke                          | Reserve | Add Cap | Draw Cap |
| -------- | -------- | ------------------------------ | ------- | ------- | -------- |
| Ethereum | Core Hub | Main Spoke                     | cirBTC  | 250     | 25       |
| Ethereum | Core Hub | Core cirBTC Tokenization Spoke | cirBTC  | 25      | 0        |

In line with WBTC, cbBTC and LBTC on the Core Hub, cirBTC also gets a Tokenization Spoke. Tokenization Spokes serve as the standard entry point for integrators, vaults, aggregators, and other strategies routing liquidity into Aave V4 markets. They are supply-only, so the draw cap is set to 0.

#### Interest Rate Curve

| Chain    | Hub      | Asset  | Base  | Slope 1 | Slope 2 | Uoptimal | Liquidity Fee |
| -------- | -------- | ------ | ----- | ------- | ------- | -------- | ------------- |
| Ethereum | Core Hub | cirBTC | 0.25% | 4%      | 60%     | 80%      | 20%           |

### Price feed Recommendation

We recommend using Chainlink’s [SVR BTC/USD feed](https://etherscan.io/address/0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A) to price cirBTC on Aave V3 and V4. The same feed already prices BTC wrappers on the Aave V3 Core instance and on the Aave V4 Main Spoke.

Price feed: [`0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A`](https://etherscan.io/address/0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A)

## Disclaimer

This proposal was prepared by Aave Labs in its capacity as a contributor to the Aave ecosystem. Aave Labs has no financial relationship with Circle or any of its affiliates and has not received compensation from Circle in connection with this proposal.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.sol), [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.t.sol), [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0xe7ce2a6c2c3f8ea303351a12ea0e991815b3944bd44af4fd2890cadc2ff19881)
- [Discussion](https://governance.aave.com/t/arfc-onboard-cirbtc-on-aave-v3-core-and-aave-v4-core/25128)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
