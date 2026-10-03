import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260907_Multi_AugustSeptember2026FundingUpdate/config.ts',
    markets: ['AaveV3Ethereum', 'AaveV3Base', 'AaveV3Monad', 'AaveV3Plasma'],
    title: 'August/September 2026 Funding Update',
    shortName: 'AugustSeptember2026FundingUpdate',
    date: '20260907',
    author: 'TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 25927734}},
    AaveV3Base: {configs: {OTHERS: {}}, cache: {blockNumber: 51612000}},
    AaveV3Monad: {configs: {OTHERS: {}}, cache: {blockNumber: 107787000}},
    AaveV3Plasma: {configs: {OTHERS: {}}, cache: {blockNumber: 32456523}},
  },
};
