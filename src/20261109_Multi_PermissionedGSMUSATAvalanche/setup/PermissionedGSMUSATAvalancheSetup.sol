// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';

/**
 * @notice Constants and helpers shared by the payloads.
 * @dev Forum: https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852
 */
library PermissionedGSMUSATAvalancheSetup {
  // Initial GHO funding, minted on Ethereum and bridged to the Avalanche Collector
  uint256 public constant GHO_BRIDGE_AMOUNT = 65_000_000 ether;

  // Initial GHO funding * 110%, applied to the Ethereum <> Avalanche lane for the one-off transfer
  uint128 public constant TEMP_BRIDGE_CAPACITY = 71_500_000 ether;

  // ARFC initial refill rate, GHO per second
  uint128 public constant TEMP_BRIDGE_RATE = 64_999_999 ether;

  // Ongoing config of the Ethereum <> Avalanche lane, both directions (current on-chain values)
  uint128 public constant DEFAULT_RATE_LIMITER_CAPACITY = 5_000_000 ether;
  uint128 public constant DEFAULT_LIMITER_RATE = 1_000 ether;

  uint128 public constant DIRECT_FACILITATOR_CAPACITY = uint128(GHO_BRIDGE_AMOUNT);

  // ARFC bridge bucket capacity: the Ethereum bridge limit and every remote token pool bucket after execution
  uint256 public constant EXPECTED_BUCKET_CAPACITY = 265_000_000 ether;

  // Remote GSM Draw Limit
  uint256 public constant GSM_RESERVE_LIMIT = 25_000_000 ether;

  // waCoreUSAT shares, 6 decimals (TokenizationSpoke decimals = underlying decimals)
  uint128 public constant GSM_EXPOSURE_CAP = 20_000_000e6;

  /**
   * @notice Sets both directions of one GHO lane of `tokenPool` back to the ongoing config,
   * undoing the Part 1 widening. Every other lane is left untouched.
   * @dev `setChainRateLimiterConfig` has the same selector on the lock-release and burn-mint pools.
   */
  function restoreLaneRateLimitConfig(address tokenPool, uint64 remoteChainSelector) internal {
    IRateLimiter.Config memory defaultConfig = IRateLimiter.Config({
      isEnabled: true,
      capacity: DEFAULT_RATE_LIMITER_CAPACITY,
      rate: DEFAULT_LIMITER_RATE
    });

    IUpgradeableLockReleaseTokenPool(tokenPool).setChainRateLimiterConfig({
      remoteChainSelector: remoteChainSelector,
      outboundConfig: defaultConfig,
      inboundConfig: defaultConfig
    });
  }
}
