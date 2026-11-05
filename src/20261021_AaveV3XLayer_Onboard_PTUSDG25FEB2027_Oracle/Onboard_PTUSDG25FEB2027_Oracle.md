---
title: "Onboard PT-USDG-25FEB2027 to the LlamaRisk PT Risk Oracle"
author: "LlamaRisk"
discussions: "https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/7?u=llamarisk"
---

## Simple Summary

Registers two predeployed risk agents on the Aave-owned AgentHub so that discount rate and eMode risk parameters for PT-USDG-25FEB2027 on Aave V3 X Layer can be maintained automatically from the LlamaRisk PT Risk Oracle, within bounds this proposal sets.

## Motivation

PT-USDG-25FEB2027 is a Pendle principal token onboarded to Aave V3 X Layer by a separate AIP, [Onboard PT-USDG-25FEB2027 on X Layer](https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733), as collateral in eMode category 9. Its fair value depends on an implied discount rate that decays to zero at maturity, so a static discount rate is wrong almost everywhere: too high early, and increasingly too low as maturity approaches. The same drift affects the liquidation threshold and bonus that should apply to it.

LlamaRisk operates an offchain pipeline on Chainlink CRE that tracks the Pendle market, maintains an EMA of the implied rate, and derives both the discount rate and the eMode parameters from it. This proposal is the last link in that chain: it grants the two agent contracts permission to apply those values, and bounds how far each application may move a parameter.

The pipeline publishes to a RiskOracle that only LlamaRisk's router can write to, and the router only accepts reports from the Chainlink CRE forwarder for a workflow owned by the Aave CRE organisation multisig. Governance retains the ability to disable either agent at any time.

## Specification

The payload performs three groups of actions.

**1. Register the discount rate agent.** The payload registers the predeployed `AaveDiscountRateAgent` from `MiscXLayer.LLAMARISK_PT_DISCOUNT_RATE_AGENT` on `MiscXLayer.AGENT_HUB`, consuming `PendleDiscountRateUpdate` records from the LlamaRisk RiskOracle and allowed to act only on PT-USDG-25FEB2027. Minimum delay 2 days, expiration period 2 days.

**2. Register the eMode agent.** The predeployed `AaveEModeAgent` from `MiscXLayer.LLAMARISK_PT_EMODE_AGENT` is registered for the same oracle, consuming `EModeCategoryUpdate` and allowed to act only on eMode category 9. Minimum delay 3 days, expiration period 3 days. Its agent context encodes `AaveV3XLayer.CONFIG_ENGINE`, which it delegatecalls to apply category updates.

Both are registered with `admin` set to `MiscXLayer.PROTOCOL_GUARDIAN`, so a misbehaving agent can be disabled without a governance cycle. Registration stays governance-only: `registerAgent` and `setAgentAdmin` are `onlyOwner`, and the AgentHub is owned by `GovernanceV3XLayer.EXECUTOR_LVL_1`. Both `isAgentPermissioned` and `isMarketsFromAgentEnabled` are left at their defaults.

These are the first agents on the X Layer AgentHub, so they take agent ids 0 and 1. Both agent addresses and the RiskOracle are imported from `MiscXLayer`. Neither agent is registered with a suffixed update type: the LlamaRisk RiskOracle serves this stack alone, so the base types are unambiguous.

**3. Grant RISK_ADMIN and bound the ranges.** `addRiskAdmin` on `AaveV3XLayer.ACL_MANAGER` for both predeployed agents, then `setDefaultRangeConfig` on `MiscXLayer.RANGE_VALIDATION_MODULE` for each parameter each agent can move.

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
| 9   | `PT_USDG_25FEB2027__Stablecoins` |

No reserve configuration is changed by this payload. The snapshot diff is empty by design.

## Deployed Contracts

- `MiscXLayer.LLAMARISK_RISK_ORACLE`: [0x3e0C920C2bdDF6DF87f9A39Ea4db9CF65Cec1EDE](https://www.oklink.com/xlayer/address/0x3e0C920C2bdDF6DF87f9A39Ea4db9CF65Cec1EDE)
- `MiscXLayer.LLAMARISK_RISK_ORACLE_ROUTER`: [0xfC354324B152E2A358A17182d2AF0d3f882c27D2](https://www.oklink.com/xlayer/address/0xfC354324B152E2A358A17182d2AF0d3f882c27D2)
- `MiscXLayer.LLAMARISK_PT_DISCOUNT_RATE_AGENT`: [0xb00251C67dB290D0AD779903bfFeB092DAE76fFa](https://www.oklink.com/xlayer/address/0xb00251C67dB290D0AD779903bfFeB092DAE76fFa)
- `MiscXLayer.LLAMARISK_PT_EMODE_AGENT`: [0x19ae7c91dfd35a4515595cEd305d2102C3b1B02D](https://www.oklink.com/xlayer/address/0x19ae7c91dfd35a4515595cEd305d2102C3b1B02D)
- `CHAINLINK_CRE_FORWARDER`: [0x76c9cf548b4179F8901cda1f8623568b58215E62](https://www.oklink.com/xlayer/address/0x76c9cf548b4179F8901cda1f8623568b58215E62)

The payload references the RiskOracle and both agents directly. The Router and CRE Forwarder are included above to make the complete write path easier to review.

Existing Aave contracts referenced, all from the address book:

- AgentHub: `MiscXLayer.AGENT_HUB`
- RangeValidationModule: `MiscXLayer.RANGE_VALIDATION_MODULE`
- PT-USDG-25FEB2027: `AaveV3XLayerAssets.PT_USDG_25FEB2027_UNDERLYING`
- eMode category 9 (`PT_USDG_25FEB2027__Stablecoins`):
  `AaveV3XLayerEModes.PT_USDG_29OCT2026_PT_USDG_25FEB2027__USDT_GHO_USDC`
- ACL manager: `AaveV3XLayer.ACL_MANAGER`
- Config engine: `AaveV3XLayer.CONFIG_ENGINE`
- Agent admin: `MiscXLayer.PROTOCOL_GUARDIAN`
- AgentHub owner: `GovernanceV3XLayer.EXECUTOR_LVL_1`

### Agent source

Both predeployed agents are verified deployments of the stock implementations from [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents). The tests verify their bytecode is present and their immutable AgentHub, RangeValidationModule, pool, oracle and update-type wiring matches the configuration registered by this payload.

## References

- Agent implementations: [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents)
- Implementation: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/ac40785eb1e3921061d7781acd5e01168ba082d7/src/20261021_AaveV3XLayer_Onboard_PTUSDG25FEB2027_Oracle/AaveV3XLayer_Onboard_PTUSDG25FEB2027_Oracle_20261021.sol)
- Tests: [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/27cb6948f818712371dfb203afd30733fca50c65/src/20261021_AaveV3XLayer_Onboard_PTUSDG25FEB2027_Oracle/AaveV3XLayer_Onboard_PTUSDG25FEB2027_Oracle_20261021.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/7)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
