// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GhoCCIPChains} from 'src/helpers/gho-launch/constants/GhoCCIPChains.sol';
import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';

/**
 * @dev The lane tests loop over GhoCCIPChains; this pins it equal to the lanes the pool reports
 * (`getSupportedChains`) so no lane escapes the checks.
 */
abstract contract SupportedChainsCheck is Test {
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

  /// @dev Hash of the configured rate limits (enabled, capacity, rate) of every lane but `skipSelector`
  function _laneConfigHash(
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
}
