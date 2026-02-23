---
title: "Focussing the Aave V3 Multichain Strategy - Phase 1"
author: "Aavechan Initiative @aci"
discussions: "https://governance.aave.com/t/arfc-focussing-the-aave-v3-multichain-strategy-phase-1/23954"
snapshot: "https://snapshot.org/#/aavedao.eth/proposal/0x62340121a7428f902f3232030350eb2d2bb753dc10ab0657a16ffd4d85cb530b"
---

## Simple Summary

The proposal plans to provide and execute a multichain strategy for Aave V3 that will freeze the following networks, as a start:

1. zkSync
2. Metis
3. Soneium

This proposal sets to reduce operational overhead and governance burden by addressing instances that are clearly non viable today.

## Motivation

Aave V3 maintains multiple live deployments across different networks, each of which introduces:

- Ongoing operational and monitoring requirements
- Governance overhead for parameter updates and asset maintenance
- Risk surface area, even when usage is minimal

Over time, it has become clear that a small subset of instances contributes very little **user activity, TVL, and revenue**, while still requiring a non-trivial amount of attention from service providers and governance participants.

The zkSync, Metis, and Soneium deployments fall firmly into this category. These instances exhibit:

- Low and persistent usage
- No signs of organic growth
- No credible short-term path to becoming meaningful contributors to the Aave ecosystem

Continuing to operate these markets in their current state provides little upside while consuming attention better spent elsewhere.

### **Policy for Future Aave V3 Deployments**

We would like to highlight the significant value an Aave deployment provides to a new chain. As the largest DeFi protocol, the value and stimulating effect on the onchain ecosystem that a properly planned Aave deployment can bring is significant.

The work involved in a deployment and the substantial ongoing effort from service providers and governance participants has at times been under appreciated, yet in light of the above revenue numbers we must bring this back into focus. The upfront and recurring costs mean the DAO must prioritize deployments that generate sufficient revenue to justify the time and risk involved.

We therefore propose that for any new Aave deployment the chain on which we are deploying guarantees a revenue floor of $2m per annum for all new deployments.

### Conclusion

We believe that the above remediation measures will help to focus the DAO on high revenue opportunities, ensure Aave shares in upside from successful instance deployments, reduce the number of low value deployments going forward, ensure that Aave is fairly compensated for the value it brings to our partners, and reduce risk and operational overhead by offboarding poor performing instances.

## Specification

This AIP will freeze the following assets:

| **Instances** | **Asset** |
| ------------- | --------- |
| Metis         | m.USDC    |
| Metis         | m.USDT    |
| Metis         | m.DAI     |
| Metis         | Metis     |
| Metis         | WETH      |
| Soneium       | USDC.e    |
| Soneium       | ETH       |
| Soneium       | USDT      |
| zkSync        | wstETH    |
| zkSync        | wETH      |
| zkSync        | ZK        |
| zkSync        | USDC      |
| zkSync        | weETH     |
| zkSync        | USDT      |
| zkSync        | sUSDe     |
| zkSync        | wrsETH    |

## Disclaimer

Due to explorer issues, the zkSync payload cannot currently be verified on-chain. However, its bytecode and address legitimacy can be confirmed using the deployment script.

## References

- Implementation: [AaveV3Metis](https://github.com/aave-dao/aave-proposals-v3/blob/4a5130dfdfdfbea21cb3b5107aaeacba5f6f50b5/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol), [AaveV3ZkSync](https://github.com/aave-dao/aave-proposals-v3/blob/4a5130dfdfdfbea21cb3b5107aaeacba5f6f50b5/zksync/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol), [AaveV3Soneium](https://github.com/aave-dao/aave-proposals-v3/blob/4a5130dfdfdfbea21cb3b5107aaeacba5f6f50b5/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol)
- Tests: [AaveV3Metis](https://github.com/aave-dao/aave-proposals-v3/blob/4a5130dfdfdfbea21cb3b5107aaeacba5f6f50b5/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209.t.sol), [AaveV3ZkSync](https://github.com/aave-dao/aave-proposals-v3/blob/4a5130dfdfdfbea21cb3b5107aaeacba5f6f50b5/zksync/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1_20260209.t.sol), [AaveV3Soneium](https://github.com/aave-dao/aave-proposals-v3/blob/4a5130dfdfdfbea21cb3b5107aaeacba5f6f50b5/src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209.t.sol)
- [Snapshot](https://snapshot.org/#/aavedao.eth/proposal/0x62340121a7428f902f3232030350eb2d2bb753dc10ab0657a16ffd4d85cb530b)
- [Discussion](https://governance.aave.com/t/arfc-focussing-the-aave-v3-multichain-strategy-phase-1/23954)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
