import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Plasma'],
    title: 'Onboard PT-sUSDe-22OCT2026 to the LlamaRisk PT Risk Oracle',
    shortName: 'Onboard_PTsUSDe22OCT2026_Oracle',
    date: '20260925',
    author: 'LlamaRisk',
    discussion:
      'https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/5?u=llamarisk',
    snapshot: 'direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Plasma: {configs: {OTHERS: {}}, cache: {blockNumber: 33398691}}},
};
