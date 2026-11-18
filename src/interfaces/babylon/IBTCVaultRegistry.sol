// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BTCVaultBasicInfo, BTCVaultProtocolInfo} from './BabylonTypes.sol';

/**
 * @dev Subset of Babylon's BTCVaultRegistry.
 */
interface IBTCVaultRegistry {
  error VaultAboveMaximum(uint256 actual, uint256 maximum);

  error CapExceeded();

  function registerVaultProvider(
    bytes32 btcPubKeyXOnly,
    bytes memory btcPopSignature,
    address applicationEntryPoint,
    uint16 commissionBps,
    bytes memory payoutScriptPubKey
  ) external payable;

  function submitPeginRequest(
    address depositor,
    bytes32 depositorBtcPubKey,
    bytes memory btcPopSignature,
    bytes memory unsignedPrePeginTx,
    bytes memory depositorSignedPeginTx,
    address vaultProvider,
    uint16 maxAcceptableCommissionBps,
    bytes32 hashlock,
    uint8 htlcVout,
    bytes memory depositorPayoutBtcAddress,
    bytes32 depositorWotsPkHash,
    bytes32 expectedFingerprint
  ) external payable returns (bytes32);

  function submitPeginInputSignatureAsVP(bytes32 vaultId, bytes calldata signature) external;

  function submitPeginInputSignatureAsVK(
    bytes32 vaultId,
    bytes32 btcPubKey,
    bytes calldata signature
  ) external;

  function submitPeginInputSignatureAsUC(
    bytes32 vaultId,
    bytes32 btcPubKey,
    bytes calldata signature
  ) external;

  function submitPeginACK(bytes32 vaultId, bytes memory signature) external;

  function activateVaultWithSecret(
    bytes32 vaultId,
    bytes32 s,
    bytes memory activationMetadata
  ) external;

  function redeemVaultForAVK(bytes32 vaultId, bytes32 claimerBtcPubKey) external;

  function redeemVaultForDepositor(bytes32 vaultId) external;

  function unfreeze() external;

  function getBtcVaultBasicInfo(bytes32 vaultId) external view returns (BTCVaultBasicInfo memory);

  function getBtcVaultProtocolInfo(
    bytes32 vaultId
  ) external view returns (BTCVaultProtocolInfo memory);

  function getBTCVaultAmountsBatch(
    bytes32[] calldata vaultIds
  ) external view returns (uint256[] memory);

  function getPegInFee(address vaultProvider) external view returns (uint256);

  function vpKeyEpochCurrent() external view returns (uint64);

  function getOperationBtcKeyAtEpoch(
    address provider,
    uint64 epoch
  ) external view returns (bytes32);

  function pauseState() external view returns (uint8);

  function protocolParams() external view returns (address);

  function applicationRegistry() external view returns (address);

  function feeEscrow() external view returns (address);

  function capPolicy() external view returns (address);

  function allowListPolicy() external view returns (address);
}
