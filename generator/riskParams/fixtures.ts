// config.ts of past AIPs, copied from aave-proposals-v3 (folders pruned from main on Oct 27, 2026)
import type {ConfigFile} from '../types';

// src/20261013_AaveV3XLayer_AaveV3XLayerUSDeListing/config.ts
export const USDE_XLAYER_LISTING: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261013_AaveV3XLayer_AaveV3XLayerUSDeListing/config.ts',
    markets: ['AaveV3XLayer'],
    title: 'Onboard USDe to Aave V3 X Layer',
    shortName: 'AaveV3XLayerUSDeListing',
    date: '20261013',
    author: '@TokenLogic',
    discussion: 'https://governance.aave.com/t/direct-to-aip-asset-listing-usde-x-layer/25688',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3XLayer: {
      configs: {
        ASSET_LISTING: [
          {
            assetSymbol: 'USDe',
            decimals: 18,
            priceFeed: '0x7ec7E5497EAf312FE82F8307D05eb0E5f0f157D3',
            ltv: '0',
            liqThreshold: '0',
            liqBonus: '0',
            liqProtocolFee: '10',
            enabledToBorrow: 'ENABLED',
            flashloanable: 'ENABLED',
            reserveFactor: '25',
            supplyCap: '100000000',
            borrowCap: '20000000',
            rateStrategyParams: {
              optimalUtilizationRate: '85',
              baseVariableBorrowRate: '6.3',
              variableRateSlope1: '0.25',
              variableRateSlope2: '45',
            },
            asset: '0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34',
            admin: '',
          },
        ],
        EMODES_CREATION: [
          {
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '2',
            label: 'USDe__Stablecoins',
            isolated: 'DISABLED',
            collateralAssets: ['USDe'],
            borrowableAssets: ['USDT', 'USDG', 'USDC', 'GHO'],
          },
        ],
        EMODES_ASSETS: [
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3XLayerEModes.xBTC__USDT_USDG_GHO_USDC',
            collateral: 'KEEP_CURRENT',
            borrowable: 'ENABLED',
            ltvzero: 'KEEP_CURRENT',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3XLayerEModes.xETH__USDT_USDG_GHO_USDC',
            collateral: 'KEEP_CURRENT',
            borrowable: 'ENABLED',
            ltvzero: 'KEEP_CURRENT',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3XLayerEModes.xSOL__USDT_USDG_GHO_USDC',
            collateral: 'KEEP_CURRENT',
            borrowable: 'ENABLED',
            ltvzero: 'KEEP_CURRENT',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3XLayerEModes.WOKB__USDT_USDG_GHO_USDC',
            collateral: 'KEEP_CURRENT',
            borrowable: 'ENABLED',
            ltvzero: 'KEEP_CURRENT',
          },
        ],
      },
      cache: {
        blockNumber: 73119417,
      },
    },
  },
};

// src/20261016_AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH/config.ts
export const LPF_INCREASE_ETHEREUM: ConfigFile = {
  rootOptions: {
    configFile:
      'src/20261016_AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH/config.ts',
    markets: ['AaveV3Ethereum'],
    title: 'Liquidation Protocol Fee Increase for WBTC, WETH, and wstETH on Aave V3 Ethereum Core',
    shortName: 'LiquidationProtocolFeeIncreaseWBTCWETHWstETH',
    date: '20261016',
    author: 'LlamaRisk (implemented by Aave Labs)',
    discussion:
      'https://governance.aave.com/t/arfc-liquidation-protocol-fee-increase-for-wbtc-weth-and-wsteth-on-aave-v3-ethereum-core/25470',
    snapshot:
      'https://snapshot.box/#/s:aavedao.eth/proposal/0xbc1c59336255d276088fa85f95ef7122d9d8a56940299093f3246b7db897b6a6',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        COLLATERALS_UPDATE: [
          {
            asset: 'WBTC',
            ltv: '',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '20',
          },
          {
            asset: 'WETH',
            ltv: '',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '20',
          },
          {
            asset: 'wstETH',
            ltv: '',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '20',
          },
        ],
      },
      cache: {
        blockNumber: 26204670,
      },
    },
  },
};

// src/20260707_Multi_AaveV3LTVAndEModeUpdate/config.ts
export const MULTI_LTV_AND_EMODE_UPDATE: ConfigFile = {
  rootOptions: {
    markets: [
      'AaveV3Ethereum',
      'AaveV3Avalanche',
      'AaveV3Gnosis',
      'AaveV3Mantle',
      'AaveV3EthereumLido',
    ],
    title: 'Aave V3 LTV and E-Mode Update',
    shortName: 'AaveV3LTVAndEModeUpdate',
    date: '20260707',
    author: 'Llama Risk (implemented by Aave Labs)',
    discussion: 'https://governance.aave.com/t/direct-to-aip-aave-v3-ltv-and-e-mode-update/25067',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        COLLATERALS_UPDATE: [
          {
            asset: 'PYUSD',
            ltv: '0',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '',
          },
        ],
        CAPS_UPDATE: [
          {
            asset: 'wstETH',
            supplyCap: '',
            borrowCap: '7000',
          },
        ],
      },
      cache: {
        blockNumber: 25524764,
      },
    },
    AaveV3Avalanche: {
      configs: {
        COLLATERALS_UPDATE: [
          {
            asset: 'AUSD',
            ltv: '0',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '',
          },
        ],
      },
      cache: {
        blockNumber: 90217434,
      },
    },
    AaveV3Gnosis: {
      configs: {
        COLLATERALS_UPDATE: [
          {
            asset: 'wstETH',
            ltv: '0',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '',
          },
        ],
      },
      cache: {
        blockNumber: 47183996,
      },
    },
    AaveV3Mantle: {
      configs: {
        COLLATERALS_UPDATE: [
          {
            asset: 'WETH',
            ltv: '0',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '',
          },
          {
            asset: 'WMNT',
            ltv: '0',
            liqThreshold: '',
            liqBonus: '',
            liqProtocolFee: '',
          },
        ],
        EMODES_CREATION: [
          {
            ltv: '40',
            liqThreshold: '45',
            liqBonus: '10',
            label: 'WMNT__Stablecoins',
            isolated: 'ENABLED',
            collateralAssets: ['WMNT'],
            borrowableAssets: ['USDT0', 'USDC', 'GHO'],
          },
        ],
      },
      cache: {
        blockNumber: 97914064,
      },
    },
    AaveV3EthereumLido: {
      configs: {
        CAPS_UPDATE: [
          {
            asset: 'wstETH',
            supplyCap: '',
            borrowCap: '18000',
          },
        ],
      },
      cache: {
        blockNumber: 25524764,
      },
    },
  },
};
