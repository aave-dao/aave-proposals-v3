import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    title: 'Risk Params Record CI Sample',
    author: 'Aave Labs',
    markets: ['AaveV3Ethereum', 'AaveV3Arbitrum', 'AaveV3Base'],
    discussion:
      'https://governance.aave.com/t/arfc-revision-of-eth-btc-collateral-efficiency-on-aave/25649',
    votingNetwork: 'AVALANCHE',
    shortName: 'RiskParamsRecordCISample',
    date: '20261113',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        COLLATERALS_UPDATE: [
          {asset: 'WETH', ltv: '82', liqThreshold: '85', liqBonus: '', liqProtocolFee: ''},
          {asset: 'cbBTC', ltv: '82', liqThreshold: '86', liqBonus: '', liqProtocolFee: ''},
          {asset: 'weETH', ltv: '79', liqThreshold: '82', liqBonus: '', liqProtocolFee: ''},
        ],
      },
      cache: {blockNumber: 26404723},
    },
    AaveV3Arbitrum: {
      configs: {
        COLLATERALS_UPDATE: [
          {asset: 'WBTC', ltv: '79', liqThreshold: '83', liqBonus: '', liqProtocolFee: ''},
        ],
      },
      cache: {blockNumber: 523807251},
    },
    AaveV3Base: {
      configs: {
        COLLATERALS_UPDATE: [
          {asset: 'WETH', ltv: '82', liqThreshold: '85', liqBonus: '', liqProtocolFee: ''},
          {asset: 'cbBTC', ltv: '82', liqThreshold: '85', liqBonus: '6.5', liqProtocolFee: ''},
        ],
        EMODES_UPDATES: [
          {
            eModeCategory: 'AaveV3BaseEModes.cbBTC__USDC_GHO',
            ltv: '83',
            liqThreshold: '86',
            liqBonus: '',
            label: '',
            isolated: 'KEEP_CURRENT',
          },
        ],
      },
      cache: {blockNumber: 56833184},
    },
  },
};
