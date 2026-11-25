import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Ethereum'],
    title: 'Aave Institutional - OTC Facilitator',
    shortName: 'AaveInstitutionalOTCFacilitator',
    date: '20261027',
    author: 'TokenLogic',
    discussion: 'https://governance.aave.com/t/arfc-aave-institutional/25692',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0x194bd11500117aa7e0940bd0886a421a7658888af2cd04d82e07848afb8e3b79',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {AaveV3Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26287087}}},
};
