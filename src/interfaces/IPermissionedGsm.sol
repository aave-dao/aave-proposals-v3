// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGsm} from './IGsm.sol';

/// @dev aave-dao/gho-origin `src/contracts/facilitators/gsm/interfaces/IPermissionedGsm.sol`
interface IPermissionedGsm is IGsm {
  function setBuyAccessOpen(bool open) external;

  function setSellAccessOpen(bool open) external;

  function getIsBuyAccessOpen() external view returns (bool);

  function getIsSellAccessOpen() external view returns (bool);

  function BUY_ASSET_ROLE() external pure returns (bytes32);

  function SELL_ASSET_ROLE() external pure returns (bytes32);

  function SWAP_ACCESS_MANAGER_ROLE() external pure returns (bytes32);
}
