// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ISafe
 * @notice minimal interface for a Safe (Gnosis Safe) multisig, exposing the
 *         owner set and signature threshold used to assert the multisig setup
 */
interface ISafe {
  /**
   * @notice returns the number of required confirmations for a Safe transaction
   */
  function getThreshold() external view returns (uint256);

  /**
   * @notice returns the list of Safe owners
   */
  function getOwners() external view returns (address[] memory);

  /**
   * @notice returns whether `owner` is an owner of the Safe
   */
  function isOwner(address owner) external view returns (bool);

  /**
   * @notice returns a page of enabled modules, starting after `start`, and the start of the next page
   */
  function getModulesPaginated(
    address start,
    uint256 pageSize
  ) external view returns (address[] memory, address);
}
