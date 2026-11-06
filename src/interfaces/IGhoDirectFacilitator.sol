// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';

interface IGhoDirectFacilitator is IAccessControl {
  function mint(address to, uint256 amount) external;
  function burn(uint256 amount) external;
  function MINTER_ROLE() external view returns (bytes32);
  function BURNER_ROLE() external view returns (bytes32);
  function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
  function GHO_TOKEN() external view returns (address);
}
