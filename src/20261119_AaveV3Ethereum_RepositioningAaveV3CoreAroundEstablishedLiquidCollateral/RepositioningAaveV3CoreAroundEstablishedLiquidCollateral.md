---
title: "Repositioning Aave V3 Core Around Established & Liquid Collateral"
author: "LlamaRisk"
discussions: "https://governance.aave.com/t/arfc-repositioning-aave-v3-core-around-established-liquid-collateral/26191"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0x7ed3e17373060128618599b425fd0b4312bea86fcd903a1aa99c2622403f7f98"
---

## Simple Summary

LlamaRisk proposes to reposition Aave V3 Core as an instance for liquid, bluechip collateral, while the broader range of asset classes is served by Aave V4, where the Risk Premium parameter prices the additional risk each collateral asset carries and more flexible isolation levers exist. The proposal is the next step of the deprecation work that wound down low-adoption reserves and instances and deprecated the price feeds of long-tail assets.

The proposal covers rsETH, osETH, LBTC, tBTC and rETH on Core, together with a group of lower-exposure reserves. As of 9 November 2026 these assets held $1.33B of collateral backing $1.03B of debt.

The initial measure is to freeze each reserve in scope, which stops new supply and sets the LTV to zero while leaving existing positions untouched. Borrowable reserves on Core that are frozen, or frozen by this ARFC, and still carry more than $20k of debt also have their reserve factor raised to 99%. LlamaRisk will then work with each asset issuer and with the largest borrowers on an orderly migration, and allow positions to unwind naturally before taking any further action. The proposal also approves a defined range of follow-up controls, including stepwise liquidation threshold reductions and, as the final step of the process, interest rate adjustments with targeted rebates, to be applied through Risk Stewards or Direct-to-AIP proposals only where exposure does not migrate within the next months.

## Motivation

Aave V3 Core pools liquidity across every listed asset, so each WETH and stablecoin supplier underwrites every collateral asset at the same pooled borrow rate. Over time, a growing share of Core collateral has come to depend on layers that sit outside the token, such as restaking services, leveraged strategies, cross-chain bridges and custodial arrangements. Each layer adds failure modes that are harder to enforce, while the additional spread these assets generate accrues to the borrowers looping them rather than to the suppliers.

The repositioning moves Core away from restaking exposure, leveraged wrapping strategies, derivatives strategies in the backing, custom non-custodial bridge designs, issuers whose operational and security resourcing is not commensurate with their exposure on Core under the Aave Risk Framework, and reserves with limited demand on Core. It also reduces the footprint of external dependencies that Core relies on, since each reserve brings its own issuer contracts, bridges, signer sets and oracle feeds.

The repositioned Core serves WETH, the liquid staking tokens wstETH, weETH and cbETH, WBTC and cbBTC, reserve-backed and CDP stablecoins such as USDC, USDT, GHO and DAI, XAUt, AAVE and LINK, and retains the yield-bearing stablecoins listed today (USDe, sUSDe and syrupUSDT), which remain subject to the same criteria. Aave V4 provides the structure for the assets that move off Core: liquidity sits in hubs, collateral sits in spokes with their own caps, and the collateralRisk parameter adds a premium to the drawn rate in proportion to the risk of the collateral, so suppliers are paid for the risk they underwrite.

### Scope

Collateral in scope on Aave V3 Ethereum Core as of 9 November 2026. Debt is attributed pro rata to the borrower's collateral mix.

| Asset               | Collateral      | Debt backed | Borrowed    |
| ------------------- | --------------- | ----------- | ----------- |
| rsETH               | $661.8M         | $605.7M     | WETH        |
| osETH               | $279.4M         | $256.6M     | WETH        |
| LBTC                | $177.4M         | $72.1M      | Stablecoins |
| tBTC                | $117.4M         | $52.9M      | Stablecoins |
| rETH                | $81.8M          | $35.4M      | Stablecoins |
| eBTC                | $5.5M           | $2.1M       | Stablecoins |
| BTC.b               | $1.2M           | $0.5M       | Stablecoins |
| tETH                | $0.8M           | $0.3M       | Stablecoins |
| PT-srUSDe-22OCT2026 | $0.01M          | $0.01M      | Stablecoins |
| LDO                 | $0.06M          | $0.01M      | Stablecoins |
| mUSD                | Borrowable only | -           | -           |

rsETH and osETH back $862M of WETH debt, almost entirely through leveraged loops in ETH-correlated E-Modes at 12 to 14 times leverage. LBTC, tBTC and rETH back $160M of debt, mostly stablecoins, spread across several hundred addresses at moderate leverage and far from liquidation. The debt backed by the collateral in scope generates about $3.7M a year of gross DAO revenue at the realized borrow rates of the past three months.

### Approach

The repositioning reduces exposure gradually and without forced liquidations, in three stages:

1. **Initial measures.** This ARFC freezes each reserve in scope, which sets its LTV to zero including in every E-Mode the asset belongs to. Existing positions remain open, and holders can repay, withdraw or migrate at any time. Collateral that remains on Core is added to the E-Modes in which the assets in scope are borrowed against, so borrowers can swap collateral within their existing E-Mode. The reserve factor of every frozen, borrowable reserve that still carries more than $20k of debt is raised to 99%.
2. **Issuer engagement and natural unwinding.** LlamaRisk works with each asset issuer and with the largest borrowers on an orderly migration into collateral that remains on Core or into Aave V4. No further measure is applied to an asset while its exposure declines.
3. **Follow-up controls.** Where exposure does not decline, the controls approved below are applied through Risk Stewards or Direct-to-AIP proposals within the approved ranges. A borrow rate increase is considered only as the final step of the process. No abrupt parameter change that would liquidate significant positions will be made.

### Follow-up controls

Approved by this ARFC for the assets in scope and applied only where exposure does not decline after the initial measures. Each step is executed through the Risk Stewards where it falls within their bounds, and through a Direct-to-AIP proposal otherwise, and is announced on the forum beforehand. They are outside this payload.

| Control                                    | Applies to                           | Approved range                                                                                                                                                                                                                                           | Execution                                               |
| ------------------------------------------ | ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Liquidation threshold reduction            | LBTC, tBTC, rETH                     | Steps of up to 2 percentage points within Risk Steward limits, each sized so that collateral becoming liquidatable stays below $2M or 5% of the asset's remaining collateral                                                                             | Risk Stewards or Direct-to-AIP                          |
| Borrow rate increase with targeted rebates | WETH on Core (rsETH and osETH loops) | Base variable borrow rate increase of up to 100 bps in steps of 50 bps, at most monthly, with a reserve factor increase that holds the supply rate constant and a Merkl campaign rebating the increase to WETH borrowers without the affected collateral | Risk Stewards (rate) and Direct-to-AIP (reserve factor) |

## Specification

This payload implements the initial measures on Aave V3 Ethereum Core.

### Initial measures: Aave V3 Ethereum Core

Freezing a reserve sets its LTV to zero, including in every E-Mode the asset belongs to.

| Asset               | Current frozen | Recommended frozen | Current LTV                |
| ------------------- | -------------- | ------------------ | -------------------------- |
| rsETH               | Yes            | Yes                | 0%                         |
| osETH               | No             | Yes                | 0% (93% in E-Mode)         |
| LBTC                | No             | Yes                | 70% (84% in E-Mode)        |
| tBTC                | Yes            | Yes                | 0%                         |
| rETH                | No             | Yes                | 75% (93% in E-Mode)        |
| eBTC                | No             | Yes                | 67% (83% in E-Mode)        |
| BTC.b               | No             | Yes                | 73%                        |
| tETH                | No             | Yes                | 0% (72% in E-Mode)         |
| PT-srUSDe-22OCT2026 | No             | Yes                | 0% (90% and 92% in E-Mode) |
| LDO                 | No             | Yes                | 0%                         |
| mUSD                | No             | Yes                | n/a                        |

### Reserve factor

The reserve factor of each borrowable reserve on Core that is frozen, or frozen by this ARFC, and still carries more than $20k of debt is raised to 99%. LUSD, RPL and FRAX already carry a 100% reserve factor and are unchanged.

| Asset  | Debt    | Current frozen | Current RF | Recommended RF |
| ------ | ------- | -------------- | ---------- | -------------- |
| CRV    | $237.8k | Yes            | 50%        | 99%            |
| tBTC   | $185.6k | Yes            | 50%        | 99%            |
| rETH   | $101.1k | No             | 15%        | 99%            |
| crvUSD | $75.7k  | Yes            | 50%        | 99%            |
| FBTC   | $74.7k  | Yes            | 75%        | 99%            |
| UNI    | $33.5k  | Yes            | 50%        | 99%            |
| mUSD   | $21.2k  | No             | 20%        | 99%            |

### E-Mode changes

| E-Mode                    | Current collateral                      | Current borrowable | Collateral added                        | Borrowable removed | LTV / LT  |
| ------------------------- | --------------------------------------- | ------------------ | --------------------------------------- | ------------------ | --------- |
| rsETH / ETH, wstETH, ETHx | rsETH                                   | WETH, wstETH, ETHx | wstETH, weETH, cbETH                    | wstETH             | 93% / 95% |
| ETH correlated            | osETH, rETH, cbETH, wstETH, weETH, WETH | WETH               | None (retained assets already included) | None               | 93% / 95% |

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261119_AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral/AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261119_AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral/AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x7ed3e17373060128618599b425fd0b4312bea86fcd903a1aa99c2622403f7f98)
- [Discussion](https://governance.aave.com/t/arfc-repositioning-aave-v3-core-around-established-liquid-collateral/26191)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
