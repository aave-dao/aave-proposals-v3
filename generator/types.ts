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
  V4HubAssetListing,
  V4HubAssetConfigUpdate,
  V4HubSpokeToAssetsAddition,
  V4HubSpokeConfigUpdate,
  V4HubAssetHalt,
  V4HubAssetDeactivation,
  V4HubAssetCapsReset,
  V4HubSpokeDeactivation,
  V4HubSpokeCapsReset,
  V4SpokeReserveListing,
  V4SpokeReserveConfigUpdate,
  V4SpokeLiquidationConfigUpdate,
  V4SpokeDynamicReserveConfigAddition,
  V4SpokeDynamicReserveConfigUpdate,
  V4SpokePositionManagerUpdate,
  V4RoleMembership,
  V4RoleUpdate,
  V4TargetFunctionRoleUpdate,
  V4TargetAdminDelayUpdate,
  V4PMSpokeRegistration,
  V4PMRoleRenouncement,
  VotingNetwork,
} from './features/types';
import {FlashBorrower} from './features/flashBorrower';

export type {VotingNetwork};

export const V2_MARKETS = [
  'AaveV2Ethereum',
  'AaveV2EthereumAMM',
  'AaveV2Polygon',
  'AaveV2Avalanche',
] as const satisfies readonly (keyof typeof addressBook)[];

export const V3_MARKETS = [
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
  'AaveV3XLayer',
  'AaveV3Monad',
] as const satisfies readonly (keyof typeof addressBook)[];

export const V4_MARKETS = [
  'AaveV4Base',
  'AaveV4Ethereum',
  'AaveV4Avalanche',
] as const satisfies readonly (keyof typeof addressBook)[];

export const MARKETS = [
  ...V2_MARKETS,
  ...V3_MARKETS,
  ...V4_MARKETS,
] as const satisfies readonly (keyof typeof addressBook)[];

export type MarketIdentifier = (typeof MARKETS)[number];
export type MarketIdentifierV3 = (typeof V3_MARKETS)[number];
export type MarketIdentifierV4 = (typeof V4_MARKETS)[number];

export interface Options {
  force?: boolean;
  markets: MarketIdentifier[];
  title: string;
  votingNetwork?: VOTING_NETWORK | VotingNetwork;
  // automatically generated shortName from title
  shortName: string;
  author: string;
  discussion: string;
  snapshot: string;
  configFile?: string;
  date: string;
}

export type MarketConfigs = Partial<Record<MarketIdentifier, MarketConfig>>;

export type V4GetterEntry = {
  returnType: string;
  entries: string[];
  /// Assertions over the getter's entries, one block per entry and parallel to
  /// `entries`, referencing the entry as `items[__INDEX__]`. Emitted as a single
  /// `test_<getter>Input()` once every feature contributing to the getter has been
  /// merged, so the indices match the merged array rather than one feature's slice.
  inputAsserts?: string[];
  /// Solidity expressions each yielding a `<returnType>[] memory`, appended to the
  /// getter's own entries via `arrayMerge`. Used where a helpers library already builds
  /// the array (role wiring), so the payload declares intent instead of re-listing it.
  arrayExprs?: string[];
  /// Solidity function concatenating two `<returnType>[] memory`, required with
  /// `arrayExprs` (e.g. `V4RoleWiring.merge`).
  arrayMerge?: string;
};

export type CodeArtifact = {
  code?: {
    constants?: string[];
    fn?: string[];
    execute?: string[];
    v4Getters?: Record<string, V4GetterEntry>;
  };
  test?: {
    fn?: string[];
    updatedAssets?: string[];
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
  V4_HUB_ASSET_LISTING = 'V4_HUB_ASSET_LISTING',
  V4_HUB_ASSET_CONFIG_UPDATE = 'V4_HUB_ASSET_CONFIG_UPDATE',
  V4_HUB_SPOKE_TO_ASSETS_ADDITION = 'V4_HUB_SPOKE_TO_ASSETS_ADDITION',
  V4_HUB_SPOKE_CONFIG_UPDATE = 'V4_HUB_SPOKE_CONFIG_UPDATE',
  V4_HUB_ASSET_HALT = 'V4_HUB_ASSET_HALT',
  V4_HUB_ASSET_DEACTIVATION = 'V4_HUB_ASSET_DEACTIVATION',
  V4_HUB_ASSET_CAPS_RESET = 'V4_HUB_ASSET_CAPS_RESET',
  V4_HUB_SPOKE_DEACTIVATION = 'V4_HUB_SPOKE_DEACTIVATION',
  V4_HUB_SPOKE_CAPS_RESET = 'V4_HUB_SPOKE_CAPS_RESET',
  V4_SPOKE_RESERVE_LISTING = 'V4_SPOKE_RESERVE_LISTING',
  V4_SPOKE_RESERVE_CONFIG_UPDATE = 'V4_SPOKE_RESERVE_CONFIG_UPDATE',
  V4_SPOKE_LIQUIDATION_CONFIG_UPDATE = 'V4_SPOKE_LIQUIDATION_CONFIG_UPDATE',
  V4_SPOKE_DYNAMIC_RESERVE_CONFIG_ADDITION = 'V4_SPOKE_DYNAMIC_RESERVE_CONFIG_ADDITION',
  V4_SPOKE_DYNAMIC_RESERVE_CONFIG_UPDATE = 'V4_SPOKE_DYNAMIC_RESERVE_CONFIG_UPDATE',
  V4_SPOKE_POSITION_MANAGER_UPDATE = 'V4_SPOKE_POSITION_MANAGER_UPDATE',
  V4_AM_ROLE_MEMBERSHIP = 'V4_AM_ROLE_MEMBERSHIP',
  V4_AM_ROLE_UPDATE = 'V4_AM_ROLE_UPDATE',
  V4_AM_TARGET_FUNCTION_ROLE_UPDATE = 'V4_AM_TARGET_FUNCTION_ROLE_UPDATE',
  V4_AM_TARGET_ADMIN_DELAY_UPDATE = 'V4_AM_TARGET_ADMIN_DELAY_UPDATE',
  V4_PM_SPOKE_REGISTRATION = 'V4_PM_SPOKE_REGISTRATION',
  V4_PM_ROLE_RENOUNCEMENT = 'V4_PM_ROLE_RENOUNCEMENT',
  V4_USECASE_ONBOARD_ASSET_TO_HUB = 'V4_USECASE_ONBOARD_ASSET_TO_HUB',
  V4_USECASE_ONBOARD_RESERVE_TO_SPOKE = 'V4_USECASE_ONBOARD_RESERVE_TO_SPOKE',
  V4_USECASE_TUNE_SPOKE_RISK = 'V4_USECASE_TUNE_SPOKE_RISK',
  V4_USECASE_TUNE_RESERVE_RISK = 'V4_USECASE_TUNE_RESERVE_RISK',
  V4_USECASE_WIRE_POSITION_MANAGER = 'V4_USECASE_WIRE_POSITION_MANAGER',
  V4_USECASE_MANAGE_ROLE = 'V4_USECASE_MANAGE_ROLE',
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
  cli: (args: {
    options: Options;
    market: MarketIdentifier;
    cache: MarketCache;
    configs: MarketConfig['configs'];
  }) => Promise<T>;
  build: (args: {
    options: Options;
    market: MarketIdentifier;
    cache: MarketCache;
    cfg: T;
    configs: MarketConfig['configs'];
  }) => CodeArtifact;
}

export const ENGINE_FLAGS = {
  KEEP_CURRENT: 'KEEP_CURRENT',
  KEEP_CURRENT_STRING: 'KEEP_CURRENT_STRING',
  KEEP_CURRENT_ADDRESS: 'KEEP_CURRENT_ADDRESS',
  ENABLED: 'ENABLED',
  DISABLED: 'DISABLED',
} as const;

export const AVAILABLE_VERSIONS = {V2: 'V2', V3: 'V3', V4: 'V4'} as const;

export type ConfigFile = {
  rootOptions: Options;
  marketOptions: Partial<Record<MarketIdentifier, Omit<MarketConfig, 'artifacts'>>>;
};

export type MarketCache = {blockNumber: number};

export interface MarketConfig {
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
    [FEATURE.V4_HUB_ASSET_LISTING]?: V4HubAssetListing[];
    [FEATURE.V4_HUB_ASSET_CONFIG_UPDATE]?: V4HubAssetConfigUpdate[];
    [FEATURE.V4_HUB_SPOKE_TO_ASSETS_ADDITION]?: V4HubSpokeToAssetsAddition[];
    [FEATURE.V4_HUB_SPOKE_CONFIG_UPDATE]?: V4HubSpokeConfigUpdate[];
    [FEATURE.V4_HUB_ASSET_HALT]?: V4HubAssetHalt[];
    [FEATURE.V4_HUB_ASSET_DEACTIVATION]?: V4HubAssetDeactivation[];
    [FEATURE.V4_HUB_ASSET_CAPS_RESET]?: V4HubAssetCapsReset[];
    [FEATURE.V4_HUB_SPOKE_DEACTIVATION]?: V4HubSpokeDeactivation[];
    [FEATURE.V4_HUB_SPOKE_CAPS_RESET]?: V4HubSpokeCapsReset[];
    [FEATURE.V4_SPOKE_RESERVE_LISTING]?: V4SpokeReserveListing[];
    [FEATURE.V4_SPOKE_RESERVE_CONFIG_UPDATE]?: V4SpokeReserveConfigUpdate[];
    [FEATURE.V4_SPOKE_LIQUIDATION_CONFIG_UPDATE]?: V4SpokeLiquidationConfigUpdate[];
    [FEATURE.V4_SPOKE_DYNAMIC_RESERVE_CONFIG_ADDITION]?: V4SpokeDynamicReserveConfigAddition[];
    [FEATURE.V4_SPOKE_DYNAMIC_RESERVE_CONFIG_UPDATE]?: V4SpokeDynamicReserveConfigUpdate[];
    [FEATURE.V4_SPOKE_POSITION_MANAGER_UPDATE]?: V4SpokePositionManagerUpdate[];
    [FEATURE.V4_AM_ROLE_MEMBERSHIP]?: V4RoleMembership[];
    [FEATURE.V4_AM_ROLE_UPDATE]?: V4RoleUpdate[];
    [FEATURE.V4_AM_TARGET_FUNCTION_ROLE_UPDATE]?: V4TargetFunctionRoleUpdate[];
    [FEATURE.V4_AM_TARGET_ADMIN_DELAY_UPDATE]?: V4TargetAdminDelayUpdate[];
    [FEATURE.V4_PM_SPOKE_REGISTRATION]?: V4PMSpokeRegistration[];
    [FEATURE.V4_PM_ROLE_RENOUNCEMENT]?: V4PMRoleRenouncement[];
    [FEATURE.V4_USECASE_ONBOARD_ASSET_TO_HUB]?: {
      freshHubs: string[];
      freshSpokes: string[];
      listings: V4HubAssetListing[];
      spokeAdditions: V4HubSpokeToAssetsAddition[];
    };
    [FEATURE.V4_USECASE_ONBOARD_RESERVE_TO_SPOKE]?: {
      freshHubs: string[];
      freshSpokes: string[];
      hubAssetListings: V4HubAssetListing[];
      listings: V4SpokeReserveListing[];
      updates: V4SpokeReserveConfigUpdate[];
      liquidationUpdates: V4SpokeLiquidationConfigUpdate[];
      hubSpokeAdditions: V4HubSpokeToAssetsAddition[];
      pmUpdates: V4SpokePositionManagerUpdate[];
    };
    [FEATURE.V4_USECASE_TUNE_SPOKE_RISK]?: V4HubSpokeConfigUpdate[];
    [FEATURE.V4_USECASE_TUNE_RESERVE_RISK]?: {
      reserveUpdates: V4SpokeReserveConfigUpdate[];
      liquidationUpdates: V4SpokeLiquidationConfigUpdate[];
      dynamicUpdates: V4SpokeDynamicReserveConfigUpdate[];
    };
    [FEATURE.V4_USECASE_WIRE_POSITION_MANAGER]?: {
      targetFunctionRoles: V4TargetFunctionRoleUpdate[];
      spokeActivations: V4SpokePositionManagerUpdate[];
      pmRegistrations: V4PMSpokeRegistration[];
    };
    [FEATURE.V4_USECASE_MANAGE_ROLE]?: {
      memberships: V4RoleMembership[];
      updates: V4RoleUpdate[];
    };
    [FEATURE.OTHERS]?: {};
  };
  cache: MarketCache;
  /// Custom (non-address-book) V4 entities labeled during generation, keyed by
  /// lowercased address, so a `-c` regeneration re-hydrates the label registry.
  labels?: Record<string, {label: string; address: string; kind: string}>;
}

export type Scripts = {
  defaultScript: string;
  zkSyncScript?: string;
};

export type Files = {
  jsonConfig: string;
  scripts: Scripts;
  aip: string;
  payloads: {market: MarketIdentifier; payload: string; test: string; contractName: string}[];
};
