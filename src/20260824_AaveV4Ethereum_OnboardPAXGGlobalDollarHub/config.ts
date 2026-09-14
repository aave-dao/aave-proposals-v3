import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20260824_AaveV4Ethereum_OnboardPAXGGlobalDollarHub/config.ts',
    force: true,
    markets: ['AaveV4Ethereum'],
    title: 'Onboard PAXG to Global Dollar Hub',
    shortName: 'OnboardPAXGGlobalDollarHub',
    date: '20260824',
    author: 'Aave Labs',
    discussion:
      'https://governance.aave.com/t/arfc-onboard-paxg-to-the-global-dollar-hub-in-aave-v4-ethereum/25340',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0x65be5cb5922bc73d14ba16b13d4e7ee5eaae2c6d9518c27b7ab9721fd2f637b1',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV4Ethereum: {
      configs: {
        V4_USECASE_ONBOARD_RESERVE_TO_SPOKE: {
          freshHubs: [],
          freshSpokes: ['PAXG_GOLD_SPOKE'],
          hubAssetListings: [
            {
              hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              hub: 'GLOBAL_DOLLAR_HUB',
              underlying: 'PAXG',
              feeReceiver: 'AaveV4Ethereum.TREASURY_SPOKE',
              liquidityFee: '0',
              irStrategy: 'AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_USDG_IR_STRATEGY',
              irPreset: 'nonBorrowable',
              tokenization: {
                addCap: '0',
                proxyAdminOwner: '0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9',
                name: 'Wrapped Aave Global Dollar PAXG',
                symbol: 'waGlobalDollarPAXG',
              },
            },
          ],
          listings: [
            {
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              hub: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              underlying: 'PAXG',
              priceSource: '0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6',
              config: {
                collateralRisk: '0',
                paused: false,
                frozen: false,
                borrowable: false,
                receiveSharesEnabled: true,
              },
              dynamicConfig: {
                collateralFactor: '75',
                maxLiquidationBonus: '106.5',
                liquidationFee: '10',
              },
            },
            {
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              hub: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              underlying: 'AaveV4EthereumAssets.USDG_UNDERLYING',
              priceSource: '0x83D20dEEdcd4aC1313496c8CBcAad0fa298c0CE4',
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
              spokeLib: 'AaveV4EthereumSpokes.USDG_PENDLE_SPOKE',
              spoke: 'AaveV4EthereumSpokes.USDG_PENDLE_SPOKE',
              hub: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              underlying: 'AaveV4EthereumAssets.USDG_UNDERLYING',
              priceSource: '0x83D20dEEdcd4aC1313496c8CBcAad0fa298c0CE4',
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
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              targetHealthFactor: {kind: 'literal', value: '1.2'},
              healthFactorForMaxBonus: {kind: 'literal', value: '0.9'},
              liquidationBonusFactor: {kind: 'literal', value: '80'},
            },
          ],
          hubSpokeAdditions: [
            {
              hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              hub: 'GLOBAL_DOLLAR_HUB',
              spoke: 'PAXG_GOLD_SPOKE',
              assets: [
                {
                  underlying: 'PAXG',
                  addCap: '2500',
                  drawCap: '0',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
                {
                  underlying: 'AaveV4EthereumAssets.USDG_UNDERLYING',
                  addCap: '5000000',
                  drawCap: '9500000',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
            {
              hubLib: 'AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB',
              hub: 'GLOBAL_DOLLAR_HUB',
              spoke: 'AaveV4EthereumSpokes.USDG_PENDLE_SPOKE',
              assets: [
                {
                  underlying: 'AaveV4EthereumAssets.USDG_UNDERLYING',
                  addCap: '0',
                  drawCap: '4000000',
                  riskPremiumThreshold: '0',
                  active: true,
                  halted: false,
                },
              ],
            },
          ],
          pmUpdates: [
            {
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER',
              active: true,
            },
            {
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER',
              active: true,
            },
            {
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER',
              active: true,
            },
            {
              spokeLib: 'PAXG_GOLD_SPOKE',
              spoke: 'PAXG_GOLD_SPOKE',
              positionManager: 'AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY',
              active: true,
            },
          ],
        },
      },
      cache: {blockNumber: 25883490},
      labels: {
        '0x45804880de22913dafe09f4980848ece6ecbaf78': {
          label: 'PAXG',
          address: '0x45804880De22913dAFE09f4980848ECE6EcbAf78',
          kind: 'asset',
        },
        '0xad75ce6354f87f3135ce10621d385d8d1e2562c2': {
          label: 'PAXG_GOLD_SPOKE',
          address: '0xAD75cE6354f87F3135cE10621d385d8D1e2562C2',
          kind: 'spoke',
        },
      },
    },
  },
};
