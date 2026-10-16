import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
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
          {asset: 'WBTC', ltv: '', liqThreshold: '', liqBonus: '', liqProtocolFee: '20'},
          {asset: 'WETH', ltv: '', liqThreshold: '', liqBonus: '', liqProtocolFee: '20'},
          {asset: 'wstETH', ltv: '', liqThreshold: '', liqBonus: '', liqProtocolFee: '20'},
        ],
      },
      cache: {blockNumber: 26204670},
    },
  },
};
