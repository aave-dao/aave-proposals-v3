---
title: "Permissioned GSM: USAT on Aave V4 Avalanche"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2"
---

## Simple Summary

TokenLogic proposes a Permissioned GHO Stability Module (GSM) that allows approved counterparties to exchange eligible assets for GHO and vice versa. The module will retain the existing GSM functionality while introducing participant-level access controls.
The first application will support USAT on Avalanche. Under this arrangement, USAT remains supplied to Aave V4 while the GSM holds waCoreUSAT, representing USAT supplied to Aave V4 through the USAT Tokenization Spoke. The proposal includes the funding and configuration needed to launch this instance.

## Motivation

[USAT](https://usat.io/faq/) is a USD-backed stablecoin issued by Anchorage Digital Bank, N.A.

The GSM lets an approved counterparty swap between USAT and GHO on Avalanche while the USAT stays supplied to Aave V4.

For this initial launch, an approved counterparty will deposit USAT into the Aave V4 Tokenization Spoke and receive waCoreUSAT. The counterparty will then separately exchange waCoreUSAT for GHO through the Permissioned GSM, which will hold the waCoreUSAT. Returning GHO will allow the counterparty to recover waCoreUSAT. Redemption for underlying USAT will depend on the selected integration and available liquidity.

## Specification

TokenLogic proposes deploying a permissioned RemoteGSM on Avalanche to exchange waCoreUSAT for GHO and vice versa.

### Funding the GSM

A new GHO Reserve on Avalanche will provide GHO for the USAT GSM. The initial allocation of 65,000,000 GHO will be newly minted on Ethereum through a new GhoDirectFacilitator for Avalanche, with a 65,000,000 GHO bucket. This follows the existing practice of one GhoDirectFacilitator per remote GSM network, as for Arbitrum, Plasma and Monad, so that each facilitator's minted amount shows the GHO backing that network's GSMs. We will bridge the initial allocation to the Avalanche Collector, which will then transfer the funds to the reserve. To support this transfer, we will permanently increase the bridge limit by the initial allocation and temporarily increase the Ethereum → Avalanche lane rate limits, then restore the ongoing lane settings once the transfer is complete, as we have done previously when deploying new GSMs on Plasma, Monad, and Arbitrum.

### Access and Administration

The GSM is permissioned. Each swap direction has its own access control:

- **Sell:** swap waCoreUSAT for GHO.
- **Buy:** swap GHO for waCoreUSAT.

An address can have access to one direction or to both directions. The proposal grants bidirectional swap permissions to three addresses associated with the first counterparty of the Permissioned GSM. The first two are intended for testing and will later be removed by the GHO Risk Council.

- Testing address 1: [`0x1aE7FE695Fe1b71D93e0aaA0dd1CdD3890B83586`](https://snowscan.xyz/address/0x1aE7FE695Fe1b71D93e0aaA0dd1CdD3890B83586) (controlled by Tether)
- Testing address 2: [`0x966cAF619A159F35721b27fEE9147bE99a255991`](https://snowscan.xyz/address/0x966cAF619A159F35721b27fEE9147bE99a255991) (controlled by Tether)
- Final counterparty address: [`0xC7b219Ae49Fb6418576E53F9068717D4826F1A0f`](https://snowscan.xyz/address/0xC7b219Ae49Fb6418576E53F9068717D4826F1A0f) (controlled by Tether)

The AIP gives the GHO Risk Council ([`0x8513e6F37dBc52De87b166980Fa3F50639694B60`](https://snowscan.xyz/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60)) the swap access manager role. With this role, the GHO Risk Council can:

- give or remove buy access, sell access, or both, for any address after the AIP executes;
- open buys, sells, or both to all addresses, and close them again.

Aave Governance keeps the same role and can revoke the GHO Risk Council's role at any time.

The GSM will be deployed without a fee strategy, with buy and sell fees set to 0%. Introducing a non-zero fee will require an AIP to deploy and configure a fee strategy. Once a fee strategy is in place, the GHO Risk Council will be able to adjust fees within the limits specified below. The GHO Risk Council will also be able to adjust the exposure cap within the limits specified below.

Only the GHO Risk Council ([`0x8513e6F37dBc52De87b166980Fa3F50639694B60`](https://snowscan.xyz/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60)) will be authorized to call the GHO GSM Steward's parameter-update functions.

#### Initial USAT Configuration

| Parameter                | Proposed Configuration                                                                                                                                                    |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Network                  | Avalanche                                                                                                                                                                 |
| Underlying Asset         | USAT                                                                                                                                                                      |
| Underlying Asset Address | [`0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b`](https://snowscan.xyz/address/0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b)                                                   |
| Aave Market              | Aave V4                                                                                                                                                                   |
| Configured GSM Asset     | waCoreUSAT                                                                                                                                                                |
| Receipt Token Address    | [`0x653F2541E7d51a846e92fA6F7866bA92e465a379`](https://snowscan.xyz/address/0x653F2541E7d51a846e92fA6F7866bA92e465a379)                                                   |
| GSM Implementation       | Permissioned RemoteGSM                                                                                                                                                    |
| GSM                      | [`0xF6b70344b92cAb2D23c96eA834bbb45ADbdd6c40`](https://snowscan.xyz/address/0xF6b70344b92cAb2D23c96eA834bbb45ADbdd6c40)                                                   |
| GHO GSM Steward          | [`0x07ad9BEA5626ceAbcf857aaB1e398dd2327C901b`](https://snowscan.xyz/address/0x07ad9BEA5626ceAbcf857aaB1e398dd2327C901b)                                                   |
| GSM Registry             | The AIP adds the GSM to the Avalanche GsmRegistry [`0x0a0dFf46122dFdc2aF0D5D66f23BA8f78bf17edF`](https://snowscan.xyz/address/0x0a0dFf46122dFdc2aF0D5D66f23BA8f78bf17edF) |

#### Liquidity and Economic Parameters

| Parameter                          | Proposed Configuration                                                                                                                                        |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GHO Reserve                        | [`0x15f22f39FD7b3612840cF0De49b6f9C4879Aa642`](https://snowscan.xyz/address/0x15f22f39FD7b3612840cF0De49b6f9C4879Aa642)                                       |
| Remote GSM Draw Limit              | 25,000,000 GHO                                                                                                                                                |
| Initial GHO Funding                | 65,000,000 GHO                                                                                                                                                |
| GHO Funding Source                 | New GhoDirectFacilitator on Ethereum: [`0x207b377b904D5e227337F7E708e27Dfa34F6381A`](https://etherscan.io/address/0x207b377b904D5e227337F7E708e27Dfa34F6381A) |
| waCoreUSAT Exposure Cap            | 20,000,000 waCoreUSAT                                                                                                                                         |
| Buy Fee (GHO → waCoreUSAT)         | 0%                                                                                                                                                            |
| Sell Fee (waCoreUSAT → GHO)        | 0%                                                                                                                                                            |
| Pricing Strategy                   | [`0x863F2106C5543266b43991Fe842551B0E30FBF0d`](https://snowscan.xyz/address/0x863F2106C5543266b43991Fe842551B0E30FBF0d)                                       |
| Receipt Token Conversion           | at `convertToAssets()` rate                                                                                                                                   |
| Fee and Yield Recipient            | Configured treasury: [`0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0`](https://snowscan.xyz/address/0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0)                  |
| Fee Strategy                       | no fee strategy (both fees are 0%)                                                                                                                            |
| Automatic Freeze Strategy / Oracle | no automatic freeze strategy - price is hardcoded to 1                                                                                                        |

#### Bridge Configuration

| **Parameter**                                                | **Proposed Configuration**                                                                                                                            |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Funding Route and Bridge Endpoint Source                     | [`0x7F2f96fcdC3A29Be75938d2aC3D92E7006919fe6`](https://etherscan.io/address/0x7F2f96fcdC3A29Be75938d2aC3D92E7006919fe6) (Mainnet AaveGhoCcipBridge)   |
| Funding Route and Bridge Endpoint Destination                | [`0xaf9F841De7477F35D6339943C1E6f0c101bcA621`](https://snowscan.xyz/address/0xaf9F841De7477F35D6339943C1E6f0c101bcA621) (Avalanche AaveGhoCcipBridge) |
| Initial Inbound Capacity, Ethereum from Avalanche (GHO)      | 5,000,000 (unchanged)                                                                                                                                 |
| Initial Outbound Capacity, Ethereum → Avalanche (GHO)        | 71,500,000 (Initial GHO funding \* 110%)                                                                                                              |
| Initial Refill Rate (GHO/s)                                  | 64,999,999 (initial GHO funding - 1)                                                                                                                  |
| Ongoing Inbound Capacity (GHO)                               | 5,000,000 (current)                                                                                                                                   |
| Ongoing Outbound Capacity (GHO)                              | 5,000,000 (current)                                                                                                                                   |
| Ongoing Refill Rate (GHO/s)                                  | 1,000 (current)                                                                                                                                       |
| Bridge Bucket Capacity (GHO)                                 | 265,000,000 ([Current](https://etherscan.io/address/0x06179f7C1be40863405f374E7f5F8806c728660A#readProxyContract#F4) + Initial GHO Funding)           |
| Transition to Ongoing Settings                               | After the initial funding transfer                                                                                                                    |
| Avalanche Bridge Destination Gas Limit                       | 750,000                                                                                                                                               |
| Bridge Bucket Capacity on other GHO networks (GHO)           | +65,000,000 (to 265,000,000) on Avalanche, Arbitrum, Base, Gnosis, Ink, Mantle, Plasma, X Layer and Monad                                             |
| Initial Inbound Capacity, Avalanche from Ethereum (GHO)      | 71,500,000 (Initial GHO funding \* 110%)                                                                                                              |
| Initial Inbound Refill Rate, Avalanche from Ethereum (GHO/s) | 64,999,999 (initial GHO funding - 1)                                                                                                                  |

#### Administration and Permissions

| Parameter                         | Proposed Configuration                                                                                                                                                                                                                                                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Configuration Administrator       | Governance [`0x3C06dce358add17aAf230f2234bCCC4afd50d090`](https://snowscan.xyz/address/0x3C06dce358add17aAf230f2234bCCC4afd50d090), with delegated GHO Risk Council [`0x8513e6F37dBc52De87b166980Fa3F50639694B60`](https://snowscan.xyz/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60) permissions as proposed below |
| Reserve Limit Manager             | GHO Risk Council [`0x8513e6F37dBc52De87b166980Fa3F50639694B60`](https://snowscan.xyz/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60); LIMIT_MANAGER_ROLE                                                                                                                                                              |
| Steward Exposure Cap Change Limit | ±100%                                                                                                                                                                                                                                                                                                                     |
| Steward Buy/Sell Fee Change Limit | ±0.5 percentage points for each direction (after AIP approved fee strategy)                                                                                                                                                                                                                                               |
| Freeze Authority                  | Governance                                                                                                                                                                                                                                                                                                                |
| Seizure Authority                 | Governance [`0x3C06dce358add17aAf230f2234bCCC4afd50d090`](https://snowscan.xyz/address/0x3C06dce358add17aAf230f2234bCCC4afd50d090), through an AIP that grants the liquidator role and seizes                                                                                                                             |
| Treasury Address                  | [`0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0`](https://snowscan.xyz/address/0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0); same configured recipient for fees and applicable yield                                                                                                                                          |

The proposed exposure-cap and fee adjustment limits allow increases and decreases, as defined in [this post](https://governance.aave.com/t/arfc-gho-stewards/16466/11).

#### Execution Order

- Ethereum Part 1 raises the bridge limit and widens the Ethereum → Avalanche outbound limit.
- Ethereum Part 2 mints 65,000,000 GHO through the new GhoDirectFacilitator, bridges it to the Avalanche Collector, and restores the Ethereum → Avalanche lane. It reverts until Ethereum Part 1 has executed.
- Avalanche Part 1 must execute before the CCIP message arrives. Otherwise the inbound limit rejects the transfer, and the delivery must be retried manually on https://ccip.chain.link/.
- Avalanche Part 2 reverts until the bridged GHO reaches the Avalanche Collector. It then funds the reserve, configures the GSM and restores the Ethereum → Avalanche lane.
- The bucket capacity payloads for Avalanche, Arbitrum, Base, Gnosis, Ink, Mantle, Plasma, X Layer and Monad are independent and can execute at any time.

## References

- Implementation: [AaveV3Ethereum Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.sol), [AaveV3Ethereum Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2.sol), [AaveV3Avalanche Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.sol), [AaveV3Avalanche Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Arbitrum_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Base_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Gnosis_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Ink](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Ink_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Mantle_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3XLayer_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Monad_PermissionedGSMUSATAvalanche_20261109.sol)
- Tests: [AaveV3Ethereum Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.t.sol), [AaveV3Ethereum Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2.t.sol), [AaveV3Avalanche Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.t.sol), [AaveV3Avalanche Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Arbitrum_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Base_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Gnosis_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Ink](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Ink_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Mantle_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3XLayer_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/bucket-updates/AaveV3Monad_PermissionedGSMUSATAvalanche_20261109.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2)
- Audits: [Certora](https://github.com/aave-dao/gho-origin/blob/678c1d7be9a1ba61c5f8fe9a6a3ea286119a3716/audits/2026-11-06_PermissionedGSM_Certora.pdf), [Pashov](https://github.com/aave-dao/gho-origin/blob/678c1d7be9a1ba61c5f8fe9a6a3ea286119a3716/audits/2026-10-28_PermissionedGSM_Pashov.pdf)
- [Discussion](https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
