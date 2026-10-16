## Reserve changes

### Reserves altered

#### WBTC ([0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f](https://arbiscan.io/address/0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f))

| description | value before | value after |
| --- | --- | --- |
| ltv | 73 % [7300] | 78 % [7800] |
| liquidationThreshold | 78 % [7800] | 82 % [8200] |


#### WETH ([0x82aF49447D8a07e3bd95BD0d56f35241523fBab1](https://arbiscan.io/address/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1))

| description | value before | value after |
| --- | --- | --- |
| ltv | 80 % [8000] | 81 % [8100] |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Arbitrum.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | CollateralConfigurationChanged(asset: 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1 (symbol: WETH), ltv: 8100, liquidationThreshold: 8400, liquidationBonus: 10500) |
| 1 | CollateralConfigurationChanged(asset: 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f (symbol: WBTC), ltv: 7800, liquidationThreshold: 8200, liquidationBonus: 10700) |

#### 0xFF1137243698CaA18EE364Cc966CF0e02A4e6327 (AaveV3Arbitrum.ACL_ADMIN, GovernanceV3Arbitrum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 2 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1792149362, withDelegatecall: true, resultData: 0x) |

#### 0x89644CA1bB8064760312AE4F03ea41b05dA3637C (GovernanceV3Arbitrum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 3 | PayloadExecuted(payloadId: 140) |

## Raw storage changes

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Arbitrum.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x81bfc5c4d8db0b066f0ddd66ff71a6b6aa92e2c76f0f6196fb75153e955b4f36 | 0x100000000000000000000203e80000249f0000020f5805dc8512290420d01f40 | 0x100000000000000000000203e80000249f0000020f5805dc8512290420d01fa4 |
| 0xbd2d9d9236e2d14223516bc8ae27740fb40c9a497aaaaa75e8b8fcc33648771b | 0x100000000000000000000003e8000000dac0000001a01388850829cc1e781c84 | 0x100000000000000000000003e8000000dac0000001a01388850829cc20081e78 |

### 0x89644ca1bb8064760312ae4f03ea41b05da3637c (GovernanceV3Arbitrum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x83339eadc78535e76a031a9a544cf6fa252296becf88992d49fad5f832544a38 | 0x006ad20771000000000002000000000000000000000000000000000000000000 | 0x006ad20771000000000003000000000000000000000000000000000000000000 |
| 0x83339eadc78535e76a031a9a544cf6fa252296becf88992d49fad5f832544a39 | 0x000000000000000000093a800000000000006b002bf200000000000000000000 | 0x000000000000000000093a800000000000006b002bf20000000000006ad20772 |


## Raw diff

```json
{
  "reserves": {
    "0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f": {
      "liquidationThreshold": {
        "from": 7800,
        "to": 8200
      },
      "ltv": {
        "from": 7300,
        "to": 7800
      }
    },
    "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1": {
      "ltv": {
        "from": 8000,
        "to": 8100
      }
    }
  }
}
```
