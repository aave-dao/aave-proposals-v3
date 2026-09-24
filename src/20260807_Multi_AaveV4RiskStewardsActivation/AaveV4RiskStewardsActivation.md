---
title: "Aave V4 Risk Stewards Activation"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0xf736fa5f6dd1532d0e2825fe528262479949a923427989384e313490ca9d9f18"
---

## Simple Summary

This proposal activates the Risk Stewards on Aave V4 Ethereum and Aave V4 Avalanche, by setting their risk configuration and granting them the AccessManager roles they need to operate. On Aave V4 Base, where the Risk Steward is already configured, it takes ownership of the Risk Steward and grants it the Aave V3 ACL Manager role it needs to update price caps. GHO is excluded from the Risk Steward's scope on V4 Ethereum and V4 Base, as it stays under the GHO Steward.

The bounds (`maxPercentChange`) follow LlamaRisk's recommended configuration, which carries most of them over from the corresponding V3 Risk Stewards unchanged. The cooldowns (`minDelay`) on the interest rate, cap and `collateralRisk` parameters are set to 36 hours, in line with the reduction ratified for the V3 Risk Stewards; every other parameter keeps a 72 hour cooldown, and the Pendle discount rate keeps its 48 hour cooldown.

## Motivation

The V4 Risk Stewards are deployed on both networks but hold no configuration and no permissions, so risk parameter maintenance on V4 still requires a full governance cycle for every change.

Configuring them alongside their V3 counterparts keeps a single risk mandate across protocol versions: the same risk council, and the same limits on how far a single update can move a parameter wherever V4 has a V3 equivalent. The parameters that are new in V4 — `collateralRisk`, the bounds applied when appending a new dynamic reserve config, and the spoke liquidation config — follow LlamaRisk's recommendation, as do the two interest rate parameters they widened relative to their V3 analogs.

`collateralRisk` sits at or near 0 under normal conditions and is bounded absolutely, so it gets a wide 300% bound and the reduced 36 hour cooldown: that combination lets the risk premium be lifted far enough, fast enough, to push borrowers toward repayment inside a single stress window.

The same configuration is applied on both networks so the two V4 Risk Stewards do not diverge.

The Base V4 Risk Steward was deployed with its configuration already set, and its ownership handed over to the Base governance Executor pending acceptance. Accepting it puts the Base Risk Steward under governance control, as on Ethereum and Avalanche.

## Specification

On Aave V4 Ethereum, the payload targets the Risk Steward at [0x6f48d9Cdb8EE6E17c96B2d8Aec128af426A295c1](https://etherscan.io/address/0x6f48d9Cdb8EE6E17c96B2d8Aec128af426A295c1). On Aave V4 Avalanche, it targets the Risk Steward at [0xd8d7AbC42c1c938BdEC94fF8da1b3cd5b7e3b107](https://snowscan.xyz/address/0xd8d7AbC42c1c938BdEC94fF8da1b3cd5b7e3b107). Both payloads apply the same configuration:

| Scope  | Parameter                        | Cooldown | Max change per update | Mode     |
| ------ | -------------------------------- | -------- | --------------------- | -------- |
| Hub    | `optimalUsageRatio`              | 36 hours | 3%                    | absolute |
| Hub    | `baseDrawnRate`                  | 36 hours | 3%                    | absolute |
| Hub    | `rateGrowthBeforeOptimal`        | 36 hours | 3%                    | absolute |
| Hub    | `rateGrowthAfterOptimal`         | 36 hours | 20%                   | absolute |
| Hub    | `addCap`                         | 36 hours | 100%                  | relative |
| Hub    | `drawCap`                        | 36 hours | 100%                  | relative |
| Spoke  | `collateralRisk`                 | 36 hours | 300%                  | absolute |
| Spoke  | `collateralFactor` (update)      | 72 hours | 0.5%                  | absolute |
| Spoke  | `maxLiquidationBonus` (update)   | 72 hours | 0.5%                  | absolute |
| Spoke  | `collateralFactor` (addition)    | 72 hours | 5%                    | absolute |
| Spoke  | `maxLiquidationBonus` (addition) | 72 hours | 0.5%                  | absolute |
| Spoke  | `targetHealthFactor`             | 72 hours | 5%                    | relative |
| Spoke  | `healthFactorForMaxBonus`        | 72 hours | 5%                    | relative |
| Spoke  | `liquidationBonusFactor`         | 72 hours | 5%                    | absolute |
| Oracle | `priceCapLst`                    | 72 hours | 5%                    | relative |
| Oracle | `priceCapStable`                 | 72 hours | 0.5%                  | relative |
| Oracle | `discountRatePendle`             | 48 hours | 0.025                 | absolute |

### Grants

Each Risk Steward is granted `HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (200) and `SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (400) on its network's AccessManager, with no execution delay. Those are the only roles the two configurators expose today: every configurator function sits behind one of them, so they are what the Risk Steward needs to reach the caps, collateral factors and interest rate parameters the configuration above bounds.

The grants are therefore wider at the AccessManager than the mandate they serve. What keeps the mandate narrow is the Risk Steward contract itself: it only exposes the bounded entrypoints listed above, it enforces the cooldown and the maximum change on each of them, and its configuration can only be replaced by governance, which also remains able to revoke either role at any time. Breaking the two domain admin roles into granular ones, so the grant matches the mandate at the AccessManager level as well, is left to a follow-up proposal.

Each Risk Steward is also granted `RISK_ADMIN` on its network's Aave V3 ACL Manager. The CAPO adapters serving the V4 price sources are shared with V3 and gate `setCapParameters` on the V3 ACL Manager, so without this role the `priceCapLst`, `priceCapStable` and `discountRatePendle` bounds above would be unusable.

### GHO restriction

GHO falls under the GHO Steward's mandate, so on Aave V4 Ethereum the payload also restricts the GHO underlying ([0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f](https://etherscan.io/address/0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f)) on the Risk Steward. Restrictions are checked against the underlying of every hub and spoke update, so this single call blocks the Risk Steward from touching GHO on every hub and spoke it is listed on. GHO is not listed on Aave V4 Avalanche, so nothing is restricted there.

### Aave V4 Base

On Aave V4 Base, the payload targets the Risk Steward at [0x577dD4c67d4c7278CdF3bC03aE9a391C4C72DB4f](https://basescan.org/address/0x577dD4c67d4c7278CdF3bC03aE9a391C4C72DB4f) and:

1. Accepts its ownership, which is pending transfer to the Base governance Executor ([0x9390B1735def18560c509E2d0bc090E9d6BA257a](https://basescan.org/address/0x9390B1735def18560c509E2d0bc090E9d6BA257a)), so its configuration and restrictions can only be changed by governance.
2. Grants it `RISK_ADMIN` on the Aave V3 Base ACL Manager ([0x43955b0899Ab7232E3a454cf84AedD22Ad46FD33](https://basescan.org/address/0x43955b0899Ab7232E3a454cf84AedD22Ad46FD33)), which gates `setPriceCap` on the USDC CAPO adapter behind the V4 Base price source, so the `priceCapStable` bound is usable.
3. Restricts GHO ([0x6Bb7a212910682DCFdbd5BCBb3e28FB4E8da10Ee](https://basescan.org/address/0x6Bb7a212910682DCFdbd5BCBb3e28FB4E8da10Ee)) on the Risk Steward. GHO is not listed on Aave V4 Base today, so this keeps it out of the Risk Steward's scope ahead of any future listing.

The payload leaves the Base Risk Steward's configuration unchanged. It uses the same maximum changes as the table above, with shorter cooldowns: 12 hours on `addCap` and `drawCap`, and 36 hours on the spoke `collateralFactor`, `maxLiquidationBonus`, `targetHealthFactor`, `healthFactorForMaxBonus` and `liquidationBonusFactor` bounds.

Its `HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (200) and `SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (400) on the Base AccessManager are granted separately by the Aave V4 Security Council, not by this proposal.

## References

- Implementation: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.sol), [AaveV4Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807.sol), [AaveV4Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Base_AaveV4RiskStewardsActivation_20260807.sol)
- Tests: [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.t.sol), [AaveV4Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807.t.sol), [AaveV4Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Base_AaveV4RiskStewardsActivation_20260807.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0xf736fa5f6dd1532d0e2825fe528262479949a923427989384e313490ca9d9f18)
- [Discussion](https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
