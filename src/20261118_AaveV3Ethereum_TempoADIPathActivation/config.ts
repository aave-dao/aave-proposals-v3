import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261118_AaveV3Ethereum_TempoADIPathActivation/config.ts',
    markets: ['AaveV3Ethereum'],
    title: 'Tempo a.DI path activation',
    shortName: 'TempoADIPathActivation',
    date: '20261118',
    author: 'Aave Labs',
    // TODO(tempo): forum link
    discussion: 'TODO',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26441765}}},
};
