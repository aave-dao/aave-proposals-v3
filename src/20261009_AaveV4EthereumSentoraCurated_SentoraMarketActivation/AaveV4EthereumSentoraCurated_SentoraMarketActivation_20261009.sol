// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {IOwnable2Step} from 'src/interfaces/IOwnable2Step.sol';

import {AaveV4EthereumSentoraCurated, AaveV4EthereumSentoraCuratedHubs, AaveV4EthereumSentoraCuratedPositionManagers} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';

/**
 * @title Aave V4 Sentora Market Activation
 * @author Aave Labs
 * @notice Executed by the Sentora Executor through the Sentora PermissionedPayloadsController. Accepts
 * the ownerships handed over at deploy, then unhalts every asset-spoke pair the configuration halted.
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x682f73c809e03d25008b9c4898f4e25c047806683f4d1b0d7635ba8ed50276aa
 * - Discussion: https://governance.aave.com/t/arfc-sentora-externally-curated-hub-spoke-framework-on-aave-v4/25723
 */
contract AaveV4EthereumSentoraCurated_SentoraMarketActivation_20261009 is IProposalGenericExecutor {
  function execute() external override {
    _acceptOwnerships();
    _unhaltHub(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB);
  }

  function _acceptOwnerships() internal {
    IOwnable2Step(address(AaveV4EthereumSentoraCuratedPositionManagers.GIVER_POSITION_MANAGER))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraCuratedPositionManagers.TAKER_POSITION_MANAGER))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraCuratedPositionManagers.CONFIG_POSITION_MANAGER))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraCuratedPositionManagers.NATIVE_TOKEN_GATEWAY))
      .acceptOwnership();
    IOwnable2Step(address(AaveV4EthereumSentoraCuratedPositionManagers.SIGNATURE_GATEWAY))
      .acceptOwnership();
  }

  function _unhaltHub(IHub hub) internal {
    uint256 assetCount = hub.getAssetCount();
    for (uint256 assetId; assetId < assetCount; ++assetId) {
      uint256 spokeCount = hub.getSpokeCount(assetId);
      for (uint256 i; i < spokeCount; ++i) {
        AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR.updateSpokeHalted({
          hub: address(hub),
          assetId: assetId,
          spoke: hub.getSpokeAddress({assetId: assetId, index: i}),
          halted: false
        });
      }
    }
  }
}
