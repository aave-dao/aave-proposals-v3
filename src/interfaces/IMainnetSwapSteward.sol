// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMainnetSwapSteward {
  /// @notice Returns address of the Oracle to use for token swaps
  /// @param token Address of the token to swap
  function priceOracle(address token) external view returns (address);

  /// @notice Returns the budget remaining for a given token
  /// @param token The address of the token to query the budget for
  function tokenBudget(address token) external view returns (uint256);

  /// @notice Increases a token's budget (the maximum that can be swapped from)
  /// @param token The address of the token to increase the budget for
  /// @param budget The extra amount of token that can be swapped from
  function increaseTokenBudget(address token, uint256 budget) external;

  /// @notice Decreases a token's budget (the maximum that can be swapped from)
  /// @param token The address of the token to decrease the budget for
  /// @param budget The amount of token to remove from the budget
  function decreaseTokenBudget(address token, uint256 budget) external;

  /// @notice Returns whether token is approved to be swapped from/to
  /// @param fromToken Address of the token to swap from
  /// @param toToken Address of the token to swap to
  function swapApprovedToken(address fromToken, address toToken) external view returns (bool);

  /// @notice Sets a token pair as allowed for swapping in from -> to direction only
  /// @param fromToken The address of the token to swap from
  /// @param toToken The address of the token to swap to
  /// @param allowed Sets swappable pair to allowed/disallowed
  function setSwappablePair(address fromToken, address toToken, bool allowed) external;

  /// @notice Sets a token's Chainlink Oracle (in USD)
  /// @param token The address of the token
  /// @param oracle The address of the token oracle
  function setTokenOracle(address token, address oracle) external;
}
