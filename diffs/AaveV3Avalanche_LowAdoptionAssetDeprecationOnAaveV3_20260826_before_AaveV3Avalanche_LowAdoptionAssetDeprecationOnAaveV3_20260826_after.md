## Reserve changes

### Reserves altered

#### WBTC.e ([0x50b7545627a5162F82A992c33b87aDc75187B218](https://snowscan.xyz/address/0x50b7545627a5162F82A992c33b87aDc75187B218))

| description | value before | value after |
| --- | --- | --- |
| supplyCap | 2,000 WBTC.e | 1 WBTC.e |
| borrowCap | 1,100 WBTC.e | 1 WBTC.e |
| reserveFactor | 20 % [2000] | 50 % [5000] |


#### LINK.e ([0x5947BB275c521040051D82396192181b413227A3](https://snowscan.xyz/address/0x5947BB275c521040051D82396192181b413227A3))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 155,000 LINK.e | 1 LINK.e |
| reserveFactor | 20 % [2000] | 50 % [5000] |


#### AAVE.e ([0x63a72806098Bd3D9520cC43356dD78afe5D386D9](https://snowscan.xyz/address/0x63a72806098Bd3D9520cC43356dD78afe5D386D9))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 7,200 AAVE.e | 1 AAVE.e |
| borrowCap | 0 AAVE.e | 1 AAVE.e |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Avalanche.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveFactorChanged(asset: 0x50b7545627a5162F82A992c33b87aDc75187B218 (symbol: WBTC.e), oldReserveFactor: 2000, newReserveFactor: 5000) |
| 2 | ReserveFactorChanged(asset: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), oldReserveFactor: 2000, newReserveFactor: 5000) |
| 4 | SupplyCapChanged(asset: 0x50b7545627a5162F82A992c33b87aDc75187B218 (symbol: WBTC.e), oldSupplyCap: 2000, newSupplyCap: 1) |
| 5 | BorrowCapChanged(asset: 0x50b7545627a5162F82A992c33b87aDc75187B218 (symbol: WBTC.e), oldBorrowCap: 1100, newBorrowCap: 1) |
| 6 | SupplyCapChanged(asset: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), oldSupplyCap: 155000, newSupplyCap: 1) |
| 7 | SupplyCapChanged(asset: 0x63a72806098Bd3D9520cC43356dD78afe5D386D9 (symbol: AAVE.e), oldSupplyCap: 7200, newSupplyCap: 1) |
| 8 | BorrowCapChanged(asset: 0x63a72806098Bd3D9520cC43356dD78afe5D386D9 (symbol: AAVE.e), oldBorrowCap: 0, newBorrowCap: 1) |
| 9 | ReserveFrozen(asset: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), frozen: true) |
| 10 | ReserveFrozen(asset: 0x63a72806098Bd3D9520cC43356dD78afe5D386D9 (symbol: AAVE.e), frozen: true) |

#### 0x794a61358D6845594F94dc1DB02A252b5b4814aD (AaveV3Avalanche.POOL)

| index | event |
| --- | --- |
| 1 | ReserveDataUpdated(reserve: 0x50b7545627a5162F82A992c33b87aDc75187B218 (symbol: WBTC.e), liquidityRate: 201427512536895599012532, stableBorrowRate: 0, variableBorrowRate: 8985326450132898265641071, liquidityIndex: 1.0037 [1003786376200077529964235440, 27 decimals], variableBorrowIndex: 1.0407 [1040747907313511575326352578, 27 decimals]) |
| 3 | ReserveDataUpdated(reserve: 0x5947BB275c521040051D82396192181b413227A3 (symbol: LINK.e), liquidityRate: 31000729573953399854693, stableBorrowRate: 0, variableBorrowRate: 3105616412914770584378171, liquidityIndex: 1.0030 [1003071381099912042826902160, 27 decimals], variableBorrowIndex: 1.0354 [1035461685023463822285356942, 27 decimals]) |

#### 0x3C06dce358add17aAf230f2234bCCC4afd50d090 (AaveV2Avalanche.POOL_ADMIN, AaveV3Avalanche.ACL_ADMIN, GovernanceV3Avalanche.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 11 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1787723525, withDelegatecall: true, resultData: 0x) |

#### 0x1140CB7CAfAcC745771C2Ea31e7B5C653c5d0B80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 12 | PayloadExecuted(payloadId: 124) |

## Raw storage changes

### 0x1140cb7cafacc745771c2ea31e7b5c653c5d0b80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xeed16813d2f65d55dfcd646492ebe0107b86489aa89e1ee58b4c544f69fec4ae | 0x006a8e7f04000000000002000000000000000000000000000000000000000000 | 0x006a8e7f04000000000003000000000000000000000000000000000000000000 |
| 0xeed16813d2f65d55dfcd646492ebe0107b86489aa89e1ee58b4c544f69fec4af | 0x000000000000000000093a800000000000006abca38500000000000000000000 | 0x000000000000000000093a800000000000006abca3850000000000006a8e7f05 |

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Avalanche.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x25a922d75e2aaab8592dc46a8370195c26f61c233dc944290b27aa0dbd9ef70b | 0x100000000000000000000003e8000025d7800000000107d0811229fe1bbc0000 | 0x100000000000000000000003e80000000010000000011388831229fe1bbc0000 |
| 0x25a922d75e2aaab8592dc46a8370195c26f61c233dc944290b27aa0dbd9ef70c | 0x0000000000000a80e189566e0118027f00000000033db89fec55253106679256 | 0x00000000000006908d8c029b1f26966500000000033db8a086fef7bfe6af2a90 |
| 0x25a922d75e2aaab8592dc46a8370195c26f61c233dc944290b27aa0dbd9ef70d | 0x00000000000291a3b035221a6efc4fb400000000035883635f6de68cc84aba2f | 0x00000000000291a3cd974507ca719b3b000000000358838a6be0acfb90183f8e |
| 0x25a922d75e2aaab8592dc46a8370195c26f61c233dc944290b27aa0dbd9ef70e | 0x0000000000000000000001006a8e636d000000000000000016a8ab826c2aebbe | 0x0000000000000000000001006a8e7f05000000000000000016a8ab826c2aebbe |
| 0x25a922d75e2aaab8592dc46a8370195c26f61c233dc944290b27aa0dbd9ef713 | 0x00000000000011f7cec8d57da0450c650000000000000000000ed0a1e721ab95 | 0x00000000000011f7cec8d57da0450c650000000000000000000faab075104862 |
| 0x2ef0af43460a7d17297e15c9980a774850f93f9db2b1c0c472493f417a9a533a | 0x100000000000000000000003e8000001c200000000000000811229fe1b580000 | 0x100000000000000000000003e80000000010000000010000831229fe1b580000 |
| 0xfd020bc8a9e1e7b4e191e9312848e35e47de67e0d56332848f570b6ebc6ca973 | 0x100000000000000000000003e80000007d000000044c07d0870829811a2c0000 | 0x100000000000000000000003e80000000010000000011388870829811a2c0000 |
| 0xfd020bc8a9e1e7b4e191e9312848e35e47de67e0d56332848f570b6ebc6ca974 | 0x000000000000443e8fe85cc446a845c200000000033e4fe0d47704c0f10b14ec | 0x0000000000002aa76847139b4be1eab400000000033e50087d4799dd422e4ab0 |
| 0xfd020bc8a9e1e7b4e191e9312848e35e47de67e0d56332848f570b6ebc6ca975 | 0x0000000000076eb3542c244f555e9a1a00000000035cde76ab4493586f1fd266 | 0x0000000000076eb785dbe00635cf306f00000000035ce2f11b1fb55e9c78e4c2 |
| 0xfd020bc8a9e1e7b4e191e9312848e35e47de67e0d56332848f570b6ebc6ca976 | 0x0000000000000000000003006a8d686e0000000000000000000000000000379b | 0x0000000000000000000003006a8e7f050000000000000000000000000000379b |
| 0xfd020bc8a9e1e7b4e191e9312848e35e47de67e0d56332848f570b6ebc6ca97b | 0x000000000000000000000000eacae759000000000000000000000000000001b2 | 0x000000000000000000000000eacae7590000000000000000000000000000049e |


## Raw diff

```json
{
  "reserves": {
    "0x50b7545627a5162F82A992c33b87aDc75187B218": {
      "borrowCap": {
        "from": 1100,
        "to": 1
      },
      "reserveFactor": {
        "from": 2000,
        "to": 5000
      },
      "supplyCap": {
        "from": 2000,
        "to": 1
      }
    },
    "0x5947BB275c521040051D82396192181b413227A3": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 2000,
        "to": 5000
      },
      "supplyCap": {
        "from": 155000,
        "to": 1
      }
    },
    "0x63a72806098Bd3D9520cC43356dD78afe5D386D9": {
      "borrowCap": {
        "from": 0,
        "to": 1
      },
      "isFrozen": {
        "from": false,
        "to": true
      },
      "supplyCap": {
        "from": 7200,
        "to": 1
      }
    }
  }
}
```
