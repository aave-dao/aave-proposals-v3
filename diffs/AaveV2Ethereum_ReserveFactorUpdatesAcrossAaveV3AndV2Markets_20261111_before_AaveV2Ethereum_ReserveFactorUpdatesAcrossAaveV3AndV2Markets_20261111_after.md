## Reserve changes

### Reserves altered

#### WBTC ([0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599](https://etherscan.io/address/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 90 % [9000] | 99.99 % [9999] |


#### DAI ([0x6B175474E89094C44Da98b954EedeAC495271d0F](https://etherscan.io/address/0x6B175474E89094C44Da98b954EedeAC495271d0F))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### USDC ([0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48](https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### WETH ([0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2](https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


#### USDT ([0xdAC17F958D2ee523a2206206994597C13D831ec7](https://etherscan.io/address/0xdAC17F958D2ee523a2206206994597C13D831ec7))

| description | value before | value after |
| --- | --- | --- |
| reserveFactor | 85 % [8500] | 99.99 % [9999] |


## Raw storage changes

### 0x7d2768de32b0b80b7a3454c06bdac94a69ddc7a9 (AaveV2Ethereum.POOL)

| slot | previous value | new value |
| --- | --- | --- |
| 0x212aa9bd7b173642810e5e991e9e9ed2f6ac3087d28021b9f35fb9d1a8d1160e | 0x000000000000000000000000000000000000000000002134031228a01e14189c | 0x00000000000000000000000000000000000000000000270f031228a01e14189c |
| 0x4cb5a02f592bd29403ce60c982c7f5174b16842da4fff5cfd025d6836dc48d4b | 0x000000000000000000000000000000000000000000002134031229042198203a | 0x00000000000000000000000000000000000000000000270f031229042198203a |
| 0x53bbdf4cf4f70d2494b9e1c24700a6c1a17d11c747522a0d584f0f40229caaab | 0x000000000000000000000000000000000000000000002134030628d2222e1d4c | 0x00000000000000000000000000000000000000000000270f030628d2222e1d4c |
| 0xa5ac31719d9f4564672a106339496685f6250ad08b6ee3bf8e1ddeb0c36d52d2 | 0x0000000000000000000000000000000000000000000021340306000000000000 | 0x00000000000000000000000000000000000000000000270f0306000000000000 |
| 0xe08aad639ffd10ccac329590adb88878e4ea69ff976a955eed6ae73f151b10cf | 0x0000000000000000000000000000000000000000000023280308290420081c20 | 0x00000000000000000000000000000000000000000000270f0308290420081c20 |

### 0xdabad81af85554e9ae636395611c58f7ec1aaec5 (GovernanceV3Ethereum.PAYLOADS_CONTROLLER)

| slot | previous value | new value |
| --- | --- | --- |
| 0xb7d551ab1924ea19cd6ad215c87f3da1ef0dc5bf778394a70eb2808fb00906bc | 0x006af4bba6000000000002000000000000000000000000000000000000000000 | 0x006af4bba6000000000003000000000000000000000000000000000000000000 |
| 0xb7d551ab1924ea19cd6ad215c87f3da1ef0dc5bf778394a70eb2808fb00906bd | 0x000000000000000000093a800000000000006b22e02700000000000000000000 | 0x000000000000000000093a800000000000006b22e0270000000000006af4bba7 |


## Raw diff

```json
{
  "reserves": {
    "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599": {
      "reserveFactor": {
        "from": 9000,
        "to": 9999
      }
    },
    "0x6B175474E89094C44Da98b954EedeAC495271d0F": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    },
    "0xdAC17F958D2ee523a2206206994597C13D831ec7": {
      "reserveFactor": {
        "from": 8500,
        "to": 9999
      }
    }
  }
}
```
