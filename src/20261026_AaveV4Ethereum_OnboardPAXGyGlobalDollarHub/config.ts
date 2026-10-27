import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261026_AaveV4Ethereum_OnboardPAXGyGlobalDollarHub/config.ts',
    force: true,
    markets: ['AaveV4Ethereum'],
    title: 'Onboard PAXGy to Aave V4 Global Dollar Hub',
    shortName: 'OnboardPAXGyGlobalDollarHub',
    date: '20261026',
    author: 'Aave Labs',
    discussion:
      'https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0xf987dd5aed6586169b232af7691e2cbb268cf61e2845bf6a04a83b60a5404bd8',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV4Ethereum: {
      configs: {
        V4_USECASE_ONBOARD_RESERVE_TO_SPOKE: {
          freshHubs: [],
          freshSpokes: ['PAXG_PAXOS_ESPOKE'],
          hubAssetListings: [
            {
              hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              hub: 'GLOBAL_DOLLAR_HUB',
              underlying: 'PAXGY',
              feeReceiver: 'AaveV4Ethereum.TREASURY_SPOKE',
              liquidityFee: '0',
              irStrategy: 'AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_PAXG_IR_STRATEGY',
              irPreset: 'nonBorrowable',
            },
          ],
          listings: [
            {
              spokeLib: 'AaveV4EthereumSpokes.PAXG_GOLD_SPOKE',
              spoke: 'AaveV4EthereumSpokes.PAXG_GOLD_SPOKE',
              hub: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              underlying: 'PAXGY',
              priceSource: '0x8e39de6366ab0bc3e9ff6a116f366736bf0d8a9e',
              config: {
                collateralRisk: '0',
                paused: false,
                frozen: false,
                borrowable: false,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '70',
                maxLiquidationBonus: '107.5',
                liquidationFee: '10',
              },
            },
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              hub: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              underlying: 'PAXGY',
              priceSource: '0x8e39de6366ab0bc3e9ff6a116f366736bf0d8a9e',
              config: {
                collateralRisk: '0',
                paused: false,
                frozen: false,
                borrowable: false,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '85',
                maxLiquidationBonus: '104',
                liquidationFee: '10',
              },
            },
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              hub: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              underlying: 'AaveV4EthereumAssets.PAXG_UNDERLYING',
              priceSource: '0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6',
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
          liquidationUpdates: [
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              targetHealthFactor: {kind: 'literal', value: '1.05'},
              healthFactorForMaxBonus: {kind: 'literal', value: '0.99'},
              liquidationBonusFactor: {kind: 'literal', value: '100'},
            },
          ],
          hubSpokeAdditions: [
            {
              hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              hub: 'GLOBAL_DOLLAR_HUB',
              spoke: 'AaveV4EthereumSpokes.PAXG_GOLD_SPOKE',
              assets: [
                {
                  underlying: 'PAXGY',
                  addCap: '480',
                  drawCap: '0',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
            {
              hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              hub: 'GLOBAL_DOLLAR_HUB',
              spoke: 'PAXG_PAXOS_ESPOKE',
              assets: [
                {
                  underlying: 'PAXGY',
                  addCap: '480',
                  drawCap: '0',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
                {
                  underlying: 'AaveV4EthereumAssets.PAXG_UNDERLYING',
                  addCap: '0',
                  drawCap: '400',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
          ],
          pmUpdates: [
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER',
              active: true,
            },
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER',
              active: true,
            },
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER',
              active: true,
            },
            {
              spokeLib: 'PAXG_PAXOS_ESPOKE',
              spoke: 'PAXG_PAXOS_ESPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY',
              active: true,
            },
          ],
        },
        V4_HUB_ASSET_CONFIG_UPDATE: [
          {
            hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
            hub: 'GLOBAL_DOLLAR_HUB',
            underlying: 'AaveV4EthereumAssets.PAXG_UNDERLYING',
            liquidityFee: {kind: 'literal', value: '50'},
            feeReceiver: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT_ADDRESS'},
            irStrategy: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT_ADDRESS'},
            irData: {
              optimalUsageRatio: {kind: 'literal', value: '60'},
              baseDrawnRate: {kind: 'literal', value: '0'},
              rateGrowthBeforeOptimal: {kind: 'literal', value: '3'},
              rateGrowthAfterOptimal: {kind: 'literal', value: '20'},
            },
            reinvestmentController: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT_ADDRESS'},
          },
        ],
      },
      cache: {blockNumber: 26284253},
      labels: {
        '0x6c6494fd9962eb98b94ffa48f6679058f820700e': {
          label: 'PAXGY',
          address: '0x6c6494Fd9962eB98B94ffA48F6679058F820700e',
          kind: 'asset',
        },
        '0x115af1c2db26cd8eca3f29055e4e424af4edf616': {
          label: 'PAXG_PAXOS_ESPOKE',
          address: '0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616',
          kind: 'spoke',
        },
      },
    },
  },
};
