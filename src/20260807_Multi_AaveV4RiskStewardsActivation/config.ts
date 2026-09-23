import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV4Ethereum', 'AaveV4Avalanche', 'AaveV4Base'],
    title: 'Aave V4 Risk Stewards Activation',
    shortName: 'AaveV4RiskStewardsActivation',
    date: '20260807',
    author: 'Aave Labs',
    discussion: 'https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0xf736fa5f6dd1532d0e2825fe528262479949a923427989384e313490ca9d9f18',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV4Ethereum: {configs: {OTHERS: {}}, cache: {blockNumber: 26032000}},
    AaveV4Avalanche: {configs: {OTHERS: {}}, cache: {blockNumber: 92229650}},
    AaveV4Base: {configs: {OTHERS: {}}, cache: {blockNumber: 51698800}},
  },
};
