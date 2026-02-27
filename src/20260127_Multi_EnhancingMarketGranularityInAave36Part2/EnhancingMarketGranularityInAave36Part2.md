---
title: "Enhancing Market Granularity in Aave 3.6: part 2"
author: "ChaosLabs (implemented by Aavechan Initiative @aci via Skyward)"
discussions: "https://governance.aave.com/t/direct-to-aip-enhancing-market-granularity-in-aave-v3-6-restricting-borrowability-and-collateralization-outside-of-liquid-emodes/23592"
---

## Simple Summary

This proposal leverages the configurability improvements introduced in [Aave v3.6](https://governance.aave.com/t/arfc-bgd-aave-v3-6/23172/2) to strengthen risk isolation and improve parameter clarity. Specifically, it introduces:

- LTV0 for assets not intended to serve as collateral outside of eModes.
- Non-borrowable status for assets whose use cases are restricted to within their respective eModes.
- Exclusive eMode participation, ensuring these assets are only active within targeted, high-correlation environments.

This aims to reduce systemic exposure, simplify risk management, and enable cleaner differentiation between general market assets and those intended for correlated or high-efficiency lending environments.

This AIP covers only the instances that were upgraded in part 2 and 3 of the 3.6 upgrade.

## Motivation

Aave v3.6 represents an inflection point in the protocol’s ability to model and manage granular risk domains. Historically, reserve-level configurations in Aave v3 (prior to 3.6) constrained risk management, as all eMode behaviors were inherited from the global market configuration. This coupling led to inefficiencies, forced workarounds, and limited the ability to cleanly separate correlated-asset risk from the general pool.

### **Legacy Limitation: Coupled Configurations**

Under Aave v3.0–v3.5, an asset’s global (base) configuration dictated its eMode behavior. Specifically:

- An asset had to be collateralized outside of eMode to be collateralized within it.
- Similarly, to be borrowable within an eMode, it had to be borrowable in the main pool.
- If an asset’s base configuration had LTV = 0, it was treated as LTV = 0 in every eMode, triggering LTV0 rules globally.

This architectural coupling meant that assets could not be scoped to eMode-specific roles, e.g., collateral-only inside an eMode, or borrow-only within one. To accommodate, risk management often used low but nonzero LT values, which was not feasible for alternative assets with effective non-zero collateral values outside of E-mode, if and when reserves need updating in the future, or enabled borrowability globally with no practical use case, introducing unnecessary systemic exposure.

### **Emerging Complexity: Cross-Asset and Cross-Market Contagion**

As Aave’s markets evolved with Liquid Staking Tokens (LSTs), Liquid Restaking Tokens (LRTs), and Principal Tokens (PTs), risk dependencies grew more complex.

Many of these assets are highly correlated with ETH or stablecoins and are designed to operate only within structured environments, where both collateral and borrowing assets adhere to tight risk parameters (e.g., the LST eMode).

Without configuration independence, some of these tokens remain borrowable in the general market even though demand exists exclusively within the eMode (e.g., borrowing wstETH only makes sense against rsETH, not against AAVE). Their presence as general borrowables artificially expands the exposure surface and increases the potential for recursive or unintended leverage. Their collateral eligibility outside of eModes complicates the dynamics of liquidation, volatility sensitivity, and the effective exposure of liquidity to the weakest links of the system.

### **Risk Management Efficiency**

The inability to enforce LTV0 selectively has long been a point of friction for both risk managers and integrations.

Risk management often relied on LTV0 flags to gradually deprecate or isolate assets, e.g., to offboard an asset from a specific eMode or phase out its collateral use. Under the old model, setting LTV0 outside of an eMode would cascade that rule across all modes, making targeted adjustments impossible.

With v3.6 introducing per-eMode `ltvzerobitmap`, Aave can now:

- Flag specific assets as LTV0 outside eModes (fully removing their collateral role in the main pool).
- Keep them collateralizable within eModes where risk conditions are known and bounded.
- Effectively migrate eMode risk configurations via setting LTV0 of an existing Emode and creating a new Emode with a lower LT, thereby not affecting existing users within the E-mode while subjecting new users to the updated config.

This enables Aave to evolve into a multi-environment structure, where the “main pool” functions as a conservative liquidity base layer, and eModes serve as risk-contained, higher-efficiency sub-markets, allowing independent caps, parameters, and monitoring per eMode without interference from the base layer.
In line with this efficiency, we provide the following specifications for relevant risk parameter optimizations at the protocol level, made possible by the launch of v3.6, aiming to minimize tail risks while minimizing the impact on protocol revenue.

## Specification

### Volatile Asset Collateral

This section outlines volatile assets whose configurations were unaffected by the recent [asset deprecations](https://governance.aave.com/t/arfc-deprecation-of-low-demand-volatile-assets-on-aave-v3-instances/23261) and which should be treated as uncollateralizable outside of E-Mode. For assets where the vast majority of activity is driven by use cases such as borrowing stablecoins, we recommend implementing bespoke E-Modes to maximize demand while minimizing effective hypothetical exposure to these assets within the markets. Additionally, many of these assets have become increasingly illiquid over time, making them operationally unfeasible and economically risky to support as viable collateral options.

In the “aggregate demand impacted” column, we outline the nominal collateral utilization stemming from either outside the proposed emode configuration, outside current emode configurations, or in aggregate if no emode is specified or currently exists.

| **Asset** | **Instance**  | **Current isCollateral (base)** | **Recommended isCollateral (base)** | **New Emodes**   | **Aggregate Demand Impacted** |
| --------- | ------------- | ------------------------------- | ----------------------------------- | ---------------- | ----------------------------- |
| AAVE      | Base          | TRUE                            | FALSE                               | Aave/stablecoins | $ 73,011.62                   |
| AAVE      | Arbitrum      | TRUE                            | FALSE                               | Aave/stablecoins | $ 675,042.57                  |
| AAVE.e    | Avalanche     | TRUE                            | FALSE                               |                  | $ 23,627.03                   |
| ARB       | Arbitrum      | TRUE                            | FALSE                               | ARB/stablecoins  | $ 203,046.23                  |
| LINK      | Arbitrum      | TRUE                            | FALSE                               |                  | $ 608,475.89                  |
| LINK      | Ethereum Core | TRUE                            | FALSE                               | LINK/stablecoins | $ 3,726,090.68                |
| LINK.e    | Avalanche     | TRUE                            | FALSE                               |                  | $ 707,688.37                  |
| LINK      | Polygon       | TRUE                            | FALSE                               |                  | $ 1,840,392.91                |
| MaticX    | Polygon       | TRUE                            | FALSE                               |                  | $ 126,233.78                  |
| AAVE      | Polygon       | TRUE                            | FALSE                               | Aave/stablecoins | $ 44,900.88                   |

### New Emode Configurations (Volatile Asset Collateral)

**LINK Stablecoins Ethereum Core**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | LINK      | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 66%       | -         |           |
| Liquidation Threshold | 71%       | -         |           |
| Liquidation Bonus     | 7%        | -         |           |

**AAVE Stablecoins Base**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | AAVE      | USDC      | GHO       |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 63%       | -         |           |
| Liquidation Threshold | 70%       | -         |           |
| Liquidation Bonus     | 10%       | -         |           |

**AAVE Stablecoins Arbitrum**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | AAVE      | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 66%       | -         |           |
| Liquidation Threshold | 73%       | -         |           |
| Liquidation Bonus     | 10%       | -         |           |

**AAVE Stablecoins Polygon**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | AAVE      | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 63%       | -         |           |
| Liquidation Threshold | 70%       | -         |           |
| Liquidation Bonus     | 7.5%      | -         |           |

**ARB Stablecoins Arbitrum**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | ARB       | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 58%       | -         |           |
| Liquidation Threshold | 63%       | -         |           |
| Liquidation Bonus     | 10%       | -         |           |

### Low-demand collateral (outside of emode)

A subset of blue-chip assets, primarily representations of underlying assets such as LSTs, LRTs, and tokenized BTC, exhibit consistently low demand when used as collateral outside of their designated E-Modes. While these assets are fundamentally robust, their utility within the protocol is highly concentrated in a narrow, well-defined set of use cases. Beyond these contexts, they see little to no collateral uptake, resulting in inefficient parameterization and unnecessary residual risk.

Maintaining these assets as general-purpose collateral exposes the protocol to external debt dynamics, including hypothetical arbitrage activity and fundamental deviations driven by exogenous factors. Given the absence of meaningful organic demand and the asymmetric risk profile this introduces, it is prudent to pursue depreciation of their collateral functionality outside of E-Mode. For assets where the vast majority of activity is driven by use cases such as borrowing stablecoins, we recommend implementing bespoke E-Modes to maximize demand while minimizing effective hypothetical exposure to these assets within the markets.

| **Asset** | **Instance**  | **Current isCollateral (base)** | **Recommended isCollateral (base)** | **New Emodes**     | **Aggregate Demand Impacted**        |
| --------- | ------------- | ------------------------------- | ----------------------------------- | ------------------ | ------------------------------------ |
| ETHx      | Ethereum Core | TRUE                            | FALSE                               |                    | $ 792,341.26                         |
| rsETH     | Ethereum Core | TRUE                            | FALSE                               | rsETH/stablecoins  | $ 1,593,054.63                       |
| osETH     | Ethereum Core | TRUE                            | FALSE                               |                    | $ 2,054,443.12                       |
| tBTC      | Base          | TRUE                            | FALSE                               | tBTC/stablecoins   | $ 75,767.79                          |
| tBTC      | Arbitrum      | TRUE                            | FALSE                               | tBTC/stablecoins   | $ 1,748.66                           |
| LBTC      | Base          | TRUE                            | FALSE                               | LBTC/stablecoins   | $ 150,120.37                         |
| sUSDe     | Ethereum Core | TRUE                            | FALSE                               |                    | $ 1,690,688.84                       |
| USDe      | Ethereum Core | TRUE                            | FALSE                               |                    | $ 5,488,524.05 (predominantly PYUSD) |
| USDe      | Plasma        | TRUE                            | FALSE                               |                    | $ 8,400                              |
| EURC      | Avalanche     | TRUE                            | FALSE                               | EURC/stablecoins   | $ 634,695.36                         |
| EURC      | Base          | TRUE                            | FALSE                               | EURC/stablecoins   | $ 364,047.30                         |
| EURC      | Ethereum Core | TRUE                            | FALSE                               | EURC/stablecoins   | $ 361,514.30                         |
| ezETH     | Linea         | TRUE                            | FALSE                               | ezETH/stablecoins  | $ 13,591.68                          |
| wrsETH    | Linea         | TRUE                            | FALSE                               | wrsETH/stablecoins | -                                    |

### New Emode Configurations (Low-demand collateral (Outside of Emode))

**EURC Stablecoins Avalanche**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | EURC      | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 75%       | -         |           |
| Liquidation Threshold | 78%       | -         |           |
| Liquidation Bonus     | 5%        | -         |           |

**EURC Stablecoins Base**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | EURC      | USDC      | GHO       |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 75%       | -         |           |
| Liquidation Threshold | 78%       | -         |           |
| Liquidation Bonus     | 5%        | -         |           |

**EURC Stablecoins Ethereum Core**

| **Parameter**         | **Value** | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- | --------- |
| Asset                 | EURC      | USDC      | USDT      | GHO       |
| Collateral            | Yes       | No        | No        | No        |
| Borrowable            | No        | Yes       | Yes       | Yes       |
| Max LTV               | 75%       | -         |           |           |
| Liquidation Threshold | 78%       | -         |           |           |
| Liquidation Bonus     | 5%        | -         |           |           |

**rsETH Stablecoins Ethereum Core**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | rsETH     | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 75%       | -         |           |
| Liquidation Threshold | 78%       | -         |           |
| Liquidation Bonus     | 7.5%      | -         |           |

**ezETH Stablecoins Linea**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | ezETH     | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 72.5%     | -         |           |
| Liquidation Threshold | 75%       | -         |           |
| Liquidation Bonus     | 7.5%      | -         |           |

**LBTC Stablecoins Base**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | LBTC      | USDC      | GHO       |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 75%       | -         |           |
| Liquidation Threshold | 78%       | -         |           |
| Liquidation Bonus     | 5%        | -         |           |

**tBTC Stablecoins Base**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | tBTC      | USDC      | GHO       |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 72%       | -         |           |
| Liquidation Threshold | 75%       | -         |           |
| Liquidation Bonus     | 7.5%      | -         |           |

**tBTC Stablecoins Arbitrum**

| **Parameter**         | **Value** | **Value** | **Value** |
| --------------------- | --------- | --------- | --------- |
| Asset                 | tBTC      | USDC      | USDT      |
| Collateral            | Yes       | No        | No        |
| Borrowable            | No        | Yes       | Yes       |
| Max LTV               | 72%       | -         |           |
| Liquidation Threshold | 75%       | -         |           |
| Liquidation Bonus     | 7.5%      | -         |           |

### Low-demand Stablecoins

Low-demand stablecoins exhibit limited utility across the protocol, with minimal usage as collateral, low levels of borrowing activity, and shallow on-chain liquidity. As a result, these assets generate negligible revenue while introducing asymmetric risk relative to their contribution to the protocol. Given their low risk–reward profile, we recommend reevaluating their continued support under existing configurations by restricting or removing their collateral and/or borrowable eligibility. Such adjustments would ensure that protocol resources and risk parameters remain aligned with assets that provide meaningful utility and economic value.

| **Asset** | **Instance**  | **Current isBorrowable (base)** | **Recommended isBorrowable (base)** | **Current isCollateral (base)** | **Recommended isCollateral (base)** | **Aggregate Demand Impacted** | **Aggregate Collateral Utilization** |
| --------- | ------------- | ------------------------------- | ----------------------------------- | ------------------------------- | ----------------------------------- | ----------------------------- | ------------------------------------ |
| FDUSD     | BNB           | TRUE                            | FALSE                               | TRUE                            | FALSE                               | $1,126,467.10                 | $45,163                              |
| USDC.e    | Arbitrum      | TRUE                            | FALSE                               | TRUE                            | FALSE                               | $1,331,285.30                 | $80,439                              |
| USDbC     | Base          | TRUE                            | FALSE                               | TRUE                            | FALSE                               | $423,559.73                   | $115,060                             |
| FRAX      | Avalanche     | TRUE                            | FALSE                               | TRUE                            | FALSE                               | $9,089.91                     | $193                                 |
| USDC.e    | Polygon       | TRUE                            | FALSE                               |                                 |                                     | $4,264,694.03                 |                                      |
| sDAI      | Ethereum Core |                                 |                                     | TRUE                            | FALSE                               |                               | $158,437                             |

### LST/wrapper borrowing outside of emode

The introduction of LSTs and wrapped BTC derivatives has led to highly specialized, correlated borrowing demand for such assets, stemming from both ETH LRT and BTC LST collateral. Under the current configuration, these assets remain borrowable by the broader pool, inadvertently expanding the hypothetical risk surface. The following changes prevent unnecessary exposure and simplify the borrow market, particularly for tokens whose demand originates from correlation-driven use cases (e.g., LSTs, LRTs).

| **Asset** | **Instance**   | **Current isBorrowable (base)** | **Recommended isBorrowable (base)** | **Aggregate Demand Impacted** |
| --------- | -------------- | ------------------------------- | ----------------------------------- | ----------------------------- |
| wstETH    | Arbitrum       | TRUE                            | FALSE                               | $219,631.96                   |
| wstETH    | Polygon        | TRUE                            | FALSE                               | $136,418.14                   |
| wstETH    | Ethereum Core  | TRUE                            | FALSE                               | $8,369,034.52                 |
| wstETH    | Ethereum Prime | TRUE                            | FALSE                               | $ -                           |
| wstETH    | Linea          | TRUE                            | FALSE                               | $50,083.17                    |
| tBTC      | Base           | TRUE                            | FALSE                               | $15,287.88                    |
| cbETH     | Base           | TRUE                            | FALSE                               | $203,093.89                   |
| wstETH    | Base           | TRUE                            | FALSE                               | $169,108.87                   |
| cbETH     | Ethereum Core  | TRUE                            | FALSE                               | $58,977.19                    |
| FBTC      | Ethereum Core  | TRUE                            | FALSE                               | $156,748.08                   |
| WPOL      | Polygon        | TRUE                            | FALSE                               | $240,543.50                   |

### Isolated Borrowing Config Optimization

Another benefit of the v3.6 implementation is the fact that migration outside isolation mode to approximate similar yet constrained behavior becomes possible. Specifically, an asset can be configured to remove collateral status from the base configuration while simultaneously creating a stablecoin Emode configuration. By contrast, migration out of isolation mode previously implied that, unless users were forcibly liquidated to achieve the same outcome, the protocol would be subjected to an increased risk surface area due to exposure to all collateral (cross-margin) and debt assets in the reserve, at equivalent risk parameterization for that of the isolation mode config.

As such, this section removes the isolation mode status of XAUt and XAUt0 on Ethereum Core and Plasma deployments, and initializes an Emode configuration with isolated exposure to stablecoin borrowing.

| **Asset** | **Instance**  | **Current isCollateral (base)** | **Recommended isCollateral (base)** | **Additional Information**                    |
| --------- | ------------- | ------------------------------- | ----------------------------------- | --------------------------------------------- |
| XAUt      | Ethereum Core | TRUE                            | FALSE                               | remove isolation mode XAUT0 stablecoins emode |
| XAUt0     | Plasma        | TRUE                            | FALSE                               | remove isolation mode XAUT0 stablecoins emode |

### New Emodes (Isolated Borrowing Config Optimization)

**XAUt Stablecoins Ethereum Core**

| **Parameter**         | **Value** | **Value** | Value | **Value** |
| --------------------- | --------- | --------- | ----- | --------- |
| Asset                 | XAUt      | USDC      | USDT  | GHO       |
| Collateral            | Yes       | No        | No    | No        |
| Borrowable            | No        | Yes       | Yes   | Yes       |
| Max LTV               | 70%       | -         |       |           |
| Liquidation Threshold | 75%       | -         |       |           |
| Liquidation Bonus     | 6%        | -         |       |           |

**XAUt0 Stablecoins Plasma**

| **Parameter**         | **Value** | **Value** |
| --------------------- | --------- | --------- |
| Asset                 | XAUt0     | USDT      |
| Collateral            | Yes       | No        |
| Borrowable            | No        | Yes       |
| Max LTV               | 70%       | -         |
| Liquidation Threshold | 75%       | -         |
| Liquidation Bonus     | 7.5%      | -         |

### Configuration Cleanup (Collateral)

Assets that are currently leveraging the 0.1% LT workaround outside of Emode. In the interest of protocol hygiene, we recommend nulling out its collateral status entirely.

| **Asset**          | **Instance**   | **Current isCollateral (base)** | **Recommended isCollateral (base)** | **Additional Information** |
| ------------------ | -------------- | ------------------------------- | ----------------------------------- | -------------------------- |
| PT-eUSDE-14AUG2025 | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-eUSDE-29MAY2025 | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-sUSDE-25SEP2025 | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-sUSDE-31JUL2025 | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-USDe-25SEP2025  | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-sUSDE-27NOV2025 | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-USDe-27NOV2025  | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| PT-USDe-31JUL2025  | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| ezETH              | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| sDAI               | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| sUSDe              | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| tETH               | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| MKR                | Ethereum Core  | TRUE                            | FALSE                               |                            |
| sUSDe              | Ethereum Prime | TRUE                            | FALSE                               | LT 0.1%                    |
| tETH               | Ethereum Prime | TRUE                            | FALSE                               | LT 0.1%                    |
| ezETH              | Ethereum Prime | TRUE                            | FALSE                               | LT 0.1%                    |
| rsETH              | Ethereum Prime | TRUE                            | FALSE                               | LT 0.1%                    |
| syrupUSDT          | Plasma         | TRUE                            | FALSE                               | LT 0.1%                    |
| weETH              | Plasma         | TRUE                            | FALSE                               | LT 0.1%                    |
| sUSDe              | Plasma         | TRUE                            | FALSE                               | LT 0.1%                    |
| rsETH              | Plasma         | TRUE                            | FALSE                               | LT 0.1%                    |
| ezETH              | Base           | TRUE                            | FALSE                               | LT 0.1%                    |
| wrsETH             | Base           | TRUE                            | FALSE                               | LT 0.1%                    |
| ezETH              | Arbitrum       | TRUE                            | FALSE                               | LT 0.1%                    |
| rsETH              | Arbitrum       | TRUE                            | FALSE                               | LT 0.1%                    |
| eUSDe              | Ethereum Core  | TRUE                            | FALSE                               | LT 0.1%                    |
| rsETH              | Avalanche      | TRUE                            | FALSE                               | LT 0.1%                    |

### Configuration Cleanup (Borrow)

While not directly a result of v3.6, assets that are currently leveraging the Borrow Cap 1 workaround outside of Emode. For the sake of protocol hygiene, we recommend disabling the borrowable status within the base configuration.

| **Asset** | **Instance**  | **Current isBorrowable (base)** | **Recommended isBorrowable (base)** | **Additional Information** |
| --------- | ------------- | ------------------------------- | ----------------------------------- | -------------------------- |
| ARB       | Arbitrum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| LINK      | Arbitrum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| LUSD      | Arbitrum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| rETH      | Arbitrum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| weETH     | Arbitrum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| LINK.e    | Avalanche     | TRUE                            | FALSE                               | Borrow Cap 1               |
| weETH     | Base          | TRUE                            | FALSE                               | Borrow Cap 1               |
| Cake      | BNB           | TRUE                            | FALSE                               | Borrow Cap 1               |
| wstETH    | BNB           | TRUE                            | FALSE                               | Borrow Cap 1               |
| 1INCH     | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| BAL       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| CRV       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| ENS       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| ETHx      | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| LDO       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| osETH     | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| rETH      | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| RPL       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| SNX       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| UNI       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| weETH     | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| MKR       | Ethereum Core | TRUE                            | FALSE                               | Borrow Cap 1               |
| weETH     | Linea         | TRUE                            | FALSE                               | Borrow Cap 1               |
| LINK      | Polygon       | TRUE                            | FALSE                               | Borrow Cap 1               |
| MaticX    | Polygon       | TRUE                            | FALSE                               | Borrow Cap 1               |
| rsETH     | Ethereum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| LUSD      | Arbitrum      | TRUE                            | FALSE                               | Borrow Cap 1               |
| EURS      | Polygon       | TRUE                            | FALSE                               | Borrow Cap 1               |

## References

- Implementation: [AaveV3Ethereum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Ethereum_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3EthereumLido](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3EthereumLido_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3Polygon](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Polygon_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3Avalanche](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Avalanche_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3Arbitrum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Arbitrum_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3Base](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Base_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3BNB](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3BNB_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3Linea](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Linea_EnhancingMarketGranularityInAave36Part2_20260127.sol), [AaveV3Plasma](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Plasma_EnhancingMarketGranularityInAave36Part2_20260127.sol)
- Tests: [AaveV3Ethereum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Ethereum_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3EthereumLido](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3EthereumLido_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3Polygon](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Polygon_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3Avalanche](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Avalanche_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3Arbitrum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Arbitrum_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3Base](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Base_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3BNB](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3BNB_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3Linea](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Linea_EnhancingMarketGranularityInAave36Part2_20260127.t.sol), [AaveV3Plasma](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260127_Multi_EnhancingMarketGranularityInAave36Part2/AaveV3Plasma_EnhancingMarketGranularityInAave36Part2_20260127.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-enhancing-market-granularity-in-aave-v3-6-restricting-borrowability-and-collateralization-outside-of-liquid-emodes/23592)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
