// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHub, ISpoke} from 'aave-address-book/AaveV4.sol';
import {IPayloadsControllerCore} from 'aave-address-book/GovernanceV3.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';
import {SentoraRiskIncreasePayload} from './SentoraTestPayloads.sol';

/// @dev Risk-increasing path: a Sentora payload executed by the Executor (role 1000) through the PPC
/// after its 2-day delay; the Security Council can cancel it in flight.
contract SentoraRiskIncrease_Test is SentoraTestBase {
  IPayloadsControllerCore internal constant CONTROLLER = IPayloadsControllerCore(PPC);

  SentoraRiskIncreasePayload internal increase;
  uint256 internal rlusdAssetId;
  uint256 internal usdeReserveId;

  function setUp() public override {
    super.setUp();
    _activate();
    increase = new SentoraRiskIncreasePayload();
    rlusdAssetId = HUB.getAssetId(Assets.RLUSD_UNDERLYING);
    usdeReserveId = _reserveId(RLUSD_YIELD, Assets.USDe_UNDERLYING);
  }

  function test_increaseOnlyAfterDelay() public {
    uint40 payloadId = _createPayload(address(increase));
    uint256 queuedAt = block.timestamp;

    vm.warp(queuedAt + PPC_DELAY);
    vm.expectRevert(bytes('34'));
    CONTROLLER.executePayload(payloadId);
    _assertLaunchValues();

    vm.warp(queuedAt + PPC_DELAY + 1);
    CONTROLLER.executePayload(payloadId);

    IHub.SpokeConfig memory caps = HUB.getSpokeConfig(rlusdAssetId, address(RLUSD_YIELD));
    assertEq(caps.addCap, increase.RLUSD_ADD_CAP(), 'add cap raised');
    assertEq(caps.drawCap, increase.RLUSD_DRAW_CAP(), 'draw cap raised');
    ISpoke.Reserve memory reserve = RLUSD_YIELD.getReserve(usdeReserveId);
    assertEq(reserve.dynamicConfigKey, 1, 'new key');
    ISpoke.DynamicReserveConfig memory config = RLUSD_YIELD.getDynamicReserveConfig(
      usdeReserveId,
      1
    );
    assertEq(config.collateralFactor, increase.USDe_COLLATERAL_FACTOR(), 'collateral factor');
    assertEq(config.maxLiquidationBonus, 103_50, 'bonus kept');
    assertEq(config.liquidationFee, 3_50, 'fee kept');
  }

  function test_securityCouncilCancelsInFlight() public {
    SentoraRiskIncreasePayload other = new SentoraRiskIncreasePayload();
    uint40 kept = _createPayload(address(increase));
    vm.warp(block.timestamp + 1 hours);
    uint40 cancelled = _createPayload(address(other));

    vm.warp(block.timestamp + 1 days);
    vm.prank(SECURITY_COUNCIL);
    CONTROLLER.cancelPayload(cancelled);

    vm.warp(block.timestamp + PPC_DELAY);
    vm.expectRevert(bytes('33'));
    CONTROLLER.executePayload(cancelled);
    _assertLaunchValues();

    CONTROLLER.executePayload(kept);
    assertEq(
      uint8(CONTROLLER.getPayloadState(cancelled)),
      uint8(IPayloadsControllerCore.PayloadState.Cancelled),
      'cancelled'
    );
    assertEq(
      uint8(CONTROLLER.getPayloadState(kept)),
      uint8(IPayloadsControllerCore.PayloadState.Executed),
      'executed'
    );
    assertEq(
      HUB.getSpokeConfig(rlusdAssetId, address(RLUSD_YIELD)).addCap,
      increase.RLUSD_ADD_CAP(),
      'kept payload applied'
    );
  }

  function test_increaseNotReachableDirectly() public {
    address[4] memory callers = [EMERGENCY_ADMIN, SECURITY_COUNCIL, OPERATOR, DEPLOYER];
    uint256 addCap = increase.RLUSD_ADD_CAP();
    uint256 drawCap = increase.RLUSD_DRAW_CAP();
    uint16 collateralFactor = increase.USDe_COLLATERAL_FACTOR();
    for (uint256 i; i < callers.length; ++i) {
      vm.startPrank(callers[i]);
      _expectUnauthorized(callers[i]);
      HUB_CONFIGURATOR.updateSpokeCaps(
        address(HUB),
        rlusdAssetId,
        address(RLUSD_YIELD),
        addCap,
        drawCap
      );
      _expectUnauthorized(callers[i]);
      SPOKE_CONFIGURATOR.addCollateralFactor(address(RLUSD_YIELD), usdeReserveId, collateralFactor);
      vm.stopPrank();
    }
  }

  function _assertLaunchValues() internal view {
    IHub.SpokeConfig memory caps = HUB.getSpokeConfig(rlusdAssetId, address(RLUSD_YIELD));
    assertEq(caps.addCap, 100_000_000, 'launch add cap');
    assertEq(caps.drawCap, 90_000_000, 'launch draw cap');
    assertEq(RLUSD_YIELD.getReserve(usdeReserveId).dynamicConfigKey, 0, 'launch key');
  }
}
