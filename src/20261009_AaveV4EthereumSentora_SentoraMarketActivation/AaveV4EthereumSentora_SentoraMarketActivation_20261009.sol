// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {IOwnable2Step} from 'src/interfaces/IOwnable2Step.sol';

import {AaveV4EthereumSentora, AaveV4EthereumSentoraHubs, AaveV4EthereumSentoraPositionManagers} from 'aave-address-book/AaveV4EthereumSentora.sol';

/**
 * @title Aave V4 Sentora Market Activation
 * @author Aave Labs
 * @notice Executed by the Sentora Executor through the Sentora PermissionedPayloadsController. Accepts
 * the ownerships handed over at deploy, then unhalts every asset-spoke pair the configuration halted.
 * - Snapshot: TODO
 * - Discussion: https://governance.aave.com/t/arfc-sentora-externally-curated-hub-spoke-framework-on-aave-v4/25723
 */
contract AaveV4EthereumSentora_SentoraMarketActivation_20261009 is IProposalGenericExecutor {
  function execute() external override {
    _acceptOwnerships();
    _unhaltHub(AaveV4EthereumSentoraHubs.SENTORA_HUB);
  }

  function _acceptOwnerships() internal {
    IOwnable2Step(address(AaveV4EthereumSentoraPositionManagers.GIVER_POSITION_MANAGER))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraPositionManagers.TAKER_POSITION_MANAGER))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraPositionManagers.CONFIG_POSITION_MANAGER))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraPositionManagers.NATIVE_TOKEN_GATEWAY))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraPositionManagers.SIGNATURE_GATEWAY))
      .acceptOwnership();
  }

  function _unhaltHub(IHub hub) internal {
    uint256 assetCount = hub.getAssetCount();
    for (uint256 assetId; assetId < assetCount; ++assetId) {
      uint256 spokeCount = hub.getSpokeCount(assetId);
      for (uint256 i; i < spokeCount; ++i) {
        AaveV4EthereumSentora.HUB_CONFIGURATOR.updateSpokeHalted({
          hub: address(hub),
          assetId: assetId,
          spoke: hub.getSpokeAddress({assetId: assetId, index: i}),
          halted: false
        });
      }
    }
  }
}
