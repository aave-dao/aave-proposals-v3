import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: ['AaveV3InkWhitelabel'],
    title: 'Transfer Collector Revenue',
    shortName: 'TransferCollectorRevenue',
    date: '20260304',
    author: 'ACI',
  },
  poolOptions: {AaveV3InkWhitelabel: {configs: {OTHERS: {}}, cache: {blockNumber: 39167733}}},
};
