import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: ['AaveV3InkWhitelabel'],
    title: 'Change Ink SolvBTC debt ceiling',
    shortName: 'ChangeInkSolvBTCDebtCeiling',
    date: '20260228',
    author: 'ACI',
  },
  poolOptions: {AaveV3InkWhitelabel: {configs: {}, cache: {blockNumber: 38737734}}},
};
