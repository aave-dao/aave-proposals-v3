import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: ['AaveV3InkWhitelabel'],
    title: 'Activate Rates and Caps Agent on Ink',
    shortName: 'ActivateRatesAndCapsAgentOnInk',
    date: '20260219',
    author: 'BGD Labs (@bgdlabs)',
  },
  poolOptions: {AaveV3InkWhitelabel: {configs: {OTHERS: {}}, cache: {blockNumber: 38001298}}},
};
