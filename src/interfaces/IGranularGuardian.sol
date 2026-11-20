// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IAccessControlEnumerable} from 'openzeppelin-contracts/contracts/access/extensions/IAccessControlEnumerable.sol';

/**
 * @title IGranularGuardianAccessControl
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the GranularGuardianAccessControl contract
 */
interface IGranularGuardianAccessControl is IAccessControlEnumerable {
  /**
   * @notice method to update the CrossChainController guardian when this contract has been set as guardian
   */
  function updateGuardian(address newCrossChainControllerGuardian) external;

  /**
   * @notice method to get the address of the CrossChainController where the contract points to
   * @return the address of the CrossChainController
   */
  function CROSS_CHAIN_CONTROLLER() external view returns (address);

  /**
   * @notice method to get the solve emergency role
   * @return the solve emergency role id
   */
  function SOLVE_EMERGENCY_ROLE() external view returns (bytes32);

  /**
   * @notice method to get the retry role
   * @return the retry role id
   */
  function RETRY_ROLE() external view returns (bytes32);
}
