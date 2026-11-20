import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile: 'src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/config.ts',
    update: true,
    force: true,
    markets: [
      'AaveV3Ethereum',
      'AaveV3Plasma',
      'AaveV3Mantle',
      'AaveV3Monad',
      'AaveV3Avalanche',
      'AaveV3XLayer',
    ],
    title: 'Ethena E-Mode Consolidation on Aave V3',
    shortName: 'EthenaEModeConsolidationOnAaveV3',
    date: '20261111',
    author: '@TokenLogic',
    discussion:
      'https://governance.aave.com/t/direct-to-aip-ethena-e-mode-consolidation-on-aave-v3/26304',
    snapshot: 'Direct-to-AIP',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        EMODES_UPDATES: [
          {
            eModeCategory: 'AaveV3EthereumEModes.USDe__USDC_USDT',
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
        ],
        EMODES_ASSETS: [
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025__USDC_USDT',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory: '19',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory:
              'AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025_PT_eUSDE_14AUG2025_PT_USDe_25SEP2025__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory:
              'AaveV3EthereumEModes.USDe_PT_USDe_27NOV2025_PT_USDe_5FEB2026__USDC_USDT_USDe_USDtb',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3EthereumEModes.USDe_PT_USDe_27NOV2025_PT_USDe_5FEB2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory:
              'AaveV3EthereumEModes.USDe_PT_USDe_5FEB2026_PT_USDe_7MAY2026__USDC_USDT_USDe_USDtb',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3EthereumEModes.USDe_PT_USDe_5FEB2026_PT_USDe_7MAY2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_sUSDE_31JUL2025__USDC_USDT',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3EthereumEModes.sUSDe_PT_sUSDE_31JUL2025_PT_sUSDE_25SEP2025__USDC_USDT_USDe_USDtb',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3EthereumEModes.sUSDe_PT_sUSDE_25SEP2025_PT_sUSDE_27NOV2025__USDC_USDT_USDe_USDtb',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3EthereumEModes.sUSDe_PT_sUSDE_27NOV2025_PT_sUSDE_5FEB2026__USDC_USDT_USDe_USDtb',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_sUSDE_27NOV2025_PT_sUSDE_5FEB2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3EthereumEModes.sUSDe_PT_sUSDE_5FEB2026_PT_sUSDE_7MAY2026__USDC_USDT_USDe_USDtb',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_sUSDE_5FEB2026_PT_sUSDE_7MAY2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026__USDC_USDT_USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026_PT_srUSDe_25JUN2026__USDC_USDT_USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026_PT_srUSDe_25JUN2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'PT_srUSDe_22OCT2026',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'PT_srUSDe_22OCT2026',
            eModeCategory: 'AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
        ],
      },
      cache: {blockNumber: 26394174},
    },
    AaveV3Plasma: {
      configs: {
        EMODES_UPDATES: [
          {
            eModeCategory: 'AaveV3PlasmaEModes.USDe__USDT0',
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
          {
            eModeCategory:
              'AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO',
            ltv: '',
            liqThreshold: '93',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
          {
            eModeCategory:
              'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO',
            ltv: '90',
            liqThreshold: '92',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
        ],
        EMODES_ASSETS: [
          {
            asset: 'USDe',
            eModeCategory:
              'AaveV3PlasmaEModes.USDe_PT_USDe_15JAN2026_PT_USDe_9APR2026__USDT0_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3PlasmaEModes.USDe_PT_USDe_15JAN2026_PT_USDe_9APR2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory:
              'AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_15JAN2026_PT_sUSDE_9APR2026__USDT0_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_15JAN2026_PT_sUSDE_9APR2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory:
              'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'sUSDe',
            eModeCategory: 'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'PT_sUSDE_22OCT2026',
            eModeCategory: 'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'PT_sUSDE_22OCT2026',
            eModeCategory: 'AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
        ],
      },
      cache: {blockNumber: 37486717},
    },
    AaveV3Mantle: {
      configs: {
        EMODES_UPDATES: [
          {
            eModeCategory: 'AaveV3MantleEModes.USDe__USDT0_USDC_GHO',
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
        ],
      },
      cache: {blockNumber: 103149891},
    },
    AaveV3Monad: {
      configs: {
        EMODES_CREATION: [
          {
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '2',
            label: 'USDe Stablecoins',
            isolated: 'DISABLED',
            collateralAssets: ['USDe'],
            borrowableAssets: ['USDT0', 'USDC', 'AUSD', 'GHO'],
          },
        ],
        EMODES_ASSETS: [
          {
            asset: 'PT_AUSD_8OCT2026',
            eModeCategory: 'AaveV3MonadEModes.PT_AUSD_8OCT2026__USDT0_USDC_USDe_GHO',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
        ],
      },
      cache: {blockNumber: 121417398},
    },
    AaveV3Avalanche: {
      configs: {
        EMODES_UPDATES: [
          {
            eModeCategory: 'AaveV3AvalancheEModes.USDe__USDC_USDt_GHO',
            ltv: '91',
            liqThreshold: '93',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
          {
            eModeCategory: 'AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe',
            ltv: '90',
            liqThreshold: '92',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
        ],
        EMODES_ASSETS: [
          {
            asset: 'USDe',
            eModeCategory: 'AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe',
            collateral: 'KEEP_CURRENT',
            borrowable: 'DISABLED',
            ltvzero: 'KEEP_CURRENT',
          },
        ],
      },
      cache: {blockNumber: 100053881},
    },
    AaveV3XLayer: {
      configs: {
        EMODES_ASSETS: [
          {
            asset: 'PT_USDG_29OCT2026',
            eModeCategory: 'AaveV3XLayerEModes.PT_USDG_29OCT2026__USDT_USDG_GHO_USDC',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
          {
            asset: 'PT_USDG_29OCT2026',
            eModeCategory: 'AaveV3XLayerEModes.PT_USDG_29OCT2026__USDG',
            collateral: 'KEEP_CURRENT',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'ENABLED',
          },
        ],
      },
      cache: {blockNumber: 75661061},
    },
  },
};
