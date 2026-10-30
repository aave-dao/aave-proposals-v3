import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    author: 'Aave Labs',
    configFile: 'src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/config.ts',
    force: true,
    markets: ['AaveV4Avalanche'],
    title: 'Onboard USAT to Aave V4 Core Instance on Avalanche',
    shortName: 'OnboardUSATCoreHub',
    date: '20261028',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-onboard-usat-to-aave-v4-core-instance-on-avalanche/25880',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV4Avalanche: {
      configs: {
        V4_USECASE_ONBOARD_RESERVE_TO_SPOKE: {
          freshHubs: [],
          freshSpokes: [],
          hubAssetListings: [
            {
              hubLib: 'AaveV4AvalancheHubs.CORE_HUB',
              hub: 'CORE_HUB',
              underlying: 'USAT',
              feeReceiver: 'AaveV4Avalanche.TREASURY_SPOKE',
              liquidityFee: '10',
              irStrategy: 'AaveV4AvalancheIRStrategies.CORE_USDt_IR_STRATEGY',
              irData: {
                optimalUsageRatio: {kind: 'literal', value: '94'},
                baseDrawnRate: {kind: 'literal', value: '0'},
                rateGrowthBeforeOptimal: {kind: 'literal', value: '4.9'},
                rateGrowthAfterOptimal: {kind: 'literal', value: '20'},
              },
              tokenization: {
                addCap: '1500000',
                proxyAdminOwner: 'MiscAvalanche.V4_SECURITY_COUNCIL',
                name: 'Wrapped Aave Core USAT',
                symbol: 'waCoreUSAT',
              },
            },
          ],
          listings: [
            {
              spokeLib: 'AaveV4AvalancheSpokes.MAIN_SPOKE',
              spoke: 'AaveV4AvalancheSpokes.MAIN_SPOKE',
              hub: 'AaveV4AvalancheHubs.CORE_HUB',
              underlying: 'USAT',
              priceSource: '0xCcE4d712CA51098e89F26f79F114132942DE9134',
              config: {
                collateralRisk: '0',
                paused: false,
                frozen: false,
                borrowable: true,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '0',
                maxLiquidationBonus: '100',
                liquidationFee: '0',
              },
            },
            {
              spokeLib: 'AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE',
              spoke: 'AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE',
              hub: 'AaveV4AvalancheHubs.CORE_HUB',
              underlying: 'USAT',
              priceSource: '0xCcE4d712CA51098e89F26f79F114132942DE9134',
              config: {
                collateralRisk: '0',
                paused: false,
                frozen: false,
                borrowable: true,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '0',
                maxLiquidationBonus: '100',
                liquidationFee: '0',
              },
            },
          ],
          updates: [],
          liquidationUpdates: [],
          hubSpokeAdditions: [
            {
              hubLib: 'AaveV4AvalancheHubs.CORE_HUB',
              hub: 'CORE_HUB',
              spoke: 'AaveV4AvalancheSpokes.MAIN_SPOKE',
              assets: [
                {
                  underlying: 'USAT',
                  addCap: '60000000',
                  drawCap: '5000000',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
            {
              hubLib: 'AaveV4AvalancheHubs.CORE_HUB',
              hub: 'CORE_HUB',
              spoke: 'AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE',
              assets: [
                {
                  underlying: 'USAT',
                  addCap: '0',
                  drawCap: '50000000',
                  riskPremiumThreshold: '1100',
                  active: true,
                  halted: false,
                },
              ],
            },
          ],
          pmUpdates: [],
        },
      },
      cache: {blockNumber: 98782788},
      labels: {
        '0x9a5926fd88f747c357738b1e82afb46ab80f0a6b': {
          label: 'USAT',
          address: '0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b',
          kind: 'asset',
        },
      },
    },
  },
};
