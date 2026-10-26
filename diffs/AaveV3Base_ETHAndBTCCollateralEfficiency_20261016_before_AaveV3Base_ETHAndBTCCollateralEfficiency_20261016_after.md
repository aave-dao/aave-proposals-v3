## Reserve changes

### Reserves altered

#### WETH ([0x4200000000000000000000000000000000000006](https://basescan.org/address/0x4200000000000000000000000000000000000006))

| description | value before | value after |
| --- | --- | --- |
| ltv | 80 % [8000] | 81 % [8100] |
| liquidationThreshold | 83 % [8300] | 84 % [8400] |


#### cbBTC ([0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf](https://basescan.org/address/0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf))

| description | value before | value after |
| --- | --- | --- |
| ltv | 73 % [7300] | 81 % [8100] |
| liquidationThreshold | 78 % [7800] | 84 % [8400] |
| liquidationBonus | 7.5 % [10750] | 6 % [10600] |


## EMode changes

### EMode: cbBTC Stablecoins (id: 10)

| description | value before | value after |
| --- | --- | --- |
| ltv | 80 % | 82 % |
| liquidationThreshold | 83 % | 85 % |


## Event logs

#### 0x5731a04B1E775f0fdd454Bf70f3335886e9A96be (AaveV3Base.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 10, ltv: 8200, liquidationThreshold: 8500, liquidationBonus: 10400, oracle: 0x0000000000000000000000000000000000000000, label: cbBTC Stablecoins) |
| 1 | EModeCategoryIsolationChanged(categoryId: 10, isolated: false) |
| 2 | CollateralConfigurationChanged(asset: 0x4200000000000000000000000000000000000006 (symbol: WETH), ltv: 8100, liquidationThreshold: 8400, liquidationBonus: 10500) |
| 3 | CollateralConfigurationChanged(asset: 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf (symbol: cbBTC), ltv: 8100, liquidationThreshold: 8400, liquidationBonus: 10600) |

#### 0x9390B1735def18560c509E2d0bc090E9d6BA257a (AaveV3Base.ACL_ADMIN, GovernanceV3Base.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 4 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1792149363, withDelegatecall: true, resultData: 0x) |

#### 0x2DC219E716793fb4b21548C0f009Ba3Af753ab01 (GovernanceV3Base.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 5 | PayloadExecuted(payloadId: 120) |

## Raw storage changes

### 0x2dc219e716793fb4b21548c0f009ba3af753ab01 (GovernanceV3Base.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xe372c44748f4c2908ae7c0a1dc553464478b0394f70953faecd55173b039317c | 0x006ad20772000000000002000000000000000000000000000000000000000000 | 0x006ad20772000000000003000000000000000000000000000000000000000000 |
| 0xe372c44748f4c2908ae7c0a1dc553464478b0394f70953faecd55173b039317d | 0x000000000000000000093a800000000000006b002bf300000000000000000000 | 0x000000000000000000093a800000000000006b002bf30000000000006ad20773 |

### 0xa238dd80c259a72e81d7e4664a9801593f98d1c5 (AaveV3Base.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x89c297050f05308a1ebd800db358705332b6d10d9be0598b08aa6c1829173df7 | 0x100000000000000000000003e8000000fa000000017c1388850829fe1e781c84 | 0x100000000000000000000003e8000000fa000000017c13888508296820d01fa4 |
| 0x9f34118313d08abcbe5d630066a42015e9c14ddd958820a505759421525c3ade | 0x100000000000000000000103e800001e8480000186a005dc85122904206c1f40 | 0x100000000000000000000103e800001e8480000186a005dc8512290420d01fa4 |
| 0xb6395f9c432dd8cece69c29d0bafa901e98160153dacb5e1d5fb45e8d47ba1d6 | 0x000000000000000000000000000000000000000000000000004028a0206c1f40 | 0x000000000000000000000000000000000000000000000000004028a021342008 |
| 0xb6395f9c432dd8cece69c29d0bafa901e98160153dacb5e1d5fb45e8d47ba1d7 | 0x636242544320537461626c65636f696e73000000000000000000000000000022 | 0x636242544320537461626c65636f696e73000000000000000000000000000022 |


## Raw diff

```json
{
  "reserves": {
    "0x4200000000000000000000000000000000000006": {
      "liquidationThreshold": {
        "from": 8300,
        "to": 8400
      },
      "ltv": {
        "from": 8000,
        "to": 8100
      }
    },
    "0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf": {
      "liquidationBonus": {
        "from": 10750,
        "to": 10600
      },
      "liquidationThreshold": {
        "from": 7800,
        "to": 8400
      },
      "ltv": {
        "from": 7300,
        "to": 8100
      }
    }
  },
  "eModes": {
    "10": {
      "liquidationThreshold": {
        "from": 8300,
        "to": 8500
      },
      "ltv": {
        "from": 8000,
        "to": 8200
      }
    }
  }
}
```
