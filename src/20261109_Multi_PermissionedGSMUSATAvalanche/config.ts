import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: [
      'AaveV3Ethereum',
      'AaveV3Avalanche',
      'AaveV3Arbitrum',
      'AaveV3Base',
      'AaveV3Gnosis',
      'AaveV3Mantle',
      'AaveV3Plasma',
      'AaveV3XLayer',
      'AaveV3Ink',
      'AaveV3Monad',
    ],
    title: 'Permissioned GSM: USAT on Aave V4 Avalanche',
    shortName: 'PermissionedGSMUSATAvalanche',
    date: '20261109',
    author: 'TokenLogic',
    discussion: 'https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {
    AaveV3Ethereum: {configs: {}, cache: {blockNumber: 26405330}},
    AaveV3Avalanche: {configs: {}, cache: {blockNumber: 101345000}},
    AaveV3Arbitrum: {configs: {}, cache: {blockNumber: 523822200}},
    AaveV3Base: {configs: {}, cache: {blockNumber: 56854300}},
    AaveV3Gnosis: {configs: {}, cache: {blockNumber: 49255900}},
    AaveV3Mantle: {configs: {}, cache: {blockNumber: 103215400}},
    AaveV3Plasma: {configs: {}, cache: {blockNumber: 37617800}},
    AaveV3XLayer: {configs: {}, cache: {blockNumber: 75792200}},
    AaveV3Ink: {configs: {}, cache: {blockNumber: 61062800}},
    AaveV3Monad: {configs: {}, cache: {blockNumber: 121848000}},
  },
};
