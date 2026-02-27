## Reserve changes

### Reserves altered

#### wstETH ([0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD](https://polygonscan.com/address/0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### WPOL ([0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270](https://polygonscan.com/address/0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### USDC ([0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174](https://polygonscan.com/address/0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### LINK ([0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39](https://polygonscan.com/address/0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39))

| description | value before | value after |
| --- | --- | --- |
| ltv | 66 % [6600] | 0 % [0] |
| borrowingEnabled | :white_check_mark: | :x: |


#### AAVE ([0xD6DF932A45C0f255f85145f286eA0b292B21C90B](https://polygonscan.com/address/0xD6DF932A45C0f255f85145f286eA0b292B21C90B))

| description | value before | value after |
| --- | --- | --- |
| ltv | 63 % [6300] | 0 % [0] |


#### EURS ([0xE111178A87A3BFf0c8d18DECBa5798827539Ae99](https://polygonscan.com/address/0xE111178A87A3BFf0c8d18DECBa5798827539Ae99))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### MaticX ([0xfa68FB4628DFF1028CFEc22b4162FCcd0d45efb6](https://polygonscan.com/address/0xfa68FB4628DFF1028CFEc22b4162FCcd0d45efb6))

| description | value before | value after |
| --- | --- | --- |
| ltv | 50 % [5000] | 0 % [0] |


## EMode changes

### EMode: AAVE__USDCn_USDT (id: 4)

| description | value before | value after |
| --- | --- | --- |
| label | - | AAVE__USDCn_USDT |
| ltv | - | 63 % |
| liquidationThreshold | - | 70 % |
| liquidationBonus | - | 7.5 % [10750] |
| borrowableBitmap | - | USDT0, USDC |
| collateralBitmap | - | AAVE |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Polygon.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 4, ltv: 6300, liquidationThreshold: 7000, liquidationBonus: 10750, oracle: 0x0000000000000000000000000000000000000000, label: AAVE__USDCn_USDT) |
| 1 | AssetCollateralInEModeChanged(asset: 0xD6DF932A45C0f255f85145f286eA0b292B21C90B (symbol: AAVE), categoryId: 4, collateral: true) |
| 2 | AssetBorrowableInEModeChanged(asset: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F (symbol: USDT0), categoryId: 4, borrowable: true) |
| 3 | AssetBorrowableInEModeChanged(asset: 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359 (symbol: USDC), categoryId: 4, borrowable: true) |
| 4 | ReserveBorrowing(asset: 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39 (symbol: LINK), enabled: false) |
| 5 | ReserveBorrowing(asset: 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174 (symbol: USDC), enabled: false) |
| 6 | ReserveBorrowing(asset: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270 (symbol: WPOL), enabled: false) |
| 7 | ReserveBorrowing(asset: 0xE111178A87A3BFf0c8d18DECBa5798827539Ae99 (symbol: EURS), enabled: false) |
| 8 | ReserveBorrowing(asset: 0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD (symbol: wstETH), enabled: false) |
| 9 | CollateralConfigurationChanged(asset: 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39 (symbol: LINK), ltv: 0, liquidationThreshold: 7100, liquidationBonus: 10750) |
| 10 | CollateralConfigurationChanged(asset: 0xD6DF932A45C0f255f85145f286eA0b292B21C90B (symbol: AAVE), ltv: 0, liquidationThreshold: 7000, liquidationBonus: 10750) |
| 11 | CollateralConfigurationChanged(asset: 0xfa68FB4628DFF1028CFEc22b4162FCcd0d45efb6 (symbol: MaticX), ltv: 0, liquidationThreshold: 6000, liquidationBonus: 11000) |

#### 0xDf7d0e6454DB638881302729F5ba99936EaAB233 (AaveV2Polygon.POOL_ADMIN, AaveV3Polygon.ACL_ADMIN, GovernanceV3Polygon.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 12 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1770805843, withDelegatecall: true, resultData: 0x) |

#### 0x401B5D0294E23637c18fcc38b1Bca814CDa2637C (GovernanceV3Polygon.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 13 | PayloadExecuted(payloadId: 139) |

## Raw storage changes

### 0x401b5d0294e23637c18fcc38b1bca814cda2637c (GovernanceV3Polygon.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xef5e0849f239dbb5067e216b8ecbe8b6e9b8d5d1d458195d30e849b313afe11f | 0x00698c5a52000000000002000000000000000000000000000000000000000000 | 0x00698c5a52000000000003000000000000000000000000000000000000000000 |
| 0xef5e0849f239dbb5067e216b8ecbe8b6e9b8d5d1d458195d30e849b313afe120 | 0x000000000000000000093a8000000000000069ba7ed300000000000000000000 | 0x000000000000000000093a8000000000000069ba7ed3000000000000698c5a53 |

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Polygon.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x4eb4e5a6e8e7d99cfc6b20a4316cf17fcae80ee90389b4de8cfd0d3328359b3f | 0x100000000640000000000103e80000000010000000011388850229fe1b580000 | 0x100000000640000000000103e80000000010000000011388810229fe1b580000 |
| 0x5086f8006fb47d4e8b7d07ce95e816ef3f62d9d614c3cca018dfb9c36698b59e | 0x100000000000000000000103e8000b71b000007ef0181770a50629041e780000 | 0x100000000000000000000103e8000b71b000007ef0181770a10629041e780000 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354c | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000004029fe1b58189c |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354d | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x414156455f5f555344436e5f5553445400000000000000000000000000000020 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354e | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000100020 |
| 0x7106c69342d46bbeee5f28f376a6e3d96f0a8e1d092c714a8fe8243ea96d0a1a | 0x100000000000000000000003e80000b7d6800000000107d0851229fe1bbc19c8 | 0x100000000000000000000003e80000b7d6800000000107d0811229fe1bbc0000 |
| 0xd449fc9fb262d3f5e51cacbd5c816fb9866cc63c91d2a0e5827976b5261df62e | 0x100000000000000000000303e8000002cec00000016201f4851229e01edc1d4c | 0x100000000000000000000303e8000002cec00000016201f4811229e01edc1d4c |
| 0xd87cce9b5faabfdec37f32d8c75e0689cf8e2c9faac27b070479c3cf61dba3ed | 0x100000000000000000000203e8007270e0000000000107d081122af817701388 | 0x100000000000000000000203e8007270e0000000000107d081122af817700000 |
| 0xdf1a6bcffc84e5022e593141ae5e116942c789b8d0a6e6292fbaa854107f991c | 0x100000000000000000000203e8006422c40001d0533007d0851229cc1c841a90 | 0x100000000000000000000203e8006422c40001d0533007d0811229cc1c841a90 |
| 0xfc8cf3b078b74c390422232f5effbbda16d920b580936e190b4535084eb74810 | 0x100000000000000000000003e8000011d280000000000000811229fe1b58189c | 0x100000000000000000000003e8000011d280000000000000811229fe1b580000 |


## Raw diff

```json
{
  "eModes": {
    "4": {
      "from": null,
      "to": {
        "borrowableBitmap": "1048608",
        "collateralBitmap": "64",
        "eModeCategory": 4,
        "label": "AAVE__USDCn_USDT",
        "liquidationBonus": 10750,
        "liquidationThreshold": 7000,
        "ltv": 6300
      }
    }
  },
  "reserves": {
    "0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      },
      "ltv": {
        "from": 6600,
        "to": 0
      }
    },
    "0xD6DF932A45C0f255f85145f286eA0b292B21C90B": {
      "ltv": {
        "from": 6300,
        "to": 0
      }
    },
    "0xE111178A87A3BFf0c8d18DECBa5798827539Ae99": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0xfa68FB4628DFF1028CFEc22b4162FCcd0d45efb6": {
      "ltv": {
        "from": 5000,
        "to": 0
      }
    }
  }
}
```
