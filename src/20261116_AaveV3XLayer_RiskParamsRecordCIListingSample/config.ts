import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    title: 'Risk Params Record CI Listing Sample',
    author: 'Aave Labs',
    snapshot: 'Direct-to-AIP',
    markets: ['AaveV3XLayer'],
    discussion:
      'https://governance.aave.com/t/direct-to-aip-onboard-pt-usdg-25feb2027-on-x-layer/25733',
    votingNetwork: 'AVALANCHE',
    shortName: 'RiskParamsRecordCIListingSample',
    date: '20261116',
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
            supplyCap: '30000000',
            borrowCap: '1',
            rateStrategyParams: {
              optimalUtilizationRate: '45',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '10',
              variableRateSlope2: '300',
            },
            asset: '0x5ea1f184af5ced57725213d8267b5c4c834557d4',
            seedAmount: '100e6',
          },
        ],
        EMODES_CREATION: [
          {
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '2.5',
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
