---
title: "Create Allowance GHO Mantle"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/arfc-deploy-aave-v3-on-mantle/20542#p-51955-budget-15"
snapshot: "https://snapshot.box/#/s:aavedao.eth/proposal/0x2f9378770f1838f0ea8d483239af1530c9fbea98d648e0b11e4647dcb722d119"
---

## Simple Summary

This proposal creates an allowance of 1.5M aEthLidoGHO from the Aave Collector to the Aave Liquidity Committee (ALC) to support the launch of GHO on Mantle.

## Motivation

As part of the [ARFC to deploy Aave V3 on Mantle](https://governance.aave.com/t/arfc-deploy-aave-v3-on-mantle/20542#p-51955-budget-15), GHO liquidity needs to be seeded on Mantle. The Aave Liquidity Committee (ALC) will manage the bridging and liquidity provisioning of GHO on Mantle using the approved aEthLidoGHO allowance from the Aave Collector.

## Specification

Approve the Aave Liquidity Committee (ALC) [`0xA1c93D2687f7014Aaf588c764E3Ce80aF016229b`](https://etherscan.io/address/0xA1c93D2687f7014Aaf588c764E3Ce80aF016229b) to spend 1,500,000 aEthLidoGHO [`0x18eFE565A5373f430e2F809b97De30335B3ad96A`](https://etherscan.io/address/0x18eFE565A5373f430e2F809b97De30335B3ad96A) from the Aave Collector on the Ethereum Lido instance.

## References

- Implementation: [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/acd0ebe60e61db3a3bf4a9b9b833415ec1c6b706/src/20260216_AaveV3EthereumLido_CreateAllowanceGHOMantle/AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216.sol)
- Tests: [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/acd0ebe60e61db3a3bf4a9b9b833415ec1c6b706/src/20260216_AaveV3EthereumLido_CreateAllowanceGHOMantle/AaveV3EthereumLido_CreateAllowanceGHOMantle_20260216.t.sol)
- [Snapshot](https://snapshot.box/#/s:aavedao.eth/proposal/0x2f9378770f1838f0ea8d483239af1530c9fbea98d648e0b11e4647dcb722d119)
- [Discussion](https://governance.aave.com/t/arfc-deploy-aave-v3-on-mantle/20542#p-51955-budget-15)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
