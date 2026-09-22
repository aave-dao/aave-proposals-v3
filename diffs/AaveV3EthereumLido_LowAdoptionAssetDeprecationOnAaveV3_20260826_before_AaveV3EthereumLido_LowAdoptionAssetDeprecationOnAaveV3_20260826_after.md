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
| 1 | ReserveDataUpdated(reserve: 0xdC035D45d973E3EC169d2276DDab16f1e407384F (symbol: USDS), liquidityRate: 5354572117648275140537350, stableBorrowRate: 0, variableBorrowRate: 47453030711478835939240552, liquidityIndex: 1.0637 [1063774347667990997094927744, 27 decimals], variableBorrowIndex: 1.1165 [1116532580403787508567547930, 27 decimals]) |

#### 0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A (AaveV2Ethereum.POOL_ADMIN, AaveV2EthereumAMM.POOL_ADMIN, AaveV3Ethereum.ACL_ADMIN, AaveV3EthereumEtherFi.ACL_ADMIN, AaveV3EthereumHorizon.ACL_ADMIN, AaveV3EthereumLido.ACL_ADMIN, GovernanceV3Ethereum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 10 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1789399799, withDelegatecall: true, resultData: 0x) |

#### 0xdAbad81aF85554E9ae636395611C58F7eC1aAEc5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 11 | PayloadExecuted(payloadId: 467) |

## Raw storage changes

### 0x4e033931ad43597d96d6bcc25c280717730b58b1 (AaveV3EthereumLido.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c3 | 0x1000000000000000000000000000000000100000000109c48512000000000000 | 0x1000000000000000000000000000000000100000000113888712000000000000 |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c4 | 0x000000000006a1ab1d9b745badab4d5b00000000036f98906d3375e78b8a5d62 | 0x0000000000046ddfefa67e27a1e06c0600000000036feefaf05526c0524c8d80 |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c5 | 0x0000000000273fa837d50ca6399b7fa30000000003997a8df0f8060039af4cab | 0x0000000000274091f30d360c6f35ea6800000000039b92f8775af4bd43f8a01a |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550c6 | 0x0000000000000000000002006a910a0b00000000000000000000000000000000 | 0x0000000000000000000002006aa812f700000000000000000000000000000000 |
| 0x4ef18721e98712b47bd659171158f093c47a5bb2c0ced3ed1c21e431251550cb | 0x0000000000001ea5304d21e1ffa4ebb400000000000000000000000000000000 | 0x0000000000001ea5304d21e1ffa4ebb40000000000000001381993376e82d737 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354e | 0x0000000000000000000000000000000000000000000000000000000000000048 | 0x0000000000000000000000000000002000000000000000000000000000000048 |
| 0x67dcc86da9aaaf40a183002157e56801115aa6057705e43279b4c1c90942d6b4 | 0x0000000000000000000000000000000000000000000000000000000000000048 | 0x0000000000000000000000000000001000000000000000000000000000000048 |
| 0x6c3847a02c991876166c8be676e3ca84a3c105eb60433934c4091c1a7cd316ee | 0x100000000000000000000003e800000009600000000105dc011229fe000a0000 | 0x100000000000000000000003e800000000100000000105dc031229fe000a0000 |
| 0x81d0999fde243adcc41b7fa1be5cea14f789e3a6065b815ac58f4bc0838c3157 | 0x0000000000000000000000000000000000000000000000000000000000000001 | 0x0000000000000000000000000000001000000000000000000000000000000001 |
| 0xb587e101db980eb9a3d4491a64340bd6e10aa0a7bfd3cc48f4b5cadccf068ded | 0x100000000000000000000003e80002dc6c000000000103e8811229fe000a0000 | 0x100000000000000000000003e800000000100000000103e8831229fe000a0000 |

### 0xdabad81af85554e9ae636395611c58f7ec1aaec5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x05b8746a28a97ce489285bc33ceea5e2d46b5eb4ad18f6b87b844abfcb9e19fe | 0x006aa812f6000000000002000000000000000000000000000000000000000000 | 0x006aa812f6000000000003000000000000000000000000000000000000000000 |
| 0x05b8746a28a97ce489285bc33ceea5e2d46b5eb4ad18f6b87b844abfcb9e19ff | 0x000000000000000000093a800000000000006ad6377700000000000000000000 | 0x000000000000000000093a800000000000006ad637770000000000006aa812f7 |


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
