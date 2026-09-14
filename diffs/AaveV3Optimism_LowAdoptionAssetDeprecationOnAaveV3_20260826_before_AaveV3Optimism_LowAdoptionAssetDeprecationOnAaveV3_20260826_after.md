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
| 1 | ReserveDataUpdated(reserve: 0x7F5c764cBc14f9669B88837ca1490cCa17c31607 (symbol: USDC), liquidityRate: 1665232946784407423189877, stableBorrowRate: 0, variableBorrowRate: 27206683611907042097059244, liquidityIndex: 1.1506 [1150624049602826989146348159, 27 decimals], variableBorrowIndex: 1.3216 [1321634373394733807857686826, 27 decimals]) |
| 3 | ReserveDataUpdated(reserve: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), liquidityRate: 20750794825185830503032347, stableBorrowRate: 0, variableBorrowRate: 48017785599160013664504721, liquidityIndex: 1.1982 [1198281140821688138431056824, 27 decimals], variableBorrowIndex: 1.3131 [1313127918446542040469962294, 27 decimals]) |
| 5 | ReserveDataUpdated(reserve: 0x9Bcef72be871e61ED4fBbc7630889beE758eb81D (symbol: rETH), liquidityRate: 440158167855503894858, stableBorrowRate: 0, variableBorrowRate: 370052030547353115820389, liquidityIndex: 1.0004 [1000490910079062227476106566, 27 decimals], variableBorrowIndex: 1.0080 [1008098203976405339764047530, 27 decimals]) |

#### 0x746c675dAB49Bcd5BB9Dc85161f2d7Eb435009bf (AaveV3Optimism.ACL_ADMIN, GovernanceV3Optimism.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 16 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1789399803, withDelegatecall: true, resultData: 0x) |

#### 0x0E1a3Af1f9cC76A62eD31eDedca291E63632e7c4 (GovernanceV3Optimism.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 17 | PayloadExecuted(payloadId: 98) |

## Raw storage changes

### 0x0e1a3af1f9cc76a62ed31ededca291e63632e7c4 (GovernanceV3Optimism.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x95505a17747b834552dc9f252b9911e949b8ffdf7a51d678a6bd11af986b15de | 0x006aa812fa000000000002000000000000000000000000000000000000000000 | 0x006aa812fa000000000003000000000000000000000000000000000000000000 |
| 0x95505a17747b834552dc9f252b9911e949b8ffdf7a51d678a6bd11af986b15df | 0x000000000000000000093a800000000000006ad6377b00000000000000000000 | 0x000000000000000000093a800000000000006ad6377b0000000000006aa812fb |

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Optimism.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x67dcc86da9aaaf40a183002157e56801115aa6057705e43279b4c1c90942d6b4 | 0x0000000000000000000000000000000000000000000000000000000000000010 | 0x0000000000000000000000000000100000000000000000000000000000000010 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479a | 0x100000000000000000000103e80000f42400000dbba009c4851229041e140000 | 0x100000000000000000000103e80000000010000000011388871229041e140000 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479b | 0x000000000019bf3986a68f88ef0104430000000003df31a319e9901a6b9e9df7 | 0x0000000000112a26d76d6b9c05b9a61b0000000003df31e6ce6de17a7da5cbb8 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479c | 0x000000000027b828ce2b3122e137882100000000043e3134a375b135f63d54ef | 0x000000000027b8295f8bd871e45b4b9100000000043e31a718b7dbc926757e36 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479d | 0x0000000000000000000000006aa80edb0000000000000000e9ce4dbfdd2205c5 | 0x0000000000000000000000006aa812fb0000000000000000e9ce4dbfdd2205c5 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a947a2 | 0x0000000000001179ac96f0782678b87a000000000000000054227ed8a1cd33e8 | 0x0000000000001179ac96f0782678b87a00000000000000005695073e1138ee7d |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5b | 0x100000000000000000000203e80000001c200000000105dc811229fe1ce80000 | 0x100000000000000000000203e80000000010000000011388831229fe1ce80000 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5c | 0x00000000000000289050cb829f8134c800000000033b9630e8161de3aa229cac | 0x0000000000000017dc6bf19b4e11e94a00000000033b9630e9b972435b954d46 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5d | 0x0000000000004e5c8f4245f8358d352b000000000341e115f3ff5f58eb7d00ee | 0x0000000000004e5c8f8ecb21a6dc0165000000000341e1192439315a9efa3eaa |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc5e | 0x000000000000000000000c006aa7ff8f000000000000000000027a289bb18ac9 | 0x000000000000000000000c006aa812fb000000000000000000027a289bb18ac9 |
| 0x8cee8bbd821b6580e77e2af658f032b95735f4513ee645cc11dcce6d3c18cc63 | 0x000000000000000ca2e5d6b09f4e991d000000000000000000000008425c3efe | 0x000000000000000ca2e5d6b09f4e991d0000000000000000000000096428e2f3 |
| 0x8e0cc0f1f0504b4cb44a23b328568106915b169e79003737a7b094503cdbeeb2 | 0x0000000000000000000000000000008100000000000000000000000000000000 | 0x0000000000000000000000000000008500000000000000000000000000000000 |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325286 | 0x100000000000000000000103e80001b77400000000011388810629041eaa0000 | 0x100000000000000000000103e80000000010000000011d4c830629041eaa0000 |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325287 | 0x000000000002c140e3dda23a5b71af1b0000000003b7c61deff706b4356cdaaf | 0x00000000000160a0757c6e239c9683750000000003b7c61eb6f4ca1ed33a1a7f |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325288 | 0x000000000016813d2918523253dc69570000000004453aefa6525b34cd5a5b83 | 0x000000000016813d461ed1cf2f4d55ac0000000004453af6f17c664e9425d92a |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c325289 | 0x0000000000000000000002006aa8128500000000000000000000000009c93cb1 | 0x0000000000000000000002006aa812fb00000000000000000000000009c93cb1 |
| 0x999a28994fd329fbb33c1de5f7d344e757804721b9631af4101beaae2c32528e | 0x0000000000000000000000d56d4c2ec5000000000000000000000000003f5037 | 0x0000000000000000000000d56d4c2ec5000000000000000000000000003f8393 |


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
