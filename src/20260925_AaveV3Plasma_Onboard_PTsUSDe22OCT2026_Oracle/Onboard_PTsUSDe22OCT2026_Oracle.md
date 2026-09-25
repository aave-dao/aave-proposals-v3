---
title: "Onboard PT-sUSDe-22OCT2026 to the LlamaRisk PT Risk Oracle"
author: "LlamaRisk"
discussions: "https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/5?u=llamarisk"
---

## Simple Summary

Registers two predeployed risk agents on the Aave-owned AgentHub so that discount rate and eMode risk parameters for PT-sUSDe-22OCT2026 on Aave V3 Plasma can be maintained automatically from the LlamaRisk PT Risk Oracle, within bounds this proposal sets.

## Motivation

PT-sUSDe-22OCT2026 is a Pendle principal token listed on Plasma as reserve 17 and collateral in eMode categories 25 and 26. Its fair value depends on an implied discount rate that decays to zero at maturity, so a static discount rate is wrong almost everywhere: too high early, and increasingly too low as maturity approaches. The same drift affects the liquidation threshold and bonus that should apply to it.

LlamaRisk operates an offchain pipeline on Chainlink CRE that tracks the Pendle market, maintains an EMA of the implied rate, and derives both the discount rate and the eMode parameters from it. This proposal is the last link in that chain: it grants the two agent contracts permission to apply those values, and bounds how far each application may move a parameter.

The pipeline publishes to a RiskOracle that only LlamaRisk's router can write to, and the router only accepts reports from the Chainlink CRE forwarder for a workflow owned by the Aave CRE organisation multisig. Governance retains the ability to disable either agent at any time.

## Specification

The payload performs three groups of actions.

**1. Register the discount rate agent.** The payload registers the predeployed `AaveDiscountRateAgent` from `MiscPlasma.LLAMARISK_PT_DISCOUNT_RATE_AGENT` on `MiscPlasma.AGENT_HUB`, consuming `PendleDiscountRateUpdate` records from the LlamaRisk RiskOracle and allowed to act only on PT-sUSDe-22OCT2026. Minimum delay 2 days, expiration period 2 days.

**2. Register the eMode agent.** The predeployed `AaveEModeAgent` from `MiscPlasma.LLAMARISK_PT_EMODE_AGENT` is registered for the same oracle, consuming `EModeCategoryUpdate` and allowed to act only on eMode categories 25 and 26. Minimum delay 3 days, expiration period 3 days. Its agent context encodes `AaveV3Plasma.CONFIG_ENGINE`, which it delegatecalls to apply category updates.

Both are registered with `admin` set to `MiscPlasma.PROTOCOL_GUARDIAN`, so a misbehaving agent can be disabled without a governance cycle. Registration stays governance-only: `registerAgent` and `setAgentAdmin` are `onlyOwner`, and the AgentHub is owned by `GovernanceV3Plasma.EXECUTOR_LVL_1`. Both `isAgentPermissioned` and `isMarketsFromAgentEnabled` are left at their defaults.

Both are registered under new agent ids rather than reusing the two disabled agents already on the hub. The hub tracks a last-injected `updateId` per `(agentId, market)` and injects only when `updateId > lastInjected`, and that pointer survives a change of `riskOracle`. The old eMode agent carries pointers of 156 and 155 on eMode categories 22 and 24, so reusing its id against a new RiskOracle, whose counter starts at zero, would reject those markets until the counter passed 156.

Both agent addresses and the RiskOracle are imported from `MiscPlasma`. Neither agent is registered with a suffixed update type: the LlamaRisk RiskOracle serves this stack alone, so the base types are unambiguous.

**3. Grant RISK_ADMIN and bound the ranges.** `addRiskAdmin` on `AaveV3Plasma.ACL_MANAGER` for both predeployed agents, then `setDefaultRangeConfig` on `MiscPlasma.RANGE_VALIDATION_MODULE` for each parameter each agent can move.

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

Two further limits apply outside this payload. The minimum delays above are enforced by the hub per agent and market. And the LlamaRisk router applies its own 48 hour minimum delay to the discount rate route, so that value is rate limited twice, independently. The router carries no step cap of its own on any route: the per-injection bounds in the table above are enforced by the RangeValidationModule alone.

### Affected eMode categories

| Id  | Label                |
| --- | -------------------- |
| 25  | PT-sUSDe Stablecoins |
| 26  | PT-sUSDe USDe        |

No reserve configuration is changed by this payload. The snapshot diff is empty by design.

## Deployed Contracts

- `MiscPlasma.LLAMARISK_RISK_ORACLE`: [0x4f240E3825e7FD6D834EEb861b1539dF0b43BfD0](https://plasmascan.to/address/0x4f240E3825e7FD6D834EEb861b1539dF0b43BfD0)
- `MiscPlasma.LLAMARISK_RISK_ORACLE_ROUTER`: [0xaC8690DE68dcB7068805c0C631004E9894FAFbe0](https://plasmascan.to/address/0xaC8690DE68dcB7068805c0C631004E9894FAFbe0)
- `MiscPlasma.LLAMARISK_PT_DISCOUNT_RATE_AGENT`: [0x8feb86657dbBbB89B7D2D115263D6927Afeb8bd4](https://plasmascan.to/address/0x8feb86657dbBbB89B7D2D115263D6927Afeb8bd4)
- `MiscPlasma.LLAMARISK_PT_EMODE_AGENT`: [0xBcFaBC3ea806d4755ED3F1eA2C5EAE92706Beb29](https://plasmascan.to/address/0xBcFaBC3ea806d4755ED3F1eA2C5EAE92706Beb29)
- `CHAINLINK_CRE_FORWARDER`: [0x7BCcaFBD064cB3658476066Cc33ceE3F3414c04c](https://plasmascan.to/address/0x7BCcaFBD064cB3658476066Cc33ceE3F3414c04c)

The payload references the RiskOracle and both agents directly. The Router and CRE Forwarder are included above to make the complete write path easier to review.

Existing Aave contracts referenced, all from the address book:

- AgentHub: `MiscPlasma.AGENT_HUB`
- RangeValidationModule: `MiscPlasma.RANGE_VALIDATION_MODULE`
- ACL manager: `AaveV3Plasma.ACL_MANAGER`
- Config engine: `AaveV3Plasma.CONFIG_ENGINE`
- Agent admin: `MiscPlasma.PROTOCOL_GUARDIAN`
- AgentHub owner: `GovernanceV3Plasma.EXECUTOR_LVL_1`

### Agent source

Both predeployed agents are verified deployments of the stock implementations from [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents). The tests verify their bytecode is present and their immutable AgentHub, RangeValidationModule, pool, oracle and update-type wiring matches the configuration registered by this payload.

## References

- Implementation: **TBD — payload PR in aave-proposals-v3**
- Tests: **TBD — payload PR in aave-proposals-v3**
- Agent implementations: [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/5?u=llamarisk)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
