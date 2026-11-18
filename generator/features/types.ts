import {Hex} from 'viem';
import {NumberInputValues, PercentInputValues} from '../prompts';
import {BooleanSelectValues} from '../prompts/boolPrompt';

export type VotingNetwork = 'POLYGON' | 'ETHEREUM' | 'AVALANCHE';

export interface AssetSelector {
  asset: string;
}

export interface TokenImplementations {
  aToken: Hex;
  vToken: Hex;
}

export interface CapsUpdatePartial {
  supplyCap: NumberInputValues;
  borrowCap: NumberInputValues;
}

export interface CapsUpdate extends CapsUpdatePartial, AssetSelector {}

export interface BorrowUpdatePartial {
  enabledToBorrow: BooleanSelectValues;
  flashloanable: BooleanSelectValues;
  reserveFactor: PercentInputValues;
}

export interface BorrowUpdate extends BorrowUpdatePartial, AssetSelector {}

export interface CollateralUpdatePartial {
  ltv: PercentInputValues;
  liqThreshold: PercentInputValues;
  liqBonus: PercentInputValues;
  liqProtocolFee: PercentInputValues;
}

export interface CollateralUpdate extends CollateralUpdatePartial, AssetSelector {}

export interface PriceFeedUpdatePartial {
  priceFeed: Hex;
}

export interface PriceFeedUpdate extends PriceFeedUpdatePartial, AssetSelector {}

export interface AssetEModeUpdatePartial {
  eModeCategory: string;
  collateral: BooleanSelectValues;
  borrowable: BooleanSelectValues;
  ltvzero: BooleanSelectValues;
}

export interface AssetEModeUpdate extends AssetEModeUpdatePartial, AssetSelector {}

export interface EModeCategoryPartial {
  ltv: NumberInputValues;
  liqThreshold: NumberInputValues;
  liqBonus: NumberInputValues;
  label: string;
}

export interface EModeCategoryUpdate extends EModeCategoryPartial {
  // library accessor or new id
  eModeCategory: string | number;
  isolated: BooleanSelectValues;
}

export interface EModeCategoryCreation extends EModeCategoryPartial {
  borrowableAssets: string[];
  collateralAssets: string[];
  isolated: Exclude<BooleanSelectValues, 'KEEP_CURRENT'>;
}

export interface RateStrategyParams {
  optimalUtilizationRate: string;
  baseVariableBorrowRate: string;
  variableRateSlope1: string;
  variableRateSlope2: string;
  stableRateSlope1?: string;
  stableRateSlope2?: string;
  baseStableRateOffset?: string;
  stableRateExcessOffset?: string;
  optimalStableToTotalDebtRatio?: string;
}

export interface RateStrategyUpdate extends AssetSelector {
  params: RateStrategyParams;
}

export interface Listing
  extends CollateralUpdatePartial, BorrowUpdatePartial, CapsUpdatePartial, PriceFeedUpdatePartial {
  asset: Hex;
  assetSymbol: string;
  rateStrategyParams: RateStrategyParams;
  eModeCategory: string;
  decimals: number;
}

export interface ListingWithCustomImpl {
  base: Listing;
  implementations: TokenImplementations;
}

export interface TokenStream {
  asset: Hex;
  receiver: Hex;
  duration: string;
  amount: string;
}

export interface FreezeUpdate extends AssetSelector {
  shouldBeFrozen: boolean;
}

export interface EmissionUpdate {
  asset: Hex;
  symbol: string;
  admin: Hex;
}

export type Sentinel =
  | {kind: 'literal'; value: string | number | bigint | boolean}
  | {
      kind: 'keepCurrent';
      sentinel:
        | 'KEEP_CURRENT'
        | 'KEEP_CURRENT_ADDRESS'
        | 'KEEP_CURRENT_UINT64'
        | 'KEEP_CURRENT_UINT32'
        | 'KEEP_CURRENT_UINT16'
        | 'ENABLED'
        | 'DISABLED';
    };

export interface V4InterestRateData {
  optimalUsageRatio: Sentinel;
  baseDrawnRate: Sentinel;
  rateGrowthBeforeOptimal: Sentinel;
  rateGrowthAfterOptimal: Sentinel;
}

export interface V4TokenizationSpokeConfig {
  addCap: string;
  proxyAdminOwner: string;
  name: string;
  symbol: string;
}

export interface V4HubAssetListing {
  hubLib: string;
  hub: string;
  underlying: string;
  /// Codegen expression: an address-book accessor or a labeled constant.
  feeReceiver: string;
  /// Human percentage (e.g. `20` for 20%); converted to BPS at build time.
  liquidityFee: string;
  /// Codegen expression: an `<Market>IRStrategies.<KEY>` accessor, or a raw
  /// address literal that build emits as a per-listing named constant.
  irStrategy: string;
  /// Collected interest rate data; unset when `irPreset` supplies it.
  irData?: V4InterestRateData;
  /// Conventional preset filling `irData` from `V4EngineDefaults` instead of collected values.
  irPreset?: 'nonBorrowable';
  tokenization?: V4TokenizationSpokeConfig;
}

export interface V4HubAssetConfigUpdate {
  hubLib: string;
  hub: string;
  underlying: string;
  liquidityFee: Sentinel;
  feeReceiver: Sentinel;
  irStrategy: Sentinel;
  irData: V4InterestRateData;
  reinvestmentController: Sentinel;
}

export interface V4SpokeConfigEntry {
  underlying: string;
  addCap: string;
  drawCap: string;
  riskPremiumThreshold: string;
  active: boolean;
  halted: boolean;
}

export interface V4HubSpokeToAssetsAddition {
  hubLib: string;
  hub: string;
  spoke: string;
  assets: V4SpokeConfigEntry[];
}

export interface V4HubSpokeConfigUpdate {
  hubLib: string;
  hub: string;
  underlying: string;
  spoke: string;
  addCap: Sentinel;
  drawCap: Sentinel;
  riskPremiumThreshold: Sentinel;
  active: Sentinel;
  halted: Sentinel;
}

export interface V4HubAssetHalt {
  hubLib: string;
  hub: string;
  underlying: string;
}

export interface V4HubAssetDeactivation extends V4HubAssetHalt {}

export interface V4HubAssetCapsReset extends V4HubAssetHalt {}

export interface V4HubSpokeDeactivation {
  hubLib: string;
  hub: string;
  spoke: string;
}

export interface V4HubSpokeCapsReset extends V4HubSpokeDeactivation {}

export interface V4ReserveConfig {
  collateralRisk: string;
  paused: boolean;
  frozen: boolean;
  borrowable: boolean;
  receiveSharesEnabled: boolean;
}

export interface V4DynamicReserveConfig {
  collateralFactor: string;
  maxLiquidationBonus: string;
  liquidationFee: string;
}

export interface V4SpokeReserveListing {
  spokeLib: string;
  spoke: string;
  hub: string;
  underlying: string;
  priceSource: Hex;
  config: V4ReserveConfig;
  dynamicConfig: V4DynamicReserveConfig;
}

export interface V4SpokeReserveConfigUpdate {
  spokeLib: string;
  spoke: string;
  hub: string;
  underlying: string;
  priceSource: Sentinel;
  collateralRisk: Sentinel;
  paused: Sentinel;
  frozen: Sentinel;
  borrowable: Sentinel;
  receiveSharesEnabled: Sentinel;
}

export interface V4SpokeLiquidationConfigUpdate {
  spokeLib: string;
  spoke: string;
  targetHealthFactor: Sentinel;
  healthFactorForMaxBonus: Sentinel;
  liquidationBonusFactor: Sentinel;
}

export interface V4SpokeDynamicReserveConfigAddition {
  spokeLib: string;
  spoke: string;
  hub: string;
  underlying: string;
  dynamicConfig: V4DynamicReserveConfig;
}

export interface V4SpokeDynamicReserveConfigUpdate {
  spokeLib: string;
  spoke: string;
  hub: string;
  underlying: string;
  dynamicConfigKey: string;
  collateralFactor: Sentinel;
  maxLiquidationBonus: Sentinel;
  liquidationFee: Sentinel;
}

export interface V4SpokePositionManagerUpdate {
  spokeLib: string;
  spoke: string;
  positionManager: Hex;
  active: boolean;
}

export interface V4RoleMembership {
  roleId: string;
  account: Hex;
  granted: boolean;
  executionDelay: string;
}

export interface V4RoleUpdate {
  roleId: string;
  admin: Sentinel;
  guardian: Sentinel;
  grantDelay: Sentinel;
  label: string;
  labelUpdate: boolean;
}

export interface V4TargetFunctionRoleUpdate {
  /// Target: a raw address (emitted as a named constant) or a codegen expr.
  target: string;
  /// Explicit bytes4 selector literals.
  selectors: string[];
  /// Role id: a number, or an expr like `Roles.SPOKE_CONFIGURATOR_ROLE`.
  roleId: string;
}

export interface V4TargetAdminDelayUpdate {
  target: Hex;
  newDelay: string;
}

export interface V4PMSpokeRegistration {
  positionManager: Hex;
  spoke: string;
  registered: boolean;
}

export interface V4PMRoleRenouncement {
  positionManager: Hex;
  spoke: string;
  user: Hex;
}
