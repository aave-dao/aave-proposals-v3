import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/config.ts',
    markets: [
      'AaveV3Ethereum',
      'AaveV3EthereumLido',
      'AaveV3Polygon',
      'AaveV3Avalanche',
      'AaveV3Arbitrum',
      'AaveV3Base',
      'AaveV3Gnosis',
      'AaveV3BNB',
      'AaveV3Linea',
      'AaveV3Plasma',
    ],
    title: 'Update CoW Swap Adapters flashBorrowers',
    shortName: 'UpdateCoWSwapAdaptersFlashBorrowers',
    date: '20261028',
    author: 'Aave Labs',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-whitelist-new-cow-protocol-adapters-as-flash-borrowers-on-aave-v3-v4/25931',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 26292808},
    },
    AaveV3EthereumLido: {
      configs: {FLASH_BORROWER: {address: '0xFdFA036213C375808135744E865767FD90897F0A'}},
      cache: {blockNumber: 26292808},
    },
    AaveV3Polygon: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 96336080},
    },
    AaveV3Avalanche: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 98795526},
    },
    AaveV3Arbitrum: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 519114827},
    },
    AaveV3Base: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 53210075},
    },
    AaveV3Gnosis: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 48990091},
    },
    AaveV3BNB: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 130323475},
    },
    AaveV3Linea: {
      configs: {FLASH_BORROWER: {address: '0x3171FC716942a40DEDe8dD0B7885dd9f44eca176'}},
      cache: {blockNumber: 32455528},
    },
    AaveV3Plasma: {
      configs: {FLASH_BORROWER: {address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83'}},
      cache: {blockNumber: 36268094},
    },
  },
};
