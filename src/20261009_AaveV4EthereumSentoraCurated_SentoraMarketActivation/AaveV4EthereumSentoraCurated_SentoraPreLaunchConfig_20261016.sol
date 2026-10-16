// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {ISpoke} from 'aave-address-book/AaveV4.sol';
import {AaveV4EthereumSentoraCurated, AaveV4EthereumSentoraCuratedHubs, AaveV4EthereumSentoraCuratedSpokes, AaveV4EthereumSentoraCuratedAssets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';

/**
 * @title Aave V4 Sentora Pre-Launch Config
 * @author Aave Labs
 * @dev To be executed by the V4 Security Council
 */
contract AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016 is IProposalGenericExecutor {
  function execute() external override {
    _closeMWin();
    _resetReserveCaps(AaveV4EthereumSentoraCuratedAssets.PST_UNDERLYING);
    _resetReserveCaps(AaveV4EthereumSentoraCuratedAssets.PRIME_UNDERLYING);
    _updateLiquidationConfigs();
  }

  /// @dev Deactivating and resetting the asset covers every mWIN pair, the TreasurySpoke included.
  function _closeMWin() internal {
    uint256 assetId = AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB.getAssetId(
      AaveV4EthereumSentoraCuratedAssets.mWIN_UNDERLYING
    );
    AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR.deactivateAsset(
      address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB),
      assetId
    );
    AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR.resetAssetCaps(
      address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB),
      assetId
    );
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR.pauseReserve(
      address(AaveV4EthereumSentoraCuratedSpokes.RLUSD_YIELD_SPOKE),
      AaveV4EthereumSentoraCuratedSpokes.RLUSD_YIELD_SPOKE.getReserveId(
        address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB),
        assetId
      )
    );
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR.pauseReserve(
      address(AaveV4EthereumSentoraCuratedSpokes.OUSD_YIELD_SPOKE),
      AaveV4EthereumSentoraCuratedSpokes.OUSD_YIELD_SPOKE.getReserveId(
        address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB),
        assetId
      )
    );
  }

  function _resetReserveCaps(address underlying) internal {
    uint256 assetId = AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB.getAssetId(underlying);
    AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR.updateSpokeCaps(
      address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB),
      assetId,
      address(AaveV4EthereumSentoraCuratedSpokes.RLUSD_YIELD_SPOKE),
      0,
      0
    );
    AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR.updateSpokeCaps(
      address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB),
      assetId,
      address(AaveV4EthereumSentoraCuratedSpokes.OUSD_YIELD_SPOKE),
      0,
      0
    );
  }

  function _updateLiquidationConfigs() internal {
    ISpoke.LiquidationConfig memory yieldConfig = ISpoke.LiquidationConfig({
      targetHealthFactor: 1.047e18,
      healthFactorForMaxBonus: 0.99e18,
      liquidationBonusFactor: 100_00
    });
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR.updateLiquidationConfig(
      address(AaveV4EthereumSentoraCuratedSpokes.RLUSD_YIELD_SPOKE),
      yieldConfig
    );
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR.updateLiquidationConfig(
      address(AaveV4EthereumSentoraCuratedSpokes.OUSD_YIELD_SPOKE),
      yieldConfig
    );
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR.updateLiquidationConfig(
      address(AaveV4EthereumSentoraCuratedSpokes.BLUECHIP_SPOKE),
      ISpoke.LiquidationConfig({
        targetHealthFactor: 1.143e18,
        healthFactorForMaxBonus: 0.99e18,
        liquidationBonusFactor: 100_00
      })
    );
  }
}
