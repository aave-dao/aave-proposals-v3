---
title: "Aave V4 Sentora Market Activation"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/arfc-sentora-externally-curated-hub-spoke-framework-on-aave-v4/25723"
snapshot: "TODO"
---

## Simple Summary

This payload activates the Sentora curated market on Aave V4 Ethereum: one Hub (Sentora) and three Spokes (RLUSD Yield, OUSD Yield, Bluechip).

## Motivation

TODO

## Specification

The payload is executed by the Sentora Executor through the Sentora PermissionedPayloadsController, after its timelock. It:

1. Accepts the ownership of the Giver, Taker and Config position managers, the NativeTokenGateway and the SignatureGateway, transferred to the Sentora Executor during the deployment handover.
2. Unhalts every asset-spoke pair on the Sentora Hub via `HubConfigurator.updateSpokeHalted`, which the market configuration halted at deployment.

The TreasurySpoke ownership is accepted separately by the Sentora Fee Admin.

## References

- Implementation: [AaveV4EthereumSentora](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261009_AaveV4EthereumSentora_SentoraMarketActivation/AaveV4EthereumSentora_SentoraMarketActivation_20261009.sol)
- Tests: [AaveV4EthereumSentora](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261009_AaveV4EthereumSentora_SentoraMarketActivation/AaveV4EthereumSentora_SentoraMarketActivation_20261009.t.sol)
- Snapshot: TODO
- [Discussion](https://governance.aave.com/t/arfc-sentora-externally-curated-hub-spoke-framework-on-aave-v4/25723)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
