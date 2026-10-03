// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {GhoXLayer} from 'aave-address-book/GhoXLayer.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IUpgradeableBurnMintTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableBurnMintTokenPool.sol';

import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

/**
 * @title Remote GSM Launch: XLayer
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178
 */
contract AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1 is IProposalGenericExecutor {
  using SafeCast for uint256;

  function execute() external {
    // Increase bucket capacity to allow minting the bridged GHO on XLayer.
    (uint256 currentFacilitatorBucketCapacity, ) = IGhoToken(GhoXLayer.GHO_TOKEN)
      .getFacilitatorBucket(GhoXLayer.GHO_CCIP_TOKEN_POOL);

    IGhoToken(GhoXLayer.GHO_TOKEN).setFacilitatorBucketCapacity(
      GhoXLayer.GHO_CCIP_TOKEN_POOL,
      currentFacilitatorBucketCapacity.toUint128() +
        RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT.toUint128()
    );

    // Temporarily widen the Ethereum -> XLayer inbound capacity to receive the one-off 25M seed
    // (counterpart to the Ethereum Part 1 outbound step). The outbound (XLayer -> Ethereum)
    // direction is set to the standard config; Part 2 restores the whole lane to it.
    // The outbound direction already sits at DEFAULT_RATE_LIMITER_* on-chain, so rewriting it here
    // leaves it unchanged. `test_outboundRateLimiter` asserts that pre-execution state, and fails
    // if the lane is ever reconfigured out from under this assumption.
    IUpgradeableBurnMintTokenPool(GhoXLayer.GHO_CCIP_TOKEN_POOL).setChainRateLimiterConfig(
      CCIPChainSelectors.ETHEREUM,
      IRateLimiter.Config({
        isEnabled: true,
        capacity: RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
        rate: RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE
      }),
      IRateLimiter.Config({
        isEnabled: true,
        capacity: RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY, // Temporarily increase the maximum bridge limit (inbound capacity; counterpart to Ethereum / Part 1 step)
        rate: RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY - 1 // Set rate to capacity so it fills to limit right away (-1 because they cannot be the same)
      })
    );
  }
}
