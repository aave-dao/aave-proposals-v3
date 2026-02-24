import * as addressBook from '@aave-dao/aave-address-book';
import {
  AssetEModeUpdate,
  BorrowUpdate,
  CapsUpdate,
  CollateralUpdate,
  EModeCategoryUpdate,
  Listing,
  ListingWithCustomImpl,
  PriceFeedUpdate,
  RateStrategyUpdate,
  FreezeUpdate,
  EmissionUpdate,
  EModeCategoryCreation,
} from './features/types';
import {FlashBorrower} from './features/flashBorrower';

export const V2_POOLS = [
  'AaveV2Ethereum',
  'AaveV2EthereumAMM',
  'AaveV2Polygon',
  'AaveV2Avalanche',
] as const satisfies readonly (keyof typeof addressBook)[];

export const V3_POOLS = [
  'AaveV3Ethereum',
  'AaveV3EthereumLido',
  'AaveV3EthereumEtherFi',
  'AaveV3Polygon',
  'AaveV3Avalanche',
  'AaveV3Optimism',
  'AaveV3Arbitrum',
  'AaveV3Metis',
  'AaveV3Base',
  'AaveV3Gnosis',
  'AaveV3Scroll',
  'AaveV3BNB',
  'AaveV3ZkSync',
  'AaveV3Linea',
  'AaveV3Celo',
  'AaveV3Sonic',
  'AaveV3Soneium',
  'AaveV3InkWhitelabel',
  'AaveV3Plasma',
  'AaveV3Mantle',
  'AaveV3MegaEth',
] as const satisfies readonly (keyof typeof addressBook)[];

export const POOLS = [
  ...V2_POOLS,
  ...V3_POOLS,
] as const satisfies readonly (keyof typeof addressBook)[];

export type PoolIdentifier = (typeof POOLS)[number];
export type PoolIdentifierV3 = (typeof V3_POOLS)[number];

export interface Options {
  force?: boolean;
  pools: PoolIdentifier[];
  title: string;
  votingNetwork?: VOTING_NETWORK;
  // automatically generated shortName from title
  shortName: string;
  author: string;
  discussion: string;
  snapshot: string;
  configFile?: string;
  date: string;
}

export type PoolConfigs = Partial<Record<PoolIdentifier, PoolConfig>>;

export type CodeArtifact = {
  code?: {
    constants?: string[];
    fn?: string[];
    execute?: string[];
  };
  test?: {
    fn?: string[];
  };
  aip?: {
    specification: string[];
  };
};

export enum FEATURE {
  ASSET_LISTING = 'ASSET_LISTING',
  ASSET_LISTING_CUSTOM = 'ASSET_LISTING_CUSTOM',
  BORROWS_UPDATE = 'BORROWS_UPDATE',
  CAPS_UPDATE = 'CAPS_UPDATE',
  COLLATERALS_UPDATE = 'COLLATERALS_UPDATE',
  EMODES_ASSETS = 'EMODES_ASSETS',
  EMODES_UPDATES = 'EMODES_UPDATES',
  EMODES_CREATION = 'EMODES_CREATION',
  FLASH_BORROWER = 'FLASH_BORROWER',
  PRICE_FEEDS_UPDATE = 'PRICE_FEEDS_UPDATE',
  RATE_UPDATE_V3 = 'RATE_UPDATE_V3',
  RATE_UPDATE_V2 = 'RATE_UPDATE_V2',
  FREEZE = 'FREEZE',
  EMISSION = 'EMISSION',
  OTHERS = 'OTHERS',
}

export enum VOTING_NETWORK {
  POLYGON = 'POLYGON',
  ETHEREUM = 'ETHEREUM',
  AVALANCHE = 'AVALANCHE',
}

export interface FeatureModule<T extends {} = {}> {
  description: string;
  value: FEATURE;
  cli: (args: {options: Options; pool: PoolIdentifier; cache: PoolCache}) => Promise<T>;
  build: (args: {options: Options; pool: PoolIdentifier; cache: PoolCache; cfg: T}) => CodeArtifact;
}

export const ENGINE_FLAGS = {
  KEEP_CURRENT: 'KEEP_CURRENT',
  KEEP_CURRENT_STRING: 'KEEP_CURRENT_STRING',
  KEEP_CURRENT_ADDRESS: 'KEEP_CURRENT_ADDRESS',
  ENABLED: 'ENABLED',
  DISABLED: 'DISABLED',
} as const;

export const AVAILABLE_VERSIONS = {V2: 'V2', V3: 'V3'} as const;

export type ConfigFile = {
  rootOptions: Options;
  poolOptions: Partial<Record<PoolIdentifier, Omit<PoolConfig, 'artifacts'>>>;
};

export type PoolCache = {blockNumber: number};

export interface PoolConfig {
  artifacts: CodeArtifact[];
  configs: {
    [FEATURE.ASSET_LISTING]?: Listing[];
    [FEATURE.ASSET_LISTING_CUSTOM]?: ListingWithCustomImpl[];
    [FEATURE.BORROWS_UPDATE]?: BorrowUpdate[];
    [FEATURE.CAPS_UPDATE]?: CapsUpdate[];
    [FEATURE.COLLATERALS_UPDATE]?: CollateralUpdate[];
    [FEATURE.EMODES_ASSETS]?: AssetEModeUpdate[];
    [FEATURE.EMODES_CREATION]?: EModeCategoryCreation[];
    [FEATURE.EMODES_UPDATES]?: EModeCategoryUpdate[];
    [FEATURE.FLASH_BORROWER]?: FlashBorrower;
    [FEATURE.PRICE_FEEDS_UPDATE]?: PriceFeedUpdate[];
    [FEATURE.RATE_UPDATE_V3]?: RateStrategyUpdate[]; // TODO: type could be improved
    [FEATURE.RATE_UPDATE_V2]?: RateStrategyUpdate[];
    [FEATURE.FREEZE]?: FreezeUpdate[];
    [FEATURE.EMISSION]?: EmissionUpdate[];
    [FEATURE.OTHERS]?: {};
  };
  cache: PoolCache;
}

export type Scripts = {
  defaultScript: string;
  zkSyncScript?: string;
};

export type Files = {
  jsonConfig: string;
  scripts: Scripts;
  aip: string;
  payloads: {pool: PoolIdentifier; payload: string; test: string; contractName: string}[];
};
