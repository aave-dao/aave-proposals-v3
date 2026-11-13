// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Subset of Babylon's BTCVaultSwap used by the payload and its tests.
 */
interface IBTCVaultSwap {
  function setSwapFeeBps(uint256 sellDiscountBps, uint256 minimumProfitThresholdBps) external;

  function pause() external;

  function unpause() external;

  function freeze() external;

  function unfreeze() external;
}
