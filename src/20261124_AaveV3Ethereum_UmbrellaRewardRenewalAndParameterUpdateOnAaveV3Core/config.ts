import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile:
      'src/20261124_AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core/config.ts',
    force: true,
    markets: ['AaveV3Ethereum'],
    title: 'Umbrella Reward Renewal and Parameter Update on Aave V3 Core',
    shortName: 'UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core',
    date: '20261124',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-umbrella-reward-renewal-and-parameter-update-on-aave-v3-core/26462',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26484891}}},
};
