// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Avalanche, AaveV4AvalancheHubs, AaveV4AvalancheIRStrategies, AaveV4AvalancheSpokes} from 'aave-address-book/AaveV4Avalanche.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {AaveV4PayloadAvalanche} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadAvalanche.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';

/**
 * @title Onboard USAT to Aave V4 Core Instance on Avalanche
 * @author Aave Labs
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-onboard-usat-to-aave-v4-core-instance-on-avalanche/25880
 */
contract AaveV4Avalanche_OnboardUSATCoreHub_20261028 is AaveV4PayloadAvalanche {
  // https://snowscan.xyz/address/0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b
  address public constant USAT = 0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b;

  // https://snowscan.xyz/address/0xCcE4d712CA51098e89F26f79F114132942DE9134
  address public constant MAIN_SPOKE_USAT_PRICE_FEED = 0xCcE4d712CA51098e89F26f79F114132942DE9134;

  // https://snowscan.xyz/address/0xCcE4d712CA51098e89F26f79F114132942DE9134
  address public constant ETHENA_ECOSYSTEM_SPOKE_USAT_PRICE_FEED =
    0xCcE4d712CA51098e89F26f79F114132942DE9134;

  function hubAssetListings() public pure override returns (IConfigEngine.AssetListing[] memory) {
    IConfigEngine.AssetListing[] memory items = new IConfigEngine.AssetListing[](1);
    items[0] = IConfigEngine.AssetListing({
      hubConfigurator: AaveV4Avalanche.HUB_CONFIGURATOR,
      hub: address(AaveV4AvalancheHubs.CORE_HUB),
      underlying: USAT,
      feeReceiver: address(AaveV4Avalanche.TREASURY_SPOKE),
      liquidityFee: 10_00,
      irStrategy: address(AaveV4AvalancheIRStrategies.CORE_USDt_IR_STRATEGY),
      irData: IAssetInterestRateStrategy.InterestRateData({
        optimalUsageRatio: uint16(94_00),
        baseDrawnRate: uint32(0),
        rateGrowthBeforeOptimal: uint32(4_90),
        rateGrowthAfterOptimal: uint32(20_00)
      }),
      tokenization: IConfigEngine.TokenizationSpokeConfig({
        addCap: 1_500_000,
        proxyAdminOwner: address(MiscAvalanche.V4_SECURITY_COUNCIL),
        name: 'Wrapped Aave Core USAT',
        symbol: 'waCoreUSAT'
      })
    });
    return items;
  }

  function spokeReserveListings()
    public
    pure
    override
    returns (IConfigEngine.ReserveListing[] memory)
  {
    IConfigEngine.ReserveListing[] memory items = new IConfigEngine.ReserveListing[](2);
    items[0] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Avalanche.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4AvalancheSpokes.MAIN_SPOKE),
      hub: address(AaveV4AvalancheHubs.CORE_HUB),
      underlying: USAT,
      priceSource: MAIN_SPOKE_USAT_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(0),
        paused: false,
        frozen: false,
        borrowable: true,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(0),
        maxLiquidationBonus: uint32(100_00),
        liquidationFee: uint16(0)
      })
    });
    items[1] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Avalanche.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE),
      hub: address(AaveV4AvalancheHubs.CORE_HUB),
      underlying: USAT,
      priceSource: ETHENA_ECOSYSTEM_SPOKE_USAT_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(0),
        paused: false,
        frozen: false,
        borrowable: true,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(0),
        maxLiquidationBonus: uint32(100_00),
        liquidationFee: uint16(0)
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
      2
    );
    {
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](1);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: USAT,
        config: IHub.SpokeConfig({
          addCap: 60_000_000,
          drawCap: 5_000_000,
          riskPremiumThreshold: 1_100_00,
          active: true,
          halted: false
        })
      });
      items[0] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Avalanche.HUB_CONFIGURATOR,
        hub: address(AaveV4AvalancheHubs.CORE_HUB),
        spoke: address(AaveV4AvalancheSpokes.MAIN_SPOKE),
        assets: subAssets
      });
    }
    {
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](1);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: USAT,
        config: IHub.SpokeConfig({
          addCap: 0,
          drawCap: 50_000_000,
          riskPremiumThreshold: 1_100_00,
          active: true,
          halted: false
        })
      });
      items[1] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Avalanche.HUB_CONFIGURATOR,
        hub: address(AaveV4AvalancheHubs.CORE_HUB),
        spoke: address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE),
        assets: subAssets
      });
    }
    return items;
  }
}
