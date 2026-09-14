import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260821_AaveV3XLayer_WhitelistXLayerFlashBorrower/config.ts',
    markets: ['AaveV3XLayer'],
    title: 'Add X Layer Loop Tool & Margin Trading to FlashBorrowers',
    shortName: 'WhitelistXLayerFlashBorrower',
    date: '20260821',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-add-x-layer-loop-tool-margin-trading-to-flashborrowers/25551',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3XLayer: {
      configs: {FLASH_BORROWER: {address: '0xAF1Fe8819F8e953391447A3fD3f27Db5b13b9f4d'}},
      cache: {blockNumber: 70027000},
    },
  },
};
