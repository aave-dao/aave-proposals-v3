## Reserve changes

### Reserves altered

#### WETH.e ([0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB](https://snowscan.xyz/address/0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### AAVE.e ([0x63a72806098Bd3D9520cC43356dD78afe5D386D9](https://snowscan.xyz/address/0x63a72806098Bd3D9520cC43356dD78afe5D386D9))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 20 % [2000] | 99.99 % [9999] |


#### USDC.e ([0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664](https://snowscan.xyz/address/0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### WAVAX ([0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7](https://snowscan.xyz/address/0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### USDT.e ([0xc7198437980c041c805A1EDcbA50c1Ce5db95118](https://snowscan.xyz/address/0xc7198437980c041c805A1EDcbA50c1Ce5db95118))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### DAI.e ([0xd586E7F844cEa2F87f50152665BCbc2C279D8d70](https://snowscan.xyz/address/0xd586E7F844cEa2F87f50152665BCbc2C279D8d70))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


## Raw storage changes

### 0x1140cb7cafacc745771c2ea31e7b5c653c5d0b80 (GovernanceV3Avalanche.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0x93d1935305b2d38c36a29894407d9e2a1bc6d663aa42bffc7b7c21e606326569 | 0x006af4bbac000000000002000000000000000000000000000000000000000000 | 0x006af4bbac000000000003000000000000000000000000000000000000000000 |
| 0x93d1935305b2d38c36a29894407d9e2a1bc6d663aa42bffc7b7c21e60632656a | 0x000000000000000000093a800000000000006b22e02d00000000000000000000 | 0x000000000000000000093a800000000000006b22e02d0000000000006af4bbad |

### 0x4f01aed16d97e3ab5ab2b501154dc9bb0f1a5a2c (AaveV2Avalanche.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x1c436f4b938f845ee1b83ea962adc5e4cf97d5b57ac4ad0417f240d279307dc0 | 0x000000000000000000000000000000000000000000002134031229041e14189c | 0x00000000000000000000000000000000000000000000270f031229041e14189c |
| 0x39dff3183cb26c9dcd752d170fbb41505c23c8c6efcef5d6fbf04a41db655329 | 0x000000000000000000000000000000000000000000002134070629041e781d4c | 0x00000000000000000000000000000000000000000000270f070629041e781d4c |
| 0x5f66982f143050cfca979720f32a697dc119a214707431fcd220ac0c0c3fb044 | 0x0000000000000000000000000000000000000000000021340306000000000000 | 0x00000000000000000000000000000000000000000000270f0306000000000000 |
| 0x80a6bd6ed3e5cca4d8041e8c1b3aba2518ab3610d9461271e76a3e14d6eaab9f | 0x00000000000000000000000000000000000000000000213403122af819641388 | 0x00000000000000000000000000000000000000000000270f03122af819641388 |
| 0x8597339a395b4dd6e28bfeb5d53cc869f161f16c04f29a7e2b336429da7b3e6f | 0x00000000000000000000000000000000000000000000213403122904203a1f40 | 0x00000000000000000000000000000000000000000000270f03122904203a1f40 |
| 0xca99877a2878fb4f63e50c252492f16b0d99d4ef2835e66d00df76c888e7513b | 0x0000000000000000000000000000000000000000000007d003122af819640fa0 | 0x00000000000000000000000000000000000000000000270f03122af819640fa0 |


## Raw diff

```json
{
  "reserves": {
    "0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0x63a72806098Bd3D9520cC43356dD78afe5D386D9": {
      "reserveFactor": {
        "from": 2000,
        "to": 9999
      }
    },
    "0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0xc7198437980c041c805A1EDcbA50c1Ce5db95118": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0xd586E7F844cEa2F87f50152665BCbc2C279D8d70": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    }
  }
}
```
