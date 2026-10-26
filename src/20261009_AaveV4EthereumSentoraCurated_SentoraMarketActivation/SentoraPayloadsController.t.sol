// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-address-book/GovernanceV3.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';
import {IPermissionedPayloadsControllerView} from './SentoraInterfaces.sol';

/// @dev Lifecycle of the activation payload on the Sentora PermissionedPayloadsController.
contract SentoraPayloadsController_Test is SentoraTestBase {
  IPayloadsControllerCore internal constant CONTROLLER = IPayloadsControllerCore(PPC);

  function test_controllerConfig() public view {
    IPermissionedPayloadsControllerView controller = IPermissionedPayloadsControllerView(PPC);
    assertEq(controller.payloadsManager(), OPERATOR, 'payloads manager');
    assertEq(controller.guardian(), SECURITY_COUNCIL, 'guardian');
    assertEq(controller.owner(), SECURITY_COUNCIL, 'owner');
    IPayloadsControllerCore.ExecutorConfig memory level1 = CONTROLLER
      .getExecutorSettingsByAccessControl(PayloadsControllerUtils.AccessControl.Level_1);
    assertEq(level1.executor, EXECUTOR, 'executor');
    assertEq(level1.delay, PPC_DELAY, 'delay');
    assertEq(CONTROLLER.GRACE_PERIOD(), PPC_GRACE_PERIOD, 'grace period');
    assertEq(CONTROLLER.EXPIRATION_DELAY(), PPC_EXPIRATION_DELAY, 'expiration delay');
    assertEq(CONTROLLER.getPayloadsCount(), 0, 'payloads count');
  }

  function test_createPayload_onlyOperator() public {
    address[7] memory callers = [
      DEPLOYER,
      EXECUTOR,
      SECURITY_COUNCIL,
      EMERGENCY_ADMIN,
      FEE_ADMIN,
      GovernanceV3Ethereum.EXECUTOR_LVL_1,
      makeAddr('random')
    ];
    IPayloadsControllerCore.ExecutionAction[] memory actions = _actions();
    for (uint256 i; i < callers.length; ++i) {
      vm.prank(callers[i]);
      vm.expectRevert(bytes('99'));
      CONTROLLER.createPayload(actions);
    }
    assertEq(CONTROLLER.getPayloadsCount(), 0, 'payloads count');
  }

  function test_createPayload_queuedWithDelay() public {
    uint40 payloadId = _createPayload(address(proposal));
    assertEq(payloadId, 0, 'payload id');

    IPayloadsControllerCore.Payload memory payload = CONTROLLER.getPayloadById(payloadId);
    assertEq(payload.creator, OPERATOR, 'creator');
    assertEq(uint8(payload.state), uint8(IPayloadsControllerCore.PayloadState.Queued), 'state');
    assertEq(payload.createdAt, block.timestamp, 'created at');
    assertEq(payload.queuedAt, block.timestamp, 'queued at');
    assertEq(payload.delay, PPC_DELAY, 'delay');
    assertEq(payload.gracePeriod, PPC_GRACE_PERIOD, 'grace period');
    assertEq(payload.expirationTime, block.timestamp + PPC_EXPIRATION_DELAY, 'expiration');
    assertEq(
      uint8(payload.maximumAccessLevelRequired),
      uint8(PayloadsControllerUtils.AccessControl.Level_1),
      'access level'
    );
    assertEq(payload.actions.length, 1, 'actions');
    assertEq(payload.actions[0].target, address(proposal), 'target');
    assertTrue(payload.actions[0].withDelegateCall, 'delegatecall');
    assertEq(payload.actions[0].signature, 'execute()', 'signature');
  }

  function test_executePayload_revertsBeforeDelay() public {
    uint40 payloadId = _createPayload(address(proposal));
    uint256 queuedAt = block.timestamp;

    vm.expectRevert(bytes('34'));
    CONTROLLER.executePayload(payloadId);

    vm.warp(queuedAt + 1 days);
    vm.expectRevert(bytes('34'));
    CONTROLLER.executePayload(payloadId);

    // execution needs strictly more than the delay
    vm.warp(queuedAt + PPC_DELAY);
    vm.expectRevert(bytes('34'));
    CONTROLLER.executePayload(payloadId);

    assertTrue(HUB.getSpokeConfig(0, address(RLUSD_YIELD)).halted, 'still halted');
  }

  function test_executePayload_afterDelay() public {
    uint40 payloadId = _createPayload(address(proposal));
    vm.warp(block.timestamp + PPC_DELAY + 1);

    vm.prank(makeAddr('anyone'));
    CONTROLLER.executePayload(payloadId);

    IPayloadsControllerCore.Payload memory payload = CONTROLLER.getPayloadById(payloadId);
    assertEq(uint8(payload.state), uint8(IPayloadsControllerCore.PayloadState.Executed), 'state');
    assertEq(payload.executedAt, block.timestamp, 'executed at');
    assertFalse(HUB.getSpokeConfig(0, address(RLUSD_YIELD)).halted, 'unhalted');
  }

  function test_executePayload_lastSecondOfGracePeriod() public {
    uint40 payloadId = _createPayload(address(proposal));
    vm.warp(block.timestamp + PPC_DELAY + PPC_GRACE_PERIOD - 1);
    CONTROLLER.executePayload(payloadId);
    assertEq(
      uint8(CONTROLLER.getPayloadState(payloadId)),
      uint8(IPayloadsControllerCore.PayloadState.Executed),
      'state'
    );
  }

  function test_executePayload_revertsAfterGracePeriod() public {
    uint40 payloadId = _createPayload(address(proposal));
    vm.warp(block.timestamp + PPC_DELAY + PPC_GRACE_PERIOD);

    assertEq(
      uint8(CONTROLLER.getPayloadState(payloadId)),
      uint8(IPayloadsControllerCore.PayloadState.Expired),
      'state'
    );
    vm.expectRevert(bytes('33'));
    CONTROLLER.executePayload(payloadId);
  }

  function test_executePayload_revertsTwice() public {
    uint40 payloadId = _createPayload(address(proposal));
    _executeAfterDelay(payloadId);
    vm.expectRevert(bytes('33'));
    CONTROLLER.executePayload(payloadId);
  }

  function test_guardianCancels() public {
    uint40 payloadId = _createPayload(address(proposal));
    vm.warp(block.timestamp + 1 days);

    vm.prank(SECURITY_COUNCIL);
    CONTROLLER.cancelPayload(payloadId);

    IPayloadsControllerCore.Payload memory payload = CONTROLLER.getPayloadById(payloadId);
    assertEq(uint8(payload.state), uint8(IPayloadsControllerCore.PayloadState.Cancelled), 'state');
    assertEq(payload.cancelledAt, block.timestamp, 'cancelled at');

    vm.warp(payload.queuedAt + PPC_DELAY + 1);
    vm.expectRevert(bytes('33'));
    CONTROLLER.executePayload(payloadId);
    assertTrue(HUB.getSpokeConfig(0, address(RLUSD_YIELD)).halted, 'still halted');
  }

  function test_operatorCancels() public {
    uint40 payloadId = _createPayload(address(proposal));

    vm.prank(OPERATOR);
    CONTROLLER.cancelPayload(payloadId);

    assertEq(
      uint8(CONTROLLER.getPayloadState(payloadId)),
      uint8(IPayloadsControllerCore.PayloadState.Cancelled),
      'state'
    );
  }

  function test_cancelPayload_unauthorized() public {
    uint40 payloadId = _createPayload(address(proposal));
    address[6] memory callers = [
      DEPLOYER,
      EXECUTOR,
      EMERGENCY_ADMIN,
      FEE_ADMIN,
      GovernanceV3Ethereum.EXECUTOR_LVL_1,
      makeAddr('random')
    ];
    for (uint256 i; i < callers.length; ++i) {
      vm.prank(callers[i]);
      vm.expectRevert(bytes('100'));
      CONTROLLER.cancelPayload(payloadId);
    }
  }

  function test_cancelPayload_revertsAfterExecution() public {
    uint40 payloadId = _createPayload(address(proposal));
    _executeAfterDelay(payloadId);
    vm.prank(SECURITY_COUNCIL);
    vm.expectRevert(bytes('35'));
    CONTROLLER.cancelPayload(payloadId);
  }

  function test_updateExecutors_notSupported() public {
    IPayloadsControllerCore.UpdateExecutorInput[]
      memory executors = new IPayloadsControllerCore.UpdateExecutorInput[](0);
    vm.prank(SECURITY_COUNCIL);
    vm.expectRevert(bytes('101'));
    CONTROLLER.updateExecutors(executors);
  }

  function _actions() internal view returns (IPayloadsControllerCore.ExecutionAction[] memory a) {
    a = new IPayloadsControllerCore.ExecutionAction[](1);
    a[0] = GovV3Helpers.buildAction(address(proposal));
  }
}
