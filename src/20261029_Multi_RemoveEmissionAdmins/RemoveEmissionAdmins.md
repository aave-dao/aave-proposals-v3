---
title: "Remove Emission Admins from Aave V3 Instances"
author: "Aave Labs"
discussions: "TODO"
---

## Simple Summary

This proposal removes every emission admin set on the Aave V3 EmissionManagers across 14 networks, including the Horizon instance on Ethereum. After execution, no address can start, extend or reconfigure a liquidity mining distribution on the RewardsController without a new governance vote. Rewards already accrued stay claimable.

## Motivation

The EmissionManager lets governance appoint an emission admin per reward token. That admin can configure distributions of its reward on the RewardsController: add assets to a distribution, set the emission rate, move the distribution end, and replace the transfer strategy or the reward oracle. Admins were appointed over time, mostly through asset listing payloads, to run liquidity mining campaigns.

All of these campaigns have ended. The most recent, aEthUSDS rewards on aEthUSDS on Ethereum Core, ended on July 7th, 2026 at 11:00 UTC. Every other distribution ended in January 2025 or earlier. No distribution is active on any reserve token.

The admins still hold the permission to start or reconfigure distributions on Aave V3 reserves, although none of them has a campaign to run. 250 of the 275 admins are held by the ACI Safe (`0xac140648435d03f784879cd789130F22Ef588Fcd`), set as liquidity mining admin by past listing payloads. ACI has since [left the Aave DAO](https://governance.aave.com/t/aci-is-leaving-aave/24205). The rest are spread across 15 other addresses. Removing these permissions leaves the DAO as the only party able to configure rewards.

The EmissionManager and RewardsController feature is planned to be deprecated and removed from the codebase. This proposal is the first step of that process.

## Specification

On each network in scope, the payload (two on Ethereum: one for the Core EmissionManager, shared with Prime, and one for the Horizon EmissionManager) is executed by the Executor Lvl1, owner of the Aave V3 EmissionManager, and calls `EmissionManager.setEmissionAdmin(reward, address(0))` for every reward token that currently has a non-zero emission admin.

Nothing else changes. Transfer strategies, rewards vaults, token allowances, reward oracles and distribution configurations on the RewardsController are left as they are, so users can keep claiming rewards accrued up to each distribution end. Governance keeps the ability to appoint a new emission admin through `setEmissionAdmin` if a future proposal requires it.

| Network                   | Emission admins removed |
| ------------------------- | ----------------------: |
| Ethereum (Core and Prime) |                      81 |
| Ethereum (Horizon)        |                      11 |
| Polygon                   |                       7 |
| Avalanche                 |                      16 |
| Optimism                  |                       5 |
| Arbitrum                  |                      10 |
| Base                      |                      19 |
| Gnosis                    |                       3 |
| BNB                       |                       3 |
| Linea                     |                      16 |
| Celo                      |                      12 |
| Plasma                    |                      37 |
| Mantle                    |                      20 |
| MegaEth                   |                      17 |
| X Layer                   |                      18 |
| **Total**                 |                 **275** |

Monad has no emission admin set and is not part of this proposal.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Ethereum_RemoveEmissionAdmins_20261029.sol), [AaveV3EthereumHorizon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Polygon_RemoveEmissionAdmins_20261029.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Avalanche_RemoveEmissionAdmins_20261029.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Optimism_RemoveEmissionAdmins_20261029.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Arbitrum_RemoveEmissionAdmins_20261029.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Base_RemoveEmissionAdmins_20261029.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Gnosis_RemoveEmissionAdmins_20261029.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3BNB_RemoveEmissionAdmins_20261029.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Linea_RemoveEmissionAdmins_20261029.sol), [AaveV3Celo](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Celo_RemoveEmissionAdmins_20261029.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Plasma_RemoveEmissionAdmins_20261029.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Mantle_RemoveEmissionAdmins_20261029.sol), [AaveV3MegaEth](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3MegaEth_RemoveEmissionAdmins_20261029.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3XLayer_RemoveEmissionAdmins_20261029.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Ethereum_RemoveEmissionAdmins_20261029.t.sol), [AaveV3EthereumHorizon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Polygon_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Avalanche_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Optimism_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Arbitrum_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Base_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Gnosis_RemoveEmissionAdmins_20261029.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3BNB_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Linea_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Celo](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Celo_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Plasma_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Mantle_RemoveEmissionAdmins_20261029.t.sol), [AaveV3MegaEth](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3MegaEth_RemoveEmissionAdmins_20261029.t.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3XLayer_RemoveEmissionAdmins_20261029.t.sol)
- [Discussion](TODO)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
