// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Subset of Babylon's VaultBTC, the collateral token of the Babylon Spoke.
 */
interface IVaultBTC {
  function mint(address to, uint256 amount) external;

  function addValidProxy(address proxyAddress) external;

  function HUB() external view returns (address);

  function adapter() external view returns (address);
}
