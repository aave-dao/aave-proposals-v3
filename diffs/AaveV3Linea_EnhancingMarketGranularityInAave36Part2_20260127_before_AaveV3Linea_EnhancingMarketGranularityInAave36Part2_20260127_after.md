## Reserve changes

### Reserves altered

#### ezETH ([0x2416092f143378750bb29b79eD961ab195CcEea5](https://lineascan.build/address/0x2416092f143378750bb29b79eD961ab195CcEea5))

| description | value before | value after |
| --- | --- | --- |
| ltv | 72.5 % [7250] | 0 % [0] |


#### wstETH ([0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F](https://lineascan.build/address/0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### wrsETH ([0xD2671165570f41BBB3B0097893300b6EB6101E6C](https://lineascan.build/address/0xD2671165570f41BBB3B0097893300b6EB6101E6C))

| description | value before | value after |
| --- | --- | --- |
| ltv | 70 % [7000] | 0 % [0] |


## EMode changes

### EMode: ezETH__USDC_USDT (id: 5)

| description | value before | value after |
| --- | --- | --- |
| label | - | ezETH__USDC_USDT |
| ltv | - | 72.5 % |
| liquidationThreshold | - | 75 % |
| liquidationBonus | - | 7.5 % [10750] |
| borrowableBitmap | - | USDC, USDT |
| collateralBitmap | - | ezETH |


## Event logs

#### 0x812E7c19421D9f41A6DDCF047d5cc2dE2Ca5Bfa2 (AaveV3Linea.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 5, ltv: 7250, liquidationThreshold: 7500, liquidationBonus: 10750, oracle: 0x0000000000000000000000000000000000000000, label: ezETH__USDC_USDT) |
| 1 | AssetCollateralInEModeChanged(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), categoryId: 5, collateral: true) |
| 2 | AssetBorrowableInEModeChanged(asset: 0x176211869cA2b568f2A7D4EE941E073a821EE1ff (symbol: USDC), categoryId: 5, borrowable: true) |
| 3 | AssetBorrowableInEModeChanged(asset: 0xA219439258ca9da29E9Cc4cE5596924745e12B93 (symbol: USDT), categoryId: 5, borrowable: true) |
| 4 | ReserveBorrowing(asset: 0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F (symbol: wstETH), enabled: false) |
| 5 | CollateralConfigurationChanged(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), ltv: 0, liquidationThreshold: 7500, liquidationBonus: 10750) |
| 6 | CollateralConfigurationChanged(asset: 0xD2671165570f41BBB3B0097893300b6EB6101E6C (symbol: wrsETH), ltv: 0, liquidationThreshold: 7300, liquidationBonus: 11000) |

#### 0x8c2d95FE7aeB57b86961F3abB296A54f0ADb7F88 (AaveV3Linea.ACL_ADMIN, GovernanceV3Linea.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 7 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1770805763, withDelegatecall: true, resultData: 0x) |

#### 0x3BcE23a1363728091bc57A58a226CF2940C2e074 (GovernanceV3Linea.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 8 | PayloadExecuted(payloadId: 21) |

## Raw storage changes

### 0x3bce23a1363728091bc57a58a226cf2940c2e074 (GovernanceV3Linea.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x94f2575c7592b1dfd5a8846a17482da7b0e38fb10c93880d74916c5f16792464 | 0x00698c5a02000000000002000000000000000000000000000000000000000000 | 0x00698c5a02000000000003000000000000000000000000000000000000000000 |
| 0x94f2575c7592b1dfd5a8846a17482da7b0e38fb10c93880d74916c5f16792465 | 0x000000000000000000093a8000000000000069ba7e8300000000000000000000 | 0x000000000000000000093a8000000000000069ba7e83000000000000698c5a03 |

### 0xc47b8c00b0f69a36fa203ffeac0334874574a8ac (AaveV3Linea.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x0555d39d14c318dd3fd549cef0a010aff224252cdce9cfef2c350d76cc8a7040 | 0x100000000000000000000003e8000007530000000000119481122af81c841b58 | 0x100000000000000000000003e8000007530000000000119481122af81c840000 |
| 0x50039cf134a124858bd88bbc9225ec3c537b89a0e9237ce39fe1813e6edf8257 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000002029fe1d4c1c52 |
| 0x50039cf134a124858bd88bbc9225ec3c537b89a0e9237ce39fe1813e6edf8258 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x657a4554485f5f555344435f5553445400000000000000000000000000000020 |
| 0x50039cf134a124858bd88bbc9225ec3c537b89a0e9237ce39fe1813e6edf8259 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000000000000000000c |
| 0x80d3b16018b60b749d2bc1c0b179418bf0067c8de4f67a7e0e09c0f02bf661b2 | 0x100000000000000000000003e8000012c000000000011194811229fe1d4c1c52 | 0x100000000000000000000003e8000012c000000000011194811229fe1d4c0000 |
| 0x93edf0d849d0004112c50b390a5a5697e3b8453a41d624f054adf855aab35092 | 0x100000000000000000000003e8000004b000000012c001f4851229cc1edc1d4c | 0x100000000000000000000003e8000004b000000012c001f4811229cc1edc1d4c |


## Raw diff

```json
{
  "eModes": {
    "5": {
      "from": null,
      "to": {
        "borrowableBitmap": "12",
        "collateralBitmap": "32",
        "eModeCategory": 5,
        "label": "ezETH__USDC_USDT",
        "liquidationBonus": 10750,
        "liquidationThreshold": 7500,
        "ltv": 7250
      }
    }
  },
  "reserves": {
    "0x2416092f143378750bb29b79eD961ab195CcEea5": {
      "ltv": {
        "from": 7250,
        "to": 0
      }
    },
    "0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0xD2671165570f41BBB3B0097893300b6EB6101E6C": {
      "ltv": {
        "from": 7000,
        "to": 0
      }
    }
  }
}
```
