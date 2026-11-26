// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Errors library from Aave-Horizon
 * @author Aave
 * @notice Defines the error messages emitted by the different contracts of the Aave protocol
 */
library Errors {
  string public constant BORROWING_NOT_ENABLED = '30'; // 'Borrowing is not enabled'
  string public constant BORROW_CAP_EXCEEDED = '50'; // 'Borrow cap is exceeded'
  string public constant SUPPLY_CAP_EXCEEDED = '51'; // 'Supply cap is exceeded'
  string public constant OPERATION_NOT_SUPPORTED = '80'; // 'Operation not supported'
}
