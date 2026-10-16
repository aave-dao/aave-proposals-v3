## Reserve changes

### Reserves altered

#### WBTC ([0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599](https://etherscan.io/address/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599))

| description | value before | value after |
| --- | --- | --- |
| liquidationProtocolFee | 10 % [1000] | 20 % [2000] |


#### wstETH ([0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0](https://etherscan.io/address/0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0))

| description | value before | value after |
| --- | --- | --- |
| liquidationProtocolFee | 10 % [1000] | 20 % [2000] |


#### WETH ([0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2](https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))

| description | value before | value after |
| --- | --- | --- |
| liquidationProtocolFee | 10 % [1000] | 20 % [2000] |


## Event logs

#### 0x64b761D848206f447Fe2dd461b0c635Ec39EbB27 (AaveV3Ethereum.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | LiquidationProtocolFeeChanged(asset: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599 (symbol: WBTC), oldFee: 1000, newFee: 2000) |
| 1 | LiquidationProtocolFeeChanged(asset: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 (symbol: WETH), oldFee: 1000, newFee: 2000) |
| 2 | LiquidationProtocolFeeChanged(asset: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 (symbol: wstETH), oldFee: 1000, newFee: 2000) |

#### 0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A (AaveV2Ethereum.POOL_ADMIN, AaveV2EthereumAMM.POOL_ADMIN, AaveV3Ethereum.ACL_ADMIN, AaveV3EthereumEtherFi.ACL_ADMIN, AaveV3EthereumHorizon.ACL_ADMIN, AaveV3EthereumLido.ACL_ADMIN, GovernanceV3Ethereum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 3 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1792148591, withDelegatecall: true, resultData: 0x) |

#### 0xdAbad81aF85554E9ae636395611C58F7eC1aAEc5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 4 | PayloadExecuted(payloadId: 476) |

## Raw storage changes

### 0x87870bca3f3fd6335c3f4ce8392d69350b4fa4e2 (AaveV3Ethereum.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0xc9d7ec48cd0d839522455f78914adfeda8686316bb6819e0888e4bcd349e01b2 | 0x100000000000000000000103e80000e7ef0000006d600dac811229681fa41eaa | 0x100000000000000000000107d00000e7ef0000006d600dac811229681fa41eaa |
| 0xd0684f4db7c2f2e52cb69cf1a0bfb094fb45c257ee5dcc06511d6d99da0411e5 | 0x100000000000000000000003e8000009538000000fa01388850829041e781c84 | 0x100000000000000000000007d0000009538000000fa01388850829041e781c84 |
| 0xf81d8d79f42adb4c73cc3aa0c78e25d3343882d0313c0b80ece3d3a103ef1ebf | 0x100000000000000000000103e80002932e0000249f0005dc85122904206c1f72 | 0x100000000000000000000107d00002932e0000249f0005dc85122904206c1f72 |

### 0xdabad81af85554e9ae636395611c58f7ec1aaec5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x5eda77ce7c986e2641c5f6cd842c95bb947a7b8c2484b5aa6347baaf1f501f5c | 0x006ad2046e000000000002000000000000000000000000000000000000000000 | 0x006ad2046e000000000003000000000000000000000000000000000000000000 |
| 0x5eda77ce7c986e2641c5f6cd842c95bb947a7b8c2484b5aa6347baaf1f501f5d | 0x000000000000000000093a800000000000006b0028ef00000000000000000000 | 0x000000000000000000093a800000000000006b0028ef0000000000006ad2046f |


## Raw diff

```json
{
  "reserves": {
    "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599": {
      "liquidationProtocolFee": {
        "from": 1000,
        "to": 2000
      }
    },
    "0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0": {
      "liquidationProtocolFee": {
        "from": 1000,
        "to": 2000
      }
    },
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
      "liquidationProtocolFee": {
        "from": 1000,
        "to": 2000
      }
    }
  }
}
```
