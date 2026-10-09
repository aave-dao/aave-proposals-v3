// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';

/**
 * @notice Common setup library containing constants and helper functions used in the proposal.
 * @dev See forum post for reference: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178.
 */
library RemoteGSMLaunchXLayerSetup {
  // Amount to mint in Mainnet and bridge to XLayer
  uint256 public constant GHO_BRIDGE_AMOUNT = 25_000_000 ether;

  // 25M GHO bridge amount + 10% leeway in case of other bridges
  uint128 public constant TEMP_BRIDGE_CAPACITY = 27_500_000 ether;

  // Standard per-lane transaction limit the Ethereum <> XLayer GHO lane is RESTORED to after
  // the one-off 25M bridge. This proposal does NOT normalize every network's lanes: it only widens
  // the single Ethereum <> XLayer lane for the transfer and then puts that lane back to its pre-execution config,
  // leaving every other lane untouched.
  // Verified on-chain to match the Ethereum <> XLayer GHO lane's current config in both directions,
  // on both the Ethereum and XLayer token pools, so the proposal restores the lane faithfully.
  uint128 public constant DEFAULT_RATE_LIMITER_CAPACITY = 5_000_000 ether;

  // Refill rate per second the lane is restored to
  uint128 public constant DEFAULT_LIMITER_RATE = 1_000 ether;

  // Facilitator capacity matches bridge amount (as uint128)
  uint128 public constant DIRECT_FACILITATOR_CAPACITY = uint128(GHO_BRIDGE_AMOUNT);

  // Expected GHO facilitator bucket capacity after payloads are executed
  uint128 public constant EXPECTED_BUCKET_CAPACITY = 225_000_000 ether;

  // GSM USDG (GSM is configured to use stataUSDG; naming USDG across the proposal for simplicity)
  // Maximum GHO amount that can be withdrawn by GSM (can be changed by steward later)
  uint128 public constant GSM_USDG_RESERVE_LIMIT = 25_000_000 ether; // 25M, 18 decimals

  // 20M underlying (6 decimals).
  uint128 public constant GSM_USDG_INITIAL_EXPOSURE_CAP = 20_000_000e6; // 20M, 6 decimals

  /**
   * @notice Restores the inbound and outbound CCIP rate-limit config of a single GHO lane to the
   * standard config, without touching any other lane on the pool.
   * @dev Used to undo the temporary capacity bump applied for the one-off 25M seed bridge, so the
   * Ethereum <> XLayer lane ends the proposal with the same config it had beforehand.
   * @param tokenPool The GHO CCIP token pool whose lane will be restored. Typed as
   * `IUpgradeableLockReleaseTokenPool`, but `setChainRateLimiterConfig` shares the same selector
   * across the lock-release and burn-mint pools, so a burn-mint pool address may also be passed.
   * @param remoteChainSelector The CCIP selector of the remote chain (the lane) to restore.
   */
  function restoreLaneRateLimitConfig(address tokenPool, uint64 remoteChainSelector) internal {
    IRateLimiter.Config memory standardConfig = IRateLimiter.Config({
      isEnabled: true,
      capacity: DEFAULT_RATE_LIMITER_CAPACITY,
      rate: DEFAULT_LIMITER_RATE
    });

    IUpgradeableLockReleaseTokenPool(tokenPool).setChainRateLimiterConfig(
      remoteChainSelector,
      standardConfig,
      standardConfig
    );
  }
}
