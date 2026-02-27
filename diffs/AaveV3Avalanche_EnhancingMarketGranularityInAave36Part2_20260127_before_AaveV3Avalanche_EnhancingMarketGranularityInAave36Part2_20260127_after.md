## Reserve changes

### Reserves altered

#### LINK.e ([0x5947BB275c521040051D82396192181b413227A3](https://snowscan.xyz/address/0x5947BB275c521040051D82396192181b413227A3))

| description | value before | value after |
| --- | --- | --- |
| borrowCap | 45,000 LINK.e | 1 LINK.e |
| ltv | 66 % [6600] | 0 % [0] |
| borrowingEnabled | :white_check_mark: | :x: |


#### AAVE.e ([0x63a72806098Bd3D9520cC43356dD78afe5D386D9](https://snowscan.xyz/address/0x63a72806098Bd3D9520cC43356dD78afe5D386D9))

| description | value before | value after |
| --- | --- | --- |
| ltv | 63 % [6300] | 0 % [0] |


#### wrsETH ([0x7bFd4CA2a6Cf3A3fDDd645D10B323031afe47FF0](https://snowscan.xyz/address/0x7bFd4CA2a6Cf3A3fDDd645D10B323031afe47FF0))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### EURC ([0xC891EB4cbdEFf6e073e859e987815Ed1505c2ACD](https://snowscan.xyz/address/0xC891EB4cbdEFf6e073e859e987815Ed1505c2ACD))

| description | value before | value after |
| --- | --- | --- |
| ltv | 75 % [7500] | 0 % [0] |


## EMode changes

### EMode: EURC__USDC_USDT (id: 6)

| description | value before | value after |
| --- | --- | --- |
| label | - | EURC__USDC_USDT |
| ltv | - | 75 % |
| liquidationThreshold | - | 78 % |
| liquidationBonus | - | 5 % [10500] |
| borrowableBitmap | - | USDC, USDt |
| collateralBitmap | - | EURC |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Avalanche.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 6, ltv: 7500, liquidationThreshold: 7800, liquidationBonus: 10500, oracle: 0x0000000000000000000000000000000000000000, label: EURC__USDC_USDT) |
| 1 | AssetCollateralInEModeChanged(asset: 0xC891EB4cbdEFf6e073e859e987815Ed1505c2ACD (symbol: EURC), categoryId: 6, collateral: true) |
| 2 | AssetBorrowableInEModeChanged(asset: 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E (symbol: USDC), categoryId: 6, borrowable: true) |
| 3 | AssetBorrowableInEModeChanged(asset: 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7 (symbol: USDt), categoryId: 6, borrowable: true) |
| 4 | ReserveBorrowing(asset: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), enabled: false) |
| 5 | CollateralConfigurationChanged(asset: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), ltv: 0, liquidationThreshold: 7100, liquidationBonus: 10750) |
| 6 | CollateralConfigurationChanged(asset: 0x63a72806098Bd3D9520cC43356dD78afe5D386D9 (symbol: AAVE.e), ltv: 0, liquidationThreshold: 7000, liquidationBonus: 10750) |
| 7 | CollateralConfigurationChanged(asset: 0xC891EB4cbdEFf6e073e859e987815Ed1505c2ACD (symbol: EURC), ltv: 0, liquidationThreshold: 7800, liquidationBonus: 10500) |
| 8 | CollateralConfigurationChanged(asset: 0x7bFd4CA2a6Cf3A3fDDd645D10B323031afe47FF0 (symbol: wrsETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10700) |
| 9 | BorrowCapChanged(asset: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), oldBorrowCap: 45000, newBorrowCap: 1) |

#### 0x3C06dce358add17aAf230f2234bCCC4afd50d090 (AaveV2Avalanche.POOL_ADMIN, AaveV3Avalanche.ACL_ADMIN, GovernanceV3Avalanche.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 10 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1770805620, withDelegatecall: true, resultData: 0x) |

#### 0x1140CB7CAfAcC745771C2Ea31e7B5C653c5d0B80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 11 | PayloadExecuted(payloadId: 107) |

## Raw storage changes

### 0x1140cb7cafacc745771c2ea31e7b5c653c5d0b80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x296cfac21069339fcd7b6795214eac09a46f358e68cba56520ec496c3c1f4ad5 | 0x00698c5973000000000002000000000000000000000000000000000000000000 | 0x00698c5973000000000003000000000000000000000000000000000000000000 |
| 0x296cfac21069339fcd7b6795214eac09a46f358e68cba56520ec496c3c1f4ad6 | 0x000000000000000000093a8000000000000069ba7df400000000000000000000 | 0x000000000000000000093a8000000000000069ba7df4000000000000698c5974 |

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Avalanche.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x01290583d43e205f46f8d824d1236df318521e471f570a5b36fa1844856e40d6 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000400029041e781d4c |
| 0x01290583d43e205f46f8d824d1236df318521e471f570a5b36fa1844856e40d7 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x455552435f5f555344435f55534454000000000000000000000000000000001e |
| 0x01290583d43e205f46f8d824d1236df318521e471f570a5b36fa1844856e40d8 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000024 |
| 0x25a922d75e2aaab8592dc46a8370195c26f61c233dc944290b27aa0dbd9ef70b | 0x100000000000000000000003e800006b6c000000afc807d0851229fe1bbc19c8 | 0x100000000000000000000003e800006b6c000000000107d0811229fe1bbc0000 |
| 0x2a7909caa58f2aafa4aa80a78d11afd8a031d07aa8b6f3706ecd1984b27d326f | 0x100000000000000000000003e8000b71b00000aae60003e8850629041e781d4c | 0x100000000000000000000003e8000b71b00000aae60003e8850629041e780000 |
| 0x2ef0af43460a7d17297e15c9980a774850f93f9db2b1c0c472493f417a9a533a | 0x100000000000000000000003e8000001c200000000000000811229fe1b58189c | 0x100000000000000000000003e8000001c200000000000000811229fe1b580000 |
| 0xb812b08fc94f6751621c5f09eda8cff1b6d95c23621bb67471e4a584de3a2b6a | 0x100000000000000000000003e80000061a80000000011194811229cc000a0005 | 0x100000000000000000000003e80000061a80000000011194811229cc000a0000 |


## Raw diff

```json
{
  "eModes": {
    "6": {
      "from": null,
      "to": {
        "borrowableBitmap": "36",
        "collateralBitmap": "16384",
        "eModeCategory": 6,
        "label": "EURC__USDC_USDT",
        "liquidationBonus": 10500,
        "liquidationThreshold": 7800,
        "ltv": 7500
      }
    }
  },
  "reserves": {
    "0x5947BB275c521040051D82396192181b413227A3": {
      "borrowCap": {
        "from": 45000,
        "to": 1
      },
      "borrowingEnabled": {
        "from": true,
        "to": false
      },
      "ltv": {
        "from": 6600,
        "to": 0
      }
    },
    "0x63a72806098Bd3D9520cC43356dD78afe5D386D9": {
      "ltv": {
        "from": 6300,
        "to": 0
      }
    },
    "0x7bFd4CA2a6Cf3A3fDDd645D10B323031afe47FF0": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xC891EB4cbdEFf6e073e859e987815Ed1505c2ACD": {
      "ltv": {
        "from": 7500,
        "to": 0
      }
    }
  }
}
```
