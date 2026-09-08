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
| 1 | ReserveDataUpdated(reserve: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1 (symbol: DAI), liquidityRate: 11201632557661444617153058, stableBorrowRate: 0, variableBorrowRate: 35280396257773504232781134, liquidityIndex: 1.1939 [1193980106363164002041456778, 27 decimals], variableBorrowIndex: 1.3152 [1315241678902755598383508577, 27 decimals]) |
| 3 | ReserveDataUpdated(reserve: 0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8 (symbol: rETH), liquidityRate: 18753893496199714709490, stableBorrowRate: 0, variableBorrowRate: 2415480225374843668008784, liquidityIndex: 1.0026 [1002651086305708374784171058, 27 decimals], variableBorrowIndex: 1.0227 [1022759492901474696441213300, 27 decimals]) |
| 5 | ReserveDataUpdated(reserve: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8 (symbol: USDC), liquidityRate: 18655865538667221864418097, stableBorrowRate: 0, variableBorrowRate: 91072628828141645545130200, liquidityIndex: 1.1784 [1178411741855584202310411630, 27 decimals], variableBorrowIndex: 1.3990 [1399088382832115061696021831, 27 decimals]) |
| 7 | ReserveDataUpdated(reserve: 0xD22a58f79e9481D1a88e00c343885A588b34b68B (symbol: EURS), liquidityRate: 8940206438716810024004234, stableBorrowRate: 0, variableBorrowRate: 35062538263224572230119868, liquidityIndex: 1.1208 [1120854853711183568605850397, 27 decimals], variableBorrowIndex: 1.2204 [1220495270113847697141813343, 27 decimals]) |

#### 0xFF1137243698CaA18EE364Cc966CF0e02A4e6327 (AaveV3Arbitrum.ACL_ADMIN, GovernanceV3Arbitrum.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 29 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1787723525, withDelegatecall: true, resultData: 0x) |

#### 0x89644CA1bB8064760312AE4F03ea41b05dA3637C (GovernanceV3Arbitrum.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 30 | PayloadExecuted(payloadId: 137) |

## Raw storage changes

### 0x794a61358d6845594f94dc1db02a252b5b4814ad (AaveV3Arbitrum.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x2fb1ad43c3875564c9e17e163f725f9a9a0608795fdc720b7ce5631c6c97e9a5 | 0x100000000000000000000003e800000002300000000107d0811229fe1e780000 | 0x100000000000000000000003e800000000100000000107d0831229fe1e780000 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee39 | 0x100000000000000000000003e800000051400000000105dc811229fe1ce81af4 | 0x100000000000000000000003e80000000010000000011388831229fe1ce80000 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee3a | 0x00000000000006c04c5f5f10311ff38e00000000033d5f9eadaec2b761259f54 | 0x00000000000003f8a68df4684c8c1ff200000000033d5fa04d0678c532575c32 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee3b | 0x000000000001ff7f2763ae115efffef200000000034e0141d1beb006cf13cd24 | 0x000000000001ff7f72058fb2ed040f5000000000034e01bf34ea220b4df1b174 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee3c | 0x000000000000000000000a006a8e0baf000000000000000000000c1cfdac98f9 | 0x000000000000000000000a006a8e7f05000000000000000000000c1cfdac98f9 |
| 0x36ce690a3e41633995fb479a7fd89cf51578df5d336828d9f194d6be37a2ee41 | 0x0000000000000036a111935ca3c9ae9b00000000000000000002592dcef240cd | 0x0000000000000036a111935ca3c9ae9b000000000000000000025e11e9b678e9 |
| 0x533efb5c9f032d0e72b35f5d59b231dc7a9fb94625f73b3c45c394126326354e | 0x0000000000000000000000000000000000000000000000000000000000001020 | 0x0000000000000000000000000002000000000000000000000000000000001020 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479a | 0x100000000000000000000103e80004ac4a0000434a9009c4851229041e140000 | 0x100000000000000000000103e80000000010000000011388871229041e140000 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479b | 0x00000000000de60510ba49b6fd7e3a110000000003dba1664bb79e575699a02d | 0x0000000000094409b7bc80380cd62a220000000003dba31f42dc16fb2dcbe88a |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479c | 0x00000000001d2ee020e6c44eac899a6f00000000043fed465659f7d4e27fee19 | 0x00000000001d2eea1d0a7e7258fd754e00000000043ff14247ce5b24f31cec61 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a9479d | 0x0000000000000000000000006a8e4d12000000000000000cf0158b7381602c42 | 0x0000000000000000000000006a8e7f05000000000000000cf0158b7381602c42 |
| 0x737d92e4f754ad0901f4ba2f145786361957fa4b3c4c8367f2da2a3a09a947a2 | 0x0000000000011d189a922deb519883ba000000000000007b8be60ed12698c96b | 0x0000000000011d189a922deb519883ba000000000000007bed478ca93970f032 |
| 0x80d3b16018b60b749d2bc1c0b179418bf0067c8de4f67a7e0e09c0f02bf661b2 | 0x100000000000000000000003e800000004200000000105dc811229fe000a0000 | 0x100000000000000000000003e800000000100000000105dc831229fe000a0000 |
| 0x81d0999fde243adcc41b7fa1be5cea14f789e3a6065b815ac58f4bc0838c3157 | 0x0000000000000000000000000000000000000000000000000000000000000110 | 0x0000000000000000000000000002000000000000000000000000000000000110 |
| 0x8e0cc0f1f0504b4cb44a23b328568106915b169e79003737a7b094503cdbeeb2 | 0x0000000000000000000000000000008100000000000000000000000000000000 | 0x0000000000000000000000000000008500000000000000000000000000000000 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa167 | 0x100000000000000000000103e800019f0a00001758901388810629041e780000 | 0x100000000000000000000103e80000000010000000011d4c830629041e780000 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa168 | 0x00000000001edd0eb2d2ec29d1f6c71a0000000003cec21238d115b065769ec2 | 0x00000000000f6e887f5115fe81a40b310000000003cec26487b575734f79e56e |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa169 | 0x00000000004b555e4d21f0d519b0468b0000000004854b8eaef57e056465fe5f | 0x00000000004b556119fa0f45d7bcc8d80000000004854c7d355286f08ddcc547 |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa16a | 0x0000000000000000000002006a8e7ac400000000000000000000000016be29ae | 0x0000000000000000000002006a8e7f0500000000000000000000000016be29ae |
| 0xaa36895e16bf88054bc9ce1f3803f0ce3c9c129a784656f6747518dc4dcfa16f | 0x000000000000000000000030b2b617d90000000000000000000000010fb3fcf9 | 0x000000000000000000000030b2b617d90000000000000000000000010fc757e3 |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e5 | 0x100000000000000000000103e800001388000000fde807d0870229fe1a2c0000 | 0x100000000000000000000103e80000000010000000011388870229fe1a2c0000 |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e6 | 0x00000000000bc73343fdf8530c83117600000000039d63a8bf593da8f2aabd29 | 0x00000000000765298fea212870712a8a00000000039f263f5f29a801d2ccab1d |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e7 | 0x00000000001cefc6c567af1b37c8090c0000000003ecdd07f1326218c6d343f7 | 0x00000000001d00c80205395149d631bc0000000003f191ed2b14c767e17a505f |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859e8 | 0x0000000000000000000007006a4e37b300000000000000000000000000000059 | 0x0000000000000000000007006a8e7f0500000000000000000000000000000059 |
| 0xb423b4edbb56a3db80b29d0d26652b14f39041f82ba0703dad532c260ec859ed | 0x0000000000000000000000000007ed1400000000000000000000000000000000 | 0x0000000000000000000000000007ed14000000000000000000000000000001c1 |
| 0xb6395f9c432dd8cece69c29d0bafa901e98160153dacb5e1d5fb45e8d47ba1d8 | 0x0000000000000000000000000000000000000000000000000000000000001020 | 0x0000000000000000000000000008000000000000000000000000000000001020 |

### 0x8145edddf43f50276641b55bd3ad95944510021e (AaveV3Arbitrum.POOL_CONFIGURATOR)

| slot | previous value | new value |
| --- | --- | --- |
| 0xb40295f3731c96704053dd65105e1cbfdff43c943b64100df6874402c364189e | 0x0000000000000000000000000000000000000000000000000000000000000000 | 0x0000000000000000000000000000000000000000000000000000000000001af4 |

### 0x89644ca1bb8064760312ae4f03ea41b05da3637c (GovernanceV3Arbitrum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x0f7c2a22036bfa20acc9ee73aa9ab92bebf1413ecc0991a7c2b4d6178e9838ed | 0x006a8e7f04000000000002000000000000000000000000000000000000000000 | 0x006a8e7f04000000000003000000000000000000000000000000000000000000 |
| 0x0f7c2a22036bfa20acc9ee73aa9ab92bebf1413ecc0991a7c2b4d6178e9838ee | 0x000000000000000000093a800000000000006abca38500000000000000000000 | 0x000000000000000000093a800000000000006abca3850000000000006a8e7f05 |


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
