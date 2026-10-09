import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Monad'],
    title: 'Onboard PT-AUSD-17DEC2026 to the LlamaRisk PT Risk Oracle',
    shortName: 'Onboard_PTAUSD17DEC2026_Oracle',
    date: '20261002',
    author: 'LlamaRisk',
    discussion:
      'https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/6?u=llamarisk',
    snapshot: 'direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Monad: {configs: {OTHERS: {}}, cache: {blockNumber: 109947773}}},
};
