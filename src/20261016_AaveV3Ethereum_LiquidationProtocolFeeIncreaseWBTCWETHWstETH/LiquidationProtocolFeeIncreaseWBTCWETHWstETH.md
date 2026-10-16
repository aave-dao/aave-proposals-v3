---
title: "Liquidation Protocol Fee Increase for WBTC, WETH, and wstETH on Aave V3 Ethereum Core"
author: "LlamaRisk (implemented by Aave Labs)"
discussions: "https://governance.aave.com/t/arfc-liquidation-protocol-fee-increase-for-wbtc-weth-and-wsteth-on-aave-v3-ethereum-core/25470"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0xbc1c59336255d276088fa85f95ef7122d9d8a56940299093f3246b7db897b6a6"
---

## Simple Summary

LlamaRisk has initiated a review of the Liquidation Protocol Fee (LPF) configuration on Aave V3 Ethereum Core. The LPF is the share of each liquidation bonus that accrues to the Aave treasury, defined on a per collateral reserve basis. It currently stands at 10% for most Ethereum Core collateral, with USDC and DAI at 20%. Based on a full measurement of liquidation economics on Ethereum Core through the Chainlink SVR era, combined with forward-looking modeling of net revenue and liquidator behavior at higher fee levels, we propose raising the LPF from 10% to 20% on WBTC, WETH, and wstETH, on Aave V3 Ethereum Core only, and we recommend against going higher or broader than that at this time.

Backtested against the observed liquidation history, the change would have added between $1.35M and $2.23M per year of net treasury revenue, with no measurable bad debt attributable to it, including through the October 2025 crash. Realized dollar figures will depend on future liquidation volume, so the more durable way to express the gain is Aave's take per dollar of value liquidated. On these three collaterals it is expected to rise from about 173 bps today to 187–196 bps, an increase of roughly 8% to 13%.

The LPF and the SVR auction recapture value from the same liquidation bonus, so a higher fee partly displaces income Aave already receives, and beyond a point it suppresses the marginal liquidations that fund both revenue streams. Under conservative assumptions, Aave's take per dollar liquidated on these three collaterals peaks near a 30% fee and falls back below today's level by 40%. Any increase also adds risk in stress scenarios that are difficult to predict, because a static fee keeps taking its share even when liquidator margins compress, while SVR auction bids shrink with the margin. We therefore treat 20% as the appropriate step today and 30% as a hard ceiling on what the data could support.

## Motivation

Liquidation revenue on Ethereum Core comes from two sources. The static LPF is taken from each liquidation bonus, and the SVR auction recaptures part of what remains, with liquidators bidding away their margin and the proceeds shared 65% to Aave and 35% to Chainlink. Since October 2025, the auction reaches nearly all liquidated value. A higher fee would therefore draw on the same surplus the auction already recaptures. The relevant question for the DAO is not what a higher fee collects gross, but what it collects net of the auction income it displaces, and what tail risk it introduces where liquidator margins are thin.

To answer it, LlamaRisk measured the economics of every liquidation on Aave V3 Ethereum Core between April 2025 and June 2026, covering 14,006 events and approximately $1.05B of seized collateral. Each event was measured from onchain data at block-by-block oracle prices, including DEX price impact, gas, payments to block builders, and SVR auction proceeds. On that base we modeled fee levels from 20% to 60% and validated every liquidation a higher fee would have made unprofitable against the borrower's counterfactual price path.

WBTC, WETH, and wstETH account for approximately $612M of liquidated value in the post-October window and for most of the portfolio's fee gain at any level. They are the deepest markets on Aave, served by the most redundant set of liquidators, and they show no bad debt attributable to a 20% fee in either measurement window.

However, thinner collateral looks different and this is an important trade-off. In the portfolio-wide assessment BAL came out net negative at both 20% and 30%, earning around $30–60k of extra fee per year while accounting for the entire modeled bad-debt line. Its liquidations settle exclusively on DEX liquidity with high price impact, and its liquidators run the thinnest margins on the market.

The same economics apply, in milder degrees, across the smaller reserves. Liquidator margins thin out as collateral moves away from the bluechips, so each fee increase starts leaving positions unliquidated earlier there than on the majors, and a level that is comfortable for WBTC can already be suppressing liquidations on a mid-tail asset, even if liquidation bonus is overall larger. Somewhere around 20%, a broader increase would begin shifting risk onto the assets least able to bear it.

## Fee mechanics

The liquidation bonus is the discount a liquidator receives on seized collateral. The LPF is deducted from this bonus first, and the Chainlink Smart Value Recapture (SVR) auction then recaptures value from what the liquidator has left. Raising the fee from f₀ to f therefore displaces each liquidation's SVR bid one for one, up to the size of that bid:

`D_i = min((f - f_0) * bonus_i, recapture_i)`

where bonusᵢ is the gross liquidation bonus of liquidation i and recaptureᵢ its observed SVR auction proceeds (zero for liquidations that settle outside the auction). Aave gains the full extra fee but loses its 65% share of the displaced auction proceeds. A fee increase in the current regime is therefore partly a reallocation of existing liquidation income rather than new revenue.

At higher fee levels a second mechanic dominates. A liquidation whose surplus the fee would exhaust no longer occurs, because no liquidator can execute it profitably. It then pays no fee, and it also stops generating the LPF and SVR recapture it produces at the current 10% fee. Onchain history cannot show how liquidators would respond to a fee that has never changed during the SVR era, so results are reported as a band between two treatments. The conservative case assumes that every liquidation the fee makes unprofitable stops occurring, and the upper bound assumes that all of them still execute and pay the fee.

## Financial results

### Measurement window

All figures in this document are based on the period from October 13, 2025 to June 1, 2026. Earlier months are excluded because the SVR order flow was only fully integrated with the dominant block builders in mid-October 2025, so they do not reflect the mechanism as it operates today. The October 10, 2025 crash, the most severe liquidation episode in the dataset, falls just before that cutoff. Where it matters, we therefore also report the same scenarios with the crash week added back in, as a stress test. The window covers three of the four major liquidation cascades of the past year.

### Net effect by fee level, WBTC / WETH / wstETH

Post-October regime, net to Aave, change versus the current 10% fee, $/yr. Each cell is the band of [conservative, upper bound] estimations:

| LPF     |                   WBTC |                   WETH |                 wstETH |                  Total |
| ------- | ---------------------: | ---------------------: | ---------------------: | ---------------------: |
| **20%** | **+$0.38M to +$0.88M** | **+$0.81M to +$0.84M** | **+$0.16M to +$0.51M** | **+$1.35M to +$2.23M** |
| 30%     |     +$0.93M to +$1.81M |     +$1.57M to +$1.69M |     +$0.57M to +$1.10M |     +$3.07M to +$4.60M |
| 40%     |     −$0.07M to +$2.90M |     +$1.57M to +$2.56M |     +$0.48M to +$1.69M |     +$1.97M to +$7.14M |
| 50%     |     −$0.06M to +$4.26M |     +$1.71M to +$3.56M |     −$0.91M to +$2.40M |    +$0.74M to +$10.23M |
| 60%     |     −$0.34M to +$5.79M |     +$1.16M to +$4.71M |     −$2.44M to +$3.36M |    −$1.62M to +$13.87M |

Including the October 10 crash week, the 20% total is +$1.20M to +$2.15M per year. The 20% level produces no bad debt on these collaterals in either window. The only bad-debt charge these three assets show anywhere in the analysis appears at the 40% to 60% levels, on WETH positions from the crash week, most of which were already insolvent at the moment of liquidation.

In recapture terms, Aave today keeps about 173 bps of every dollar liquidated on these three collaterals, combining the 10% LPF and its 65% share of the SVR recapture. Under the conservative treatment that take peaks at about 205 bps near a 30% fee and falls back to about 156 bps at 60%, below today's level. The upper bound keeps rising with the fee, but it assumes that no liquidator ever pulls back. The higher the fee, the wider the gap between the two bounds, and the less certain the outcome.

### The risk-adjusted ceiling

The build-up below traces, for the three collaterals combined at a 60% fee, how the gross fee turns into net revenue under each treatment. A flipped liquidation is one the higher fee makes unprofitable, meaning the fee takes so much of the bonus that no liquidator can execute it and keep a margin. Both treatments begin from the same $24.1M of annual fee a 60% LPF would collect if every liquidation executed. The upper bound assumes the flipped liquidations still execute, so it subtracts only the displaced SVR income and stays positive.

The conservative treatment assumes they stop occurring, so it also removes the fee they no longer pay and the baseline LPF and SVR income they generate today, leaving −$1.6M. Beyond a certain fee level the protocol is no longer taxing liquidator surplus but suppressing the liquidations that fund both revenue streams, and additional fee lowers revenue.

The broader problem with higher fee levels is that the uncertainty of the estimate grows. Each additional fee percentage point adds a fixed amount of gross fee but pushes more liquidations toward their break-even point, where behavior cannot be predicted from onchain history. wstETH shows this most directly, where the majority of its liquidation value settles against market-maker inventory off-book, where the margin behind the observed auction bid cannot be traced onchain, and under the conservative treatment its net turns negative from 50% onward, reaching −$2.44M per year at 60%. The realized outcome at high fees would land somewhere inside the band. The protocol cannot know where in advance, and the cost of being wrong rises with the fee. On a risk-adjusted basis, approximately 30% is the ceiling this data could support. We propose 20% rather than the ceiling because it captures the well-supported part of the gain and lets the protocol observe actual liquidator behavior under a raised fee for the most liquid reserves before any additional move is considered.

## Risk assessment

### Which liquidations a higher fee stops

A liquidation remains economically viable while its bonus covers the liquidator's two hard costs, the price impact of selling the seized collateral and the transaction processing fee. Everything above those costs is surplus. Payments to block builders and bids into the SVR auction are surplus too, given away voluntarily to win the execution. For each liquidation, the surplus was measured onchain as the cash the operator's addresses kept plus what it paid to the builder or auction, capped at the liquidation's own bonus. The fee level at which this surplus reaches zero is the liquidation's break-even fee. A liquidation is treated as unexecuted when the proposed fee would leave its liquidator less than 10% of the bonus as profit, a deliberately stricter rule than pure break-even.

### The counterfactual check

For every position below the cushion, market-maker liquidations included, the analysis reconstructs the borrower's counterfactual health factor at each of the 100 blocks (about 20 minutes) following the liquidation, using block-exact oracle prices, and books a shortfall only where collateral can no longer cover the debt plus the liquidation bonus a future liquidator must be paid.

Across the union of all candidate sets on these three collaterals in both windows, 465 positions worth approximately $354M were checked. In the post-October window a single position crosses the bad-debt threshold, for a negligible shortfall. Every other liquidation a higher fee would have left unexecuted either recovered on its own or remained adequately collateralised over the following 100 blocks. Across both windows, ten positions cross, all WETH, with a combined shortfall of approximately $0.55M. Nine of them were liquidated during the October 10 crash while already below the threshold, so the shortfall existed at the current 10% fee.

The pattern behind these results is consistent. Liquidations near the margin are overwhelmingly triggered by momentary oracle price dips on positions that are healthy minutes later, and a higher fee declines to act on dips that did not need acting on. The mechanism also self-corrects. If a price genuinely keeps falling, the same position becomes more profitable to liquidate and a liquidator returns within blocks, even at the higher fee. The figure below traces the block-by-block counterfactual path of the 10 largest flipped positions, including the largest market-maker liquidations. Each remains at or above its liquidation threshold and returns toward or above 1.

### Conservatism of the estimates

The estimates are deliberately biased against the proposal. The conservative bound treats every liquidation the fee makes unprofitable as not occurring, including all market-maker value, even though some of it would still execute at a thinner margin. The bad-debt line charges the worst point of each position's 100-block path in full, including shortfall that already existed at the current fee. The 10% profit cushion stops liquidations that are still profitable, where the break-even may have been lower. The counterfactual reprices each position by its seized collateral's full price move, which overstates the drop for positions holding several collateral types.

### Assumptions

- The analysis is a backtest carrying empirical estimates. The 2025 to 2026 record, including the October 2025 crash, shows how those months would have played out under a higher fee. It cannot price a future episode more severe than October 10, in which prices do not recover before liquidators return. Equivalently, future liquidation volumes cannot be predicted.
- Within the backtest, the central assumption is that the fee displaces SVR bids one for one. It follows from the auction's design, since a liquidator cannot bid surplus the fee has already taken, but it has never been observable, because the fee has not changed since inception. Raising the fee to 20% would produce the first onchain observation of it.
- The model further assumes that liquidators stop acting once the fee leaves them less than 10% of the bonus. Break-even fees are measured from traced onchain cash flows, but how liquidators actually respond cannot be measured in advance, and a static fee does not throttle itself in stress the way the auction does. Market-maker liquidations are the largest single unknown here. That uncertainty grows with the fee and is a further reason to stop at 20%.
- The bad-debt check follows each position for 100 blocks, about 20 minutes. Beyond that horizon a genuinely falling price makes the same position more profitable to liquidate, so a liquidator returns. This is an argument from incentives rather than an observation, and it is why 20 minutes is treated as the relevant window.

## Specification

| Market                | Asset  | Parameter                | Current | Proposed |
| --------------------- | ------ | ------------------------ | ------: | -------: |
| Aave V3 Ethereum Core | WBTC   | Liquidation Protocol Fee |     10% |      20% |
| Aave V3 Ethereum Core | WETH   | Liquidation Protocol Fee |     10% |      20% |
| Aave V3 Ethereum Core | wstETH | Liquidation Protocol Fee |     10% |      20% |

All other reserves and markets remain unchanged.

## Next Steps

Following implementation, LlamaRisk will monitor liquidation execution, SVR recapture, and liquidator margins on the affected collaterals, including through the next stress episode.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH/AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH/AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016.t.sol)
- [Snapshot](https://snapshot.box/#/s:aavedao.eth/proposal/0xbc1c59336255d276088fa85f95ef7122d9d8a56940299093f3246b7db897b6a6)
- [Discussion](https://governance.aave.com/t/arfc-liquidation-protocol-fee-increase-for-wbtc-weth-and-wsteth-on-aave-v3-ethereum-core/25470)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
