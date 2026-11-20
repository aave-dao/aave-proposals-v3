## EMode changes

### EMode: USDe Stablecoins (id: 2)

| description | value before | value after |
| --- | --- | --- |
| ltv | 90 % | 91 % |


## Event logs

#### 0x719755fC1ACf2f9079B0Cbc56e23712c09Ab8626 (AaveV3Mantle.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | EModeCategoryAdded(categoryId: 2, ltv: 9100, liquidationThreshold: 9300, liquidationBonus: 10200, oracle: 0x0000000000000000000000000000000000000000, label: USDe Stablecoins) |
| 1 | EModeCategoryIsolationChanged(categoryId: 2, isolated: false) |

#### 0x70884634D0098782592111A2A6B8d223be31CB7b (AaveV3Mantle.ACL_ADMIN, GovernanceV3Mantle.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 2 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1794430094, withDelegatecall: true, resultData: 0x) |

#### 0xF089f77173A3009A98c45f49D547BF714A7B1e01 (GovernanceV3Mantle.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 3 | PayloadExecuted(payloadId: 15) |

## Raw storage changes

### 0x458f293454fe0d67ec0655f3672301301dd51422 (AaveV3Mantle.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x67dcc86da9aaaf40a183002157e56801115aa6057705e43279b4c1c90942d6b2 | 0x000000000000000000000000000000000000000000000000001027d824542328 | 0x000000000000000000000000000000000000000000000000001027d82454238c |
| 0x67dcc86da9aaaf40a183002157e56801115aa6057705e43279b4c1c90942d6b3 | 0x5553446520537461626c65636f696e7300000000000000000000000000000020 | 0x5553446520537461626c65636f696e7300000000000000000000000000000020 |

### 0xf089f77173a3009a98c45f49d547bf714a7b1e01 (GovernanceV3Mantle.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xf60b7f6a315ec68a6ac240e69dca53652b38627f709a2caa217d9e18af4d7a60 | 0x006af4d48d000000000002000000000000000000000000000000000000000000 | 0x006af4d48d000000000003000000000000000000000000000000000000000000 |
| 0xf60b7f6a315ec68a6ac240e69dca53652b38627f709a2caa217d9e18af4d7a61 | 0x000000000000000000093a800000000000006b22f90e00000000000000000000 | 0x000000000000000000093a800000000000006b22f90e0000000000006af4d48e |


## Raw diff

```json
{
  "eModes": {
    "2": {
      "ltv": {
        "from": 9000,
        "to": 9100
      }
    }
  }
}
```
