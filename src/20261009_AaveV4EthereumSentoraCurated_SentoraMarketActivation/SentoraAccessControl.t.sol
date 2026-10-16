// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHubConfigurator, ISpokeConfigurator} from 'aave-address-book/AaveV4.sol';
import {IOwnable} from 'aave-address-book/common/IOwnable.sol';
import {IOwnable2Step} from 'src/interfaces/IOwnable2Step.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';

interface IRescuable {
  function rescueGuardian() external view returns (address);
}

/// @dev End state of roles and ownerships once the Fee Admin acceptance and the activation payload
/// have run.
contract SentoraAccessControl_Test is SentoraTestBase {
  /// @dev TreasurySpoke ProxyAdmin, created by the market deploy and moved to the Security Council
  /// by the relinquish.
  address internal constant TREASURY_SPOKE_PROXY_ADMIN = 0xB73edB24752457229f15B598A9bB4F53384Add3c;

  function setUp() public override {
    super.setUp();
    _acceptTreasurySpokeOwnership();
    _activate();
  }

  function test_roleMembers() public view {
    _assertMembers(ADMIN_ROLE, _list(SECURITY_COUNCIL, EXECUTOR_LVL_1));
    _assertMembers(HUB_CONFIGURATOR_ROLE, _list(address(HUB_CONFIGURATOR)));
    _assertMembers(SPOKE_CONFIGURATOR_ROLE, _list(address(SPOKE_CONFIGURATOR)));
    // the Council Executor keeps the roles it ran the pre-launch config with
    _assertMembers(HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE, _list(EXECUTOR, COUNCIL_EXECUTOR));
    _assertMembers(SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE, _list(EXECUTOR, COUNCIL_EXECUTOR));
    _assertMembers(SENTORA_RISK_ROLE, _list(EXECUTOR, address(RISK_STEWARD), COUNCIL_EXECUTOR));
    _assertMembers(
      SENTORA_EMERGENCY_ROLE,
      _list(EMERGENCY_ADMIN, SECURITY_COUNCIL, COUNCIL_EXECUTOR)
    );
  }

  function test_otherRolesEmpty() public view {
    uint256 roleCount = ACCESS_MANAGER.getRoleCount();
    uint256 held;
    for (uint256 i; i < roleCount; ++i) {
      uint64 role = ACCESS_MANAGER.getRole(i);
      if (_isHeldRole(role)) {
        ++held;
      } else {
        assertEq(ACCESS_MANAGER.getRoleMemberCount(role), 0, 'unexpected member');
      }
    }
    // every held role but 0 is enumerated
    assertEq(held, 6, 'held roles');
    uint64[5] memory unheld = [uint64(100), 102, 103, 300, 302];
    for (uint256 i; i < unheld.length; ++i) {
      assertEq(ACCESS_MANAGER.getRoleMemberCount(unheld[i]), 0, 'unheld role');
    }
  }

  function test_deployerHoldsNoRole() public view {
    (bool isAdmin, ) = ACCESS_MANAGER.hasRole(ADMIN_ROLE, DEPLOYER);
    assertFalse(isAdmin, 'role 0');
    uint256 roleCount = ACCESS_MANAGER.getRoleCount();
    for (uint256 i; i < roleCount; ++i) {
      (bool isMember, ) = ACCESS_MANAGER.hasRole(ACCESS_MANAGER.getRole(i), DEPLOYER);
      assertFalse(isMember, 'deployer role');
    }
  }

  function test_delaysZero() public view {
    uint64[7] memory roles = [
      ADMIN_ROLE,
      HUB_CONFIGURATOR_ROLE,
      SPOKE_CONFIGURATOR_ROLE,
      HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      SENTORA_RISK_ROLE,
      SENTORA_EMERGENCY_ROLE
    ];
    for (uint256 i; i < roles.length; ++i) {
      assertEq(ACCESS_MANAGER.getRoleGrantDelay(roles[i]), 0, 'grant delay');
      uint256 members = ACCESS_MANAGER.getRoleMemberCount(roles[i]);
      for (uint256 j; j < members; ++j) {
        (bool isMember, uint32 executionDelay) = ACCESS_MANAGER.hasRole(
          roles[i],
          ACCESS_MANAGER.getRoleMember(roles[i], j)
        );
        assertTrue(isMember, 'member');
        assertEq(executionDelay, 0, 'execution delay');
      }
    }
    address[] memory targets = _managedTargets();
    for (uint256 i; i < targets.length; ++i) {
      assertEq(ACCESS_MANAGER.getTargetAdminDelay(targets[i]), 0, 'target admin delay');
      assertFalse(ACCESS_MANAGER.isTargetClosed(targets[i]), 'target closed');
    }
  }

  function test_hubConfiguratorSelectorRoles() public view {
    bytes4[] memory risk = _hubRiskSelectors();
    bytes4[] memory emergency = _hubEmergencySelectors();
    bytes4[] memory domainAdmin = _hubDomainAdminSelectors();
    assertEq(risk.length + emergency.length + domainAdmin.length, 22, 'hub selectors');
    _assertSelectors(address(HUB_CONFIGURATOR), risk, SENTORA_RISK_ROLE);
    _assertSelectors(address(HUB_CONFIGURATOR), emergency, SENTORA_EMERGENCY_ROLE);
    _assertSelectors(address(HUB_CONFIGURATOR), domainAdmin, HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE);
  }

  function test_spokeConfiguratorSelectorRoles() public view {
    bytes4[] memory risk = _spokeRiskSelectors();
    bytes4[] memory emergency = _spokeEmergencySelectors();
    bytes4[] memory domainAdmin = _spokeDomainAdminSelectors();
    assertEq(risk.length + emergency.length + domainAdmin.length, 24, 'spoke selectors');
    _assertSelectors(address(SPOKE_CONFIGURATOR), risk, SENTORA_RISK_ROLE);
    _assertSelectors(address(SPOKE_CONFIGURATOR), emergency, SENTORA_EMERGENCY_ROLE);
    _assertSelectors(
      address(SPOKE_CONFIGURATOR),
      domainAdmin,
      SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE
    );
  }

  function test_executorOwnsManagersAndGateways() public view {
    address[] memory owned = _ownedByExecutor();
    for (uint256 i; i < owned.length; ++i) {
      assertEq(IOwnable(owned[i]).owner(), EXECUTOR, 'owner');
      assertEq(IOwnable2Step(owned[i]).pendingOwner(), address(0), 'pending owner');
      assertEq(IRescuable(owned[i]).rescueGuardian(), EXECUTOR, 'rescue guardian');
    }
  }

  function test_treasurySpokeOwnedByFeeAdmin() public view {
    assertEq(IOwnable(address(TREASURY_SPOKE)).owner(), FEE_ADMIN, 'owner');
    assertEq(IOwnable2Step(address(TREASURY_SPOKE)).pendingOwner(), address(0), 'pending owner');
  }

  function test_proxyAdminsOwnedBySecurityCouncil() public view {
    address[] memory proxies = _marketProxies();
    for (uint256 i; i < proxies.length; ++i) {
      address proxyAdmin = _proxyAdmin(proxies[i]);
      assertNotEq(proxyAdmin, address(0), 'not a proxy');
      assertEq(IOwnable(proxyAdmin).owner(), SECURITY_COUNCIL, 'proxy admin owner');
    }
    assertEq(
      _proxyAdmin(address(TREASURY_SPOKE)),
      TREASURY_SPOKE_PROXY_ADMIN,
      'treasury proxy admin'
    );
  }

  function test_riskStewardOwnedBySecurityCouncil() public view {
    assertEq(RISK_STEWARD.owner(), SECURITY_COUNCIL, 'owner');
    assertEq(RISK_STEWARD.pendingOwner(), address(0), 'pending owner');
    assertEq(RISK_STEWARD.RISK_COUNCIL(), address(WRAPPER), 'steward council');
    assertEq(address(WRAPPER.RISK_STEWARD()), address(RISK_STEWARD), 'wrapped steward');
    assertEq(WRAPPER.RISK_COUNCIL(), EMERGENCY_ADMIN, 'wrapper council');
  }

  function test_deployerOwnsNothing() public view {
    address[] memory owned = _ownedByExecutor();
    for (uint256 i; i < owned.length; ++i) {
      _assertNotDeployer(owned[i]);
      assertNotEq(IRescuable(owned[i]).rescueGuardian(), DEPLOYER, 'rescue guardian');
    }
    _assertNotDeployer(address(TREASURY_SPOKE));
    _assertNotDeployer(address(RISK_STEWARD));
    address[] memory proxies = _marketProxies();
    for (uint256 i; i < proxies.length; ++i) {
      assertNotEq(IOwnable(_proxyAdmin(proxies[i])).owner(), DEPLOYER, 'proxy admin owner');
    }
  }

  function _assertNotDeployer(address target) internal view {
    assertNotEq(IOwnable(target).owner(), DEPLOYER, 'owner');
    assertNotEq(IOwnable2Step(target).pendingOwner(), DEPLOYER, 'pending owner');
  }

  function _assertMembers(uint64 role, address[] memory expected) internal view {
    assertEq(ACCESS_MANAGER.getRoleMemberCount(role), expected.length, 'member count');
    for (uint256 i; i < expected.length; ++i) {
      (bool isMember, ) = ACCESS_MANAGER.hasRole(role, expected[i]);
      assertTrue(isMember, 'member');
    }
  }

  function _assertSelectors(address target, bytes4[] memory selectors, uint64 role) internal view {
    for (uint256 i; i < selectors.length; ++i) {
      assertEq(ACCESS_MANAGER.getTargetFunctionRole(target, selectors[i]), role, 'selector role');
    }
    assertEq(
      ACCESS_MANAGER.getRoleTargetSelectorCount(role, target),
      selectors.length,
      'role selector count'
    );
  }

  function _isHeldRole(uint64 role) internal pure returns (bool) {
    return
      role == HUB_CONFIGURATOR_ROLE ||
      role == SPOKE_CONFIGURATOR_ROLE ||
      role == HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE ||
      role == SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE ||
      role == SENTORA_RISK_ROLE ||
      role == SENTORA_EMERGENCY_ROLE;
  }

  function _managedTargets() internal pure returns (address[] memory targets) {
    targets = new address[](6);
    targets[0] = address(HUB);
    targets[1] = address(RLUSD_YIELD);
    targets[2] = address(OUSD_YIELD);
    targets[3] = address(BLUECHIP);
    targets[4] = address(HUB_CONFIGURATOR);
    targets[5] = address(SPOKE_CONFIGURATOR);
  }

  function _list(address a) internal pure returns (address[] memory list) {
    list = new address[](1);
    list[0] = a;
  }

  function _list(address a, address b) internal pure returns (address[] memory list) {
    list = new address[](2);
    list[0] = a;
    list[1] = b;
  }

  function _list(address a, address b, address c) internal pure returns (address[] memory list) {
    list = new address[](3);
    list[0] = a;
    list[1] = b;
    list[2] = c;
  }

  function _hubRiskSelectors() internal pure returns (bytes4[] memory s) {
    s = new bytes4[](3);
    s[0] = IHubConfigurator.updateSpokeAddCap.selector;
    s[1] = IHubConfigurator.updateSpokeDrawCap.selector;
    s[2] = IHubConfigurator.updateSpokeCaps.selector;
  }

  function _hubEmergencySelectors() internal pure returns (bytes4[] memory s) {
    s = new bytes4[](4);
    s[0] = IHubConfigurator.haltAsset.selector;
    s[1] = IHubConfigurator.haltSpoke.selector;
    s[2] = IHubConfigurator.resetAssetCaps.selector;
    s[3] = IHubConfigurator.resetSpokeCaps.selector;
  }

  function _hubDomainAdminSelectors() internal pure returns (bytes4[] memory s) {
    s = new bytes4[](15);
    s[0] = IHubConfigurator.addAsset.selector;
    s[1] = IHubConfigurator.addAssetWithDecimals.selector;
    s[2] = IHubConfigurator.updateLiquidityFee.selector;
    s[3] = IHubConfigurator.updateFeeReceiver.selector;
    s[4] = IHubConfigurator.updateFeeConfig.selector;
    s[5] = IHubConfigurator.updateInterestRateStrategy.selector;
    s[6] = IHubConfigurator.updateReinvestmentController.selector;
    s[7] = IHubConfigurator.deactivateAsset.selector;
    s[8] = IHubConfigurator.addSpoke.selector;
    s[9] = IHubConfigurator.addSpokeToAssets.selector;
    s[10] = IHubConfigurator.updateSpokeActive.selector;
    s[11] = IHubConfigurator.updateSpokeHalted.selector;
    s[12] = IHubConfigurator.updateSpokeRiskPremiumThreshold.selector;
    s[13] = IHubConfigurator.deactivateSpoke.selector;
    s[14] = IHubConfigurator.updateInterestRateData.selector;
  }

  function _spokeRiskSelectors() internal pure returns (bytes4[] memory s) {
    s = new bytes4[](6);
    s[0] = ISpokeConfigurator.addCollateralFactor.selector;
    s[1] = ISpokeConfigurator.updateCollateralFactor.selector;
    s[2] = ISpokeConfigurator.addMaxLiquidationBonus.selector;
    s[3] = ISpokeConfigurator.updateMaxLiquidationBonus.selector;
    s[4] = ISpokeConfigurator.addDynamicReserveConfig.selector;
    s[5] = ISpokeConfigurator.updateDynamicReserveConfig.selector;
  }

  function _spokeEmergencySelectors() internal pure returns (bytes4[] memory s) {
    s = new bytes4[](4);
    s[0] = ISpokeConfigurator.pauseReserve.selector;
    s[1] = ISpokeConfigurator.freezeReserve.selector;
    s[2] = ISpokeConfigurator.pauseAllReserves.selector;
    s[3] = ISpokeConfigurator.freezeAllReserves.selector;
  }

  function _spokeDomainAdminSelectors() internal pure returns (bytes4[] memory s) {
    s = new bytes4[](14);
    s[0] = ISpokeConfigurator.updateReservePriceSource.selector;
    s[1] = ISpokeConfigurator.updateLiquidationTargetHealthFactor.selector;
    s[2] = ISpokeConfigurator.updateHealthFactorForMaxBonus.selector;
    s[3] = ISpokeConfigurator.updateLiquidationBonusFactor.selector;
    s[4] = ISpokeConfigurator.updateLiquidationConfig.selector;
    s[5] = ISpokeConfigurator.addReserve.selector;
    s[6] = ISpokeConfigurator.updatePaused.selector;
    s[7] = ISpokeConfigurator.updateFrozen.selector;
    s[8] = ISpokeConfigurator.updateBorrowable.selector;
    s[9] = ISpokeConfigurator.updateReceiveSharesEnabled.selector;
    s[10] = ISpokeConfigurator.updateCollateralRisk.selector;
    s[11] = ISpokeConfigurator.addLiquidationFee.selector;
    s[12] = ISpokeConfigurator.updateLiquidationFee.selector;
    s[13] = ISpokeConfigurator.updatePositionManager.selector;
  }
}
