---
title: "Caps Rate Limiter Activation"
author: "LlamaRisk"
discussions: "https://governance.aave.com/t/arfc-dynamic-caps-oracle-rate-limiter/26219"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0xd80bf15385e4f525108133bee1460b1907aabd1013b67821936fd52f3140793d"
---

<!-- DRAFT. Every TODO is filled once the production stack is deployed (PXE-238) and the Certora final report is linked. -->

## Simple Summary

Activates LlamaGuard Caps, the borrow rate limiter, on Aave V3 Arbitrum. The payload registers a Raise agent and a Cut agent on the Aave-owned AgentHub, grants them RISK_ADMIN, and lists WBTC, WETH, USD₮0 and USDC in the rate limiter's range validation module with the parameters below.

## Motivation

A static borrow cap limits how much can be borrowed but not how fast. Its headroom is open to any borrower at any time, so an attacker with bad collateral can draw all of it in one block. The rate limiter keeps each borrow cap one buffer above debt and refills that buffer at most once per delay. Everyday borrowing keeps instant access to liquidity, while a large draw has to wait for each refill, which gives the Protocol Guardian time to respond.

The ARFC passed Snapshot on 20 November 2026 with 371,959 votes for and none against. Aave Labs agreed on Arbitrum as the first market on 10 November.

## Specification

The payload performs three groups of actions.

**1. Grant RISK_ADMIN.** `addRiskAdmin` on `AaveV3Arbitrum.ACL_MANAGER` for the Raise agent and the Cut agent. Both agents are stock `AaveBorrowCapAgent` deployments. They delegatecall `AaveV3Arbitrum.CONFIG_ENGINE`, so the PoolConfigurator sees the agent as the caller of `setBorrowCap`, and the role has to sit on the agent.

The `CapsBorrowForwarder` (atomic cap raise and borrow) is not deployed or activated by this proposal.

**2. Register the agents on `MiscArbitrum.AGENT_HUB`.**

|                     | Raise agent                                       | Cut agent                        |
| ------------------- | ------------------------------------------------- | -------------------------------- |
| Agent id            | 3                                                 | 4                                |
| Reads updates from  | LlamaRisk caps RiskOracle                         | `CapsReducerOracle`              |
| Update type         | `BorrowCapUpdate_Core`                            | `BorrowCapUpdate_Core`           |
| Minimum delay       | 30 minutes                                        | none                             |
| Expiration period   | 1 minute                                          | 1 minute                         |
| Permissioned sender | LlamaGuard Router only                            | LlamaGuard Router only           |
| Agent admin         | `MiscArbitrum.PROTOCOL_GUARDIAN`                  | `MiscArbitrum.PROTOCOL_GUARDIAN` |
| Markets             | read from the agent (`isMarketsFromAgentEnabled`) | read from the agent              |

The AgentHub holds agents 0 to 2 today. The payload reverts if the ids it receives are not 3 and 4, so it cannot wire the module to agents registered by another proposal in between.

Both agents are permissioned to the Router, so only a routed Chainlink CRE report can execute them. A cut can then not be bundled with a repay in one transaction, and pausing the Router stops any raise still pending in the RiskOracle. The one-minute expiration limits how long a published raise can be applied. Both follow from the Certora review (M-01 and L-04).

**3. Configure the range validation module.** The module (`CapsRangeValidationModuleV3`) is owned by `GovernanceV3Arbitrum.EXECUTOR_LVL_1`. The payload:

- registers agent 3 as the Raise agent and agent 4 as the Cut agent (`setAgent`). The module checks that each agent points to this AgentHub, this module and the Arbitrum Pool;
- sets the limits within which the Risk Council can tune parameters (`setBounds`);
- lists each reserve (`setRateLimitConfig`). The hard maximum (`maxCap`) is the reserve's borrow cap when the payload executes, so the cap stays at or below the value the Risk Stewards set.

Every raise and cut the agents apply is checked again by the module against live Pool state in the executing block, whatever the workflow signed.

### Parameters

| Reserve | Buffer (share of debt) | Buffer ceiling   | Buffer floor  | Cut band | Hard maximum            |
| ------- | ---------------------- | ---------------- | ------------- | -------- | ----------------------- |
| WBTC    | 10%                    | 233 WBTC         | 10 WBTC       | 10%      | borrow cap at execution |
| WETH    | 10%                    | 8,282 WETH       | 332 WETH      | 10%      | borrow cap at execution |
| USD₮0   | 10%                    | 15,008,779 USD₮0 | 600,352 USD₮0 | 10%      | borrow cap at execution |
| USDC    | 10%                    | 15,003,601 USDC  | 600,145 USDC  | 10%      | borrow cap at execution |

The buffer ceiling is $15M at Aave oracle prices of 15 November 2026 and the floor is a 25th of it. A raise sets the cap to debt plus one buffer and happens at most once every 30 minutes per reserve. A cut returns the cap to debt plus one buffer once headroom exceeds the buffer by more than the band.

<!-- TODO: the ARFC's indicative ceiling and floor were $25M and $1M; say here why Stage 1 starts at $15M and $0.6M. -->

Risk Council limits (`setBounds`, borrow caps):

| Limit                                                                         | Value |
| ----------------------------------------------------------------------------- | ----- |
| Max buffer share (`alphaBpsLimit`)                                            | 20%   |
| Max cut band (`cutBandBpsLimit`)                                              | 20%   |
| Max raise of a hard maximum or buffer ceiling per cooldown (`maxIncreaseBps`) | 50%   |
| Cooldown between two such raises                                              | 1 day |

The Risk Council can lower any parameter, retire a reserve, and hold off cuts for up to 24 hours. Only governance can list a reserve or change these limits.

### Reserves not listed

GHO stays out of the rate limiter: its caps stay with the Risk Stewards. Every other Arbitrum reserve is frozen or has borrowing disabled at the time of writing. Supply caps are unchanged.

### Roles

| Role                                 | Holder                                                                                                                                                            | Can                                                                         |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Owner of the module and the registry | `GovernanceV3Arbitrum.EXECUTOR_LVL_1`                                                                                                                             | list reserves, set Risk Council limits, replace the Risk Council            |
| Risk Council                         | Risk Council Safe (Aave Labs and LlamaRisk), [0x3Be327F22eB4BD8042e6944073b8826dCf357Aa2](https://arbiscan.io/address/0x3Be327F22eB4BD8042e6944073b8826dCf357Aa2) | tune parameters within the limits, hold cuts, retire a reserve              |
| Agent admin                          | `MiscArbitrum.PROTOCOL_GUARDIAN`                                                                                                                                  | disable either agent, change the delay and the permissioned senders         |
| Operator                             | LlamaRisk Safe                                                                                                                                                    | run the workflow and the Router, set the trigger and margin in the registry |

Each part can be switched off on its own: the Protocol Guardian can disable either agent, the LlamaRisk Safe can disable the Router route or pause one reserve in the registry, and the Risk Council can retire a reserve, which returns its cap to the Risk Stewards. A freeze or pause of a reserve always blocks raises.

No reserve configuration is changed by this payload. The snapshot diff is empty by design.

## Deployed Contracts

<!-- TODO(PXE-238): fill from the production deployment and verify on Arbiscan. -->

- `LLAMARISK_CAPS_RISK_ORACLE` (RiskOracle): TODO
- `LLAMARISK_CAPS_RISK_ORACLE_ROUTER` (LlamaguardRiskOracleRouter): TODO
- `LLAMARISK_CAPS_PARAMETER_REGISTRY` (CapsParameterRegistry): TODO
- `LLAMARISK_CAPS_RANGE_VALIDATION_MODULE` (CapsRangeValidationModuleV3): TODO
- `LLAMARISK_CAPS_REDUCER_ORACLE` (CapsReducerOracle): TODO
- `LLAMARISK_CAPS_RAISE_AGENT` (AaveBorrowCapAgent): TODO
- `LLAMARISK_CAPS_CUT_AGENT` (AaveBorrowCapAgent): TODO
- Chainlink KeystoneForwarder: [0xF8344CFd5c43616a4366C34E3EEE75af79a74482](https://arbiscan.io/address/0xF8344CFd5c43616a4366C34E3EEE75af79a74482)

Existing Aave contracts referenced, all from the address book:

- AgentHub: `MiscArbitrum.AGENT_HUB`
- ACL manager: `AaveV3Arbitrum.ACL_MANAGER`
- Config engine: `AaveV3Arbitrum.CONFIG_ENGINE`
- Pool: `AaveV3Arbitrum.POOL`
- Agent admin: `MiscArbitrum.PROTOCOL_GUARDIAN`
- Owner: `GovernanceV3Arbitrum.EXECUTOR_LVL_1`

## Security

The four contracts and the raise workflow were audited by Certora. All findings are addressed; see the report and LlamaRisk's response.

- Certora report: TODO
- Findings and response: TODO

## References

- Contracts: [llama-risk/llamaguard-contracts](https://github.com/llama-risk/llamaguard-contracts) at TODO
- Workflow: [llama-risk/llamaguard-risk-oracles](https://github.com/llama-risk/llamaguard-risk-oracles) at TODO
- Implementation: TODO
- Tests: TODO
- [Snapshot](https://snapshot.box/#/s:aavedao.eth/proposal/0xd80bf15385e4f525108133bee1460b1907aabd1013b67821936fd52f3140793d)
- [Discussion](https://governance.aave.com/t/arfc-dynamic-caps-oracle-rate-limiter/26219)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
