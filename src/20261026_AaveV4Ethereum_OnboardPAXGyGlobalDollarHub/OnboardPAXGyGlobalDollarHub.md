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

This proposal lists PAXGy on the Global Dollar Hub of the Aave V4 Ethereum instance, configures PAXGy as collateral on the PAXG Gold Spoke and on the new PAXG Paxos eSpoke, makes PAXG borrowable on the PAXG Paxos eSpoke, updates the PAXG interest rate model on the Global Dollar Hub, and sets an Add Cap on the existing PAXG Tokenization Spoke. The parameters follow [LlamaRisk's recommendation](https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499/3), where the PAXG Gold Spoke is referred to as the "Gold Spoke" and the PAXG Paxos eSpoke as the "Gold Correlated Spoke".

**PAXGy**: [`0x6c6494Fd9962eB98B94ffA48F6679058F820700e`](https://etherscan.io/address/0x6c6494Fd9962eB98B94ffA48F6679058F820700e)

**PAXGy price adapter (CAPO)**: [`0x8E39De6366AB0bc3e9FF6a116f366736bf0D8A9e`](https://etherscan.io/address/0x8E39De6366AB0bc3e9FF6a116f366736bf0D8A9e#code)

The PAXG Paxos eSpoke is deployed at [`0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616`](https://etherscan.io/address/0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616#code). The payload wires it to the Ethereum AccessManager, sets its liquidation configuration, and enables the Giver, Taker and Config Position Managers and the Signature Gateway on it. Registration of the spoke on these position managers is a separate Security Council action.

PAXGy is listed on the Global Dollar Hub as a non-borrowable asset, with a 0.00% liquidity fee, the Global Dollar Hub's PAXG interest rate strategy [`0xD7eC225DC053151100A0ef47b94a77AAD9C413b7`](https://etherscan.io/address/0xD7eC225DC053151100A0ef47b94a77AAD9C413b7), and no PAXGy Tokenization Spoke.

**Spoke configuration**

| Hub               | Spoke             | Reserve | Collateral Factor | Max Liquidation Bonus | Borrowable | Collateral Risk | Liquidation Fee | Risk Premium Threshold | receiveShares |
| ----------------- | ----------------- | ------- | ----------------: | --------------------: | ---------- | --------------: | --------------: | ---------------------: | ------------- |
| Global Dollar Hub | PAXG Gold Spoke   | PAXGy   |            70.00% |                 7.50% | FALSE      |           0.00% |          10.00% |                  0.00% | TRUE          |
| Global Dollar Hub | PAXG Paxos eSpoke | PAXGy   |            85.00% |                 4.00% | FALSE      |           0.00% |          10.00% |                  0.00% | TRUE          |
| Global Dollar Hub | PAXG Paxos eSpoke | PAXG    |             0.00% |                     - | TRUE       |               - |               - |                  0.00% | TRUE          |

For required onchain fields, the dash values in the table resolve to zero. On the PAXG Gold Spoke, borrowing USDG against PAXGy uses the spoke's existing USDG Draw Cap.

**Dynamic liquidation configuration**

| Parameter               | PAXG Paxos eSpoke |
| ----------------------- | ----------------: |
| targetHealthFactor      |              1.05 |
| healthFactorForMaxBonus |              0.99 |
| liquidationBonusFactor  |              1.00 |

The PAXG Gold Spoke keeps its existing liquidation configuration and its PAXG and USDG reserve configurations.

**Caps**

| Hub               | Spoke                   | Reserve | Add Cap | Draw Cap |
| ----------------- | ----------------------- | ------- | ------: | -------: |
| Global Dollar Hub | PAXG Gold Spoke         | PAXGy   |     480 |        0 |
| Global Dollar Hub | PAXG Paxos eSpoke       | PAXGy   |     480 |        0 |
| Global Dollar Hub | PAXG Paxos eSpoke       | PAXG    |       0 |      400 |
| Global Dollar Hub | PAXG Tokenization Spoke | PAXG    |     400 |        0 |

The [PAXG Tokenization Spoke](https://etherscan.io/address/0x6493a23874b506D5Bb6038ea44aE9CC74cD00849) already exists on the Global Dollar Hub with both caps at 0. Its Add Cap is raised to 400 PAXG and its Draw Cap stays at 0, as Tokenization Spokes are supply-only.

Caps are stated in units of the reserve asset. Each 480 PAXGy Add Cap is about $2.0 million, and the 400 PAXG Draw Cap and the 400 PAXG Tokenization Spoke Add Cap are each about $1.7 million at the October 1, 2026 exchange rate and gold price.

**PAXG interest rate model**

| Hub               | Reserve |  Base | Slope 1 | Slope 2 | Uoptimal | Liquidity Fee |
| ----------------- | ------- | ----: | ------: | ------: | -------: | ------------: |
| Global Dollar Hub | PAXG    | 0.00% |   3.00% |  20.00% |   60.00% |        50.00% |

The rate at 60% utilisation matches PAXGy's 3% target yield, so a PAXGy/PAXG loop earns more than PAXGy alone below that point and unwinds above it. The model applies to all PAXG on the Global Dollar Hub, including PAXG supplied as collateral on the PAXG Gold Spoke. The existing interest rate strategy, fee receiver and reinvestment controller are kept.

**Oracle configuration**

PAXGy is priced on both spokes through a CAPO adapter that multiplies the exchange rate of the PAXGy vault accountant, read through its `getRate()` getter, by the Chainlink XAU/USD feed, returning a USD price with 8 decimals and capping the yearly growth of the ratio. PAXG on the PAXG Paxos eSpoke is priced with the same Chainlink XAU/USD feed.

| Parameter                     |                                                                                                                                       Value |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------: |
| Contract                      |                                                                                                  0x8E39De6366AB0bc3e9FF6a116f366736bf0D8A9e |
| Ratio provider                |    PAXGy accountant ([0x397e38359f169748a02bc11f98D4f451FE88C1fd](https://etherscan.io/address/0x397e38359f169748a02bc11f98D4f451FE88C1fd)) |
| Base aggregator               | Chainlink XAU / USD ([0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6](https://etherscan.io/address/0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6)) |
| `maxYearlyRatioGrowthPercent` |                                                                                                                                       6.00% |
| `MINIMUM_SNAPSHOT_DELAY`      |                                                                                                                                      7 days |
| `snapshotRatio`               |                                                                                                                         1001317899581791979 |
| `snapshotTimestamp`           |                                                                                                                                  1791136619 |

If the accountant pauses, `getRate()` keeps returning the last stored rate, so PAXGy remains priced and liquidations continue; a markdown reaches the price only after the issuer's 24-hour timelock. LlamaRisk recommends responding to an accountant pause by freezing PAXGy and setting its collateral factor to 0 on both spokes.

**Liquidity**

LlamaRisk's support is conditional on the liquidity Paxos Labs committed on Ethereum being live at listing: $2 million in a Uniswap PAXGy/PAXG pool and $1 million in the PAXG/USDC pool.

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
