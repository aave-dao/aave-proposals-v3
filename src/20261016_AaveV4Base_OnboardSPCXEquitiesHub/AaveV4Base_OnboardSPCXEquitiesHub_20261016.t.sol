// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ProtocolV4TestBaseBase} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseBase.sol';
import {GovV3Helpers, IPayloadsControllerCore} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4BaseHubs, AaveV4BaseSpokes, AaveV4BaseAssets, AaveV4Base, AaveV4BaseIRStrategies} from 'aave-address-book/AaveV4Base.sol';
import {IAaveV4ConfigEngine as IConfigEngine, IHub, ISpoke, ISpokeConfigurator} from 'aave-address-book/AaveV4.sol';
import {Errors} from 'aave-address-book/governance-v3/Errors.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';
import {Types} from 'aave-helpers/src/dependencies/v4/Types.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {AaveV4Base_OnboardSPCXEquitiesHub_20261016} from './AaveV4Base_OnboardSPCXEquitiesHub_20261016.sol';

interface IListingPriceFeed {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

/**
 * @dev Test for AaveV4Base_OnboardSPCXEquitiesHub_20261016.
 *      Uses forge's Base EVM (nightly) for native B20 tokens. The fork is on Cobalt.
 *      E2E isolation is disabled to avoid L1 data fees for 0-ETH pranked callers.
 * forge-config: default.networks.network = "base"
 * forge-config: default.hardfork = "base:cobalt"
 * forge-config: default.isolate = false
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/AaveV4Base_OnboardSPCXEquitiesHub_20261016.t.sol -vv
 */
contract AaveV4Base_OnboardSPCXEquitiesHub_20261016_Test is ProtocolV4TestBaseBase {
  AaveV4Base_OnboardSPCXEquitiesHub_20261016 internal proposal;
  IHub internal hub = AaveV4BaseHubs.EQUITIES_HUB;
  ISpoke internal spoke = AaveV4BaseSpokes.MAG7_SPOKE;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 52669984);
    proposal = new AaveV4Base_OnboardSPCXEquitiesHub_20261016();
  }

  /**
   * @dev executes the payload with config snapshots and diff; e2e runs separately
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4Base_OnboardSPCXEquitiesHub_20261016',
      payload: address(proposal),
      runE2E: false,
      testPositionManagers: false,
      runSeatbelt: false
    });
  }

  function test_e2e() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestAllSpokes({spokes: _getSpokes(), testPositionManagers: true});
    e2eTestAllTokenizationSpokes(_getTokenizationSpokes());
  }

  function test_preState() public view {
    assertEq(block.chainid, 8453);
    assertEq(hub.getAssetCount(), 8);
    assertEq(spoke.getReserveCount(), 8);
    assertFalse(hub.isUnderlyingListed(proposal.SPCXC()));
    assertEq(address(spoke.ORACLE()), address(AaveV4BaseSpokes.MAG7_SPOKE_ORACLE));
    for (uint256 i; i < 8; ++i) {
      ISpoke.Reserve memory reserve = spoke.getReserve(i);
      assertEq(address(reserve.hub), address(hub));
      (address underlying, ) = hub.getAssetUnderlyingAndDecimals(reserve.assetId);
      assertEq(underlying, reserve.underlying);
    }
    assertTrue(_isB20(proposal.SPCXC()));
    assertEq(IERC20Metadata(proposal.SPCXC()).symbol(), 'SPCXc');
    assertEq(IERC20Metadata(proposal.SPCXC()).name(), 'Space Exploration Technologies Corp.');
    assertEq(IERC20Metadata(proposal.SPCXC()).decimals(), 8);
    IListingPriceFeed feed = IListingPriceFeed(proposal.MAG7_SPOKE_SPCXC_PRICE_FEED());
    assertEq(feed.description(), 'Coinbase SPCX');
    assertEq(feed.decimals(), 8);
    (uint80 roundId, int256 answer, , uint256 updatedAt, uint80 answeredInRound) = feed
      .latestRoundData();
    assertGt(answer, 0);
    assertGt(updatedAt, 0);
    assertLe(updatedAt, block.timestamp);
    assertGe(answeredInRound, roundId);
  }

  function test_hubAssetListing_EQUITIES_HUB_SPCXC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(hub.getAssetCount(), 9, 'asset count');
    assertTrue(hub.isUnderlyingListed(proposal.SPCXC()), 'asset not listed');
    uint256 assetId = hub.getAssetId(proposal.SPCXC());
    IHub.Asset memory asset = hub.getAsset(assetId);
    assertEq(asset.underlying, proposal.SPCXC(), 'underlying');
    assertEq(asset.decimals, 8, 'decimals');
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    assertEq(cfg.feeReceiver, address(AaveV4Base.TREASURY_SPOKE), 'feeReceiver');
    assertEq(cfg.liquidityFee, 0, 'liquidityFee');
    assertEq(
      cfg.irStrategy,
      address(AaveV4BaseIRStrategies.EQUITIES_AAPLc_IR_STRATEGY),
      'irStrategy'
    );
    IAssetInterestRateStrategy.InterestRateData memory ir = IAssetInterestRateStrategy(
      cfg.irStrategy
    ).getInterestRateData(assetId);
    assertEq(ir.optimalUsageRatio, V4EngineDefaults.MAX_OPTIMAL_USAGE_RATIO, 'optimalUsageRatio');
    assertEq(ir.baseDrawnRate, 0, 'baseDrawnRate');
    assertEq(ir.rateGrowthBeforeOptimal, 0, 'rateGrowthBeforeOptimal');
    assertEq(ir.rateGrowthAfterOptimal, 0, 'rateGrowthAfterOptimal');
    assertEq(hub.getAssetDrawnRate(assetId), 0, 'drawn rate');
    assertEq(
      _findTokenizationSpoke(hub, proposal.SPCXC()),
      address(0),
      'unexpected tokenization spoke'
    );
  }

  function test_spokeReserveListing_MAG7_SPOKE_SPCXC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(spoke.getReserveCount(), 9, 'reserve count');
    uint256 assetId = hub.getAssetId(proposal.SPCXC());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    assertEq(address(reserve.hub), address(hub), 'hub');
    assertEq(reserve.assetId, assetId, 'assetId');
    assertEq(reserve.underlying, proposal.SPCXC(), 'underlying');
    assertEq(reserve.decimals, 8, 'decimals');
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(cfg.collateralRisk, 10_00, 'collateralRisk');
    assertFalse(cfg.borrowable, 'borrowable');
    assertFalse(cfg.frozen, 'frozen');
    assertFalse(cfg.paused, 'paused');
    assertTrue(cfg.receiveSharesEnabled, 'receiveSharesEnabled');
    ISpoke.DynamicReserveConfig memory dynamicCfg = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );
    assertEq(dynamicCfg.collateralFactor, 55_00, 'collateralFactor');
    assertEq(dynamicCfg.maxLiquidationBonus, 106_50, 'maxLiquidationBonus');
    assertEq(dynamicCfg.liquidationFee, 10_00, 'liquidationFee');
  }

  function test_reservePriceSources_MAG7_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(proposal.SPCXC()));
    assertEq(
      AaveV4BaseSpokes.MAG7_SPOKE_ORACLE.getReserveSource(reserveId),
      proposal.MAG7_SPOKE_SPCXC_PRICE_FEED(),
      'price source'
    );
    assertGt(AaveV4BaseSpokes.MAG7_SPOKE_ORACLE.getReservePrice(reserveId), 0, 'price');
  }

  function test_hubSpokeToAssetsAddition_EQUITIES_HUB_MAG7_SPOKE_SPCXC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 assetId = hub.getAssetId(proposal.SPCXC());
    assertTrue(hub.isSpokeListed(assetId, address(spoke)), 'spoke not listed');
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(assetId, address(spoke));
    assertEq(cfg.addCap, 37_000, 'addCap');
    assertEq(cfg.drawCap, 0, 'drawCap');
    assertEq(cfg.riskPremiumThreshold, 0, 'riskPremiumThreshold');
    assertTrue(cfg.active, 'active');
    assertFalse(cfg.halted, 'halted');
  }

  function test_hubSpokeConfigUpdate_EQUITIES_HUB_MAG7_SPOKE_USDC() public {
    uint256 assetId = hub.getAssetId(AaveV4BaseAssets.USDC_UNDERLYING);
    IHub.SpokeConfig memory beforeConfig = hub.getSpokeConfig(assetId, address(spoke));
    GovV3Helpers.executePayload(vm, address(proposal));
    beforeConfig.riskPremiumThreshold = 1_000_00;
    assertEq(
      abi.encode(hub.getSpokeConfig(assetId, address(spoke))),
      abi.encode(beforeConfig),
      'USDC config'
    );
  }

  function test_existingMarketConfigUnchanged() public {
    bytes32[8] memory reserveHashes;
    bytes32[8] memory assetHashes;
    for (uint256 i; i < 8; ++i) {
      reserveHashes[i] = _reserveHash(i);
      assetHashes[i] = keccak256(abi.encode(hub.getAssetConfig(i)));
    }
    bytes32 liquidationHash = keccak256(abi.encode(spoke.getLiquidationConfig()));
    GovV3Helpers.executePayload(vm, address(proposal));
    for (uint256 i; i < 8; ++i) {
      assertEq(_reserveHash(i), reserveHashes[i], 'existing reserve changed');
      assertEq(
        keccak256(abi.encode(hub.getAssetConfig(i))),
        assetHashes[i],
        'existing asset changed'
      );
    }
    assertEq(
      keccak256(abi.encode(spoke.getLiquidationConfig())),
      liquidationHash,
      'liquidation config changed'
    );
  }

  function test_accessManagerRoleMembership_SPOKE_CONFIGURATOR_DOMAIN_ADMIN() public {
    uint64 role = Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE;
    address target = address(AaveV4Base.SPOKE_CONFIGURATOR);
    uint256 count = AaveV4Base.ACCESS_MANAGER.getRoleTargetSelectorCount(role, target);
    bytes4[] memory selectors = AaveV4Base.ACCESS_MANAGER.getRoleTargetSelectors(
      role,
      target,
      0,
      count
    );
    uint256 members = AaveV4Base.ACCESS_MANAGER.getRoleMemberCount(role);
    address[] memory existingMembers = AaveV4Base.ACCESS_MANAGER.getRoleMembers(role, 0, members);
    _assertExecutorHasNoListingRole();
    GovV3Helpers.executePayload(vm, address(proposal));
    (bool isMember, uint32 executionDelay) = AaveV4Base.ACCESS_MANAGER.hasRole(
      role,
      GovernanceV3Base.EXECUTOR_LVL_1
    );
    assertTrue(isMember, 'executor domain role missing');
    assertEq(executionDelay, 0, 'execution delay');
    assertEq(AaveV4Base.ACCESS_MANAGER.getRoleMemberCount(role), members + 1, 'member count');
    for (uint256 i; i < members; ++i) {
      assertEq(
        AaveV4Base.ACCESS_MANAGER.getRoleMember(role, i),
        existingMembers[i],
        'existing member changed'
      );
    }
    assertEq(
      AaveV4Base.ACCESS_MANAGER.getRoleTargetSelectorCount(role, target),
      count,
      'selector count'
    );
    assertEq(
      abi.encode(AaveV4Base.ACCESS_MANAGER.getRoleTargetSelectors(role, target, 0, count)),
      abi.encode(selectors),
      'selectors changed'
    );
    for (uint256 i; i < count; ++i) {
      assertEq(
        AaveV4Base.ACCESS_MANAGER.getTargetFunctionRole(target, selectors[i]),
        role,
        'selector role changed'
      );
    }
  }

  function test_otherPermissionsUnchanged() public {
    uint64[] memory roles = AaveV4Base.ACCESS_MANAGER.getRoles(
      0,
      AaveV4Base.ACCESS_MANAGER.getRoleCount()
    );
    bytes32[] memory beforeHashes = new bytes32[](roles.length);
    for (uint256 i; i < roles.length; ++i) {
      beforeHashes[i] = _rolePermissionsHash(roles[i]);
    }
    bytes32 adminHash = _rolePermissionsHash(Roles.ACCESS_MANAGER_ADMIN_ROLE);
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      abi.encode(AaveV4Base.ACCESS_MANAGER.getRoles(0, AaveV4Base.ACCESS_MANAGER.getRoleCount())),
      abi.encode(roles),
      'roles changed'
    );
    for (uint256 i; i < roles.length; ++i) {
      assertEq(_rolePermissionsHash(roles[i]), beforeHashes[i], 'other permissions changed');
    }
    assertEq(
      _rolePermissionsHash(Roles.ACCESS_MANAGER_ADMIN_ROLE),
      adminHash,
      'admin permissions changed'
    );
  }

  function test_accessManagerRoleMembershipsInput() public view {
    IConfigEngine.RoleMembership[] memory items = proposal.accessManagerRoleMemberships();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].authority, address(AaveV4Base.ACCESS_MANAGER), 'authority');
    assertEq(items[0].roleId, Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE, 'role');
    assertEq(items[0].account, GovernanceV3Base.EXECUTOR_LVL_1, 'account');
    assertTrue(items[0].granted, 'granted');
    assertEq(items[0].executionDelay, 0, 'executionDelay');
    assertEq(
      proposal.accessManagerTargetFunctionRoleUpdates().length,
      0,
      'unexpected selector updates'
    );
  }

  function test_revertUnauthorizedExecution() public {
    vm.expectRevert(
      abi.encodeWithSignature(
        'AccessManagerUnauthorizedAccount(address,uint64)',
        address(proposal),
        Roles.ACCESS_MANAGER_ADMIN_ROLE
      )
    );
    proposal.execute();
    assertFalse(hub.isUnderlyingListed(proposal.SPCXC()), 'asset listed without governance');
    _assertExecutorHasNoListingRole();
  }

  function test_listingFailureRollsBackAuthorization() public {
    vm.mockCallRevert(
      address(AaveV4Base.SPOKE_CONFIGURATOR),
      abi.encodeWithSelector(ISpokeConfigurator.addReserve.selector),
      abi.encodeWithSignature('Error(string)', 'listing failure')
    );
    uint40 payloadId = GovV3Helpers.readyPayload(vm, address(proposal));
    IPayloadsControllerCore controller = GovV3Helpers.getPayloadsController(block.chainid);
    vm.expectCall(
      address(AaveV4Base.SPOKE_CONFIGURATOR),
      abi.encodeWithSelector(ISpokeConfigurator.addReserve.selector)
    );
    vm.expectRevert(bytes(Errors.FAILED_ACTION_EXECUTION));
    controller.executePayload(payloadId);
    assertFalse(hub.isUnderlyingListed(proposal.SPCXC()), 'hub listing was not rolled back');
    assertEq(spoke.getReserveCount(), 8, 'reserve count changed');
    _assertExecutorHasNoListingRole();
  }

  function test_roleGrantFailurePreventsListing() public {
    bytes memory grantCall = abi.encodeCall(
      AaveV4Base.ACCESS_MANAGER.grantRole,
      (Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE, GovernanceV3Base.EXECUTOR_LVL_1, 0)
    );
    vm.mockCallRevert(
      address(AaveV4Base.ACCESS_MANAGER),
      grantCall,
      abi.encodeWithSignature('Error(string)', 'grant failure')
    );
    uint40 payloadId = GovV3Helpers.readyPayload(vm, address(proposal));
    IPayloadsControllerCore controller = GovV3Helpers.getPayloadsController(block.chainid);
    vm.expectCall(address(AaveV4Base.ACCESS_MANAGER), grantCall);
    vm.expectRevert(bytes(Errors.FAILED_ACTION_EXECUTION));
    controller.executePayload(payloadId);
    assertFalse(hub.isUnderlyingListed(proposal.SPCXC()), 'asset listed after grant failure');
    assertEq(spoke.getReserveCount(), 8, 'reserve count changed');
    _assertExecutorHasNoListingRole();
  }

  function test_e2e_MAG7_SPOKE_SPCXC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(proposal.SPCXC()));
    uint256 usdcReserveId = spoke.getReserveId(
      address(hub),
      hub.getAssetId(AaveV4BaseAssets.USDC_UNDERLYING)
    );
    address user = makeAddr('borrower');
    deal2(proposal.SPCXC(), user, 10e8);
    vm.startPrank(user);
    IERC20Metadata(proposal.SPCXC()).approve(address(spoke), type(uint256).max);
    spoke.supply(reserveId, 10e8, user);
    spoke.setUsingAsCollateral(reserveId, true, user);
    spoke.borrow(usdcReserveId, 100e6, user);
    assertEq(IERC20Metadata(AaveV4BaseAssets.USDC_UNDERLYING).balanceOf(user), 100e6);
    vm.expectRevert(ISpoke.ReserveNotBorrowable.selector);
    spoke.borrow(reserveId, 1e8, user);
    // Cover the debt-share rounding on full repayment.
    deal2(AaveV4BaseAssets.USDC_UNDERLYING, user, 101e6);
    IERC20Metadata(AaveV4BaseAssets.USDC_UNDERLYING).approve(address(spoke), type(uint256).max);
    spoke.repay(usdcReserveId, type(uint256).max, user);
    spoke.withdraw(reserveId, type(uint256).max, user);
    assertEq(IERC20Metadata(proposal.SPCXC()).balanceOf(user), 10e8);
    vm.stopPrank();
  }

  function test_borrowOverCollateralFactor_MAG7_SPOKE_SPCXC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(proposal.SPCXC()));
    uint256 usdcReserveId = spoke.getReserveId(
      address(hub),
      hub.getAssetId(AaveV4BaseAssets.USDC_UNDERLYING)
    );
    uint256 borrowAmount = (10 *
      AaveV4BaseSpokes.MAG7_SPOKE_ORACLE.getReservePrice(reserveId) *
      56 *
      1e6) / (AaveV4BaseSpokes.MAG7_SPOKE_ORACLE.getReservePrice(usdcReserveId) * 100);
    address user = makeAddr('over-collateral-factor borrower');
    deal2(proposal.SPCXC(), user, 10e8);
    vm.startPrank(user);
    IERC20Metadata(proposal.SPCXC()).approve(address(spoke), type(uint256).max);
    spoke.supply(reserveId, 10e8, user);
    spoke.setUsingAsCollateral(reserveId, true, user);
    vm.expectRevert(ISpoke.HealthFactorBelowThreshold.selector);
    spoke.borrow(usdcReserveId, borrowAmount, user);
    vm.stopPrank();
  }

  function test_addCap_EQUITIES_HUB_MAG7_SPOKE_SPCXC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(proposal.SPCXC()));
    address user = makeAddr('cap supplier');
    deal2(proposal.SPCXC(), user, 37_000e8 + 1);
    vm.startPrank(user);
    IERC20Metadata(proposal.SPCXC()).approve(address(spoke), type(uint256).max);
    spoke.supply(reserveId, 37_000e8, user);
    vm.expectRevert(abi.encodeWithSelector(IHub.AddCapExceeded.selector, uint256(37_000)));
    spoke.supply(reserveId, 1, user);
    vm.stopPrank();
  }

  function test_hubAssetListingsInput() public view {
    IConfigEngine.AssetListing[] memory items = proposal.hubAssetListings();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].hub, address(AaveV4BaseHubs.EQUITIES_HUB), 'hub');
    assertEq(items[0].underlying, proposal.SPCXC(), 'underlying');
    assertEq(
      address(items[0].hubConfigurator),
      address(AaveV4Base.HUB_CONFIGURATOR),
      'hubConfigurator'
    );
    assertEq(
      abi.encode(items[0].tokenization),
      abi.encode(V4EngineDefaults.noTokenization()),
      'tokenization'
    );
    assertEq(items[0].feeReceiver, address(AaveV4Base.TREASURY_SPOKE), 'feeReceiver');
    assertEq(items[0].liquidityFee, 0, 'liquidityFee');
    assertEq(
      items[0].irStrategy,
      address(AaveV4BaseIRStrategies.EQUITIES_AAPLc_IR_STRATEGY),
      'irStrategy'
    );
    assertEq(
      uint256(items[0].irData.optimalUsageRatio),
      V4EngineDefaults.MAX_OPTIMAL_USAGE_RATIO,
      'optimalUsageRatio'
    );
    assertEq(uint256(items[0].irData.baseDrawnRate), 0, 'baseDrawnRate');
    assertEq(uint256(items[0].irData.rateGrowthBeforeOptimal), 0, 'rateGrowthBeforeOptimal');
    assertEq(uint256(items[0].irData.rateGrowthAfterOptimal), 0, 'rateGrowthAfterOptimal');
  }

  function test_spokeReserveListingsInput() public view {
    IConfigEngine.ReserveListing[] memory items = proposal.spokeReserveListings();
    assertEq(items.length, 1, 'length');
    assertEq(
      address(items[0].spokeConfigurator),
      address(AaveV4Base.SPOKE_CONFIGURATOR),
      'spokeConfigurator'
    );
    assertEq(items[0].spoke, address(AaveV4BaseSpokes.MAG7_SPOKE), 'spoke');
    assertEq(items[0].hub, address(AaveV4BaseHubs.EQUITIES_HUB), 'hub');
    assertEq(items[0].underlying, proposal.SPCXC(), 'underlying');
    assertEq(items[0].priceSource, proposal.MAG7_SPOKE_SPCXC_PRICE_FEED(), 'priceSource');
    assertEq(uint256(items[0].config.collateralRisk), 10_00, 'collateralRisk');
    assertEq(items[0].config.paused, false, 'paused');
    assertEq(items[0].config.frozen, false, 'frozen');
    assertEq(items[0].config.borrowable, false, 'borrowable');
    assertEq(items[0].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[0].dynamicConfig.collateralFactor), 55_00, 'collateralFactor');
    assertEq(uint256(items[0].dynamicConfig.maxLiquidationBonus), 106_50, 'maxLiquidationBonus');
    assertEq(uint256(items[0].dynamicConfig.liquidationFee), 10_00, 'liquidationFee');
  }

  function test_hubSpokeToAssetsAdditionsInput() public view {
    IConfigEngine.SpokeToAssetsAddition[] memory items = proposal.hubSpokeToAssetsAdditions();
    assertEq(items.length, 1, 'length');
    assertEq(
      address(items[0].hubConfigurator),
      address(AaveV4Base.HUB_CONFIGURATOR),
      'hubConfigurator'
    );
    assertEq(items[0].hub, address(hub), 'hub');
    assertEq(items[0].spoke, address(AaveV4BaseSpokes.MAG7_SPOKE), 'spoke');
    assertEq(items[0].assets.length, 1, 'assets length');
    assertEq(items[0].assets[0].underlying, proposal.SPCXC(), 'underlying');
    assertEq(uint256(items[0].assets[0].config.addCap), 37_000, 'addCap');
    assertEq(uint256(items[0].assets[0].config.drawCap), 0, 'drawCap');
    assertEq(uint256(items[0].assets[0].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[0].assets[0].config.active, true, 'active');
    assertEq(items[0].assets[0].config.halted, false, 'halted');
  }

  function test_hubSpokeConfigUpdatesInput() public view {
    IConfigEngine.SpokeConfigUpdate[] memory items = proposal.hubSpokeConfigUpdates();
    assertEq(items.length, 1, 'length');
    assertEq(
      address(items[0].hubConfigurator),
      address(AaveV4Base.HUB_CONFIGURATOR),
      'hubConfigurator'
    );
    assertEq(items[0].hub, address(hub), 'hub');
    assertEq(items[0].spoke, address(spoke), 'spoke');
    assertEq(items[0].underlying, AaveV4BaseAssets.USDC_UNDERLYING, 'underlying');
    assertEq(items[0].riskPremiumThreshold, 1_000_00, 'riskPremiumThreshold');
    assertEq(items[0].addCap, EngineFlags.KEEP_CURRENT, 'addCap');
    assertEq(items[0].drawCap, EngineFlags.KEEP_CURRENT, 'drawCap');
    assertEq(items[0].active, EngineFlags.KEEP_CURRENT, 'active');
    assertEq(items[0].halted, EngineFlags.KEEP_CURRENT, 'halted');
  }

  function test_e2e_MAG7_SPOKE_SPCXC_USDC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    Types.ReserveInfo[] memory reserves = _getReserveInfo(spoke);
    Types.ReserveInfo[] memory collaterals = _getAllUsableCollaterals(reserves);
    uint256 collateralIndex = type(uint256).max;
    for (uint256 i; i < collaterals.length; ++i) {
      if (collaterals[i].underlying == proposal.SPCXC()) collateralIndex = i;
    }
    assertLt(collateralIndex, collaterals.length, 'SPCXc collateral missing');
    uint256 usdcReserveId = spoke.getReserveId(
      address(hub),
      hub.getAssetId(AaveV4BaseAssets.USDC_UNDERLYING)
    );
    e2eTestAsset(spoke, collaterals, collateralIndex, reserves[usdcReserveId]);
  }

  function _assertExecutorHasNoListingRole() internal view {
    (bool member, ) = AaveV4Base.ACCESS_MANAGER.hasRole(
      Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      GovernanceV3Base.EXECUTOR_LVL_1
    );
    assertFalse(member, 'executor domain role granted');
    assertEq(
      AaveV4Base.ACCESS_MANAGER.getTargetFunctionRole(
        address(AaveV4Base.SPOKE_CONFIGURATOR),
        ISpokeConfigurator.addReserve.selector
      ),
      Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      'listing role'
    );
  }

  function _rolePermissionsHash(uint64 role) internal view returns (bytes32) {
    bytes32 permissionsHash = keccak256(
      abi.encode(
        AaveV4Base.ACCESS_MANAGER.getRoleAdmin(role),
        AaveV4Base.ACCESS_MANAGER.getRoleGuardian(role),
        AaveV4Base.ACCESS_MANAGER.getRoleGrantDelay(role)
      )
    );
    address[] memory members = AaveV4Base.ACCESS_MANAGER.getRoleMembers(
      role,
      0,
      AaveV4Base.ACCESS_MANAGER.getRoleMemberCount(role)
    );
    for (uint256 i; i < members.length; ++i) {
      if (
        role == Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE &&
        members[i] == GovernanceV3Base.EXECUTOR_LVL_1
      ) continue;
      (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) = AaveV4Base
        .ACCESS_MANAGER
        .getAccess(role, members[i]);
      permissionsHash = keccak256(
        abi.encode(permissionsHash, members[i], since, currentDelay, pendingDelay, effect)
      );
    }
    address[] memory targets = AaveV4Base.ACCESS_MANAGER.getRoleTargets(
      role,
      0,
      AaveV4Base.ACCESS_MANAGER.getRoleTargetCount(role)
    );
    for (uint256 i; i < targets.length; ++i) {
      bytes4[] memory selectors = AaveV4Base.ACCESS_MANAGER.getRoleTargetSelectors(
        role,
        targets[i],
        0,
        AaveV4Base.ACCESS_MANAGER.getRoleTargetSelectorCount(role, targets[i])
      );
      permissionsHash = keccak256(
        abi.encode(
          permissionsHash,
          targets[i],
          selectors,
          AaveV4Base.ACCESS_MANAGER.getTargetAdminDelay(targets[i]),
          AaveV4Base.ACCESS_MANAGER.isTargetClosed(targets[i])
        )
      );
      for (uint256 j; j < selectors.length; ++j) {
        permissionsHash = keccak256(
          abi.encode(
            permissionsHash,
            AaveV4Base.ACCESS_MANAGER.getTargetFunctionRole(targets[i], selectors[j])
          )
        );
      }
    }
    return permissionsHash;
  }

  function _reserveHash(uint256 reserveId) internal view returns (bytes32) {
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    return
      keccak256(
        abi.encode(
          reserve,
          spoke.getReserveConfig(reserveId),
          spoke.getDynamicReserveConfig(reserveId, reserve.dynamicConfigKey),
          AaveV4BaseSpokes.MAG7_SPOKE_ORACLE.getReserveSource(reserveId)
        )
      );
  }
}
