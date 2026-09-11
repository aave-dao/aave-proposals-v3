import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    markets: ['AaveV3Mantle'],
    title: 'Aave V3 Mantle – XAUt Listing',
    shortName: 'XAUtListing',
    date: '20260805',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-aave-v3-mantle-collateral-enablement-emode-expansion-and-isolation-updates-usdt0-usde-eth-xaut/24153',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Mantle: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'XAUt',
            decimals: 6,
            priceFeed: '0x23A1105fd2C26BCc9EA691725Bbda3f5F1bC0b78',
            ltv: '0',
            liqThreshold: '0',
            liqBonus: '0',
            liqProtocolFee: '10',
            enabledToBorrow: 'DISABLED',
            flashloanable: 'ENABLED',
            reserveFactor: '20',
            supplyCap: '4000',
            borrowCap: '1',
            rateStrategyParams: {
              optimalUtilizationRate: '45',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '10',
              variableRateSlope2: '300',
            },
            asset: '0x6199ccd9273a1e0e41e2cc18d9dacd1e9382f58e',
            admin: '',
          },
        ],
        EMODES_CREATION: [
          {
            ltv: '70',
            liqThreshold: '75',
            liqBonus: '6',
            label: 'XAUt Stablecoins',
            isolated: 'DISABLED',
            collateralAssets: ['XAUt'],
            borrowableAssets: ['USDT0', 'USDC', 'GHO'],
          },
        ],
      },
      cache: {blockNumber: 99216559},
    },
  },
};
