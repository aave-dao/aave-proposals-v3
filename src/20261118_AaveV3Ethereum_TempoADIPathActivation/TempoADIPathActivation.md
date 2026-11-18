---
title: "Tempo a.DI path activation"
author: "Aave Labs"
discussions: "TODO"
---

## Simple Summary

Proposal to register the Ethereum → Tempo adapters on a.DI (Aave Delivery Infrastructure), a technical prerequisite for governance messages from Ethereum to reach Tempo.

## Motivation

To pass messages from Ethereum to Tempo through a.DI, the Ethereum CrossChainController needs at least one valid Ethereum → Tempo adapter enabled.

Any later governance action on Tempo depends on this path, so the Aave governance must approve the a.DI adapter contracts in advance.

## Specification

The proposal payload registers pre-deployed Tempo adapters on the Ethereum a.DI instance by calling `enableBridgeAdapters()` on the Ethereum CrossChainController.

The Ethereum → Tempo path uses Chainlink CCIP, Hyperlane and the Wormhole Executor adapter, with 2 of 3 confirmations required. Tempo has no native bridge to Ethereum, and LayerZero is not used on this path.

Ethereum uses dedicated adapters for Tempo, one per bridge. Each has a `BASE_GAS_LIMIT` of 700,000 (TODO: pending measurement on a Tempo fork). Combined with the 300,000 destination gas limit that Governance sets for all networks, deliveries to Tempo get about 1,000,000 gas without changing the global setting.

The configured adapters for the Ethereum → Tempo path are:

| Adapter           | Ethereum | Tempo |
| ----------------- | -------- | ----- |
| CCIP              | TODO     | TODO  |
| Hyperlane         | TODO     | TODO  |
| Wormhole Executor | TODO     | TODO  |

The CCIP and Wormhole Executor adapters require Tempo in their chain-id mappings, added in [aave-delivery-infrastructure#126](https://github.com/aave-dao/aave-delivery-infrastructure/pull/126). That change builds on [#124](https://github.com/aave-dao/aave-delivery-infrastructure/pull/124) and [#123](https://github.com/aave-dao/aave-delivery-infrastructure/pull/123), which adds the Wormhole Executor adapter. The Hyperlane adapter needs no change.

The a.DI deployments on Tempo are:

| Contract             | Address |
| -------------------- | ------- |
| CrossChainController | TODO    |
| Granular Guardian    | TODO    |

The Tempo CrossChainController runs with emergency mode enabled, using Chainlink's "AAVE Network Emergency Count (Tempo)" feed `0x0Bd931F734D4fA4F6e7566225Ce02B19996D8Ff4`, which currently reads 0.

The Aave Governance deployments on Tempo are:

| Contract            | Address                                      |
| ------------------- | -------------------------------------------- |
| PayloadsController  | TODO                                         |
| Executor Lvl 1      | `0x502fDdcC5586cf94BD0D313798f2006984D53DAF` |
| Governance Guardian | `0xC275a4243AfBF3Eeb4A6AB1D335F8A9cBb206F3F` |
| Aave Labs Guardian  | `0x2B99790c35a401be873FA7Eb514D9220736BB1cA` |

- Executor Lvl 1 is owned by the Tempo PayloadsController before activation, and it is the default admin of the Granular Guardian.
- The Governance Guardian is a 5 of 9 Safe with the same signers as on Ethereum. It holds `SOLVE_EMERGENCY_ROLE` on the Granular Guardian and is the guardian of the PayloadsController.
- The Aave Labs Guardian is a 2 of 5 Safe holding `RETRY_ROLE` on the Granular Guardian.

In an end-to-end mainnet test in October 2026, messages from Ethereum reached Tempo through all three bridges, with 2 of 3 confirmations.

## References

- Adapter implementation: [aave-delivery-infrastructure#126](https://github.com/aave-dao/aave-delivery-infrastructure/pull/126) (TODO: link merged commit)
- Executor Lvl 1: [aave-governance-v3#91](https://github.com/aave-dao/aave-governance-v3/pull/91)
- Payload implementation: TODO (aave-dao/adi-deploy)
- Payload tests: TODO (aave-dao/adi-deploy)
- Diffs: TODO (aave-dao/adi-deploy)
- [Discussion](TODO)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
