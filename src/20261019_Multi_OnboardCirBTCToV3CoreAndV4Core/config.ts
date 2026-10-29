import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/config.ts',
    force: true,
    markets: ['AaveV3Ethereum', 'AaveV4Ethereum'],
    title: 'Onboard cirBTC on Aave V3 Core and Aave V4 Core',
    shortName: 'OnboardCirBTCToV3CoreAndV4Core',
    date: '20261019',
    author: 'Aave Labs',
    discussion:
      'https://governance.aave.com/t/arfc-onboard-cirbtc-on-aave-v3-core-and-aave-v4-core/25128',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0xe7ce2a6c2c3f8ea303351a12ea0e991815b3944bd44af4fd2890cadc2ff19881',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'cirBTC',
            decimals: 8,
            priceFeed: '0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A',
            ltv: '73',
            liqThreshold: '78',
            liqBonus: '5',
            liqProtocolFee: '20',
            enabledToBorrow: 'ENABLED',
            flashloanable: 'ENABLED',
            reserveFactor: '50',
            supplyCap: '250',
            borrowCap: '20',
            rateStrategyParams: {
              optimalUtilizationRate: '80',
              baseVariableBorrowRate: '0.25',
              variableRateSlope1: '4',
              variableRateSlope2: '60',
            },
            asset: '0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E',
            admin: '',
          },
        ],
      },
      cache: {blockNumber: 26282649},
    },
    AaveV4Ethereum: {
      configs: {
        V4_USECASE_ONBOARD_RESERVE_TO_SPOKE: {
          freshHubs: [],
          freshSpokes: [],
          hubAssetListings: [
            {
              hubLib: 'AaveV4EthereumHubs.CORE_HUB',
              hub: 'CORE_HUB',
              underlying: 'cirBTC',
              feeReceiver: 'AaveV4Ethereum.TREASURY_SPOKE',
              liquidityFee: '20',
              irStrategy: 'AaveV4EthereumIRStrategies.CORE_WBTC_IR_STRATEGY',
              irData: {
                optimalUsageRatio: {kind: 'literal', value: '80'},
                baseDrawnRate: {kind: 'literal', value: '0.25'},
                rateGrowthBeforeOptimal: {kind: 'literal', value: '4'},
                rateGrowthAfterOptimal: {kind: 'literal', value: '60'},
              },
              tokenization: {
                addCap: '25',
                proxyAdminOwner: '0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9',
                name: 'Wrapped Aave Core cirBTC',
                symbol: 'waCorecirBTC',
              },
            },
          ],
          listings: [
            {
              spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
              spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
              hub: 'AaveV4EthereumHubs.CORE_HUB',
              underlying: 'cirBTC',
              priceSource: '0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A',
              config: {
                collateralRisk: '0',
                paused: false,
                frozen: false,
                borrowable: true,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '78',
                maxLiquidationBonus: '105.55',
                liquidationFee: '10',
              },
            },
          ],
          updates: [],
          liquidationUpdates: [],
          hubSpokeAdditions: [
            {
              hubLib: 'AaveV4EthereumHubs.CORE_HUB',
              hub: 'CORE_HUB',
              spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
              assets: [
                {
                  underlying: 'cirBTC',
                  addCap: '250',
                  drawCap: '25',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
          ],
          pmUpdates: [],
        },
      },
      cache: {blockNumber: 26282649},
      labels: {
        '0x72dfb2e44f59c5ad2bafe84314e5b99a7cd5075e': {
          label: 'cirBTC',
          address: '0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E',
          kind: 'asset',
        },
      },
    },
  },
};
