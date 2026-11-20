// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from 'forge-std/Vm.sol';
import {SafeCast} from 'aave-v4/dependencies/openzeppelin/SafeCast.sol';
import {IBTCVaultRegistry} from 'src/interfaces/babylon/IBTCVaultRegistry.sol';
import {IApplicationRegistry} from 'src/interfaces/babylon/IApplicationRegistry.sol';
import {IProtocolParams} from 'src/interfaces/babylon/IProtocolParams.sol';
import {IAllowListPolicy, IFeeEscrow} from 'src/interfaces/babylon/IBabylonPolicies.sol';
import {AddressBTCKeyPair, VaultKeeperRegistration} from 'src/interfaces/babylon/BabylonTypes.sol';
import {BabylonTestBase} from './BabylonTestBase.sol';
import {BabylonMainnet} from './BabylonMainnet.sol';

/**
 * @dev Pegs BTC vaults into Babylon's deployed BTCVaultRegistry on the fork, up to the activation
 * with the HTLC secret, where the registry activates the vault on the AaveAdapter. The vault
 * provider, the vault keeper and the universal challenger are test accounts, installed as a new
 * roster version by Babylon's protocol timelock. The registry checks no Bitcoin inclusion proof and
 * stores the peg-in input signatures without verifying them, so the Bitcoin transactions are never
 * broadcast and the signatures are placeholders.
 */
abstract contract BabylonPegInHelper is BabylonTestBase {
  using SafeCast for uint256;

  struct PegInRequest {
    address depositor;
    bytes32 depositorBtcPubKey;
    bytes btcPopSignature;
    bytes unsignedPrePeginTx;
    bytes depositorSignedPeginTx;
    bytes32 hashlock;
    bytes depositorPayoutBtcAddress;
    bytes32 depositorWotsPkHash;
    bytes32 expectedFingerprint;
    bytes32 secret;
    uint256 fee;
  }

  // BTCVaultRegistry vault status
  uint8 internal constant REGISTRY_VAULT_PENDING = 0;
  uint8 internal constant REGISTRY_VAULT_VERIFIED = 1;
  uint8 internal constant REGISTRY_VAULT_ACTIVE = 2;
  uint8 internal constant REGISTRY_VAULT_REDEEMED = 3;

  // BTCVaultRegistry pause state
  uint8 internal constant REGISTRY_FROZEN = 1;

  // Babylon's Constants.MIN_VP_COMMISSION_BPS
  uint16 internal constant VAULT_PROVIDER_COMMISSION_BPS = 1;
  // PeginLogic.PEGIN_FINGERPRINT_DOMAIN
  bytes32 internal constant PEGIN_FINGERPRINT_DOMAIN = keccak256('TBV.PeginFingerprint.v1');
  uint256 internal constant SECONDS_PER_BLOCK = 12;

  IBTCVaultRegistry internal registry = IBTCVaultRegistry(BabylonMainnet.BTC_VAULT_REGISTRY);
  IApplicationRegistry internal applicationRegistry =
    IApplicationRegistry(BabylonMainnet.APPLICATION_REGISTRY);
  IProtocolParams internal protocolParams = IProtocolParams(BabylonMainnet.PROTOCOL_PARAMS);

  Vm.Wallet internal vaultProvider;
  Vm.Wallet internal vaultKeeper;
  Vm.Wallet internal universalChallenger;
  Vm.Wallet internal depositorBtcWallet;

  mapping(bytes32 vaultId => bytes32) internal _pegInSecrets;
  uint256 internal _pegInNonce;

  function _setUpPegIns(address depositor) internal {
    vaultProvider = vm.createWallet('testVaultProvider');
    vaultKeeper = vm.createWallet('testVaultKeeper');
    universalChallenger = vm.createWallet('testUniversalChallenger');
    depositorBtcWallet = vm.createWallet('testDepositorBtcKey');

    assertEq(registry.protocolParams(), address(protocolParams), 'protocol params');
    assertEq(registry.applicationRegistry(), address(applicationRegistry), 'application registry');
    assertEq(registry.feeEscrow(), BabylonMainnet.FEE_ESCROW, 'fee escrow');
    assertEq(registry.allowListPolicy(), BabylonMainnet.ALLOW_LIST_POLICY, 'allow list policy');
    assertEq(registry.capPolicy(), BabylonMainnet.CAP_POLICY, 'cap policy');

    _unfreezeRegistry();
    _installTestRoster();
    vm.prank(BabylonMainnet.PROTOCOL_TIMELOCK);
    IAllowListPolicy(BabylonMainnet.ALLOW_LIST_POLICY).setDepositorAllowed({
      appEntryPoint: BABYLON_AAVE_ADAPTER,
      depositor: depositor,
      allowed: true
    });
    _registerVaultProvider();
  }

  /// @dev The BTCVaultRegistry is frozen at the fork block, which blocks vault provider
  /// registration and every peg-in step before activation.
  function _unfreezeRegistry() internal {
    assertEq(registry.pauseState(), REGISTRY_FROZEN, 'registry frozen');
    vm.prank(BABYLON_INTERIM_GOVERNANCE);
    registry.unfreeze();
  }

  /// @dev Every keeper and challenger of the roster a vault is bound to must acknowledge its peg-in,
  /// so the roster is replaced by one whose keys the test holds.
  function _installTestRoster() internal {
    VaultKeeperRegistration[] memory keepers = new VaultKeeperRegistration[](1);
    keepers[0] = VaultKeeperRegistration({
      adminEthAddress: vaultKeeper.addr,
      opBtcKey: _btcKey(vaultKeeper),
      payoutScript: _p2trScript(_btcKey(vaultKeeper)),
      opEthKey: address(0),
      ethPopSignature: ''
    });
    AddressBTCKeyPair[] memory challengers = new AddressBTCKeyPair[](1);
    challengers[0] = AddressBTCKeyPair({
      ethAddress: universalChallenger.addr,
      btcPubKey: _btcKey(universalChallenger)
    });

    vm.startPrank(BabylonMainnet.PROTOCOL_TIMELOCK);
    applicationRegistry.addVaultKeepersVersion(BABYLON_AAVE_ADAPTER, keepers);
    protocolParams.addUniversalChallengersVersion(challengers);
    vm.stopPrank();
  }

  function _registerVaultProvider() internal {
    uint256 fee = IFeeEscrow(BabylonMainnet.FEE_ESCROW).vpRegistrationFee();
    bytes memory proofOfPossession = _btcProofOfPossession(vaultProvider, vaultProvider.addr);
    deal(vaultProvider.addr, fee);
    vm.prank(vaultProvider.addr);
    registry.registerVaultProvider{value: fee}({
      btcPubKeyXOnly: _btcKey(vaultProvider),
      btcPopSignature: proofOfPossession,
      applicationEntryPoint: BABYLON_AAVE_ADAPTER,
      commissionBps: VAULT_PROVIDER_COMMISSION_BPS,
      payoutScriptPubKey: _p2trScript(_btcKey(vaultProvider))
    });
  }

  /// @dev Full peg-in. The registry activates the vault on the AaveAdapter.
  function _pegIn(address depositor, uint256 amount) internal returns (bytes32 vaultId) {
    vaultId = _pegInUntilVerified(depositor, amount);
    _passActivationDelay(vaultId);
    _activateVaultWithSecret(vaultId);
  }

  /// @dev Peg-in up to the last acknowledgement, which leaves the vault verified.
  function _pegInUntilVerified(
    address depositor,
    uint256 amount
  ) internal returns (bytes32 vaultId) {
    vaultId = _submitPegIn(_buildPegIn(depositor, amount));
    assertEq(_registryVaultStatus(vaultId), REGISTRY_VAULT_PENDING, 'vault pending');
    _submitPeginInputSignatures(vaultId);
    _acknowledge(vaultId);
    assertEq(_registryVaultStatus(vaultId), REGISTRY_VAULT_VERIFIED, 'vault verified');
  }

  function _buildPegIn(
    address depositor,
    uint256 amount
  ) internal returns (PegInRequest memory request) {
    uint256 nonce = ++_pegInNonce;
    request.depositor = depositor;
    request.depositorBtcPubKey = _btcKey(depositorBtcWallet);
    // only its length is checked on-chain
    request.btcPopSignature = new bytes(66);
    request.secret = keccak256(abi.encode('secret', depositor, nonce));
    request.hashlock = sha256(abi.encodePacked(request.secret));
    request.depositorPayoutBtcAddress = _p2trScript(request.depositorBtcPubKey);
    request.depositorWotsPkHash = keccak256(abi.encode('wots', depositor, nonce));
    request.unsignedPrePeginTx = _prePeginTx({
      fundingTxId: keccak256(abi.encode('funding', depositor, nonce)),
      htlcOutputKey: request.depositorBtcPubKey,
      amount: amount
    });
    request.depositorSignedPeginTx = _peginTx({
      prePeginTxId: sha256(abi.encodePacked(sha256(request.unsignedPrePeginTx))),
      vaultOutputKey: request.depositorBtcPubKey,
      amount: amount
    });
    request.expectedFingerprint = _peginFingerprint();
    request.fee = registry.getPegInFee(vaultProvider.addr);
    deal(depositor, depositor.balance + request.fee);
  }

  function _submitPegIn(PegInRequest memory request) internal returns (bytes32 vaultId) {
    vm.prank(request.depositor);
    vaultId = registry.submitPeginRequest{value: request.fee}({
      depositor: request.depositor,
      depositorBtcPubKey: request.depositorBtcPubKey,
      btcPopSignature: request.btcPopSignature,
      unsignedPrePeginTx: request.unsignedPrePeginTx,
      depositorSignedPeginTx: request.depositorSignedPeginTx,
      vaultProvider: vaultProvider.addr,
      maxAcceptableCommissionBps: VAULT_PROVIDER_COMMISSION_BPS,
      hashlock: request.hashlock,
      htlcVout: 0,
      depositorPayoutBtcAddress: request.depositorPayoutBtcAddress,
      depositorWotsPkHash: request.depositorWotsPkHash,
      expectedFingerprint: request.expectedFingerprint
    });
    _pegInSecrets[vaultId] = request.secret;
  }

  /// @dev Each participant posts from its own operation key. The registry stores the 64 bytes
  /// without verifying them.
  function _submitPeginInputSignatures(bytes32 vaultId) internal {
    bytes memory signature = new bytes(64);
    vm.prank(vaultProvider.addr);
    registry.submitPeginInputSignatureAsVP(vaultId, signature);
    vm.prank(vaultKeeper.addr);
    registry.submitPeginInputSignatureAsVK({
      vaultId: vaultId,
      btcPubKey: _btcKey(vaultKeeper),
      signature: signature
    });
    vm.prank(universalChallenger.addr);
    registry.submitPeginInputSignatureAsUC({
      vaultId: vaultId,
      btcPubKey: _btcKey(universalChallenger),
      signature: signature
    });
  }

  /// @dev Anyone can relay the signed acknowledgements.
  function _acknowledge(bytes32 vaultId) internal {
    registry.submitPeginACK(vaultId, _ackSignature(vaultProvider, vaultId));
    registry.submitPeginACK(vaultId, _ackSignature(vaultKeeper, vaultId));
    registry.submitPeginACK(vaultId, _ackSignature(universalChallenger, vaultId));
  }

  /// @dev A verified vault can only be activated once the observation window has elapsed.
  function _passActivationDelay(bytes32 vaultId) internal {
    uint256 activationBlock = registry.getBtcVaultProtocolInfo(vaultId).verifiedAt +
      protocolParams.getTBVProtocolParams().peginActivationDelay;
    if (block.number >= activationBlock) return;
    skip((activationBlock - block.number) * SECONDS_PER_BLOCK);
    vm.roll(activationBlock);
  }

  function _activateVaultWithSecret(bytes32 vaultId) internal {
    address depositor = registry.getBtcVaultBasicInfo(vaultId).depositor;
    vm.prank(depositor);
    registry.activateVaultWithSecret({
      vaultId: vaultId,
      s: _pegInSecrets[vaultId],
      activationMetadata: ''
    });
  }

  function _registryVaultStatus(bytes32 vaultId) internal view returns (uint8) {
    return registry.getBtcVaultBasicInfo(vaultId).status;
  }

  /// @dev Mirrors PeginLogic._peginFingerprint, which has no getter, over the live values.
  function _peginFingerprint() internal view returns (bytes32) {
    return
      keccak256(
        abi.encode(
          PEGIN_FINGERPRINT_DOMAIN,
          block.chainid,
          address(registry),
          registry.getOperationBtcKeyAtEpoch(vaultProvider.addr, registry.vpKeyEpochCurrent()),
          applicationRegistry.appKeeperKeyEpochCurrent(BABYLON_AAVE_ADAPTER),
          protocolParams.ucKeyEpochCurrent(),
          applicationRegistry.getCurrentVaultKeepersVersion(BABYLON_AAVE_ADAPTER),
          protocolParams.latestUniversalChallengersVersion(),
          protocolParams.latestOffchainParamsVersion(),
          protocolParams.activeVaultCoreVersion()
        )
      );
  }

  function _ackSignature(
    Vm.Wallet memory signer,
    bytes32 vaultId
  ) internal view returns (bytes memory) {
    bytes32 ackHash = keccak256(
      abi.encodePacked('PEGIN_ACK:', vaultId, block.chainid, address(registry))
    );
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      signer.privateKey,
      keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', ackHash))
    );
    return abi.encodePacked(r, s, v);
  }

  // ─── Bitcoin encoding ───

  /// @dev x-only public key.
  function _btcKey(Vm.Wallet memory wallet) internal pure returns (bytes32) {
    return bytes32(wallet.publicKeyX);
  }

  function _compressedPubKey(Vm.Wallet memory wallet) internal pure returns (bytes memory) {
    return
      abi.encodePacked(wallet.publicKeyY % 2 == 0 ? bytes1(0x02) : bytes1(0x03), _btcKey(wallet));
  }

  function _p2trScript(bytes32 outputKey) internal pure returns (bytes memory) {
    return abi.encodePacked(hex'5120', outputKey);
  }

  /// @dev One funding input, the HTLC output at index 0 and a pay-to-anchor output.
  function _prePeginTx(
    bytes32 fundingTxId,
    bytes32 htlcOutputKey,
    uint256 amount
  ) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        hex'02000000', // version
        hex'01', // input count
        fundingTxId,
        hex'00000000', // funding output index
        hex'00', // scriptSig length
        hex'ffffffff', // sequence
        hex'02', // output count
        _le64(amount + 1000),
        hex'22', // script length
        _p2trScript(htlcOutputKey),
        _le64(240),
        hex'0451024e73', // pay-to-anchor
        hex'00000000' // locktime
      );
  }

  /// @dev Spends the HTLC output into the vault output at index 0, in SegWit serialization with
  /// the depositor's 64 byte witness signature.
  function _peginTx(
    bytes32 prePeginTxId,
    bytes32 vaultOutputKey,
    uint256 amount
  ) internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        hex'02000000', // version
        hex'0001', // SegWit marker and flag
        hex'01', // input count
        prePeginTxId,
        hex'00000000', // HTLC output index
        hex'00', // scriptSig length
        hex'ffffffff', // sequence
        hex'01', // output count
        _le64(amount),
        hex'22', // script length
        _p2trScript(vaultOutputKey),
        hex'0140', // one witness item of 64 bytes
        new bytes(64),
        hex'00000000' // locktime
      );
  }

  function _le64(uint256 value) internal pure returns (bytes8 encoded) {
    uint64 remaining = value.toUint64();
    for (uint256 i; i < 8; ++i) {
      encoded |= bytes8(bytes1(uint8(remaining))) >> (i * 8); // intentional truncation to the low byte
      remaining >>= 8;
    }
  }

  /// @dev BIP-322 simple signature for a P2WPKH address, the ECDSA form BTCProofOfPossession
  /// accepts, over the message the registry builds for a registration.
  function _btcProofOfPossession(
    Vm.Wallet memory wallet,
    address owner
  ) internal view returns (bytes memory) {
    bytes memory message = abi.encodePacked(
      vm.toLowercase(vm.toString(owner)),
      ':',
      vm.toString(block.chainid),
      ':register:',
      vm.toLowercase(vm.toString(address(registry)))
    );
    bytes memory compressedPubKey = _compressedPubKey(wallet);
    (, bytes32 r, bytes32 s) = vm.sign(
      wallet.privateKey,
      _bip322SigHashP2WPKH({message: message, compressedPubKey: compressedPubKey})
    );
    bytes memory der = abi.encodePacked(_derInteger(r), _derInteger(s));
    der = abi.encodePacked(hex'30', der.length.toUint8(), der, hex'01'); // SIGHASH_ALL
    return abi.encodePacked(hex'02', der.length.toUint8(), der, hex'21', compressedPubKey);
  }

  /// @dev Mirrors BIP322Utils.calculateBIP322SigHashP2WPKH.
  function _bip322SigHashP2WPKH(
    bytes memory message,
    bytes memory compressedPubKey
  ) internal pure returns (bytes32) {
    bytes32 tagHash = sha256('BIP0322-signed-message');
    bytes32 messageHash = sha256(abi.encodePacked(tagHash, tagHash, message));
    bytes20 pubKeyHash = ripemd160(abi.encodePacked(sha256(compressedPubKey)));

    bytes memory toSpendTx = abi.encodePacked(
      hex'00000000', // version
      hex'01', // input count
      bytes32(0),
      hex'ffffffff', // previous output index
      hex'220020', // scriptSig: OP_0 PUSH32
      messageHash,
      hex'00000000', // sequence
      hex'01', // output count
      hex'0000000000000000', // value
      hex'160014', // P2WPKH script
      pubKeyHash,
      hex'00000000' // locktime
    );
    bytes32 toSpendTxId = _hash256(toSpendTx);

    // BIP-143 digest of the to_sign transaction
    return
      _hash256(
        abi.encodePacked(
          hex'00000000', // version
          _hash256(abi.encodePacked(toSpendTxId, hex'00000000')), // hashPrevouts
          _hash256(hex'00000000'), // hashSequence
          toSpendTxId,
          hex'00000000', // previous output index
          hex'1976a914', // scriptCode
          pubKeyHash,
          hex'88ac',
          hex'0000000000000000', // value
          hex'00000000', // sequence
          _hash256(hex'0000000000000000016a'), // hashOutputs: one empty OP_RETURN
          hex'00000000', // locktime
          hex'01000000' // SIGHASH_ALL
        )
      );
  }

  function _hash256(bytes memory data) internal pure returns (bytes32) {
    return sha256(abi.encodePacked(sha256(data)));
  }

  /// @dev Minimal DER integer.
  function _derInteger(bytes32 value) internal pure returns (bytes memory encoded) {
    uint256 start;
    while (start < 31 && value[start] == 0) ++start;
    encoded = new bytes(32 - start);
    for (uint256 i = start; i < 32; ++i) encoded[i - start] = value[i];
    if (encoded[0] & 0x80 != 0) encoded = abi.encodePacked(hex'00', encoded);
    return abi.encodePacked(hex'02', encoded.length.toUint8(), encoded);
  }
}
