import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    author: 'Chaos Labs (implemented by Aavechan Initiative @aci via Skyward)',
    pools: ['AaveV3InkWhitelabel'],
    title: 'INK SolvBTC Listing',
    shortName: 'INKSolvBTCListing',
    date: '20260211',
  },
  poolOptions: {
    AaveV3InkWhitelabel: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'SolvBTC',
            decimals: 18,
            priceFeed: '0xAe48F22903d43f13f66Cc650F57Bd4654ac222cb',
            ltv: '70',
            liqThreshold: '75',
            liqBonus: '7.5',
            debtCeiling: '1',
            liqProtocolFee: '10',
            enabledToBorrow: 'DISABLED',
            flashloanable: 'ENABLED',
            borrowableInIsolation: 'DISABLED',
            withSiloedBorrowing: 'DISABLED',
            reserveFactor: '50',
            supplyCap: '50',
            borrowCap: '1',
            rateStrategyParams: {
              optimalUtilizationRate: '45',
              baseVariableBorrowRate: '0',
              variableRateSlope1: '10',
              variableRateSlope2: '300',
            },
            asset: '0xaE4EFbc7736f963982aACb17EFA37fCBAb924cB3',
            admin: '0xac140648435d03f784879cd789130F22Ef588Fcd',
          },
        ],
      },
      cache: {blockNumber: 37330715},
    },
  },
};
