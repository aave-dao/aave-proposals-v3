---
title: "Aave V3. Deprecation of Liquidity Mining: Removal of Emission Admins"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/technical-maintenance-proposals/26300/2"
---

## Simple Summary

As the first step toward deprecating the liquidity mining feature, this proposal removes every emission admin set on the Aave V3 EmissionManager contracts across 19 networks, including the Horizon instance on Ethereum. After execution, starting, extending, or reconfiguring a liquidity mining distribution on the RewardsController will require a governance vote. Claims of rewards already accrued are not affected by this proposal.

## Motivation

The EmissionManager allows governance to appoint an emission admin per reward token. That admin can configure distributions of its reward on the RewardsController: add assets to a distribution, set the emission rate, move the distribution end, and replace the transfer strategy or the reward oracle. Admins were appointed over time, mostly through asset listing payloads, to run liquidity mining campaigns.

All of these campaigns have ended, and no distribution is active on any reserve token. The most recent one ended in July 2026, a distribution on Metis ended in November 2025, and every other distribution ended in January 2025 or earlier. The admins nonetheless retain the permission to start or reconfigure distributions. Of the 300 admins, 266 are held by the ACI Safe ([0xac140648435d03f784879cd789130F22Ef588Fcd](https://etherscan.io/address/0xac140648435d03f784879cd789130F22Ef588Fcd)), which is [no longer part of the DAO](https://governance.aave.com/t/aci-is-leaving-aave/24205). The remaining 34 are spread across 17 other addresses. None of these holders currently needs the role, and none is expected to need it in the future, as new incentive campaigns are run through Merkl.

## Specification

On each network in scope, the payload calls `EmissionManager.setEmissionAdmin(reward, address(0))` for every reward token that currently has a non-zero emission admin. It is executed by the Executor Lvl1, owner of the EmissionManager. Ethereum has two payloads: one for the Core EmissionManager, shared with Prime and EtherFi, and one for the Horizon EmissionManager. No other configuration changes.

Transfer strategies, rewards vaults, token allowances, reward oracles and distribution configurations on the RewardsController are left as they are, so claims of rewards accrued up to each distribution end are not affected by this proposal. On Metis, the METIS rewards vault (`0x97177cD80475f8b38945c1E77e12F0c9d50Ac84D`) approves only about 0.00005 METIS to its transfer strategy, so most METIS claims already revert; this is independent of this proposal.

All Aave V3 instances are within the scope of this proposal. However, markets without an emission admin configured are skipped. Aave V2 instances are out of scope, as updating the EmissionManager would require an upgrade, and the last reward campaign ended in 2023.

| Network                            | Emission admins removed |
| ---------------------------------- | ----------------------: |
| Ethereum (Core, Prime and EtherFi) |                      81 |
| Ethereum (Horizon)                 |                      11 |
| Polygon                            |                       7 |
| Avalanche                          |                      16 |
| Optimism                           |                       5 |
| Arbitrum                           |                      10 |
| Metis                              |                       1 |
| Base                               |                      19 |
| Gnosis                             |                       3 |
| Scroll                             |                       3 |
| BNB                                |                       3 |
| zkSync                             |                       7 |
| Linea                              |                      16 |
| Celo                               |                      12 |
| Sonic                              |                       8 |
| Soneium                            |                       6 |
| Plasma                             |                      37 |
| Mantle                             |                      20 |
| MegaEth                            |                      17 |
| X Layer                            |                      18 |
| **Total**                          |                 **300** |

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Ethereum_RemoveEmissionAdmins_20261029.sol), [AaveV3EthereumHorizon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Polygon_RemoveEmissionAdmins_20261029.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Avalanche_RemoveEmissionAdmins_20261029.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Optimism_RemoveEmissionAdmins_20261029.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Arbitrum_RemoveEmissionAdmins_20261029.sol), [AaveV3Metis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Metis_RemoveEmissionAdmins_20261029.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Base_RemoveEmissionAdmins_20261029.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Gnosis_RemoveEmissionAdmins_20261029.sol), [AaveV3Scroll](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Scroll_RemoveEmissionAdmins_20261029.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3BNB_RemoveEmissionAdmins_20261029.sol), [AaveV3ZkSync](https://github.com/aave-dao/aave-proposals-v3/blob/main/zksync/src/20261029_Multi_RemoveEmissionAdmins/AaveV3ZkSync_RemoveEmissionAdmins_20261029.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Linea_RemoveEmissionAdmins_20261029.sol), [AaveV3Celo](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Celo_RemoveEmissionAdmins_20261029.sol), [AaveV3Sonic](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Sonic_RemoveEmissionAdmins_20261029.sol), [AaveV3Soneium](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Soneium_RemoveEmissionAdmins_20261029.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Plasma_RemoveEmissionAdmins_20261029.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Mantle_RemoveEmissionAdmins_20261029.sol), [AaveV3MegaEth](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3MegaEth_RemoveEmissionAdmins_20261029.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3XLayer_RemoveEmissionAdmins_20261029.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Ethereum_RemoveEmissionAdmins_20261029.t.sol), [AaveV3EthereumHorizon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Polygon_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Avalanche_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Optimism_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Arbitrum_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Metis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Metis_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Base_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Gnosis_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Scroll](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Scroll_RemoveEmissionAdmins_20261029.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3BNB_RemoveEmissionAdmins_20261029.t.sol), [AaveV3ZkSync](https://github.com/aave-dao/aave-proposals-v3/blob/main/zksync/src/20261029_Multi_RemoveEmissionAdmins/AaveV3ZkSync_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Linea_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Celo](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Celo_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Sonic](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Sonic_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Soneium](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Soneium_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Plasma_RemoveEmissionAdmins_20261029.t.sol), [AaveV3Mantle](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3Mantle_RemoveEmissionAdmins_20261029.t.sol), [AaveV3MegaEth](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3MegaEth_RemoveEmissionAdmins_20261029.t.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261029_Multi_RemoveEmissionAdmins/AaveV3XLayer_RemoveEmissionAdmins_20261029.t.sol)
- [Discussion](https://governance.aave.com/t/technical-maintenance-proposals/26300/2)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
