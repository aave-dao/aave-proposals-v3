import {Options} from '../../types';
import {
  CapsUpdate,
  CollateralUpdate,
  EModeCategoryCreation,
  EModeCategoryUpdate,
  Listing,
  ListingWithCustomImpl,
  PriceFeedUpdate,
  RateStrategyUpdate,
} from '../types';

export const MOCK_OPTIONS: Options = {
  markets: ['AaveV3Ethereum'],
  title: 'test',
  shortName: 'Test',
  date: '20231023',
  author: 'test',
  discussion: 'test',
  snapshot: 'test',
};

export const assetListingConfig: Listing[] = [
  {
    assetSymbol: 'PSP',
    onchainSymbol: 'PSP',
    decimals: 18,
    priceFeed: '0x72AFAECF99C9d9C8215fF44C77B94B99C28741e8',
    ltv: '40',
    liqThreshold: '50',
    liqBonus: '5',
    liqProtocolFee: '20',
    enabledToBorrow: 'ENABLED',
    flashloanable: 'ENABLED',
    reserveFactor: '20',
    supplyCap: '10000',
    borrowCap: '5000',
    rateStrategyParams: {
      optimalUtilizationRate: '80',
      baseVariableBorrowRate: '0',
      variableRateSlope1: '10',
      variableRateSlope2: '100',
      stableRateSlope1: '10',
      stableRateSlope2: '100',
      baseStableRateOffset: '1',
      stableRateExcessOffset: '0',
      optimalStableToTotalDebtRatio: '10',
    },
    eModeCategory: 'AaveV3EthereumEModes.NONE',
    asset: '0xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5',
  },
];

export const assetListingCustomConfig: ListingWithCustomImpl[] = [
  {
    base: {
      ...assetListingConfig[0],
      assetSymbol: 'CUSTOM_PSP',
      onchainSymbol: 'CUSTOM_PSP',
      asset: '0x1111111111111111111111111111111111111111',
      priceFeed: '0x2222222222222222222222222222222222222222',
    },
    implementations: {
      aToken: '0x3333333333333333333333333333333333333333',
      vToken: '0x4444444444444444444444444444444444444444',
    },
  },
];

// listing of a PT-style collateral-only (base LTV 0) asset, paired with an isolated e-mode.
// assetSymbol is already sanitized (the dash in the on-chain symbol is captured as `_` at cli time).
export const ptListingConfig: Listing[] = [
  {
    assetSymbol: 'PT_sUSDe_TEST',
    onchainSymbol: 'PT-sUSDe-TEST',
    decimals: 18,
    priceFeed: '0x9c823f4e19Ef68347810a9C139619273b8282b7e',
    ltv: '0',
    liqThreshold: '0',
    liqBonus: '0',
    liqProtocolFee: '10',
    enabledToBorrow: 'DISABLED',
    flashloanable: 'DISABLED',
    reserveFactor: '45',
    supplyCap: '150000000',
    borrowCap: '1',
    rateStrategyParams: {
      optimalUtilizationRate: '45',
      baseVariableBorrowRate: '0',
      variableRateSlope1: '10',
      variableRateSlope2: '300',
    },
    eModeCategory: 'AaveV3EthereumEModes.NONE',
    asset: '0xf7fB83435F455Bd970F2D9f943f4eECE1941b3e9',
  },
];

export const emodeCreations: EModeCategoryCreation[] = [
  {
    ltv: '87.71',
    liqThreshold: '89.71',
    liqBonus: '4.87',
    label: 'PT_sUSDe_TEST__Stablecoins',
    isolated: 'ENABLED',
    collateralAssets: ['PT_sUSDe_TEST', 'sUSDe'],
    borrowableAssets: ['USDC', 'USDT', 'GHO'],
  },
];

export const priceFeedsUpdateConfig: PriceFeedUpdate[] = [
  {
    asset: 'DAI',
    priceFeed: '0xae7ab96520de3a18e5e111b5eaab095312d7fe84',
  },
];

export const collateralUpdates: CollateralUpdate[] = [
  {
    asset: 'DAI',
    ltv: '0',
    liqThreshold: '',
    liqBonus: '',
    liqProtocolFee: '',
  },
  {
    asset: 'USDC',
    ltv: '77',
    liqThreshold: '80',
    liqBonus: '5',
    liqProtocolFee: '10',
  },
];

export const capsUpdates: CapsUpdate[] = [
  {
    asset: 'DAI',
    supplyCap: '1000000',
    borrowCap: '',
  },
  {
    asset: 'USDC',
    supplyCap: '2000000',
    borrowCap: '900000',
  },
];

export const emodeUpdates: EModeCategoryUpdate[] = [
  {
    eModeCategory: 2,
    ltv: '20',
    liqThreshold: '30',
    liqBonus: '5',
    label: 'label',
    isolated: 'ENABLED',
  },
  {
    eModeCategory: 'AaveV3EthereumEModes.ETH_CORRELATED',
    ltv: '',
    liqThreshold: '50',
    liqBonus: '',
    label: '',
    isolated: 'KEEP_CURRENT',
  },
];

export const rateUpdateV2: RateStrategyUpdate[] = [
  {
    asset: 'WETH',
    params: {
      optimalUtilizationRate: '',
      baseVariableBorrowRate: '6',
      variableRateSlope1: '',
      variableRateSlope2: '',
      stableRateSlope1: '',
      stableRateSlope2: '',
    },
  },
  {
    asset: 'DAI',
    params: {
      optimalUtilizationRate: '',
      baseVariableBorrowRate: '4',
      variableRateSlope1: '10',
      variableRateSlope2: '',
      stableRateSlope1: '',
      stableRateSlope2: '',
    },
  },
  {
    asset: 'USDC',
    params: {
      optimalUtilizationRate: '',
      baseVariableBorrowRate: '4',
      variableRateSlope1: '10',
      variableRateSlope2: '',
      stableRateSlope1: '',
      stableRateSlope2: '',
    },
  },
  {
    asset: 'USDT',
    params: {
      optimalUtilizationRate: '',
      baseVariableBorrowRate: '6',
      variableRateSlope1: '10',
      variableRateSlope2: '',
      stableRateSlope1: '',
      stableRateSlope2: '',
    },
  },
  {
    asset: 'WBTC',
    params: {
      optimalUtilizationRate: '',
      baseVariableBorrowRate: '5',
      variableRateSlope1: '',
      variableRateSlope2: '',
      stableRateSlope1: '',
      stableRateSlope2: '',
    },
  },
];
