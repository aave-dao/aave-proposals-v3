// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISafeAccount {
  function execTransaction(
    address to,
    uint256 value,
    bytes calldata data,
    uint8 operation,
    uint256 safeTxGas,
    uint256 baseGas,
    uint256 gasPrice,
    address gasToken,
    address payable refundReceiver,
    bytes memory signatures
  ) external payable returns (bool success);
  function getOwners() external view returns (address[] memory);
}
