// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AddressBTCKeyPair, TBVProtocolParams} from './BabylonTypes.sol';

/**
 * @dev Subset of Babylon's ProtocolParams.
 */
interface IProtocolParams {
  function addUniversalChallengersVersion(AddressBTCKeyPair[] calldata challengers) external;

  function latestUniversalChallengersVersion() external view returns (uint16);

  function ucKeyEpochCurrent() external view returns (uint64);

  function latestOffchainParamsVersion() external view returns (uint16);

  function activeVaultCoreVersion() external view returns (uint16);

  function getTBVProtocolParams() external view returns (TBVProtocolParams memory);
}
