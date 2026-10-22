// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Ethereum, AaveV4EthereumAssets, AaveV4EthereumHubs, AaveV4EthereumTokenizationSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {AaveV4PayloadEthereum} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadEthereum.sol';

/**
 * @title Mainnet GSM migration
 * @author TokenLogic
 * - Snapshot: TODO
 * - Discussion: TODO
 * @dev Must execute before AaveV3Ethereum_MainnetGSMMigration_20261022: it raises the add caps of the
 * Core USDC and USDT TokenizationSpokes so the new GSMs can hold their shares and the stataUSDT
 * backing of the current USDT GSM can be migrated into the Core USDT TokenizationSpoke.
 */
contract AaveV4Ethereum_MainnetGSMMigration_20261022 is AaveV4PayloadEthereum {
  // TODO: re-check the add caps with the risk providers before going live
  uint256 public constant CORE_USDC_TOKENIZATION_SPOKE_ADD_CAP = 100_000_000;
  uint256 public constant CORE_USDT_TOKENIZATION_SPOKE_ADD_CAP = 100_000_000;

  function hubSpokeConfigUpdates()
    public
    pure
    override
    returns (IConfigEngine.SpokeConfigUpdate[] memory)
  {
    IConfigEngine.SpokeConfigUpdate[] memory items = new IConfigEngine.SpokeConfigUpdate[](2);
    items[0] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.USDC_UNDERLYING,
      spoke: address(AaveV4EthereumTokenizationSpokes.CORE_USDC_TOKENIZATION_SPOKE),
      addCap: CORE_USDC_TOKENIZATION_SPOKE_ADD_CAP,
      drawCap: EngineFlags.KEEP_CURRENT,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    items[1] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: AaveV4EthereumAssets.USDT_UNDERLYING,
      spoke: address(AaveV4EthereumTokenizationSpokes.CORE_USDT_TOKENIZATION_SPOKE),
      addCap: CORE_USDT_TOKENIZATION_SPOKE_ADD_CAP,
      drawCap: EngineFlags.KEEP_CURRENT,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    return items;
  }
}
