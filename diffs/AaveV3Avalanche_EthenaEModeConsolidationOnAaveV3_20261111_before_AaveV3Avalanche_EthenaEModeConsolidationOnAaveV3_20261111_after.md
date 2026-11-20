## EMode changes

### EMode: USDe/Stablecoin (id: 3)

| description | value before | value after |
| --- | --- | --- |
| ltv | 89 % | 91 % |
| liquidationThreshold | 92 % | 93 % |


### EMode: sUSDe/Stablecoin (id: 4)

| description | value before | value after |
| --- | --- | --- |
| ltv | 89 % | 90 % |
| liquidationThreshold | 91 % | 92 % |
| borrowableBitmap | USDC, USDt, GHO, USDe | USDC, USDt, GHO |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Avalanche.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 3, ltv: 9100, liquidationThreshold: 9300, liquidationBonus: 10200, oracle: 0x0000000000000000000000000000000000000000, label: USDe/Stablecoin) |
| 1 | EModeCategoryIsolationChanged(categoryId: 3, isolated: false) |
| 2 | EModeCategoryAdded(categoryId: 4, ltv: 9000, liquidationThreshold: 9200, liquidationBonus: 10400, oracle: 0x0000000000000000000000000000000000000000, label: sUSDe/Stablecoin) |
| 3 | EModeCategoryIsolationChanged(categoryId: 4, isolated: false) |
| 4 | AssetBorrowableInEModeChanged(asset: 0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34 (symbol: USDe), categoryId: 4, borrowable: false) |

#### 0x3C06dce358add17aAf230f2234bCCC4afd50d090 (AaveV2Avalanche.POOL_ADMIN, AaveV3Avalanche.ACL_ADMIN, GovernanceV3Avalanche.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 5 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1794430095, withDelegatecall: true, resultData: 0x) |

#### 0x1140CB7CAfAcC745771C2Ea31e7B5C653c5d0B80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 6 | PayloadExecuted(payloadId: 131) |

## Raw storage changes

### 0x1140cb7cafacc745771c2ea31e7b5c653c5d0b80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x93d1935305b2d38c36a29894407d9e2a1bc6d663aa42bffc7b7c21e606326569 | 0x006af4d48e000000000002000000000000000000000000000000000000000000 | 0x006af4d48e000000000003000000000000000000000000000000000000000000 |
| 0x93d1935305b2d38c36a29894407d9e2a1bc6d663aa42bffc7b7c21e60632656a | 0x000000000000000000093a800000000000006b22f90f00000000000000000000 | 0x000000000000000000093a800000000000006b22f90f0000000000006af4d48f |

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Avalanche.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354c | 0x000000000000000000000000000000000000000000000001000028a0238c22c4 | 0x000000000000000000000000000000000000000000000001000028a023f02328 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354d | 0x73555344652f537461626c65636f696e00000000000000000000000000000020 | 0x73555344652f537461626c65636f696e00000000000000000000000000000020 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354e | 0x000000000000000000000000000000000000000000000000000000000000a024 | 0x0000000000000000000000000000000000000000000000000000000000002024 |
| 0x81d0999fde243adcc41b7fa1be5cea14f789e3a6065b815ac58f4bc0838c3155 | 0x000000000000000000000000000000000000000000000000800027d823f022c4 | 0x000000000000000000000000000000000000000000000000800027d82454238c |
| 0x81d0999fde243adcc41b7fa1be5cea14f789e3a6065b815ac58f4bc0838c3156 | 0x555344652f537461626c65636f696e000000000000000000000000000000001e | 0x555344652f537461626c65636f696e000000000000000000000000000000001e |


## Raw diff

```json
{
  "eModes": {
    "3": {
      "liquidationThreshold": {
        "from": 9200,
        "to": 9300
      },
      "ltv": {
        "from": 8900,
        "to": 9100
      }
    },
    "4": {
      "borrowableBitmap": {
        "from": "40996",
        "to": "8228"
      },
      "liquidationThreshold": {
        "from": 9100,
        "to": 9200
      },
      "ltv": {
        "from": 8900,
        "to": 9000
      }
    }
  }
}
```
