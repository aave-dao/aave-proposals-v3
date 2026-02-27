## Reserve changes

### Reserves altered

#### weETH ([0x04C0599Ae5A44757c0af6F9eC3b93da8976c150A](https://basescan.org/address/0x04C0599Ae5A44757c0af6F9eC3b93da8976c150A))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### tBTC ([0x236aa50979D5f3De3Bd1Eeb40E81137F22ab794b](https://basescan.org/address/0x236aa50979D5f3De3Bd1Eeb40E81137F22ab794b))

| description | value before | value after |
| --- | --- | --- |
| ltv | 73 % [7300] | 0 % [0] |
| borrowingEnabled | :white_check_mark: | :x: |


#### ezETH ([0x2416092f143378750bb29b79eD961ab195CcEea5](https://basescan.org/address/0x2416092f143378750bb29b79eD961ab195CcEea5))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### cbETH ([0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22](https://basescan.org/address/0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### EURC ([0x60a3E35Cc302bFA44Cb288Bc5a4F316Fdb1adb42](https://basescan.org/address/0x60a3E35Cc302bFA44Cb288Bc5a4F316Fdb1adb42))

| description | value before | value after |
| --- | --- | --- |
| ltv | 75 % [7500] | 0 % [0] |


#### AAVE ([0x63706e401c06ac8513145b7687A14804d17f814b](https://basescan.org/address/0x63706e401c06ac8513145b7687A14804d17f814b))

| description | value before | value after |
| --- | --- | --- |
| ltv | 60 % [6000] | 0 % [0] |


#### wrsETH ([0xEDfa23602D0EC14714057867A78d01e94176BEA0](https://basescan.org/address/0xEDfa23602D0EC14714057867A78d01e94176BEA0))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### wstETH ([0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452](https://basescan.org/address/0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### USDbC ([0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA](https://basescan.org/address/0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA))

| description | value before | value after |
| --- | --- | --- |
| ltv | 75 % [7500] | 0 % [0] |
| borrowingEnabled | :white_check_mark: | :x: |


#### LBTC ([0xecAc9C5F704e954931349Da37F60E39f515c11c1](https://basescan.org/address/0xecAc9C5F704e954931349Da37F60E39f515c11c1))

| description | value before | value after |
| --- | --- | --- |
| ltv | 68 % [6800] | 0 % [0] |


## EMode changes

### EMode: AAVE__USDC_GHO (id: 12)

| description | value before | value after |
| --- | --- | --- |
| label | - | AAVE__USDC_GHO |
| ltv | - | 63 % |
| liquidationThreshold | - | 70 % |
| liquidationBonus | - | 10 % [11000] |
| borrowableBitmap | - | USDC, GHO |
| collateralBitmap | - | AAVE |


### EMode: EURC__USDC_GHO (id: 13)

| description | value before | value after |
| --- | --- | --- |
| label | - | EURC__USDC_GHO |
| ltv | - | 75 % |
| liquidationThreshold | - | 78 % |
| liquidationBonus | - | 5 % [10500] |
| borrowableBitmap | - | USDC, GHO |
| collateralBitmap | - | EURC |


### EMode: LBTC__USDC_GHO (id: 14)

| description | value before | value after |
| --- | --- | --- |
| label | - | LBTC__USDC_GHO |
| ltv | - | 75 % |
| liquidationThreshold | - | 78 % |
| liquidationBonus | - | 5 % [10500] |
| borrowableBitmap | - | USDC, GHO |
| collateralBitmap | - | LBTC |


### EMode: tBTC__USDC_GHO (id: 15)

| description | value before | value after |
| --- | --- | --- |
| label | - | tBTC__USDC_GHO |
| ltv | - | 72 % |
| liquidationThreshold | - | 75 % |
| liquidationBonus | - | 7.5 % [10750] |
| borrowableBitmap | - | USDC, GHO |
| collateralBitmap | - | tBTC |


## Event logs

#### 0x5731a04B1E775f0fdd454Bf70f3335886e9A96be (AaveV3Base.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 12, ltv: 6300, liquidationThreshold: 7000, liquidationBonus: 11000, oracle: 0x0000000000000000000000000000000000000000, label: AAVE__USDC_GHO) |
| 1 | AssetCollateralInEModeChanged(asset: 0x63706e401c06ac8513145b7687A14804d17f814b (symbol: AAVE), categoryId: 12, collateral: true) |
| 2 | AssetBorrowableInEModeChanged(asset: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 (symbol: USDC), categoryId: 12, borrowable: true) |
| 3 | AssetBorrowableInEModeChanged(asset: 0x6Bb7a212910682DCFdbd5BCBb3e28FB4E8da10Ee (symbol: GHO), categoryId: 12, borrowable: true) |
| 4 | EModeCategoryAdded(categoryId: 13, ltv: 7500, liquidationThreshold: 7800, liquidationBonus: 10500, oracle: 0x0000000000000000000000000000000000000000, label: EURC__USDC_GHO) |
| 5 | AssetCollateralInEModeChanged(asset: 0x60a3E35Cc302bFA44Cb288Bc5a4F316Fdb1adb42 (symbol: EURC), categoryId: 13, collateral: true) |
| 6 | AssetBorrowableInEModeChanged(asset: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 (symbol: USDC), categoryId: 13, borrowable: true) |
| 7 | AssetBorrowableInEModeChanged(asset: 0x6Bb7a212910682DCFdbd5BCBb3e28FB4E8da10Ee (symbol: GHO), categoryId: 13, borrowable: true) |
| 8 | EModeCategoryAdded(categoryId: 14, ltv: 7500, liquidationThreshold: 7800, liquidationBonus: 10500, oracle: 0x0000000000000000000000000000000000000000, label: LBTC__USDC_GHO) |
| 9 | AssetCollateralInEModeChanged(asset: 0xecAc9C5F704e954931349Da37F60E39f515c11c1 (symbol: LBTC), categoryId: 14, collateral: true) |
| 10 | AssetBorrowableInEModeChanged(asset: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 (symbol: USDC), categoryId: 14, borrowable: true) |
| 11 | AssetBorrowableInEModeChanged(asset: 0x6Bb7a212910682DCFdbd5BCBb3e28FB4E8da10Ee (symbol: GHO), categoryId: 14, borrowable: true) |
| 12 | EModeCategoryAdded(categoryId: 15, ltv: 7200, liquidationThreshold: 7500, liquidationBonus: 10750, oracle: 0x0000000000000000000000000000000000000000, label: tBTC__USDC_GHO) |
| 13 | AssetCollateralInEModeChanged(asset: 0x236aa50979D5f3De3Bd1Eeb40E81137F22ab794b (symbol: tBTC), categoryId: 15, collateral: true) |
| 14 | AssetBorrowableInEModeChanged(asset: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 (symbol: USDC), categoryId: 15, borrowable: true) |
| 15 | AssetBorrowableInEModeChanged(asset: 0x6Bb7a212910682DCFdbd5BCBb3e28FB4E8da10Ee (symbol: GHO), categoryId: 15, borrowable: true) |
| 16 | ReserveBorrowing(asset: 0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22 (symbol: cbETH), enabled: false) |
| 17 | ReserveBorrowing(asset: 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA (symbol: USDbC), enabled: false) |
| 18 | ReserveBorrowing(asset: 0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452 (symbol: wstETH), enabled: false) |
| 19 | ReserveBorrowing(asset: 0x04C0599Ae5A44757c0af6F9eC3b93da8976c150A (symbol: weETH), enabled: false) |
| 20 | ReserveBorrowing(asset: 0x236aa50979D5f3De3Bd1Eeb40E81137F22ab794b (symbol: tBTC), enabled: false) |
| 21 | CollateralConfigurationChanged(asset: 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA (symbol: USDbC), ltv: 0, liquidationThreshold: 7800, liquidationBonus: 10500) |
| 22 | CollateralConfigurationChanged(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10750) |
| 23 | CollateralConfigurationChanged(asset: 0xEDfa23602D0EC14714057867A78d01e94176BEA0 (symbol: wrsETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10750) |
| 24 | CollateralConfigurationChanged(asset: 0xecAc9C5F704e954931349Da37F60E39f515c11c1 (symbol: LBTC), ltv: 0, liquidationThreshold: 7300, liquidationBonus: 10850) |
| 25 | CollateralConfigurationChanged(asset: 0x60a3E35Cc302bFA44Cb288Bc5a4F316Fdb1adb42 (symbol: EURC), ltv: 0, liquidationThreshold: 7800, liquidationBonus: 10500) |
| 26 | CollateralConfigurationChanged(asset: 0x63706e401c06ac8513145b7687A14804d17f814b (symbol: AAVE), ltv: 0, liquidationThreshold: 6500, liquidationBonus: 11000) |
| 27 | CollateralConfigurationChanged(asset: 0x236aa50979D5f3De3Bd1Eeb40E81137F22ab794b (symbol: tBTC), ltv: 0, liquidationThreshold: 7800, liquidationBonus: 10750) |

#### 0x9390B1735def18560c509E2d0bc090E9d6BA257a (AaveV3Base.ACL_ADMIN, GovernanceV3Base.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 28 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1770805651, withDelegatecall: true, resultData: 0x) |

#### 0x2DC219E716793fb4b21548C0f009Ba3Af753ab01 (GovernanceV3Base.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 29 | PayloadExecuted(payloadId: 97) |

## Raw storage changes

### 0x2dc219e716793fb4b21548c0f009ba3af753ab01 (GovernanceV3Base.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x767e32fd18349f6756b14c9960d71c7fab8d03be981e4c9c8d4aa06a28b66047 | 0x00698c5992000000000002000000000000000000000000000000000000000000 | 0x00698c5992000000000003000000000000000000000000000000000000000000 |
| 0x767e32fd18349f6756b14c9960d71c7fab8d03be981e4c9c8d4aa06a28b66048 | 0x000000000000000000093a8000000000000069ba7e1300000000000000000000 | 0x000000000000000000093a8000000000000069ba7e13000000000000698c5993 |

### 0xa238dd80c259a72e81d7e4664a9801593f98d1c5 (AaveV3Base.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x04e6a57294bb916b654e5f2a9be58b33bb23f83005593c07f959637b56d00d6f | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000080029041e781d4c |
| 0x04e6a57294bb916b654e5f2a9be58b33bb23f83005593c07f959637b56d00d70 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x455552435f5f555344435f47484f00000000000000000000000000000000001c |
| 0x04e6a57294bb916b654e5f2a9be58b33bb23f83005593c07f959637b56d00d71 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000110 |
| 0x06511f122a6ecc4dc280e9f39df5119c2e43c998c438a2cdea36d46bbc885187 | 0x100000000000000000000103e80000249f00000000011194851229fe1e141d4c | 0x100000000000000000000103e80000249f00000000011194811229fe1e141d4c |
| 0x142b8024331e7a0999f0b47d24464879477fb31a681c25e930aab464ba948f9d | 0x100000000000000000000003e800000006e000000001138881082a621c841a90 | 0x100000000000000000000003e800000006e000000001138881082a621c840000 |
| 0x1aec1d7d90e7fdc8d0cb5cae39901fd57c1eb538af488d7215b10b8d307d84b7 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x00000000000000000000000000000000000000000000000010002af81b58189c |
| 0x1aec1d7d90e7fdc8d0cb5cae39901fd57c1eb538af488d7215b10b8d307d84b8 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x414156455f5f555344435f47484f00000000000000000000000000000000001c |
| 0x1aec1d7d90e7fdc8d0cb5cae39901fd57c1eb538af488d7215b10b8d307d84b9 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000110 |
| 0x2ab8cd8eab3e8c901115e793997bc427e1596b98dcca832d2eb3bc8b02d226a1 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000040029041e781d4c |
| 0x2ab8cd8eab3e8c901115e793997bc427e1596b98dcca832d2eb3bc8b02d226a2 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x4c4254435f5f555344435f47484f00000000000000000000000000000000001c |
| 0x2ab8cd8eab3e8c901115e793997bc427e1596b98dcca832d2eb3bc8b02d226a3 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000110 |
| 0x576d2086a3d5f0898768a114197adc4053263301f03ff1504528cd2771084b42 | 0x100000000000000000000003e800017c9d8000108e481388a50629041e781d4c | 0x100000000000000000000003e800017c9d8000108e481388a10629041e780000 |
| 0x5f6aa73d31c2f4ef6adff1bc9136292ba6ec4a935a3394501b252da30ee66ef5 | 0x100000000000000000000003e800222b8f00015fb71003e8850629041e781d4c | 0x100000000000000000000003e800222b8f00015fb71003e8850629041e780000 |
| 0x70f3bb6a392ddd8da0d065901d06be3531eaee419994175e61f7027f7f10e693 | 0x100000000000000000000003e800000753000000000107d0811229fe000a0005 | 0x100000000000000000000003e800000753000000000107d0811229fe000a0000 |
| 0x769cad6e4f69fb39d4bdc2ee07759d8d4955411817e0dd7fe8899ea55308f3d7 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000200029fe1d4c1c20 |
| 0x769cad6e4f69fb39d4bdc2ee07759d8d4955411817e0dd7fe8899ea55308f3d8 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x744254435f5f555344435f47484f00000000000000000000000000000000001c |
| 0x769cad6e4f69fb39d4bdc2ee07759d8d4955411817e0dd7fe8899ea55308f3d9 | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000110 |
| 0x80d3b16018b60b749d2bc1c0b179418bf0067c8de4f67a7e0e09c0f02bf661b2 | 0x100000000000000000000003e8000001c2000000000105dc811229fe000a0005 | 0x100000000000000000000003e8000001c2000000000105dc811229fe000a0000 |
| 0x96beb4f9742350119893c92f4298c1cc379c4d82d0886b6326a3a5b4c22e68a7 | 0x100000000000000000000003e800000008200000000d07d0851229fe1e781c84 | 0x100000000000000000000003e800000008200000000d07d0811229fe1e780000 |
| 0xaa500ffa00a5d6e86c03b52ec24b3e4017fc1ff3799a0fec773e15c518a611d7 | 0x100000000000000000000103e800000271000000030905dc851229fe1edc1d4c | 0x100000000000000000000103e800000271000000030905dc811229fe1edc1d4c |
| 0xb2fb8b7096735d73c6c4d5b1a418a8cdf1a6f7c6702f0c322b17a7e19c120ebe | 0x100000000000000000000103e800000a02800000076c01f4851229681edc1d4c | 0x100000000000000000000103e800000a02800000076c01f4811229681edc1d4c |
| 0xd70f257193c79f7683dc422d26d444f336579483b3e679e2693fd67db2791a97 | 0x100000000000000000000003e800000753000000000107d081122af819641770 | 0x100000000000000000000003e800000753000000000107d081122af819640000 |


## Raw diff

```json
{
  "eModes": {
    "12": {
      "from": null,
      "to": {
        "borrowableBitmap": "272",
        "collateralBitmap": "4096",
        "eModeCategory": 12,
        "label": "AAVE__USDC_GHO",
        "liquidationBonus": 11000,
        "liquidationThreshold": 7000,
        "ltv": 6300
      }
    },
    "13": {
      "from": null,
      "to": {
        "borrowableBitmap": "272",
        "collateralBitmap": "2048",
        "eModeCategory": 13,
        "label": "EURC__USDC_GHO",
        "liquidationBonus": 10500,
        "liquidationThreshold": 7800,
        "ltv": 7500
      }
    },
    "14": {
      "from": null,
      "to": {
        "borrowableBitmap": "272",
        "collateralBitmap": "1024",
        "eModeCategory": 14,
        "label": "LBTC__USDC_GHO",
        "liquidationBonus": 10500,
        "liquidationThreshold": 7800,
        "ltv": 7500
      }
    },
    "15": {
      "from": null,
      "to": {
        "borrowableBitmap": "272",
        "collateralBitmap": "8192",
        "eModeCategory": 15,
        "label": "tBTC__USDC_GHO",
        "liquidationBonus": 10750,
        "liquidationThreshold": 7500,
        "ltv": 7200
      }
    }
  },
  "reserves": {
    "0x04C0599Ae5A44757c0af6F9eC3b93da8976c150A": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x236aa50979D5f3De3Bd1Eeb40E81137F22ab794b": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      },
      "ltv": {
        "from": 7300,
        "to": 0
      }
    },
    "0x2416092f143378750bb29b79eD961ab195CcEea5": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x60a3E35Cc302bFA44Cb288Bc5a4F316Fdb1adb42": {
      "ltv": {
        "from": 7500,
        "to": 0
      }
    },
    "0x63706e401c06ac8513145b7687A14804d17f814b": {
      "ltv": {
        "from": 6000,
        "to": 0
      }
    },
    "0xEDfa23602D0EC14714057867A78d01e94176BEA0": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xc1CBa3fCea344f92D9239c08C0568f6F2F0ee452": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      },
      "ltv": {
        "from": 7500,
        "to": 0
      }
    },
    "0xecAc9C5F704e954931349Da37F60E39f515c11c1": {
      "ltv": {
        "from": 6800,
        "to": 0
      }
    }
  }
}
```
