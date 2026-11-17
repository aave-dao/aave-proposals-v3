---
title: "Permissioned GSM: USAT on Aave V4 Avalanche"
author: "TokenLogic"
discussions: "https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2"
---

## Simple Summary

TokenLogic proposes a Permissioned GHO Stability Module (GSM) that allows approved counterparties to exchange eligible assets for GHO and vice versa. The module would retain the existing GSM functionality while introducing participant-level access controls.

The first application would support USAT on Avalanche. Under this arrangement, USAT remains supplied to Aave V4 while the GSM holds waCoreUSAT, the receipt token representing the supplied USAT. The proposal includes the funding and configuration needed to launch this instance.

## Motivation

Existing GSMs allow users to exchange supported assets for GHO within governance-defined limits. However, some institutional arrangements require restricting access to approved counterparties, particularly when specific commercial terms or asset requirements apply.

A Permissioned GSM would support these arrangements without changing existing GSM exchange functionality.

### Initial Application: USAT

[USAT](https://usat.io/faq/) is a USD-backed stablecoin issued by Anchorage Digital Bank, N.A.

An approved counterparty would deposit USAT into the Aave V4 Tokenization Spoke and receive waCoreUSAT. The counterparty would then separately exchange waCoreUSAT for GHO through the Permissioned GSM, which would hold the waCoreUSAT. Returning GHO would allow the counterparty to recover waCoreUSAT. Redemption for underlying USAT would depend on the selected integration and available liquidity.

The same framework could support additional assets and counterparties. Multiple approved participants could share a GSM instance under the same configuration, while existing permissionless GSMs would remain unaffected.

#### Permissioned Access

Permissioning would apply to the swap originator in both directions. Approved participants could specify another recipient or use a relayer to submit a valid signed swap. Neither the recipient nor the relayer would require separate participant approval.

GHO received through the module would remain freely transferable. Revoking a participant's approval would prevent further swaps, including exchanges intended to recover previously deposited assets.

#### Liquidity and Exposure Management

Each instance would operate with shared liquidity, allowing approved counterparties to exchange against the same pool under governance-defined limits. Liquidity would not be reserved for individual participants. The module would not track individual principal balances or require a participant's swaps to match their previous deposits.

**The reserve supplies the GHO needed for swaps. The Remote GSM Draw Limit caps the GSM's use of that reserve. The Exposure Cap limits additional asset inflows through swaps. Exchange fees and any applicable accrued yield go to the configured treasury.**

The exposure cap would be denominated in the configured asset, including share units where applicable. Exchanges would remain subject to sufficient available liquidity, independently of the configured limits.

### Administration and Emergency Controls

Governance would assign configuration and emergency permissions.

The selected GSM implementation would retain its emergency controls, including the ability to freeze exchanges. Seizure transfers assets held by the module to the designated treasury and prevents further exchanges through the instance.

Revocation, freezing or insufficient liquidity could prevent counterparties from reversing an exchange. These restrictions would need to be reflected in the relevant counterparty agreements.

## Specification

TokenLogic proposes deploying a permissioned remoteGSM on Avalanche to exchange waCoreUSAT for GHO and vice versa.

### Funding the GSM

A new GHO Reserve on Avalanche would provide GHO for the USAT GSM. The initial allocation of 65,000,000 GHO would be newly minted on Ethereum through a new GhoDirectFacilitator for this GSM, with a 65,000,000 GHO bucket. This follows the existing practice of one GhoDirectFacilitator per remote GSM network, as for Arbitrum, Plasma and Monad, so that each facilitator's minted amount shows the GHO backing that network's GSMs. We would bridge the initial allocation to the Avalanche Collector, which would then transfer the funds to the reserve. To support this transfer, we would increase the bridge limits and refill rates, then apply the ongoing settings once the transfer is complete, as we have done previously when deploying new GSMs on Plasma, Monad, and Arbitrum.

### Access and Administration

The GSM is permissioned. Each swap direction has its own access control:

- **Sell:** swap waCoreUSAT for GHO.
- **Buy:** swap GHO for waCoreUSAT.

An address can have access to one direction or to both directions. The initial whitelist would include only an Aave DAO Safe, controlled by the Aave Finance Committee, with access in both directions. The commercial counterparty would get approved in a follow-up GHO Risk Council transaction.

The AIP gives the GHO Risk Council ([`0x8513e6F37dBc52De87b166980Fa3F50639694B60`](https://snowscan.xyz/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60)) the swap access manager role. With this role, the GHO Stewards can:

- give or remove buy access, sell access, or both, for any address, including the commercial counterparty, after the AIP executes;
- open buys, sells, or both to all addresses, and close them again.

Aave Governance keeps the same role and can revoke the GHO Stewards' role at any time.

The GSM will be deployed without a fee strategy, with buy and sell fees set to 0%. Introducing a non-zero fee will require an AIP to deploy and configure a fee strategy. Once a fee strategy is in place, the GHO Stewards will be able to adjust fees within the limits specified below. The GHO Stewards will also be able to adjust the exposure cap within the limits specified below.

Only the GHO Risk Council ([`0x8513e6F37dBc52De87b166980Fa3F50639694B60`](https://snowscan.xyz/address/0x8513e6F37dBc52De87b166980Fa3F50639694B60)) would be authorized to call the GHO GSM Steward's parameter-update functions.

#### Initial USAT Configuration

| Parameter                | Proposed Configuration                                                                                                                                                    |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Network                  | Avalanche                                                                                                                                                                 |
| Underlying Asset         | USAT                                                                                                                                                                      |
| Underlying Asset Address | [`0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b`](https://snowscan.xyz/address/0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b)                                                   |
| Aave Market              | Aave V4                                                                                                                                                                   |
| Configured GSM Asset     | waCoreUSAT                                                                                                                                                                |
| Receipt Token Address \* | [`0x653F2541E7d51a846e92fA6F7866bA92e465a379`](https://snowscan.xyz/address/0x653F2541E7d51a846e92fA6F7866bA92e465a379)                                                   |
| GSM Implementation       | Permissioned remoteGSM                                                                                                                                                    |
| Approved Aave DAO Safe   | [`0x22740deBa78d5a0c24C58C740e3715ec29de1bFa`](https://snowscan.xyz/address/0x22740deBa78d5a0c24C58C740e3715ec29de1bFa)                                                   |
| GSM Registry             | The AIP adds the GSM to the Avalanche GsmRegistry [`0x0a0dFf46122dFdc2aF0D5D66f23BA8f78bf17edF`](https://snowscan.xyz/address/0x0a0dFf46122dFdc2aF0D5D66f23BA8f78bf17edF) |

\* Pending USAT onboarding to Aave V4 ([forum](https://governance.aave.com/t/direct-to-aip-onboard-usat-to-aave-v4-core-instance-on-avalanche/25880), [AIP](https://github.com/aave-dao/aave-proposals-v3/pull/1236)).

#### Liquidity and Economic Parameters

| Parameter                          | Proposed Configuration                                                                                                                       |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| GHO Reserve                        | [`0x15f22f39FD7b3612840cF0De49b6f9C4879Aa642`](https://snowscan.xyz/address/0x15f22f39FD7b3612840cF0De49b6f9C4879Aa642)                      |
| Remote GSM Draw Limit              | 25,000,000 GHO                                                                                                                               |
| Initial GHO Funding                | 65,000,000 GHO                                                                                                                               |
| GHO Funding Source                 | [`0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0`](https://snowscan.xyz/address/0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0)                      |
| waCoreUSAT Exposure Cap            | 20,000,000 waCoreUSAT                                                                                                                        |
| Buy Fee (GHO → waCoreUSAT)         | 0                                                                                                                                            |
| Sell Fee (waCoreUSAT → GHO)        | 0                                                                                                                                            |
| Pricing Strategy                   | [`0x863F2106C5543266b43991Fe842551B0E30FBF0d`](https://snowscan.xyz/address/0x863F2106C5543266b43991Fe842551B0E30FBF0d)                      |
| Receipt Token Conversion           | at `convertToAssets()` rate                                                                                                                  |
| Fee and Yield Recipient            | Configured treasury: [`0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0`](https://snowscan.xyz/address/0x5ba7fd868c40c16f7aDfAe6CF87121E13FC2F7a0) |
| Fee Strategy                       | no fee strategy (both fees are 0)                                                                                                            |
| Automatic Freeze Strategy / Oracle | no automatic freeze strategy - price is hardcoded to 1                                                                                       |

#### Bridge Configuration

| **Parameter**                                           | **Proposed Configuration**                                                                                                                            |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Funding Route and Bridge Endpoint Source                | [`0x7F2f96fcdC3A29Be75938d2aC3D92E7006919fe6`](https://etherscan.io/address/0x7F2f96fcdC3A29Be75938d2aC3D92E7006919fe6) (Mainnet AaveGhoCcipBridge)   |
| Funding Route and Bridge Endpoint Destination           | [`0xaf9f841de7477f35d6339943c1e6f0c101bca621`](https://snowscan.xyz/address/0xaf9f841de7477f35d6339943c1e6f0c101bca621) (Avalanche AaveGhoCcipBridge) |
| Initial Inbound Capacity, Ethereum from Avalanche (GHO) | 5,000,000 (unchanged)                                                                                                                                 |
| Initial Outbound Capacity, Ethereum → Avalanche (GHO)   | 71,500,000 (Initial GHO funding \* 110%)                                                                                                              |
| Initial Refill Rate (GHO/s)                             | 64,999,999 (initial GHO funding - 1)                                                                                                                  |
| Ongoing Inbound Capacity (GHO)                          | 5,000,000 (current)                                                                                                                                   |
| Ongoing Outbound Capacity (GHO)                         | 5,000,000 (current)                                                                                                                                   |
| Ongoing Refill Rate (GHO/s)                             | 1,000 (current)                                                                                                                                       |
| Bridge Bucket Capacity (GHO)                            | 265,000,000 ([Current](https://etherscan.io/address/0x06179f7C1be40863405f374E7f5F8806c728660A#readProxyContract#F4) + Initial GHO Funding)           |
| Transition to Ongoing Settings                          | After the initial funding transfer                                                                                                                    |
| Avalanche Bridge Destination Gas Limit                  | 750,000                                                                                                                                               |
| Bridge Bucket Capacity on other GHO networks (GHO)      | +65,000,000 (to 265,000,000) on Avalanche, Arbitrum, Base, Gnosis, Ink, Mantle, Plasma, X Layer and Monad                                             |

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

### Execution Order

- Ethereum Part 1 raises the bridge limit and widens the Ethereum → Avalanche outbound limit.
- Ethereum Part 2 mints 65,000,000 GHO through the new GhoDirectFacilitator, bridges it to the Avalanche Collector, and restores the Ethereum → Avalanche lane. It reverts if Ethereum Part 1 has not executed.
- Avalanche Part 1 must execute before the CCIP message arrives. Otherwise the inbound limit rejects the transfer, and the delivery must be retried manually on https://ccip.chain.link/.
- Avalanche Part 2 reverts until the bridged GHO reaches the Avalanche Collector. It then funds the reserve, configures the GSM and restores the Avalanche → Ethereum lane.
- The payloads for Arbitrum, Base, Gnosis, Ink, Mantle, Plasma, X Layer and Monad are independent and can execute at any time.

## References

- Implementation: [AaveV3Ethereum Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.sol), [AaveV3Ethereum Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2.sol), [AaveV3Avalanche Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.sol), [AaveV3Avalanche Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Arbitrum_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Base_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Gnosis_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Ink](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ink_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Mantle_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3XLayer_PermissionedGSMUSATAvalanche_20261109.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Monad_PermissionedGSMUSATAvalanche_20261109.sol)
- Tests: [AaveV3Ethereum Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.t.sol), [AaveV3Ethereum Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2.t.sol), [AaveV3Avalanche Part 1](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.t.sol), [AaveV3Avalanche Part 2](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Arbitrum_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Base_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Gnosis_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Ink](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ink_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Mantle_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3XLayer_PermissionedGSMUSATAvalanche_20261109.t.sol), [AaveV3Monad](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Monad_PermissionedGSMUSATAvalanche_20261109.t.sol)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2)
- Audits: [Certora](https://github.com/aave-dao/gho-origin/blob/678c1d7be9a1ba61c5f8fe9a6a3ea286119a3716/audits/2026-11-06_PermissionedGSM_Certora.pdf), [Pashov](https://github.com/aave-dao/gho-origin/blob/678c1d7be9a1ba61c5f8fe9a6a3ea286119a3716/audits/2026-10-28_PermissionedGSM_Pashov.pdf)
- [Discussion](https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
