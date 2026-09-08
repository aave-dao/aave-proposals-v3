---
title: "Low Adoption Asset Deprecation on Aave V3"
author: "Llama Risk (implemented by Aave Labs)"
discussions: "https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401"
snapshot: "https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7"
---

## Simple Summary

LlamaRisk, together with the Aave service providers working on risk surface reduction, recommends offboarding a broad set of low-activity Aave V3 reserves along with six whole deployments. The following specification lists the current configuration of each reserve and the parameter changes required to wind it down.

The individual removals cover 49 reserves and 21 matured Pendle PTs across eleven deployments, holding $80.1M of supply and $11.5M of debt. The whole-market deprecations add 29 reserves across Sonic, Scroll, zkSync, Metis, Soneium and Aptos, holding $12.8M of supply and $4.1M of debt. A large share of the set is already in motion, with borrowing disabled, reserves frozen, or caps already reduced to 1 on most of it.

A further set of V3 reserves flagged for Chainlink price feed risk is being offboarded through the [companion oracle deprecation ARFC](https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400). Those reserves receive a freeze, caps of 1 and a fixed-price oracle there, so they are listed in the cross-reference section below and excluded from the tables and specification of this document.

## Motivation

This recommendation is part of a portfolio-level effort to reduce Aave's risk surface across deployments, applying the [Aave Risk Framework](https://governance.aave.com/t/arfc-aave-risk-framework/25114) rather than reacting to a problem with any single asset. Most reserves in scope are assets whose usage on Aave has remained below, or declined to, the level the framework requires for a standalone listing. Each listed reserve carries a fixed operational load regardless of its size: an oracle to maintain, risk parameters to monitor, and a liquidation path that must function reliably. Where a reserve's activity no longer justifies that load, it is wound down.

The scope also includes several structural cases. Bridged tokens such as USDC.e and USDbC are removed where the native version is listed and retained, so the same asset is not carried twice. MaticX is being sunset by its issuer. A group of Pendle Principal Tokens has passed maturity, after which the reserve serves no ongoing function. On six smaller deployments the assessment applies to the whole market rather than individual reserves: aggregate activity has declined to a level where the revenue the deployment generates does not cover the cost of supporting it, so the entire market is wound down at once.

### Wind-down mechanics

Each reserve is wound down so that exposure is removed while users exit in an orderly way and liquidation risk is minimised.

The default action on every reserve is to freeze it, reduce its supply and borrow caps to 1 and, on reserves that carry a borrow, raise the RF. The freeze blocks new supply, borrow, and use as fresh collateral. Raising the RF directs more of the borrow interest to the treasury, so suppliers earn less yield and withdraw their assets. As supply leaves, utilisation rises and borrowers are pushed to repay. For assets that are currently used as collateral, freezing the market stops new activity, but the positions already in place can remain open. Any effort to unwind those positions is discussed on a case-by-case basis. The next steps listed per reserve below reflect this default action and the current state of each reserve.

Beyond the default action, further levers may be applied depending on how each asset behaves, so they are deliberately not part of the per-reserve next steps:

- Where borrowers do not repay despite the raised reserve factor, the IRM curves are increased to make carrying a borrow more expensive.
- When it is deemed risky to keep the exposure, the Liquidation Threshold can be gradually reduced to deleverage the market, applied per asset when that is necessary to remove a lingering collateral position.

The whole-market deprecations apply the same approach to every reserve at once: each reserve is frozen with caps reduced to 1 and, where it is borrowed, the RF is raised to 99% and the IRM base rate is set to 5%, matching the initial rate step used in the oracle deprecation ARFC. We will reassess periodically whether further measures, such as raising the IRM further, are needed.

### Overlap with the oracle deprecation ARFC

The reserves of Aave V3 below qualify for this scope on adoption grounds but also carry a Chainlink price feed assessed at elevated risk. They are handled in the oracle deprecation ARFC, which freezes each reserve, reduces its caps to 1 and replaces the live feed with a fixed-price adapter. They are excluded from the specification of this document to avoid double-specifying the same reserves.

| Asset   | Instance  | Feed tier | Supplied | Borrowed |
| ------- | --------- | --------- | -------: | -------: |
| LUSD    | Ethereum  | Very High |    $2.0M |    $665k |
| RPL     | Ethereum  | High      |    $608k |    $212k |
| BAL     | Ethereum  | Very High |     $46k |      $3k |
| FRAX    | Ethereum  | Very High |     $38k |     $29k |
| KNC     | Ethereum  | High      |      $6k |      $1k |
| FXS     | Ethereum  | High      |      $1k |      $17 |
| LUSD    | Arbitrum  | Very High |    $192k |     $75k |
| FRAX    | Arbitrum  | Very High |    $170k |     $48k |
| MAI     | Arbitrum  | Very High |     $16k |      $13 |
| MAI     | Avalanche | Very High |     $21k |      $4k |
| FRAX    | Avalanche | Very High |      $7k |      $6k |
| LUSD    | Optimism  | Very High |     $26k |     $18k |
| MAI     | Optimism  | Very High |      $9k |      $3k |
| sUSD    | Optimism  | Very High |     $26k |     $12k |
| GHST    | Polygon   | Very High |     $31k |     $311 |
| miMATIC | Polygon   | Very High |      $9k |      $11 |
| BAL     | Polygon   | Very High |      $1k |     $450 |
| STG     | Ethereum  | Medium    |      $92 |       $2 |

USDm on Celo and SCR on Scroll are also covered by the oracle deprecation ARFC. SCR additionally falls under the Scroll whole-market deprecation below, where the deployment-wide parameter changes still apply.

### Live markets: individual reserve removals

#### Ethereum Core

The Ethereum Core scope is dominated by BTC liquid-staking wrapper FBTC, which holds $11.1M of supply against $63k of borrowing. CRV and UNI carry the largest remaining borrow balances in scope, with supply roughly halving over the same window, CRV from $4.2M to $2.2M and UNI from $4.1M to $1.7M. The remainder is a long tail of reserves below $250k, most of them already frozen, borrow-disabled or capped to 1, where this proposal formalises a wind-down that is already underway.

| Asset            | Supplied | Borrowed |  RF | State                                    | Borrowable | Collateral       | Reason           | Next steps                                        |
| ---------------- | -------: | -------: | --: | ---------------------------------------- | ---------- | ---------------- | ---------------- | ------------------------------------------------- |
| FBTC             |   $11.1M |     $63k | 50% | Active                                   | No         | General + E-Mode | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 75% |
| Matured PTs (15) |     $86k |       $0 |   - | Active, supply cap of 1                  | No         | E-Mode only      | Matured          | Freeze all and set caps to 1                      |
| CRV              |    $2.2M |    $238k | 35% | Active                                   | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| UNI              |    $1.7M |     $29k | 20% | Active                                   | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| crvUSD           |    $185k |     $78k | 20% | Active, supply cap of 1, borrow cap of 1 | Yes        | Non-collateral   | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| MKR              |    $175k |      $2k | 20% | Frozen, supply cap of 1, borrow cap of 1 | Yes        | General          | Limited adoption | Raise RF to 50%                                   |
| ETHx             |    $159k |     $650 | 15% | Active, supply cap of 1                  | No         | General + E-Mode | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| 1INCH            |    $154k |      $6k | 20% | Active                                   | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| ezETH            |    $111k |       $0 |   - | Active                                   | No         | General + E-Mode | Limited adoption | Freeze reserve and set caps to 1                  |
| ENS              |     $72k |      $5k | 20% | Active                                   | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| SNX              |     $59k |     $13k | 95% | Active, supply cap of 1                  | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 99% |
| sDAI             |     $50k |       $0 |   - | Active, supply cap of 1                  | No         | General          | Limited adoption | Freeze reserve and set caps to 1                  |
| eUSDe            |     $17k |       $0 | 45% | Active, supply cap of 1                  | No         | General + E-Mode | Limited adoption | Freeze reserve and set caps to 1                  |

#### Ethereum Prime

The Ethereum Prime instance is built around wstETH-collateralised WETH leverage, and the three reserves in scope never found a role in that structure. ezETH supply has fallen from $11.7M in late January to $337k as looping demand consolidated on other deployments. USDS holds $217k against $42k of borrowing and already has both caps at 1. sUSDe holds $46k and was never borrowable. USDS and sUSDe remain fully served by their Ethereum Core listings, where liquidity is materially deeper, and ezETH is already in the Ethereum Core scope of this proposal. The Prime listings therefore add operational load without adding usage.

| Asset | Supplied | Borrowed |  RF | State                                    | Borrowable | Collateral       | Reason                                           | Next steps                                        |
| ----- | -------: | -------: | --: | ---------------------------------------- | ---------- | ---------------- | ------------------------------------------------ | ------------------------------------------------- |
| ezETH |    $337k |       $0 | 15% | Active                                   | No         | General + E-Mode | Limited adoption                                 | Freeze reserve and set caps to 1                  |
| USDS  |    $217k |     $42k | 25% | Active, supply cap of 1, borrow cap of 1 | Yes        | Non-collateral   | Limited adoption, deeper market on Ethereum Core | Freeze reserve, set caps to 1 and raise RF to 50% |
| sUSDe |     $46k |       $0 | 10% | Active                                   | No         | General + E-Mode | Limited adoption, deeper market on Ethereum Core | Freeze reserve and set caps to 1                  |

#### Arbitrum

On Arbitrum the largest position is DAI, at $3.6M supplied and $2.5M borrowed, flagged for limited on-chain exit liquidity rather than inactivity, with supply down from $6.1M six months ago. rETH and tBTC hold a combined $3.7M with almost no borrowing against them. USDC.e is the bridged predecessor of native USDC and is removed as a duplicate listing, its supply declining from $1.8M to $1.1M as users migrate to the native version.

| Asset  | Supplied | Borrowed |  RF | State                            | Borrowable | Collateral       | Reason                                | Next steps                                        |
| ------ | -------: | -------: | --: | -------------------------------- | ---------- | ---------------- | ------------------------------------- | ------------------------------------------------- |
| DAI    |    $3.6M |    $2.5M | 25% | Active, borrow cap 4,410,000 DAI | Yes        | General + E-Mode | Limited liquidity                     | Freeze reserve, set caps to 1 and raise RF to 50% |
| rETH   |    $2.2M |     $35k | 15% | Active                           | No         | General          | Limited adoption                      | Freeze reserve, set caps to 1 and raise RF to 50% |
| tBTC   |    $1.4M |       $0 | 20% | Active                           | No         | General + E-Mode | Limited adoption                      | Freeze reserve and set caps to 1                  |
| USDC.e |    $1.1M |    $943k | 50% | Active                           | No         | General + E-Mode | Bridged USDC, native version retained | Freeze reserve, set caps to 1 and raise RF to 75% |
| ezETH  |    $150k |       $0 | 15% | Active                           | No         | General + E-Mode | Limited adoption                      | Freeze reserve and set caps to 1                  |
| EURS   |     $12k |      $6k | 20% | Frozen, borrow cap 65,000 EURS   | Yes        | General + E-Mode | Limited adoption                      | Set caps to 1 and raise RF to 50%                 |

#### Plasma

Plasma's in-scope balance is dominated by matured Pendle PTs at $32.2M, which no longer accrue yield and only await withdrawal. The two live reserves reflect the deployment's post-launch contraction: WETH supply has fallen from $47.2M to $2.1M and weETH from $277.5M to $1.1M over six months as launch-phase looping capital exited.

| Asset           | Supplied | Borrowed |  RF | State                                    | Borrowable | Collateral       | Reason                         | Next steps                                        |
| --------------- | -------: | -------: | --: | ---------------------------------------- | ---------- | ---------------- | ------------------------------ | ------------------------------------------------- |
| Matured PTs (6) |   $32.2M |       $0 |   - | Active, supply cap of 1                  | No         | E-Mode only      | Matured                        | Freeze all and set caps to 1                      |
| WETH            |    $2.1M |    $861k | 15% | Active, supply cap of 1, borrow cap of 1 | Yes        | General          | Limited adoption and liquidity | Freeze reserve, set caps to 1 and raise RF to 50% |
| weETH           |    $1.1M |       $0 | 20% | Active                                   | No         | General + E-Mode | Limited adoption and liquidity | Freeze reserve and set caps to 1                  |
| wstETH          |     $195 |       $1 | 35% | Frozen, borrow cap 5,000 wstETH          | Yes        | General + E-Mode | Limited adoption and liquidity | Set caps to 1 and raise RF to 50%                 |

#### Base

The Base scope is small: tBTC at $421k, with supply down from $836k over six months, the bridged USDbC removed as a duplicate of native USDC, and a dust ezETH reserve.

| Asset | Supplied | Borrowed |  RF | State  | Borrowable | Collateral       | Reason                                | Next steps                                        |
| ----- | -------: | -------: | --: | ------ | ---------- | ---------------- | ------------------------------------- | ------------------------------------------------- |
| tBTC  |    $421k |     $47k | 20% | Active | No         | General + E-Mode | Limited adoption                      | Freeze reserve, set caps to 1 and raise RF to 50% |
| USDbC |    $172k |    $125k | 50% | Active | No         | General          | Bridged USDC, native version retained | Freeze reserve, set caps to 1 and raise RF to 75% |
| ezETH |     $17k |       $0 | 15% | Active | No         | General + E-Mode | Limited adoption                      | Freeze reserve and set caps to 1                  |

#### Polygon

Polygon's scope is led by the bridged USDC.e at $3.4M supplied and $2.9M borrowed, removed as a duplicate of native USDC. EURS holds $1.9M and already sits at an RF of 99% from earlier deprecation steps. MaticX is wound down because Stader is sunsetting the token. The remaining six reserves are frozen dust positions below $40k each.

| Asset   | Supplied | Borrowed |  RF | State                            | Borrowable | Collateral       | Reason                                | Next steps                                        |
| ------- | -------: | -------: | --: | -------------------------------- | ---------- | ---------------- | ------------------------------------- | ------------------------------------------------- |
| USDC.e  |    $3.4M |    $2.9M | 60% | Active                           | No         | General + E-Mode | Bridged USDC, native version retained | Freeze reserve, set caps to 1 and raise RF to 85% |
| EURS    |    $1.9M |    $252k | 99% | Active, supply cap of 1          | No         | General + E-Mode | Limited adoption and liquidity        | Freeze reserve and set caps to 1                  |
| MaticX  |    $654k |      $5k | 20% | Active                           | No         | General + E-Mode | Issuer sunsetting the asset           | Freeze reserve, set caps to 1 and raise RF to 50% |
| DPI     |     $38k |      $4k | 35% | Frozen, borrow cap 779 DPI       | Yes        | General          | Limited adoption                      | Set caps to 1 and raise RF to 50%                 |
| stMATIC |     $16k |       $0 |   - | Frozen                           | No         | General + E-Mode | Limited adoption                      | Set caps to 1. Monitor, residual immaterial       |
| SUSHI   |     $17k |      $6k | 20% | Frozen, borrow cap 180,000 SUSHI | Yes        | General          | Limited adoption                      | Set caps to 1 and raise RF to 50%                 |
| CRV     |      $9k |     $416 | 35% | Frozen, borrow cap 300,000 CRV   | Yes        | General          | Limited adoption                      | Set caps to 1 and raise RF to 50%                 |
| EURA    |      $7k |      $2k | 20% | Frozen                           | No         | E-Mode only      | Limited adoption                      | Set caps to 1 and raise RF to 50%                 |
| jEUR    |      $4k |      $3k | 20% | Frozen, borrow cap 100,000 jEUR  | Yes        | E-Mode only      | Limited adoption                      | Set caps to 1 and raise RF to 50%                 |

#### Avalanche

The Avalanche scope consists of three bridged tokens, WBTC.e, LINK.e and AAVE.e, carrying minimal borrowing and exposure. For example, WBTC.e supply sits at $2.6M, down from $4.1M six months ago.

| Asset  | Supplied | Borrowed |  RF | State                           | Borrowable | Collateral | Reason           | Next steps                                        |
| ------ | -------: | -------: | --: | ------------------------------- | ---------- | ---------- | ---------------- | ------------------------------------------------- |
| WBTC.e |    $2.6M |    $122k | 20% | Frozen, borrow cap 1,100 WBTC.e | Yes        | General    | Limited adoption | Set caps to 1 and raise RF to 50%                 |
| LINK.e |    $824k |     $15k | 20% | Active                          | No         | General    | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| AAVE.e |    $154k |       $0 |   - | Active                          | No         | General    | Limited adoption | Freeze reserve and set caps to 1                  |

#### Optimism

On Optimism the bridged USDC.e, at $1.2M supplied and down from $2.0M six months ago, is removed as a duplicate of native USDC, while DAI and rETH carry a combined $1.1M with usage below the framework's thresholds.

| Asset  | Supplied | Borrowed |  RF | State                          | Borrowable | Collateral       | Reason                                | Next steps                                        |
| ------ | -------: | -------: | --: | ------------------------------ | ---------- | ---------------- | ------------------------------------- | ------------------------------------------------- |
| USDC.e |    $1.2M |    $303k | 50% | Active                         | No         | General + E-Mode | Bridged USDC, native version retained | Freeze reserve, set caps to 1 and raise RF to 75% |
| DAI    |    $617k |    $517k | 25% | Active, borrow cap 900,000 DAI | Yes        | General + E-Mode | Limited adoption                      | Freeze reserve, set caps to 1 and raise RF to 50% |
| rETH   |    $518k |      $1k | 15% | Active                         | No         | General + E-Mode | Limited adoption                      | Freeze reserve, set caps to 1 and raise RF to 50% |

#### Gnosis

GNO is excluded from this scope for now and will be treated separately. The remaining Gnosis reserves in scope are listed below.

WETH is the material Gnosis reserve at $3.2M supplied and $1.8M borrowed, with supply down from $7.8M over six months and borrowing already disabled. The legacy bridged USDC reserve is frozen with caps at 1 and only awaits the RF step.

| Asset | Supplied | Borrowed |  RF | State                                    | Borrowable | Collateral       | Reason           | Next steps                                        |
| ----- | -------: | -------: | --: | ---------------------------------------- | ---------- | ---------------- | ---------------- | ------------------------------------------------- |
| WETH  |    $3.2M |    $1.8M | 15% | Active                                   | No         | General + E-Mode | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| USDC  |    $142k |     $13k | 80% | Frozen, supply cap of 1, borrow cap of 1 | Yes        | General          | Limited adoption | Raise RF to 99%                                   |

#### BSC

The BSC scope holds wstETH, FDUSD and Cake, together $3.6M of supply. wstETH supply has fallen from $5.2M to $2.1M over six months and carries under $1k of borrowing, while FDUSD's $582k borrow is the only material debt in scope.

| Asset  | Supplied | Borrowed |  RF | State                   | Borrowable | Collateral       | Reason           | Next steps                                        |
| ------ | -------: | -------: | --: | ----------------------- | ---------- | ---------------- | ---------------- | ------------------------------------------------- |
| wstETH |    $2.1M |     $941 | 15% | Active, supply cap of 1 | No         | General + E-Mode | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| FDUSD  |    $858k |    $582k | 20% | Active                  | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| Cake   |    $636k |     $13k | 20% | Active                  | No         | General          | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |

#### MegaETH

WETH is excluded from this scope for now and will be treated separately. The two remaining in-scope reserves hold about $4k between them, so no supply history chart is included.

| Asset | Supplied | Borrowed |  RF | State                              | Borrowable | Collateral     | Reason           | Next steps                                        |
| ----- | -------: | -------: | --: | ---------------------------------- | ---------- | -------------- | ---------------- | ------------------------------------------------- |
| USDT0 |      $4k |      $3k | 10% | Active, borrow cap 9,000,000 USDT0 | Yes        | Non-collateral | Limited adoption | Freeze reserve, set caps to 1 and raise RF to 50% |
| ezETH |       $6 |       $0 | 20% | Active, supply cap of 1            | No         | E-Mode only    | Limited adoption | Freeze reserve and set caps to 1                  |

### Whole-market deprecations

Each deployment is wound down in full: every reserve is frozen with caps reduced to 1 and, on reserves that carry a borrow, the RF is raised to 99% and the IRM base rate is set to 5%. We will reassess periodically whether additional measures, such as raising the IRM further, are needed.

#### Sonic

Deposits on the Sonic deployment have fallen from $28.9M to $7.6M over the trailing six months, a decline of 74%, and $2.7M remains borrowed. At current balances, rates and reserve factors the deployment generates under $5k per quarter in protocol revenue, which does not cover the cost of maintaining oracles, monitoring and operational support for the market.

| Asset | Supplied | Borrowed |  RF | State                             | Borrowable | Collateral | Next steps                                                                 |
| ----- | -------: | -------: | --: | --------------------------------- | ---------- | ---------- | -------------------------------------------------------------------------- |
| USDC  |    $2.9M |    $1.6M | 10% | Active, borrow cap 1,050,000 USDC | Yes        | General    | Freeze reserve, set caps to 1, raise RF to 99% and set IRM base rate to 5% |
| wS    |    $1.7M |    $879k | 15% | Active, borrow cap 36,100,000 wS  | Yes        | General    | Freeze reserve, set caps to 1, raise RF to 99% and set IRM base rate to 5% |
| stS   |    $1.5M |       $0 | 10% | Active                            | No         | General    | Freeze reserve and set caps to 1                                           |
| WETH  |    $1.5M |    $249k | 15% | Active, borrow cap 97 WETH        | Yes        | General    | Freeze reserve, set caps to 1, raise RF to 99% and set IRM base rate to 5% |

#### Scroll

Deposits on the Scroll deployment have fallen from $16.1M to $2.2M over the trailing six months, a decline of 86%, and $422k remains borrowed. At current balances, rates and reserve factors the deployment generates under $5k per quarter in protocol revenue, which does not cover the cost of maintaining oracles, monitoring and operational support for the market.

| Asset  | Supplied | Borrowed |  RF | State                                    | Borrowable | Collateral       | Next steps                                  |
| ------ | -------: | -------: | --: | ---------------------------------------- | ---------- | ---------------- | ------------------------------------------- |
| WETH   |    $1.5M |    $169k | 50% | Frozen, supply cap of 1, borrow cap of 1 | Yes        | General + E-Mode | Raise RF to 99% and set IRM base rate to 5% |
| weETH  |    $312k |     $11k | 85% | Frozen, supply cap of 1                  | No         | General + E-Mode | Raise RF to 99% and set IRM base rate to 5% |
| USDC   |    $311k |    $226k | 85% | Frozen, supply cap of 1, borrow cap of 1 | Yes        | General          | Raise RF to 99% and set IRM base rate to 5% |
| wstETH |     $93k |     $17k | 85% | Frozen, supply cap of 1                  | No         | General + E-Mode | Raise RF to 99% and set IRM base rate to 5% |
| SCR    |     $14k |      $52 | 85% | Frozen, supply cap of 1                  | No         | Non-collateral   | Raise RF to 99% and set IRM base rate to 5% |

#### zkSync

Deposits on the zkSync deployment have fallen from $7.2M to $844k over the trailing six months, a decline of 88%, and $235k remains borrowed. At current balances, rates and reserve factors the deployment generates under $5k per quarter in protocol revenue, which does not cover the cost of maintaining oracles, monitoring and operational support for the market.

| Asset  | Supplied | Borrowed |  RF | State                   | Borrowable | Collateral       | Next steps                                                    |
| ------ | -------: | -------: | --: | ----------------------- | ---------- | ---------------- | ------------------------------------------------------------- |
| WETH   |    $383k |    $104k | 15% | Frozen, borrow cap of 1 | Yes        | General + E-Mode | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| ZK     |    $213k |     $138 | 20% | Frozen, borrow cap of 1 | Yes        | General          | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| USDC   |    $102k |    $112k | 10% | Frozen, borrow cap of 1 | Yes        | General          | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| weETH  |    $106k |       $0 | 45% | Frozen                  | No         | General + E-Mode | Set caps to 1. Monitor, residual immaterial                   |
| USDT   |     $22k |     $19k | 10% | Frozen, borrow cap of 1 | Yes        | General          | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| wstETH |     $18k |     $234 |  5% | Frozen, borrow cap of 1 | Yes        | General + E-Mode | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| wrsETH |      $71 |       $0 | 10% | Frozen, supply cap of 1 | No         | General + E-Mode | Monitor, residual immaterial                                  |
| sUSDe  |     $127 |       $0 | 20% | Frozen                  | No         | General          | Set caps to 1. Monitor, residual immaterial                   |

#### Metis

Deposits on the Metis deployment have fallen from $1.4M to $297k over the trailing six months, a decline of 79%, and $31k remains borrowed. At current balances, rates and reserve factors the deployment generates under $1k per quarter in protocol revenue, which does not cover the cost of maintaining oracles, monitoring and operational support for the market.

| Asset  | Supplied | Borrowed |  RF | State                   | Borrowable | Collateral | Next steps                                                    |
| ------ | -------: | -------: | --: | ----------------------- | ---------- | ---------- | ------------------------------------------------------------- |
| Metis  |     $77k |     $216 | 15% | Frozen, borrow cap of 1 | Yes        | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| m.USDT |     $82k |      $8k | 10% | Frozen, borrow cap of 1 | Yes        | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| m.USDC |     $74k |     $21k | 10% | Frozen, borrow cap of 1 | Yes        | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| WETH   |     $42k |      $2k | 15% | Frozen                  | No         | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| m.DAI  |     $21k |     $394 | 25% | Frozen                  | No         | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |

#### Soneium

Deposits on the Soneium deployment have fallen from $3.2M to $173k over the trailing six months, a decline of 95%, and $38k remains borrowed. At current balances, rates and reserve factors the deployment generates under $1k per quarter in protocol revenue, which does not cover the cost of maintaining oracles, monitoring and operational support for the market.

| Asset  | Supplied | Borrowed |  RF | State                               | Borrowable | Collateral | Next steps                                                    |
| ------ | -------: | -------: | --: | ----------------------------------- | ---------- | ---------- | ------------------------------------------------------------- |
| WETH   |    $124k |      $8k | 15% | Frozen, borrow cap 720 WETH         | Yes        | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| USDC.e |     $42k |     $30k | 10% | Frozen, borrow cap 7,200,000 USDC.e | Yes        | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |
| USDT   |      $7k |     $536 | 10% | Frozen, borrow cap 4,500,000 USDT   | Yes        | General    | Set caps to 1 and raise RF to 99% and set IRM base rate to 5% |

#### Aptos

Available liquidity across the Aptos reserves has moved from $18.0M to $1.0M over the trailing six months (-94%, DefiLlama pool TVL, supply net of borrows). The market carries about $1.7M of supply and $719k of debt, and at current balances and reserve factors it generates under $1k per quarter in protocol revenue, which does not cover the cost of maintaining the market.

| Asset | Supplied | Borrowed |  RF | State                           | Borrowable | Collateral       | Next steps                                                                 |
| ----- | -------: | -------: | --: | ------------------------------- | ---------- | ---------------- | -------------------------------------------------------------------------- |
| USDT  |    $1.2M |    $672k | 10% | Active, borrow cap 448,000 USDT | Yes        | General + E-Mode | Freeze reserve, set caps to 1, raise RF to 99% and set IRM base rate to 5% |
| APT   |    $351k |      $8k | 20% | Active, borrow cap 8,370 APT    | Yes        | General          | Freeze reserve, set caps to 1, raise RF to 99% and set IRM base rate to 5% |
| USDC  |    $156k |     $40k | 10% | Active, borrow cap 33,000 USDC  | Yes        | General + E-Mode | Freeze reserve, set caps to 1, raise RF to 99% and set IRM base rate to 5% |
| sUSDe |      $5k |       $0 | 20% | Active                          | No         | General + E-Mode | Freeze reserve and set caps to 1                                           |

### Special cases

- **MaticX on Polygon** is in scope for issuer wind-down, with Stader sunsetting the token. Its Aave oracle is an exchange-rate adapter that values MaticX at its fixed MATIC redemption rate times the MATIC/USD feed, so it already tracks the asset's redemption value, and roughly $0.6M of MATIC-correlated debt is backed by MaticX collateral that stays correctly valued as MATIC moves. MaticX is already at LTV of 0 and borrow-disabled, and is wound down on the standard basis.

### Next Steps

For the whole-market deprecations the sequence continues beyond this proposal: once the RF and rate changes have forced the remaining positions to unwind further, the oracles on those deployments will be deprecated in the same way as in the oracle deprecation ARFC, fixing each feed so the market can be retired completely.

For the individual reserve removals no further parameter work is expected beyond IRM adjustments, applied later only where borrowers have not responded to the initial changes or if the reserve becomes stressed.

> **Changelog:**
>
> _2026-08-11_ EtherFi has committed to grow the eBTC reserve significantly in the coming weeks, therefore, it has been decided to remove the asset from the deprecation list on Aave Core market

## Specification

Whenever a reserve is frozen its supply and borrow caps are also reduced to 1, and already-frozen reserves have their caps reduced to 1 where they are not already, so every deprecated reserve ends in the same terminal state as in the companion oracle deprecation ARFC.

_Note: the Aptos deployment is non-EVM and is therefore not covered by the payloads of this proposal; its wind-down is executed separately._

### Aave V3 Ethereum Core

| Asset            | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ---------------- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| FBTC             | No             | **Yes**            | 175 / **1**                | 1 / 1                      | 50%        | **75%**        |
| ezETH            | No             | **Yes**            | 3,330 / **1**              | n/a / **1**                | n/a        | n/a            |
| eUSDe            | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 45%        | n/a            |
| ETHx             | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 15%        | **50%**        |
| Matured PTs (15) | No             | **Yes**            | 1 / 1                      | 1 / 1                      | n/a        | n/a            |
| CRV              | No             | **Yes**            | 11,000,000 / **1**         | 1 / 1                      | 35%        | **50%**        |
| UNI              | No             | **Yes**            | 1,500,000 / **1**          | 1 / 1                      | 20%        | **50%**        |
| 1INCH            | No             | **Yes**            | 7,000,000 / **1**          | 1 / 1                      | 20%        | **50%**        |
| crvUSD           | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 20%        | **50%**        |
| MKR              | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 20%        | **50%**        |
| ENS              | No             | **Yes**            | 50,000 / **1**             | 1 / 1                      | 20%        | **50%**        |
| SNX              | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 95%        | **99%**        |
| sDAI             | No             | **Yes**            | 1 / 1                      | n/a / **1**                | n/a        | n/a            |

### Aave V3 Ethereum Prime

| Asset | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ----- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| ezETH | No             | **Yes**            | 150 / **1**                | 1 / 1                      | 15%        | No change      |
| USDS  | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 25%        | **50%**        |
| sUSDe | No             | **Yes**            | 3,000,000 / **1**          | 1 / 1                      | 10%        | No change      |

### Aave V3 Arbitrum

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| DAI    | No             | **Yes**            | 4,900,000 / **1**          | 4,410,000 / **1**          | 25%        | **50%**        |
| rETH   | No             | **Yes**            | 1,300 / **1**              | 1 / 1                      | 15%        | **50%**        |
| tBTC   | No             | **Yes**            | 35 / **1**                 | 1 / 1                      | 20%        | n/a            |
| USDC.e | No             | **Yes**            | 1,700,000 / **1**          | 1,530,000 / **1**          | 50%        | **75%**        |
| ezETH  | No             | **Yes**            | 66 / **1**                 | 1 / 1                      | 15%        | No change      |
| EURS   | Yes            | Yes                | 80,000 / **1**             | 65,000 / **1**             | 20%        | **50%**        |

### Aave V3 Plasma

| Asset           | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| --------------- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| Matured PTs (6) | No             | **Yes**            | 1 / 1                      | 1 / 1                      | n/a        | n/a            |
| WETH            | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 15%        | **50%**        |
| weETH           | No             | **Yes**            | 10,000 / **1**             | 1 / 1                      | 20%        | n/a            |
| wstETH          | Yes            | Yes                | 20,000 / **1**             | 5,000 / **1**              | 35%        | **50%**        |

### Aave V3 Base

| Asset | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ----- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| tBTC  | No             | **Yes**            | 8 / **1**                  | 1 / 1                      | 20%        | **50%**        |
| ezETH | No             | **Yes**            | 23 / **1**                 | 1 / 1                      | 15%        | No change      |
| USDbC | No             | **Yes**            | 500,000 / **1**            | 450,000 / **1**            | 50%        | **75%**        |

### Aave V3 Polygon

| Asset   | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ------- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| USDC.e  | No             | **Yes**            | 4,390,000 / **1**          | 3,950,000 / **1**          | 60%        | **85%**        |
| EURS    | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 99%        | 99%            |
| MaticX  | No             | **Yes**            | 9,330,000 / **1**          | 1 / 1                      | 20%        | **50%**        |
| jEUR    | Yes            | Yes                | 120,000 / **1**            | 100,000 / **1**            | 20%        | **50%**        |
| stMATIC | Yes            | Yes                | 61,000,000 / **1**         | n/a / **1**                | n/a        | n/a            |
| EURA    | Yes            | Yes                | 300,000 / **1**            | 250,000 / **1**            | 20%        | **50%**        |
| DPI     | Yes            | Yes                | 1,417 / **1**              | 779 / **1**                | 35%        | **50%**        |
| SUSHI   | Yes            | Yes                | 299,320 / **1**            | 180,000 / **1**            | 20%        | **50%**        |
| CRV     | Yes            | Yes                | 1,400,000 / **1**          | 300,000 / **1**            | 35%        | **50%**        |

### Aave V3 Avalanche

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| WBTC.e | Yes            | Yes                | 2,000 / **1**              | 1,100 / **1**              | 20%        | **50%**        |
| LINK.e | No             | **Yes**            | 155,000 / **1**            | 1 / 1                      | 20%        | **50%**        |
| AAVE.e | No             | **Yes**            | 7,200 / **1**              | n/a / **1**                | n/a        | n/a            |

### Aave V3 Optimism

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| USDC.e | No             | **Yes**            | 1,800,000 / **1**          | 1 / 1                      | 50%        | **75%**        |
| DAI    | No             | **Yes**            | 1,000,000 / **1**          | 900,000 / **1**            | 25%        | **50%**        |
| rETH   | No             | **Yes**            | 450 / **1**                | 1 / 1                      | 15%        | **50%**        |

### Aave V3 Gnosis

| Asset          | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| -------------- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| WETH           | No             | **Yes**            | 3,500 / **1**              | 2,400 / **1**              | 15%        | **50%**        |
| USD//C on xDai | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 80%        | **99%**        |

### Aave V3 BSC

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| wstETH | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 15%        | **50%**        |
| FDUSD  | No             | **Yes**            | 1,200,000 / **1**          | 1,080,000 / **1**          | 20%        | **50%**        |
| Cake   | No             | **Yes**            | 600,000 / **1**            | 1 / 1                      | 20%        | **50%**        |

### Aave V3 MegaETH

| Asset | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF |
| ----- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- |
| ezETH | No             | **Yes**            | 1 / 1                      | 1 / 1                      | 20%        | No change      |
| USDT0 | No             | **Yes**            | 10,000,000 / **1**         | 9,000,000 / **1**          | 10%        | **50%**        |

### Whole-market deployments

Every reserve on each of these deployments is frozen with caps reduced to 1. Reserves that carry a borrow have the RF raised to 99% and the IRM base variable rate set to 5%.

### Aave V3 Sonic

| Asset | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF | Current IRM base rate | Recommended IRM base rate |
| ----- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- | --------------------- | ------------------------- |
| USDC  | No             | **Yes**            | 2,170,000 / **1**          | 1,050,000 / **1**          | 10%        | **99%**        | 0%                    | **5%**                    |
| wS    | No             | **Yes**            | 59,100,000 / **1**         | 36,100,000 / **1**         | 15%        | **99%**        | 0%                    | **5%**                    |
| stS   | No             | **Yes**            | 50,300,000 / **1**         | 1 / 1                      | 10%        | n/a            | 0%                    | n/a                       |
| WETH  | No             | **Yes**            | 556 / **1**                | 97 / **1**                 | 15%        | **99%**        | 0%                    | **5%**                    |

### Aave V3 Scroll

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF | Current IRM base rate | Recommended IRM base rate |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- | --------------------- | ------------------------- |
| WETH   | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 50%        | **99%**        | 0%                    | **5%**                    |
| weETH  | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 85%        | **99%**        | 1%                    | **5%**                    |
| wstETH | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 85%        | **99%**        | 0%                    | **5%**                    |
| USDC   | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 85%        | **99%**        | 0%                    | **5%**                    |
| SCR    | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 85%        | **99%**        | 0%                    | **5%**                    |

### Aave V3 zkSync

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF | Current IRM base rate | Recommended IRM base rate |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- | --------------------- | ------------------------- |
| WETH   | Yes            | Yes                | 600 / **1**                | 1 / 1                      | 15%        | **99%**        | 0%                    | **5%**                    |
| weETH  | Yes            | Yes                | 200 / **1**                | 1 / 1                      | 45%        | n/a            | 0%                    | n/a                       |
| wstETH | Yes            | Yes                | 500 / **1**                | 1 / 1                      | 5%         | **99%**        | 0%                    | **5%**                    |
| wrsETH | Yes            | Yes                | 1 / 1                      | 1 / 1                      | 10%        | n/a            | 0%                    | n/a                       |
| ZK     | Yes            | Yes                | 45,000,000 / **1**         | 1 / 1                      | 20%        | **99%**        | 0%                    | **5%**                    |
| USDC   | Yes            | Yes                | 800,000 / **1**            | 1 / 1                      | 10%        | **99%**        | 0%                    | **5%**                    |
| USDT   | Yes            | Yes                | 150,000 / **1**            | 1 / 1                      | 10%        | **99%**        | 0%                    | **5%**                    |
| sUSDe  | Yes            | Yes                | 110 / **1**                | 1 / 1                      | 20%        | n/a            | 0%                    | n/a                       |

### Aave V3 Metis

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF | Current IRM base rate | Recommended IRM base rate |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- | --------------------- | ------------------------- |
| Metis  | Yes            | Yes                | 80,000 / **1**             | 1 / 1                      | 15%        | **99%**        | 0%                    | **5%**                    |
| m.USDT | Yes            | Yes                | 250,000 / **1**            | 1 / 1                      | 10%        | **99%**        | 0%                    | **5%**                    |
| m.USDC | Yes            | Yes                | 400,000 / **1**            | 1 / 1                      | 10%        | **99%**        | 0%                    | **5%**                    |
| WETH   | Yes            | Yes                | 150 / **1**                | 1 / 1                      | 15%        | **99%**        | 1%                    | **5%**                    |
| m.DAI  | Yes            | Yes                | 25,000 / **1**             | 1 / 1                      | 25%        | **99%**        | 0%                    | **5%**                    |

### Aave V3 Soneium

| Asset  | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF | Current IRM base rate | Recommended IRM base rate |
| ------ | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- | --------------------- | ------------------------- |
| WETH   | Yes            | Yes                | 800 / **1**                | 720 / **1**                | 15%        | **99%**        | 0%                    | **5%**                    |
| USDC.e | Yes            | Yes                | 8,000,000 / **1**          | 7,200,000 / **1**          | 10%        | **99%**        | 0%                    | **5%**                    |
| USDT   | Yes            | Yes                | 5,000,000 / **1**          | 4,500,000 / **1**          | 10%        | **99%**        | 0%                    | **5%**                    |

### Aave V3 Aptos

| Asset | Current frozen | Recommended frozen | Supply cap (current / new) | Borrow cap (current / new) | Current RF | Recommended RF | Current IRM base rate | Recommended IRM base rate |
| ----- | -------------- | ------------------ | -------------------------- | -------------------------- | ---------- | -------------- | --------------------- | ------------------------- |
| USDT  | No             | **Yes**            | 1,040,000 / **1**          | 448,000 / **1**            | 10%        | **99%**        | 0%                    | **5%**                    |
| APT   | No             | **Yes**            | 415,000 / **1**            | 8,370 / **1**              | 20%        | **99%**        | 0%                    | **5%**                    |
| USDC  | No             | **Yes**            | 144,000 / **1**            | 33,000 / **1**             | 10%        | **99%**        | 0%                    | **5%**                    |
| sUSDe | No             | **Yes**            | 2,600 / **1**              | n/a / **1**                | 20%        | n/a            | 0%                    | n/a                       |

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Ethereum (part 2)](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Arbitrum_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Base_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Avalanche_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Optimism_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Gnosis_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3MegaEth](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3MegaEth_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Sonic](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Scroll](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3ZkSync](https://github.com/aave-dao/aave-proposals-v3/blob/main/zksync/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Metis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol), [AaveV3Soneium](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Ethereum (part 2)](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826.t.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Arbitrum_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Base_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Avalanche_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Optimism_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Gnosis_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3MegaEth](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3MegaEth_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Sonic](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Scroll](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3ZkSync](https://github.com/aave-dao/aave-proposals-v3/blob/main/zksync/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Metis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol), [AaveV3Soneium](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol)
- [Snapshot](https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7)
- [Discussion](https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
