// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GhoCCIPChains} from 'src/helpers/gho-launch/constants/GhoCCIPChains.sol';
import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';

/**
 * @title SupportedChainsCheck
 * @author TokenLogic
 * @notice Lane assertions and helpers shared by the GHO CCIP token pool tests of this proposal.
 */
abstract contract SupportedChainsCheck is Test {
  /**
   * @notice Asserts that the pool's getSupportedChains() has the same count as the GhoCCIPChains lanes (every lane except ownSelector, including CCIP 1.6 lanes) and contains each of those selectors.
   * @param tokenPool The address of the token pool to check.
   * @param ownSelector The chain selector to exclude from the comparison.
   */
  function _assertSupportedChainsMatchLibrary(address tokenPool, uint64 ownSelector) internal view {
    uint64[] memory supported = IUpgradeableLockReleaseTokenPool(tokenPool).getSupportedChains();
    GhoCCIPChains.ChainInfo[] memory expected = GhoCCIPChains.getAllChainsExcept(
      ownSelector,
      false
    );
    assertEq(supported.length, expected.length, 'supported chain count');
    for (uint256 i = 0; i < expected.length; i++) {
      bool found;
      for (uint256 j = 0; j < supported.length; j++) {
        if (supported[j] == expected[i].chainSelector) found = true;
      }
      assertTrue(found, 'GhoCCIPChains lane not supported by the pool');
    }
  }

  /**
   * @notice Hashes enabled/capacity/rate of the current inbound and outbound rate limiter state for every GhoCCIPChains lane, including CCIP 1.6 lanes, except ownSelector and skipSelector.
   * @param tokenPool The address of the token pool to hash.
   * @param ownSelector The chain selector to exclude from the hash.
   * @param skipSelector The additional chain selector to skip during hashing.
   * @return hash The resulting hash of the rate limiter configurations.
   */
  function _hashLanesConfig(
    address tokenPool,
    uint64 ownSelector,
    uint64 skipSelector
  ) internal view returns (bytes32 hash) {
    GhoCCIPChains.ChainInfo[] memory chains = GhoCCIPChains.getAllChainsExcept(ownSelector, false);
    IUpgradeableLockReleaseTokenPool pool = IUpgradeableLockReleaseTokenPool(tokenPool);
    for (uint256 i = 0; i < chains.length; i++) {
      uint64 selector = chains[i].chainSelector;
      if (selector == skipSelector) continue;
      IRateLimiter.TokenBucket memory inbound = pool.getCurrentInboundRateLimiterState(selector);
      IRateLimiter.TokenBucket memory outbound = pool.getCurrentOutboundRateLimiterState(selector);
      hash = keccak256(
        abi.encode(
          hash,
          selector,
          inbound.isEnabled,
          inbound.capacity,
          inbound.rate,
          outbound.isEnabled,
          outbound.capacity,
          outbound.rate
        )
      );
    }
  }

  /**
   * @notice Asserts the bucket's isEnabled, capacity and rate equal the given values.
   * @param bucket The token bucket to verify.
   * @param isEnabled The expected enabled state.
   * @param capacity The expected capacity value.
   * @param rate The expected rate value.
   */
  function _assertRateLimiterConfig(
    IRateLimiter.TokenBucket memory bucket,
    bool isEnabled,
    uint128 capacity,
    uint128 rate
  ) internal pure {
    assertEq(bucket.isEnabled, isEnabled, 'rate limiter isEnabled');
    assertEq(bucket.capacity, capacity, 'rate limiter capacity');
    assertEq(bucket.rate, rate, 'rate limiter rate');
  }
}
