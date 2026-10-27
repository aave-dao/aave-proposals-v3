---
title: "Onboard PAXGy to Aave V4 Global Dollar Hub"
author: "@AaveLabs"
date: "2026-10-26"
discussions: "https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0xf987dd5aed6586169b232af7691e2cbb268cf61e2845bf6a04a83b60a5404bd8"
---

## Simple Summary

This proposal onboards PAXGy as collateral to the Aave V4 Global Dollar Hub on Ethereum. Users can borrow USDG against PAXGy on the existing PAXG Gold Spoke and borrow PAXG against PAXGy on the new PAXG Paxos eSpoke.

## Motivation

PAXGy is a vault share token issued by Paxos Labs. Holders deposit PAXG into the vault and receive PAXGy in return. The vault is designed to generate a return on the deposited PAXG and to pass that return to holders by letting each PAXGy share redeem for a growing amount of PAXG over time.

Onboarding PAXGy to the Global Dollar Hub would be aligned with the DAO's long-term objectives in several ways:

- It extends the Global Dollar Hub's existing gold exposure through PAXG into a yield-bearing form, giving users a way to earn a return on gold-backed collateral without leaving the Aave ecosystem.
- It gives users access to a Paxos-administered yield product on top of a regulated, physically-backed gold token, supporting demand from participants seeking commodity exposure with a return component.
- It complements the Global Dollar Hub's composition, adding a non-correlated, yield-bearing asset alongside its existing PAXG listing.

## Specification

The configuration follows [LlamaRisk's recommendations](https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499/3) and the [asset assessment](https://governance.aave.com/t/paxgy-on-aave-ethereum-assessments/25831/2), including the October 26, 2026 update to the accountant getter.

PAXGy is listed on the [Global Dollar Hub](https://etherscan.io/address/0x62d63197660c080236193CA60b70E49A08E90368). The existing [PAXG Gold Spoke](https://etherscan.io/address/0xAD75cE6354f87F3135cE10621d385d8D1e2562C2) is the spoke called "Gold Spoke" in the recommendation. The new PAXG Paxos eSpoke corresponds to its "Gold Correlated Spoke"; it is deployed at [0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616](https://etherscan.io/address/0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616).

The payload configures the deployed PAXG Paxos eSpoke and wires its restricted selectors to the Ethereum AccessManager. Its ProxyAdmin is owned by the V4 Security Council. The spoke uses oracle [0x6b3800e96Bb4AA38a879b2c143B6E2f5f2687b77](https://etherscan.io/address/0x6b3800e96bb4aa38a879b2c143b6e2f5f2687b77), bound to that spoke.

The Giver, Taker and Config Position Managers and the Signature Gateway are enabled on the new spoke. Registration of the spoke on these council-owned managers is a separate Security Council action during the hardening phase.

**PAXGy**: [0x6c6494Fd9962eB98B94ffA48F6679058F820700e](https://etherscan.io/address/0x6c6494Fd9962eB98B94ffA48F6679058F820700e)

**Spoke configuration**

| Hub               | Spoke             | Reserve | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee | Risk Premium Threshold | receiveShares |
| ----------------- | ----------------- | ------- | ----------------: | --------------------: | ---------- | --------------: | --------------: | ---------------------: | ------------- |
| Global Dollar Hub | PAXG Gold Spoke   | PAXGy   |            70.00% |                 7.50% | FALSE      |           0.00% |          10.00% |                  0.00% | TRUE          |
| Global Dollar Hub | PAXG Paxos eSpoke | PAXGy   |            85.00% |                 4.00% | FALSE      |           0.00% |          10.00% |                  0.00% | TRUE          |
| Global Dollar Hub | PAXG Paxos eSpoke | PAXG    |             0.00% |                     - | TRUE       |               - |               - |                  0.00% | TRUE          |

PAXGy is collateral only on both spokes. PAXGy is listed on the Global Dollar Hub as a non-borrowable asset, with a 0.00% liquidity fee, the Global Dollar Hub's PAXG interest rate strategy [`0xD7eC225DC053151100A0ef47b94a77AAD9C413b7`](https://etherscan.io/address/0xD7eC225DC053151100A0ef47b94a77AAD9C413b7), and no Tokenization Spoke. The PAXG reserve's dash values resolve to zero collateral risk and liquidation fee, with a 100% onchain maximum liquidation multiplier (zero bonus).

**Dynamic liquidation configuration**

| Parameter               | PAXG Paxos eSpoke |
| ----------------------- | ----------------: |
| targetHealthFactor      |              1.05 |
| healthFactorForMaxBonus |              0.99 |
| liquidationBonusFactor  |              1.00 |

The currently existing Gold Spoke keeps its configuration.

On the existing [Gold Spoke](https://etherscan.io/address/0xAD75cE6354f87F3135cE10621d385d8D1e2562C2), PAXGy is a collateral-only reserve borrowing USDG. It is a gold-denominated asset of the type that spoke already carries, so it takes the spoke's liquidation configuration unchanged and its own collateral factor, bonus, and caps, and its USDG borrowing draws on the spoke's existing USDG Draw Cap.

**Caps**

| Hub               | Spoke             | Reserve | Add Cap | Draw Cap |
| ----------------- | ----------------- | ------- | ------: | -------: |
| Global Dollar Hub | PAXG Gold Spoke   | PAXGy   |     480 |        0 |
| Global Dollar Hub | PAXG Paxos eSpoke | PAXGy   |     480 |        0 |
| Global Dollar Hub | PAXG Paxos eSpoke | PAXG    |       0 |      400 |

Caps are stated in units of the reserve asset. Each 480 PAXGy Add Cap is about $2.0 million at the October 1, 2026 exchange rate and gold price, and the 400 PAXG Draw Cap is about $1.7 million.

**Interest rate model**

| Hub               | Reserve |  Base | Slope 1 | Slope 2 | Uoptimal | Liquidity Fee |
| ----------------- | ------- | ----: | ------: | ------: | -------: | ------------: |
| Global Dollar Hub | PAXG    | 0.00% |   3.00% |  20.00% |   60.00% |        50.00% |

The rate at 60% utilisation matches PAXGy's 3% target yield, so a loop earns more than PAXGy alone below that point and unwinds above it. The model applies to all PAXG on the hub, including the PAXG supplied as collateral on the Gold Spoke.

**Oracle configuration**

We recommend pricing PAXGy through a CAPO adapter that multiplies the exchange rate published by the [vault's accountant](https://etherscan.io/address/0x397e38359f169748a02bc11f98D4f451FE88C1fd), read through its `getRate()` getter, by the Chainlink [XAU/USD aggregator](https://etherscan.io/address/0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6), denominated in USD at 8 decimals, with the ratio capped at 6.00% yearly growth over a 7-day snapshot delay.

| Parameter                     |               Value |
| ----------------------------- | ------------------: |
| `maxYearlyRatioGrowthPercent` |               6.00% |
| `MINIMUM_SNAPSHOT_DELAY`      |              7 days |
| `snapshotRatio`               | 1001317899581791979 |
| `snapshotTimestamp`           |          1791136619 |

A Chainlink [PAXG/USD feed](https://etherscan.io/address/0x9944D86CEB9160aF5C5feB251FD671923323f8C3) exists and prices the token the vault actually redeems into, but it publishes about 4.7 rounds a day at a 0.5% deviation threshold, against 11.1 rounds a day at 0.3% on the gold feed, making the gold reference the faster and tighter instrument on both axes that govern liquidation timing. Aave already prices gold-backed collateral against it, PAXG on the Global Dollar Hub included, so for a position that borrows PAXG against PAXGy the collateral-to-debt ratio equals the accountant's rate, which is what redemption pays in PAXG. The adapter reads the accountant directly. A Chainlink [PAXGy/Gold exchange-rate feed](https://etherscan.io/address/0xaaA69F0bC7E355581a83002B597Fe5c6C134ae08) carries the same rate one daily publication behind the accountant itself.

The composition accepts the gap between gold and the wrapper the market holds. Across 664 daily observations from December 7, 2024 to October 1, 2026 the underlying PAXG priced within 1% of gold spot on 96.5% of days, at a worst discount of 1.47%.

A write below the standing rate on the PAXGy vault accountant pauses the accountant instead of publishing, and `getRate()` keeps returning the last stored rate. The adapter therefore keeps pricing PAXGy, and liquidations continue while the accountant is paused. A markdown can reach the price only after the timelock lowers the accountant's floor, an operation scheduled on-chain at least 24 hours before it executes, and until then the price holds at the last rate written. We recommend that a pause of the accountant be met with a freeze of PAXGy and a collateral factor of 0 on both spokes, so that no new borrowing is taken against that rate. The `getRateSafe()` getter reverts while the accountant is paused, so reading it would halt liquidations on every PAXGy position until the timelock lifts the pause. A single pause-holder key or an out-of-bounds update can set off that pause. The accountant's own limiter allows 0.04% per hour, which places no meaningful bound on annual growth, leaving the adapter's ceiling as the only annual constraint on the ratio. The rate has grown by about 0.88 basis points a day, 3.25% a year, in daily writes with weekly steps of up to 4 basis points, and the 6.00% ceiling allows 11.5 basis points over 7 days against a largest 7-day rise to date of about 9.7.

PAXG debt uses the same XAU/USD reference.

**Liquidity**

The support is conditional on the liquidity Paxos Labs has committed on Ethereum being live at the time of listing, $2 million in a Uniswap pool against PAXG and $1 million in the PAXG/USDC pool.

## Disclaimer

This proposal was prepared by Aave Labs in its capacity as a contributor to the Aave ecosystem. Aave Labs has no financial relationship with Paxos Trust Company or any of its affiliates and has not received compensation from Paxos in connection with this proposal.

## References

- Implementation: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261026_AaveV4Ethereum_OnboardPAXGyGlobalDollarHub/AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026.sol)
- Tests: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261026_AaveV4Ethereum_OnboardPAXGyGlobalDollarHub/AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0xf987dd5aed6586169b232af7691e2cbb268cf61e2845bf6a04a83b60a5404bd8)
- [Discussion](https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499)
- [LlamaRisk recommendation](https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499/3)
- [Risk assessment](https://governance.aave.com/t/paxgy-on-aave-ethereum-assessments/25831/2)
- [CAPO implementation](https://github.com/aave-dao/aave-price-feeds/pull/179)
- [PAXG Paxos eSpoke deployment](https://github.com/aave/aave-v4/pull/1388)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
