import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/config.ts',
    update: true,
    force: true,
    markets: [
      'AaveV3Ethereum',
      'AaveV3EthereumLido',
      'AaveV3Arbitrum',
      'AaveV3Plasma',
      'AaveV3Base',
      'AaveV3Polygon',
      'AaveV3Avalanche',
      'AaveV3Optimism',
      'AaveV3Gnosis',
      'AaveV3BNB',
      'AaveV3MegaEth',
      'AaveV3Sonic',
      'AaveV3Scroll',
      'AaveV3ZkSync',
      'AaveV3Metis',
      'AaveV3Soneium',
    ],
    title: 'Low Adoption Asset Deprecation on Aave V3',
    shortName: 'LowAdoptionAssetDeprecationOnAaveV3',
    date: '20260826',
    author: 'Llama Risk (implemented by Aave Labs)',
    discussion:
      'https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401',
    snapshot:
      'https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        FREEZE: [
          {asset: 'FBTC', shouldBeFrozen: true},
          {asset: 'ezETH', shouldBeFrozen: true},
          {asset: 'eUSDe', shouldBeFrozen: true},
          {asset: 'ETHx', shouldBeFrozen: true},
          {asset: 'CRV', shouldBeFrozen: true},
          {asset: 'UNI', shouldBeFrozen: true},
          {asset: 'ONE_INCH', shouldBeFrozen: true},
          {asset: 'crvUSD', shouldBeFrozen: true},
          {asset: 'ENS', shouldBeFrozen: true},
          {asset: 'SNX', shouldBeFrozen: true},
          {asset: 'sDAI', shouldBeFrozen: true},
          {asset: 'PT_eUSDE_29MAY2025', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_31JUL2025', shouldBeFrozen: true},
          {asset: 'PT_USDe_31JUL2025', shouldBeFrozen: true},
          {asset: 'PT_eUSDE_14AUG2025', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_25SEP2025', shouldBeFrozen: true},
          {asset: 'PT_USDe_25SEP2025', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_27NOV2025', shouldBeFrozen: true},
          {asset: 'PT_USDe_27NOV2025', shouldBeFrozen: true},
          {asset: 'PT_USDe_5FEB2026', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_5FEB2026', shouldBeFrozen: true},
          {asset: 'PT_srUSDe_2APR2026', shouldBeFrozen: true},
          {asset: 'PT_USDe_7MAY2026', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_7MAY2026', shouldBeFrozen: true},
          {asset: 'PT_USDG_28MAY2026', shouldBeFrozen: true},
          {asset: 'PT_srUSDe_25JUN2026', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'FBTC', supplyCap: '1', borrowCap: ''},
          {asset: 'ezETH', supplyCap: '1', borrowCap: '1'},
          {asset: 'CRV', supplyCap: '1', borrowCap: ''},
          {asset: 'UNI', supplyCap: '1', borrowCap: ''},
          {asset: 'ONE_INCH', supplyCap: '1', borrowCap: ''},
          {asset: 'ENS', supplyCap: '1', borrowCap: ''},
          {asset: 'sDAI', supplyCap: '', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'FBTC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '75',
          },
          {
            asset: 'ETHx',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'CRV',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'UNI',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'ONE_INCH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'crvUSD',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'MKR',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'ENS',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'SNX',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
        ],
      },
      cache: {blockNumber: 25837412},
    },
    AaveV3EthereumLido: {
      configs: {
        FREEZE: [
          {asset: 'ezETH', shouldBeFrozen: true},
          {asset: 'USDS', shouldBeFrozen: true},
          {asset: 'sUSDe', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'ezETH', supplyCap: '1', borrowCap: ''},
          {asset: 'sUSDe', supplyCap: '1', borrowCap: ''},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'USDS',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 25837412},
    },
    AaveV3Arbitrum: {
      configs: {
        FREEZE: [
          {asset: 'DAI', shouldBeFrozen: true},
          {asset: 'rETH', shouldBeFrozen: true},
          {asset: 'tBTC', shouldBeFrozen: true},
          {asset: 'USDC', shouldBeFrozen: true},
          {asset: 'ezETH', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'DAI', supplyCap: '1', borrowCap: '1'},
          {asset: 'rETH', supplyCap: '1', borrowCap: ''},
          {asset: 'tBTC', supplyCap: '1', borrowCap: ''},
          {asset: 'USDC', supplyCap: '1', borrowCap: '1'},
          {asset: 'ezETH', supplyCap: '1', borrowCap: ''},
          {asset: 'EURS', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'DAI',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'rETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'USDC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '75',
          },
          {
            asset: 'EURS',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 498482602},
    },
    AaveV3Plasma: {
      configs: {
        FREEZE: [
          {asset: 'WETH', shouldBeFrozen: true},
          {asset: 'weETH', shouldBeFrozen: true},
          {asset: 'PT_USDe_15JAN2026', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_15JAN2026', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_9APR2026', shouldBeFrozen: true},
          {asset: 'PT_USDe_9APR2026', shouldBeFrozen: true},
          {asset: 'PT_USDe_18JUN2026', shouldBeFrozen: true},
          {asset: 'PT_sUSDE_18JUN2026', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'weETH', supplyCap: '1', borrowCap: ''},
          {asset: 'wstETH', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'WETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'wstETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 30782965},
    },
    AaveV3Base: {
      configs: {
        FREEZE: [
          {asset: 'tBTC', shouldBeFrozen: true},
          {asset: 'ezETH', shouldBeFrozen: true},
          {asset: 'USDbC', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'tBTC', supplyCap: '1', borrowCap: ''},
          {asset: 'ezETH', supplyCap: '1', borrowCap: ''},
          {asset: 'USDbC', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'tBTC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'USDbC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '75',
          },
        ],
      },
      cache: {blockNumber: 50467089},
    },
    AaveV3Polygon: {
      configs: {
        FREEZE: [
          {asset: 'USDC', shouldBeFrozen: true},
          {asset: 'EURS', shouldBeFrozen: true},
          {asset: 'MaticX', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'USDC', supplyCap: '1', borrowCap: '1'},
          {asset: 'MaticX', supplyCap: '1', borrowCap: ''},
          {asset: 'jEUR', supplyCap: '1', borrowCap: '1'},
          {asset: 'stMATIC', supplyCap: '1', borrowCap: '1'},
          {asset: 'EURA', supplyCap: '1', borrowCap: '1'},
          {asset: 'DPI', supplyCap: '1', borrowCap: '1'},
          {asset: 'SUSHI', supplyCap: '1', borrowCap: '1'},
          {asset: 'CRV', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'USDC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '85',
          },
          {
            asset: 'MaticX',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'jEUR',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'EURA',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'DPI',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'SUSHI',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'CRV',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 92679000},
    },
    AaveV3Avalanche: {
      configs: {
        FREEZE: [
          {asset: 'LINKe', shouldBeFrozen: true},
          {asset: 'AAVEe', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'WBTCe', supplyCap: '1', borrowCap: '1'},
          {asset: 'LINKe', supplyCap: '1', borrowCap: ''},
          {asset: 'AAVEe', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'WBTCe',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'LINKe',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 93706889},
    },
    AaveV3Optimism: {
      configs: {
        FREEZE: [
          {asset: 'USDC', shouldBeFrozen: true},
          {asset: 'DAI', shouldBeFrozen: true},
          {asset: 'rETH', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'USDC', supplyCap: '1', borrowCap: ''},
          {asset: 'DAI', supplyCap: '1', borrowCap: '1'},
          {asset: 'rETH', supplyCap: '1', borrowCap: ''},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'USDC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '75',
          },
          {
            asset: 'DAI',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'rETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 156062375},
    },
    AaveV3Gnosis: {
      configs: {
        FREEZE: [{asset: 'WETH', shouldBeFrozen: true}],
        CAPS_UPDATE: [{asset: 'WETH', supplyCap: '1', borrowCap: '1'}],
        BORROWS_UPDATE: [
          {
            asset: 'WETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'USDC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
        ],
      },
      cache: {blockNumber: 47919245},
    },
    AaveV3BNB: {
      configs: {
        FREEZE: [
          {asset: 'wstETH', shouldBeFrozen: true},
          {asset: 'FDUSD', shouldBeFrozen: true},
          {asset: 'Cake', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'FDUSD', supplyCap: '1', borrowCap: '1'},
          {asset: 'Cake', supplyCap: '1', borrowCap: ''},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'wstETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'FDUSD',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
          {
            asset: 'Cake',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 118138918},
    },
    AaveV3MegaEth: {
      configs: {
        FREEZE: [
          {asset: 'ezETH', shouldBeFrozen: true},
          {asset: 'USDT0', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [{asset: 'USDT0', supplyCap: '1', borrowCap: '1'}],
        BORROWS_UPDATE: [
          {
            asset: 'USDT0',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
          },
        ],
      },
      cache: {blockNumber: 24926517},
    },
    AaveV3Sonic: {
      configs: {
        FREEZE: [
          {asset: 'USDC', shouldBeFrozen: true},
          {asset: 'wS', shouldBeFrozen: true},
          {asset: 'stS', shouldBeFrozen: true},
          {asset: 'WETH', shouldBeFrozen: true},
        ],
        CAPS_UPDATE: [
          {asset: 'USDC', supplyCap: '1', borrowCap: '1'},
          {asset: 'wS', supplyCap: '1', borrowCap: '1'},
          {asset: 'stS', supplyCap: '1', borrowCap: ''},
          {asset: 'WETH', supplyCap: '1', borrowCap: '1'},
        ],
        BORROWS_UPDATE: [
          {
            asset: 'USDC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
          {
            asset: 'wS',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
          {
            asset: 'WETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
        ],
        RATE_UPDATE_V3: [
          {
            asset: 'USDC',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'wS',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'WETH',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
        ],
      },
      cache: {blockNumber: 78180833},
    },
    AaveV3Scroll: {
      configs: {
        BORROWS_UPDATE: [
          {
            asset: 'WETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
          {
            asset: 'weETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
          {
            asset: 'wstETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
          {
            asset: 'USDC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
          {
            asset: 'SCR',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '99',
          },
        ],
        RATE_UPDATE_V3: [
          {
            asset: 'WETH',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'weETH',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'wstETH',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'USDC',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'SCR',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '5',
              variableRateSlope1: '',
              variableRateSlope2: '',
            },
          },
        ],
      },
      cache: {blockNumber: 34797720},
    },
    AaveV3ZkSync: {configs: {OTHERS: {}}, cache: {blockNumber: 71724909}},
    AaveV3Metis: {configs: {OTHERS: {}}, cache: {blockNumber: 23074556}},
    AaveV3Soneium: {configs: {OTHERS: {}}, cache: {blockNumber: 27294389}},
  },
};
