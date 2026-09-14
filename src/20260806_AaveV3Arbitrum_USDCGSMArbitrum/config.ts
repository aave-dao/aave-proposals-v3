import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Arbitrum'],
    title: 'USDC Native GSM Arbitrum',
    shortName: 'USDCGSMArbitrum_20260806',
    date: '20260806',
    author: '@TokenLogic',
    discussion: 'https://governance.aave.com/t/arfc-launch-remotegsm-on-arbitrum/24986',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0xf24321514fb593af9e5082d26a1358819ec0f648db8fdb5c2b083f53ef785793',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Arbitrum: {configs: {OTHERS: {}}, cache: {blockNumber: 491792569}}},
};
