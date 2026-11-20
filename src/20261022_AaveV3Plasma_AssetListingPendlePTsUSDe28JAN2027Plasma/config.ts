import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261022_AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma/config.ts',
    markets: ['AaveV3Plasma'],
    title: 'Asset Listing - Pendle PT-sUSDe-28JAN2027 Plasma',
    shortName: 'AssetListingPendlePTsUSDe28JAN2027Plasma',
    date: '20261022',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Plasma: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'PT_sUSDE_28JAN2027',
            decimals: 18,
            priceFeed: '0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f',
            ltv: '0',
            liqThreshold: '0',
            liqBonus: '0',
            liqProtocolFee: '10',
            enabledToBorrow: 'DISABLED',
            flashloanable: 'DISABLED',
            reserveFactor: '45',
            supplyCap: '25000000',
            borrowCap: '1',
            rateStrategyParams: {
              optimalUtilizationRate: '45',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '10',
              variableRateSlope2: '300',
            },
            asset: '0x257561233419039BeC3a28be717d14B4f490883D',
            admin: '',
          },
        ],
        EMODES_CREATION: [
          {
            ltv: '90',
            liqThreshold: '92',
            liqBonus: '4.95',
            label: 'sUSDe_PT_sUSDe_28JAN2027__Stablecoins',
            isolated: 'DISABLED',
            collateralAssets: ['sUSDe', 'PT_sUSDE_28JAN2027', 'PT_sUSDE_22OCT2026'],
            borrowableAssets: ['USDT0', 'USDe', 'GHO'],
          },
        ],
      },
      cache: {blockNumber: 37634563},
    },
  },
};
