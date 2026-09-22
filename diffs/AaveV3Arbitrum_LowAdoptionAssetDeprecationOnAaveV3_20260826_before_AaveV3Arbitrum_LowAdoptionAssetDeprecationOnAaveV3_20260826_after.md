## Reserve changes

### Reserves altered

#### ezETH ([0x2416092f143378750bb29b79eD961ab195CcEea5](https://arbiscan.io/address/0x2416092f143378750bb29b79eD961ab195CcEea5))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 66 ezETH | 1 ezETH |


#### tBTC ([0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40](https://arbiscan.io/address/0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 35 tBTC | 1 tBTC |


#### EURS ([0xD22a58f79e9481D1a88e00c343885A588b34b68B](https://arbiscan.io/address/0xD22a58f79e9481D1a88e00c343885A588b34b68B))

| description | value before | value after |
| --- | --- | --- |
| supplyCap | 80,000 EURS | 1 EURS |
| borrowCap | 65,000 EURS | 1 EURS |
| reserveFactor | 20 % [2000] | 50 % [5000] |


#### DAI ([0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1](https://arbiscan.io/address/0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 4,900,000 DAI | 1 DAI |
| borrowCap | 4,410,000 DAI | 1 DAI |
| reserveFactor | 25 % [2500] | 50 % [5000] |


#### rETH ([0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8](https://arbiscan.io/address/0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 1,300 rETH | 1 rETH |
| ltv | 69 % [6900] | 0 % [0] |
| reserveFactor | 15 % [1500] | 50 % [5000] |


#### USDC ([0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8](https://arbiscan.io/address/0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 1,700,000 USDC | 1 USDC |
| borrowCap | 1,530,000 USDC | 1 USDC |
| reserveFactor | 50 % [5000] | 75 % [7500] |


## Event logs

#### 0x8145eddDf43f50276641b55bd3AD95944510021E (AaveV3Arbitrum.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveFactorChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), oldReserveFactor: 2500, newReserveFactor: 5000) |
| 2 | ReserveFactorChanged(asset: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), oldReserveFactor: 1500, newReserveFactor: 5000) |
| 4 | ReserveFactorChanged(asset: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), oldReserveFactor: 5000, newReserveFactor: 7500) |
| 6 | ReserveFactorChanged(asset: 0xD22a58f79e9481D1a88e00c343885A588b34b68B (symbol: EURS), oldReserveFactor: 2000, newReserveFactor: 5000) |
| 8 | SupplyCapChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), oldSupplyCap: 4900000, newSupplyCap: 1) |
| 9 | BorrowCapChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), oldBorrowCap: 4410000, newBorrowCap: 1) |
| 10 | SupplyCapChanged(asset: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), oldSupplyCap: 1300, newSupplyCap: 1) |
| 11 | SupplyCapChanged(asset: 0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40 (symbol: tBTC), oldSupplyCap: 35, newSupplyCap: 1) |
| 12 | SupplyCapChanged(asset: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), oldSupplyCap: 1700000, newSupplyCap: 1) |
| 13 | BorrowCapChanged(asset: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), oldBorrowCap: 1530000, newBorrowCap: 1) |
| 14 | SupplyCapChanged(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), oldSupplyCap: 66, newSupplyCap: 1) |
| 15 | SupplyCapChanged(asset: 0xD22a58f79e9481D1a88e00c343885A588b34b68B (symbol: EURS), oldSupplyCap: 80000, newSupplyCap: 1) |
| 16 | BorrowCapChanged(asset: 0xD22a58f79e9481D1a88e00c343885A588b34b68B (symbol: EURS), oldBorrowCap: 65000, newBorrowCap: 1) |
| 17 | AssetLtvzeroInEModeChanged(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), categoryId: 1, ltvzero: true) |
| 18 | ReserveFrozen(asset: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), frozen: true) |
| 19 | PendingLtvChanged(asset: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), ltv: 6900) |
| 20 | CollateralConfigurationChanged(asset: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), ltv: 0, liquidationThreshold: 7400, liquidationBonus: 10750) |
| 21 | ReserveFrozen(asset: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), frozen: true) |
| 22 | AssetLtvzeroInEModeChanged(asset: 0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40 (symbol: tBTC), categoryId: 10, ltvzero: true) |
| 23 | ReserveFrozen(asset: 0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40 (symbol: tBTC), frozen: true) |
| 24 | AssetLtvzeroInEModeChanged(asset: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), categoryId: 1, ltvzero: true) |
| 25 | ReserveFrozen(asset: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), frozen: true) |
| 26 | AssetLtvzeroInEModeChanged(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), categoryId: 3, ltvzero: true) |
| 27 | AssetLtvzeroInEModeChanged(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), categoryId: 4, ltvzero: true) |
| 28 | ReserveFrozen(asset: 0x2416092f143378750bb29b79eD961ab195CcEea5 (symbol: ezETH), frozen: true) |

#### 0x794a61358D6845594F94dc1DB02A252b5b4814aD (AaveV3Arbitrum.POOL)

| index | event |
| --- | --- |
| 1 | ReserveDataUpdated(reserve: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), liquidityRate: 12561560225195196495925394, stableBorrowRate: 0, variableBorrowRate: 37360694648011628328976701, liquidityIndex: 1.1951 [1195168427391258700772852012, 27 decimals], variableBorrowIndex: 1.3178 [1317846308513279399501450364, 27 decimals]) |
| 3 | ReserveDataUpdated(reserve: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), liquidityRate: 13393077635184195242125, stableBorrowRate: 0, variableBorrowRate: 2041258269029276469187820, liquidityIndex: 1.0026 [1002652400436789336071802895, 27 decimals], variableBorrowIndex: 1.0228 [1022874478549963647981310054, 27 decimals]) |
| 5 | ReserveDataUpdated(reserve: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), liquidityRate: 19518915234458918446675132, stableBorrowRate: 0, variableBorrowRate: 93155671240007162241603879, liquidityIndex: 1.1807 [1180794604334422145262991958, 27 decimals], variableBorrowIndex: 1.4059 [1405938173187899338135947124, 27 decimals]) |
| 7 | ReserveDataUpdated(reserve: 0xD22a58f79e9481D1a88e00c343885A588b34b68B (symbol: EURS), liquidityRate: 8956501729902209483502743, stableBorrowRate: 0, variableBorrowRate: 35094476518169403928198836, liquidityIndex: 1.1217 [1121701573422769484198091326, 27 decimals], variableBorrowIndex: 1.2227 [1222766845636252391438705085, 27 decimals]) |

#### 0xFF1137243698CaA18EE364Cc966CF0e02A4e6327 (AaveV3Arbitrum.ACL_ADMIN, GovernanceV3Arbitrum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 29 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1789399804, withDelegatecall: true, resultData: 0x) |

#### 0x89644CA1bB8064760312AE4F03ea41b05dA3637C (GovernanceV3Arbitrum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 30 | PayloadExecuted(payloadId: 138) |

## Raw storage changes

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Arbitrum.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x2fb1ad43c3875564c9e17e163f725f9a9a0608795fdc720b7ce5631c6c97e9a5 | 0x100000000000000000000003e800000002300000000107d0811229fe1e780000 | 0x100000000000000000000003e800000000100000000107d0831229fe1e780000 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee39 | 0x100000000000000000000003e800000051400000000105dc811229fe1ce81af4 | 0x100000000000000000000003e80000000010000000011388831229fe1ce80000 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee3a | 0x00000000000004d23d332a1d090b3bcb00000000033d5fe041b414b398c5355c | 0x00000000000002d60a4a1da22eab888d00000000033d5fe78a41f056f7fd100f |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee3b | 0x000000000001b03f8542678c1d1d0f5900000000034e177e6e8390af3f2f6ffc | 0x000000000001b040d51e584e368854ec00000000034e1a18975862ab7e45d066 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee3c | 0x000000000000000000000a006aa53df6000000000000000000000c1cfdac98f9 | 0x000000000000000000000a006aa812fc000000000000000000000c1cfdac98f9 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee41 | 0x0000000000000034742a76e011cf4942000000000000000000031d95f4215ace | 0x0000000000000034742a76e011cf494200000000000000000003329deb09b7b3 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354e | 0x0000000000000000000000000000000000000000000000000000000000001020 | 0x0000000000000000000000000002000000000000000000000000000000001020 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479a | 0x100000000000000000000103e80004ac4a0000434a9009c4851229041e140000 | 0x100000000000000000000103e80000000010000000011388871229041e140000 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479b | 0x00000000000f9601bd3177c777685fe60000000003dc9e1391fa1a1371c9e5d0 | 0x00000000000a64038b5720951fa390920000000003dc9ec245ef6877faa4c12c |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479c | 0x00000000001ee76bc4cb824c05993bde000000000442175193586fb976b0cd00 | 0x00000000001ee76f50ad7ac5a3f7013d00000000044218cf88dbdf6d53df4c7c |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479d | 0x0000000000000000000000006aa8015b000000000000000cf0158b7381602c42 | 0x0000000000000000000000006aa812fc000000000000000cf0158b7381602c42 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a947a2 | 0x000000000000f980e0c7ac7ef579457d00000000000000b1d30f00eb56dd809e | 0x000000000000f980e0c7ac7ef579457d00000000000000b1f89bb36820f589b2 |
| 0x80d3b16018b60b749d2bc1c0b179418bf0067c8de4f67a7e0e09c0f02bf661b2 | 0x100000000000000000000003e800000004200000000105dc811229fe000a0000 | 0x100000000000000000000003e800000000100000000105dc831229fe000a0000 |
| 0x81d0999fde243adcc41b7fa1be5cea14f789e3a6065b815ac58f4bc0838c3157 | 0x0000000000000000000000000000000000000000000000000000000000000110 | 0x0000000000000000000000000002000000000000000000000000000000000110 |
| 0x8e0cc0f1f0504b4cb44a23b328568106915b169e79003737a7b094503cdbeeb2 | 0x0000000000000000000000000000008100000000000000000000000000000000 | 0x0000000000000000000000000000008500000000000000000000000000000000 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa167 | 0x100000000000000000000103e800019f0a00001758901388810629041e780000 | 0x100000000000000000000103e80000000010000000011d4c830629041e780000 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa168 | 0x0000000000204a77ac23db7fa09936160000000003d0b67d6c3932ff4e947c31 | 0x000000000010254a83dccf47999bb4bc0000000003d0bafbc390ba10dd9cba56 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa169 | 0x00000000004d0e580f1f8436571b9c0d00000000048aea389fb4f72c6277915f | 0x00000000004d0e7b0e90374317f1d92700000000048af6fd1668700a48f3c774 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa16a | 0x0000000000000000000002006aa7da4600000000000000000000000016be29ae | 0x0000000000000000000002006aa812fc00000000000000000000000016be29ae |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa16f | 0x00000000000000000000002adcb1e0ac0000000000000000000000018454a16b | 0x00000000000000000000002adcb1e0ac000000000000000000000001855d45db |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e5 | 0x100000000000000000000103e800001388000000fde807d0870229fe1a2c0000 | 0x100000000000000000000103e80000000010000000011388870229fe1a2c0000 |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e6 | 0x00000000000bc73343fdf8530c83117600000000039d63a8bf593da8f2aabd29 | 0x000000000007689cee820620393d749700000000039fd98c23a71e1967749a3e |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e7 | 0x00000000001cefc6c567af1b37c8090c0000000003ecdd07f1326218c6d343f7 | 0x00000000001d078b62587183d64dbeb40000000003f372f3862ba78c010661bd |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e8 | 0x0000000000000000000007006a4e37b300000000000000000000000000000059 | 0x0000000000000000000007006aa812fc00000000000000000000000000000059 |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859ed | 0x0000000000000000000000000007ed1400000000000000000000000000000000 | 0x0000000000000000000000000007ed1400000000000000000000000000000274 |
| 0xb6395f9c432dd8cece69c29d0bafa901e98160153dacb5e1d5fb45e8d47ba1d8 | 0x0000000000000000000000000000000000000000000000000000000000001020 | 0x0000000000000000000000000008000000000000000000000000000000001020 |

### 0x8145edddf43f50276641b55bd3ad95944510021e (AaveV3Arbitrum.POOL_CONFIGURATOR)

| slot | previous value | new value |
| --- | --- | --- |
| 0xb40295f3731c96704053dd65105e1cbfdff43c943b64100df6874402c364189e | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000001af4 |

### 0x89644ca1bb8064760312ae4f03ea41b05da3637c (GovernanceV3Arbitrum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x70d52b43b3e1f9a31ab6163a901e55133bd37da50c470c7ad07e6be9a4e139f4 | 0x006aa812fb000000000002000000000000000000000000000000000000000000 | 0x006aa812fb000000000003000000000000000000000000000000000000000000 |
| 0x70d52b43b3e1f9a31ab6163a901e55133bd37da50c470c7ad07e6be9a4e139f5 | 0x000000000000000000093a800000000000006ad6377c00000000000000000000 | 0x000000000000000000093a800000000000006ad6377c0000000000006aa812fc |


## Raw diff

```json
{
  "reserves": {
    "0x2416092f143378750bb29b79eD961ab195CcEea5": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "supplyCap": {
        "from": 66,
        "to": 1
      }
    },
    "0x6c84a8f1c29108F47a79964b5Fe888D4f4D0dE40": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "supplyCap": {
        "from": 35,
        "to": 1
      }
    },
    "0xD22a58f79e9481D1a88e00c343885A588b34b68B": {
      "borrowCap": {
        "from": 65000,
        "to": 1
      },
      "reserveFactor": {
        "from": 2000,
        "to": 5000
      },
      "supplyCap": {
        "from": 80000,
        "to": 1
      }
    },
    "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1": {
      "borrowCap": {
        "from": 4410000,
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
        "from": 4900000,
        "to": 1
      }
    },
    "0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8": {
      "isFrozen": {
        "from": false,
        "to": true
      },
      "ltv": {
        "from": 6900,
        "to": 0
      },
      "reserveFactor": {
        "from": 1500,
        "to": 5000
      },
      "supplyCap": {
        "from": 1300,
        "to": 1
      }
    },
    "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8": {
      "borrowCap": {
        "from": 1530000,
        "to": 1
      },
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 5000,
        "to": 7500
      },
      "supplyCap": {
        "from": 1700000,
        "to": 1
      }
    }
  }
}
```
