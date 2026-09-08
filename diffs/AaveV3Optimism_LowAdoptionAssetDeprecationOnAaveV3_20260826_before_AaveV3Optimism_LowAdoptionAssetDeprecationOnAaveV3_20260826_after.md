## Reserve changes

### Reserves altered

#### USDC ([0x7F5c764cBc14f9669B88837ca1490cCa17c31607](https://optimistic.etherscan.io/address/0x7F5c764cBc14f9669B88837ca1490cCa17c31607))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 1,800,000 USDC | 1 USDC |
| reserveFactor | 50 % [5000] | 75 % [7500] |


#### rETH ([0x9Bcef72be871e61ED4fBbc7630889beE758eb81D](https://optimistic.etherscan.io/address/0x9Bcef72be871e61ED4fBbc7630889beE758eb81D))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 450 rETH | 1 rETH |
| reserveFactor | 15 % [1500] | 50 % [5000] |


#### DAI ([0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1](https://optimistic.etherscan.io/address/0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 1,000,000 DAI | 1 DAI |
| borrowCap | 900,000 DAI | 1 DAI |
| reserveFactor | 25 % [2500] | 50 % [5000] |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Optimism.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveFactorChanged(asset: 0x7F5c764cBc14f9669B88837ca1490cCa17c31607 (symbol: USDC), oldReserveFactor: 5000, newReserveFactor: 7500) |
| 2 | ReserveFactorChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), oldReserveFactor: 2500, newReserveFactor: 5000) |
| 4 | ReserveFactorChanged(asset: 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D (symbol: rETH), oldReserveFactor: 1500, newReserveFactor: 5000) |
| 6 | SupplyCapChanged(asset: 0x7F5c764cBc14f9669B88837ca1490cCa17c31607 (symbol: USDC), oldSupplyCap: 1800000, newSupplyCap: 1) |
| 7 | SupplyCapChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), oldSupplyCap: 1000000, newSupplyCap: 1) |
| 8 | BorrowCapChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), oldBorrowCap: 900000, newBorrowCap: 1) |
| 9 | SupplyCapChanged(asset: 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D (symbol: rETH), oldSupplyCap: 450, newSupplyCap: 1) |
| 10 | AssetLtvzeroInEModeChanged(asset: 0x7F5c764cBc14f9669B88837ca1490cCa17c31607 (symbol: USDC), categoryId: 1, ltvzero: true) |
| 11 | ReserveFrozen(asset: 0x7F5c764cBc14f9669B88837ca1490cCa17c31607 (symbol: USDC), frozen: true) |
| 12 | AssetLtvzeroInEModeChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), categoryId: 1, ltvzero: true) |
| 13 | ReserveFrozen(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), frozen: true) |
| 14 | AssetLtvzeroInEModeChanged(asset: 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D (symbol: rETH), categoryId: 2, ltvzero: true) |
| 15 | ReserveFrozen(asset: 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D (symbol: rETH), frozen: true) |

#### 0x794a61358D6845594F94dc1DB02A252b5b4814aD (AaveV3Optimism.POOL)

| index | event |
| --- | --- |
| 1 | ReserveDataUpdated(reserve: 0x7F5c764cBc14f9669B88837ca1490cCa17c31607 (symbol: USDC), liquidityRate: 1724101756989722696296953, stableBorrowRate: 0, variableBorrowRate: 27683402050604374680174036, liquidityIndex: 1.1504 [1150420346165220778994592925, 27 decimals], variableBorrowIndex: 1.3197 [1319724362741671779093506345, 27 decimals]) |
| 3 | ReserveDataUpdated(reserve: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), liquidityRate: 20170578167186279380387689, stableBorrowRate: 0, variableBorrowRate: 47341703919261194392183743, liquidityIndex: 1.1963 [1196323756956033383191494596, 27 decimals], variableBorrowIndex: 1.3098 [1309800563763452882864500009, 27 decimals]) |
| 5 | ReserveDataUpdated(reserve: 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D (symbol: rETH), liquidityRate: 648086869335784058047, stableBorrowRate: 0, variableBorrowRate: 449029649843034262137824, liquidityIndex: 1.0004 [1000490861749886340107289201, 27 decimals], variableBorrowIndex: 1.0080 [1008076450425681831252756720, 27 decimals]) |

#### 0x746c675dAB49Bcd5BB9Dc85161f2d7Eb435009bf (AaveV3Optimism.ACL_ADMIN, GovernanceV3Optimism.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 16 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1787723527, withDelegatecall: true, resultData: 0x) |

#### 0x0E1a3Af1f9cC76A62eD31eDedca291E63632e7c4 (GovernanceV3Optimism.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 17 | PayloadExecuted(payloadId: 98) |

## Raw storage changes

### 0x0e1a3af1f9cc76a62ed31ededca291e63632e7c4 (GovernanceV3Optimism.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x95505a17747b834552dc9f252b9911e949b8ffdf7a51d678a6bd11af986b15de | 0x006a8e7f06000000000002000000000000000000000000000000000000000000 | 0x006a8e7f06000000000003000000000000000000000000000000000000000000 |
| 0x95505a17747b834552dc9f252b9911e949b8ffdf7a51d678a6bd11af986b15df | 0x000000000000000000093a800000000000006abca38700000000000000000000 | 0x000000000000000000093a800000000000006abca3870000000000006a8e7f07 |

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Optimism.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x67dcc86da9aaaf40a183002157e56801115aa6057705e43279b4c1c90942d6b4 | 0x0000000000000000000000000000000000000000000000000000000000000010 | 0x0000000000000000000000000000100000000000000000000000000000000010 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479a | 0x100000000000000000000103e80000f42400000dbba009c4851229041e140000 | 0x100000000000000000000103e80000000010000000011388871229041e140000 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479b | 0x00000000001906ed24d66e4b1db7d81e0000000003dd932c75f67ae1e5cc873b | 0x000000000010af493bc3e09f63d187690000000003dd9368d07bb4aa59bb3fc4 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479c | 0x00000000002728fe5c0157e0a7c30e5c00000000043b70a771ade08c29382906 | 0x00000000002728fee973aeba594823bf00000000043b710ed67706db2fceed29 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479d | 0x0000000000000000000000006a8e7b3d0000000000000000e9ce3d818871ca0b | 0x0000000000000000000000006a8e7f070000000000000000e9ce3d818871ca0b |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a947a2 | 0x00000000000013328dd94687b86530d40000000000000000c22bfe2caad6c4de | 0x00000000000013328dd94687b86530d40000000000000000c460e10ab29e7cc3 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5b | 0x100000000000000000000203e80000001c200000000105dc811229fe1ce80000 | 0x100000000000000000000203e80000000010000000011388831229fe1ce80000 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5c | 0x000000000000003bb9cfe1bcf4a408d800000000033b962e4193f44e3a155e7d | 0x0000000000000023220315f312686cbf00000000033b962e4b05b8da3d974271 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5d | 0x0000000000005f15f07a3598b4db5fd2000000000341dc6ebab45388bd032e00 | 0x0000000000005f15f2332f315de8ebe0000000000341dc7de10ff993087088f0 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5e | 0x000000000000000000000c006a8e32f90000000000000000000278f14524131d | 0x000000000000000000000c006a8e7f070000000000000000000278f14524131d |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc63 | 0x000000000000000ca1daefc528f2e52e00000000000000000000001675782a5e | 0x000000000000000ca1daefc528f2e52e00000000000000000000001cfcb47fae |
| 0x8e0cc0f1f0504b4cb44a23b328568106915b169e79003737a7b094503cdbeeb2 | 0x0000000000000000000000000000008100000000000000000000000000000000 | 0x0000000000000000000000000000008500000000000000000000000000000000 |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325286 | 0x100000000000000000000103e80001b77400000000011388810629041eaa0000 | 0x100000000000000000000103e80000000010000000011d4c830629041eaa0000 |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325287 | 0x000000000002da2f45cd5ad752977e380000000003b79af5ff239d25ae03769b | 0x0000000000016d17be57b38ca7e329f90000000003b79afbeddf96570b246c9d |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325288 | 0x000000000016e62f5f26c6570c55190f000000000443a64a6b97462c6f743be9 | 0x000000000016e6303b74ea7eebcc7dd4000000000443a6810eee9c8a8bb4e929 |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325289 | 0x0000000000000000000002006a8e7ba100000000000000000000000009c92a6d | 0x0000000000000000000002006a8e7f0700000000000000000000000009c92a6d |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c32528e | 0x0000000000000000000000d4e74f97f100000000000000000000000000a7cb75 | 0x0000000000000000000000d4e74f97f100000000000000000000000000a954e0 |


## Raw diff

```json
{
  "reserves": {
    "0x7F5c764cBc14f9669B88837ca1490cCa17c31607": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 5000,
        "to": 7500
      },
      "supplyCap": {
        "from": 1800000,
        "to": 1
      }
    },
    "0x9Bcef72be871e61ED4fBbc7630889beE758eb81D": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 1500,
        "to": 5000
      },
      "supplyCap": {
        "from": 450,
        "to": 1
      }
    },
    "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1": {
      "borrowCap": {
        "from": 900000,
        "to": 1
      },
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 2500,
        "to": 5000
      },
      "supplyCap": {
        "from": 1000000,
        "to": 1
      }
    }
  }
}
```
