import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Arbitrum'],
    title: 'Caps Rate Limiter Activation',
    shortName: 'CapsRateLimiterActivation',
    date: '20261126',
    author: 'LlamaRisk',
    discussion: 'https://governance.aave.com/t/arfc-dynamic-caps-oracle-rate-limiter/26219',
    snapshot:
      'https://snapshot.box/#/s:aavedao.eth/proposal/0xd80bf15385e4f525108133bee1460b1907aabd1013b67821936fd52f3140793d',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Arbitrum: {configs: {OTHERS: {}}, cache: {blockNumber: 527782941}}},
};
