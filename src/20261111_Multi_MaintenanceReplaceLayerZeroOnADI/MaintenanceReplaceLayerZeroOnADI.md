---
title: "Maintenance: Replace LayerZero bridge adapter on a.DI"
author: "Aave Labs"
discussions: ""
---

## Simple Summary

This proposal removes the LayerZero bridge adapter from the a.DI paths between Ethereum and Polygon, Avalanche, BNB, Monad and Gnosis. On Polygon, Avalanche, BNB and Monad it is replaced by a Wormhole adapter built on the Wormhole Executor. On Gnosis it is replaced by a CCIP adapter. The number of adapters, the required confirmations and the optimal bandwidth stay the same on every path.

## Motivation

a.DI sends every governance message through several bridge providers and only accepts it once enough of them agree. Each path above uses three or four providers, one of which is LayerZero.

LayerZero ended support for Gnosis on 30 September 2026 and no longer verifies or delivers messages to it. Since then the Ethereum → Gnosis path has run on two of its three adapters, which is exactly its required confirmation count, so a single further outage would stop governance messages to Gnosis.

This proposal starts moving a.DI off LayerZero. It replaces LayerZero with a provider each path does not already use, so the paths keep their current level of redundancy:

- Polygon, Avalanche, BNB and Monad already use CCIP and Hyperlane, so LayerZero is replaced with Wormhole.
- Gnosis already uses its native bridge and Hyperlane. Wormhole's Executor does not support Gnosis, so LayerZero is replaced with CCIP.

The Wormhole adapter a.DI used so far relies on Wormhole's Standard Relayer, which stopped automatic delivery on 1 April 2026. The new adapter uses the Wormhole Executor instead.

Celo, Sonic and Plasma are not part of this proposal and keep their current configuration.

## Specification

The proposal executes one pre-deployed payload on each network. Each payload calls `disableBridgeAdapters` / `enableBridgeAdapters` and `disallowReceiverBridgeAdapters` / `allowReceiverBridgeAdapters` on the CrossChainController.

### Ethereum

Payload: [0x8312F5ad259AAB7A3f9C090746B3be80643147ea](https://etherscan.io/address/0x8312F5ad259AAB7A3f9C090746B3be80643147ea)

Forwarding paths:

| Destination | Removed (current → destination)                                                                       | Added (current → destination)                                                                        |
| ----------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Polygon     | LayerZero `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` → `0x7FAE7765abB4c8f778d57337bB720d0BC53057e3` | Wormhole `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` → `0xe556210CfCDd4Ce198B6742E7DF8B21C3460A1d0` |
| Avalanche   | LayerZero `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` → `0x10f02995a399C0dC0FaF29914220E9C1bCdE8640` | Wormhole `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` → `0x758540A2f8eB9f37d5fcc064A5eB1b12f7D1390c` |
| BNB         | LayerZero `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` → `0xa5cc218513305221201f196760E9e64e9D49d98A` | Wormhole `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` → `0x4fab391411EB51694763731C041c8E3d4bE006B6` |
| Monad       | LayerZero `0xf9482751C9937fF940b93B5921B8984645dD0a53` → `0xb544322f8e59B71d7875e0E2EbceB7f3783257BE` | Wormhole `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` → `0xe7cb2DbbEfCB82aF2EB3E6719103a0EE3dC39773` |
| Gnosis      | LayerZero `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` → `0x9b6f5ef589A3DD08670Dd146C11C4Fb33E04494F` | CCIP `0x458E8e349192a909B400ecE95DEe16A13665e7a8` → `0x4018c061c70e186699cb3f0520745B56d261204d`     |

Receiving paths:

| Origin    | Removed                                                | Added                                                 |
| --------- | ------------------------------------------------------ | ----------------------------------------------------- |
| Polygon   | LayerZero `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` | Wormhole `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` |
| Avalanche | LayerZero `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` | Wormhole `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` |

The LayerZero adapter `0x8410d9BD353b420ebA8C48ff1B0518426C280FCC` stays enabled on the Ethereum → Celo path.

### Remote networks

Each remote network swaps the adapter that receives messages from Ethereum. Polygon and Avalanche also send messages to Ethereum, so they swap the same adapter on their forwarding path to Ethereum.

| Network   | Payload                                                                                                                  | Removed                                                | Added                                                 |
| --------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ | ----------------------------------------------------- |
| Polygon   | [0x5665adC50a076A17087Ebb32965E7A08142C9b83](https://polygonscan.com/address/0x5665adC50a076A17087Ebb32965E7A08142C9b83) | LayerZero `0x7FAE7765abB4c8f778d57337bB720d0BC53057e3` | Wormhole `0xe556210CfCDd4Ce198B6742E7DF8B21C3460A1d0` |
| Avalanche | [0x04C02073e13fBc162E393280E5030F92E6B82dbe](https://snowscan.xyz/address/0x04C02073e13fBc162E393280E5030F92E6B82dbe)    | LayerZero `0x10f02995a399C0dC0FaF29914220E9C1bCdE8640` | Wormhole `0x758540A2f8eB9f37d5fcc064A5eB1b12f7D1390c` |
| BNB       | [0x250f199fE5b8672c263a4b1e6476709a3F459cF3](https://bscscan.com/address/0x250f199fE5b8672c263a4b1e6476709a3F459cF3)     | LayerZero `0xa5cc218513305221201f196760E9e64e9D49d98A` | Wormhole `0x4fab391411EB51694763731C041c8E3d4bE006B6` |
| Monad     | [0xdeccc59707d77b8F8fca4B9acAc9F94eEEC95A65](https://monadscan.com/address/0xdeccc59707d77b8F8fca4B9acAc9F94eEEC95A65)   | LayerZero `0xb544322f8e59B71d7875e0E2EbceB7f3783257BE` | Wormhole `0xe7cb2DbbEfCB82aF2EB3E6719103a0EE3dC39773` |
| Gnosis    | [0x22D753e7c05EE2D23B4f5c6C9428fb7229df4abe](https://gnosisscan.io/address/0x22D753e7c05EE2D23B4f5c6C9428fb7229df4abe)   | LayerZero `0x9b6f5ef589A3DD08670Dd146C11C4Fb33E04494F` | CCIP `0x4018c061c70e186699cb3f0520745B56d261204d`     |

### Unchanged configuration

| Path                 | Adapters | Required confirmations | Optimal bandwidth                              |
| -------------------- | -------- | ---------------------- | ---------------------------------------------- |
| Ethereum ↔ Polygon   | 4        | 3                      | 3 (Ethereum → Polygon), 4 (Polygon → Ethereum) |
| Ethereum ↔ Avalanche | 3        | 2                      | 2                                              |
| Ethereum → BNB       | 3        | 2                      | 2                                              |
| Ethereum → Monad     | 3        | 2                      | 2                                              |
| Ethereum → Gnosis    | 3        | 2                      | 2                                              |

### New adapters

| Adapter            | Network   | Address                                      | Trusted remotes                             |
| ------------------ | --------- | -------------------------------------------- | ------------------------------------------- |
| Wormhole Executor  | Ethereum  | `0xA2A952378DFe468ddb793c4574a0c27Dd81FA560` | Polygon and Avalanche CrossChainControllers |
| Wormhole Executor  | Polygon   | `0xe556210CfCDd4Ce198B6742E7DF8B21C3460A1d0` | Ethereum CrossChainController               |
| Wormhole Executor  | Avalanche | `0x758540A2f8eB9f37d5fcc064A5eB1b12f7D1390c` | Ethereum CrossChainController               |
| Wormhole Executor  | BNB       | `0x4fab391411EB51694763731C041c8E3d4bE006B6` | Ethereum CrossChainController               |
| Wormhole Executor  | Monad     | `0xe7cb2DbbEfCB82aF2EB3E6719103a0EE3dC39773` | Ethereum CrossChainController               |
| CCIP (Gnosis path) | Ethereum  | `0x458E8e349192a909B400ecE95DEe16A13665e7a8` | none (send only)                            |
| CCIP               | Gnosis    | `0x4018c061c70e186699cb3f0520745B56d261204d` | Ethereum CrossChainController               |

The Wormhole Executor adapters use the Wormhole Labs relay provider. Executor fees are paid in the native token from each CrossChainController's balance, as with the other adapters.

## Security

The Wormhole Executor adapter was audited by Certora ([report](https://github.com/aave-dao/aave-delivery-infrastructure/blob/cd799974/security/Certora%20-%20Aave%20Wormhole%20a.DI%20Adapter%20-%20Final%20Report.pdf)). The CCIP adapter is the existing a.DI CCIP adapter with Gnosis added to its chain id mapping ([diff](https://github.com/aave-dao/aave-delivery-infrastructure/pull/124)).

## References

- Payload implementation: [Ethereum](https://github.com/aave-dao/adi-deploy/blob/a5c1a09/src/adapter_payloads/Ethereum_Replace_LZ_Payload.sol), [Polygon, Avalanche, BNB, Monad, Gnosis](https://github.com/aave-dao/adi-deploy/blob/a5c1a09/src/adapter_payloads/Remote_Replace_LZ_Payload.sol)
- Adapter implementation: [WormholeExecutorAdapter](https://github.com/aave-dao/aave-delivery-infrastructure/pull/123), [CCIPAdapter](https://github.com/aave-dao/aave-delivery-infrastructure/pull/124)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3Ethereum_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3Polygon_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3Avalanche_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3BNB_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3Monad_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3Gnosis_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol)
- [LayerZero support update, 24 July 2026](https://layerzero.network/blog/support-update-july-24-2026)
- [Wormhole Standard Relayer deprecation](https://wormhole.com/docs/protocol/infrastructure/relayers/relayer)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
