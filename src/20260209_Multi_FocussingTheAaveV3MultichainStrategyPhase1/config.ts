import {ConfigFile} from '../../generator/types';
export const config: ConfigFile = {
  rootOptions: {
    author: 'Aavechan Initiative @aci',
    pools: ['AaveV3Metis', 'AaveV3ZkSync', 'AaveV3Soneium'],
    title: 'Focussing the Aave V3 Multichain Strategy - Phase 1',
    shortName: 'FocussingTheAaveV3MultichainStrategyPhase1',
    date: '20260209',
    discussion:
      'https://governance.aave.com/t/arfc-focussing-the-aave-v3-multichain-strategy-phase-1/23954',
    snapshot:
      'https://snapshot.org/#/aavedao.eth/proposal/0x62340121a7428f902f3232030350eb2d2bb753dc10ab0657a16ffd4d85cb530b',
    votingNetwork: 'AVALANCHE',
  },
  poolOptions: {
    AaveV3Metis: {
      configs: {
        FREEZE: [
          {asset: 'mDAI', shouldBeFrozen: true},
          {asset: 'Metis', shouldBeFrozen: true},
          {asset: 'mUSDC', shouldBeFrozen: true},
          {asset: 'mUSDT', shouldBeFrozen: true},
          {asset: 'WETH', shouldBeFrozen: true},
        ],
      },
      cache: {blockNumber: 22138489},
    },
    AaveV3ZkSync: {
      configs: {
        FREEZE: [
          {asset: 'USDC', shouldBeFrozen: true},
          {asset: 'USDT', shouldBeFrozen: true},
          {asset: 'WETH', shouldBeFrozen: true},
          {asset: 'wstETH', shouldBeFrozen: true},
          {asset: 'ZK', shouldBeFrozen: true},
          {asset: 'weETH', shouldBeFrozen: true},
          {asset: 'sUSDe', shouldBeFrozen: true},
          {asset: 'wrsETH', shouldBeFrozen: true},
        ],
      },
      cache: {blockNumber: 68460116},
    },
    AaveV3Soneium: {
      configs: {
        FREEZE: [
          {asset: 'WETH', shouldBeFrozen: true},
          {asset: 'USDCe', shouldBeFrozen: true},
          {asset: 'USDT', shouldBeFrozen: true},
        ],
      },
      cache: {blockNumber: 18760511},
    },
  },
};
