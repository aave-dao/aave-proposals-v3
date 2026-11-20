// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumHorizonCustom} from './AaveV3EthereumHorizonCustom.sol';

/// @dev Horizon-specific governance helpers, mirroring GovV3Helpers for multisig-executed proposals.
library AaveHorizonGovV3Helpers {
  address internal constant MULTI_SEND_CALL_ONLY = 0x9641d764fc13c8B624c04430C7356C1C7C8102e2; // trusted SAFE address

  struct Action {
    address to;
    bytes data;
  }

  // OPS multisig

  /// @dev Single action via OPS multisig — direct call (operation = 0).
  function createOpsMultisigCalldata(
    Action memory action
  ) internal pure returns (address to, bytes memory data, uint8 operation) {
    to = action.to;
    data = action.data;
    operation = 0;

    return (to, data, operation);
  }

  /// @dev Batch actions via OPS multisig — delegatecall to MultiSendCallOnly (operation = 1).
  /// Falls through to single-action path if only 1 action.
  function createOpsMultisigCalldata(
    Action[] memory actions
  ) internal pure returns (address to, bytes memory data, uint8 operation) {
    require(actions.length > 0, 'NO_ACTIONS');
    if (actions.length == 1) {
      return createOpsMultisigCalldata(actions[0]);
    }
    to = MULTI_SEND_CALL_ONLY;
    data = _encodeMultiSend(actions);
    operation = 1;

    return (to, data, operation);
  }

  // Emergency multisig

  /// @dev Single action via Emergency multisig — direct call (operation = 0).
  function createEmergencyMultisigCalldata(
    Action memory action
  ) internal pure returns (address to, bytes memory data, uint8 operation) {
    to = action.to;
    data = action.data;
    operation = 0;

    return (to, data, operation);
  }

  /// @dev Batch actions via Emergency multisig — delegatecall to MultiSendCallOnly (operation = 1).
  /// Falls through to single-action path if only 1 action.
  function createEmergencyMultisigCalldata(
    Action[] memory actions
  ) internal pure returns (address to, bytes memory data, uint8 operation) {
    require(actions.length > 0, 'NO_ACTIONS');
    if (actions.length == 1) {
      return createEmergencyMultisigCalldata(actions[0]);
    }
    to = MULTI_SEND_CALL_ONLY;
    data = _encodeMultiSend(actions);
    operation = 1;

    return (to, data, operation);
  }

  // Payload execution via HORIZON_EXECUTOR (Emergency MS path)
  /// @dev Build calldata for Emergency MS to execute a payload via HORIZON_EXECUTOR delegatecall.
  function createExecutorCalldata(
    address payload
  ) internal pure returns (address to, bytes memory data, uint8 operation) {
    to = AaveV3EthereumHorizonCustom.HORIZON_EXECUTOR;
    // executor data
    data = abi.encodeWithSignature(
      'executeTransaction(address,uint256,string,bytes,bool)', // signature
      payload, // target
      0, // value
      'execute()', // signature
      '', // data
      true // withDelegatecall
    );
    operation = 0; // operation = call

    return (to, data, operation);
  }

  /// @dev Encode actions into Gnosis Safe MultiSendCallOnly packed format.
  /// Each tx: operation (1) + to (20) + value (32) + dataLength (32) + data (variable).
  function _encodeMultiSend(Action[] memory actions) private pure returns (bytes memory) {
    bytes memory packedData;
    for (uint256 i = 0; i < actions.length; i++) {
      packedData = abi.encodePacked(
        packedData,
        uint8(0), // operation = call
        actions[i].to,
        uint256(0), // value
        actions[i].data.length,
        actions[i].data
      );
    }
    return abi.encodeWithSelector(bytes4(0x8d80ff0a), packedData);
  }
}
