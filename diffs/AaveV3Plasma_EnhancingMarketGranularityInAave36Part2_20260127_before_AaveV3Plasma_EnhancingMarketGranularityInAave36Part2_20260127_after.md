## Reserve changes

### Reserves altered

#### XAUt0 ([0x1B64B9025EEbb9A6239575dF9Ea4b9Ac46D4d193](https://plasmascan.to/address/0x1B64B9025EEbb9A6239575dF9Ea4b9Ac46D4d193))

| description | value before | value after |
| --- | --- | --- |
| debtCeiling | 18,000,000 $ [1800000000] | 0 $ [0] |
| ltv | 70 % [7000] | 0 % [0] |


#### sUSDe ([0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2](https://plasmascan.to/address/0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### USDe ([0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34](https://plasmascan.to/address/0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34))

| description | value before | value after |
| --- | --- | --- |
| ltv | 72 % [7200] | 0 % [0] |


#### weETH ([0xA3D68b74bF0528fdD07263c60d6488749044914b](https://plasmascan.to/address/0xA3D68b74bF0528fdD07263c60d6488749044914b))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### syrupUSDT ([0xC4374775489CB9C56003BF2C9b12495fC64F0771](https://plasmascan.to/address/0xC4374775489CB9C56003BF2C9b12495fC64F0771))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### wrsETH ([0xe561FE05C39075312Aa9Bc6af79DdaE981461359](https://plasmascan.to/address/0xe561FE05C39075312Aa9Bc6af79DdaE981461359))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


## EMode changes

### EMode: XAUt__USDT (id: 17)

| description | value before | value after |
| --- | --- | --- |
| label | - | XAUt__USDT |
| ltv | - | 70 % |
| liquidationThreshold | - | 75 % |
| liquidationBonus | - | 7.5 % [10750] |
| borrowableBitmap | - | USDT0 |
| collateralBitmap | - | XAUt0 |


## Event logs

#### 0xc022B6c71c30A8Ad52Dac504eFA132d13D99d2D9 (AaveV3Plasma.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 17, ltv: 7000, liquidationThreshold: 7500, liquidationBonus: 10750, oracle: 0x0000000000000000000000000000000000000000, label: XAUt__USDT) |
| 1 | AssetCollateralInEModeChanged(asset: 0x1B64B9025EEbb9A6239575dF9Ea4b9Ac46D4d193 (symbol: XAUt0), categoryId: 17, collateral: true) |
| 2 | AssetBorrowableInEModeChanged(asset: 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb (symbol: USDT0), categoryId: 17, borrowable: true) |
| 3 | CollateralConfigurationChanged(asset: 0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34 (symbol: USDe), ltv: 0, liquidationThreshold: 7500, liquidationBonus: 10850) |
| 4 | CollateralConfigurationChanged(asset: 0x1B64B9025EEbb9A6239575dF9Ea4b9Ac46D4d193 (symbol: XAUt0), ltv: 0, liquidationThreshold: 7500, liquidationBonus: 10750) |
| 6 | DebtCeilingChanged(asset: 0x1B64B9025EEbb9A6239575dF9Ea4b9Ac46D4d193 (symbol: XAUt0), oldDebtCeiling: 1800000000, newDebtCeiling: 0) |
| 7 | CollateralConfigurationChanged(asset: 0xA3D68b74bF0528fdD07263c60d6488749044914b (symbol: weETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10700) |
| 8 | CollateralConfigurationChanged(asset: 0xC4374775489CB9C56003BF2C9b12495fC64F0771 (symbol: syrupUSDT), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10600) |
| 9 | CollateralConfigurationChanged(asset: 0xe561FE05C39075312Aa9Bc6af79DdaE981461359 (symbol: wrsETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10700) |
| 10 | CollateralConfigurationChanged(asset: 0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2 (symbol: sUSDe), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10850) |

#### 0x925a2A7214Ed92428B5b1B090F80b25700095e12 (AaveV3Plasma.POOL)

| index | event |
| --- | --- |
| 5 | topics: `0xaef84d3b40895fd58c561f3998000f0583abb992a52fbdc99ace8e8de4d676a5`, `0x0000000000000000000000001b64b9025eebb9a6239575df9ea4b9ac46d4d193`, data: `0x0000000000000000000000000000000000000000000000000000000000000000` |

#### 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A (AaveV3Plasma.ACL_ADMIN, GovernanceV3Plasma.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 11 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1770805802, withDelegatecall: true, resultData: 0x) |

#### 0xe76EB348E65eF163d85ce282125FF5a7F5712A1d (GovernanceV3Plasma.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 12 | PayloadExecuted(payloadId: 17) |

## Raw storage changes

### 0x925a2a7214ed92428b5b1b090f80b25700095e12 (AaveV3Plasma.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x0ee1b4748ece9938d60c5a08c06fdcc57c304bfbc0758f61e612ab3ee93ce023 | 0x100000000000000000000003e80684ee180023c3460009c485122a621d4c1c20 | 0x100000000000000000000003e80684ee180023c3460009c485122a621d4c0000 |
| 0x0f69e495df4462160fbe947b1aac24bd3791eb88f23edd1cd5f46506f4070e42 | 0x1006b49d2000000000000003e8000001b5800000000107d0810629fe1d4c1b58 | 0x100000000000000000000003e8000001b5800000000107d0810629fe1d4c0000 |
| 0x0f69e495df4462160fbe947b1aac24bd3791eb88f23edd1cd5f46506f4070e4b | 0x00000000000000000000000000000000000000000000000000000000306ecfeb | 0x0000000000000000000000000000000000000000000000000000000000000000 |
| 0x52f7f1440ab20fcadde51b79423bd2f17e1c58bc3878efc43624e8de64ae798f | 0x100000000000000000000003e800003a98000000000107d0811229cc000a0005 | 0x100000000000000000000003e800003a98000000000107d0811229cc000a0000 |
| 0x7635c6f6fb0dc990d132e97ffe82e07606fac72c3d39da71ac41d6a8564addda | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000000829fe1d4c1b58 |
| 0x7635c6f6fb0dc990d132e97ffe82e07606fac72c3d39da71ac41d6a8564adddb | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x584155745f5f5553445400000000000000000000000000000000000000000014 |
| 0x7635c6f6fb0dc990d132e97ffe82e07606fac72c3d39da71ac41d6a8564adddc | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000001 |
| 0xa2611fffb1563e77311e06c60d4d847b1804f1b210a636975fa6e9c20cb74aaa | 0x100000000000000000000003e801ad27480000000001119481062968000a0005 | 0x100000000000000000000003e801ad27480000000001119481062968000a0000 |
| 0xb69e101291cae8ac8885e4f60b77f31b4a9feff65bb4172464a0e8f08242ae35 | 0x100000000000000000000003e805de097c000000000107d081122a62000a0005 | 0x100000000000000000000003e805de097c000000000107d081122a62000a0000 |
| 0xf235290065507aca56dd1272ea508d53a3f4f7d822b50f8bbe62ce44a2aace13 | 0x100000000000000000000003e8000004e200000000011194811229cc000a0005 | 0x100000000000000000000003e8000004e200000000011194811229cc000a0000 |

### 0xe76eb348e65ef163d85ce282125ff5a7f5712a1d (GovernanceV3Plasma.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xfc111d09a6e2f0958402cbe16a5aef32c9d8ddb9a4df7271140de57bfed6525a | 0x00698c5a29000000000002000000000000000000000000000000000000000000 | 0x00698c5a29000000000003000000000000000000000000000000000000000000 |
| 0xfc111d09a6e2f0958402cbe16a5aef32c9d8ddb9a4df7271140de57bfed6525b | 0x000000000000000000093a8000000000000069ba7eaa00000000000000000000 | 0x000000000000000000093a8000000000000069ba7eaa000000000000698c5a2a |


## Raw diff

```json
{
  "eModes": {
    "17": {
      "from": null,
      "to": {
        "borrowableBitmap": "1",
        "collateralBitmap": "8",
        "eModeCategory": 17,
        "label": "XAUt__USDT",
        "liquidationBonus": 10750,
        "liquidationThreshold": 7500,
        "ltv": 7000
      }
    }
  },
  "reserves": {
    "0x1B64B9025EEbb9A6239575dF9Ea4b9Ac46D4d193": {
      "debtCeiling": {
        "from": 1800000000,
        "to": 0
      },
      "ltv": {
        "from": 7000,
        "to": 0
      }
    },
    "0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34": {
      "ltv": {
        "from": 7200,
        "to": 0
      }
    },
    "0xA3D68b74bF0528fdD07263c60d6488749044914b": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xC4374775489CB9C56003BF2C9b12495fC64F0771": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xe561FE05C39075312Aa9Bc6af79DdaE981461359": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    }
  }
}
```
