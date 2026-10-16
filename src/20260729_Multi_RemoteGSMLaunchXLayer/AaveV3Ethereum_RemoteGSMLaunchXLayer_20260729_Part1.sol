// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';

import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';

import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

/**
 * @title Remote GSM Launch: XLayer
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178
 */
contract AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1 is IProposalGenericExecutor {
  function execute() external {
    // Increment bridge limit to accommodate the amount to bridge.
    uint256 currentBridgeLimit = IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL)
      .getBridgeLimit();
    IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL).setBridgeLimit(
      currentBridgeLimit + RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT
    );

    // Temporarily increase the Ethereum -> XLayer outbound capacity for the one-off seed bridge.
    // The inbound (XLayer -> Ethereum) direction is set to the standard config; it is not
    // widened here and is left at the value Part 2 restores the lane to.
    // The inbound direction already sits at DEFAULT_RATE_LIMITER_* on-chain, so rewriting it here
    // leaves it unchanged. `test_inboundRateLimiter` asserts that pre-execution state, and fails
    // if the lane is ever reconfigured out from under this assumption.
    IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL).setChainRateLimiterConfig(
      CCIPChainSelectors.XLAYER,
      IRateLimiter.Config({
        isEnabled: true,
        capacity: RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY,
        rate: RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY - 1 // Set rate to capacity so it fills to limit right away (-1 because they cannot be the same)
      }),
      IRateLimiter.Config({
        isEnabled: true,
        capacity: RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
        rate: RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE
      })
    );
  }
}
