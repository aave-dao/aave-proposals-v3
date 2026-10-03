// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {GhoCCIPChains} from 'src/helpers/gho-launch/constants/GhoCCIPChains.sol';
import {IUpgradeableBurnMintTokenPool} from 'src/interfaces/ccip/IUpgradeableBurnMintTokenPool.sol';
import {IRateLimiter} from 'src/interfaces/ccip/IRateLimiter.sol';

import {RemoteGSMLaunchXLayerFacilitatorProposalBase} from './RemoteGSMLaunchXLayerFacilitatorProposalBase.sol';
import {RemoteGSMLaunchXLayerSetup} from './RemoteGSMLaunchXLayerSetup.sol';

/**
 * @dev Shared tests for side chains in the the current proposal.
 */
abstract contract RemoteGSMLaunchXLayerFacilitatorProposalBaseTest is ProtocolV3TestBase {
  RemoteGSMLaunchXLayerFacilitatorProposalBase internal proposal;

  function CURRENT_CHAIN_SELECTOR() public view virtual returns (uint64);

  function test_facilitatorBucketCapacityIncrease() public {
    IGhoToken gho = IGhoToken(proposal.GHO_TOKEN());
    address ccipTokenPool = proposal.GHO_CCIP_TOKEN_POOL();

    IGhoToken.Facilitator memory preFacilitator = gho.getFacilitator(ccipTokenPool);

    executePayload(vm, address(proposal));

    IGhoToken.Facilitator memory postFacilitator = gho.getFacilitator(ccipTokenPool);

    assertEq(
      postFacilitator.bucketCapacity,
      RemoteGSMLaunchXLayerSetup.EXPECTED_BUCKET_CAPACITY,
      'post-proposal facilitator capacity should be 225M'
    );
    assertEq(
      postFacilitator.bucketCapacity,
      preFacilitator.bucketCapacity + RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
      'post-proposal facilitator capacity should have incremented by GHO_BRIDGE_AMOUNT'
    );
    assertEq(
      postFacilitator.bucketLevel,
      preFacilitator.bucketLevel,
      'facilitator bucket level should be unchanged by the capacity update'
    );
  }

  function test_allLaneRateLimitsNormalized() public {
    // Every lane to every other supported network (itself excluded).
    GhoCCIPChains.ChainInfo[] memory chains = GhoCCIPChains.getAllChainsExcept(
      CURRENT_CHAIN_SELECTOR(),
      false
    );
    address ccipTokenPool = proposal.GHO_CCIP_TOKEN_POOL();

    for (uint256 i = 0; i < chains.length; i++) {
      _assertLaneDefaults(ccipTokenPool, chains[i].chainSelector, false);
    }

    executePayload(vm, address(proposal));

    for (uint256 i = 0; i < chains.length; i++) {
      _assertLaneDefaults(ccipTokenPool, chains[i].chainSelector, true);
    }
  }

  function _assertLaneDefaults(
    address ccipTokenPool,
    uint64 remoteChainSelector,
    bool postProposal
  ) internal view {
    string memory msgPrefix = postProposal ? 'post' : 'pre';

    IRateLimiter.TokenBucket memory inbound = IUpgradeableBurnMintTokenPool(ccipTokenPool)
      .getCurrentInboundRateLimiterState(remoteChainSelector);

    assertEq(
      inbound.capacity,
      RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
      string.concat(msgPrefix, '-proposal inbound capacity should be default')
    );
    assertEq(
      inbound.rate,
      RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE,
      string.concat(msgPrefix, '-proposal inbound rate should be default')
    );
    assertTrue(
      inbound.isEnabled,
      string.concat(msgPrefix, '-proposal inbound rate limiter should be enabled')
    );

    IRateLimiter.TokenBucket memory outbound = IUpgradeableBurnMintTokenPool(ccipTokenPool)
      .getCurrentOutboundRateLimiterState(remoteChainSelector);

    assertEq(
      outbound.capacity,
      RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
      string.concat(msgPrefix, '-proposal outbound capacity should be default')
    );
    assertEq(
      outbound.rate,
      RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE,
      string.concat(msgPrefix, '-proposal outbound rate should be default')
    );
    assertTrue(
      outbound.isEnabled,
      string.concat(msgPrefix, '-proposal outbound rate limiter should be enabled')
    );
  }
}
