import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    configFile:
      'src/20261119_AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral/config.ts',
    force: true,
    markets: ['AaveV3Ethereum'],
    title: 'Repositioning Aave V3 Core Around Established & Liquid Collateral',
    shortName: 'RepositioningAaveV3CoreAroundEstablishedLiquidCollateral',
    date: '20261119',
    author: 'LlamaRisk',
    discussion:
      'https://governance.aave.com/t/arfc-repositioning-aave-v3-core-around-established-liquid-collateral/26191',
    snapshot:
      'https://snapshot.org/#/s:aavedao.eth/proposal/0x7ed3e17373060128618599b425fd0b4312bea86fcd903a1aa99c2622403f7f98',
    votingNetwork: 'AVALANCHE',
  },
  marketOptions: {
    AaveV3Ethereum: {
      configs: {
        EMODES_ASSETS: [
          {
            asset: 'wstETH',
            eModeCategory: 'AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx',
            collateral: 'ENABLED',
            borrowable: 'DISABLED',
            ltvzero: 'KEEP_CURRENT',
          },
          {
            asset: 'weETH',
            eModeCategory: 'AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx',
            collateral: 'ENABLED',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'KEEP_CURRENT',
          },
          {
            asset: 'cbETH',
            eModeCategory: 'AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx',
            collateral: 'ENABLED',
            borrowable: 'KEEP_CURRENT',
            ltvzero: 'KEEP_CURRENT',
          },
        ],
        BORROWS_UPDATE: [
          {
            asset: 'CRV',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
          {
            asset: 'tBTC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
          {
            asset: 'rETH',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
          {
            asset: 'crvUSD',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
          {
            asset: 'FBTC',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
          {
            asset: 'UNI',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
          {
            asset: 'mUSD',
            enabledToBorrow: 'KEEP_CURRENT',
            flashloanable: 'KEEP_CURRENT',
            reserveFactor: '100',
          },
        ],
        FREEZE: [
          {asset: 'osETH', shouldBeFrozen: true},
          {asset: 'LBTC', shouldBeFrozen: true},
          {asset: 'rETH', shouldBeFrozen: true},
          {asset: 'eBTC', shouldBeFrozen: true},
          {asset: 'BTCb', shouldBeFrozen: true},
          {asset: 'tETH', shouldBeFrozen: true},
          {asset: 'PT_srUSDe_22OCT2026', shouldBeFrozen: true},
          {asset: 'LDO', shouldBeFrozen: true},
          {asset: 'mUSD', shouldBeFrozen: true},
        ],
      },
      cache: {blockNumber: 26449568},
    },
  },
};
