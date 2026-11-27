// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ApplicationCapParams} from './BabylonTypes.sol';

/**
 * @dev Subset of Babylon's AllowListPolicy.
 */
interface IAllowListPolicy {
  function setDepositorAllowed(address appEntryPoint, address depositor, bool allowed) external;
}

/**
 * @dev Subset of Babylon's CapPolicy.
 */
interface ICapPolicy {
  function getApplicationCaps(
    address appEntryPoint
  ) external view returns (ApplicationCapParams memory);

  function getApplicationUserBTC(
    address appEntryPoint,
    address user
  ) external view returns (uint256);
}

/**
 * @dev Subset of Babylon's FeeEscrow.
 */
interface IFeeEscrow {
  function vpRegistrationFee() external view returns (uint256);
}

/**
 * @dev Subset of Babylon's AaveAdapterConfig.
 */
interface IAaveAdapterConfig {
  function getPositionSizeParams()
    external
    view
    returns (uint256 maxPositionBTC, uint256 maxVaultsPerPosition);
}
