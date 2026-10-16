import {ConfigFile} from '../../generator/types';

export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/config.ts',
    force: false,
    markets: ['AaveV4Base'],
    title: 'Onboard SPCXc to the Equities Hub on Base',
    shortName: 'OnboardSPCXEquitiesHub',
    date: '20261016',
    author: 'Aave Labs',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-asset-listing-spcx-to-the-aave-v4-equities-hub-on-base/25850',
    snapshot: 'direct-to-aip',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV4Base: {
      configs: {
        V4_AM_ROLE_MEMBERSHIP: [
          {
            roleId: '400',
            account: '0x9390B1735def18560c509E2d0bc090E9d6BA257a',
            granted: true,
            executionDelay: '0',
          },
        ],
        V4_USECASE_ONBOARD_RESERVE_TO_SPOKE: {
          freshHubs: [],
          freshSpokes: [],
          hubAssetListings: [
            {
              hubLib: 'AaveV4BaseHubs.EQUITIES_HUB',
              hub: 'EQUITIES_HUB',
              underlying: 'SPCXC',
              feeReceiver: 'AaveV4Base.TREASURY_SPOKE',
              liquidityFee: '0',
              irStrategy: 'AaveV4BaseIRStrategies.EQUITIES_AAPLc_IR_STRATEGY',
              irPreset: 'nonBorrowable',
            },
          ],
          listings: [
            {
              spokeLib: 'AaveV4BaseSpokes.MAG7_SPOKE',
              spoke: 'AaveV4BaseSpokes.MAG7_SPOKE',
              hub: 'AaveV4BaseHubs.EQUITIES_HUB',
              underlying: 'SPCXC',
              priceSource: '0x6A634B235903C4ad6376892180d6fF8612e3Fa68',
              config: {
                collateralRisk: '10',
                paused: false,
                frozen: false,
                borrowable: false,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '55',
                maxLiquidationBonus: '106.5',
                liquidationFee: '10',
              },
            },
          ],
          updates: [],
          liquidationUpdates: [],
          hubSpokeAdditions: [
            {
              hubLib: 'AaveV4BaseHubs.EQUITIES_HUB',
              hub: 'EQUITIES_HUB',
              spoke: 'AaveV4BaseSpokes.MAG7_SPOKE',
              assets: [
                {
                  underlying: 'SPCXC',
                  addCap: '37000',
                  drawCap: '0',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
          ],
          pmUpdates: [],
        },
        V4_HUB_SPOKE_CONFIG_UPDATE: [
          {
            hubLib: 'AaveV4BaseHubs.EQUITIES_HUB',
            hub: 'EQUITIES_HUB',
            underlying: 'AaveV4BaseAssets.USDC_UNDERLYING',
            spoke: 'AaveV4BaseSpokes.MAG7_SPOKE',
            addCap: {
              kind: 'keepCurrent',
              sentinel: 'KEEP_CURRENT',
            },
            drawCap: {
              kind: 'keepCurrent',
              sentinel: 'KEEP_CURRENT',
            },
            riskPremiumThreshold: {
              kind: 'literal',
              value: '1000',
            },
            active: {
              kind: 'keepCurrent',
              sentinel: 'KEEP_CURRENT',
            },
            halted: {
              kind: 'keepCurrent',
              sentinel: 'KEEP_CURRENT',
            },
          },
        ],
      },
      cache: {
        blockNumber: 52669984,
      },
      labels: {
        '0xb2000000000000000000007b9fcbd005511acbd5': {
          label: 'SPCXC',
          address: '0xb2000000000000000000007b9fcbd005511aCBd5',
          kind: 'asset',
        },
      },
    },
  },
};
