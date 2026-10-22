import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Ethereum', 'AaveV4Ethereum'],
    title: 'Mainnet GSM migration',
    shortName: 'MainnetGSMMigration',
    date: '20261022',
    author: 'TokenLogic',
    discussion: 'TODO',
    snapshot: 'TODO',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26248572}},
    AaveV4Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26248572}},
  },
};
