// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @dev Minimal interface for the Llama Risk RWA Oracle parameter registry
/// @notice Based on https://github.com/llama-risk/llamaguard-contracts/blob/main/src/ParameterRegistry.sol
interface IRwaOracleParameterRegistry {
  function assetExists(address asset) external view returns (bool);
}
