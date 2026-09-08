## Reserve changes

### Reserves altered

#### sUSDe ([0x9D39A5DE30e57443BfF2A8307A4256c8797A3497](https://etherscan.io/address/0x9D39A5DE30e57443BfF2A8307A4256c8797A3497))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 3,000,000 sUSDe | 1 sUSDe |


#### ezETH ([0xbf5495Efe5DB9ce00f80364C8B423567e58d2110](https://etherscan.io/address/0xbf5495Efe5DB9ce00f80364C8B423567e58d2110))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 150 ezETH | 1 ezETH |


#### USDS ([0xdC035D45d973E3EC169d2276DDab16f1e407384F](https://etherscan.io/address/0xdC035D45d973E3EC169d2276DDab16f1e407384F))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| reserveFactor | 25 % [2500] | 50 % [5000] |


## Event logs

#### 0x342631c6CeFC9cfbf97b2fe4aa242a236e1fd517 (AaveV3EthereumLido.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveFactorChanged(asset: 0xdC035D45d973E3EC169d2276DDab16f1e407384F (symbol: USDS), oldReserveFactor: 2500, newReserveFactor: 5000) |
| 2 | SupplyCapChanged(asset: 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110 (symbol: ezETH), oldSupplyCap: 150, newSupplyCap: 1) |
| 3 | SupplyCapChanged(asset: 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497 (symbol: sUSDe), oldSupplyCap: 3000000, newSupplyCap: 1) |
| 4 | AssetLtvzeroInEModeChanged(asset: 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110 (symbol: ezETH), categoryId: 2, ltvzero: true) |
| 5 | AssetLtvzeroInEModeChanged(asset: 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110 (symbol: ezETH), categoryId: 3, ltvzero: true) |
| 6 | ReserveFrozen(asset: 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110 (symbol: ezETH), frozen: true) |
| 7 | ReserveFrozen(asset: 0xdC035D45d973E3EC169d2276DDab16f1e407384F (symbol: USDS), frozen: true) |
| 8 | AssetLtvzeroInEModeChanged(asset: 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497 (symbol: sUSDe), categoryId: 4, ltvzero: true) |
| 9 | ReserveFrozen(asset: 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497 (symbol: sUSDe), frozen: true) |

#### 0x4e033931ad43597d96D6bcc25c280717730B58B1 (AaveV3EthereumLido.POOL)

| index | event |
| --- | --- |
| 1 | ReserveDataUpdated(reserve: 0xdC035D45d973E3EC169d2276DDab16f1e407384F (symbol: USDS), liquidityRate: 5446005126729551835804594, stableBorrowRate: 0, variableBorrowRate: 47492827287013138525568224, liquidityIndex: 1.0633 [1063320484558753465541282386, 27 decimals], variableBorrowIndex: 1.1137 [1113719881374872437427214607, 27 decimals]) |

#### 0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A (AaveV2Ethereum.POOL_ADMIN, AaveV2EthereumAMM.POOL_ADMIN, AaveV3Ethereum.ACL_ADMIN, AaveV3EthereumEtherFi.ACL_ADMIN, AaveV3EthereumHorizon.ACL_ADMIN, AaveV3EthereumLido.ACL_ADMIN, GovernanceV3Ethereum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 10 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1787723519, withDelegatecall: true, resultData: 0x) |

#### 0xdAbad81aF85554E9ae636395611C58F7eC1aAEc5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 11 | PayloadExecuted(payloadId: 465) |

## Raw storage changes

### 0x4e033931ad43597d96d6bcc25c280717730b58b1 (AaveV3EthereumLido.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c3 | 0x1000000000000000000000000000000000100000000109c48512000000000000 | 0x1000000000000000000000000000000000100000000113888712000000000000 |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c4 | 0x000000000006bdbd9bd6a3d4d6a34b0c00000000036f1d85e320ff8d482db556 | 0x000000000004813c878c8cbb646bb3b200000000036f8edef868a9074eab4a52 |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c5 | 0x00000000002747cdeed3b9ba98e707930000000003968c3f137cd3c595e14055 | 0x00000000002748ff537b7b33f23bbce00000000003993f5bbf10949f3073190f |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c6 | 0x0000000000000000000002006a70c1ef00000000000000000000000000000000 | 0x0000000000000000000002006a8e7eff00000000000000000000000000000000 |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550cb | 0x0000000000001e7ba58665a0bbd936b500000000000000000000000000000000 | 0x0000000000001e7ba58665a0bbd936b50000000000000001999a4964deaaab67 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354e | 0x0000000000000000000000000000000000000000000000000000000000000048 | 0x0000000000000000000000000000002000000000000000000000000000000048 |
| 0x67dcc86da9aaaf40a183002157e56801115aa6057705e43279b4c1c90942d6b4 | 0x0000000000000000000000000000000000000000000000000000000000000048 | 0x0000000000000000000000000000001000000000000000000000000000000048 |
| 0x6c3847a02c991876166c8be676e3ca84a3c105eb60433934c4091c1a7cd316ee | 0x100000000000000000000003e800000009600000000105dc011229fe000a0000 | 0x100000000000000000000003e800000000100000000105dc031229fe000a0000 |
| 0x81d0999fde243adcc41b7fa1be5cea14f789e3a6065b815ac58f4bc0838c3157 | 0x0000000000000000000000000000000000000000000000000000000000000001 | 0x0000000000000000000000000000001000000000000000000000000000000001 |
| 0xb587e101db980eb9a3d4491a64340bd6e10aa0a7bfd3cc48f4b5cadccf068ded | 0x100000000000000000000003e80002dc6c000000000103e8811229fe000a0000 | 0x100000000000000000000003e800000000100000000103e8831229fe000a0000 |

### 0xdabad81af85554e9ae636395611c58f7ec1aaec5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xc1355f755e4ac59f1f7a39229a099c027b263370068e3e3edb3865c0c33160ee | 0x006a8e7efe000000000002000000000000000000000000000000000000000000 | 0x006a8e7efe000000000003000000000000000000000000000000000000000000 |
| 0xc1355f755e4ac59f1f7a39229a099c027b263370068e3e3edb3865c0c33160ef | 0x000000000000000000093a800000000000006abca37f00000000000000000000 | 0x000000000000000000093a800000000000006abca37f0000000000006a8e7eff |


## Raw diff

```json
{
  "reserves": {
    "0x9D39A5DE30e57443BfF2A8307A4256c8797A3497": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "supplyCap": {
        "from": 3000000,
        "to": 1
      }
    },
    "0xbf5495Efe5DB9ce00f80364C8B423567e58d2110": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "supplyCap": {
        "from": 150,
        "to": 1
      }
    },
    "0xdC035D45d973E3EC169d2276DDab16f1e407384F": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 2500,
        "to": 5000
      }
    }
  }
}
```
