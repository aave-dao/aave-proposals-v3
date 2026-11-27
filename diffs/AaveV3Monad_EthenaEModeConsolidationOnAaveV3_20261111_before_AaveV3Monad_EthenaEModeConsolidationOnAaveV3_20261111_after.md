## EMode changes

### EMode: USDe Stablecoins (id: 7)

| description | value before | value after |
| --- | --- | --- |
| label | - | USDe Stablecoins |
| ltv | - | 91 % |
| liquidationThreshold | - | 93 % |
| liquidationBonus | - | 2 % [10200] |
| borrowableBitmap | - | USDT0, USDC, AUSD, GHO |
| collateralBitmap | - | USDe |
| isolated | - | :x: |


## Event logs

#### 0xC7A386Da9cB528aa86feD862a7bf33d10AA8455B (AaveV3Monad.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | AssetLtvzeroInEModeChanged(asset: 0x9FC74f8Ed616B5BaF52a170caa97d6d3898602d1 (symbol: PT-AUSD-8OCT2026), categoryId: 5, ltvzero: true) |
| 1 | EModeCategoryAdded(categoryId: 7, ltv: 9100, liquidationThreshold: 9300, liquidationBonus: 10200, oracle: 0x0000000000000000000000000000000000000000, label: USDe Stablecoins) |
| 2 | EModeCategoryIsolationChanged(categoryId: 7, isolated: false) |
| 3 | AssetCollateralInEModeChanged(asset: 0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34 (symbol: USDe), categoryId: 7, collateral: true) |
| 4 | AssetBorrowableInEModeChanged(asset: 0xe7cd86e13AC4309349F30B3435a9d337750fC82D (symbol: USDT0), categoryId: 7, borrowable: true) |
| 5 | AssetBorrowableInEModeChanged(asset: 0x754704Bc059F8C67012fEd69BC8A327a5aafb603 (symbol: USDC), categoryId: 7, borrowable: true) |
| 6 | AssetBorrowableInEModeChanged(asset: 0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a (symbol: AUSD), categoryId: 7, borrowable: true) |
| 7 | AssetBorrowableInEModeChanged(asset: 0xfc421aD3C883Bf9E7C4f42dE845C4e4405799e73 (symbol: GHO), categoryId: 7, borrowable: true) |

#### 0xa9d0EAFF48cE1DF468f9eAeb7e628c413343F6A2 (AaveV3Monad.ACL_ADMIN, GovernanceV3Monad.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 8 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1794430095, withDelegatecall: true, resultData: 0x) |

#### 0x442CA936e5E6Db875357d0A16481145c96dd9a82 (GovernanceV3Monad.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 9 | PayloadExecuted(payloadId: 12) |

## Raw storage changes

### 0x442ca936e5e6db875357d0a16481145c96dd9a82 (GovernanceV3Monad.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xd56a60595ebefebed7f22dcee6c2acc61b06cf8c68e84c88677840365d1ff92b | 0x006af4d48e000000000002000000000000000000000000000000000000000000 | 0x006af4d48e000000000003000000000000000000000000000000000000000000 |
| 0xd56a60595ebefebed7f22dcee6c2acc61b06cf8c68e84c88677840365d1ff92c | 0x000000000000000000093a800000000000006b22f90f00000000000000000000 | 0x000000000000000000093a800000000000006b22f90f0000000000006af4d48f |

### 0x69a5f9ad4f96ebf0a0c792dd42a01cc5c0102fef (AaveV3Monad.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x1e4061ed12ce1f4439fe6c7922bd1dce45af754358ce2f94214f93749947e40a | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x000000000000000000000000000000000000000000000000000427d82454238c |
| 0x1e4061ed12ce1f4439fe6c7922bd1dce45af754358ce2f94214f93749947e40b | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x5553446520537461626c65636f696e7300000000000000000000000000000020 |
| 0x1e4061ed12ce1f4439fe6c7922bd1dce45af754358ce2f94214f93749947e40c | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000000813 |
| 0x50039cf134a124858bd88bbc9225ec3c537b89a0e9237ce39fe1813e6edf8259 | 0x0000000000000000000000000000000000000000000000000000000000000807 | 0x0000000000000000000000000000100000000000000000000000000000000807 |


## Raw diff

```json
{
  "eModes": {
    "7": {
      "from": null,
      "to": {
        "borrowableBitmap": "2067",
        "collateralBitmap": "4",
        "eModeCategory": 7,
        "isolated": false,
        "label": "USDe Stablecoins",
        "liquidationBonus": 10200,
        "liquidationThreshold": 9300,
        "ltv": 9100
      }
    }
  }
}
```
