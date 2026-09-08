## Reserve changes

### Reserves altered

#### ezETH ([0x09601A65e7de7BC8A19813D263dD9E98bFdC3c57](https://mega.etherscan.io/address/0x09601A65e7de7BC8A19813D263dD9E98bFdC3c57))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |


#### USDT0 ([0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb](https://mega.etherscan.io/address/0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb))

| description | value before | value after |
| --- | --- | --- |
| isFrozen | :x: | :white_check_mark: |
| supplyCap | 10,000,000 USDT0 | 1 USDT0 |
| borrowCap | 9,000,000 USDT0 | 1 USDT0 |
| reserveFactor | 10 % [1000] | 50 % [5000] |


## Event logs

#### 0xF15D31Bc839A853C9068686043cEc6EC5995DAbB (AaveV3MegaEth.POOL_CONFIGURATOR)

| index | event |
| --- | --- |
| 0 | ReserveFactorChanged(asset: 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb (symbol: USDT0), oldReserveFactor: 1000, newReserveFactor: 5000) |
| 2 | SupplyCapChanged(asset: 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb (symbol: USDT0), oldSupplyCap: 10000000, newSupplyCap: 1) |
| 3 | BorrowCapChanged(asset: 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb (symbol: USDT0), oldBorrowCap: 9000000, newBorrowCap: 1) |
| 4 | AssetLtvzeroInEModeChanged(asset: 0x09601A65e7de7BC8A19813D263dD9E98bFdC3c57 (symbol: ezETH), categoryId: 6, ltvzero: true) |
| 5 | ReserveFrozen(asset: 0x09601A65e7de7BC8A19813D263dD9E98bFdC3c57 (symbol: ezETH), frozen: true) |
| 6 | ReserveFrozen(asset: 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb (symbol: USDT0), frozen: true) |

#### 0x7e324AbC5De01d112AfC03a584966ff199741C28 (AaveV3MegaEth.POOL)

| index | event |
| --- | --- |
| 1 | ReserveDataUpdated(reserve: 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb (symbol: USDT0), liquidityRate: 11007830266780207540101719, stableBorrowRate: 0, variableBorrowRate: 31280565875501261519127584, liquidityIndex: 1.0110 [1011051663947996079356721915, 27 decimals], variableBorrowIndex: 1.0151 [1015180328014815434734638847, 27 decimals]) |

#### 0xE2E8Badc5d50f8a6188577B89f50701cDE2D4e19 (AaveV3MegaEth.ACL_ADMIN, GovernanceV3MegaEth.EXECUTOR_LVL_1)

| index | event |
| --- | --- |
| 7 | ExecutedAction(target: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, value: 0, signature: execute(), data: 0x, executionTime: 1787723528, withDelegatecall: true, resultData: 0x) |

#### 0x80e11cB895a23C901a990239E5534054C66476B5 (GovernanceV3MegaEth.PAYLOADS_CONTROLLER)

| index | event |
| --- | --- |
| 8 | PayloadExecuted(payloadId: 10) |

## Raw storage changes

### 0x7e324abc5de01d112afc03a584966ff199741c28 (AaveV3MegaEth.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x01290583d43e205f46f8d824d1236df318521e471f570a5b36fa1844856e40d8 | 0x0000000000000000000000000000000000000000000000000000000000000001 | 0x0000000000000000000000000000004000000000000000000000000000000001 |
| 0x80432f665e0bdbfe261b656dbe8c35e7f08625c01f0327d4e88f6aaee03aeced | 0x100000000000000000000003e800000000100000000107d08112000000000000 | 0x100000000000000000000003e800000000100000000107d08312000000000000 |
| 0xace1738bd21dfb38ab702aadd1277b4df729315c49e6743bfbebb5a89576504a | 0x100000000000000000000003e800098968000089544003e88506000000000000 | 0x100000000000000000000003e800000000100000000113888706000000000000 |
| 0xace1738bd21dfb38ab702aadd1277b4df729315c49e6743bfbebb5a89576504b | 0x000000000010636f1a70512baf98ad9c0000000003443eacc9f69df1b461e75d | 0x0000000000091affacaab44727206257000000000344528487020d8e07613afb |
| 0xace1738bd21dfb38ab702aadd1277b4df729315c49e6743bfbebb5a89576504c | 0x000000000019dfa1600e488f8f89285a0000000003479d57343cbf885c5be084 | 0x000000000019dfeadfba8374aaf50420000000000347bccbdadb6a078c2d16ff |
| 0xace1738bd21dfb38ab702aadd1277b4df729315c49e6743bfbebb5a89576504d | 0x0000000000000000000002006a8c3eb800000000000000000000000000000000 | 0x0000000000000000000002006a8e7f0800000000000000000000000000000000 |
| 0xace1738bd21dfb38ab702aadd1277b4df729315c49e6743bfbebb5a895765052 | 0x0000000000000000000000001fa79e3b00000000000000000000000000000000 | 0x0000000000000000000000001fa79e3b00000000000000000000000000004758 |

### 0x80e11cb895a23c901a990239e5534054c66476b5 (GovernanceV3MegaEth.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x9dcb9783ba5cd0b54745f65f4f918525e461e91888c334e5342cb380ac558d53 | 0x006a8e7f07000000000002000000000000000000000000000000000000000000 | 0x006a8e7f07000000000003000000000000000000000000000000000000000000 |
| 0x9dcb9783ba5cd0b54745f65f4f918525e461e91888c334e5342cb380ac558d54 | 0x000000000000000000093a800000000000006abca38800000000000000000000 | 0x000000000000000000093a800000000000006abca3880000000000006a8e7f08 |


## Raw diff

```json
{
  "reserves": {
    "0x09601A65e7de7BC8A19813D263dD9E98bFdC3c57": {
      "isFrozen": {
        "from": false,
        "to": true
      }
    },
    "0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb": {
      "borrowCap": {
        "from": 9000000,
        "to": 1
      },
      "isFrozen": {
        "from": false,
        "to": true
      },
      "reserveFactor": {
        "from": 1000,
        "to": 5000
      },
      "supplyCap": {
        "from": 10000000,
        "to": 1
      }
    }
  }
}
```
