import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261118_Multi_November2026FundingUpdate/config.ts',
    update: true,
    markets: [
      'AaveV3Ethereum',
      'AaveV3Plasma',
      'AaveV3Monad',
      'AaveV3Arbitrum',
      'AaveV3Mantle',
      'AaveV3Gnosis',
      'AaveV3Sonic',
    ],
    title: 'November 2026 Funding Update',
    shortName: 'November2026FundingUpdate',
    date: '20261118',
    author: 'TokenLogic',
    discussion: 'https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26501265}},
    AaveV3Plasma: {configs: {OTHERS: {}}, cache: {blockNumber: 38745731}},
    AaveV3Monad: {configs: {OTHERS: {}}, cache: {blockNumber: 125651484}},
    AaveV3Arbitrum: {configs: {OTHERS: {}}, cache: {blockNumber: 527804174}},
    AaveV3Mantle: {configs: {OTHERS: {}}, cache: {blockNumber: 103794418}},
    AaveV3Gnosis: {configs: {OTHERS: {}}, cache: {blockNumber: 49345689}},
    AaveV3Sonic: {configs: {OTHERS: {}}, cache: {blockNumber: 83173631}},
  },
};
