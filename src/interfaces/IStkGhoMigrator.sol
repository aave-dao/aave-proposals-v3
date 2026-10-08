// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IStkGhoMigrator {
  function claimHelperRole() external;
  function setClaimHelperPendingAdmin(address newPendingAdmin) external;
  function pause() external;
  function migrate() external;
}
