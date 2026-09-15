// Bootstrap configuration only: custom oracle adapters and tests are added after generation.
// Do not regenerate over this draft without preserving the custom code.
import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'draft-oracle-config.ts',
    markets: [
      'AaveV2Ethereum',
      'AaveV2Polygon',
      'AaveV3Arbitrum',
      'AaveV3Avalanche',
      'AaveV3Celo',
      'AaveV3Ethereum',
      'AaveV3EthereumEtherFi',
      'AaveV3Optimism',
      'AaveV3Polygon',
      'AaveV3Scroll',
    ],
    title: 'Oracle Deprecation for Long-tail Assets',
    shortName: 'OracleDeprecationForLongTailAssets',
    date: '20260915',
    author: 'LlamaRisk',
    discussion:
      'https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400',
    snapshot:
      'https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV2Ethereum: {
      configs: {
        RATE_UPDATE_V2: [
          {
            asset: 'AMPL',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '0',
              variableRateSlope2: '0',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'TUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '0',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'BAL',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'ENJ',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'sUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '0',
              variableRateSlope2: '0',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'KNC',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'LUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'REN',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'ZRX',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 25982593},
    },
    AaveV2Polygon: {
      configs: {
        RATE_UPDATE_V2: [
          {
            asset: 'BAL',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
          {
            asset: 'GHST',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '',
              variableRateSlope2: '40',
              stableRateSlope1: '',
              stableRateSlope2: '',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 93844683},
    },
    AaveV3Arbitrum: {
      configs: {
        FREEZE: [
          {asset: 'FRAX', shouldBeFrozen: true},
          {asset: 'LUSD', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [{asset: 'MAI', supplyCap: '1', borrowCap: '1'}],
        BORROWS_UPDATE: [
          {
            asset: 'LUSD',
            reserveFactor: '99',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
          },
          {
            asset: 'FRAX',
            reserveFactor: '99',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
          },
        ],
        RATE_UPDATE_V3: [
          {
            asset: 'FRAX',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '5.5',
              variableRateSlope2: '100',
            },
          },
          {
            asset: 'LUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '6.5',
              variableRateSlope2: '100',
            },
          },
          {
            asset: 'MAI',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '9',
              variableRateSlope2: '40',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 505404403},
    },
    AaveV3Avalanche: {
      configs: {
        FREEZE: [{asset: 'FRAX', shouldBeFrozen: true}],
        CAPS_UPDATE: [{asset: 'MAI', supplyCap: '1', borrowCap: '1'}],
        RATE_UPDATE_V3: [
          {
            asset: 'FRAX',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '5.5',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'MAI',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '9',
              variableRateSlope2: '40',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 95341470},
    },
    AaveV3Celo: {
      configs: {
        FREEZE: [{asset: 'USDm', shouldBeFrozen: true}],
        CAPS_UPDATE: [{asset: 'USDm', supplyCap: '1', borrowCap: '1'}],
        BORROWS_UPDATE: [
          {
            asset: 'USDm',
            reserveFactor: '99',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
          },
        ],
        RATE_UPDATE_V3: [
          {
            asset: 'USDm',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '4',
              variableRateSlope2: '100',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 77571299},
    },
    AaveV3Ethereum: {
      configs: {
        FREEZE: [
          {asset: 'BAL', shouldBeFrozen: true},
          {asset: 'FRAX', shouldBeFrozen: true},
          {asset: 'LUSD', shouldBeFrozen: true},
          {asset: 'RPL', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'FXS', supplyCap: '1', borrowCap: '1'},
          {asset: 'KNC', supplyCap: '1', borrowCap: '1'},
          {asset: 'LUSD', supplyCap: '1', borrowCap: ''},
          {asset: 'RPL', supplyCap: '1', borrowCap: ''},
          {asset: 'STG', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'LUSD',
            reserveFactor: '99',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
          },
          {
            asset: 'FRAX',
            reserveFactor: '99',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
          },
          {
            asset: 'RPL',
            reserveFactor: '99',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
          },
        ],
        RATE_UPDATE_V3: [
          {
            asset: 'FRAX',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '5.5',
              variableRateSlope2: '100',
            },
          },
          {
            asset: 'LUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '5',
              variableRateSlope2: '100',
            },
          },
          {
            asset: 'RPL',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '8.5',
              variableRateSlope2: '100',
            },
          },
          {
            asset: 'BAL',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '15',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'FXS',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '9',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'KNC',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '9',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'STG',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '7',
              variableRateSlope2: '40',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 25982593},
    },
    AaveV3EthereumEtherFi: {
      configs: {
        FREEZE: [{asset: 'FRAX', shouldBeFrozen: true}],
        CAPS_UPDATE: [],
        RATE_UPDATE_V3: [
          {
            asset: 'FRAX',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '5.5',
              variableRateSlope2: '40',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 25982593},
    },
    AaveV3Optimism: {
      configs: {
        FREEZE: [
          {asset: 'LUSD', shouldBeFrozen: true},
          {asset: 'sUSD', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [{asset: 'MAI', supplyCap: '1', borrowCap: '1'}],
        RATE_UPDATE_V3: [
          {
            asset: 'LUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '5.5',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'MAI',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '5.5',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'sUSD',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '0',
              variableRateSlope2: '0',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 156936640},
    },
    AaveV3Polygon: {
      configs: {
        CAPS_UPDATE: [
          {asset: 'BAL', supplyCap: '1', borrowCap: '1'},
          {asset: 'miMATIC', supplyCap: '1', borrowCap: '1'},
        ],
        FREEZE: [{asset: 'GHST', shouldBeFrozen: true}],
        RATE_UPDATE_V3: [
          {
            asset: 'BAL',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '15',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'GHST',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '7',
              variableRateSlope2: '40',
            },
          },
          {
            asset: 'miMATIC',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '9',
              variableRateSlope2: '40',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 93844683},
    },
    AaveV3Scroll: {
      configs: {
        RATE_UPDATE_V3: [
          {
            asset: 'SCR',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '20',
              variableRateSlope1: '7',
              variableRateSlope2: '40',
            },
          },
        ],
        OTHERS: {},
      },
      cache: {blockNumber: 35039319},
    },
  },
};
