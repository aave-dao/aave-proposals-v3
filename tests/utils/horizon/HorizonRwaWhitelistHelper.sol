// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IPool} from 'aave-v3-origin/contracts/interfaces/IPool.sol';
import {AaveV3EthereumHorizonCustom} from './AaveV3EthereumHorizonCustom.sol';
import {AaveV3EthereumHorizonAssets} from 'aave-address-book/AaveV3EthereumHorizon.sol';

/**
 * @dev Helper for whitelisting E2E test actors on RWA compliance systems used
 *      by Horizon pool assets.  Each RWA issuer has its own compliance mechanism:
 *        - Superstate  (USTB, USCC) — AllowlistV4_2.setAllowed
 *        - Centrifuge  (JTRSY, JAAA) — RestrictionManager.endorse
 *        - Circle/USYC             — RolesAuthority.setUserRole
 *        - Securitize  (VBILL, ACRED) — RegistryService.addWallet
 *        - Midas       (mGLOBAL) — MidasAccessControl GREENLISTED_ROLE
 *
 *      Override `_whitelistRwaActors` in concrete tests to add whitelisting for
 *      newly listed assets.
 */
abstract contract HorizonRwaWhitelistHelper is Test {
  // ── Superstate (USTB, USCC) ──────────────────────────────────────────
  address internal constant SUPERSTATE_ALLOWLIST_V4_2 = 0xBcBC2b4FB2AbE1C598C9ea91E0b03338e4728D1f;

  // ── Centrifuge (JTRSY, JAAA) ─────────────────────────────────────────
  address internal constant CENTRIFUGE_HOOK = 0xa2C98F0F76Da0C97039688CA6280d082942d0b48;
  address internal constant CENTRIFUGE_WARD = 0xFEE13c017693a4706391D516ACAbF6789D5c3157;

  // ── Circle (USYC) ────────────────────────────────────────────────────
  uint8 internal constant CIRCLE_USYC_AUTHORIZED_ROLE = 19;
  address internal constant CIRCLE_SET_USER_ROLE_AUTHORIZED_CALLER =
    0xDbE01f447040F78ccbC8Dfd101BEc1a2C21f800D;

  // ── Securitize (VBILL, ACRED) ────────────────────────────────────────
  address internal constant SECURITIZE_ADMIN = 0xDA8e2d926D28a86aeE933d928357583aae5D3b85;
  string internal constant VBILL_SECURITIZE_FUND_ID = 'f27e20ca73314651b387da0aa9116f30';
  string internal constant ACRED_SECURITIZE_FUND_ID = '69023a78d57776eca9542d33';

  // ── Midas (mGLOBAL) ──────────────────────────────────────────────────
  // Shared Midas access control (mGLOBAL.accessControl()). Transfers require the
  // sender and recipient to hold mGLOBAL's product-specific greenlist role.
  address internal constant MIDAS_ACCESS_CONTROL = 0x0312A9D1Ff2372DDEdCBB21e4B6389aFc919aC4B;
  bytes32 internal constant MGLOBAL_GREENLISTED_ROLE = keccak256('M_GLOBAL_GREENLISTED_ROLE');
  // Slot of the OZ `_roles` mapping (role => account => bool) in MidasAccessControl.
  uint256 internal constant MIDAS_ROLES_SLOT = 101;

  // ── Whale addresses for tokens incompatible with foundry `deal` ────
  // Securitize DS-protocol tokens store balances in an external data store,
  // so cannot use native foundry deal. Transfer from a real holder instead.
  address internal constant ACRED_WHALE = 0xbb543C77436645C8b95B64eEc39E3C0d48D4842b;
  address internal constant VBILL_WHALE = 0x69133f8Ef7F9A5F80D25c2DAEaea64C804aC7Cf9;

  // ─── Orchestrator ────────────────────────────────────────────────────

  /**
   * @dev Whitelists all E2E test actors on every known RWA compliance system.
   *      Override in test contracts to add whitelisting for newly listed assets.
   */
  function _whitelistRwaUsers(address[] memory actors) internal virtual {
    for (uint256 i; i < actors.length; i++) {
      // Superstate (USTB, USCC)
      _whitelistSuperstateRwa(actors[i]);
      // Circle (USYC) — msg.sender in transferFrom must also be whitelisted
      _whitelistUsycRwa(actors[i]);
      // Centrifuge (JTRSY, JAAA)
      _whitelistCentrifugeRwa(actors[i]);
      // Securitize (VBILL)
      _whitelistVbillRwa(actors[i]);
      // Securitize (ACRED) — only if listed (aToken exists)
      _whitelistAcredRwa(actors[i]);
      // Midas (mGLOBAL)
      _whitelistMidasRwa(actors[i]);
    }
  }

  function _whitelistRwaPool(IPool pool) internal {
    // Superstate (USTB, USCC)
    _whitelistSuperstateRwa(_requireAToken(pool, AaveV3EthereumHorizonAssets.USTB_UNDERLYING));
    _whitelistSuperstateRwa(_requireAToken(pool, AaveV3EthereumHorizonAssets.USCC_UNDERLYING));
    // Circle (USYC)
    _whitelistUsycRwa(_requireAToken(pool, AaveV3EthereumHorizonAssets.USYC_UNDERLYING));
    // Circle (USYC) — msg.sender in transferFrom must also be whitelisted
    _whitelistUsycRwa(address(pool));
    // Centrifuge (JTRSY, JAAA)
    _whitelistCentrifugeRwa(_requireAToken(pool, AaveV3EthereumHorizonAssets.JTRSY_UNDERLYING));
    _whitelistCentrifugeRwa(_requireAToken(pool, AaveV3EthereumHorizonAssets.JAAA_UNDERLYING));
    // Securitize (VBILL)
    _whitelistVbillRwa(_requireAToken(pool, AaveV3EthereumHorizonAssets.VBILL_UNDERLYING));
    // Securitize (ACRED)
    _whitelistAcredRwa(_requireAToken(pool, AaveV3EthereumHorizonCustom.ACRED_UNDERLYING));
    // Midas (mGLOBAL)
    _whitelistMidasRwa(_requireAToken(pool, AaveV3EthereumHorizonCustom.MGLOBAL_UNDERLYING));
  }

  function _requireAToken(IPool pool, address underlying) internal view returns (address aToken) {
    aToken = pool.getReserveAToken(underlying);
    require(aToken != address(0), '_whitelistRwaPool: aToken not found');
  }

  // ─── Per-issuer helpers ──────────────────────────────────────────────

  function _whitelistSuperstateRwa(address addressToWhitelist) internal {
    _whitelistSuperstateToken(AaveV3EthereumHorizonAssets.USTB_UNDERLYING, addressToWhitelist);
    _whitelistSuperstateToken(AaveV3EthereumHorizonAssets.USCC_UNDERLYING, addressToWhitelist);
  }

  function _whitelistSuperstateToken(address token, address addressToWhitelist) internal {
    (bool success, bytes memory data) = token.staticcall(abi.encodeWithSignature('allowlist()'));
    require(
      success && abi.decode(data, (address)) == SUPERSTATE_ALLOWLIST_V4_2,
      'Superstate: unknown allowlist'
    );
    _whitelistSuperstateV4_2(token, addressToWhitelist);

    (success, data) = token.staticcall(
      abi.encodeWithSignature('isAllowed(address)', addressToWhitelist)
    );
    require(success && abi.decode(data, (bool)), 'Superstate: token does not allow account');
  }

  function _whitelistSuperstateV4_2(address token, address addressToWhitelist) internal {
    if (_isSuperstateV4_2Allowed(token, addressToWhitelist)) {
      return;
    }

    (bool success, bytes memory data) = SUPERSTATE_ALLOWLIST_V4_2.staticcall(
      abi.encodeWithSignature('owner()')
    );
    require(success, 'Failed to call owner()');

    vm.prank(abi.decode(data, (address)));
    (success, ) = SUPERSTATE_ALLOWLIST_V4_2.call(
      abi.encodeWithSignature('setAllowed(address,address,bool)', addressToWhitelist, token, true)
    );
    require(success, 'Failed to call setAllowed()');

    // Verify whitelisted
    require(
      _isSuperstateV4_2Allowed(token, addressToWhitelist),
      'Superstate: address not whitelisted'
    );
  }

  function _isSuperstateV4_2Allowed(address token, address account) internal view returns (bool) {
    (bool success, bytes memory data) = SUPERSTATE_ALLOWLIST_V4_2.staticcall(
      abi.encodeWithSignature('isAllowed(address,address)', account, token)
    );
    require(success, 'Failed to call isAllowed()');
    return abi.decode(data, (bool));
  }

  function _whitelistCentrifugeRwa(address addressToWhitelist) internal {
    (bool success, bytes memory data) = CENTRIFUGE_HOOK.call(abi.encodeWithSignature('root()'));
    require(success, 'Failed to call root()');
    address root = abi.decode(data, (address));

    // Ensure CENTRIFUGE_WARD is authorized on root (wards mapping at slot 0)
    bytes32 wardSlot = keccak256(abi.encode(CENTRIFUGE_WARD, uint256(0)));
    vm.store(root, wardSlot, bytes32(uint256(1)));

    vm.prank(CENTRIFUGE_WARD);
    (success, ) = root.call(abi.encodeWithSignature('endorse(address)', addressToWhitelist));
    require(success, 'Failed to call endorse()');

    // Verify whitelisted
    (success, data) = root.call(abi.encodeWithSignature('endorsed(address)', addressToWhitelist));
    require(success && abi.decode(data, (bool)), 'Centrifuge: address not endorsed');
  }

  function _whitelistUsycRwa(address addressToWhitelist) internal {
    (bool success, bytes memory data) = AaveV3EthereumHorizonAssets.USYC_UNDERLYING.call(
      abi.encodeWithSignature('authority()')
    );
    require(success, 'Failed to call authority()');
    address authority = abi.decode(data, (address));

    vm.prank(CIRCLE_SET_USER_ROLE_AUTHORIZED_CALLER);
    (success, ) = authority.call(
      abi.encodeWithSignature(
        'setUserRole(address,uint8,bool)',
        addressToWhitelist,
        CIRCLE_USYC_AUTHORIZED_ROLE,
        true
      )
    );
    require(success, 'Failed to call setUserRole()');

    // Verify whitelisted
    (success, data) = authority.call(
      abi.encodeWithSignature(
        'doesUserHaveRole(address,uint8)',
        addressToWhitelist,
        CIRCLE_USYC_AUTHORIZED_ROLE
      )
    );
    require(success && abi.decode(data, (bool)), 'USYC: address not whitelisted');
  }

  function _whitelistVbillRwa(address addressToWhitelist) internal {
    _whitelistSecuritizeRwa(
      AaveV3EthereumHorizonAssets.VBILL_UNDERLYING,
      SECURITIZE_ADMIN,
      VBILL_SECURITIZE_FUND_ID,
      addressToWhitelist
    );
  }

  function _whitelistAcredRwa(address addressToWhitelist) internal {
    _whitelistSecuritizeRwa(
      AaveV3EthereumHorizonCustom.ACRED_UNDERLYING,
      SECURITIZE_ADMIN,
      ACRED_SECURITIZE_FUND_ID,
      addressToWhitelist
    );
  }

  /// @dev Midas whitelisting: grants mGLOBAL's greenlist role on the shared MidasAccessControl.
  function _whitelistMidasRwa(address addressToWhitelist) internal {
    bytes32 slot = keccak256(
      abi.encode(
        addressToWhitelist,
        keccak256(abi.encode(MGLOBAL_GREENLISTED_ROLE, MIDAS_ROLES_SLOT))
      )
    );
    vm.store(MIDAS_ACCESS_CONTROL, slot, bytes32(uint256(1)));

    // Verify whitelisted
    (bool success, bytes memory data) = MIDAS_ACCESS_CONTROL.call(
      abi.encodeWithSignature(
        'hasRole(bytes32,address)',
        MGLOBAL_GREENLISTED_ROLE,
        addressToWhitelist
      )
    );
    require(success && abi.decode(data, (bool)), 'Midas: address not greenlisted');
  }

  /**
   * @dev Generic Securitize whitelisting via RegistryService.addWallet.
   *      Reuse for any Securitize DS-protocol token (VBILL, ACRED, etc.) by supplying
   *      the token-specific admin and fund reference ID.
   */
  function _whitelistSecuritizeRwa(
    address token,
    address admin,
    string memory fundId,
    address addressToWhitelist
  ) internal {
    (bool success, bytes memory data) = token.call(abi.encodeWithSignature('REGISTRY_SERVICE()'));
    require(success, 'Failed to call REGISTRY_SERVICE()');
    (success, data) = token.call(
      abi.encodeWithSignature('getDSService(uint256)', abi.decode(data, (uint256)))
    );
    require(success, 'Failed to call getDSService()');
    address registryService = abi.decode(data, (address));

    // Ensure admin has a role on the trust service (role mapping at slot 1)
    (success, data) = token.call(abi.encodeWithSignature('TRUST_SERVICE()'));
    require(success, 'Failed to call TRUST_SERVICE()');
    (success, data) = token.call(
      abi.encodeWithSignature('getDSService(uint256)', abi.decode(data, (uint256)))
    );
    require(success, 'Failed to call getDSService() for trust');
    address trustService = abi.decode(data, (address));
    bytes32 roleSlot = keccak256(abi.encode(admin, uint256(1)));
    vm.store(trustService, roleSlot, bytes32(uint256(2)));

    if (_isSecuritizeWhitelisted(registryService, addressToWhitelist)) return;

    vm.prank(admin);
    (success, ) = registryService.call(
      abi.encodeWithSignature('addWallet(address,string)', addressToWhitelist, fundId)
    );
    // always verify the address is whitelisted as a regular wallet OR passes compliance as a special wallet.
    require(
      _isSecuritizeWhitelisted(registryService, addressToWhitelist) ||
        _passesSecuritizeCompliance(token, addressToWhitelist),
      'Securitize: not whitelisted'
    );
  }

  /// @dev Returns true if `addr` is whitelisted as a regular wallet.
  function _isSecuritizeWhitelisted(address registryService, address addr) internal returns (bool) {
    (bool success, bytes memory data) = registryService.call(
      abi.encodeWithSignature('isWallet(address)', addr)
    );
    return success && abi.decode(data, (bool));
  }

  /// @dev Checks if `addr` passes the DS compliance service's preTransferCheck (code 0 = allowed).
  function _passesSecuritizeCompliance(address token, address addr) internal returns (bool) {
    (bool success, bytes memory data) = token.call(abi.encodeWithSignature('COMPLIANCE_SERVICE()'));
    if (!success) return false;
    (success, data) = token.call(
      abi.encodeWithSignature('getDSService(uint256)', abi.decode(data, (uint256)))
    );
    if (!success) return false;
    address complianceService = abi.decode(data, (address));

    (success, data) = complianceService.call(
      abi.encodeWithSignature('preTransferCheck(address,address,uint256)', addr, addr, 0)
    );
    if (!success) return false;
    (uint256 code, ) = abi.decode(data, (uint256, string));
    return code == 0;
  }

  /// @dev Returns true if `token` requires tokens from whale instead of foundry's `deal`.
  function _needsWhaleDeal(address token) internal pure returns (bool) {
    return
      token == AaveV3EthereumHorizonCustom.ACRED_UNDERLYING ||
      token == AaveV3EthereumHorizonAssets.VBILL_UNDERLYING;
  }

  /// @dev Returns the whale address for `token`.
  function _getWhale(address token) internal pure returns (address) {
    if (token == AaveV3EthereumHorizonCustom.ACRED_UNDERLYING) {
      return ACRED_WHALE;
    } else if (token == AaveV3EthereumHorizonAssets.VBILL_UNDERLYING) {
      return VBILL_WHALE;
    } else {
      revert('_getWhale: no whale configured');
    }
  }

  /// @dev Transfers `amount` of `token` to `recipient` from a known whale.
  /// @notice Assumes `recipient` is already whitelisted to hold the token, otherwise reverts.
  function _dealRwaToken(address token, address recipient, uint256 amount) internal {
    address whale = _getWhale(token);
    require(IERC20(token).balanceOf(whale) >= amount, 'whale has insufficient balance');

    vm.prank(whale);
    IERC20(token).transfer(recipient, amount);
  }
}
