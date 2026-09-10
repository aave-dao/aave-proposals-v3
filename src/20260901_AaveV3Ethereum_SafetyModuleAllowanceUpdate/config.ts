import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260901_AaveV3Ethereum_SafetyModuleAllowanceUpdate/config.ts',
    markets: ['AaveV3Ethereum'],
    title: 'Safety Module August 2026 - Allowance Update',
    shortName: 'SafetyModuleAllowanceUpdate',
    date: '20260901',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-safety-module-august-2026-allowance-update/25550',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 25880238}}},
};
