import {FEATURE, MarketConfigs, Options} from '../../types';
import {hubAssetListing} from './hub/hubAssetListing';
import {hubAssetConfigUpdate} from './hub/hubAssetConfigUpdate';
import {hubSpokeToAssetsAddition} from './hub/hubSpokeToAssetsAddition';
import {hubSpokeConfigUpdate} from './hub/hubSpokeConfigUpdate';
import {hubAssetHalt} from './hub/hubAssetHalt';
import {hubAssetDeactivation} from './hub/hubAssetDeactivation';
import {hubAssetCapsReset} from './hub/hubAssetCapsReset';
import {hubSpokeDeactivation} from './hub/hubSpokeDeactivation';
import {hubSpokeCapsReset} from './hub/hubSpokeCapsReset';
import {spokeReserveListing} from './spoke/spokeReserveListing';
import {spokeReserveConfigUpdate} from './spoke/spokeReserveConfigUpdate';
import {spokeLiquidationConfigUpdate} from './spoke/spokeLiquidationConfigUpdate';
import {spokeDynamicReserveConfigAddition} from './spoke/spokeDynamicReserveConfigAddition';
import {spokeDynamicReserveConfigUpdate} from './spoke/spokeDynamicReserveConfigUpdate';
import {spokePositionManagerUpdate} from './spoke/spokePositionManagerUpdate';
import {accessManagerRoleMembership} from './access/accessManagerRoleMembership';
import {accessManagerRoleUpdate} from './access/accessManagerRoleUpdate';
import {accessManagerTargetFunctionRoleUpdate} from './access/accessManagerTargetFunctionRoleUpdate';
import {accessManagerTargetAdminDelayUpdate} from './access/accessManagerTargetAdminDelayUpdate';
import {positionManagerSpokeRegistration} from './positionManager/positionManagerSpokeRegistration';
import {positionManagerRoleRenouncement} from './positionManager/positionManagerRoleRenouncement';
import {onboardAssetToHub} from './bundles/onboardAssetToHub';
import {onboardReserveToSpoke} from './bundles/onboardReserveToSpoke';
import {tuneSpokeRisk} from './bundles/tuneSpokeRisk';
import {tuneReserveRisk} from './bundles/tuneReserveRisk';
import {wirePositionManager} from './bundles/wirePositionManager';
import {manageRole} from './bundles/manageRole';
import {
  literal,
  keepCurrent,
  keepCurrentAddress,
  keepCurrentUint16,
  keepCurrentUint32,
  keepCurrentUint64,
  enabled,
  disabled,
} from './sentinels';
import {
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
} from '../types';

const HUB = 'AaveV4EthereumHubs.CORE_HUB';
const SPOKE = 'AaveV4EthereumSpokes.MAIN_SPOKE';
const ASSET = 'AaveV4EthereumAssets.WETH_UNDERLYING';
const RESERVE_ASSET = 'AaveV4EthereumAssets.USDC_UNDERLYING';
const PM = '0x1111111111111111111111111111111111111111';
const ADDR = '0x2222222222222222222222222222222222222222';
// fresh deploys are by definition not in the address book, so they are raw addresses:
// a book entity here would make the generated wiring test compare a hub or spoke
// against itself instead of against the market's already-wired reference
const FRESH_HUB = '0x3333333333333333333333333333333333333333';
const FRESH_SPOKE = '0x4444444444444444444444444444444444444444';

export type Fixture = {options: Options; marketConfigs: MarketConfigs};

/// Every standalone module exercised once. Fixtures are factories because
/// `generateFiles` mutates the market config it is handed.
export function allModulesFixture(): Fixture {
  const options: Options = {
    markets: ['AaveV4Ethereum'],
    title: 'V4 every action',
    shortName: 'V4Every',
    date: '20260521',
    author: 'test',
    discussion: 'test',
    snapshot: 'test',
  };

  const hubAssetListingCfg: V4HubAssetListing[] = [
    {
      hubLib: HUB,
      hub: HUB,
      underlying: ASSET,
      feeReceiver: ADDR,
      liquidityFee: '1',
      irStrategy: ADDR,
      irData: {
        optimalUsageRatio: literal('80'),
        baseDrawnRate: literal('0'),
        rateGrowthBeforeOptimal: literal('4'),
        rateGrowthAfterOptimal: literal('60'),
      },
      tokenization: {
        addCap: '1000',
        proxyAdminOwner: 'GovernanceV3Ethereum.EXECUTOR_LVL_1',
        // a quote and a backslash, both of which have to survive into a Solidity literal
        name: "TS\\'x",
        symbol: 'TS',
      },
    },
    {
      hubLib: HUB,
      hub: HUB,
      underlying: RESERVE_ASSET,
      feeReceiver: ADDR,
      liquidityFee: '0',
      irStrategy: ADDR,
      irPreset: 'nonBorrowable',
      // a nonzero addCap the preset has to override
      tokenization: {
        addCap: '1000',
        proxyAdminOwner: 'GovernanceV3Ethereum.EXECUTOR_LVL_1',
        name: 'TS2',
        symbol: 'TS2',
      },
    },
  ];

  const hubAssetConfigUpdateCfg: V4HubAssetConfigUpdate[] = [
    {
      hubLib: HUB,
      hub: HUB,
      underlying: ASSET,
      liquidityFee: literal('2'),
      feeReceiver: keepCurrentAddress(),
      irStrategy: keepCurrentAddress(),
      irData: {
        optimalUsageRatio: keepCurrentUint16(),
        baseDrawnRate: keepCurrentUint32(),
        rateGrowthBeforeOptimal: keepCurrentUint32(),
        rateGrowthAfterOptimal: keepCurrentUint32(),
      },
      reinvestmentController: keepCurrentAddress(),
    },
  ];

  const hubSpokeToAssetsAdditionCfg: V4HubSpokeToAssetsAddition[] = [
    {
      hubLib: HUB,
      hub: HUB,
      spoke: SPOKE,
      assets: [
        {
          underlying: ASSET,
          addCap: '1000',
          drawCap: '500',
          riskPremiumThreshold: '1',
          active: true,
          halted: false,
        },
      ],
    },
  ];

  const hubSpokeConfigUpdateCfg: V4HubSpokeConfigUpdate[] = [
    {
      hubLib: HUB,
      hub: HUB,
      underlying: ASSET,
      spoke: SPOKE,
      addCap: literal('1_000_000'),
      drawCap: literal('500_000'),
      riskPremiumThreshold: keepCurrent(),
      active: enabled(),
      halted: disabled(),
    },
  ];

  const trivial = (kind: 'asset' | 'spoke') =>
    kind === 'asset'
      ? [{hubLib: HUB, hub: HUB, underlying: ASSET}]
      : [{hubLib: HUB, hub: HUB, spoke: SPOKE}];

  const hubAssetHaltCfg = trivial('asset') as V4HubAssetHalt[];
  const hubAssetDeactivationCfg = trivial('asset') as V4HubAssetDeactivation[];
  const hubAssetCapsResetCfg = trivial('asset') as V4HubAssetCapsReset[];
  const hubSpokeDeactivationCfg = trivial('spoke') as V4HubSpokeDeactivation[];
  const hubSpokeCapsResetCfg = trivial('spoke') as V4HubSpokeCapsReset[];

  const spokeReserveListingCfg: V4SpokeReserveListing[] = [
    {
      spokeLib: SPOKE,
      spoke: SPOKE,
      hub: HUB,
      underlying: ASSET,
      priceSource: ADDR,
      config: {
        collateralRisk: '0',
        paused: false,
        frozen: false,
        borrowable: true,
        receiveSharesEnabled: true,
      },
      dynamicConfig: {
        collateralFactor: '80',
        maxLiquidationBonus: '105',
        liquidationFee: '1',
      },
    },
  ];

  const spokeReserveConfigUpdateCfg: V4SpokeReserveConfigUpdate[] = [
    {
      spokeLib: SPOKE,
      spoke: SPOKE,
      hub: HUB,
      underlying: ASSET,
      priceSource: keepCurrentAddress(),
      collateralRisk: keepCurrent(),
      paused: keepCurrent(),
      frozen: disabled(),
      borrowable: enabled(),
      receiveSharesEnabled: keepCurrent(),
    },
  ];

  const spokeLiquidationConfigUpdateCfg: V4SpokeLiquidationConfigUpdate[] = [
    {
      spokeLib: SPOKE,
      spoke: SPOKE,
      targetHealthFactor: literal('1.5'),
      healthFactorForMaxBonus: keepCurrent(),
      liquidationBonusFactor: literal('100'),
    },
  ];

  const spokeDynamicReserveConfigAdditionCfg: V4SpokeDynamicReserveConfigAddition[] = [
    {
      spokeLib: SPOKE,
      spoke: SPOKE,
      hub: HUB,
      underlying: ASSET,
      dynamicConfig: {collateralFactor: '75', maxLiquidationBonus: '105', liquidationFee: '1'},
    },
  ];

  const spokeDynamicReserveConfigUpdateCfg: V4SpokeDynamicReserveConfigUpdate[] = [
    {
      spokeLib: SPOKE,
      spoke: SPOKE,
      hub: HUB,
      underlying: ASSET,
      dynamicConfigKey: '1',
      collateralFactor: literal('77'),
      maxLiquidationBonus: keepCurrent(),
      liquidationFee: keepCurrent(),
    },
  ];

  const spokePositionManagerUpdateCfg: V4SpokePositionManagerUpdate[] = [
    {spokeLib: SPOKE, spoke: SPOKE, positionManager: PM, active: true},
  ];

  const roleMembershipCfg: V4RoleMembership[] = [
    {roleId: '1', account: ADDR, granted: true, executionDelay: '0'},
  ];

  const roleUpdateCfg: V4RoleUpdate[] = [
    {
      roleId: '1',
      admin: keepCurrentUint64(),
      guardian: literal('2'),
      grantDelay: keepCurrentUint32(),
      label: 'admin',
      labelUpdate: false,
    },
  ];

  const targetFunctionRoleUpdateCfg: V4TargetFunctionRoleUpdate[] = [
    {target: ADDR, selectors: ['0x12345678'], roleId: '1'},
  ];

  const targetAdminDelayUpdateCfg: V4TargetAdminDelayUpdate[] = [{target: ADDR, newDelay: '3600'}];

  const pmSpokeRegistrationCfg: V4PMSpokeRegistration[] = [
    {positionManager: PM, spoke: SPOKE, registered: true},
  ];

  const pmRoleRenouncementCfg: V4PMRoleRenouncement[] = [
    {positionManager: PM, spoke: SPOKE, user: ADDR},
  ];

  const ctx = {
    options,
    market: 'AaveV4Ethereum' as const,
    cache: {blockNumber: 42},
    configs: {},
  };
  const artifacts = [
    hubAssetListing.build({...ctx, cfg: hubAssetListingCfg}),
    hubAssetConfigUpdate.build({...ctx, cfg: hubAssetConfigUpdateCfg}),
    hubSpokeToAssetsAddition.build({...ctx, cfg: hubSpokeToAssetsAdditionCfg}),
    hubSpokeConfigUpdate.build({...ctx, cfg: hubSpokeConfigUpdateCfg}),
    hubAssetHalt.build({...ctx, cfg: hubAssetHaltCfg}),
    hubAssetDeactivation.build({...ctx, cfg: hubAssetDeactivationCfg}),
    hubAssetCapsReset.build({...ctx, cfg: hubAssetCapsResetCfg}),
    hubSpokeDeactivation.build({...ctx, cfg: hubSpokeDeactivationCfg}),
    hubSpokeCapsReset.build({...ctx, cfg: hubSpokeCapsResetCfg}),
    spokeReserveListing.build({...ctx, cfg: spokeReserveListingCfg}),
    spokeReserveConfigUpdate.build({...ctx, cfg: spokeReserveConfigUpdateCfg}),
    spokeLiquidationConfigUpdate.build({...ctx, cfg: spokeLiquidationConfigUpdateCfg}),
    spokeDynamicReserveConfigAddition.build({...ctx, cfg: spokeDynamicReserveConfigAdditionCfg}),
    spokeDynamicReserveConfigUpdate.build({...ctx, cfg: spokeDynamicReserveConfigUpdateCfg}),
    spokePositionManagerUpdate.build({...ctx, cfg: spokePositionManagerUpdateCfg}),
    accessManagerRoleMembership.build({...ctx, cfg: roleMembershipCfg}),
    accessManagerRoleUpdate.build({...ctx, cfg: roleUpdateCfg}),
    accessManagerTargetFunctionRoleUpdate.build({...ctx, cfg: targetFunctionRoleUpdateCfg}),
    accessManagerTargetAdminDelayUpdate.build({...ctx, cfg: targetAdminDelayUpdateCfg}),
    positionManagerSpokeRegistration.build({...ctx, cfg: pmSpokeRegistrationCfg}),
    positionManagerRoleRenouncement.build({...ctx, cfg: pmRoleRenouncementCfg}),
  ];
  const marketConfigs: MarketConfigs = {
    ['AaveV4Ethereum']: {
      artifacts,
      configs: {
        [FEATURE.V4_HUB_ASSET_LISTING]: hubAssetListingCfg,
        [FEATURE.V4_HUB_ASSET_CONFIG_UPDATE]: hubAssetConfigUpdateCfg,
        [FEATURE.V4_HUB_SPOKE_TO_ASSETS_ADDITION]: hubSpokeToAssetsAdditionCfg,
        [FEATURE.V4_HUB_SPOKE_CONFIG_UPDATE]: hubSpokeConfigUpdateCfg,
        [FEATURE.V4_HUB_ASSET_HALT]: hubAssetHaltCfg,
        [FEATURE.V4_HUB_ASSET_DEACTIVATION]: hubAssetDeactivationCfg,
        [FEATURE.V4_HUB_ASSET_CAPS_RESET]: hubAssetCapsResetCfg,
        [FEATURE.V4_HUB_SPOKE_DEACTIVATION]: hubSpokeDeactivationCfg,
        [FEATURE.V4_HUB_SPOKE_CAPS_RESET]: hubSpokeCapsResetCfg,
        [FEATURE.V4_SPOKE_RESERVE_LISTING]: spokeReserveListingCfg,
        [FEATURE.V4_SPOKE_RESERVE_CONFIG_UPDATE]: spokeReserveConfigUpdateCfg,
        [FEATURE.V4_SPOKE_LIQUIDATION_CONFIG_UPDATE]: spokeLiquidationConfigUpdateCfg,
        [FEATURE.V4_SPOKE_DYNAMIC_RESERVE_CONFIG_ADDITION]: spokeDynamicReserveConfigAdditionCfg,
        [FEATURE.V4_SPOKE_DYNAMIC_RESERVE_CONFIG_UPDATE]: spokeDynamicReserveConfigUpdateCfg,
        [FEATURE.V4_SPOKE_POSITION_MANAGER_UPDATE]: spokePositionManagerUpdateCfg,
        [FEATURE.V4_AM_ROLE_MEMBERSHIP]: roleMembershipCfg,
        [FEATURE.V4_AM_ROLE_UPDATE]: roleUpdateCfg,
        [FEATURE.V4_AM_TARGET_FUNCTION_ROLE_UPDATE]: targetFunctionRoleUpdateCfg,
        [FEATURE.V4_AM_TARGET_ADMIN_DELAY_UPDATE]: targetAdminDelayUpdateCfg,
        [FEATURE.V4_PM_SPOKE_REGISTRATION]: pmSpokeRegistrationCfg,
        [FEATURE.V4_PM_ROLE_RENOUNCEMENT]: pmRoleRenouncementCfg,
      },
      cache: {blockNumber: 42},
    },
  };
  return {options, marketConfigs};
}

/// Every use-case bundle exercised once. Two bundles contribute to the same modules
/// (hub asset listing, spoke-to-assets addition), which is the overlap that the
/// generated payload and test have to survive.
export function useCasesFixture(): Fixture {
  const options: Options = {
    markets: ['AaveV4Ethereum'],
    title: 'V4 every use-case',
    shortName: 'V4EveryUseCase',
    date: '20260521',
    author: 'test',
    discussion: 'test',
    snapshot: 'test',
  };

  const ctx = {
    options,
    market: 'AaveV4Ethereum' as const,
    cache: {blockNumber: 42},
    configs: {},
  };

  const onboardAssetCfg = {
    freshHubs: [FRESH_HUB],
    freshSpokes: [],
    listings: [
      {
        hubLib: HUB,
        hub: HUB,
        underlying: ASSET,
        feeReceiver: ADDR as `0x${string}`,
        liquidityFee: '1',
        irStrategy: ADDR as `0x${string}`,
        irData: {
          optimalUsageRatio: literal('80'),
          baseDrawnRate: literal('0'),
          rateGrowthBeforeOptimal: literal('4'),
          rateGrowthAfterOptimal: literal('60'),
        },
        tokenization: undefined,
      },
    ],
    spokeAdditions: [
      {
        hubLib: HUB,
        hub: HUB,
        spoke: SPOKE,
        assets: [
          {
            underlying: ASSET,
            addCap: '1000',
            drawCap: '500',
            riskPremiumThreshold: '1',
            active: true,
            halted: false,
          },
        ],
      },
    ],
  };

  const onboardReserveCfg = {
    freshHubs: [],
    freshSpokes: [FRESH_SPOKE],
    hubAssetListings: [
      {
        hubLib: HUB,
        hub: HUB,
        underlying: RESERVE_ASSET,
        feeReceiver: ADDR as `0x${string}`,
        liquidityFee: '1',
        irStrategy: ADDR as `0x${string}`,
        irData: {
          optimalUsageRatio: literal('80'),
          baseDrawnRate: literal('0'),
          rateGrowthBeforeOptimal: literal('4'),
          rateGrowthAfterOptimal: literal('60'),
        },
        tokenization: undefined,
      },
    ],
    listings: [
      {
        spokeLib: SPOKE,
        spoke: SPOKE,
        hub: HUB,
        underlying: RESERVE_ASSET,
        priceSource: ADDR as `0x${string}`,
        config: {
          collateralRisk: '0',
          paused: false,
          frozen: false,
          borrowable: true,
          receiveSharesEnabled: true,
        },
        dynamicConfig: {
          collateralFactor: '80',
          maxLiquidationBonus: '105',
          liquidationFee: '1',
        },
      },
    ],
    updates: [],
    liquidationUpdates: [],
    hubSpokeAdditions: [
      {
        hubLib: HUB,
        hub: HUB,
        spoke: SPOKE,
        assets: [
          {
            underlying: RESERVE_ASSET,
            addCap: '1000',
            drawCap: '500',
            riskPremiumThreshold: '1',
            active: true,
            halted: false,
          },
        ],
      },
    ],
    pmUpdates: [],
  };

  const tuneSpokeCfg = [
    {
      hubLib: HUB,
      hub: HUB,
      underlying: ASSET,
      spoke: SPOKE,
      addCap: literal('1_000_000'),
      drawCap: keepCurrent(),
      riskPremiumThreshold: keepCurrent(),
      active: enabled(),
      halted: keepCurrent(),
    },
  ];

  const tuneReserveCfg = {
    reserveUpdates: [
      {
        spokeLib: SPOKE,
        spoke: SPOKE,
        hub: HUB,
        underlying: ASSET,
        priceSource: keepCurrentAddress(),
        collateralRisk: literal('70'),
        paused: keepCurrent(),
        frozen: keepCurrent(),
        borrowable: keepCurrent(),
        receiveSharesEnabled: keepCurrent(),
      },
    ],
    liquidationUpdates: [
      {
        spokeLib: SPOKE,
        spoke: SPOKE,
        targetHealthFactor: literal('1.5'),
        healthFactorForMaxBonus: keepCurrent(),
        liquidationBonusFactor: literal('100'),
      },
    ],
    dynamicUpdates: [
      {
        spokeLib: SPOKE,
        spoke: SPOKE,
        hub: HUB,
        underlying: ASSET,
        dynamicConfigKey: '1',
        collateralFactor: literal('77'),
        maxLiquidationBonus: keepCurrent(),
        liquidationFee: keepCurrent(),
      },
    ],
  };

  const wirePmCfg = {
    targetFunctionRoles: [{target: PM as `0x${string}`, selectors: ['0x12345678'], roleId: '1'}],
    spokeActivations: [
      {spokeLib: SPOKE, spoke: SPOKE, positionManager: PM as `0x${string}`, active: true},
    ],
    pmRegistrations: [{positionManager: PM as `0x${string}`, spoke: SPOKE, registered: true}],
  };

  const manageRoleCfg = {
    memberships: [
      {
        roleId: '1',
        account: ADDR as `0x${string}`,
        granted: true,
        executionDelay: '0',
      },
    ],
    updates: [
      {
        roleId: '1',
        admin: keepCurrentUint64(),
        guardian: literal('2'),
        grantDelay: keepCurrentUint32(),
        label: 'admin',
        labelUpdate: false,
      },
    ],
  };

  const artifacts = [
    onboardAssetToHub.build({...ctx, cfg: onboardAssetCfg}),
    onboardReserveToSpoke.build({...ctx, cfg: onboardReserveCfg}),
    tuneSpokeRisk.build({...ctx, cfg: tuneSpokeCfg}),
    tuneReserveRisk.build({...ctx, cfg: tuneReserveCfg}),
    wirePositionManager.build({...ctx, cfg: wirePmCfg}),
    manageRole.build({...ctx, cfg: manageRoleCfg}),
  ];

  const marketConfigs: MarketConfigs = {
    ['AaveV4Ethereum']: {
      artifacts,
      configs: {
        [FEATURE.V4_USECASE_ONBOARD_ASSET_TO_HUB]: onboardAssetCfg,
        [FEATURE.V4_USECASE_ONBOARD_RESERVE_TO_SPOKE]: onboardReserveCfg,
        [FEATURE.V4_USECASE_TUNE_SPOKE_RISK]: tuneSpokeCfg,
        [FEATURE.V4_USECASE_TUNE_RESERVE_RISK]: tuneReserveCfg,
        [FEATURE.V4_USECASE_WIRE_POSITION_MANAGER]: wirePmCfg,
        [FEATURE.V4_USECASE_MANAGE_ROLE]: manageRoleCfg,
      },
      cache: {blockNumber: 42},
    },
  };
  return {options, marketConfigs};
}

/// Base smoke fixture exercises the native-EVM test setup and split execution/e2e path.
export function baseFixture(): Fixture {
  const options: Options = {
    markets: ['AaveV4Base'],
    title: 'V4 Base spoke config update',
    shortName: 'V4BaseTestSetup',
    date: '20260521',
    author: 'test',
    discussion: 'test',
    snapshot: 'test',
  };
  const cfg: V4HubSpokeConfigUpdate[] = [
    {
      hubLib: 'AaveV4BaseHubs.EQUITIES_HUB',
      hub: 'AaveV4BaseHubs.EQUITIES_HUB',
      spoke: 'AaveV4BaseSpokes.MAG7_SPOKE',
      underlying: 'AaveV4BaseAssets.USDC_UNDERLYING',
      addCap: keepCurrent(),
      drawCap: keepCurrent(),
      riskPremiumThreshold: literal('1100'),
      active: keepCurrent(),
      halted: keepCurrent(),
    },
  ];
  const configs = {[FEATURE.V4_HUB_SPOKE_CONFIG_UPDATE]: cfg};
  return {
    options,
    marketConfigs: {
      AaveV4Base: {
        configs,
        artifacts: [
          hubSpokeConfigUpdate.build({
            options,
            market: 'AaveV4Base',
            cfg,
            configs,
            cache: {blockNumber: 52669984},
          }),
        ],
        cache: {blockNumber: 52669984},
      },
    },
  };
}
