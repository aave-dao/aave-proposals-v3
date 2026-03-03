import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    author: 'Aavechan Initiative @aci',
    pools: ['AaveV3Ethereum'],
    title: 'ACI Is Leaving Aave',
    shortName: 'ACIIsLeavingAave',
    date: '20260302',
    discussion: '',
    snapshot: 'direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 24572457}}},
};
