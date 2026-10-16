import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: [
      'AaveV3Ethereum',
      'AaveV3Arbitrum',
      'AaveV3Avalanche',
      'AaveV3Base',
      'AaveV3Gnosis',
      'AaveV3Mantle',
      'AaveV3Plasma',
      'AaveV3Monad',
      'AaveV3XLayer',
      'AaveV3Ink',
    ],
    title: 'Remote GSM Launch: XLayer',
    shortName: 'RemoteGSMLaunchXLayer',
    date: '20260729',
    author: 'TokenLogic',
    discussion: 'https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {
    AaveV3Ethereum: {configs: {}, cache: {blockNumber: 25731136}},
    AaveV3Arbitrum: {configs: {OTHERS: {}}, cache: {blockNumber: 493392463}},
    AaveV3Avalanche: {configs: {OTHERS: {}}, cache: {blockNumber: 92551188}},
    AaveV3Base: {configs: {OTHERS: {}}, cache: {blockNumber: 49827271}},
    AaveV3Gnosis: {configs: {OTHERS: {}}, cache: {blockNumber: 47668794}},
    AaveV3Mantle: {configs: {OTHERS: {}}, cache: {blockNumber: 99156810}},
    AaveV3Plasma: {configs: {OTHERS: {}}, cache: {blockNumber: 29503521}},
    AaveV3Monad: {configs: {OTHERS: {}}, cache: {blockNumber: 95037063}},
    AaveV3XLayer: {configs: {OTHERS: {}}, cache: {blockNumber: 67674936}},
    AaveV3Ink: {configs: {OTHERS: {}}, cache: {blockNumber: 52945574}},
  },
};
