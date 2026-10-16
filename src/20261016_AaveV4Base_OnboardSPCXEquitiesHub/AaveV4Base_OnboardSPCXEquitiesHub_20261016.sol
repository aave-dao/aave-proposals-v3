// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Base, AaveV4BaseHubs, AaveV4BaseIRStrategies, AaveV4BaseSpokes, AaveV4BaseAssets} from 'aave-address-book/AaveV4Base.sol';
import {AaveV4PayloadBase} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadBase.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';

/**
 * @title Onboard SPCXc to the Equities Hub on Base
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-asset-listing-spcx-to-the-aave-v4-equities-hub-on-base/25850
 */
contract AaveV4Base_OnboardSPCXEquitiesHub_20261016 is AaveV4PayloadBase {
  // https://basescan.org/address/0xb2000000000000000000007b9fcbd005511aCBd5
  address public constant SPCXC = 0xb2000000000000000000007b9fcbd005511aCBd5;

  // https://basescan.org/address/0x6A634B235903C4ad6376892180d6fF8612e3Fa68
  address public constant MAG7_SPOKE_SPCXC_PRICE_FEED = 0x6A634B235903C4ad6376892180d6fF8612e3Fa68;

  function accessManagerRoleMemberships()
    public
    pure
    override
    returns (IConfigEngine.RoleMembership[] memory)
  {
    IConfigEngine.RoleMembership[] memory items = new IConfigEngine.RoleMembership[](1);
    items[0] = IConfigEngine.RoleMembership({
      authority: address(AaveV4Base.ACCESS_MANAGER),
      roleId: Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      account: GovernanceV3Base.EXECUTOR_LVL_1,
      granted: true,
      executionDelay: 0
    });
    return items;
  }

  function hubAssetListings() public pure override returns (IConfigEngine.AssetListing[] memory) {
    IConfigEngine.AssetListing[] memory items = new IConfigEngine.AssetListing[](1);
    items[0] = IConfigEngine.AssetListing({
      hubConfigurator: AaveV4Base.HUB_CONFIGURATOR,
      hub: address(AaveV4BaseHubs.EQUITIES_HUB),
      underlying: SPCXC,
      feeReceiver: address(AaveV4Base.TREASURY_SPOKE),
      liquidityFee: 0,
      irStrategy: address(AaveV4BaseIRStrategies.EQUITIES_AAPLc_IR_STRATEGY),
      irData: V4EngineDefaults.nonBorrowableIRData(),
      tokenization: V4EngineDefaults.noTokenization()
    });
    return items;
  }

  function spokeReserveListings()
    public
    pure
    override
    returns (IConfigEngine.ReserveListing[] memory)
  {
    IConfigEngine.ReserveListing[] memory items = new IConfigEngine.ReserveListing[](1);
    items[0] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Base.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4BaseSpokes.MAG7_SPOKE),
      hub: address(AaveV4BaseHubs.EQUITIES_HUB),
      underlying: SPCXC,
      priceSource: MAG7_SPOKE_SPCXC_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(10_00),
        paused: false,
        frozen: false,
        borrowable: false,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(55_00),
        maxLiquidationBonus: uint32(106_50),
        liquidationFee: uint16(10_00)
      })
    });
    return items;
  }

  function hubSpokeToAssetsAdditions()
    public
    pure
    override
    returns (IConfigEngine.SpokeToAssetsAddition[] memory)
  {
    IConfigEngine.SpokeToAssetsAddition[] memory items = new IConfigEngine.SpokeToAssetsAddition[](
      1
    );
    {
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](1);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: SPCXC,
        config: IHub.SpokeConfig({
          addCap: 37_000,
          drawCap: 0,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      items[0] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Base.HUB_CONFIGURATOR,
        hub: address(AaveV4BaseHubs.EQUITIES_HUB),
        spoke: address(AaveV4BaseSpokes.MAG7_SPOKE),
        assets: subAssets
      });
    }
    return items;
  }

  function hubSpokeConfigUpdates()
    public
    pure
    override
    returns (IConfigEngine.SpokeConfigUpdate[] memory)
  {
    IConfigEngine.SpokeConfigUpdate[] memory items = new IConfigEngine.SpokeConfigUpdate[](1);
    items[0] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: AaveV4Base.HUB_CONFIGURATOR,
      hub: address(AaveV4BaseHubs.EQUITIES_HUB),
      underlying: AaveV4BaseAssets.USDC_UNDERLYING,
      spoke: address(AaveV4BaseSpokes.MAG7_SPOKE),
      addCap: EngineFlags.KEEP_CURRENT,
      drawCap: EngineFlags.KEEP_CURRENT,
      riskPremiumThreshold: 1_100_00,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    return items;
  }
}
