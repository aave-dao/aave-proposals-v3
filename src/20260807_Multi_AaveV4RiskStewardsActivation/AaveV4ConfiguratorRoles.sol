// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessManagerEnumerable, IHubConfigurator, ISpokeConfigurator} from 'aave-address-book/AaveV4.sol';

/**
 * @title AaveV4ConfiguratorRoles
 * @author Aave Labs
 * @notice Breaks the two configurator domain admin roles down into five granular roles each.
 *         Mirrors the role IDs and selector sets of `aave-v4/deployments/utils/libraries/Roles.sol`;
 *         they are restated here because the version of that library this repo builds against
 *         predates the breakdown.
 * @dev A role never spans both configurators, so Hub and Spoke access is always granted separately.
 */
library AaveV4ConfiguratorRoles {
  uint64 internal constant HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE = 200;
  uint64 internal constant HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE = 201;
  uint64 internal constant HUB_CONFIGURATOR_SPOKE_HALTED_ROLE = 202;
  uint64 internal constant HUB_CONFIGURATOR_LISTING_ROLE = 203;
  uint64 internal constant HUB_CONFIGURATOR_EMERGENCY_ROLE = 204;
  uint64 internal constant HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE = 205;

  uint64 internal constant SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE = 400;
  uint64 internal constant SPOKE_CONFIGURATOR_PAUSE_ROLE = 401;
  uint64 internal constant SPOKE_CONFIGURATOR_FREEZE_ROLE = 402;
  uint64 internal constant SPOKE_CONFIGURATOR_LISTING_ROLE = 403;
  uint64 internal constant SPOKE_CONFIGURATOR_EMERGENCY_ROLE = 404;
  uint64 internal constant SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE = 405;

  /// @notice Labels the ten new roles, moves their selectors off the domain admin roles and carries
  ///         every current domain admin holder over to them.
  /// @dev `setTargetFunctionRole` overwrites the selector mapping, so each reassignment removes the
  ///      selector from the domain admin role. The domain admin roles keep the selectors that are
  ///      never reassigned: the Hub fee and strategy configuration plus the batch cap resets, and
  ///      the Spoke reserve price source and position managers.
  /// @param accessManager The AccessManager governing both configurators.
  /// @param hubConfigurator The HubConfigurator whose selectors are split.
  /// @param spokeConfigurator The SpokeConfigurator whose selectors are split.
  function breakDownDomainAdminRoles(
    IAccessManagerEnumerable accessManager,
    IHubConfigurator hubConfigurator,
    ISpokeConfigurator spokeConfigurator
  ) internal {
    _labelRoles(accessManager);
    _splitHubSelectors(accessManager, address(hubConfigurator));
    _splitSpokeSelectors(accessManager, address(spokeConfigurator));
    _carryOverDomainAdmins(accessManager, HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE, hubRoles());
    _carryOverDomainAdmins(accessManager, SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE, spokeRoles());
  }

  /// @notice Returns the five new HubConfigurator roles.
  function hubRoles() internal pure returns (uint64[] memory) {
    uint64[] memory roles = new uint64[](5);
    roles[0] = HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE;
    roles[1] = HUB_CONFIGURATOR_SPOKE_HALTED_ROLE;
    roles[2] = HUB_CONFIGURATOR_LISTING_ROLE;
    roles[3] = HUB_CONFIGURATOR_EMERGENCY_ROLE;
    roles[4] = HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE;
    return roles;
  }

  /// @notice Returns the five new SpokeConfigurator roles.
  function spokeRoles() internal pure returns (uint64[] memory) {
    uint64[] memory roles = new uint64[](5);
    roles[0] = SPOKE_CONFIGURATOR_PAUSE_ROLE;
    roles[1] = SPOKE_CONFIGURATOR_FREEZE_ROLE;
    roles[2] = SPOKE_CONFIGURATOR_LISTING_ROLE;
    roles[3] = SPOKE_CONFIGURATOR_EMERGENCY_ROLE;
    roles[4] = SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE;
    return roles;
  }

  /// @notice Returns the selectors of the given HubConfigurator role, domain admin included.
  function hubSelectors(uint64 role) internal pure returns (bytes4[] memory) {
    if (role == HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE) {
      bytes4[] memory selectors = new bytes4[](7);
      selectors[0] = IHubConfigurator.updateLiquidityFee.selector;
      selectors[1] = IHubConfigurator.updateFeeReceiver.selector;
      selectors[2] = IHubConfigurator.updateFeeConfig.selector;
      selectors[3] = IHubConfigurator.updateInterestRateStrategy.selector;
      selectors[4] = IHubConfigurator.updateReinvestmentController.selector;
      selectors[5] = IHubConfigurator.resetAssetCaps.selector;
      selectors[6] = IHubConfigurator.resetSpokeCaps.selector;
      return selectors;
    }
    if (role == HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE) {
      bytes4[] memory selectors = new bytes4[](1);
      selectors[0] = IHubConfigurator.updateSpokeActive.selector;
      return selectors;
    }
    if (role == HUB_CONFIGURATOR_SPOKE_HALTED_ROLE) {
      bytes4[] memory selectors = new bytes4[](1);
      selectors[0] = IHubConfigurator.updateSpokeHalted.selector;
      return selectors;
    }
    if (role == HUB_CONFIGURATOR_LISTING_ROLE) {
      bytes4[] memory selectors = new bytes4[](4);
      selectors[0] = IHubConfigurator.addAsset.selector;
      selectors[1] = IHubConfigurator.addAssetWithDecimals.selector;
      selectors[2] = IHubConfigurator.addSpoke.selector;
      selectors[3] = IHubConfigurator.addSpokeToAssets.selector;
      return selectors;
    }
    if (role == HUB_CONFIGURATOR_EMERGENCY_ROLE) {
      bytes4[] memory selectors = new bytes4[](4);
      selectors[0] = IHubConfigurator.deactivateAsset.selector;
      selectors[1] = IHubConfigurator.haltAsset.selector;
      selectors[2] = IHubConfigurator.deactivateSpoke.selector;
      selectors[3] = IHubConfigurator.haltSpoke.selector;
      return selectors;
    }
    bytes4[] memory riskSelectors = new bytes4[](5);
    riskSelectors[0] = IHubConfigurator.updateSpokeAddCap.selector;
    riskSelectors[1] = IHubConfigurator.updateSpokeDrawCap.selector;
    riskSelectors[2] = IHubConfigurator.updateSpokeCaps.selector;
    riskSelectors[3] = IHubConfigurator.updateSpokeRiskPremiumThreshold.selector;
    riskSelectors[4] = IHubConfigurator.updateInterestRateData.selector;
    return riskSelectors;
  }

  /// @notice Returns the selectors of the given SpokeConfigurator role, domain admin included.
  function spokeSelectors(uint64 role) internal pure returns (bytes4[] memory) {
    if (role == SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE) {
      bytes4[] memory selectors = new bytes4[](2);
      selectors[0] = ISpokeConfigurator.updateReservePriceSource.selector;
      selectors[1] = ISpokeConfigurator.updatePositionManager.selector;
      return selectors;
    }
    if (role == SPOKE_CONFIGURATOR_PAUSE_ROLE) {
      bytes4[] memory selectors = new bytes4[](1);
      selectors[0] = ISpokeConfigurator.updatePaused.selector;
      return selectors;
    }
    if (role == SPOKE_CONFIGURATOR_FREEZE_ROLE) {
      bytes4[] memory selectors = new bytes4[](1);
      selectors[0] = ISpokeConfigurator.updateFrozen.selector;
      return selectors;
    }
    if (role == SPOKE_CONFIGURATOR_LISTING_ROLE) {
      bytes4[] memory selectors = new bytes4[](3);
      selectors[0] = ISpokeConfigurator.addReserve.selector;
      selectors[1] = ISpokeConfigurator.updateBorrowable.selector;
      selectors[2] = ISpokeConfigurator.updateReceiveSharesEnabled.selector;
      return selectors;
    }
    if (role == SPOKE_CONFIGURATOR_EMERGENCY_ROLE) {
      bytes4[] memory selectors = new bytes4[](4);
      selectors[0] = ISpokeConfigurator.pauseReserve.selector;
      selectors[1] = ISpokeConfigurator.pauseAllReserves.selector;
      selectors[2] = ISpokeConfigurator.freezeReserve.selector;
      selectors[3] = ISpokeConfigurator.freezeAllReserves.selector;
      return selectors;
    }
    bytes4[] memory riskSelectors = new bytes4[](13);
    riskSelectors[0] = ISpokeConfigurator.updateCollateralRisk.selector;
    riskSelectors[1] = ISpokeConfigurator.addCollateralFactor.selector;
    riskSelectors[2] = ISpokeConfigurator.updateCollateralFactor.selector;
    riskSelectors[3] = ISpokeConfigurator.addMaxLiquidationBonus.selector;
    riskSelectors[4] = ISpokeConfigurator.updateMaxLiquidationBonus.selector;
    riskSelectors[5] = ISpokeConfigurator.addLiquidationFee.selector;
    riskSelectors[6] = ISpokeConfigurator.updateLiquidationFee.selector;
    riskSelectors[7] = ISpokeConfigurator.addDynamicReserveConfig.selector;
    riskSelectors[8] = ISpokeConfigurator.updateDynamicReserveConfig.selector;
    riskSelectors[9] = ISpokeConfigurator.updateLiquidationTargetHealthFactor.selector;
    riskSelectors[10] = ISpokeConfigurator.updateHealthFactorForMaxBonus.selector;
    riskSelectors[11] = ISpokeConfigurator.updateLiquidationBonusFactor.selector;
    riskSelectors[12] = ISpokeConfigurator.updateLiquidationConfig.selector;
    return riskSelectors;
  }

  function _labelRoles(IAccessManagerEnumerable accessManager) private {
    accessManager.labelRole(
      HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE,
      'HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE'
    );
    accessManager.labelRole(
      HUB_CONFIGURATOR_SPOKE_HALTED_ROLE,
      'HUB_CONFIGURATOR_SPOKE_HALTED_ROLE'
    );
    accessManager.labelRole(HUB_CONFIGURATOR_LISTING_ROLE, 'HUB_CONFIGURATOR_LISTING_ROLE');
    accessManager.labelRole(HUB_CONFIGURATOR_EMERGENCY_ROLE, 'HUB_CONFIGURATOR_EMERGENCY_ROLE');
    accessManager.labelRole(
      HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE,
      'HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE'
    );
    accessManager.labelRole(SPOKE_CONFIGURATOR_PAUSE_ROLE, 'SPOKE_CONFIGURATOR_PAUSE_ROLE');
    accessManager.labelRole(SPOKE_CONFIGURATOR_FREEZE_ROLE, 'SPOKE_CONFIGURATOR_FREEZE_ROLE');
    accessManager.labelRole(SPOKE_CONFIGURATOR_LISTING_ROLE, 'SPOKE_CONFIGURATOR_LISTING_ROLE');
    accessManager.labelRole(SPOKE_CONFIGURATOR_EMERGENCY_ROLE, 'SPOKE_CONFIGURATOR_EMERGENCY_ROLE');
    accessManager.labelRole(
      SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE,
      'SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE'
    );
  }

  function _splitHubSelectors(
    IAccessManagerEnumerable accessManager,
    address hubConfigurator
  ) private {
    uint64[] memory roles = hubRoles();
    for (uint256 i; i < roles.length; ++i) {
      accessManager.setTargetFunctionRole(hubConfigurator, hubSelectors(roles[i]), roles[i]);
    }
  }

  function _splitSpokeSelectors(
    IAccessManagerEnumerable accessManager,
    address spokeConfigurator
  ) private {
    uint64[] memory roles = spokeRoles();
    for (uint256 i; i < roles.length; ++i) {
      accessManager.setTargetFunctionRole(spokeConfigurator, spokeSelectors(roles[i]), roles[i]);
    }
  }

  /// @dev Snapshots the domain admin holders before granting, so the loop is not affected by the
  ///      membership writes it performs.
  function _carryOverDomainAdmins(
    IAccessManagerEnumerable accessManager,
    uint64 domainAdminRole,
    uint64[] memory roles
  ) private {
    uint256 holderCount = accessManager.getRoleMemberCount(domainAdminRole);
    address[] memory holders = new address[](holderCount);
    for (uint256 i; i < holderCount; ++i) {
      holders[i] = accessManager.getRoleMember(domainAdminRole, i);
    }

    for (uint256 i; i < holders.length; ++i) {
      for (uint256 j; j < roles.length; ++j) {
        accessManager.grantRole({roleId: roles[j], account: holders[i], executionDelay: 0});
      }
    }
  }
}
