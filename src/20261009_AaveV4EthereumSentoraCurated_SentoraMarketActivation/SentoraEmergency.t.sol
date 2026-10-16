// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IHub, ISpoke, IHubConfigurator, ISpokeConfigurator} from 'aave-address-book/AaveV4.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {IPayloadsControllerCore} from 'aave-address-book/GovernanceV3.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';
import {SentoraCallsPayload} from './SentoraTestPayloads.sol';

/// @dev Role 1001: one-way emergency actions for the Emergency Admin and the Security Council;
/// only the Executor, behind the PPC delay, can undo them.
contract SentoraEmergency_Test is SentoraTestBase {
  uint256 internal constant RLUSD_ASSET_ID = 0;

  function setUp() public override {
    super.setUp();
    _activate();
    assertEq(HUB.getAssetId(Assets.RLUSD_UNDERLYING), RLUSD_ASSET_ID, 'rlusd asset id');
  }

  function test_haltAsset() public {
    address[2] memory callers = _emergencyCallers();
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      HUB_CONFIGURATOR.haltAsset(address(HUB), RLUSD_ASSET_ID);
      uint256 spokeCount = HUB.getSpokeCount(RLUSD_ASSET_ID);
      assertEq(spokeCount, 3, 'rlusd spokes');
      for (uint256 i; i < spokeCount; ++i) {
        address spoke = HUB.getSpokeAddress(RLUSD_ASSET_ID, i);
        assertTrue(HUB.getSpokeConfig(RLUSD_ASSET_ID, spoke).halted, 'halted');
      }
      _expectSupplyRevert(RLUSD_YIELD, Assets.RLUSD_UNDERLYING, IHub.SpokeHalted.selector);
      vm.revertToState(snapshot);
    }
  }

  function test_haltSpoke() public {
    address[2] memory callers = _emergencyCallers();
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      HUB_CONFIGURATOR.haltSpoke(address(HUB), address(RLUSD_YIELD));
      _assertSpokePairs(RLUSD_YIELD, true, false);
      assertFalse(HUB.getSpokeConfig(RLUSD_ASSET_ID, address(BLUECHIP)).halted, 'bluechip live');
      _expectSupplyRevert(RLUSD_YIELD, Assets.USDe_UNDERLYING, IHub.SpokeHalted.selector);
      vm.revertToState(snapshot);
    }
  }

  function test_resetAssetCaps() public {
    address[2] memory callers = _emergencyCallers();
    uint256 assetId = HUB.getAssetId(Assets.USDe_UNDERLYING);
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      HUB_CONFIGURATOR.resetAssetCaps(address(HUB), assetId);
      uint256 spokeCount = HUB.getSpokeCount(assetId);
      for (uint256 i; i < spokeCount; ++i) {
        IHub.SpokeConfig memory config = HUB.getSpokeConfig(
          assetId,
          HUB.getSpokeAddress(assetId, i)
        );
        assertEq(config.addCap, 0, 'add cap');
        assertEq(config.drawCap, 0, 'draw cap');
      }
      _expectSupplyRevert(
        RLUSD_YIELD,
        Assets.USDe_UNDERLYING,
        abi.encodeWithSelector(IHub.AddCapExceeded.selector, 0)
      );
      vm.revertToState(snapshot);
    }
  }

  function test_resetSpokeCaps() public {
    address[2] memory callers = _emergencyCallers();
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      HUB_CONFIGURATOR.resetSpokeCaps(address(HUB), address(BLUECHIP));
      _assertSpokePairs(BLUECHIP, false, true);
      _expectSupplyRevert(
        BLUECHIP,
        Assets.kBTC_UNDERLYING,
        abi.encodeWithSelector(IHub.AddCapExceeded.selector, 0)
      );
      vm.revertToState(snapshot);
    }
  }

  function test_pauseReserve() public {
    address[2] memory callers = _emergencyCallers();
    uint256 reserveId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      SPOKE_CONFIGURATOR.pauseReserve(address(RLUSD_YIELD), reserveId);
      assertTrue(RLUSD_YIELD.getReserveConfig(reserveId).paused, 'paused');
      assertFalse(
        RLUSD_YIELD.getReserveConfig(_reserveId(RLUSD_YIELD, Assets.PST_UNDERLYING)).paused,
        'other reserve live'
      );
      _expectSupplyRevert(RLUSD_YIELD, Assets.USDe_UNDERLYING, ISpoke.ReservePaused.selector);
      vm.revertToState(snapshot);
    }
  }

  function test_pauseAllReserves() public {
    address[2] memory callers = _emergencyCallers();
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      SPOKE_CONFIGURATOR.pauseAllReserves(address(OUSD_YIELD));
      uint256 reserveCount = OUSD_YIELD.getReserveCount();
      for (uint256 reserveId; reserveId < reserveCount; ++reserveId) {
        assertTrue(OUSD_YIELD.getReserveConfig(reserveId).paused, 'paused');
      }
      _expectSupplyRevert(OUSD_YIELD, Assets.OUSD_UNDERLYING, ISpoke.ReservePaused.selector);
      vm.revertToState(snapshot);
    }
  }

  function test_freezeReserve() public {
    address[2] memory callers = _emergencyCallers();
    uint256 reserveId = _reserveId(BLUECHIP, Assets.kBTC_UNDERLYING);
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      SPOKE_CONFIGURATOR.freezeReserve(address(BLUECHIP), reserveId);
      assertTrue(BLUECHIP.getReserveConfig(reserveId).frozen, 'frozen');
      _expectSupplyRevert(BLUECHIP, Assets.kBTC_UNDERLYING, ISpoke.ReserveFrozen.selector);
      vm.revertToState(snapshot);
    }
  }

  function test_freezeAllReserves() public {
    address[2] memory callers = _emergencyCallers();
    for (uint256 c; c < callers.length; ++c) {
      uint256 snapshot = vm.snapshotState();
      vm.prank(callers[c]);
      SPOKE_CONFIGURATOR.freezeAllReserves(address(RLUSD_YIELD));
      uint256 reserveCount = RLUSD_YIELD.getReserveCount();
      for (uint256 reserveId; reserveId < reserveCount; ++reserveId) {
        assertTrue(RLUSD_YIELD.getReserveConfig(reserveId).frozen, 'frozen');
      }
      _expectSupplyRevert(RLUSD_YIELD, Assets.RLUSD_UNDERLYING, ISpoke.ReserveFrozen.selector);
      vm.revertToState(snapshot);
    }
  }

  function test_emergencyCallersCannotUndo() public {
    address[2] memory callers = _emergencyCallers();
    uint256 reserveId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    vm.startPrank(EMERGENCY_ADMIN);
    HUB_CONFIGURATOR.haltSpoke(address(HUB), address(RLUSD_YIELD));
    SPOKE_CONFIGURATOR.pauseReserve(address(RLUSD_YIELD), reserveId);
    SPOKE_CONFIGURATOR.freezeReserve(address(RLUSD_YIELD), reserveId);
    vm.stopPrank();

    for (uint256 c; c < callers.length; ++c) {
      vm.startPrank(callers[c]);
      _expectUnauthorized(callers[c]);
      HUB_CONFIGURATOR.updateSpokeHalted(address(HUB), RLUSD_ASSET_ID, address(RLUSD_YIELD), false);
      _expectUnauthorized(callers[c]);
      SPOKE_CONFIGURATOR.updatePaused(address(RLUSD_YIELD), reserveId, false);
      _expectUnauthorized(callers[c]);
      SPOKE_CONFIGURATOR.updateFrozen(address(RLUSD_YIELD), reserveId, false);
      vm.stopPrank();
    }
  }

  function test_emergencyCallersReachNoOtherConfiguratorSelector() public {
    address[2] memory callers = _emergencyCallers();
    (address[] memory targets, bytes[] memory data) = _nonEmergencyCalls();
    assertEq(targets.length, 15 + 3 + 14 + 6, 'role 200, 1000 and 400 selectors');
    for (uint256 c; c < callers.length; ++c) {
      for (uint256 i; i < targets.length; ++i) {
        vm.prank(callers[c]);
        _expectUnauthorized(callers[c]);
        (bool success, ) = targets[i].call(data[i]);
        assertTrue(success, 'expectRevert consumed the call');
      }
    }
  }

  function test_othersCannotTakeEmergencyActions() public {
    address[5] memory callers = [
      EXECUTOR,
      DEPLOYER,
      address(RISK_STEWARD),
      OPERATOR,
      makeAddr('random')
    ];
    for (uint256 c; c < callers.length; ++c) {
      vm.startPrank(callers[c]);
      _expectUnauthorized(callers[c]);
      HUB_CONFIGURATOR.haltAsset(address(HUB), RLUSD_ASSET_ID);
      _expectUnauthorized(callers[c]);
      HUB_CONFIGURATOR.haltSpoke(address(HUB), address(RLUSD_YIELD));
      _expectUnauthorized(callers[c]);
      HUB_CONFIGURATOR.resetAssetCaps(address(HUB), RLUSD_ASSET_ID);
      _expectUnauthorized(callers[c]);
      HUB_CONFIGURATOR.resetSpokeCaps(address(HUB), address(RLUSD_YIELD));
      _expectUnauthorized(callers[c]);
      SPOKE_CONFIGURATOR.pauseReserve(address(RLUSD_YIELD), 0);
      _expectUnauthorized(callers[c]);
      SPOKE_CONFIGURATOR.pauseAllReserves(address(RLUSD_YIELD));
      _expectUnauthorized(callers[c]);
      SPOKE_CONFIGURATOR.freezeReserve(address(RLUSD_YIELD), 0);
      _expectUnauthorized(callers[c]);
      SPOKE_CONFIGURATOR.freezeAllReserves(address(RLUSD_YIELD));
      vm.stopPrank();
    }
  }

  function test_executorUndoesThroughPayload() public {
    uint256 bluechipCount = BLUECHIP.getReserveCount();
    IHub.SpokeConfig[] memory bluechipCaps = new IHub.SpokeConfig[](bluechipCount);
    for (uint256 reserveId; reserveId < bluechipCount; ++reserveId) {
      bluechipCaps[reserveId] = HUB.getSpokeConfig(
        BLUECHIP.getReserve(reserveId).assetId,
        address(BLUECHIP)
      );
    }

    vm.startPrank(EMERGENCY_ADMIN);
    HUB_CONFIGURATOR.haltAsset(address(HUB), RLUSD_ASSET_ID);
    HUB_CONFIGURATOR.resetSpokeCaps(address(HUB), address(BLUECHIP));
    SPOKE_CONFIGURATOR.pauseAllReserves(address(RLUSD_YIELD));
    SPOKE_CONFIGURATOR.freezeAllReserves(address(OUSD_YIELD));
    vm.stopPrank();

    uint256 rlusdSpokes = HUB.getSpokeCount(RLUSD_ASSET_ID);
    uint256 rlusdYieldCount = RLUSD_YIELD.getReserveCount();
    uint256 ousdYieldCount = OUSD_YIELD.getReserveCount();
    // mWIN was paused by the pre-launch config, so the undo leaves it paused
    uint256 mWinId = _reserveId(RLUSD_YIELD, Assets.mWIN_UNDERLYING);
    SentoraCallsPayload.Call[] memory calls = new SentoraCallsPayload.Call[](
      rlusdSpokes + bluechipCount + rlusdYieldCount - 1 + ousdYieldCount
    );
    uint256 n;
    for (uint256 i; i < rlusdSpokes; ++i) {
      calls[n++] = _call(
        address(HUB_CONFIGURATOR),
        abi.encodeCall(
          IHubConfigurator.updateSpokeHalted,
          (address(HUB), RLUSD_ASSET_ID, HUB.getSpokeAddress(RLUSD_ASSET_ID, i), false)
        )
      );
    }
    for (uint256 reserveId; reserveId < bluechipCount; ++reserveId) {
      calls[n++] = _call(
        address(HUB_CONFIGURATOR),
        abi.encodeCall(
          IHubConfigurator.updateSpokeCaps,
          (
            address(HUB),
            BLUECHIP.getReserve(reserveId).assetId,
            address(BLUECHIP),
            bluechipCaps[reserveId].addCap,
            bluechipCaps[reserveId].drawCap
          )
        )
      );
    }
    for (uint256 reserveId; reserveId < rlusdYieldCount; ++reserveId) {
      if (reserveId == mWinId) continue;
      calls[n++] = _call(
        address(SPOKE_CONFIGURATOR),
        abi.encodeCall(ISpokeConfigurator.updatePaused, (address(RLUSD_YIELD), reserveId, false))
      );
    }
    for (uint256 reserveId; reserveId < ousdYieldCount; ++reserveId) {
      calls[n++] = _call(
        address(SPOKE_CONFIGURATOR),
        abi.encodeCall(ISpokeConfigurator.updateFrozen, (address(OUSD_YIELD), reserveId, false))
      );
    }

    uint40 payloadId = _createPayload(address(new SentoraCallsPayload(calls)));
    vm.warp(block.timestamp + PPC_DELAY);
    vm.expectRevert(bytes('34'));
    IPayloadsControllerCore(PPC).executePayload(payloadId);
    assertTrue(HUB.getSpokeConfig(RLUSD_ASSET_ID, address(RLUSD_YIELD)).halted, 'still halted');

    vm.warp(block.timestamp + 1);
    IPayloadsControllerCore(PPC).executePayload(payloadId);

    for (uint256 i; i < rlusdSpokes; ++i) {
      assertFalse(
        HUB.getSpokeConfig(RLUSD_ASSET_ID, HUB.getSpokeAddress(RLUSD_ASSET_ID, i)).halted,
        'unhalted'
      );
    }
    for (uint256 reserveId; reserveId < bluechipCount; ++reserveId) {
      IHub.SpokeConfig memory config = HUB.getSpokeConfig(
        BLUECHIP.getReserve(reserveId).assetId,
        address(BLUECHIP)
      );
      assertEq(config.addCap, bluechipCaps[reserveId].addCap, 'add cap restored');
      assertEq(config.drawCap, bluechipCaps[reserveId].drawCap, 'draw cap restored');
    }
    for (uint256 reserveId; reserveId < rlusdYieldCount; ++reserveId) {
      assertEq(RLUSD_YIELD.getReserveConfig(reserveId).paused, reserveId == mWinId, 'unpaused');
    }
    for (uint256 reserveId; reserveId < ousdYieldCount; ++reserveId) {
      assertFalse(OUSD_YIELD.getReserveConfig(reserveId).frozen, 'unfrozen');
    }

    address user = makeAddr('user');
    uint256 usdeId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
    _supplyAs(RLUSD_YIELD, usdeId, user, 1_000e18);
    assertEq(RLUSD_YIELD.getUserSuppliedAssets(usdeId, user), 1_000e18, 'market live');
  }

  function _emergencyCallers() internal pure returns (address[2] memory) {
    return [EMERGENCY_ADMIN, SECURITY_COUNCIL];
  }

  function _expectSupplyRevert(ISpoke spoke, address underlying, bytes4 error_) internal {
    _expectSupplyRevert(spoke, underlying, abi.encodeWithSelector(error_));
  }

  function _expectSupplyRevert(ISpoke spoke, address underlying, bytes memory error_) internal {
    address user = makeAddr('supplier');
    uint256 reserveId = _reserveId(spoke, underlying);
    uint256 amount = _units(spoke, reserveId, 1);
    deal2(underlying, user, amount);
    vm.startPrank(user);
    IERC20(underlying).approve(address(spoke), amount);
    vm.expectRevert(error_);
    spoke.supply(reserveId, amount, user);
    vm.stopPrank();
  }

  function _assertSpokePairs(ISpoke spoke, bool halted, bool capsZero) internal view {
    uint256 reserveCount = spoke.getReserveCount();
    for (uint256 reserveId; reserveId < reserveCount; ++reserveId) {
      IHub.SpokeConfig memory config = HUB.getSpokeConfig(
        spoke.getReserve(reserveId).assetId,
        address(spoke)
      );
      assertEq(config.halted, halted, 'halted');
      if (capsZero) {
        assertEq(config.addCap, 0, 'add cap');
        assertEq(config.drawCap, 0, 'draw cap');
      }
    }
  }

  function _call(
    address target,
    bytes memory data
  ) internal pure returns (SentoraCallsPayload.Call memory) {
    return SentoraCallsPayload.Call({target: target, data: data});
  }

  /// @dev One well-formed call per configurator selector held by roles 200, 1000 and 400.
  function _nonEmergencyCalls() internal returns (address[] memory targets, bytes[] memory data) {
    address hub = address(HUB);
    address spoke = address(RLUSD_YIELD);
    address any = makeAddr('any');
    IHub.SpokeConfig memory spokeConfig;
    uint256[] memory assetIds = new uint256[](0);
    IHub.SpokeConfig[] memory spokeConfigs = new IHub.SpokeConfig[](0);
    ISpoke.LiquidationConfig memory liquidationConfig;
    ISpoke.ReserveConfig memory reserveConfig;
    ISpoke.DynamicReserveConfig memory dynamicConfig;

    data = new bytes[](38);
    targets = new address[](38);
    for (uint256 i; i < 18; ++i) targets[i] = address(HUB_CONFIGURATOR);
    for (uint256 i = 18; i < 38; ++i) targets[i] = address(SPOKE_CONFIGURATOR);

    data[0] = abi.encodeCall(IHubConfigurator.addAsset, (hub, any, any, 0, any, ''));
    data[1] = abi.encodeCall(
      IHubConfigurator.addAssetWithDecimals,
      (hub, any, 18, any, 0, any, '')
    );
    data[2] = abi.encodeCall(IHubConfigurator.updateLiquidityFee, (hub, 0, 0));
    data[3] = abi.encodeCall(IHubConfigurator.updateFeeReceiver, (hub, 0, any));
    data[4] = abi.encodeCall(IHubConfigurator.updateFeeConfig, (hub, 0, 0, any));
    data[5] = abi.encodeCall(IHubConfigurator.updateInterestRateStrategy, (hub, 0, any, ''));
    data[6] = abi.encodeCall(IHubConfigurator.updateReinvestmentController, (hub, 0, any));
    data[7] = abi.encodeCall(IHubConfigurator.deactivateAsset, (hub, 0));
    data[8] = abi.encodeCall(IHubConfigurator.addSpoke, (hub, any, 0, spokeConfig));
    data[9] = abi.encodeCall(IHubConfigurator.addSpokeToAssets, (hub, any, assetIds, spokeConfigs));
    data[10] = abi.encodeCall(IHubConfigurator.updateSpokeActive, (hub, 0, spoke, false));
    data[11] = abi.encodeCall(IHubConfigurator.updateSpokeHalted, (hub, 0, spoke, false));
    data[12] = abi.encodeCall(IHubConfigurator.updateSpokeRiskPremiumThreshold, (hub, 0, spoke, 0));
    data[13] = abi.encodeCall(IHubConfigurator.deactivateSpoke, (hub, spoke));
    data[14] = abi.encodeCall(IHubConfigurator.updateInterestRateData, (hub, 0, ''));
    data[15] = abi.encodeCall(IHubConfigurator.updateSpokeAddCap, (hub, 0, spoke, 0));
    data[16] = abi.encodeCall(IHubConfigurator.updateSpokeDrawCap, (hub, 0, spoke, 0));
    data[17] = abi.encodeCall(IHubConfigurator.updateSpokeCaps, (hub, 0, spoke, 0, 0));

    data[18] = abi.encodeCall(ISpokeConfigurator.updateReservePriceSource, (spoke, 0, any));
    data[19] = abi.encodeCall(ISpokeConfigurator.updateLiquidationTargetHealthFactor, (spoke, 0));
    data[20] = abi.encodeCall(ISpokeConfigurator.updateHealthFactorForMaxBonus, (spoke, 0));
    data[21] = abi.encodeCall(ISpokeConfigurator.updateLiquidationBonusFactor, (spoke, 0));
    data[22] = abi.encodeCall(
      ISpokeConfigurator.updateLiquidationConfig,
      (spoke, liquidationConfig)
    );
    data[23] = abi.encodeCall(
      ISpokeConfigurator.addReserve,
      (spoke, hub, 0, any, reserveConfig, dynamicConfig)
    );
    data[24] = abi.encodeCall(ISpokeConfigurator.updatePaused, (spoke, 0, false));
    data[25] = abi.encodeCall(ISpokeConfigurator.updateFrozen, (spoke, 0, false));
    data[26] = abi.encodeCall(ISpokeConfigurator.updateBorrowable, (spoke, 0, false));
    data[27] = abi.encodeCall(ISpokeConfigurator.updateReceiveSharesEnabled, (spoke, 0, false));
    data[28] = abi.encodeCall(ISpokeConfigurator.updateCollateralRisk, (spoke, 0, 0));
    data[29] = abi.encodeCall(ISpokeConfigurator.addLiquidationFee, (spoke, 0, 0));
    data[30] = abi.encodeCall(ISpokeConfigurator.updateLiquidationFee, (spoke, 0, 0, 0));
    data[31] = abi.encodeCall(ISpokeConfigurator.updatePositionManager, (spoke, any, false));
    data[32] = abi.encodeCall(ISpokeConfigurator.addCollateralFactor, (spoke, 0, 0));
    data[33] = abi.encodeCall(ISpokeConfigurator.updateCollateralFactor, (spoke, 0, 0, 0));
    data[34] = abi.encodeCall(ISpokeConfigurator.addMaxLiquidationBonus, (spoke, 0, 0));
    data[35] = abi.encodeCall(ISpokeConfigurator.updateMaxLiquidationBonus, (spoke, 0, 0, 0));
    data[36] = abi.encodeCall(
      ISpokeConfigurator.addDynamicReserveConfig,
      (spoke, 0, dynamicConfig)
    );
    data[37] = abi.encodeCall(
      ISpokeConfigurator.updateDynamicReserveConfig,
      (spoke, 0, 0, dynamicConfig)
    );
  }
}
