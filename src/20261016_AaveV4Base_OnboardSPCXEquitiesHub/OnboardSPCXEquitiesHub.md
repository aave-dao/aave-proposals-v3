---
title: "Onboard SPCXc to the Aave V4 Equities Hub on Base"
author: "@AaveLabs"
date: "2026-10-16"
discussions: "https://governance.aave.com/t/direct-to-aip-asset-listing-spcx-to-the-aave-v4-equities-hub-on-base/25850"
---

## Simple Summary

This proposal onboards SPCXc as collateral only on the existing MAG7 Spoke of the Aave V4 Equities Hub on Base, with USDC available to borrow against it. It follows the Direct to AIP route.

## Motivation

SPCX is a tokenized equity issued by Base, providing onchain exposure to SpaceX shares, which trade on Nasdaq under the same ticker. The Equities Hub on Base currently holds seven tokenized equities alongside USDC.

Onboarding SPCX would:

- Add tokenized SpaceX equity exposure to the Aave V4 Equities Hub on Base.
- Broaden the set of tokenized equities available on the Equities Hub.

## Specification

The payload lists SPCXc on the Equities Hub and MAG7 Spoke with the parameters below, and sets the MAG7 Spoke's USDC risk premium threshold to 1100%.

### Spoke Parameters

| Chain | Hub          | Spoke      | Reserve | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee | Risk Premium Threshold | Receive Shares |
| ----- | ------------ | ---------- | ------- | ----------------: | --------------------: | ---------- | --------------: | --------------: | ---------------------: | -------------- |
| Base  | Equities Hub | MAG7 Spoke | SPCXc   |            55.00% |                 6.50% | FALSE      |       1,000 bps |          10.00% |                      0 | TRUE           |

### Add and Draw Caps

| Chain | Hub          | Spoke      | Reserve | Add Cap | Draw Cap |
| ----- | ------------ | ---------- | ------- | ------: | -------: |
| Base  | Equities Hub | MAG7 Spoke | SPCXc   |  37,000 |        0 |

### Hub Spoke Configuration

| Chain | Hub          | Spoke      | Asset | Risk Premium Threshold |
| ----- | ------------ | ---------- | ----- | ---------------------: |
| Base  | Equities Hub | MAG7 Spoke | USDC  |                  1100% |

### Price Feed

SPCXc uses the Chainlink total return feed, which includes the issuer multiplier and follows 24/5 US equities market hours.

| Reserve | Token                                                                                                               | Chainlink feed                                                                                                        |
| ------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| SPCXc   | [0xb2000000000000000000007b9fcbd005511acbd5](https://basescan.org/token/0xb2000000000000000000007b9fcbd005511acbd5) | [0x6A634B235903C4ad6376892180d6fF8612e3Fa68](https://basescan.org/address/0x6A634B235903C4ad6376892180d6fF8612e3Fa68) |

### Execution permissions

The payload grants the Base governance executor `SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (400) on the Base AccessManager with zero execution delay. This persistent role permits the executor to call the SpokeConfigurator functions assigned to that role, including `addReserve`. Existing selector assignments remain unchanged.

## Disclaimer

This proposal was prepared by Aave Labs in its capacity as a contributor to the Aave ecosystem. Aave Labs has no direct financial relationship with Base or its affiliates and has not received compensation from Base or its affiliates in connection with this proposal.

## References

- Implementation: [AaveV4Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/AaveV4Base_OnboardSPCXEquitiesHub_20261016.sol)
- Tests: [AaveV4Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/AaveV4Base_OnboardSPCXEquitiesHub_20261016.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-asset-listing-spcx-to-the-aave-v4-equities-hub-on-base/25850)
- [Risk parameters](https://governance.aave.com/t/25850/2)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
