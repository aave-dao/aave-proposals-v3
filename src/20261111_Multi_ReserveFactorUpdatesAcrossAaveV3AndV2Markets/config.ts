import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/config.ts',
    update: true,
    force: true,
    markets: [
      'AaveV3Ethereum',
      'AaveV3EthereumLido',
      'AaveV3Plasma',
      'AaveV3Base',
      'AaveV3Arbitrum',
      'AaveV3Avalanche',
      'AaveV3Polygon',
      'AaveV3BNB',
      'AaveV3XLayer',
      'AaveV3Optimism',
      'AaveV3Gnosis',
      'AaveV3Linea',
      'AaveV2Ethereum',
      'AaveV2Avalanche',
    ],
    title: 'Reserve Factor Updates Across Aave V3 and V2 Markets',
    shortName: 'ReserveFactorUpdatesAcrossAaveV3AndV2Markets',
    date: '20261111',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-reserve-factor-updates-across-aave-v3-and-v2-markets/26249',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '30',
            asset: 'DAI',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'WBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'cbBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'wstETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'LINK',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'weETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'tBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'FBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'cbETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'rETH',
          },
        ],
      },
      cache: {blockNumber: 26393644},
    },
    AaveV3EthereumLido: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'wstETH',
          },
        ],
      },
      cache: {blockNumber: 26393644},
    },
    AaveV3Plasma: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '7.5',
            asset: 'USDT0',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '35',
            asset: 'USDe',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '10',
            asset: 'GHO',
          },
        ],
      },
      cache: {blockNumber: 37480349},
    },
    AaveV3Base: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'cbBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'cbETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'wstETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'weETH',
          },
        ],
      },
      cache: {blockNumber: 56166750},
    },
    AaveV3Arbitrum: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'WBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'ARB',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'LINK',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'weETH',
          },
        ],
      },
      cache: {blockNumber: 523360441},
    },
    AaveV3Avalanche: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '25',
            asset: 'USDC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'WAVAX',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '25',
            asset: 'USDt',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '90',
            asset: 'DAIe',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'WETHe',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'BTCb',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'WBTCe',
          },
        ],
      },
      cache: {blockNumber: 100047514},
    },
    AaveV3Polygon: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '30',
            asset: 'USDT0',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '25',
            asset: 'USDCn',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '70',
            asset: 'DAI',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '25',
            asset: 'WETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'WPOL',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'WBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'wstETH',
          },
        ],
      },
      cache: {blockNumber: 97145514},
    },
    AaveV3BNB: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '25',
            asset: 'ETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'BTCB',
          },
        ],
      },
      cache: {blockNumber: 133020760},
    },
    AaveV3XLayer: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'xBTC',
          },
        ],
      },
      cache: {blockNumber: 75654691},
    },
    AaveV3Optimism: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '15',
            asset: 'USDCn',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '20',
            asset: 'WETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '15',
            asset: 'USDT',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'WBTC',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
            asset: 'wstETH',
          },
        ],
      },
      cache: {blockNumber: 159412475},
    },
    AaveV3Gnosis: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '15',
            asset: 'EURe',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '20',
            asset: 'USDCe',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '50',
            asset: 'GNO',
          },
        ],
      },
      cache: {blockNumber: 49228906},
    },
    AaveV3Linea: {
      configs: {
        BORROWS_UPDATE: [
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '20',
            asset: 'WETH',
          },
          {
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '15',
            asset: 'USDC',
          },
        ],
      },
      cache: {blockNumber: 32577924},
    },
    AaveV2Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26393644}},
    AaveV2Avalanche: {configs: {OTHERS: {}}, cache: {blockNumber: 100047514}},
  },
};
