import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3XLayer'],
    title: 'Onboard PT-USDG-25FEB2027 to the LlamaRisk PT Risk Oracle',
    shortName: 'Onboard_PTUSDG25FEB2027_Oracle',
    date: '20261021',
    author: 'LlamaRisk',
    discussion:
      'https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/7?u=llamarisk',
    snapshot: 'direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3XLayer: {configs: {OTHERS: {}}, cache: {blockNumber: 73808231}}},
};
