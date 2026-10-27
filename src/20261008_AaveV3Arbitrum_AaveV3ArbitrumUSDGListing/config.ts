import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261008_AaveV3Arbitrum_AaveV3ArbitrumUSDGListing/config.ts',
    markets: ['AaveV3Arbitrum'],
    title: 'Onboard USDG to Aave V3 Arbitrum',
    shortName: 'AaveV3ArbitrumUSDGListing',
    date: '20261008',
    author: '@TokenLogic',
    discussion: 'https://governance.aave.com/t/direct-to-aip-asset-listing-usdg-arbitrum/25811',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Arbitrum: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'USDG',
            decimals: 6,
            priceFeed: '0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D',
            ltv: '0',
            liqThreshold: '0',
            liqBonus: '0',
            liqProtocolFee: '10',
            enabledToBorrow: 'ENABLED',
            flashloanable: 'ENABLED',
            reserveFactor: '10',
            supplyCap: '30000000',
            borrowCap: '27000000',
            rateStrategyParams: {
              optimalUtilizationRate: '90',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '4.5',
              variableRateSlope2: '30',
            },
            asset: '0x004B506865409877C9fA29bfb1ebA929984B9bbC',
            admin: '',
          },
        ],
      },
      cache: {blockNumber: 518408593},
    },
  },
};
