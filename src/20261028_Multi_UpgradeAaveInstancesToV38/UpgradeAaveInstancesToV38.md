---
title: "Upgrade Aave instances to v3.8"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/arfc-aave-v3-8/25891"
snapshot: "https://snapshot.org/#/s:aavedao.eth/proposal/0xe425ad8fc8cf631c358427d1cd37beb0de963230b547c77ac02c754e63bbebae"
---

## Simple Summary

This proposal upgrades Aave V3 to V3.8, a non-invasive and very measured release focused on security. The changes it introduces are quite minor, but we consider them worth applying to make the system more robust and resilient going forward.

It includes the following changes:

- A reentrancy guard on Pool operations during external callbacks.

Securing Aave V3 remains a top priority, and additional security reviews are being planned. Further defense-in-depth improvements may be proposed in future upgrades.

## Motivation

Aave V3.8 aims to make the system more robust and predictable. Gas costs are no longer the concern they once were, and recent developments such as transient storage allow the protocol to be strengthened with little downside in efficiency or gas costs.

## Aave V3.8 Changes

### Reentrancy hardening

Aave V3.8 introduces a guard based on transient storage (EIP-1153) that protects Pool accounting consistency, including when a single transaction's execution flow interacts with the Pool more than once. The change is intended to strengthen the robustness and security of the protocol over the long term, aligning the pools with industry best practice and protecting them against theoretical reentrancy exploits. Gas costs were historically a concern for this type of guard. With transient storage, that concern is no longer valid, as the guard can be applied with little overhead.

## Specification

The upgrade applies to the Aave V3 instances on Ethereum (Core and Lido), Plasma, Avalanche, BNB, Monad, Base, Arbitrum, Mantle, X Layer, Polygon, Linea, Optimism, Gnosis, MegaETH and Celo.

## Licensing

Aave V3.8 will be published as its own version of the Licensed Work under a Business Source License. The licence text is available [here](https://github.com/aave-dao/aave-v3-origin/blob/d1086a13a4f7c730a3e5c62a8c32397383c7704c/LICENSE) and will be included in the V3.8 repository. The Change Date for V3.8 is set by Aave Governance and recorded in the change-date text record at v38.aavelicense.eth. Until Governance sets a date, V3.8 stays under the Business Source License. As with the other codebase IP, the V3.8 IP will be transferred to the Aave Foundation through a separate governance proposal.

## Security

Aave V3.8 has been audited by:

- [Certora](https://github.com/aave-dao/aave-v3-origin/blob/feat/V3.8/audits/2026-10-27_Certora_Aave-v3.8.pdf)
- [ChainSecurity](https://github.com/aave-dao/aave-v3-origin/blob/feat/V3.8/audits/2026-10-27_ChainSecurity_Aave-v3.8.pdf)
- [TomerSecurityFirst](https://github.com/aave-dao/aave-v3-origin/blob/feat/V3.8/audits/2026-10-27_TomerSecurityFirst_Aave-v3.8.pdf)

## References

- [Implementation](https://github.com/aave/protocol-v3.8-upgrade/blob/main/src/UpgradePayload.sol)
- [Deployments](https://github.com/aave/protocol-v3.8-upgrade/blob/main/src/Deployments.sol)
- [Tests](https://github.com/aave/protocol-v3.8-upgrade/tree/main/test)
- [Code diffs](https://github.com/aave/protocol-v3.8-upgrade/tree/main/diffs/code)
- [Execution diffs](https://github.com/aave/protocol-v3.8-upgrade/tree/main/diffs)
- [Snapshot](https://snapshot.org/#/s:aavedao.eth/proposal/0xe425ad8fc8cf631c358427d1cd37beb0de963230b547c77ac02c754e63bbebae)
- [Discussion](https://governance.aave.com/t/arfc-aave-v3-8/25891)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
