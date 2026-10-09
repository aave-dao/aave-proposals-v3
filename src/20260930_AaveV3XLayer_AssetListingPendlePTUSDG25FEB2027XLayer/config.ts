import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260930_AaveV3XLayer_AssetListingPendlePTUSDG25FEB2027XLayer/config.ts',
    force: true,
    markets: ['AaveV3XLayer'],
    title: 'Asset Listing - Pendle PT-USDG-25FEB2027 X Layer',
    shortName: 'AssetListingPendlePTUSDG25FEB2027XLayer',
    date: '20260930',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3XLayer: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'PT_USDG_25FEB2027',
            decimals: 6,
            priceFeed: '0xB81f0B2cCAC262288fED924DA750CFc7CC450530',
            ltv: '0',
            liqThreshold: '0',
            liqBonus: '0',
            liqProtocolFee: '10',
            enabledToBorrow: 'DISABLED',
            flashloanable: 'ENABLED',
            reserveFactor: '20',
            supplyCap: '35000000',
            borrowCap: '1',
            rateStrategyParams: {
              optimalUtilizationRate: '45',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '10',
              variableRateSlope2: '300',
            },
            asset: '0x5ea1f184af5ced57725213d8267b5c4c834557d4',
            admin: '',
          },
        ],
        EMODES_CREATION: [
          {
            ltv: '91.48',
            liqThreshold: '93.48',
            liqBonus: '2.62',
            label: 'PT_USDG_25FEB2027__Stablecoins',
            isolated: 'DISABLED',
            collateralAssets: ['PT_USDG_25FEB2027', 'PT_USDG_29OCT2026'],
            borrowableAssets: ['USDT', 'GHO', 'USDC'],
          },
        ],
      },
      cache: {blockNumber: 72750800},
    },
  },
};
