import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: ['AaveV3ZkSync'],
    title: 'Focussing the Aave V3 Multichain Strategy - Phase 1bis',
    shortName: 'FocussingTheAaveV3MultichainStrategyPhase1bis',
    date: '20260224',
    author: 'ACI',
    discussion:
      'https://governance.aave.com/t/arfc-focussing-the-aave-v3-multichain-strategy-phase-1/23954',
    snapshot:
      'https://snapshot.org/#/aavedao.eth/proposal/0x62340121a7428f902f3232030350eb2d2bb753dc10ab0657a16ffd4d85cb530b',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {AaveV3ZkSync: {configs: {OTHERS: {}}, cache: {blockNumber: 68739788}}},
};
