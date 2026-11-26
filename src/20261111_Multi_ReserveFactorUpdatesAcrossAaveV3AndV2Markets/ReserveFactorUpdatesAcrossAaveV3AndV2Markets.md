---
title: "Reserve Factor Updates Across Aave V3 and V2 Markets"
author: "@TokenLogic"
discussions: "https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249"
---

## Simple Summary

This AIP updates the Reserve Factor (RF) of 60 reserves across 12 Aave V3 instances and the Aave V2 Ethereum and Avalanche markets. At balances and rates as of 9 November 2026, the changes add about $3.5M of annualised revenue to the DAO and raise the blended RF from 12.0% to 12.7%.

## Motivation

Every borrowable reserve exposes the DAO to collateral, oracle and liquidation risk, and the RF compensates the DAO for carrying that risk. The RF decides how the interest paid by borrowers is split between suppliers and the DAO; it does not change the rate a borrower pays. The updates are grouped by rationale:

- **Assets with no supply yield (to 100%)**: BTC wrappers, LSTs and LRTs with utilisation of a few percent and a supply APY that rounds to zero. Raising the RF to 100% routes the full interest to the DAO, costing suppliers at most 1-2 bps.
- **Volatile tokens (to 50%)**: LINK, ARB, WPOL and GNO, whose suppliers do not supply for yield.
- **Plasma**: USDe moves from 25% to 35%, GHO from 5% to 10% in line with GHO on Monad and Base, and USDT0 from 5% to 7.5% in line with the terms agreed with the Plasma team.
- **Ethereum Core DAI**: a 5 percentage point increase, lowering the supply APY by about 17 bps.
- **Avalanche**: larger increases on V3 so that its economics reflect the Aave V4 alternative live on the same chain.
- **Polygon, Optimism, Gnosis, Linea and BNB Chain**: moderate increases on the main reserves of these smaller markets with limited growth, and a larger one on Polygon DAI, a legacy reserve.
- **Ethereum Prime wstETH**: utilisation is 31% and supply APY is 6 bps; Prime suppliers use wstETH as collateral and are not meaningfully exposed to the supply rate.
- **Aave V2 Ethereum and Avalanche (to 99.99%)**: all V2 Ethereum and Avalanche reserves are frozen under the V2 deprecation plan; directing nearly all remaining interest to the DAO gives remaining suppliers a reason to withdraw and pushes open positions to close. With AAVE.e included, all seven Avalanche V2 reserves will have a 99.99% RF. Ethereum V2 AAVE and stETH are frozen with no debt and keep their current RF.

Ethereum Core WETH is not included, so that its parameters can be coordinated with the ongoing work on Ethereum Core collateral. Reserves not listed in the Specification keep their current RF.

## Specification

The following Reserve Factor updates are implemented. All other reserve parameters remain unchanged.

### Ethereum Core (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| DAI    | 0x6B175474E89094C44Da98b954EedeAC495271d0F | 25%                    | 30%                     |
| WBTC   | 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 | 50%                    | 100%                    |
| cbBTC  | 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf | 50%                    | 100%                    |
| wstETH | 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 | 35%                    | 100%                    |
| LINK   | 0x514910771AF9Ca656af840dff83E8264EcF986CA | 20%                    | 50%                     |
| weETH  | 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee | 45%                    | 100%                    |
| tBTC   | 0x18084fbA666a33d37592fA2633fD49a74DD93a88 | 50%                    | 100%                    |
| FBTC   | 0xC96dE26018A54D51c097160568752c4E3BD6C364 | 75%                    | 100%                    |
| cbETH  | 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704 | 15%                    | 100%                    |
| rETH   | 0xae78736Cd615f374D3085123A210448E74Fc6393 | 15%                    | 100%                    |

### Ethereum Prime (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| wstETH | 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 | 5%                     | 50%                     |

### Plasma (Aave V3)

| Asset | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ----- | ------------------------------------------ | ---------------------- | ----------------------- |
| USDT0 | 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb | 5%                     | 7.5%                    |
| USDe  | 0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34 | 25%                    | 35%                     |
| GHO   | 0xb77E872A68C62CfC0dFb02C067Ecc3DA23B4bbf3 | 5%                     | 10%                     |

### Base (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| cbBTC  | 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf | 50%                    | 100%                    |
| cbETH  | 0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22 | 15%                    | 100%                    |
| wstETH | 0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452 | 5%                     | 100%                    |
| weETH  | 0x04C0599Ae5A44757c0af6F9eC3b93da8976c150A | 45%                    | 100%                    |

### Arbitrum (Aave V3)

| Asset | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ----- | ------------------------------------------ | ---------------------- | ----------------------- |
| WBTC  | 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f | 50%                    | 100%                    |
| ARB   | 0x912CE59144191C1204E64559FE8253a0e49E6548 | 20%                    | 50%                     |
| LINK  | 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4 | 20%                    | 50%                     |
| weETH | 0x35751007a407ca6FEFfE80b3cB397736D2cf4dbe | 45%                    | 100%                    |

### Avalanche (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| USDC   | 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E | 10%                    | 25%                     |
| WAVAX  | 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 | 20%                    | 50%                     |
| USDt   | 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7 | 10%                    | 25%                     |
| DAI.e  | 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70 | 25%                    | 90%                     |
| WETH.e | 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB | 15%                    | 50%                     |
| BTC.b  | 0x152b9d0FdC40C096757F570A51E494bd4b943E50 | 50%                    | 100%                    |
| WBTC.e | 0x50b7545627a5162F82A992c33b87aDc75187B218 | 50%                    | 100%                    |

### Polygon (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| USDT0  | 0xc2132D05D31c914a87C6611C10748AEb04B58e8F | 25%                    | 30%                     |
| USDC   | 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359 | 20%                    | 25%                     |
| DAI    | 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063 | 25%                    | 70%                     |
| WETH   | 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619 | 15%                    | 25%                     |
| WPOL   | 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270 | 20%                    | 50%                     |
| WBTC   | 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6 | 50%                    | 100%                    |
| wstETH | 0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD | 5%                     | 100%                    |

### BNB Chain (Aave V3)

| Asset | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ----- | ------------------------------------------ | ---------------------- | ----------------------- |
| ETH   | 0x2170Ed0880ac9A755fd29B2688956BD959F933F8 | 15%                    | 25%                     |
| BTCB  | 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c | 20%                    | 100%                    |

### X Layer (Aave V3)

| Asset | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ----- | ------------------------------------------ | ---------------------- | ----------------------- |
| xBTC  | 0xb7C00000bcDEeF966b20B3D884B98E64d2b06b4f | 10%                    | 100%                    |

### Optimism (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| USDC   | 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85 | 10%                    | 15%                     |
| WETH   | 0x4200000000000000000000000000000000000006 | 15%                    | 20%                     |
| USDT   | 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58 | 10%                    | 15%                     |
| WBTC   | 0x68f180fcCe6836688e9084f035309E29Bf0A2095 | 50%                    | 100%                    |
| wstETH | 0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb | 5%                     | 100%                    |

### Gnosis (Aave V3)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| EURe   | 0xcB444e90D8198415266c6a2724b7900fb12FC56E | 10%                    | 15%                     |
| USDC.e | 0x2a22f9c3b484c3629090FeED35F17Ff8F88f76F0 | 10%                    | 20%                     |
| GNO    | 0x9C58BAcC331c9aa871AFD802DB6379a98e80CEdb | 20%                    | 50%                     |

### Linea (Aave V3)

| Asset | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ----- | ------------------------------------------ | ---------------------- | ----------------------- |
| WETH  | 0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f | 15%                    | 20%                     |
| USDC  | 0x176211869cA2b568f2A7D4EE941E073a821EE1ff | 10%                    | 15%                     |

### Ethereum (Aave V2)

| Asset | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ----- | ------------------------------------------ | ---------------------- | ----------------------- |
| USDC  | 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 | 85%                    | 99.99%                  |
| DAI   | 0x6B175474E89094C44Da98b954EedeAC495271d0F | 85%                    | 99.99%                  |
| WETH  | 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 | 85%                    | 99.99%                  |
| USDT  | 0xdAC17F958D2ee523a2206206994597C13D831ec7 | 85%                    | 99.99%                  |
| WBTC  | 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 | 90%                    | 99.99%                  |

### Avalanche (Aave V2)

| Asset  | Underlying                                 | Current Reserve Factor | Proposed Reserve Factor |
| ------ | ------------------------------------------ | ---------------------- | ----------------------- |
| DAI.e  | 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70 | 85%                    | 99.99%                  |
| USDC.e | 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664 | 85%                    | 99.99%                  |
| USDT.e | 0xc7198437980c041c805A1EDcbA50c1Ce5db95118 | 85%                    | 99.99%                  |
| WETH.e | 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB | 85%                    | 99.99%                  |
| WAVAX  | 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7 | 85%                    | 99.99%                  |
| AAVE.e | 0x63a72806098Bd3D9520cC43356dD78afe5D386D9 | 20%                    | 99.99%                  |

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3EthereumLido_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Plasma_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Base_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Arbitrum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3BNB_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3XLayer_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Optimism_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Gnosis_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Linea_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV2Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol), [AaveV2Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3EthereumLido](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3EthereumLido_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Plasma](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Plasma_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Base](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Base_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Arbitrum](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Arbitrum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Polygon](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3BNB](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3BNB_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3XLayer](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3XLayer_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Optimism](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Optimism_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Gnosis](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Gnosis_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV3Linea](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Linea_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV2Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol), [AaveV2Avalanche](https://github.com/aave-dao/aave-proposals-v3/blob/94f9334532a3eeefbd5e221abb8c9fffb847400e/src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol)
- Snapshot: Direct-to-AIP
- [Discussion](https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
