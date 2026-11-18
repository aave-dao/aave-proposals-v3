// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AddressBTCKeyPair} from './BabylonTypes.sol';

/**
 * @dev Subset of Babylon's ApplicationRegistry.
 */
interface IApplicationRegistry {
  error UnauthorizedVaultKeeper();

  function getCurrentVaultKeepers(
    address appEntryPoint
  ) external view returns (AddressBTCKeyPair[] memory);

  function getCurrentVaultKeepersVersion(address appEntryPoint) external view returns (uint16);
}
