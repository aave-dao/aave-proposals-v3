## Reserve changes

### Reserves altered

#### Cake ([0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82](https://bscscan.com/address/0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### wstETH ([0x26c5e01524d2E6280A48F2c50fF6De7e52E9611C](https://bscscan.com/address/0x26c5e01524d2E6280A48F2c50fF6De7e52E9611C))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### FDUSD ([0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409](https://bscscan.com/address/0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409))

| description | value before | value after |
| --- | --- | --- |
| ltv | 70 % [7000] | 0 % [0] |
| borrowingEnabled | :white_check_mark: | :x: |


## Event logs

#### 0x67bdF23C7fCE7C65fF7415Ba3F2520B45D6f9584 (AaveV3BNB.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveBorrowing(asset: 0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409 (symbol: FDUSD), enabled: false) |
| 1 | ReserveBorrowing(asset: 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82 (symbol: Cake), enabled: false) |
| 2 | ReserveBorrowing(asset: 0x26c5e01524d2E6280A48F2c50fF6De7e52E9611C (symbol: wstETH), enabled: false) |
| 3 | CollateralConfigurationChanged(asset: 0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409 (symbol: FDUSD), ltv: 0, liquidationThreshold: 7500, liquidationBonus: 10500) |

#### 0x9390B1735def18560c509E2d0bc090E9d6BA257a (AaveV3BNB.ACL_ADMIN, GovernanceV3BNB.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 4 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1770805702, withDelegatecall: true, resultData: 0x) |

#### 0xE5EF2Dd06755A97e975f7E282f828224F2C3e627 (GovernanceV3BNB.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 5 | PayloadExecuted(payloadId: 55) |

## Raw storage changes

### 0x6807dc923806fe8fd134338eabca509979a7e0cb (AaveV3BNB.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x4f7e401a3bd0628317467a9b48b7a242cbced3635594d81f505845155d278cdc | 0x100000000000000000000003e800000000100000000105dc851229fe1d4c1c20 | 0x100000000000000000000003e800000000100000000105dc811229fe1d4c1c20 |
| 0x5d54c6410275cc5a5b440259b3bdba59addb097a220aaccc7a447ece2a2b45b3 | 0x10014dc93800000000000003e8000124f8000000000107d085122af817d40000 | 0x10014dc93800000000000003e8000124f8000000000107d081122af817d40000 |
| 0x736fd0af6a08a2b2749fa3064a0b73eac95be3d9ec3b096778dfebe1892b0329 | 0x100000000000000000000003e8000b71b00000a4cb8007d0a51229041d4c1b58 | 0x100000000000000000000003e8000b71b00000a4cb8007d0a11229041d4c0000 |

### 0xe5ef2dd06755a97e975f7e282f828224f2c3e627 (GovernanceV3BNB.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x2bb318060b44525c3d947c00393e6d416e9d457a7e83b67b8daab0973739b0fa | 0x00698c59c5000000000002000000000000000000000000000000000000000000 | 0x00698c59c5000000000003000000000000000000000000000000000000000000 |
| 0x2bb318060b44525c3d947c00393e6d416e9d457a7e83b67b8daab0973739b0fb | 0x000000000000000000093a8000000000000069ba7e4600000000000000000000 | 0x000000000000000000093a8000000000000069ba7e46000000000000698c59c6 |


## Raw diff

```json
{
  "reserves": {
    "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x26c5e01524d2E6280A48F2c50fF6De7e52E9611C": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0xc5f0f7b66764F6ec8C8Dff7BA683102295E16409": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      },
      "ltv": {
        "from": 7000,
        "to": 0
      }
    }
  }
}
```
