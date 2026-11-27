// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GhoCCIPChains} from 'src/helpers/gho-launch/constants/GhoCCIPChains.sol';
import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';

/**
 * @title SupportedChainsCheck
 * @author TokenLogic
 * @notice Lane assertions and helpers shared by the GHO CCIP token pool tests.
 */
abstract contract SupportedChainsCheck is Test {
  /**
   * @notice Asserts that tokenPool has a lane for every chain in GhoCCIPChains except ownChainSelector, including CCIP 1.6 lanes, and no additional lane.
   * @dev Treats GhoCCIPChains as the source of truth. Compares chain selectors only; remote pool and remote token addresses are not checked.
   * @param tokenPool The address of the token pool to check.
   * @param ownChainSelector The chain selector of tokenPool's own chain, excluded from the comparison.
   */
  function _assertSupportedChainsMatchLibrary(
    address tokenPool,
    uint64 ownChainSelector
  ) internal view {
    uint64[] memory supported = IUpgradeableLockReleaseTokenPool(tokenPool).getSupportedChains();
    GhoCCIPChains.ChainInfo[] memory expected = GhoCCIPChains.getAllChainsExcept(
      ownChainSelector,
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
   * @notice Returns a hash of the rate limit configuration of tokenPool for every GhoCCIPChains lane, excluding ownChainSelector and skipChainSelector.
   * @dev Lets a test prove that a payload changed no lane except skipChainSelector. Includes CCIP 1.6 lanes.
   * @dev It covers both inbound and outbound directions, including the enabled state, capacity, and refill rate of each rate limiter.
   * @param tokenPool The address of the token pool to hash.
   * @param ownChainSelector The chain selector to exclude from the hash.
   * @param skipChainSelector The additional chain selector to skip during hashing.
   * @return hash The resulting hash of the rate limiter configurations.
   */
  function _hashLanesConfig(
    address tokenPool,
    uint64 ownChainSelector,
    uint64 skipChainSelector
  ) internal view returns (bytes32 hash) {
    GhoCCIPChains.ChainInfo[] memory chains = GhoCCIPChains.getAllChainsExcept(
      ownChainSelector,
      false
    );
    IUpgradeableLockReleaseTokenPool pool = IUpgradeableLockReleaseTokenPool(tokenPool);
    for (uint256 i = 0; i < chains.length; i++) {
      uint64 selector = chains[i].chainSelector;
      if (selector == skipChainSelector) continue;
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
