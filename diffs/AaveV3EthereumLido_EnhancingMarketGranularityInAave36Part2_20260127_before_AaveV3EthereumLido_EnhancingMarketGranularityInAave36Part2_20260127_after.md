## Reserve changes

### Reserves altered

#### wstETH ([0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0](https://etherscan.io/address/0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0))

| description | value before | value after |
| --- | --- | --- |
| borrowingEnabled | :white_check_mark: | :x: |


#### sUSDe ([0x9D39A5DE30e57443BfF2A8307A4256c8797A3497](https://etherscan.io/address/0x9D39A5DE30e57443BfF2A8307A4256c8797A3497))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### rsETH ([0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7](https://etherscan.io/address/0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### tETH ([0xD11c452fc99cF405034ee446803b6F6c1F6d5ED8](https://etherscan.io/address/0xD11c452fc99cF405034ee446803b6F6c1F6d5ED8))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


#### ezETH ([0xbf5495Efe5DB9ce00f80364C8B423567e58d2110](https://etherscan.io/address/0xbf5495Efe5DB9ce00f80364C8B423567e58d2110))

| description | value before | value after |
| --- | --- | --- |
| ltv | 0.05 % [5] | 0 % [0] |


## Event logs

#### 0x342631c6CeFC9cfbf97b2fe4aa242a236e1fd517 (AaveV3EthereumLido.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveBorrowing(asset: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0 (symbol: wstETH), enabled: false) |
| 1 | CollateralConfigurationChanged(asset: 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110 (symbol: ezETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10750) |
| 2 | CollateralConfigurationChanged(asset: 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497 (symbol: sUSDe), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10750) |
| 3 | CollateralConfigurationChanged(asset: 0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7 (symbol: rsETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10750) |
| 4 | CollateralConfigurationChanged(asset: 0xD11c452fc99cF405034ee446803b6F6c1F6d5ED8 (symbol: tETH), ltv: 0, liquidationThreshold: 10, liquidationBonus: 10750) |

#### 0x5300A1a15135EA4dc7aD5a167152C01EFc9b192A (AaveV2Ethereum.POOL_ADMIN, AaveV2EthereumAMM.POOL_ADMIN, AaveV3Ethereum.ACL_ADMIN, AaveV3EthereumEtherFi.ACL_ADMIN, AaveV3EthereumHorizon.ACL_ADMIN, AaveV3EthereumLido.ACL_ADMIN, GovernanceV3Ethereum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 5 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1771935263, withDelegatecall: true, resultData: 0x) |

#### 0xdAbad81aF85554E9ae636395611C58F7eC1aAEc5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 6 | PayloadExecuted(payloadId: 406) |

## Raw storage changes

### 0x4e033931ad43597d96d6bcc25c280717730b58b1 (AaveV3EthereumLido.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x6c3847a02c991876166c8be676e3ca84a3c105eb60433934c4091c1a7cd316ee | 0x100000000000000000000003e8000004e2000000006405dc011229fe000a0005 | 0x100000000000000000000003e8000004e2000000006405dc011229fe000a0000 |
| 0xb175b141cba0cc992ab972ad55e21f463dc10a5251e5513e6498931ace66c014 | 0x100000000000000000000003e800000ea600000000011388811229fe000a0005 | 0x100000000000000000000003e800000ea600000000011388811229fe000a0000 |
| 0xb587e101db980eb9a3d4491a64340bd6e10aa0a7bfd3cc48f4b5cadccf068ded | 0x100000000000000000000003e80004c4b400000003e803e8811229fe000a0005 | 0x100000000000000000000003e80004c4b400000003e803e8811229fe000a0000 |
| 0xc9d7ec48cd0d839522455f78914adfeda8686316bb6819e0888e4bcd349e01b2 | 0x100000000000000000000103e8000030d4000001117001f485122968206c2008 | 0x100000000000000000000103e8000030d4000001117001f481122968206c2008 |
| 0xed45a05ce0954e645f11725167843283bb37c29952c0335b670d63d10fcad8ef | 0x100000000000000000000003e8000001388000000001000f811229fe000a0005 | 0x100000000000000000000003e8000001388000000001000f811229fe000a0000 |

### 0xdabad81af85554e9ae636395611c58f7ec1aaec5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x79fda4321a66d0103c3efc31f3a3604a86e56a20810d896d2458a6b5e769054d | 0x00699d961e000000000002000000000000000000000000000000000000000000 | 0x00699d961e000000000003000000000000000000000000000000000000000000 |
| 0x79fda4321a66d0103c3efc31f3a3604a86e56a20810d896d2458a6b5e769054e | 0x000000000000000000093a8000000000000069cbba9f00000000000000000000 | 0x000000000000000000093a8000000000000069cbba9f000000000000699d961f |


## Raw diff

```json
{
  "reserves": {
    "0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0": {
      "borrowingEnabled": {
        "from": true,
        "to": false
      }
    },
    "0x9D39A5DE30e57443BfF2A8307A4256c8797A3497": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xD11c452fc99cF405034ee446803b6F6c1F6d5ED8": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    },
    "0xbf5495Efe5DB9ce00f80364C8B423567e58d2110": {
      "ltv": {
        "from": 5,
        "to": 0
      }
    }
  }
}
```
