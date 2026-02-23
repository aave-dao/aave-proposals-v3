## Reserve changes

### Reserves added

#### SolvBTC ([0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3](https://explorer.inkonchain.com/address/0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3))

| description | value |
| --- | --- |
| decimals | 18 |
| isActive | true |
| isFrozen | false |
| supplyCap | 50 SolvBTC |
| borrowCap | 1 SolvBTC |
| debtCeiling | 1 $ [100] |
| isSiloed | false |
| isFlashloanable | true |
| oracle | [0xAe48F22903d43f13f66Cc650F57Bd4654ac222cb](https://explorer.inkonchain.com/address/0xAe48F22903d43f13f66Cc650F57Bd4654ac222cb) |
| oracleDecimals | 8 |
| oracleDescription | BTC / USD |
| oracleLatestAnswer | 67339.3 |
| usageAsCollateralEnabled | true |
| ltv | 70 % [7000] |
| liquidationThreshold | 75 % [7500] |
| liquidationBonus | 7.5 % |
| liquidationProtocolFee | 10 % [1000] |
| reserveFactor | 50 % [5000] |
| aToken | [0x24C1FaC3447C45137E5f1c2C54Fe9ed3F1EdeA61](https://explorer.inkonchain.com/address/0x24C1FaC3447C45137E5f1c2C54Fe9ed3F1EdeA61) |
| variableDebtToken | [0xD02245a1CD906AD9336600E037345a4C5242B141](https://explorer.inkonchain.com/address/0xD02245a1CD906AD9336600E037345a4C5242B141) |
| borrowingEnabled | false |
| isBorrowableInIsolation | false |
| interestRateStrategy | [0xCFDAdA7DCd2e785cF706BaDBC2B8Af5084d595e9](https://explorer.inkonchain.com/address/0xCFDAdA7DCd2e785cF706BaDBC2B8Af5084d595e9) |
| aTokenName | Aave InkWhitelabel SolvBTC |
| aTokenSymbol | aInkWlSolvBTC |
| aTokenUnderlyingBalance | 0.0016 SolvBTC [1600000000000000] |
| id | 9 |
| isPaused | false |
| variableDebtTokenName | Aave InkWhitelabel Variable Debt SolvBTC |
| variableDebtTokenSymbol | variableDebtInkWlSolvBTC |
| virtualBalance | 0.0016 SolvBTC [1600000000000000] |
| optimalUsageRatio | 45 % |
| maxVariableBorrowRate | 310 % |
| baseVariableBorrowRate | 0 % |
| variableRateSlope1 | 10 % |
| variableRateSlope2 | 300 % |
| interestRate | ![ir](https://dash.onaave.com/api/static?variableRateSlope1=100000000000000000000000000&variableRateSlope2=3000000000000000000000000000&optimalUsageRatio=450000000000000000000000000&baseVariableBorrowRate=0&maxVariableBorrowRate=3100000000000000000000000000) |


## Raw diff

```json
{
  "reserves": {
    "0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3": {
      "from": null,
      "to": {
        "aToken": "0x24C1FaC3447C45137E5f1c2C54Fe9ed3F1EdeA61",
        "aTokenName": "Aave InkWhitelabel SolvBTC",
        "aTokenSymbol": "aInkWlSolvBTC",
        "aTokenUnderlyingBalance": "1600000000000000",
        "borrowCap": 1,
        "borrowingEnabled": false,
        "debtCeiling": 100,
        "decimals": 18,
        "id": 9,
        "interestRateStrategy": "0xCFDAdA7DCd2e785cF706BaDBC2B8Af5084d595e9",
        "isActive": true,
        "isBorrowableInIsolation": false,
        "isFlashloanable": true,
        "isFrozen": false,
        "isPaused": false,
        "isSiloed": false,
        "liquidationBonus": 10750,
        "liquidationProtocolFee": 1000,
        "liquidationThreshold": 7500,
        "ltv": 7000,
        "oracle": "0xAe48F22903d43f13f66Cc650F57Bd4654ac222cb",
        "oracleDecimals": 8,
        "oracleDescription": "BTC / USD",
        "oracleLatestAnswer": "6733930000000",
        "reserveFactor": 5000,
        "supplyCap": 50,
        "symbol": "SolvBTC",
        "underlying": "0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3",
        "usageAsCollateralEnabled": true,
        "variableDebtToken": "0xD02245a1CD906AD9336600E037345a4C5242B141",
        "variableDebtTokenName": "Aave InkWhitelabel Variable Debt SolvBTC",
        "variableDebtTokenSymbol": "variableDebtInkWlSolvBTC",
        "virtualBalance": "1600000000000000"
      }
    }
  },
  "strategies": {
    "0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3": {
      "from": null,
      "to": {
        "address": "0xCFDAdA7DCd2e785cF706BaDBC2B8Af5084d595e9",
        "baseVariableBorrowRate": "0",
        "maxVariableBorrowRate": "3100000000000000000000000000",
        "optimalUsageRatio": "450000000000000000000000000",
        "variableRateSlope1": "100000000000000000000000000",
        "variableRateSlope2": "3000000000000000000000000000"
      }
    }
  },
  "raw": {
    "0x1de9cb9420dd1f2ccefff9393e126b800d413b7a": {
      "label": "GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER",
      "contract": "lib/aave-umbrella/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy",
      "balanceDiff": null,
      "nonceDiff": null,
      "stateDiff": {
        "0xf60b7f6a315ec68a6ac240e69dca53652b38627f709a2caa217d9e18af4d7a60": {
          "previousValue": "0x00698f28f2000000000002000000000000000000000000000000000000000000",
          "newValue": "0x00698f28f2000000000003000000000000000000000000000000000000000000"
        },
        "0xf60b7f6a315ec68a6ac240e69dca53652b38627f709a2caa217d9e18af4d7a61": {
          "previousValue": "0x000000000000000000093a8000000000000069bd4d7300000000000000000000",
          "newValue": "0x000000000000000000093a8000000000000069bd4d73000000000000698f28f3"
        }
      }
    },
    "0x24c1fac3447c45137e5f1c2c54fe9ed3f1edea61": {
      "label": null,
      "contract": "lib/aave-umbrella/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy",
      "balanceDiff": null,
      "nonceDiff": {
        "previousValue": 0,
        "newValue": 1
      },
      "stateDiff": {
        "0x0000000000000000000000000000000000000000000000000000000000000000": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000005"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000001": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000000"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000036": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000005af3107a40000"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000037": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x4161766520496e6b57686974656c6162656c20536f6c76425443000000000034"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000038": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x61496e6b576c536f6c764254430000000000000000000000000000000000001a"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000039": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000012"
        },
        "0x000000000000000000000000000000000000000000000000000000000000003b": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x5101e53002f3f22035b76552328b5c64952f50f1fc9f86198b16af600bb7767d"
        },
        "0x000000000000000000000000000000000000000000000000000000000000003d": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ae4efbc7736f963982aacb17efa37fcbab924cb3"
        },
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000b322b2b3cddeba3c726a8d0306a86697de3eccff",
          "label": "Implementation slot"
        },
        "0xffb1c44aaa95ab07b2e32cfca3531e9cdbab14027ba421318af503f8dfb83ade": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x00000000033b2e3c9fd0803ce800000000000000000000000005af3107a40000"
        }
      }
    },
    "0x2816cf15f6d2a220e789aa011d5ee4eb6c47feba": {
      "label": "AaveV3InkWhitelabel.POOL",
      "contract": "lib/aave-umbrella/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy",
      "balanceDiff": null,
      "nonceDiff": null,
      "stateDiff": {
        "0x000000000000000000000000000000000000000000000000000000000000003b": {
          "previousValue": "0x0000000000000000000000000000000000000000000000090000000000000000",
          "newValue": "0x00000000000000000000000000000000000000000000000a0000000000000000"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f881": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x100000000640000000000003e80000000320000000011388811229fe1d4c1b58"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f882": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000033b2e3c9fd0803ce8000000"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f883": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000033b2e3c9fd0803ce8000000"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f884": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000900698f28f300000000000000000000000000000000"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f885": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x00000000000000000000000024c1fac3447c45137e5f1c2c54fe9ed3f1edea61"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f887": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000d02245a1cd906ad9336600e037345a4c5242b141"
        },
        "0x2f2eeefff7f00ed3f25efa13f1e72fbbac2c9af130c4b7730070c92ef635f889": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x00000000000000000005af3107a4000000000000000000000000000000000000"
        },
        "0x748ad6d0c5a24a04515706b6da6a7b0cb9e1a9408b9f3a5672a42f933d02d13e": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ae4efbc7736f963982aacb17efa37fcbab924cb3"
        }
      }
    },
    "0x4758213271bfdc72224a7a8742dc865fc97756e1": {
      "label": "AaveV3InkWhitelabel.ORACLE",
      "contract": null,
      "balanceDiff": null,
      "nonceDiff": null,
      "stateDiff": {
        "0x7cfe9dc51f1b63accb3cc0ffb0fc1c67687dc2d0ed82e6714dff0de15f6786f3": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ae48f22903d43f13f66cc650f57bd4654ac222cb"
        }
      }
    },
    "0x4f221e5c0b7103f7e3291e10097de6d9e3bfc02d": {
      "label": "AaveV3InkWhitelabel.POOL_CONFIGURATOR",
      "contract": "lib/aave-umbrella/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy",
      "balanceDiff": null,
      "nonceDiff": {
        "previousValue": 19,
        "newValue": 21
      },
      "stateDiff": {}
    },
    "0x6e2afd57a161d12f34f416c29619bfeacac8aa18": {
      "label": null,
      "contract": null,
      "balanceDiff": null,
      "nonceDiff": {
        "previousValue": 19,
        "newValue": 21
      },
      "stateDiff": {}
    },
    "0x6fddde45f777a4e461b0721a578b169b44579623": {
      "label": "AaveV3InkWhitelabel.POOL_CONFIGURATOR_IMPL",
      "contract": null,
      "balanceDiff": null,
      "nonceDiff": {
        "previousValue": 19,
        "newValue": 21
      },
      "stateDiff": {}
    },
    "0x9cbcef2c44cf28ff2aa36bff7bab315398209a79": {
      "label": "AaveV3InkWhitelabel.EMISSION_MANAGER",
      "contract": null,
      "balanceDiff": null,
      "nonceDiff": null,
      "stateDiff": {
        "0x2447dc477e9e2e9915ab7ae6f56bd0d5ee600c56324c020c77e2a70135ea3cec": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ac140648435d03f784879cd789130f22ef588fcd"
        },
        "0x259d7374874799a2db79cf1567135b3c56822f62a24aabcd018f303d02c145d0": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ac140648435d03f784879cd789130f22ef588fcd"
        },
        "0x643789f674ff3c4665ab3db2f943a4f9972212d2b6e97726f51e999c9aa2ae4e": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ac140648435d03f784879cd789130f22ef588fcd"
        }
      }
    },
    "0xae4efbc7736f963982aacb17efa37fcbab924cb3": {
      "label": null,
      "contract": null,
      "balanceDiff": null,
      "nonceDiff": null,
      "stateDiff": {
        "0x25061132631c31b50f47b084591ef5cae6f847b89f571506a7396e9b4e489015": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000005aff8cec5f7bd",
          "newValue": "0x000000000000000000000000000000000000000000000000000000c7c721f7bd"
        },
        "0x52712fef6ac14b4cddc4788d2f6037328f670bb495889563480600b5004e8a14": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000000"
        },
        "0x8f9a02632668c64a7638e17d0cdeeafc3308341882512e774e71a75ec5c48232": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000005af3107a40000"
        }
      }
    },
    "0xcfdada7dcd2e785cf706badbc2b8af5084d595e9": {
      "label": "AaveV3InkWhitelabel.ASSETS.WETH.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.kBTC.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.USDT.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.USDG.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.GHO.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.USDC.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.weETH.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.wrsETH.INTEREST_RATE_STRATEGY, AaveV3InkWhitelabel.ASSETS.ezETH.INTEREST_RATE_STRATEGY",
      "contract": null,
      "balanceDiff": null,
      "nonceDiff": null,
      "stateDiff": {
        "0x7cfe9dc51f1b63accb3cc0ffb0fc1c67687dc2d0ed82e6714dff0de15f6786f3": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x00000000000000000000000000000000000000007530000003e8000000001194"
        }
      }
    },
    "0xd02245a1cd906ad9336600e037345a4c5242b141": {
      "label": null,
      "contract": "lib/aave-umbrella/lib/aave-v3-origin/lib/solidity-utils/lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy",
      "balanceDiff": null,
      "nonceDiff": {
        "previousValue": 0,
        "newValue": 1
      },
      "stateDiff": {
        "0x0000000000000000000000000000000000000000000000000000000000000000": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000005"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000001": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000000"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000035": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0xa681c3d464c6c4f6346278de36e393188fe697b8cf2d287bd71fa56d3d2c3363"
        },
        "0x0000000000000000000000000000000000000000000000000000000000000037": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ae4efbc7736f963982aacb17efa37fcbab924cb3"
        },
        "0x000000000000000000000000000000000000000000000000000000000000003b": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000051"
        },
        "0x000000000000000000000000000000000000000000000000000000000000003c": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x7661726961626c6544656274496e6b576c536f6c764254430000000000000030"
        },
        "0x000000000000000000000000000000000000000000000000000000000000003d": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x0000000000000000000000000000000000000000000000000000000000000012"
        },
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x000000000000000000000000ed9ee9cec2782a307e8f6ca6e10977b4ad44358d",
          "label": "Implementation slot"
        },
        "0xbbe3212124853f8b0084a66a2d057c2966e251e132af3691db153ab65f0d1a4d": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x4161766520496e6b57686974656c6162656c205661726961626c652044656274"
        },
        "0xbbe3212124853f8b0084a66a2d057c2966e251e132af3691db153ab65f0d1a4e": {
          "previousValue": "0x0000000000000000000000000000000000000000000000000000000000000000",
          "newValue": "0x20536f6c76425443000000000000000000000000000000000000000000000000"
        }
      }
    }
  }
}
```