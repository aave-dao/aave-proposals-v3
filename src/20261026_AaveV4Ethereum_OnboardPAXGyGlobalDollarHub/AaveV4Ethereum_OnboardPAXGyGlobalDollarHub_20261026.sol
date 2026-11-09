// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumIRStrategies, AaveV4EthereumSpokePriceFeeds, AaveV4EthereumSpokes, AaveV4EthereumAssets, AaveV4EthereumPositionManagers, AaveV4EthereumTokenizationSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {AaveV4PayloadEthereum} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadEthereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';
import {V4RoleWiring} from 'aave-helpers/src/v4-config-engine/V4RoleWiring.sol';

/**
 * @title Onboard PAXGy to Aave V4 Global Dollar Hub
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xf987dd5aed6586169b232af7691e2cbb268cf61e2845bf6a04a83b60a5404bd8
 * - Discussion: https://governance.aave.com/t/arfc-onboard-paxgy-to-aave-v4-global-dollar-hub/25499
 */
contract AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026 is AaveV4PayloadEthereum {
  // https://etherscan.io/address/0x6c6494Fd9962eB98B94ffA48F6679058F820700e
  address public constant PAXGY = 0x6c6494Fd9962eB98B94ffA48F6679058F820700e;

  // https://etherscan.io/address/0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616
  address public constant PAXG_PAXOS_ESPOKE = 0x115aF1C2db26cD8ECa3f29055E4E424AF4edF616;

  // https://etherscan.io/address/0x8E39De6366AB0bc3e9FF6a116f366736bf0D8A9e
  address public constant PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED =
    0x8E39De6366AB0bc3e9FF6a116f366736bf0D8A9e;

  function accessManagerTargetFunctionRoleUpdates()
    public
    pure
    override
    returns (IConfigEngine.TargetFunctionRoleUpdate[] memory)
  {
    return V4RoleWiring.spokeWiring(address(AaveV4Ethereum.ACCESS_MANAGER), PAXG_PAXOS_ESPOKE);
  }

  function hubAssetListings() public pure override returns (IConfigEngine.AssetListing[] memory) {
    IConfigEngine.AssetListing[] memory items = new IConfigEngine.AssetListing[](1);
    items[0] = IConfigEngine.AssetListing({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: PAXGY,
      feeReceiver: address(AaveV4Ethereum.TREASURY_SPOKE),
      liquidityFee: 0,
      irStrategy: address(AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_PAXG_IR_STRATEGY),
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
    IConfigEngine.ReserveListing[] memory items = new IConfigEngine.ReserveListing[](3);
    items[0] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE),
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: PAXGY,
      priceSource: PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(0),
        paused: false,
        frozen: false,
        borrowable: false,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(70_00),
        maxLiquidationBonus: uint32(107_50),
        liquidationFee: uint16(10_00)
      })
    });
    items[1] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_PAXOS_ESPOKE,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: PAXGY,
      priceSource: PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(0),
        paused: false,
        frozen: false,
        borrowable: false,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(85_00),
        maxLiquidationBonus: uint32(104_00),
        liquidationFee: uint16(10_00)
      })
    });
    items[2] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_PAXOS_ESPOKE,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: AaveV4EthereumAssets.PAXG_UNDERLYING,
      priceSource: AaveV4EthereumSpokePriceFeeds.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED,
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
      spoke: PAXG_PAXOS_ESPOKE,
      targetHealthFactor: 1.05e18,
      healthFactorForMaxBonus: 0.99e18,
      liquidationBonusFactor: 100_00
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
        underlying: PAXGY,
        config: IHub.SpokeConfig({
          addCap: 480,
          drawCap: 0,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      items[0] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
        spoke: address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE),
        assets: subAssets
      });
    }
    {
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](2);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: PAXGY,
        config: IHub.SpokeConfig({
          addCap: 480,
          drawCap: 0,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      subAssets[1] = IConfigEngine.SpokeAssetConfig({
        underlying: AaveV4EthereumAssets.PAXG_UNDERLYING,
        config: IHub.SpokeConfig({
          addCap: 0,
          drawCap: 400,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      items[1] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
        spoke: PAXG_PAXOS_ESPOKE,
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
      spoke: PAXG_PAXOS_ESPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER),
      active: true
    });
    items[1] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_PAXOS_ESPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER),
      active: true
    });
    items[2] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_PAXOS_ESPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER),
      active: true
    });
    items[3] = IConfigEngine.PositionManagerUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: PAXG_PAXOS_ESPOKE,
      positionManager: address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY),
      active: true
    });
    return items;
  }

  function hubAssetConfigUpdates()
    public
    pure
    override
    returns (IConfigEngine.AssetConfigUpdate[] memory)
  {
    IConfigEngine.AssetConfigUpdate[] memory items = new IConfigEngine.AssetConfigUpdate[](1);
    items[0] = IConfigEngine.AssetConfigUpdate({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: AaveV4EthereumAssets.PAXG_UNDERLYING,
      liquidityFee: 50_00,
      feeReceiver: EngineFlags.KEEP_CURRENT_ADDRESS,
      irStrategy: EngineFlags.KEEP_CURRENT_ADDRESS,
      irData: IAssetInterestRateStrategy.InterestRateData({
        optimalUsageRatio: uint16(60_00),
        baseDrawnRate: uint32(0),
        rateGrowthBeforeOptimal: uint32(3_00),
        rateGrowthAfterOptimal: uint32(20_00)
      }),
      reinvestmentController: EngineFlags.KEEP_CURRENT_ADDRESS
    });
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
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
      underlying: AaveV4EthereumAssets.PAXG_UNDERLYING,
      spoke: address(AaveV4EthereumTokenizationSpokes.GLOBAL_DOLLAR_PAXG_TOKENIZATION_SPOKE),
      addCap: 400,
      drawCap: EngineFlags.KEEP_CURRENT,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    return items;
  }
}
