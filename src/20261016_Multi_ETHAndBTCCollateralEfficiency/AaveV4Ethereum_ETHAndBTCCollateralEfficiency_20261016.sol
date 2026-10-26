// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Ethereum, AaveV4EthereumSpokes, AaveV4EthereumHubs, AaveV4EthereumAssets} from 'aave-address-book/AaveV4Ethereum.sol';
import {AaveV4PayloadEthereum} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadEthereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';

/**
 * @title Revision of ETH & BTC Collateral Efficiency on Aave
 * @author LlamaRisk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x0845fbf2d49ec5ad85f8a569e51ce7014f6f4c6dfc34e3b6cd28ef3f9037d586
 * - Discussion: https://governance.aave.com/t/arfc-revision-of-eth-btc-collateral-efficiency-on-aave/25649
 */
contract AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016 is AaveV4PayloadEthereum {
  function spokeDynamicReserveConfigUpdates()
    public
    pure
    override
    returns (IConfigEngine.DynamicReserveConfigUpdate[] memory)
  {
    IConfigEngine.DynamicReserveConfigUpdate[]
      memory items = new IConfigEngine.DynamicReserveConfigUpdate[](7);
    items[0] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.WETH_UNDERLYING,
      dynamicConfigKey: 0,
      collateralFactor: 84_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    items[1] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.WBTC_UNDERLYING,
      dynamicConfigKey: 0,
      collateralFactor: 85_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    items[2] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.cbBTC_UNDERLYING,
      dynamicConfigKey: 0,
      collateralFactor: 85_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    items[3] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.wstETH_UNDERLYING,
      dynamicConfigKey: 0,
      collateralFactor: 82_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    items[4] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.weETH_UNDERLYING,
      dynamicConfigKey: 0,
      collateralFactor: 81_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    items[5] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.wstETH_UNDERLYING,
      dynamicConfigKey: 2,
      collateralFactor: 82_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    items[6] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.weETH_UNDERLYING,
      dynamicConfigKey: 2,
      collateralFactor: 81_00,
      maxLiquidationBonus: EngineFlags.KEEP_CURRENT,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    return items;
  }
}
