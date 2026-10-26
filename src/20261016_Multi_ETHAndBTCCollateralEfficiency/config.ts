import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261016_Multi_ETHAndBTCCollateralEfficiency/config.ts',
    force: true,
    markets: ['AaveV3Ethereum', 'AaveV3Arbitrum', 'AaveV3Base', 'AaveV4Ethereum'],
    title: 'Revision of ETH & BTC Collateral Efficiency on Aave',
    shortName: 'ETHAndBTCCollateralEfficiency',
    date: '20261016',
    author: 'LlamaRisk (implemented by Aave Labs)',
    discussion:
      'https://governance.aave.com/t/arfc-revision-of-eth-btc-collateral-efficiency-on-aave/25649',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0x0845fbf2d49ec5ad85f8a569e51ce7014f6f4c6dfc34e3b6cd28ef3f9037d586',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        COLLATERALS_UPDATE: [
          {asset: 'WETH', ltv: '81', liqThreshold: '84', liqBonus: '', liqProtocolFee: ''},
          {asset: 'WBTC', ltv: '81', liqThreshold: '85', liqBonus: '', liqProtocolFee: ''},
          {asset: 'cbBTC', ltv: '81', liqThreshold: '85', liqBonus: '', liqProtocolFee: ''},
          {asset: 'wstETH', ltv: '79', liqThreshold: '82', liqBonus: '', liqProtocolFee: ''},
          {asset: 'weETH', ltv: '78', liqThreshold: '81', liqBonus: '', liqProtocolFee: ''},
        ],
      },
      cache: {blockNumber: 26204733},
    },
    AaveV3Arbitrum: {
      configs: {
        COLLATERALS_UPDATE: [
          {asset: 'WETH', ltv: '81', liqThreshold: '', liqBonus: '', liqProtocolFee: ''},
          {asset: 'WBTC', ltv: '78', liqThreshold: '82', liqBonus: '', liqProtocolFee: ''},
        ],
      },
      cache: {blockNumber: 515357810},
    },
    AaveV3Base: {
      configs: {
        COLLATERALS_UPDATE: [
          {asset: 'WETH', ltv: '81', liqThreshold: '84', liqBonus: '', liqProtocolFee: ''},
          {asset: 'cbBTC', ltv: '81', liqThreshold: '84', liqBonus: '6', liqProtocolFee: ''},
        ],
        EMODES_UPDATES: [
          {
            eModeCategory: 'AaveV3BaseEModes.cbBTC__USDC_GHO',
            ltv: '82',
            liqThreshold: '85',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
        ],
      },
      cache: {blockNumber: 52680008},
    },
    AaveV4Ethereum: {
      configs: {
        V4_SPOKE_DYNAMIC_RESERVE_CONFIG_UPDATE: [
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.WETH_UNDERLYING',
            dynamicConfigKey: '0',
            collateralFactor: {kind: 'literal', value: '84'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.WBTC_UNDERLYING',
            dynamicConfigKey: '0',
            collateralFactor: {kind: 'literal', value: '85'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.cbBTC_UNDERLYING',
            dynamicConfigKey: '0',
            collateralFactor: {kind: 'literal', value: '85'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.wstETH_UNDERLYING',
            dynamicConfigKey: '0',
            collateralFactor: {kind: 'literal', value: '82'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.weETH_UNDERLYING',
            dynamicConfigKey: '0',
            collateralFactor: {kind: 'literal', value: '81'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.wstETH_UNDERLYING',
            dynamicConfigKey: '2',
            collateralFactor: {kind: 'literal', value: '82'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
          {
            spokeLib: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            spoke: 'AaveV4EthereumSpokes.MAIN_SPOKE',
            hub: 'AaveV4EthereumHubs.CORE_HUB',
            underlying: 'AaveV4EthereumAssets.weETH_UNDERLYING',
            dynamicConfigKey: '2',
            collateralFactor: {kind: 'literal', value: '81'},
            maxLiquidationBonus: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
            liquidationFee: {kind: 'keepCurrent', sentinel: 'KEEP_CURRENT'},
          },
        ],
      },
      cache: {blockNumber: 26204733},
    },
  },
};
