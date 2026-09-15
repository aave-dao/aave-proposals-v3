// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumSpokes, AaveV4EthereumSpokePriceFeeds, AaveV4EthereumAssets} from 'aave-address-book/AaveV4Ethereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine, IHub, ISpoke, ITokenizationSpoke} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {AaveV4ConfiguratorRoles} from './AaveV4ConfiguratorRoles.sol';
import {IPendlePriceCapAdapter} from 'src/interfaces/IPendlePriceCapAdapter.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskSteward} from 'src/interfaces/IRiskSteward.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807} from './AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807_Test is ProtocolV4TestBaseEthereum {
  IHub internal constant CORE_HUB = AaveV4EthereumHubs.CORE_HUB;
  ISpoke internal constant MAIN_SPOKE = AaveV4EthereumSpokes.MAIN_SPOKE;
  address internal constant WETH = AaveV4EthereumAssets.WETH_UNDERLYING;
  // capped wstETH / stETH(ETH) / USD, the price source of wstETH on the main spoke
  IPriceCapAdapter internal constant wstETH_CAPO_ADAPTER =
    IPriceCapAdapter(0xe1D97bF61901B075E9626c8A2340a7De385861Ef);
  IPriceCapAdapterStable internal constant USDC_CAPO_ADAPTER =
    IPriceCapAdapterStable(AaveV4EthereumSpokePriceFeeds.MAIN_SPOKE_USDC_PRICE_FEED);
  // the only Pendle price source not yet past maturity at the fork block; a matured adapter
  // reverts on any `setDiscountRatePerYear` call
  IPendlePriceCapAdapter internal constant PT_USDG_PENDLE_ADAPTER =
    IPendlePriceCapAdapter(
      AaveV4EthereumSpokePriceFeeds.USDG_PENDLE_SPOKE_PT_USDG_24SEP2026_PRICE_FEED
    );

  AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807 internal proposal;
  IRiskStewardV4 internal steward;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25701834);
    proposal = new AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807();
    steward = IRiskStewardV4(proposal.RISK_STEWARD());
  }

  modifier activated() {
    GovV3Helpers.executePayload(vm, address(proposal));
    _;
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807', address(proposal));
  }

  function test_stewardOwnerAndCouncil() public view {
    assertEq(steward.owner(), GovernanceV3Ethereum.EXECUTOR_LVL_1, 'owner mismatch');
    assertEq(
      steward.RISK_COUNCIL(),
      IRiskSteward(AaveV3Ethereum.RISK_STEWARD).RISK_COUNCIL(),
      'council diverges from the v3 risk steward'
    );
  }

  function test_rolesGranted() public activated {
    uint64[] memory granted = new uint64[](4);
    granted[0] = AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE;
    granted[1] = AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_EMERGENCY_ROLE;
    granted[2] = AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE;
    granted[3] = AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_EMERGENCY_ROLE;

    for (uint256 i; i < granted.length; ++i) {
      (bool hasRole, uint32 delay) = AaveV4Ethereum.ACCESS_MANAGER.hasRole(
        granted[i],
        proposal.RISK_STEWARD()
      );
      assertTrue(hasRole, string.concat('role not granted: ', vm.toString(granted[i])));
      assertEq(uint256(delay), 0, string.concat('role delay: ', vm.toString(granted[i])));
    }

    assertTrue(
      AaveV3Ethereum.ACL_MANAGER.isRiskAdmin(proposal.RISK_STEWARD()),
      'risk admin role not granted'
    );
  }

  /// @dev The steward is deliberately not given the flag, listing or domain admin roles.
  function test_stewardNotGrantedRemainingRoles() public activated {
    uint64[] memory withheld = new uint64[](8);
    withheld[0] = AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
    withheld[1] = AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE;
    withheld[2] = AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_SPOKE_HALTED_ROLE;
    withheld[3] = AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_LISTING_ROLE;
    withheld[4] = AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
    withheld[5] = AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_PAUSE_ROLE;
    withheld[6] = AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_FREEZE_ROLE;
    withheld[7] = AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_LISTING_ROLE;

    for (uint256 i; i < withheld.length; ++i) {
      (bool hasRole, ) = AaveV4Ethereum.ACCESS_MANAGER.hasRole(
        withheld[i],
        proposal.RISK_STEWARD()
      );
      assertFalse(hasRole, string.concat('role should be withheld: ', vm.toString(withheld[i])));
    }
  }

  /// @dev Every selector of each new role must resolve to that role on its own configurator, and
  /// the domain admin roles must be left holding only the residual selectors.
  function test_configuratorSelectorsSplitAcrossRoles() public activated {
    _assertHubRoleSelectors(AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE);
    uint64[] memory hubRoles = AaveV4ConfiguratorRoles.hubRoles();
    for (uint256 i; i < hubRoles.length; ++i) {
      _assertHubRoleSelectors(hubRoles[i]);
    }

    _assertSpokeRoleSelectors(AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE);
    uint64[] memory spokeRoles = AaveV4ConfiguratorRoles.spokeRoles();
    for (uint256 i; i < spokeRoles.length; ++i) {
      _assertSpokeRoleSelectors(spokeRoles[i]);
    }
  }

  /// @dev The split above only proves each listed selector landed on its role. This proves the six
  /// sets are exhaustive: a configurator function missing from the library would silently keep the
  /// domain admin role instead of the granular one it belongs to.
  function test_configuratorRolesCoverEverySelector() public activated {
    bytes4[] memory hubSelectors = _interfaceSelectors('IHubConfigurator');
    for (uint256 i; i < hubSelectors.length; ++i) {
      uint64 role = AaveV4Ethereum.ACCESS_MANAGER.getTargetFunctionRole(
        address(AaveV4Ethereum.HUB_CONFIGURATOR),
        hubSelectors[i]
      );
      assertTrue(
        _contains(AaveV4ConfiguratorRoles.hubSelectors(role), hubSelectors[i]),
        string.concat('hub selector missing from the breakdown: ', vm.toString(hubSelectors[i]))
      );
    }

    bytes4[] memory spokeSelectors = _interfaceSelectors('ISpokeConfigurator');
    for (uint256 i; i < spokeSelectors.length; ++i) {
      uint64 role = AaveV4Ethereum.ACCESS_MANAGER.getTargetFunctionRole(
        address(AaveV4Ethereum.SPOKE_CONFIGURATOR),
        spokeSelectors[i]
      );
      assertTrue(
        _contains(AaveV4ConfiguratorRoles.spokeSelectors(role), spokeSelectors[i]),
        string.concat('spoke selector missing from the breakdown: ', vm.toString(spokeSelectors[i]))
      );
    }
  }

  /// @dev Each address that held a domain admin role keeps the same reach through the new roles.
  function test_domainAdminsCarriedOverToNewRoles() public {
    address[] memory hubAdmins = _roleMembers(
      AaveV4ConfiguratorRoles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE
    );
    address[] memory spokeAdmins = _roleMembers(
      AaveV4ConfiguratorRoles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE
    );
    assertGt(hubAdmins.length, 0, 'no hub domain admin to carry over');
    assertGt(spokeAdmins.length, 0, 'no spoke domain admin to carry over');

    GovV3Helpers.executePayload(vm, address(proposal));

    _assertHoldsAll(hubAdmins, AaveV4ConfiguratorRoles.hubRoles());
    _assertHoldsAll(spokeAdmins, AaveV4ConfiguratorRoles.spokeRoles());
  }

  function test_newRolesLabeled() public activated {
    string[10] memory labels = [
      'HUB_CONFIGURATOR_SPOKE_ACTIVE_ROLE',
      'HUB_CONFIGURATOR_SPOKE_HALTED_ROLE',
      'HUB_CONFIGURATOR_LISTING_ROLE',
      'HUB_CONFIGURATOR_EMERGENCY_ROLE',
      'HUB_CONFIGURATOR_RISK_MANAGEMENT_ROLE',
      'SPOKE_CONFIGURATOR_PAUSE_ROLE',
      'SPOKE_CONFIGURATOR_FREEZE_ROLE',
      'SPOKE_CONFIGURATOR_LISTING_ROLE',
      'SPOKE_CONFIGURATOR_EMERGENCY_ROLE',
      'SPOKE_CONFIGURATOR_RISK_MANAGEMENT_ROLE'
    ];
    uint64[] memory roles = new uint64[](10);
    uint64[] memory hubRoles = AaveV4ConfiguratorRoles.hubRoles();
    uint64[] memory spokeRoles = AaveV4ConfiguratorRoles.spokeRoles();
    for (uint256 i; i < 5; ++i) {
      roles[i] = hubRoles[i];
      roles[i + 5] = spokeRoles[i];
    }

    for (uint256 i; i < roles.length; ++i) {
      assertEq(
        AaveV4Ethereum.ACCESS_MANAGER.getLabelOfRole(roles[i]),
        labels[i],
        string.concat('label mismatch: ', vm.toString(roles[i]))
      );
      assertEq(
        uint256(AaveV4Ethereum.ACCESS_MANAGER.getRoleOfLabel(labels[i])),
        uint256(roles[i]),
        string.concat('reverse label mismatch: ', labels[i])
      );
    }
  }

  function _assertHubRoleSelectors(uint64 role) internal view {
    bytes4[] memory selectors = AaveV4ConfiguratorRoles.hubSelectors(role);
    for (uint256 i; i < selectors.length; ++i) {
      assertEq(
        uint256(
          AaveV4Ethereum.ACCESS_MANAGER.getTargetFunctionRole(
            address(AaveV4Ethereum.HUB_CONFIGURATOR),
            selectors[i]
          )
        ),
        uint256(role),
        string.concat('hub selector role mismatch: ', vm.toString(role))
      );
    }
  }

  function _assertSpokeRoleSelectors(uint64 role) internal view {
    bytes4[] memory selectors = AaveV4ConfiguratorRoles.spokeSelectors(role);
    for (uint256 i; i < selectors.length; ++i) {
      assertEq(
        uint256(
          AaveV4Ethereum.ACCESS_MANAGER.getTargetFunctionRole(
            address(AaveV4Ethereum.SPOKE_CONFIGURATOR),
            selectors[i]
          )
        ),
        uint256(role),
        string.concat('spoke selector role mismatch: ', vm.toString(role))
      );
    }
  }

  /// @dev Reads the compiled ABI so the expected set comes from the interface, not from the library
  /// under test.
  function _interfaceSelectors(string memory name) internal view returns (bytes4[] memory) {
    string memory path = string.concat('out/prague/', name, '.sol/', name, '.json');
    if (!vm.isFile(path)) path = string.concat('out/shanghai/', name, '.sol/', name, '.json');
    string[] memory signatures = vm.parseJsonKeys(vm.readFile(path), '.methodIdentifiers');
    assertGt(signatures.length, 0, string.concat('no methods found for ', name));

    bytes4[] memory selectors = new bytes4[](signatures.length);
    for (uint256 i; i < signatures.length; ++i) {
      selectors[i] = bytes4(keccak256(bytes(signatures[i])));
    }
    return selectors;
  }

  function _contains(bytes4[] memory selectors, bytes4 selector) internal pure returns (bool) {
    for (uint256 i; i < selectors.length; ++i) {
      if (selectors[i] == selector) return true;
    }
    return false;
  }

  function _roleMembers(uint64 role) internal view returns (address[] memory) {
    uint256 count = AaveV4Ethereum.ACCESS_MANAGER.getRoleMemberCount(role);
    address[] memory members = new address[](count);
    for (uint256 i; i < count; ++i) {
      members[i] = AaveV4Ethereum.ACCESS_MANAGER.getRoleMember(role, i);
    }
    return members;
  }

  function _assertHoldsAll(address[] memory accounts, uint64[] memory roles) internal view {
    for (uint256 i; i < accounts.length; ++i) {
      for (uint256 j; j < roles.length; ++j) {
        (bool hasRole, ) = AaveV4Ethereum.ACCESS_MANAGER.hasRole(roles[j], accounts[i]);
        assertTrue(
          hasRole,
          string.concat(vm.toString(accounts[i]), ' missing role ', vm.toString(roles[j]))
        );
      }
    }
  }

  function test_riskCouncilCanUpdateLstPriceCap() public activated {
    uint16 growthBefore = uint16(wstETH_CAPO_ADAPTER.getMaxYearlyGrowthRatePercent());
    uint16 growthAfter = growthBefore + growthBefore / 20;
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(growthAfter);
    address riskCouncil = steward.RISK_COUNCIL();

    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);

    assertEq(
      wstETH_CAPO_ADAPTER.getMaxYearlyGrowthRatePercent(),
      growthAfter,
      'maxYearlyGrowthRatePercent not updated'
    );
  }

  function test_riskCouncilCannotUpdateLstPriceCapAboveBound() public activated {
    uint16 growthBefore = uint16(wstETH_CAPO_ADAPTER.getMaxYearlyGrowthRatePercent());
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = _lstPriceCapUpdate(
      growthBefore + growthBefore / 20 + 1
    );
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateLstPriceCaps(updates);
  }

  function _lstPriceCapUpdate(
    uint16 maxYearlyRatioGrowthPercent
  ) internal view returns (IRiskStewardV4.PriceCapLstUpdate[] memory) {
    IRiskStewardV4.PriceCapLstUpdate[] memory updates = new IRiskStewardV4.PriceCapLstUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapLstUpdate({
      oracle: address(wstETH_CAPO_ADAPTER),
      priceCapUpdateParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: uint104(uint256(wstETH_CAPO_ADAPTER.getRatio())),
        snapshotTimestamp: uint48(block.timestamp - wstETH_CAPO_ADAPTER.MINIMUM_SNAPSHOT_DELAY()),
        maxYearlyRatioGrowthPercent: maxYearlyRatioGrowthPercent
      })
    });
    return updates;
  }

  function test_riskStewardConfig() public activated {
    _assertConfig(steward.getConfig());
  }

  /// @dev Covers the bounds LlamaRisk carried over from the v3 Risk Steward unchanged. The params
  /// they widened (baseDrawnRate, rateGrowthBeforeOptimal, collateralRisk, the dynamicAdd bounds)
  /// and those with no v3 counterpart are asserted in `_assertConfig` only.
  function test_boundsMatchV3RiskSteward() public activated {
    IRiskSteward.Config memory v3 = IRiskSteward(AaveV3Ethereum.RISK_STEWARD).getRiskConfig();
    IRiskStewardV4.Config memory v4 = steward.getConfig();

    assertEq(
      uint256(v4.hub.rate.optimalUsageRatio.maxPercentChange),
      v3.rateConfig.optimalUsageRatio.maxPercentChange,
      'optimalUsageRatio bound'
    );
    assertEq(
      uint256(v4.hub.rate.rateGrowthAfterOptimal.maxPercentChange),
      v3.rateConfig.variableRateSlope2.maxPercentChange,
      'rateGrowthAfterOptimal bound'
    );
    assertEq(
      uint256(v4.hub.cap.addCap.maxPercentChange),
      v3.capConfig.supplyCap.maxPercentChange,
      'addCap bound'
    );
    assertEq(
      uint256(v4.hub.cap.drawCap.maxPercentChange),
      v3.capConfig.borrowCap.maxPercentChange,
      'drawCap bound'
    );
    assertEq(
      uint256(v4.spoke.dynamicUpdate.collateralFactor.maxPercentChange),
      v3.collateralConfig.ltv.maxPercentChange,
      'collateralFactor bound'
    );
    assertEq(
      uint256(v4.spoke.dynamicUpdate.maxLiquidationBonus.maxPercentChange),
      v3.collateralConfig.liquidationBonus.maxPercentChange,
      'maxLiquidationBonus bound'
    );
    assertEq(
      uint256(v4.oracle.priceCapLst.maxPercentChange),
      v3.priceCapConfig.priceCapLst.maxPercentChange,
      'priceCapLst bound'
    );
    assertEq(
      uint256(v4.oracle.priceCapStable.maxPercentChange),
      v3.priceCapConfig.priceCapStable.maxPercentChange,
      'priceCapStable bound'
    );
    assertEq(
      uint256(v4.oracle.discountRatePendle.maxPercentChange),
      v3.priceCapConfig.discountRatePendle.maxPercentChange,
      'discountRatePendle bound'
    );
    assertEq(
      uint256(v4.oracle.discountRatePendle.minDelay),
      uint256(v3.priceCapConfig.discountRatePendle.minDelay),
      'discountRatePendle cooldown'
    );
  }

  function test_riskCouncilCanUpdateHubAssetIRs() public activated {
    IAssetInterestRateStrategy.InterestRateData memory expected = _currentIrData();
    expected.optimalUsageRatio += 3_00;
    expected.baseDrawnRate += 3_00;
    expected.rateGrowthBeforeOptimal += 3_00;
    expected.rateGrowthAfterOptimal += 20_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateHubAssetIRs(_irUpdate(expected));

    IAssetInterestRateStrategy.InterestRateData memory current = _currentIrData();
    assertEq(
      current.optimalUsageRatio,
      expected.optimalUsageRatio,
      'optimalUsageRatio not updated'
    );
    assertEq(current.baseDrawnRate, expected.baseDrawnRate, 'baseDrawnRate not updated');
    assertEq(
      current.rateGrowthBeforeOptimal,
      expected.rateGrowthBeforeOptimal,
      'rateGrowthBeforeOptimal not updated'
    );
    assertEq(
      current.rateGrowthAfterOptimal,
      expected.rateGrowthAfterOptimal,
      'rateGrowthAfterOptimal not updated'
    );
  }

  function test_riskCouncilCannotUpdateHubAssetIRsAboveBound() public activated {
    IAssetInterestRateStrategy.InterestRateData memory outOfRange = _currentIrData();
    outOfRange.optimalUsageRatio += 3_00 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateHubAssetIRs(_irUpdate(outOfRange));
  }

  function test_riskCouncilCanUpdateHubSpokeCaps() public activated {
    uint256 assetId = CORE_HUB.getAssetId(WETH);
    IHub.SpokeConfig memory before = CORE_HUB.getSpokeConfig(assetId, address(MAIN_SPOKE));
    uint256 addCap = 2 * uint256(before.addCap);
    uint256 drawCap = 2 * uint256(before.drawCap);

    vm.prank(steward.RISK_COUNCIL());
    steward.updateHubSpokeCaps(_capsUpdate(addCap, drawCap));

    IHub.SpokeConfig memory current = CORE_HUB.getSpokeConfig(assetId, address(MAIN_SPOKE));
    assertEq(uint256(current.addCap), addCap, 'addCap not updated');
    assertEq(uint256(current.drawCap), drawCap, 'drawCap not updated');
  }

  function test_riskCouncilCannotUpdateHubSpokeCapsAboveBound() public activated {
    uint256 assetId = CORE_HUB.getAssetId(WETH);
    uint256 addCapBefore = CORE_HUB.getSpokeConfig(assetId, address(MAIN_SPOKE)).addCap;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateHubSpokeCaps(_capsUpdate(2 * addCapBefore + 1, EngineFlags.KEEP_CURRENT));
  }

  function test_riskCouncilCanUpdateReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint256 collateralRisk = uint256(MAIN_SPOKE.getReserveConfig(reserveId).collateralRisk) +
      300_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateReserveConfigs(_reserveConfigUpdate(collateralRisk));

    assertEq(
      uint256(MAIN_SPOKE.getReserveConfig(reserveId).collateralRisk),
      collateralRisk,
      'collateralRisk not updated'
    );
  }

  function test_riskCouncilCannotUpdateReserveConfigsAboveBound() public activated {
    uint256 collateralRisk = uint256(MAIN_SPOKE.getReserveConfig(_reserveId()).collateralRisk) +
      300_00 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateReserveConfigs(_reserveConfigUpdate(collateralRisk));
  }

  function test_riskCouncilCanUpdateDynamicReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = MAIN_SPOKE.getReserve(reserveId).dynamicConfigKey;
    ISpoke.DynamicReserveConfig memory before = MAIN_SPOKE.getDynamicReserveConfig(reserveId, key);
    uint256 collateralFactor = uint256(before.collateralFactor) + 50;
    uint256 maxLiquidationBonus = uint256(before.maxLiquidationBonus) + 50;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateDynamicReserveConfigs(
      _dynamicReserveConfigUpdate(key, collateralFactor, maxLiquidationBonus)
    );

    ISpoke.DynamicReserveConfig memory current = MAIN_SPOKE.getDynamicReserveConfig(reserveId, key);
    assertEq(uint256(current.collateralFactor), collateralFactor, 'collateralFactor not updated');
    assertEq(
      uint256(current.maxLiquidationBonus),
      maxLiquidationBonus,
      'maxLiquidationBonus not updated'
    );
  }

  function test_riskCouncilCannotUpdateDynamicReserveConfigsAboveBound() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = MAIN_SPOKE.getReserve(reserveId).dynamicConfigKey;
    uint256 collateralFactor = uint256(
      MAIN_SPOKE.getDynamicReserveConfig(reserveId, key).collateralFactor
    ) +
      50 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateDynamicReserveConfigs(
      _dynamicReserveConfigUpdate(key, collateralFactor, EngineFlags.KEEP_CURRENT)
    );
  }

  function test_riskCouncilCanAddDynamicReserveConfigs() public activated {
    uint256 reserveId = _reserveId();
    uint32 keyBefore = MAIN_SPOKE.getReserve(reserveId).dynamicConfigKey;
    ISpoke.DynamicReserveConfig memory added = MAIN_SPOKE.getDynamicReserveConfig(
      reserveId,
      keyBefore
    );
    added.collateralFactor += 5_00;
    added.maxLiquidationBonus += 50;

    vm.prank(steward.RISK_COUNCIL());
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(added));

    uint32 keyAfter = MAIN_SPOKE.getReserve(reserveId).dynamicConfigKey;
    assertEq(uint256(keyAfter), uint256(keyBefore) + 1, 'dynamic config key not bumped');

    ISpoke.DynamicReserveConfig memory current = MAIN_SPOKE.getDynamicReserveConfig(
      reserveId,
      keyAfter
    );
    assertEq(
      uint256(current.collateralFactor),
      uint256(added.collateralFactor),
      'collateralFactor not added'
    );
    assertEq(
      uint256(current.maxLiquidationBonus),
      uint256(added.maxLiquidationBonus),
      'maxLiquidationBonus not added'
    );
  }

  function test_riskCouncilCannotAddDynamicReserveConfigsAboveBound() public activated {
    uint256 reserveId = _reserveId();
    uint32 key = MAIN_SPOKE.getReserve(reserveId).dynamicConfigKey;
    address riskCouncil = steward.RISK_COUNCIL();

    ISpoke.DynamicReserveConfig memory outOfRange = MAIN_SPOKE.getDynamicReserveConfig(
      reserveId,
      key
    );
    outOfRange.collateralFactor += 5_00 + 1;

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(outOfRange));

    outOfRange = MAIN_SPOKE.getDynamicReserveConfig(reserveId, key);
    outOfRange.maxLiquidationBonus += 50 + 1;

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.addDynamicReserveConfigs(_dynamicReserveConfigAddition(outOfRange));
  }

  function test_riskCouncilCanUpdateSpokeLiquidationConfigs() public activated {
    ISpoke.LiquidationConfig memory before = MAIN_SPOKE.getLiquidationConfig();
    uint256 targetHealthFactor = uint256(before.targetHealthFactor) +
      (uint256(before.targetHealthFactor) * 5_00) /
      100_00;
    uint256 healthFactorForMaxBonus = uint256(before.healthFactorForMaxBonus) +
      (uint256(before.healthFactorForMaxBonus) * 5_00) /
      100_00;
    uint256 liquidationBonusFactor = uint256(before.liquidationBonusFactor) + 5_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateSpokeLiquidationConfigs(
      _liquidationConfigUpdate(targetHealthFactor, healthFactorForMaxBonus, liquidationBonusFactor)
    );

    ISpoke.LiquidationConfig memory current = MAIN_SPOKE.getLiquidationConfig();
    assertEq(
      uint256(current.targetHealthFactor),
      targetHealthFactor,
      'targetHealthFactor not updated'
    );
    assertEq(
      uint256(current.healthFactorForMaxBonus),
      healthFactorForMaxBonus,
      'healthFactorForMaxBonus not updated'
    );
    assertEq(
      uint256(current.liquidationBonusFactor),
      liquidationBonusFactor,
      'liquidationBonusFactor not updated'
    );
  }

  function test_riskCouncilCannotUpdateSpokeLiquidationConfigsAboveBound() public activated {
    uint256 targetHealthFactorBefore = MAIN_SPOKE.getLiquidationConfig().targetHealthFactor;
    uint256 targetHealthFactor = targetHealthFactorBefore +
      (targetHealthFactorBefore * 5_00) /
      100_00 +
      1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateSpokeLiquidationConfigs(
      _liquidationConfigUpdate(
        targetHealthFactor,
        EngineFlags.KEEP_CURRENT,
        EngineFlags.KEEP_CURRENT
      )
    );
  }

  function test_riskCouncilCanUpdateStablePriceCap() public activated {
    uint256 priceCapBefore = uint256(USDC_CAPO_ADAPTER.getPriceCap());
    uint256 priceCap = priceCapBefore + (priceCapBefore * 50) / 100_00;

    vm.prank(steward.RISK_COUNCIL());
    steward.updateStablePriceCaps(_stablePriceCapUpdate(priceCap));

    assertEq(uint256(USDC_CAPO_ADAPTER.getPriceCap()), priceCap, 'priceCap not updated');
  }

  function test_riskCouncilCannotUpdateStablePriceCapAboveBound() public activated {
    uint256 priceCapBefore = uint256(USDC_CAPO_ADAPTER.getPriceCap());
    uint256 priceCap = priceCapBefore + (priceCapBefore * 50) / 100_00 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updateStablePriceCaps(_stablePriceCapUpdate(priceCap));
  }

  function test_riskCouncilCanUpdatePendleDiscountRate() public activated {
    uint256 discountRate = PT_USDG_PENDLE_ADAPTER.discountRatePerYear() + 0.025e18;

    vm.prank(steward.RISK_COUNCIL());
    steward.updatePendleDiscountRates(_pendleDiscountRateUpdate(discountRate));

    assertEq(
      uint256(PT_USDG_PENDLE_ADAPTER.discountRatePerYear()),
      discountRate,
      'discountRate not updated'
    );
  }

  function test_riskCouncilCannotUpdatePendleDiscountRateAboveBound() public activated {
    uint256 discountRate = PT_USDG_PENDLE_ADAPTER.discountRatePerYear() + 0.025e18 + 1;
    address riskCouncil = steward.RISK_COUNCIL();

    vm.expectRevert(IRiskStewardV4.UpdateNotInRange.selector);
    vm.prank(riskCouncil);
    steward.updatePendleDiscountRates(_pendleDiscountRateUpdate(discountRate));
  }

  function _getTokenizationSpokes() internal view override returns (ITokenizationSpoke[] memory) {
    ITokenizationSpoke[] memory all = super._getTokenizationSpokes();
    uint256 activeCount;
    for (uint256 i; i < all.length; ++i) {
      if (_isTokenizationSpokeActive(all[i])) ++activeCount;
    }
    ITokenizationSpoke[] memory active = new ITokenizationSpoke[](activeCount);
    uint256 index;
    for (uint256 i; i < all.length; ++i) {
      if (_isTokenizationSpokeActive(all[i])) active[index++] = all[i];
    }
    return active;
  }

  function _isTokenizationSpokeActive(
    ITokenizationSpoke tokenizationSpoke
  ) internal view returns (bool) {
    return
      IHub(tokenizationSpoke.hub())
        .getSpokeConfig(tokenizationSpoke.assetId(), address(tokenizationSpoke))
        .active;
  }

  function _reserveId() internal view returns (uint256) {
    return MAIN_SPOKE.getReserveId(address(CORE_HUB), CORE_HUB.getAssetId(WETH));
  }

  function _currentIrData()
    internal
    view
    returns (IAssetInterestRateStrategy.InterestRateData memory)
  {
    uint256 assetId = CORE_HUB.getAssetId(WETH);
    return
      IAssetInterestRateStrategy(CORE_HUB.getAssetConfig(assetId).irStrategy).getInterestRateData(
        assetId
      );
  }

  function _irUpdate(
    IAssetInterestRateStrategy.InterestRateData memory irData
  ) internal pure returns (IConfigEngine.AssetConfigUpdate[] memory) {
    IConfigEngine.AssetConfigUpdate[] memory updates = new IConfigEngine.AssetConfigUpdate[](1);
    updates[0] = IConfigEngine.AssetConfigUpdate({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(CORE_HUB),
      underlying: WETH,
      liquidityFee: EngineFlags.KEEP_CURRENT,
      feeReceiver: EngineFlags.KEEP_CURRENT_ADDRESS,
      irStrategy: EngineFlags.KEEP_CURRENT_ADDRESS,
      irData: irData,
      reinvestmentController: EngineFlags.KEEP_CURRENT_ADDRESS
    });
    return updates;
  }

  function _capsUpdate(
    uint256 addCap,
    uint256 drawCap
  ) internal pure returns (IConfigEngine.SpokeConfigUpdate[] memory) {
    IConfigEngine.SpokeConfigUpdate[] memory updates = new IConfigEngine.SpokeConfigUpdate[](1);
    updates[0] = IConfigEngine.SpokeConfigUpdate({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(CORE_HUB),
      underlying: WETH,
      spoke: address(MAIN_SPOKE),
      addCap: addCap,
      drawCap: drawCap,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _reserveConfigUpdate(
    uint256 collateralRisk
  ) internal pure returns (IConfigEngine.ReserveConfigUpdate[] memory) {
    IConfigEngine.ReserveConfigUpdate[] memory updates = new IConfigEngine.ReserveConfigUpdate[](1);
    updates[0] = IConfigEngine.ReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(MAIN_SPOKE),
      hub: address(CORE_HUB),
      underlying: WETH,
      priceSource: EngineFlags.KEEP_CURRENT_ADDRESS,
      collateralRisk: collateralRisk,
      paused: EngineFlags.KEEP_CURRENT,
      frozen: EngineFlags.KEEP_CURRENT,
      borrowable: EngineFlags.KEEP_CURRENT,
      receiveSharesEnabled: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _dynamicReserveConfigUpdate(
    uint32 dynamicConfigKey,
    uint256 collateralFactor,
    uint256 maxLiquidationBonus
  ) internal pure returns (IConfigEngine.DynamicReserveConfigUpdate[] memory) {
    IConfigEngine.DynamicReserveConfigUpdate[]
      memory updates = new IConfigEngine.DynamicReserveConfigUpdate[](1);
    updates[0] = IConfigEngine.DynamicReserveConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(MAIN_SPOKE),
      hub: address(CORE_HUB),
      underlying: WETH,
      dynamicConfigKey: dynamicConfigKey,
      collateralFactor: collateralFactor,
      maxLiquidationBonus: maxLiquidationBonus,
      liquidationFee: EngineFlags.KEEP_CURRENT
    });
    return updates;
  }

  function _dynamicReserveConfigAddition(
    ISpoke.DynamicReserveConfig memory dynamicConfig
  ) internal pure returns (IConfigEngine.DynamicReserveConfigAddition[] memory) {
    IConfigEngine.DynamicReserveConfigAddition[]
      memory additions = new IConfigEngine.DynamicReserveConfigAddition[](1);
    additions[0] = IConfigEngine.DynamicReserveConfigAddition({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(MAIN_SPOKE),
      hub: address(CORE_HUB),
      underlying: WETH,
      dynamicConfig: dynamicConfig
    });
    return additions;
  }

  function _liquidationConfigUpdate(
    uint256 targetHealthFactor,
    uint256 healthFactorForMaxBonus,
    uint256 liquidationBonusFactor
  ) internal pure returns (IConfigEngine.LiquidationConfigUpdate[] memory) {
    IConfigEngine.LiquidationConfigUpdate[]
      memory updates = new IConfigEngine.LiquidationConfigUpdate[](1);
    updates[0] = IConfigEngine.LiquidationConfigUpdate({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(MAIN_SPOKE),
      targetHealthFactor: targetHealthFactor,
      healthFactorForMaxBonus: healthFactorForMaxBonus,
      liquidationBonusFactor: liquidationBonusFactor
    });
    return updates;
  }

  function _stablePriceCapUpdate(
    uint256 priceCap
  ) internal pure returns (IRiskStewardV4.PriceCapStableUpdate[] memory) {
    IRiskStewardV4.PriceCapStableUpdate[]
      memory updates = new IRiskStewardV4.PriceCapStableUpdate[](1);
    updates[0] = IRiskStewardV4.PriceCapStableUpdate({
      oracle: address(USDC_CAPO_ADAPTER),
      priceCap: priceCap
    });
    return updates;
  }

  function _pendleDiscountRateUpdate(
    uint256 discountRate
  ) internal pure returns (IRiskStewardV4.DiscountRatePendleUpdate[] memory) {
    IRiskStewardV4.DiscountRatePendleUpdate[]
      memory updates = new IRiskStewardV4.DiscountRatePendleUpdate[](1);
    updates[0] = IRiskStewardV4.DiscountRatePendleUpdate({
      oracle: address(PT_USDG_PENDLE_ADAPTER),
      discountRate: discountRate
    });
    return updates;
  }

  function _assertConfig(IRiskStewardV4.Config memory config) internal pure {
    assertEq(
      address(config.hub.configurator),
      address(AaveV4Ethereum.HUB_CONFIGURATOR),
      'hub configurator mismatch'
    );
    assertEq(
      address(config.spoke.configurator),
      address(AaveV4Ethereum.SPOKE_CONFIGURATOR),
      'spoke configurator mismatch'
    );

    // prettier-ignore
    {
      //           param                                           minDelay  maxChange   relative  label
      _assertParam(config.hub.rate.optimalUsageRatio,               36 hours, 3_00,       false,    'optimalUsageRatio');
      _assertParam(config.hub.rate.baseDrawnRate,                   36 hours, 3_00,       false,    'baseDrawnRate');
      _assertParam(config.hub.rate.rateGrowthBeforeOptimal,         36 hours, 3_00,       false,    'rateGrowthBeforeOptimal');
      _assertParam(config.hub.rate.rateGrowthAfterOptimal,          36 hours, 20_00,      false,    'rateGrowthAfterOptimal');
      _assertParam(config.hub.cap.addCap,                           36 hours, 100_00,     true,     'addCap');
      _assertParam(config.hub.cap.drawCap,                          36 hours, 100_00,     true,     'drawCap');
      _assertParam(config.spoke.collateralRisk,                     36 hours, 300_00,     false,    'collateralRisk');
      _assertParam(config.spoke.dynamicUpdate.collateralFactor,     72 hours, 50,         false,    'dynamicUpdate collateralFactor');
      _assertParam(config.spoke.dynamicUpdate.maxLiquidationBonus,  72 hours, 50,         false,    'dynamicUpdate maxLiquidationBonus');
      _assertParam(config.spoke.dynamicAdd.collateralFactor,        72 hours, 5_00,       false,    'dynamicAdd collateralFactor');
      _assertParam(config.spoke.dynamicAdd.maxLiquidationBonus,     72 hours, 50,         false,    'dynamicAdd maxLiquidationBonus');
      _assertParam(config.spoke.liquidation.targetHealthFactor,     72 hours, 5_00,       true,     'targetHealthFactor');
      _assertParam(config.spoke.liquidation.healthFactorForMaxBonus,72 hours, 5_00,       true,     'healthFactorForMaxBonus');
      _assertParam(config.spoke.liquidation.liquidationBonusFactor, 72 hours, 5_00,       false,    'liquidationBonusFactor');
      _assertParam(config.oracle.priceCapLst,                       72 hours, 5_00,       true,     'priceCapLst');
      _assertParam(config.oracle.priceCapStable,                    72 hours, 50,         true,     'priceCapStable');
      _assertParam(config.oracle.discountRatePendle,                48 hours, 0.025e18,   false,    'discountRatePendle');
    }
  }

  function _assertParam(
    IRiskStewardV4.RiskParamConfig memory param,
    uint256 minDelay,
    uint256 maxPercentChange,
    bool isChangeRelative,
    string memory label
  ) internal pure {
    assertEq(uint256(param.minDelay), minDelay, string.concat(label, ' minDelay'));
    assertEq(
      uint256(param.maxPercentChange),
      maxPercentChange,
      string.concat(label, ' maxPercentChange')
    );
    assertEq(param.isChangeRelative, isChangeRelative, string.concat(label, ' isChangeRelative'));
  }
}
