## Reserve changes

### Reserves altered

#### WBTC ([0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599](https://etherscan.io/address/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599))

| description | value before | value after |
| --- | --- | --- |
| ltv | 73 % [7300] | 81 % [8100] |
| liquidationThreshold | 78 % [7800] | 85 % [8500] |


#### wstETH ([0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0](https://etherscan.io/address/0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0))

| description | value before | value after |
| --- | --- | --- |
| ltv | 78.5 % [7850] | 79 % [7900] |
| liquidationThreshold | 81 % [8100] | 82 % [8200] |


#### WETH ([0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2](https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))

| description | value before | value after |
| --- | --- | --- |
| ltv | 80.5 % [8050] | 81 % [8100] |
| liquidationThreshold | 83 % [8300] | 84 % [8400] |


#### weETH ([0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee](https://etherscan.io/address/0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee))

| description | value before | value after |
| --- | --- | --- |
| ltv | 77.5 % [7750] | 78 % [7800] |
| liquidationThreshold | 80 % [8000] | 81 % [8100] |


#### cbBTC ([0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf](https://etherscan.io/address/0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf))

| description | value before | value after |
| --- | --- | --- |
| ltv | 73 % [7300] | 81 % [8100] |
| liquidationThreshold | 78 % [7800] | 85 % [8500] |


## Event logs

#### 0x64b761D848206f447Fe2dd461b0c635Ec39EbB27 (AaveV3Ethereum.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | CollateralConfigurationChanged(asset: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 (symbol: WETH), ltv: 8100, liquidationThreshold: 8400, liquidationBonus: 10500) |
| 1 | CollateralConfigurationChanged(asset: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 (symbol: WBTC), ltv: 8100, liquidationThreshold: 8500, liquidationBonus: 10500) |
| 2 | CollateralConfigurationChanged(asset: 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf (symbol: cbBTC), ltv: 8100, liquidationThreshold: 8500, liquidationBonus: 10750) |
| 3 | CollateralConfigurationChanged(asset: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 (symbol: wstETH), ltv: 7900, liquidationThreshold: 8200, liquidationBonus: 10600) |
| 4 | CollateralConfigurationChanged(asset: 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee (symbol: weETH), ltv: 7800, liquidationThreshold: 8100, liquidationBonus: 10700) |

#### 0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A (AaveV2Ethereum.POOL_ADMIN, AaveV2EthereumAMM.POOL_ADMIN, AaveV3Ethereum.ACL_ADMIN, AaveV3EthereumEtherFi.ACL_ADMIN, AaveV3EthereumHorizon.ACL_ADMIN, AaveV3EthereumLido.ACL_ADMIN, GovernanceV3Ethereum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 5 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1792149359, withDelegatecall: true, resultData: 0x) |

#### 0xdAbad81aF85554E9ae636395611C58F7eC1aAEc5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 6 | PayloadExecuted(payloadId: 476) |

## Raw storage changes

### 0x87870bca3f3fd6335c3f4ce8392d69350b4fa4e2 (AaveV3Ethereum.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x89c297050f05308a1ebd800db358705332b6d10d9be0598b08aa6c1829173df7 | 0x100000000000000000000003e80000059100000005a01388850829fe1e781c84 | 0x100000000000000000000003e80000059100000005a01388850829fe21341fa4 |
| 0x8ceade8e25499bbf43e93c54022788a929205aeed9322007025beb95ec50b2e3 | 0x100000000000000000000103e800016e3600000000011194811229cc1f401e46 | 0x100000000000000000000103e800016e3600000000011194811229cc1fa41e78 |
| 0xc9d7ec48cd0d839522455f78914adfeda8686316bb6819e0888e4bcd349e01b2 | 0x100000000000000000000103e80000e7ef0000006d600dac811229681fa41eaa | 0x100000000000000000000103e80000e7ef0000006d600dac8112296820081edc |
| 0xd0684f4db7c2f2e52cb69cf1a0bfb094fb45c257ee5dcc06511d6d99da0411e5 | 0x100000000000000000000003e8000009538000000fa01388850829041e781c84 | 0x100000000000000000000003e8000009538000000fa013888508290421341fa4 |
| 0xf81d8d79f42adb4c73cc3aa0c78e25d3343882d0313c0b80ece3d3a103ef1ebf | 0x100000000000000000000103e80002932e0000249f0005dc85122904206c1f72 | 0x100000000000000000000103e80002932e0000249f0005dc8512290420d01fa4 |

### 0xdabad81af85554e9ae636395611c58f7ec1aaec5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x5eda77ce7c986e2641c5f6cd842c95bb947a7b8c2484b5aa6347baaf1f501f5c | 0x006ad2076e000000000002000000000000000000000000000000000000000000 | 0x006ad2076e000000000003000000000000000000000000000000000000000000 |
| 0x5eda77ce7c986e2641c5f6cd842c95bb947a7b8c2484b5aa6347baaf1f501f5d | 0x000000000000000000093a800000000000006b002bef00000000000000000000 | 0x000000000000000000093a800000000000006b002bef0000000000006ad2076f |


## Raw diff

```json
{
  "reserves": {
    "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599": {
      "liquidationThreshold": {
        "from": 7800,
        "to": 8500
      },
      "ltv": {
        "from": 7300,
        "to": 8100
      }
    },
    "0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0": {
      "liquidationThreshold": {
        "from": 8100,
        "to": 8200
      },
      "ltv": {
        "from": 7850,
        "to": 7900
      }
    },
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
      "liquidationThreshold": {
        "from": 8300,
        "to": 8400
      },
      "ltv": {
        "from": 8050,
        "to": 8100
      }
    },
    "0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee": {
      "liquidationThreshold": {
        "from": 8000,
        "to": 8100
      },
      "ltv": {
        "from": 7750,
        "to": 7800
      }
    },
    "0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf": {
      "liquidationThreshold": {
        "from": 7800,
        "to": 8500
      },
      "ltv": {
        "from": 7300,
        "to": 8100
      }
    }
  }
}
```
