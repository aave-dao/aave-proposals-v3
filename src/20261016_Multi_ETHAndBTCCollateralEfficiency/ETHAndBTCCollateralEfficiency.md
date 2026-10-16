---
title: "Revision of ETH & BTC Collateral Efficiency on Aave"
author: "LlamaRisk (implemented by Aave Labs)"
discussions: "https://governance.aave.com/t/arfc-revision-of-eth-btc-collateral-efficiency-on-aave/25649"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0x0845fbf2d49ec5ad85f8a569e51ce7014f6f4c6dfc34e3b6cd28ef3f9037d586"
---

## Simple Summary

This ARFC proposes raising the LTV and liquidation threshold of the ETH and BTC collateral families on Aave V3 Ethereum Core, Arbitrum, and Base, and the collateral factors of the same assets on the Aave V4 Ethereum Main Spoke. The proposed settings follow from a calibration against historical price behavior and Chainlink price feed updates, which are dense during fast markets and span both the February 2025 and October 2025 stress events. Each threshold is sized to the 99.9th percentile of the worst excursion inside a 1 hour window, the period over which positions are cleared through sequential liquidation calls, at the reserve's liquidation bonus.

The proposed changes are the following:

- WETH moves to 81% LTV and 84% LT on Ethereum Core, Base, and Arbitrum.
- wstETH moves to 79% LTV and 82% LT and weETH to 78% LTV and 81% LT on Ethereum Core.
- WBTC moves to 81% LTV and 85% LT on Ethereum Core and to 78% LTV and 82% LT on Arbitrum.
- cbBTC moves to 81% LTV and 85% LT on Ethereum Core and to 81% LTV and 84% LT on Base, with the Base liquidation bonus lowered to 6.00% and the Base cbBTC Stablecoins E-Mode raised to 82% LTV and 85% LT.
- On the Aave V4 Main Spoke, the collateral factor moves to 84% for WETH, 82% for wstETH, 81% for weETH, and 85% for WBTC and cbBTC, applied as a dynamic configuration update.

The analysis supports these settings on the following grounds:

- ETH remains materially more volatile than BTC, with two-year annualized volatility of 68.8% against 44.4% and deeper excursion tails at every window. The 1 hour p99.9 excursion is -11.85% for ETH and -5.09% for BTC on its binding leg.
- The recommended ETH family thresholds sit inside the buffer implied by the basis at each reserve's live bonus. WETH is set at its ceiling, and wstETH and weETH one point inside theirs.
- The BTC settings of 82 to 85% sit deliberately deep inside the buffer implied by the basis, as margin against depth, cap, and concentration risks the price model does not capture.
- The basis covers every realized 1 hour excursion of the two-year record up to its 99.9th percentile and relies on the measured liquidation cadence, which kept position marks seconds to minutes fresh through both stress events. The residual scenario outside the basis is a stalled oracle and liquidation pipeline coinciding with a move beyond that percentile, with the realized worst at -24.27% for ETH and -11.15% for BTC over one hour.
- Liquidation processing is measured in seconds on every market examined, the slow tail is attributed to dust debt, and the two stress events produced $0 and $0.39M of bad debt respectively, with no bad debt for the analyzed collateral.
- The same framework applied to the Aave V4 Main Spoke, the V4 counterpart of the Ethereum Core market, supports the same moves as V3, as the same Chainlink SVR auction setup is applied for both markets, integrating a set of robust searchers.

## Motivation

Aave's bluechip collateral parameters have remained relatively stable over time, even as market conditions and volatility risk profiles have changed. This creates a trade-off in which overly conservative parameters reduce how much users can borrow against their collateral. The purpose of this assessment is to determine whether current LTV and LT parameters are consistent with the observed volatility and liquidity of each collateral asset, and this ARFC proposes the parameter changes that follow from it.

## Methodology

### Liquidation window

The window is the period over which the tail move is measured and it is the single largest input to the resulting parameter. We measure it from liquidation behaviour in two parts. The first is the time each liquidation call spent at or below the price at which it executed, weighted by the value being processed, computed with a single code path across markets, each market joined against the feed its Aave deployment reads and against stablecoin debt, over August 2025 to August 2026.

| Market        | Collateral | Liquidations | Seized | Weighted median | Weighted p95 | Weighted p99 | Value below price over 1 h |
| ------------- | ---------- | -----------: | -----: | --------------: | -----------: | -----------: | -------------------------: |
| Ethereum Core | ETH        |        7,206 |  $618M |       under 1 s |      2.0 min |        5 min |                      0.00% |
| Ethereum Core | BTC        |        2,621 |  $358M |       under 1 s |      2.2 min |        5 min |                      0.07% |
| Arbitrum      | ETH        |        5,699 |   $41M |       under 1 s |         18 s |        2 min |                      0.00% |
| Arbitrum      | BTC        |        1,819 |   $18M |       under 1 s |         48 s |        2 min |                      0.00% |
| Base          | ETH        |        7,448 |   $20M |       under 1 s |         48 s |        2 min |                      0.02% |
| Base          | BTC        |        1,444 |   $22M |       under 1 s |      1.1 min |        2 min |                      0.00% |

_Source: LlamaRisk, August 29, 2026_

Weighted by value, every market clears its economically meaningful liquidations within minutes of the price crossing, and the share of processed value that had been below its liquidation price for more than an hour is at most 0.07%. The event-count tail reaches hours only through dust positions whose bonus barely covers gas, the same tail quantified in the processing section below. The exposure that the threshold must cover is therefore the work-off of a position rather than a clearing span. A liquidation call repays at most half the outstanding debt, so a large position clears through roughly five sequential calls, each landing on a feed publication. Across both stress events on Ethereum Core the value-weighted gap between consecutive calls on the same position had a median under one minute and a p95 of 15 to 21 minutes. One hour covers the work-off of the bulk of value with margin on every market examined, and Arbitrum and Base sit inside the Core distribution on every quantile. We therefore adopt a 1 hour work-off window as the basis for both families.

### Liquidation processing

The window above measures how long a position stays exposed. Processing speed measures how quickly liquidators act once a feed publication makes a position liquidatable. We measured the lag between each liquidation and the most recent publication of either leg of its pair on Aave V3 Ethereum Core, Arbitrum, and Base across the two largest stress events of the observation period. Ethereum is joined against the SVR publications Aave reads where they were live, which is October 2025, and against the pre-SVR standard aggregators in February 2025.

| Event                  | Market        | Liquidations | Seized | Median lag |  p75 |      p95 | Volume within 1 min | Volume within 5 min |
| ---------------------- | ------------- | -----------: | -----: | ---------: | ---: | -------: | ------------------: | ------------------: |
| February 2 to 4, 2025  | Ethereum Core |          936 |  $172M |       24 s | 51 s | 10.3 min |                 95% |                100% |
| February 2 to 4, 2025  | Arbitrum      |        1,511 |   $15M |        6 s | 17 s |     57 s |                100% |                100% |
| February 2 to 4, 2025  | Base          |        1,435 |    $9M |       10 s | 28 s |  2.0 min |                 99% |                100% |
| October 10 to 12, 2025 | Ethereum Core |          430 |  $100M |       36 s | 72 s |  6.0 min |                 63% |                100% |
| October 10 to 12, 2025 | Arbitrum      |          346 |   $17M |        1 s | 10 s |     23 s |                100% |                100% |
| October 10 to 12, 2025 | Base          |          392 |    $6M |        2 s |  4 s |  2.8 min |                100% |                100% |

_Source: LlamaRisk, August 29, 2026_

Liquidations execute at feed speed even at peak congestion. Nearly all seized volume clears within five minutes of the publication that made it profitable, so liquidator responsiveness is not the binding constraint on the parameters. Arbitrum and Base, whose feeds print on tighter deviations and whose execution gas is negligible, clear faster than Ethereum Core with no lag tail at all, so the Core benchmark is the conservative one for the markets receiving the proposed increases.

The latency tail consists almost entirely of dust positions. Broken down by lag behind the triggering publication on Ethereum Core across both stress windows, liquidations slower than five minutes were 11.1% of events but 0.23% of seized volume. The residual sub-hour maxima are dust positions whose bonus barely covers mainnet gas, together with positions pushed over the threshold by interest accrual between publications rather than by a fresh print.

| Lag behind print | Events | Share of events | Share of seized USD | Median size |
| ---------------- | -----: | --------------: | ------------------: | ----------: |
| under 1 min      |    967 |           70.8% |               78.6% |     $21,833 |
| 1 to 5 min       |    248 |           18.2% |               21.2% |     $16,958 |
| 5 to 15 min      |    112 |            8.2% |                0.2% |        $993 |
| over 15 min      |     39 |            2.9% |                0.0% |        $341 |

Liquidators clear economically meaningful positions at feed speed and defer only positions where the bonus barely covers gas. The processing tail therefore carries no bad debt relevance.

Fast processing does not mean a position is cleared at its first touch of the threshold. A liquidation call repays at most half of the outstanding debt, resets the health factor slightly above one, and leaves the remainder exposed to the next leg down. In the February event, 32% of liquidated users across all deployments were liquidated more than once, and these users accounted for 64% of all seized volume, with a median of 3.5 hours between a user's first and last liquidation and a p90 of roughly 10 hours.

_Source: LlamaRisk, August 29, 2026_

Both events cleared with negligible bad debt. February produced no recognized deficit at all, and October produced $0.39M against roughly $128M, without affecting the ETH- and BTC-family collateral across all deployments. The liquidation machinery has held through both stress events at current parameters.

### Liquidation bonus

The liquidation bonus is an input to the derivation. The threshold has to cover the tail move and the bonus paid to the liquidator, so a higher bonus mechanically supports a lower threshold at the same level of risk. Each reserve is therefore assessed at its own live bonus rather than a single assumed value. The same asset carries different bonuses on different deployments, with WBTC at 5.00% on Ethereum and 8.50% on Polygon, and that difference moves the supportable threshold by several points due to the impact to the bad debt buffer of the protocol.

### Parameter derivation

The model ceiling for the liquidation threshold is the largest value at which the collateral remaining after the basis move still covers the debt plus the bonus:

```
LT ceiling = round((1 - |p99.9 excursion|) / (1 + LB))
```

Each reserve is assessed at its recommended bonus where one is proposed and at its live bonus otherwise. Recommended thresholds are set relative to the ceiling: WETH at the ceiling, the rest of the ETH family one point inside it, and BTC at least three points inside it as margin against depth, cap, and concentration risks the price model does not capture.

In the open market every borrowable reserve is reachable from every collateral, so each collateral is assessed against every debt leg its deployment exposes and takes the lowest result.

## Calibration Results

### Realized tails and supported thresholds

All windows measured on the two-year deviation-threshold series, including February 2025. The 1 hour row is the basis for both families.

| Window          | ETH p99 | ETH p99.9 | ETH worst | BTC p99 | BTC p99.9 | BTC worst |
| --------------- | ------: | --------: | --------: | ------: | --------: | --------: |
| single print    |  -0.88% |    -1.66% |    -4.75% |  -0.71% |    -1.14% |    -3.44% |
| 5 min           |  -1.16% |    -3.09% |   -13.31% |  -0.63% |    -2.04% |    -5.61% |
| 15 min          |  -2.00% |    -6.28% |   -18.02% |  -1.19% |    -3.14% |    -8.45% |
| 30 min          |  -2.88% |   -11.75% |   -22.02% |  -1.72% |    -4.06% |   -10.08% |
| 1 h **(basis)** |  -3.94% |   -11.85% |   -24.27% |  -2.39% |    -5.03% |   -10.72% |
| 2 h             |  -5.19% |   -14.61% |   -26.24% |  -3.33% |    -6.28% |   -10.72% |
| 4 h             |  -7.10% |   -24.13% |   -28.43% |  -4.69% |    -7.44% |   -11.32% |
| 6 h             |  -8.63% |   -24.45% |   -29.25% |  -5.61% |    -9.55% |   -12.77% |
| 12 h            | -12.46% |   -27.25% |   -33.64% |  -6.88% |   -13.78% |   -16.38% |
| 1 d             | -16.73% |   -29.74% |   -35.06% |  -9.89% |   -17.05% |   -19.75% |

_Source: LlamaRisk, August 29, 2026_

The chart below plots the model ceiling at each work-off window across the live bonus range, with the 1 hour basis marked.

_Source: LlamaRisk, August 29, 2026_

The basis covers any 1 hour excursion up to the 99.9th percentile of the two-year record, which spans the whole of the October 2025 event and all but the core legs of February 3, 2025, and it relies on the measured liquidation cadence keeping position marks seconds to minutes fresh. The residual scenario outside the basis is a maximally levered position marked at its threshold at the start of a move beyond that percentile, with no liquidation landing for the full hour. Reaching it requires the oracle cadence and the liquidation pipeline to stall together through the worst 0.1% hour of two years, which did not happen in either stress event, where calls landed at a median of 24 seconds behind their triggering publication throughout.

### wstETH and weETH

The two established LSTs warrant a similar empirical treatment as the canonical wrappers. Across the two years to August 2026 they account for 6,486 liquidations and roughly $361M of seized collateral across all deployments, $296M of it wstETH and $47M weETH, overwhelmingly against stablecoin debt. Processing speed during both stress events was indistinguishable from WETH. On Ethereum Core the median lag behind the triggering publication was 12 s for LST collateral against 24 s for WETH in February 2025, and 72 s against 24 s in October 2025 on the sparser SVR publications, with lower p95 values than WETH in both events. The liquidation pipeline treats them as blue-chip collateral in practice.

Instant exit liquidity, quoted through aggregate routing against the on-chain redemption rate, supports the same conclusion within the sizes the protocol has actually needed.

_Source: LlamaRisk, August 29, 2026_

wstETH exits at under 0.05% discount up to roughly $24M and 0.55% at $47M, with the route exhausting beyond about $55M. weETH exits at under 0.25% up to roughly $21M and exhausts beyond about $25M. For comparison, the entire February 2025 cascade seized $39M of LST collateral on Ethereum Core spread over several hours, well inside these depths.

On this evidence both assets are assessed on the measured ETH basis, and their processing and depth place them in the same tier as WETH. Against live settings of 81% and 80%, we recommend raising wstETH to 82% and weETH to 81% on Ethereum, each one point inside the ceiling at its live bonus, and WETH to 84%, at its ceiling. The conservatism in weETH's configuration sits in its 7.00% bonus against wstETH's 6.00% despite comparable processing speed and depth proportionate to its supply.

## Specification

### Arbitrum

| Asset | Current LTV | Current LT |    LB | Recommended LTV | Recommended LT | Borrowable assets            |
| ----- | ----------: | ---------: | ----: | --------------: | -------------: | ---------------------------- |
| WETH  |       80.0% |      84.0% | 5.00% |         **81%** |              - | WBTC, WETH, GHO, USDC, USD₮0 |
| WBTC  |       73.0% |      78.0% | 7.00% |         **78%** |        **82%** | WBTC, WETH, GHO, USDC, USD₮0 |

### Base

| Asset | Current LTV | Current LT |    LB | Recommended LTV | Recommended LT | Recommended LB | Borrowable assets            |
| ----- | ----------: | ---------: | ----: | --------------: | -------------: | -------------: | ---------------------------- |
| WETH  |       80.0% |      83.0% | 5.00% |         **81%** |        **84%** |          **-** | WETH, cbBTC, EURC, GHO, USDC |
| cbBTC |       73.0% |      78.0% | 7.50% |         **81%** |        **84%** |      **6.00%** | WETH, cbBTC, EURC, GHO, USDC |

Due to robust cbBTC liquidity on Base (~$33M in stables) we also recommend lowering liquidation bonus to 6.00%.

**E-Mode**

| Asset | E-Mode            | Category ID | Current LTV | Current LT |    LB | Recommended LTV | Recommended LT | Borrowable assets |
| ----- | ----------------- | ----------: | ----------: | ---------: | ----: | --------------: | -------------: | ----------------- |
| cbBTC | cbBTC Stablecoins |          10 |       80.0% |      83.0% | 4.00% |         **82%** |        **85%** | GHO, USDC         |

### Ethereum Core

| Asset  | Current LTV | Current LT |    LB | Recommended LTV | Recommended LT |
| ------ | ----------: | ---------: | ----: | --------------: | -------------: |
| WETH   |       80.5% |      83.0% | 5.00% |         **81%** |        **84%** |
| WBTC   |       73.0% |      78.0% | 5.00% |         **81%** |        **85%** |
| cbBTC  |       73.0% |      78.0% | 7.50% |         **81%** |        **85%** |
| wstETH |       78.5% |      81.0% | 6.00% |         **79%** |        **82%** |
| weETH  |       77.5% |      80.0% | 7.00% |         **78%** |        **81%** |

Liquidation bonuses on Ethereum Core stay at their current values, including the 7.50% bonus on cbBTC, even though the depth that supports a 6.00% bonus on Base is also present on Ethereum. An increase to the liquidation protocol fee for these assets on Ethereum Core is pending. The protocol fee is taken out of the liquidation bonus, so lowering the bonus at the same time would reduce the liquidator's net share from both sides.

### Aave V4 Ethereum Main Spoke

The Main Spoke is the V4 counterpart of the V3 Ethereum Core market and is assessed identically, on the same basis and with each reserve at its recommended maximum liquidation bonus where one is proposed and at its live maximum otherwise, with WETH, WBTC, and cbBTC as volatile debt alongside deep stablecoins.

| Asset  | Current CF | Max LB | Recommended CF | Recommended Max LB |
| ------ | ---------: | -----: | -------------: | ------------------ |
| WETH   |      83.0% |  5.55% |        **84%** | -                  |
| wstETH |      80.0% |  6.66% |        **82%** | -                  |
| weETH  |      80.0% |  7.77% |        **81%** | -                  |
| WBTC   |      78.0% |  5.55% |        **85%** | -                  |
| cbBTC  |      78.0% |  5.55% |        **85%** | -                  |

For the CF changes, we recommend performing a configuration update instead of deploying a new collateral configuration.

## Implementation details

The payload updates dynamic configuration key 0 for WETH, WBTC, and cbBTC, and key 2 for wstETH and weETH. Earlier wstETH and weETH configurations remain unchanged. Positions using an earlier configuration adopt the current key when borrowing more.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Base_ETHAndBTCCollateralEfficiency_20261016.sol), [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Base_ETHAndBTCCollateralEfficiency_20261016.t.sol), [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x0845fbf2d49ec5ad85f8a569e51ce7014f6f4c6dfc34e3b6cd28ef3f9037d586)
- [Discussion](https://governance.aave.com/t/arfc-revision-of-eth-btc-collateral-efficiency-on-aave/25649)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
