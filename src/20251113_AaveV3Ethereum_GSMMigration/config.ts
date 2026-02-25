import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: ['AaveV3Ethereum'],
    title: 'GSM Migration',
    shortName: 'GSMMigration',
    date: '20251113',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/arfc-launch-gho-on-plasma-set-aci-as-emissions-manager-for-rewards/22994/8',
    snapshot:
      'https://snapshot.box/#/s:aavedao.eth/proposal/0xeb3572580924976867073ad9c8012cb9e52093c76dafebd7d3aebf318f2576fb',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 24347697}}},
};
