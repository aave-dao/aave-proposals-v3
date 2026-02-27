## Reserve changes

### Reserves altered

#### SolvBTC ([0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3](https://explorer.inkonchain.com/address/0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3))

| description | value before | value after |
| --- | --- | --- |
| debtCeiling | 1 $ [100] | 0 $ [0] |


## Event logs

#### 0x2816cf15F6d2A220E789aA011D5EE4eB6c47FEbA (AaveV3InkWhitelabel.POOL)

| index | event |
| --- | --- |
| 0 | topics: `0xaef84d3b40895fd58c561f3998000f0583abb992a52fbdc99ace8e8de4d676a5`, `0x000000000000000000000000ae4efbc7736f963982aacb17efa37fcbab924cb3`, data: `0x0000000000000000000000000000000000000000000000000000000000000000` |

#### 0x4f221e5c0B7103f7e3291E10097de6D9e3BfC02d (AaveV3InkWhitelabel.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 1 | DebtCeilingChanged(asset: 0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3 (symbol: SolvBTC), oldDebtCeiling: 100, newDebtCeiling: 0) |

#### 0x1dF462e2712496373A347f8ad10802a5E95f053D (AaveV3InkWhitelabel.ACL_ADMIN, GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER_EXECUTOR)

| index | event |
| --- | --- |
| 2 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1772236145, withDelegatecall: true, resultData: 0x) |

#### 0x1dE9CB9420Dd1f2cCeFFf9393E126b800D413b7A (GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 3 | PayloadExecuted(payloadId: 17) |

## Raw storage changes

### 0x1de9cb9420dd1f2ccefff9393e126b800d413b7a (GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xfc111d09a6e2f0958402cbe16a5aef32c9d8ddb9a4df7271140de57bfed6525a | 0x0069a22d70000000000002000000000000000000000000000000000000000000 | 0x0069a22d70000000000003000000000000000000000000000000000000000000 |
| 0xfc111d09a6e2f0958402cbe16a5aef32c9d8ddb9a4df7271140de57bfed6525b | 0x000000000000000000093a8000000000000069d051f100000000000000000000 | 0x000000000000000000093a8000000000000069d051f100000000000069a22d71 |

### 0x2816cf15f6d2a220e789aa011d5ee4eb6c47feba (AaveV3InkWhitelabel.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f881 | 0x100000000640000000000003e80000000320000000011388811229fe1d4c1b58 | 0x100000000000000000000003e80000000320000000011388811229fe1d4c1b58 |
| 0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f88a | 0x0000000000000000000000000000000000000000000000000000000000000063 | 0x0000000000000000000000000000000000000000000000000000000000000000 |


## Raw diff

```json
{
  "reserves": {
    "0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3": {
      "debtCeiling": {
        "from": 100,
        "to": 0
      }
    }
  }
}
```
