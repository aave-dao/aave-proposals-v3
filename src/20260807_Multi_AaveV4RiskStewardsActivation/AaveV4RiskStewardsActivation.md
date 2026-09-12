---
title: "Aave V4 Risk Stewards Activation"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510"
---

## Simple Summary

This proposal activates the Risk Stewards on Aave V4 Ethereum and Aave V4 Avalanche, by setting their risk configuration and granting them the AccessManager roles they need to operate. It also breaks each configurator's single domain admin role down into five granular roles, so the Risk Stewards receive only the subset they need instead of full configurator access.

The bounds (`maxPercentChange`) follow LlamaRisk's recommended configuration, which carries most of them over from the corresponding V3 Risk Stewards unchanged. The cooldowns (`minDelay`) on the interest rate, cap and `collateralRisk` parameters are set to 36 hours, in line with the reduction ratified for the V3 Risk Stewards; every other parameter keeps a 72 hour cooldown, and the Pendle discount rate keeps its 48 hour cooldown.

## Motivation

The V4 Risk Stewards are deployed on both networks but hold no configuration and no permissions, so risk parameter maintenance on V4 still requires a full governance cycle for every change.

Configuring them alongside their V3 counterparts keeps a single risk mandate across protocol versions: the same risk council, and the same limits on how far a single update can move a parameter wherever V4 has a V3 equivalent. The parameters that are new in V4 — `collateralRisk`, the bounds applied when appending a new dynamic reserve config, and the spoke liquidation config — follow LlamaRisk's recommendation, as do the two interest rate parameters they widened relative to their V3 analogs.

`collateralRisk` sits at or near 0 under normal conditions and is bounded absolutely, so it gets a wide 300% bound and the reduced 36 hour cooldown: that combination lets the risk premium be lifted far enough, fast enough, to push borrowers toward repayment inside a single stress window.

The 36 hour cooldowns are applied to both networks so the two V4 Risk Stewards do not diverge.

The HubConfigurator and SpokeConfigurator each currently expose every one of their functions behind a single domain admin role, 200 and 400 respectively. Granting a Risk Steward that role to let it move caps and collateral factors would also let it list assets, register spokes, pause and freeze reserves, and change price sources and fee receivers. Splitting the two roles first keeps the grant proportionate to what the Risk Steward actually calls, and gives governance a vocabulary for delegating narrower mandates to other entities later without another restructuring.

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

### Configurator role breakdown

Before granting anything, each payload splits its network's two configurator domain admin roles into five granular roles apiece. A role never spans both configurators, so Hub and Spoke access is always granted separately.

| Concern               | Hub role                                      | Spoke role                                      | Scope                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| --------------------- | --------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prevent all activity  | `HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE` (201)    | `SPOKE_CONFIGURATOR_PAUSE_ROLE` (401)           | Flips the flag that prevents all activity, in both directions. `updateSpokeActive` on the Hub, `updatePaused` on the Spoke.                                                                                                                                                                                                                                                                                                                                                                                                 |
| Prevent new activity  | `HUB_CONFIGURATOR_SPOKE_HALTED_ROLE` (202)    | `SPOKE_CONFIGURATOR_FREEZE_ROLE` (402)          | Flips the flag that prevents new activity, in both directions. `updateSpokeHalted` on the Hub, `updateFrozen` on the Spoke.                                                                                                                                                                                                                                                                                                                                                                                                 |
| Listing               | `HUB_CONFIGURATOR_LISTING_ROLE` (203)         | `SPOKE_CONFIGURATOR_LISTING_ROLE` (403)         | `addAsset`, `addAssetWithDecimals`, `addSpoke`, `addSpokeToAssets` on the Hub. `addReserve`, `updateBorrowable`, `updateReceiveSharesEnabled` on the Spoke.                                                                                                                                                                                                                                                                                                                                                                 |
| Emergency             | `HUB_CONFIGURATOR_EMERGENCY_ROLE` (204)       | `SPOKE_CONFIGURATOR_EMERGENCY_ROLE` (404)       | The one-directional batch flag actions. `deactivateAsset`, `haltAsset`, `deactivateSpoke`, `haltSpoke` on the Hub. `pauseReserve`, `pauseAllReserves`, `freezeReserve`, `freezeAllReserves` on the Spoke.                                                                                                                                                                                                                                                                                                                   |
| Risk management       | `HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE` (205) | `SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE` (405) | `updateSpokeAddCap`, `updateSpokeDrawCap`, `updateSpokeCaps`, `updateSpokeRiskPremiumThreshold`, `updateInterestRateData` on the Hub. `updateCollateralRisk`, `addCollateralFactor`, `updateCollateralFactor`, `addMaxLiquidationBonus`, `updateMaxLiquidationBonus`, `addLiquidationFee`, `updateLiquidationFee`, `addDynamicReserveConfig`, `updateDynamicReserveConfig`, `updateLiquidationTargetHealthFactor`, `updateHealthFactorForMaxBonus`, `updateLiquidationBonusFactor`, `updateLiquidationConfig` on the Spoke. |
| Residual domain admin | `HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (200)    | `SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE` (400)    | `updateLiquidityFee`, `updateFeeReceiver`, `updateFeeConfig`, `updateInterestRateStrategy`, `updateReinvestmentController`, `resetAssetCaps`, `resetSpokeCaps` on the Hub. `updateReservePriceSource`, `updatePositionManager` on the Spoke.                                                                                                                                                                                                                                                                                |

The two flag roles are named after the flag they own rather than after pause and freeze, because the Hub has no `paused`/`frozen` flags of its own: the equivalent state is the per-asset Spoke `active` flag, which gates every Hub action, and the `halted` flag, which gates the actions that instantly update liquidity. The emergency role is kept separate from both because every one of its selectors only ever moves a target to a safer state and cannot revert it, so it can be delegated to a faster-moving entity than the two-way flag roles. The Hub's batch cap resets stay with the domain admin role: zeroing caps is as one-directional as a halt, but only risk management can restore them, so it remains governance-only.

The role IDs and selector sets match `Roles.sol` in the Aave V4 repository, following the documented convention of appending new IDs and letting the domain admin role's selector set shrink. Existing IDs are never repurposed, so the two domain admin roles keep the selectors that fall outside the five and every address that holds one today is granted the corresponding five new roles, retaining exactly the reach it has now. The ten new roles are also labelled on the AccessManager, matching what a fresh V4 deployment produces.

### Grants

Each Risk Steward is granted four of the new roles on its network's AccessManager, with no execution delay: `HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE` (205), `HUB_CONFIGURATOR_EMERGENCY_ROLE` (204), `SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE` (405) and `SPOKE_CONFIGURATOR_EMERGENCY_ROLE` (404). The two risk management roles are what the configuration above actually needs; without them the Risk Steward cannot reach the configurators and the bounds have no effect. The two emergency roles are granted alongside so a future Risk Steward release can de-risk without another governance cycle; the release deployed today calls none of their selectors, so they stay inert until then.

Each Risk Steward is also granted `RISK_ADMIN` on its network's Aave V3 ACL Manager. The CAPO adapters serving the V4 price sources are shared with V3 and gate `setCapParameters` on the V3 ACL Manager, so without this role the `priceCapLst`, `priceCapStable` and `discountRatePendle` bounds above would be unusable.

The Risk Stewards receive neither flag role, nor the listing or domain admin roles, so listings, spoke registrations, borrowability, price sources, position managers, fees and interest rate strategy addresses remain governance-only, as does clearing a pause, freeze or halt once set. Liquidation fees are the one parameter that sits inside a granted role without being in the Risk Stewards' scope: they hold no bound for it, and every entrypoint that carries the parameter reverts unless it is left unchanged.

## References

- Implementation: [AaveV4Ethereum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.sol), [AaveV4Avalanche](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807.sol), [AaveV4ConfiguratorRoles](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4ConfiguratorRoles.sol)
- Tests: [AaveV4Ethereum](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.t.sol), [AaveV4Avalanche](https://github.com/bgd-labs/aave-proposals-v3/blob/main/src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807.t.sol)
- [Snapshot](TODO)
- [Discussion](https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
