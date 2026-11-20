// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Subset of Babylon's TimelockController, which adds a short delay tier to OpenZeppelin's.
 */
interface IBabylonTimelockController {
  event CallScheduled(
    bytes32 indexed id,
    uint256 indexed index,
    address target,
    uint256 value,
    bytes data,
    bytes32 predecessor,
    uint256 delay
  );

  function schedule(
    address target,
    uint256 value,
    bytes calldata data,
    bytes32 predecessor,
    bytes32 salt,
    bool useShortDelay
  ) external;

  function execute(
    address target,
    uint256 value,
    bytes calldata payload,
    bytes32 predecessor,
    bytes32 salt
  ) external payable;

  function isOperationPending(bytes32 id) external view returns (bool);

  function getTimestamp(bytes32 id) external view returns (uint256);

  function getMinDelay() external view returns (uint256);
}
