---
title: "Umbrella - Renew Allowances"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-umbrella-renew-allowances/25700"
---

## Simple Summary

This proposal renews the Ethereum Collector's allowances to the Umbrella RewardsController for the current reward period, ending on 2 December 2026. The proposed allowances are 500,000 aEthUSDT, 475,000 aEthUSDC and 160 aEthWETH, covering unclaimed rewards and the remaining emissions.

## Motivation

Umbrella reward allowances are due for renewal. As stakers claim rewards, the RewardsController draws on the allowances granted by the Ethereum Collector. Governance periodically renews these allowances to support reward payments, most recently for aEthUSDT and aEthUSDC through [AIP 507](https://vote.onaave.com/proposal/?proposalId=507).

This renewal accounts for rewards accrued by current and former stakers, together with emissions scheduled through 2 December 2026. The Collector holds sufficient balances of the reward assets to fund these payments.

### Proposed Allowances

The allowances are sized using unclaimed rewards as of 25 September 2026 and the maximum emissions for the rest of the period, rounded up. The calculation uses each market's `maxEmissionPerSecond` to allow for deposits growing toward Target Liquidity. Current emissions are approximately 80% of that maximum for USDT and USDC, and 84% for WETH.

| Reward asset | Accrued, unclaimed | Emissions to 2 Dec 2026 (max rate) | Total required through 2 Dec 2026 | New allowance |
| ------------ | ------------------ | ---------------------------------- | --------------------------------- | ------------- |
| aEthUSDT     | 259,782            | 238,379                            | 498,162                           | 500,000       |
| aEthUSDC     | 242,001            | 227,194                            | 469,196                           | 475,000       |
| aEthWETH     | 67.26              | 87.53                              | 154.79                            | 160           |

These amounts replace the remaining allowances; they are not additional amounts.

GHO emissions ended with AIP 507. The existing allowance of 52,730 GHO covers the 22,663 GHO still claimable and remains unchanged.

A separate proposal will renew rewards ahead of 2 December 2026. That renewal will also account for any rewards still unclaimed at the time.

## Specification

The AIP will call `approve` on the Aave Ethereum Collector (`0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c`) to set the following allowances for the Umbrella RewardsController (`0x4655Ce3D625a63d30bA704087E52B4C31E38188B`):

| Reward asset | Address                                      | Current allowance | New allowance |
| ------------ | -------------------------------------------- | ----------------- | ------------- |
| aEthUSDT     | `0x23878914EFE38d27C4D67Ab83ed1b93A74D4086a` | 173,981           | 500,000       |
| aEthUSDC     | `0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c` | 281,241           | 475,000       |
| aEthWETH     | `0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8` | 60.07             | 160           |

Current allowances are shown as of 25 September 2026 and decrease with each claim. Emission rates, Target Liquidity, the 2 December 2026 `distributionEnd`, cooldown parameters, Deficit Offsets and the stkGHO.v1 allowance remain unchanged.

This proposal follows the Direct-to-AIP precedent of [AIP 417](https://vote.onaave.com/proposal/?proposalId=417), [Renewal of Umbrella Reward Allowances](https://governance.aave.com/t/direct-to-aip-renewal-of-umbrella-reward-allowances/23474).

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260928_AaveV3Ethereum_UmbrellaRenewAllowances/AaveV3Ethereum_UmbrellaRenewAllowances_20260928.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260928_AaveV3Ethereum_UmbrellaRenewAllowances/AaveV3Ethereum_UmbrellaRenewAllowances_20260928.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-umbrella-renew-allowances/25700)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
