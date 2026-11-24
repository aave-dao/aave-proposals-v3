---
title: "Umbrella Reward Renewal and Parameter Update on Aave V3 Core"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-umbrella-reward-renewal-and-parameter-update-on-aave-v3-core/26462"
---

## Overview

The Umbrella reward period for USDC, USDT and WETH on Aave V3 Core ends on December 2, 2026. This proposal extends it to April 2, 2027, renews the Collector allowances and updates the parameters set in [TokenLogic's June parameter update](https://governance.aave.com/t/arfc-umbrella-parameter-update-target-liquidity-and-emission-optimization/25154).

Aave V3 Core is being [repositioned around established and liquid collateral](https://governance.aave.com/t/arfc-repositioning-aave-v3-core-around-established-liquid-collateral/26191). The rsETH and osETH loops behind 23% of WETH debt are to migrate to other collateral on Core or to Aave V4, or unwind, and weETH, the largest WETH collateral, no longer carries restaking.

Since the June update, stablecoin stake has remained well above target, while WETH stake has remained below it. We propose raising Target Liquidity from 38.84M to 45.80M USDC and from 40.37M to 45.20M USDT, reflecting half the percentage growth in each loan book since June. The APY at target would fall to 2.50% for both stablecoins, from 3.14% for USDC and 3.17% for USDT. WETH Target Liquidity would remain at 18,716 WETH, with annual emissions unchanged at 470 aEthWETH, until the rsETH and osETH offboarding completes. Annual spend at maximum emission would fall from $3.35M to $3.13M.

All data are as of November 17, 2026. Figures in the tables are rounded to at most two decimals; the Specification gives exact parameter values.

## Framework for Umbrella Liquidity Requirements

This proposal applies the framework from TokenLogic's June parameter update. Target Liquidity follows each market's loan book, adjusted for collateral quality and the Deficit Offset. The premium follows alternative yields and each module's stake.

## Active Loan Exposure

Borrowing has grown in all three covered markets since the June update. USDC loans rose 36%, USDT loans rose 24%, and WETH loans rose 15% (measured in WETH). Part of the USDC growth is recent and concentrated: in early November, one account collateralized with USDe and sUSDe borrowed more than $330M of USDC within a few hours, while USDT borrowing grew more gradually.

Source: TokenLogic Aave Analytics API | November 17, 2026

## Collateral Quality

We measure collateral quality by the pristine share of the collateral behind each market's debt, with pristine defined as ETH, WBTC, cbBTC, wstETH, USDC and USDT. That share has fallen for both stablecoins and risen for WETH as rsETH left the book.
Source: TokenLogic Aave Analytics API, Ethereum mainnet | June 3 and November 17, 2026

Source: TokenLogic Aave Analytics API | June 3 and November 17, 2026

Two-thirds of the USDC decline comes from USDe and sUSDe, which rose from 4% to 12% of the collateral behind USDC debt, with weETH accounting for most of the rest. Nearly all of the USDe-backed debt sits in stable-on-stable E-Mode loops. In USDT the smaller decline came as weETH and syrupUSDT grew; Core prices syrupUSDT at Maple's loss-adjusted exit value, and Maple reports no unrealized losses today.

Outside stable-on-stable loops, 1% of USDC debt and 1.3% of USDT debt sit below a health factor of 1.1. If syrupUSDT positions count as credit-bearing, the USDT share is 5.4%, and in both markets collateral covers debt close to twice over.

Source: TokenLogic Aave Analytics API | November 17, 2026

The WETH book remains a leveraged staking book, with weETH at more than half of collateral value. About 94% of WETH debt sits in ETH-correlated E-Mode loops, almost all of it at health factors between 1.01 and 1.06 and exposed to the exchange rate between the liquid staking token and ETH, the risk that materialized in the rsETH incident. In August 2026, [ether.fi](http://ether.fi) [removed restaking](https://etherfi.gitbook.io/etherfi/products/staking/eeth) from weETH, which is now a plain liquid staking token with no EigenLayer AVS slashing exposure. This removes one source of risk to the WETH reserve.

The reserves in the repositioning ARFC's scope back only $68M of USDC debt and $47M of USDT debt, so the repositioning mainly affects WETH. On WETH they back a far larger amount, almost all of it against rsETH and osETH. The ARFC stops new supply and borrowing against osETH and keeps rsETH frozen, as it has been since April. It also adds wstETH, weETH and cbETH to the rsETH E-Mode, so the loops can swap collateral without repaying their WETH debt. The ARFC provides for an orderly migration, worked out with the issuers and largest borrowers, into collateral that remains on Core or into Aave V4.

Source: TokenLogic Aave Analytics API, Aave governance forum | November 17, 2026

## Deficit Offsets

This proposal does not resize Deficit Offsets. The USDC offset of 1.3M USDC and the USDT offset of 1.6M USDT, set in April, stand in full ahead of stakers, and no USDC or USDT staker has been slashed since launch. In May the WETH offset was raised above the deficit recorded in the rsETH incident, so no WETH staker was slashed. Net of that deficit, the WETH offset ahead of stakers is 77 WETH. The GHO offset stays at 3 million GHO, on a module that no longer emits.

## Relative Yield Environment

Yields on the stablecoin alternatives tracked below have risen since June, and Aave Core supply rates rose with them. Stakers earn those rates through waEthUSDC and waEthUSDT on top of Umbrella emissions. Over the last seven days, annualized total yields averaged 7.0% for USDC stakers and 5.0% for USDT stakers. The lower premium proposed for both stablecoins assumes supply rates stay near current levels.

Lido stETH, weETH and Aave Core WETH supply have stayed close to their June levels, and the WETH Umbrella emission APR on its own sits above both staking yields.

Source: FRED, TokenLogic Aave Analytics API, Morpho, Sky, Ethena, DefiLlama (Maple, Lido, [ether.fi](http://ether.fi)) | 7-day averages to June 3 and to November 17, 2026 (SOFR, T-bill and Fed funds to November 16; sUSDe to November 11); Fed funds is the target-range upper bound

## Staker Participation Since the June Update

Both stablecoin modules have stayed above target every day since the update executed. A staker who starts a cooldown is not committed to leaving. Across all cooldown windows closed since launch (to October 26), stakers withdrew 44% of queued USDC, 55% of queued USDT and 51% of queued WETH (the historical share). If the historical share of today's USDC queue is withdrawn, USDC stake would stand near 46M, still above target.

stkwaEthUSDT has held higher still, though stake has declined since the day of the update. Its cooldown queue, more than half of stake, is the largest of the three markets, and the five largest holders account for $24M of it. The queue has grown over the last three weeks.

stkwaEthWETH has sat below target since one large holder withdrew in January. Without that holder, WETH stake has never reached its target, peaking just below it in April. Since the trough in May and June, stake has rebuilt gradually at an emission APR averaging 3.6%.

Source: Ethereum mainnet (stkwaEthUSDC, stkwaEthUSDT, stkwaEthWETH, Umbrella RewardsController) | November 17, 2026

Source: Ethereum mainnet (Umbrella RewardsController), TokenLogic Aave Analytics API | November 17, 2026

## Recommendation

We recommend renewing the Umbrella reward period to April 2, 2027, with new allowances, raising Target Liquidity on USDC and USDT, reducing their APY at target, and keeping WETH Target Liquidity and emissions unchanged.

The stablecoin targets now cover 1.50% of USDC loans and 1.64% of USDT loans, down from 2.0% in June as borrowing has grown, while the pristine share of the collateral behind both has fallen. We propose raising each target by half the percentage growth in its market's loan book since June, to 45.80M USDC and 45.20M USDT. At the new targets, coverage is 1.77% of USDC loans and 1.83% of USDT loans.

Both modules have maintained stake above target since the update executed in late July, while paying emission yields of 1.47% to 1.83% on USDC and 1.27% to 1.74% on USDT, well below the current APY at target. We therefore propose reducing the APY at target to 2.50%. At today's stake, the proposed curve pays 1.76% on USDC and 1.53% on USDT.

The main participation risk is the USDT cooldown queue, which contains more than half of stake. Withdrawals at the historical rate would leave USDT stake at 0.91 times the new target, with a proposed emission APR of 2.73%. Withdrawal of the entire queue would leave stake at 0.58 times the target and raise the APR to 3.54%. If the historical share of its queue is withdrawn, USDC stake would fall to 1.01 times its new target, with an emission APR of 2.47%.

WETH Target Liquidity remains unchanged while the WETH book is in transition. The unwind of rsETH and osETH loops may reduce the WETH loan book, but how much of that exposure stays on Core is not yet known. Stake is already 7,200 WETH below target, and raising the target would not automatically increase participation.

We propose keeping the WETH emission unchanged at 470 aEthWETH per year, an APY at target of 2.51%. WETH stake remains below target, and the proposal lowers the premium only where stake sits above target. We will reassess the WETH parameters once the rsETH and osETH offboarding completes.
Source: Ethereum mainnet (Umbrella RewardsController) | November 17, 2026

The proposal lowers annual reward spend by 6.7% at maximum emission and by 5.5% at today's stakes. The new parameters apply from execution, intended on or before December 2. Over the rest of the period, the proposal saves $49.7k at today's stakes. The new allowances, $1.84M in total, cover the rewards already accrued plus emissions at the maximum rate to the end of the period, as in the September renewal.

Source: Ethereum mainnet (Umbrella RewardsController), TokenLogic Aave Analytics API | November 17, 2026 | WETH at $1,814.66

## Specification

The AIP will apply the parameters below on the Umbrella RewardsController (`0x4655Ce3D625a63d30bA704087E52B4C31E38188B`) and approve the allowances below from the Aave Ethereum Collector (`0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c`). Allowances will be resized at submission from the unclaimed balance. These amounts replace the remaining allowances. The cooldown, unstake window, Deficit Offsets and stkGHO allowance remain unchanged.

| Stake token  | Address                                      | Reward asset | Target Liquidity, current | Target Liquidity, proposed | `maxEmissionPerSecond`, current (reward-token units per second) | `maxEmissionPerSecond`, proposed (reward-token units per second) | `distributionEnd`, current | `distributionEnd`, proposed |
| ------------ | -------------------------------------------- | ------------ | ------------------------- | -------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------- | --------------------------- |
| stkwaEthUSDC | `0x6bf183243FdD1e306ad2C4450BC7dcf6f0bf8Aa6` | aEthUSDC     | 32,518,555 waEthUSDC      | 38,345,557 waEthUSDC       | 0.038685                                                        | 0.036307                                                         | 2026-12-02 07:36:47 UTC    | 2027-04-02 00:00 UTC        |
| stkwaEthUSDT | `0xA484Ab92fe32B143AEE7019fC1502b1dAA522D31` | aEthUSDT     | 34,114,525 waEthUSDT      | 38,194,079 waEthUSDT       | 0.040588                                                        | 0.035832                                                         | 2026-12-02 07:40:23 UTC    | 2027-04-02 00:00 UTC        |
| stkwaEthWETH | `0xaAFD07D53A7365D3e9fb6F3a3B09EC19676B73Ce` | aEthWETH     | 17,437.44 waEthWETH       | unchanged                  | 0.000014903602232369                                            | unchanged                                                        | 2026-12-02 07:41:23 UTC    | 2027-04-02 00:00 UTC        |

| Reward asset | Address                                      | Current allowance (Nov 17, 2026) | Accrued, unclaimed (Nov 17, 2026) | Emissions to Apr 2, 2027 | New allowance |
| ------------ | -------------------------------------------- | -------------------------------- | --------------------------------- | ------------------------ | ------------- |
| aEthUSDC     | `0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c` | 414,052                          | 269,770                           | ≈427,000                 | 700,000       |
| aEthUSDT     | `0x23878914EFE38d27C4D67Ab83ed1b93A74D4086a` | 426,365                          | 230,296                           | ≈424,000                 | 655,000       |
| aEthWETH     | `0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8` | 132.74                           | 86.93                             | ≈173.9                   | 270           |

## Next Steps

1. Gather feedback from the community.
2. Escalate this proposal directly to the AIP stage.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261124_AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core/AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261124_AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core/AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124.t.sol)
- [Discussion](https://governance.aave.com/t/direct-to-aip-umbrella-reward-renewal-and-parameter-update-on-aave-v3-core/26462)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
