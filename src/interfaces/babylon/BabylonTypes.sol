// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Structs of Babylon's Trustless Bitcoin Vaults contracts used by the interfaces in this folder.
 */
struct BTCVaultBasicInfo {
  address depositor;
  bytes32 depositorBtcPubKey;
  uint256 amount;
  address vaultProvider;
  uint8 status;
  address applicationEntryPoint;
  uint256 createdAt;
}

struct BTCVaultProtocolInfo {
  bytes depositorSignedPeginTx;
  uint16 universalChallengersVersion;
  uint16 appVaultKeepersVersion;
  uint16 offchainParamsVersion;
  uint256 verifiedAt;
  bytes32 depositorWotsPkHash;
  bytes32 hashlock;
  uint8 htlcVout;
  bytes depositorPopSignature;
  bytes32 prePeginTxHash;
  uint16 vaultProviderCommissionBps;
  uint256 claimExpiredUntil;
  uint16 vaultCoreVersion;
  uint64 vpKeyEpoch;
  uint64 appKeeperKeyEpoch;
  uint64 ucKeyEpoch;
}

struct TokenAmount {
  address token;
  uint256 amount;
}

struct MarketPosition {
  bytes32[] vaultIds;
  uint256 totalCollateralBTC;
  address proxyContract;
}

struct AddressBTCKeyPair {
  address ethAddress;
  bytes32 btcPubKey;
}
