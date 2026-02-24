import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    author: 'BGD Labs @bgdlabs',
    pools: ['AaveV3Ethereum', 'AaveV3Arbitrum', 'AaveV3Base'],
    title: 'Enable SVR on Base and Arbitrum',
    shortName: 'EnableSVROnBaseAndArbitrum',
    date: '20260224',
    discussion: '',
    snapshot: '',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {
    AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 24527956}},
    AaveV3Arbitrum: {configs: {OTHERS: {}}, cache: {blockNumber: 435530665}},
    AaveV3Base: {configs: {OTHERS: {}}, cache: {blockNumber: 42580570}},
  },
};
