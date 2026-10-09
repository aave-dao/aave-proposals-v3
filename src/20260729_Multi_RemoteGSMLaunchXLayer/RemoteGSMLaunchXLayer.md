---
title: "Remote GSM Launch: XLayer"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a"
---

## Simple Summary

Launch a GHO GSM on XLayer (USDG) using the RemoteGSM architecture. The proposal mints 25M GHO via a dedicated `GhoDirectFacilitator` on Ethereum, bridges it to XLayer over CCIP to seed the local `GhoReserve`, and wires up the XLayer USDG GSM.

## Motivation

The RemoteGSM upgrade refactors GHO's stability mechanism into a three-layer design (`GhoDirectFacilitator` → `GhoReserve` → `GSM`), removing the prior requirement that each GSM be its own GHO facilitator and unlocking GSM deployment on L2s, where GHO cannot be minted directly. Deploying a USDG GSM on XLayer extends GHO's stability surface to a new network while keeping mint and bridge control under DAO governance.

## Specification

### Fund the XLayer GHO Reserve

On Ethereum:

- Raise the GHO CCIP bridge limit by 25M (permanent: the bridged 25M becomes part of the locked supply) and temporarily widen the XLayer-lane outbound rate limiter to fit the one-off 25M GHO transfer.
- Register a XLayer-scoped `GhoDirectFacilitator` on the GHO token with a 25M bucket capacity.
- Mint 25M GHO into the payload and bridge it to XLayer via `AaveGhoCcipBridge` (configuring the XLayer destination lane first).
- After bridging, restore the Ethereum ↔ XLayer lane rate-limit config to its prior value. No other lane is modified.

On XLayer:

- Raise the CCIP token-pool facilitator bucket capacity by 25M.
- Temporarily raise the Ethereum-lane inbound rate limiter to receive the 25M GHO.
- On receipt, the `Collector` forwards the 25M GHO to the `GhoReserve`.
- After bridging, restore the XLayer ↔ Ethereum lane rate-limit config to its prior value.

### Wire up XLayer GSM (USDG)

For the GSM:

- Point it at the `GhoReserve`, enroll it as an entity with a 25M GHO reserve limit.
- Grant `SWAP_FREEZER_ROLE` to the asset's `OracleSwapFreezer` and to the XLayer executor.
- Register it in the `GsmRegistry` and grant `CONFIGURATOR_ROLE` to the `GhoGsmSteward`.
- Set the initial exposure cap to 20M of the underlying (6 decimals) and attach the 0% sell / 0.10% buy fee strategy (selling the underlying for GHO is free; buying it back with GHO costs 0.10%).

`LIMIT_MANAGER_ROLE` on the XLayer `GhoReserve` is granted to the XLayer Risk Council.

### GHO CCIP lane capacity

GHO CCIP lane rate-limit capacities are kept the same as before execution. The proposal only widens the Ethereum ↔ XLayer lane temporarily to move the 25M seed, then restores it. The remaining networks (Arbitrum, Avalanche, Base, Gnosis, Mantle, Plasma, Monad, Ink) only increase their CCIP token-pool facilitator bucket capacity by 25M to account for the newly minted supply; their lane rate limits are not touched.

### Execution Order

Execution order:

- Ethereum Part 1 — raises the bridge limit and the Eth→XLayer outbound rate limiter.
- Ethereum Part 2 — mints 25M GHO via the new GhoDirectFacilitator and bridges it. Reverts if executed within the same second as Part 1 (the outbound bucket needs ~1s to refill).
- XLayer Part 1 must execute before the CCIP message arrives, otherwise the inbound rate limit / facilitator bucket rejects the mint and the delivery has to be manually retried on https://ccip.chain.link/.
- XLayer Part 2 — reverts until the bridged GHO reaches the Collector.
- The remaining network payloads (Arbitrum, Avalanche, Base, Gnosis, Ink, Mantle, Plasma, Monad) are independent and can execute any time.
- Manually register OracleSwapFreezer via SAFE post execution.

## References

- Implementation: [AaveV3Ethereum_Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1.sol), [AaveV3Ethereum_Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2.sol), [AaveV3XLayer_Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1.sol), [AaveV3XLayer_Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Arbitrum_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Base_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Gnosis_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Mantle_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Ink](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ink_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Plasma_RemoteGSMLaunchXLayer_20260729.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Monad_RemoteGSMLaunchXLayer_20260729.sol)
- Tests: [AaveV3Ethereum_Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1.t.sol), [AaveV3Ethereum_Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2.t.sol), [AaveV3XLayer_Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1.t.sol), [AaveV3XLayer_Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Arbitrum_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Avalanche_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Base_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Gnosis_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Mantle_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Ink](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ink_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Plasma_RemoteGSMLaunchXLayer_20260729.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Monad_RemoteGSMLaunchXLayer_20260729.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a)
- [Discussion](https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
