// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BTCVaultBasicInfo, BTCVaultProtocolInfo} from './BabylonTypes.sol';

/**
 * @dev Subset of Babylon's BTCVaultRegistry.
 */
interface IBTCVaultRegistry {
  function redeemVaultForAVK(bytes32 vaultId, bytes32 claimerBtcPubKey) external;

  function redeemVaultForDepositor(bytes32 vaultId) external;

  function getBtcVaultBasicInfo(bytes32 vaultId) external view returns (BTCVaultBasicInfo memory);

  function getBtcVaultProtocolInfo(
    bytes32 vaultId
  ) external view returns (BTCVaultProtocolInfo memory);

  function getBTCVaultAmountsBatch(
    bytes32[] calldata vaultIds
  ) external view returns (uint256[] memory);
}
