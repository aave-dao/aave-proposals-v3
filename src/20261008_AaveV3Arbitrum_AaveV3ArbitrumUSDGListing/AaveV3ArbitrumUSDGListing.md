---
title: "Onboard USDG to Aave V3 Arbitrum"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-asset-listing-usdg-arbitrum/25811"
---

## Simple Summary

This publication proposes to onboard USDG as a supported asset on the Aave V3 Arbitrum Instance.

USDG would join the instance as a borrowable stablecoin, giving Arbitrum users another option to supply and borrow.

## Motivation

USDG is a stablecoin issued by Paxos. According to Paxos documentation, USDG on Arbitrum is deployed through LayerZero OFT from Ethereum.

USDG is listed on Aave V3 Ethereum Core, Aave V3 X Layer, Aave V3 Ink (Tydro), and Aave V4 Ethereum through the Core Hub and the Global Dollar Hub, with collateral use disabled in each market. USDG supply on Aave is growing quickly, rising from $94.1M to $123.2M over the last 90 days, which makes USDG a strong candidate stablecoin for the Aave V3 Arbitrum Instance.

On Aave V3 Arbitrum, stablecoin liquidity is concentrated in the USDC and USD₮0 reserves, both of which run at high utilisation, while the other stablecoin reserves on the instance are frozen or small.

Onboarding USDG to Aave V3 Arbitrum would:

- Provide an additional borrowable stablecoin alongside USDC and USD₮0.
- Add borrowing capacity without increasing the instance's collateral risk, as USDG would not be active as collateral.
- Extend USDG's presence on Aave to Arbitrum, in line with its listings on other Aave markets.

The listing would bring a Paxos-issued stablecoin to Arbitrum and give USDG holders on the network a market to supply into.

## Specification

USDG Contract Address: [0x004B506865409877C9fA29bfb1ebA929984B9bbC](https://arbiscan.io/address/0x004B506865409877C9fA29bfb1ebA929984B9bbC)

The address above represents Paxos's USDG deployment on Arbitrum.

### Proposed Market Configuration

The parameters below follow the [LlamaRisk recommendation](https://governance.aave.com/t/direct-to-aip-asset-listing-usdg-arbitrum/25811/2).

| **Parameter**            | **Value**  |
| ------------------------ | ---------- |
| Asset                    | USDG       |
| Borrowable               | Yes        |
| Collateral Enabled       | No         |
| Supply Cap               | 30,000,000 |
| Borrow Cap               | 27,000,000 |
| LTV                      | 0.00%      |
| LT                       | 0.00%      |
| Liquidation Bonus        | 0.00%      |
| Liquidation Protocol Fee | 10%        |
| Variable Base            | 0.00%      |
| Variable Slope 1         | 4.50%      |
| Variable Slope 2         | 30.00%     |
| Uoptimal                 | 90.00%     |
| Reserve Factor           | 10%        |
| Flashloanable            | Yes        |
| eModes                   | -          |

The configuration excludes USDG from collateral use, consistent with its listings on the other Aave instances. It sets a 10% reserve factor, matching USDC and USD₮0 on Arbitrum and USDG on X Layer and Ink.

We consider USDG's secondary-market liquidity on Arbitrum, concentrated in the Fluid USDG/USDC pool, sufficient for an initial listing.

## Oracle

A Chainlink **USDG/USD Price Feed** is available on Arbitrum.

Consistent with the oracle configuration USDG uses on Aave V3 Ethereum Core, Ink, and X Layer, we propose pricing USDG with the Chainlink USDG/USD feed, along with a Capped USDG/USD adapter at a 1.04 price cap.

| **Component**                                     | **Value**                                                                                                            |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Chainlink USDG/USD feed                           | [0xE9Bd4Ca2CDacb56cd06c9C4C5231e69c33340B3c](https://arbiscan.io/address/0xE9Bd4Ca2CDacb56cd06c9C4C5231e69c33340B3c) |
| Capped USDG/USD adapter (`PriceCapAdapterStable`) | [0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D](https://arbiscan.io/address/0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D) |
| Price cap                                         | 1.04 USD                                                                                                             |

## Next Steps

1. Gather feedback from the community.
2. Using the Direct-to-AIP process, incorporate feedback from the Risk Service Provider and the Technical Service Provider.
3. Deposit at least $150 worth of USDG into the Aave Short Executor before the market goes live, as required by Aave Governance Framework v2.
4. Escalate this proposal to the AIP Voting stage.

## References

- Implementation: [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261008_AaveV3Arbitrum_AaveV3ArbitrumUSDGListing/AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008.sol)
- Tests: [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261008_AaveV3Arbitrum_AaveV3ArbitrumUSDGListing/AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-asset-listing-usdg-arbitrum/25811)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
