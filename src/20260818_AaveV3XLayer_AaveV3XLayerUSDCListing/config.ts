import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260818_AaveV3XLayer_AaveV3XLayerUSDCListing/config.ts',
    markets: ['AaveV3XLayer'],
    title: 'Onboard USDC to Aave V3 X Layer',
    shortName: 'AaveV3XLayerUSDCListing',
    date: '20260818',
    author: '@TokenLogic',
    discussion: 'https://governance.aave.com/t/direct-to-aip-asset-listing-usdc-x-layer/25467',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3XLayer: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'USDC',
            decimals: 6,
            priceFeed: '0x26AD1207EAA39F74FAC725599ce1c431C80eF6cC',
            ltv: '75',
            liqThreshold: '78',
            liqBonus: '7.5',
            liqProtocolFee: '10',
            enabledToBorrow: 'ENABLED',
            flashloanable: 'ENABLED',
            reserveFactor: '10',
            supplyCap: '35000000',
            borrowCap: '32000000',
            rateStrategyParams: {
              optimalUtilizationRate: '90',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '4',
              variableRateSlope2: '40',
            },
            asset: '0xB6CEceAB302E2E4948951eE7843FC24E92933061',
            admin: '',
          },
        ],
        EMODES_ASSETS: [
          {
            asset: 'USDC',
            eModeCategory: 'AaveV3XLayerEModes.xBTC__USDT_USDG_GHO',
            collateral: 'DISABLED',
            borrowable: 'ENABLED',
            ltvzero: 'DISABLED',
          },
          {
            asset: 'USDC',
            eModeCategory: 'AaveV3XLayerEModes.xETH__USDT_USDG_GHO',
            collateral: 'DISABLED',
            borrowable: 'ENABLED',
            ltvzero: 'DISABLED',
          },
          {
            asset: 'USDC',
            eModeCategory: 'AaveV3XLayerEModes.xSOL__USDT_USDG_GHO',
            collateral: 'DISABLED',
            borrowable: 'ENABLED',
            ltvzero: 'DISABLED',
          },
          {
            asset: 'USDC',
            eModeCategory: 'AaveV3XLayerEModes.WOKB__USDT_USDG_GHO',
            collateral: 'DISABLED',
            borrowable: 'ENABLED',
            ltvzero: 'DISABLED',
          },
          {
            asset: 'USDC',
            eModeCategory: '7',
            collateral: 'DISABLED',
            borrowable: 'ENABLED',
            ltvzero: 'DISABLED',
          },
        ],
      },
      cache: {blockNumber: 69442624},
    },
  },
};
