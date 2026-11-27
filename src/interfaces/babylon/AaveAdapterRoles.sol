// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Role ids of Babylon's AaveAdapter, which defines them as the keccak256 of their names and
 * exposes no getter.
 */
library AaveAdapterRoles {
  bytes32 internal constant APPLICATION_ADMIN_ROLE = keccak256('APPLICATION_ADMIN');
  bytes32 internal constant APPLICATION_PAUSE_GUARDIAN_ROLE =
    keccak256('APPLICATION_PAUSE_GUARDIAN');
  bytes32 internal constant APPLICATION_FREEZE_GUARDIAN_ROLE =
    keccak256('APPLICATION_FREEZE_GUARDIAN');
}
