import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: [
      'AaveV3Ethereum',
      'AaveV3Polygon',
      'AaveV3Avalanche',
      'AaveV3BNB',
      'AaveV3Monad',
      'AaveV3Gnosis',
    ],
    title: 'Maintenance: Replace LayerZero bridge adapter on a.DI',
    shortName: 'MaintenanceReplaceLayerZeroOnADI',
    date: '20261111',
    author: 'Aave Labs',
    discussion: '',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26387256}},
    AaveV3Polygon: {configs: {OTHERS: {}}, cache: {blockNumber: 97094199}},
    AaveV3Avalanche: {configs: {OTHERS: {}}, cache: {blockNumber: 99970215}},
    AaveV3BNB: {configs: {OTHERS: {}}, cache: {blockNumber: 132849778}},
    AaveV3Monad: {configs: {OTHERS: {}}, cache: {blockNumber: 121143481}},
    AaveV3Gnosis: {configs: {OTHERS: {}}, cache: {blockNumber: 49213777}},
  },
};
