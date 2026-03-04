import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    pools: ['AaveV3InkWhitelabel'],
    title: 'Stablecoin Interest Rate Adjustment',
    shortName: 'StablecoinInterestRateAdjustment',
    date: '20260304',
    author: 'ACI',
  },
  poolOptions: {
    AaveV3InkWhitelabel: {
      configs: {
        RATE_UPDATE_V3: [
          {
            asset: 'USDT',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '',
              variableRateSlope1: '4',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'USDG',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '',
              variableRateSlope1: '4',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'USDC',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '',
              variableRateSlope1: '4',
              variableRateSlope2: '',
            },
          },
          {
            asset: 'USDe',
            params: {
              optimalUtilizationRate: '',
              baseVariableBorrowRate: '',
              variableRateSlope1: '4',
              variableRateSlope2: '',
            },
          },
        ],
      },
      cache: {blockNumber: 39160690},
    },
  },
};
