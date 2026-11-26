---
title: "Caps Rate Limiter Activation"
author: "LlamaRisk"
discussions: "https://governance.aave.com/t/arfc-dynamic-caps-oracle-rate-limiter/26219"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0xd80bf15385e4f525108133bee1460b1907aabd1013b67821936fd52f3140793d"
---

## Simple Summary

Activates LlamaGuard Caps, the borrow rate limiter, on Aave V3 Arbitrum. The payload registers a Raise agent and a Cut agent on the Aave-owned AgentHub, grants both RISK_ADMIN, and lists WBTC, WETH, USD₮0 and USDC in the caps range validation module.

## Motivation

A static borrow cap limits how much can be borrowed, not how fast. Its headroom is open to any borrower at any time, so an attacker holding bad collateral can draw all of it in one block. The rate limiter keeps each borrow cap one buffer above debt and refills that buffer at most once every 30 minutes. Everyday borrowing still has instant access to liquidity. A large draw has to wait for each refill, which gives the Protocol Guardian time to respond.

The ARFC passed Snapshot on 20 November 2026 with 371,959 votes for and none against, and Aave Labs agreed on Arbitrum as the first market.

## Specification

The payload performs three groups of actions.

**1. Grant RISK_ADMIN.** `addRiskAdmin` on `AaveV3Arbitrum.ACL_MANAGER` for `LLAMARISK_CAPS_RAISE_AGENT` and `LLAMARISK_CAPS_CUT_AGENT`. Both are stock `AaveBorrowCapAgent` deployments. They delegatecall `AaveV3Arbitrum.CONFIG_ENGINE`, and because delegatecall preserves the caller, the PoolConfigurator sees the agent when it calls `setBorrowCap`, so the role has to sit on the agent.

**2. Register the agents.** Both are registered on `MiscArbitrum.AGENT_HUB` with `MiscArbitrum.PROTOCOL_GUARDIAN` as agent admin, so either agent can be disabled without a governance cycle.

| Agent | Agent id | Reads updates from              | Update type            | Minimum delay | Expiration period |
| ----- | -------- | ------------------------------- | ---------------------- | ------------- | ----------------- |
| Raise | 3        | `LLAMARISK_CAPS_RISK_ORACLE`    | `BorrowCapUpdate_Core` | 30 minutes    | 1 minute          |
| Cut   | 4        | `LLAMARISK_CAPS_REDUCER_ORACLE` | `BorrowCapUpdate_Core` | none          | 1 minute          |

Both agents are permissioned, with `LLAMARISK_CAPS_RISK_ORACLE_ROUTER` as their only sender, and read their markets from the agent (`isMarketsFromAgentEnabled`). Only a routed CRE report can execute them. A cut can't be bundled with a repay in the same transaction, and pausing the Router also stops a raise that is still pending in the RiskOracle. The one-minute expiration limits how long a published raise stays applicable. Both settings follow from the Certora review (M-01 and L-04).

The AgentHub holds agents 0 to 2, so these registrations take ids 3 and 4. The workflow configs name these ids. If another registration lands first, the payload reverts instead of wiring the module to the wrong agents.

**3. Configure the range validation module.** `LLAMARISK_CAPS_RANGE_VALIDATION_MODULE` is owned by `GovernanceV3Arbitrum.EXECUTOR_LVL_1`. The payload calls `setAgent` for agent 3 (raise) and agent 4 (cut), `setBounds` for the Risk Council limits, and `setRateLimitConfig` once per reserve. `setAgent` checks that each agent points to this AgentHub, this module and the Arbitrum Pool.

| Reserve | Buffer      | Buffer ceiling | Buffer floor | Cut band | Hard maximum            |
| ------- | ----------- | -------------- | ------------ | -------- | ----------------------- |
| WBTC    | 10% of debt | 233            | 10           | 10%      | borrow cap at execution |
| WETH    | 10% of debt | 8,282          | 332          | 10%      | borrow cap at execution |
| USD₮0   | 10% of debt | 15,008,779     | 600,352      | 10%      | borrow cap at execution |
| USDC    | 10% of debt | 15,003,601     | 600,145      | 10%      | borrow cap at execution |

Amounts are in tokens. The buffer ceiling is $15M at Aave oracle prices of 15 November 2026 and the floor is a 25th of the ceiling. The ARFC gave $25M and $1M as indicative values; Stage 1 starts lower, and the Risk Council can raise the ceiling within the limits below. The hard maximum is read from the Pool when the payload executes, so it stays the value the Risk Stewards set.

A raise sets the cap to debt plus one buffer, at most once every 30 minutes per reserve. A cut brings the cap back to debt plus one buffer once headroom exceeds the buffer by more than the band.

| Risk Council limit (`setBounds`, borrow caps)                                  | Value |
| ------------------------------------------------------------------------------ | ----- |
| Max buffer share (`alphaBpsLimit`)                                             | 20%   |
| Max cut band (`cutBandBpsLimit`)                                               | 20%   |
| Max raise of a hard maximum or buffer ceiling, per cooldown (`maxIncreaseBps`) | 50%   |
| Cooldown between two such raises                                               | 1 day |

The Risk Council can lower any parameter, retire a reserve and hold off cuts for up to 24 hours. Only governance can list a reserve or change these limits.

GHO is not listed: its caps stay with the Risk Stewards. Every other Arbitrum reserve is frozen or has borrowing disabled. Supply caps are unchanged.

### Roles

| Role         | Holder                                      | Can                                                                     |
| ------------ | ------------------------------------------- | ----------------------------------------------------------------------- |
| Owner        | `GovernanceV3Arbitrum.EXECUTOR_LVL_1`       | list reserves, set the Risk Council limits, replace the Risk Council    |
| Risk Council | Risk Council Safe (Aave Labs and LlamaRisk) | tune parameters within the limits, hold cuts, retire a reserve          |
| Agent admin  | `MiscArbitrum.PROTOCOL_GUARDIAN`            | disable either agent, change the delay and the permissioned senders     |
| Operator     | `LLAMARISK_RISK_ORACLE_ADMIN_SAFE`          | own the Router and the RiskOracle, set the trigger and margin per asset |

Each part can be switched off on its own. The Protocol Guardian can disable either agent, the operator can disable the Router route or one asset in the registry, and the Risk Council can retire a reserve, which hands its cap back to the Risk Stewards. A frozen or paused reserve never gets a raise.

No reserve configuration is changed by this payload. The snapshot diff is empty by design.

## Deployed Contracts

- `LLAMARISK_RISK_ORACLE_ADMIN_SAFE`: [0x1a0267E9E5929a5914Ae9DbBf23Bc07B14365471](https://arbiscan.io/address/0x1a0267E9E5929a5914Ae9DbBf23Bc07B14365471)
- `LLAMARISK_CAPS_RISK_ORACLE`: TODO
- `LLAMARISK_CAPS_RISK_ORACLE_ROUTER`: TODO
- `LLAMARISK_CAPS_PARAMETER_REGISTRY`: TODO
- `LLAMARISK_CAPS_RANGE_VALIDATION_MODULE`: TODO
- `LLAMARISK_CAPS_REDUCER_ORACLE`: TODO
- `LLAMARISK_CAPS_RAISE_AGENT`: TODO
- `LLAMARISK_CAPS_CUT_AGENT`: TODO
- Risk Council Safe: [0x3Be327F22eB4BD8042e6944073b8826dCf357Aa2](https://arbiscan.io/address/0x3Be327F22eB4BD8042e6944073b8826dCf357Aa2)
- `CHAINLINK_CRE_FORWARDER`: [0xF8344CFd5c43616a4366C34E3EEE75af79a74482](https://arbiscan.io/address/0xF8344CFd5c43616a4366C34E3EEE75af79a74482)

The payload references the agents, the RiskOracle, the reducer oracle, the Router and the range validation module directly. The other contracts are listed to make the full write path easier to review.

Existing Aave contracts referenced, all from the address book:

- AgentHub: `MiscArbitrum.AGENT_HUB`
- ACL manager: `AaveV3Arbitrum.ACL_MANAGER`
- Config engine: `AaveV3Arbitrum.CONFIG_ENGINE`
- Pool: `AaveV3Arbitrum.POOL`
- Agent admin: `MiscArbitrum.PROTOCOL_GUARDIAN`
- Owner of the AgentHub and the range validation module: `GovernanceV3Arbitrum.EXECUTOR_LVL_1`

### Contract source

The agents are stock `AaveBorrowCapAgent` deployments from [aave-dao/aave-risk-agents](https://github.com/aave-dao/aave-risk-agents). The range validation module, reducer oracle and parameter registry are from [llama-risk/llamaguard-contracts](https://github.com/llama-risk/llamaguard-contracts) at TODO, audited by Certora (report: TODO). The tests check that every contract has bytecode and that its immutable AgentHub, module and Pool wiring matches what this payload registers.

## References

- Implementation: TODO
- Tests: TODO
- [Snapshot](https://snapshot.box/#/s:aavedao.eth/proposal/0xd80bf15385e4f525108133bee1460b1907aabd1013b67821936fd52f3140793d)
- [Discussion](https://governance.aave.com/t/arfc-dynamic-caps-oracle-rate-limiter/26219)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
