---
title: "Onboard PT-AUSD-17DEC2026 to the LlamaRisk PT Risk Oracle"
author: "LlamaRisk"
discussions: "https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/6?u=llamarisk"
---

## Simple Summary

Registers two predeployed risk agents on the Aave-owned AgentHub so that discount rate and eMode risk parameters for PT-AUSD-17DEC2026 on Aave V3 Monad can be maintained automatically from the LlamaRisk PT Risk Oracle, within bounds this proposal sets.

## Motivation

PT-AUSD-17DEC2026 is a Pendle principal token onboarded to Aave V3 Monad by a separate AIP, [Onboard PT-AUSD-17DEC2026 to Aave V3 Monad](https://governance.aave.com/t/direct-to-aip-onboard-pt-ausd-17dec2026-to-aave-v3-monad-instance/25701), as collateral in eMode category 6. Its fair value depends on an implied discount rate that decays to zero at maturity, so a static discount rate is wrong almost everywhere: too high early, and increasingly too low as maturity approaches. The same drift affects the liquidation threshold and bonus that should apply to it.

LlamaRisk operates an offchain pipeline on Chainlink CRE that tracks the Pendle market, maintains an EMA of the implied rate, and derives both the discount rate and the eMode parameters from it. This proposal is the last link in that chain: it grants the two agent contracts permission to apply those values, and bounds how far each application may move a parameter.

The pipeline publishes to a RiskOracle that only LlamaRisk's router can write to, and the router only accepts reports from the Chainlink CRE forwarder for a workflow owned by the Aave CRE organisation multisig. Governance retains the ability to disable either agent at any time.

## Specification

The payload performs three groups of actions.

**1. Register the discount rate agent.** The payload registers the predeployed `AaveDiscountRateAgent` from `MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT` on `MiscMonad.AGENT_HUB`, consuming `PendleDiscountRateUpdate` records from the LlamaRisk RiskOracle and allowed to act only on PT-AUSD-17DEC2026. Minimum delay 2 days, expiration period 2 days.

**2. Register the eMode agent.** The predeployed `AaveEModeAgent` from `MiscMonad.LLAMARISK_PT_EMODE_AGENT` is registered for the same oracle, consuming `EModeCategoryUpdate` and allowed to act only on eMode category 6. Minimum delay 3 days, expiration period 3 days. Its agent context encodes `AaveV3Monad.CONFIG_ENGINE`, which it delegatecalls to apply category updates.

Both are registered with `admin` set to `MiscMonad.PROTOCOL_GUARDIAN`, so a misbehaving agent can be disabled without a governance cycle. Registration stays governance-only: `registerAgent` and `setAgentAdmin` are `onlyOwner`, and the AgentHub is owned by `GovernanceV3Monad.EXECUTOR_LVL_1`. Both `isAgentPermissioned` and `isMarketsFromAgentEnabled` are left at their defaults.

These are the first agents on the Monad AgentHub, so they take agent ids 0 and 1. Both agent addresses and the RiskOracle are imported from `MiscMonad`. Neither agent is registered with a suffixed update type: the LlamaRisk RiskOracle serves this stack alone, so the base types are unambiguous.

**3. Grant RISK_ADMIN and bound the ranges.** `addRiskAdmin` on `AaveV3Monad.ACL_MANAGER` for both predeployed agents, then `setDefaultRangeConfig` on `MiscMonad.RANGE_VALIDATION_MODULE` for each parameter each agent can move.

The role is required because of how the agents write. The discount rate agent resolves the PT price source through the Aave oracle and calls `setDiscountRatePerYear` on the `PendlePriceCapAdapter`, which gates that call on `isRiskAdmin || isPoolAdmin`. The eMode agent delegatecalls the config engine, and because delegatecall preserves the caller, the PoolConfigurator sees the agent rather than the engine, so the role has to sit on the agent there as well.

### Bounds and timelocks

Every bound is absolute rather than relative. A relative cap is measured against the last value the agent injected, which does not exist on a freshly assigned agent id, so a relative configuration would leave the first injection unbounded. The minimum delay is the timelock the hub enforces between injections per agent and market, and the expiration period is how long a published update remains applicable.

| Agent         | Parameter                   | Maximum move per injection | Minimum delay | Expiration period |
| ------------- | --------------------------- | -------------------------- | ------------- | ----------------- |
| Discount rate | `PendleDiscountRateUpdate`  | 100 bps (`1e16`)           | 2 days        | 2 days            |
| eMode         | `EModeLTV`                  | 50 bps                     | 3 days        | 3 days            |
| eMode         | `EModeLiquidationThreshold` | 50 bps                     | 3 days        | 3 days            |
| eMode         | `EModeLiquidationBonus`     | 50 bps                     | 3 days        | 3 days            |

These configurations are not optional. A fresh agent id inherits no default range config, and the module reads a missing config as a zero bound, which rejects every injection. Omitting them would produce a registered but permanently inert agent.

### Affected eMode categories

| Id  | Label                            |
| --- | -------------------------------- |
| 6   | `PT_AUSD_17DEC2026__Stablecoins` |

No reserve configuration is changed by this payload. The snapshot diff is empty by design.

## Deployed Contracts

- `MiscMonad.LLAMARISK_RISK_ORACLE`: [0x4b00A38ee9396E952d07F81B26Ed1514e480dCFC](https://monadscan.com/address/0x4b00A38ee9396E952d07F81B26Ed1514e480dCFC)
- `MiscMonad.LLAMARISK_RISK_ORACLE_ROUTER`: [0x8fDdd4Ab11Ecd6A95F6d67f13166031604624B71](https://monadscan.com/address/0x8fDdd4Ab11Ecd6A95F6d67f13166031604624B71)
- `MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT`: [0x9047f3084Dd26d0d8a6b0Ef9Bb8643b01dA726D3](https://monadscan.com/address/0x9047f3084Dd26d0d8a6b0Ef9Bb8643b01dA726D3)
- `MiscMonad.LLAMARISK_PT_EMODE_AGENT`: [0xa89C6f877380af190AFD839c0F9cBF57474162f1](https://monadscan.com/address/0xa89C6f877380af190AFD839c0F9cBF57474162f1)
- `CHAINLINK_CRE_FORWARDER`: [0x76c9cf548b4179F8901cda1f8623568b58215E62](https://monadscan.com/address/0x76c9cf548b4179F8901cda1f8623568b58215E62)

The payload references the RiskOracle and both agents directly. The Router and CRE Forwarder are included above to make the complete write path easier to review.

Existing Aave contracts referenced, all from the address book:

- AgentHub: `MiscMonad.AGENT_HUB`
- RangeValidationModule: `MiscMonad.RANGE_VALIDATION_MODULE`
- PT-AUSD-17DEC2026: `AaveV3MonadAssets.PT_AUSD_17DEC2026_UNDERLYING`
- eMode category 6 (`PT_AUSD_17DEC2026__Stablecoins`):
  `AaveV3MonadEModes.PT_AUSD_17DEC2026__USDT0_USDC_USDe_mUSD_GHO`
- ACL manager: `AaveV3Monad.ACL_MANAGER`
- Config engine: `AaveV3Monad.CONFIG_ENGINE`
- Agent admin: `MiscMonad.PROTOCOL_GUARDIAN`
- AgentHub owner: `GovernanceV3Monad.EXECUTOR_LVL_1`

### Agent source

Both predeployed agents are verified deployments of the stock implementations from [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents). The tests verify their bytecode is present and their immutable AgentHub, RangeValidationModule, pool, oracle and update-type wiring matches the configuration registered by this payload.

## References

- [Implementation](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261002_AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle/AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002.sol)
- [Tests](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261002_AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle/AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002.t.sol)
- Agent implementations: [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/6)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
