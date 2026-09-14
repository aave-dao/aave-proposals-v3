// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumIRStrategies, AaveV4EthereumAssets, AaveV4EthereumSpokes, AaveV4EthereumSpokePriceFeeds, AaveV4EthereumPositionManagers} from 'aave-address-book/AaveV4Ethereum.sol';
import {AaveV4PayloadEthereum} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadEthereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';
import {V4RoleWiring} from 'aave-helpers/src/v4-config-engine/V4RoleWiring.sol';

/**
 * @title Onboard PAXG to Global Dollar Hub
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x65be5cb5922bc73d14ba16b13d4e7ee5eaae2c6d9518c27b7ab9721fd2f637b1
 * - Discussion: https://governance.aave.com/t/arfc-onboard-paxg-to-the-global-dollar-hub-in-aave-v4-ethereum/25340
 */
contract AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824 is AaveV4PayloadEthereum {
  // https://etherscan.io/address/0x45804880De22913dAFE09f4980848ECE6EcbAf78
  address public constant PAXG = 0x45804880De22913dAFE09f4980848ECE6EcbAf78;

  // https://etherscan.io/address/0xAD75cE6354f87F3135cE10621d385d8D1e2562C2
  address public constant PAXG_GOLD_SPOKE = 0xAD75cE6354f87F3135cE10621d385d8D1e2562C2;

  // https://etherscan.io/address/0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6
  address public constant PAXG_GOLD_SPOKE_PAXG_PRICE_FEED =
    0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6;

  function accessManagerTargetFunctionRoleUpdates()
    public
    pure
    override
    returns (IConfigEngine.TargetFunctionRoleUpdate[] memory)
  {
    return V4RoleWiring.spokeWiring(address(AaveV4Ethereum.ACCESS_MANAGER), PAXG_GOLD_SPOKE);
  }

  function hubAssetListings() public pure override returns (IConfigEngine.AssetListing[] memory) {
    IConfigEngine.AssetListing[] memory items = new IConfigEngine.AssetListing[](1);
    items[0] = IConfigEngine.AssetListing({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: PAXG,
      feeReceiver: address(AaveV4Ethereum.TREASURY_SPOKE),
      liquidityFee: 0,
      irStrategy: address(AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_USDG_IR_STRATEGY),
      irData: V4EngineDefaults.nonBorrowableIRData(),
      tokenization: IConfigEngine.TokenizationSpokeConfig({
        addCap: 0,
        proxyAdminOwner: 0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9,
        name: 'Wrapped Aave Global Dollar PAXG',
        symbol: 'waGlobalDollarPAXG'
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
    IConfigEngine.ReserveListing[] memory items = new IConfigEngine.ReserveListing[](3);
    items[0] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: PAXG,
      priceSource: PAXG_GOLD_SPOKE_PAXG_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(0),
        paused: false,
        frozen: false,
        borrowable: false,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(75_00),
        maxLiquidationBonus: uint32(106_50),
        liquidationFee: uint16(10_00)
      })
    });
    items[1] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: AaveV4EthereumAssets.USDG_UNDERLYING,
      priceSource: AaveV4EthereumSpokePriceFeeds.GOLD_SPOKE_USDG_PRICE_FEED,
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
    items[2] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE),
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: AaveV4EthereumAssets.USDG_UNDERLYING,
      priceSource: AaveV4EthereumSpokePriceFeeds.USDG_PENDLE_SPOKE_USDG_PRICE_FEED,
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

  function spokeLiquidationConfigUpdates()
    public
    pure
    override
    returns (IConfigEngine.LiquidationConfigUpdate[] memory)
  {
    IConfigEngine.LiquidationConfigUpdate[]
      memory items = new IConfigEngine.LiquidationConfigUpdate[](1);
    items[0] = IConfigEngine.LiquidationConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      targetHealthFactor: 1.2e18,
      healthFactorForMaxBonus: 0.9e18,
      liquidationBonusFactor: 80_00
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
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](2);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: PAXG,
        config: IHub.SpokeConfig({
          addCap: 2_500,
          drawCap: 0,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      subAssets[1] = IConfigEngine.SpokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDG_UNDERLYING,
        config: IHub.SpokeConfig({
          addCap: 5_000_000,
          drawCap: 9_500_000,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      items[0] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
        spoke: PAXG_GOLD_SPOKE,
        assets: subAssets
      });
    }
    {
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](1);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: AaveV4EthereumAssets.USDG_UNDERLYING,
        config: IHub.SpokeConfig({
          addCap: 0,
          drawCap: 4_000_000,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      items[1] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
        spoke: address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE),
        assets: subAssets
      });
    }
    return items;
  }

  function spokePositionManagerUpdates()
    public
    pure
    override
    returns (IConfigEngine.PositionManagerUpdate[] memory)
  {
    IConfigEngine.PositionManagerUpdate[] memory items = new IConfigEngine.PositionManagerUpdate[](
      4
    );
    items[0] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER),
      active: true
    });
    items[1] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER),
      active: true
    });
    items[2] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER),
      active: true
    });
    items[3] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_GOLD_SPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY),
      active: true
    });
    return items;
  }
}
