// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessManager} from 'aave-v4/dependencies/openzeppelin/IAccessManager.sol';
import {IExecutor} from 'aave-address-book/governance-v3/IExecutor.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {AaveV4EthereumSentoraCurated} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';

/**
 * @title SentoraPreLaunchCouncilCalls
 * @notice The V4 Security Council Safe transactions that run the pre-launch config payload: grant
 * the Council Executor roles 200, 400, 1000 and 1001 without execution delay, have it delegatecall
 * the payload, then grant Executor Lvl1 the AccessManager admin role 0 without execution delay.
 */
library SentoraPreLaunchCouncilCalls {
  struct Call {
    address to;
    bytes data;
  }

  /// @dev Safe MultiSendCallOnly v1.4.1 canonical deployment.
  address internal constant MULTI_SEND_CALL_ONLY = 0x9641d764fc13c8B624c04430C7356C1C7C8102e2;

  /// @dev AccessManager `ADMIN_ROLE`.
  uint64 internal constant ADMIN_ROLE = 0;

  function roles() internal pure returns (uint64[4] memory) {
    return [uint64(200), 400, 1000, 1001];
  }

  function calls(address payload) internal pure returns (Call[] memory list) {
    address accessManager = address(AaveV4EthereumSentoraCurated.ACCESS_MANAGER);
    address executor = MiscEthereum.V4_SECURITY_COUNCIL_EXECUTOR;
    uint64[4] memory roleIds = roles();
    list = new Call[](6);
    for (uint256 i; i < roleIds.length; ++i) {
      list[i] = Call({
        to: accessManager,
        data: abi.encodeCall(IAccessManager.grantRole, (roleIds[i], executor, 0))
      });
    }
    list[4] = Call({
      to: executor,
      data: abi.encodeCall(IExecutor.executeTransaction, (payload, 0, 'execute()', '', true))
    });
    list[5] = Call({
      to: accessManager,
      data: abi.encodeCall(
        IAccessManager.grantRole,
        (ADMIN_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1, 0)
      )
    });
  }

  /// @dev `multiSend` calldata for the Safe to delegatecall into MULTI_SEND_CALL_ONLY.
  function multiSend(address payload) internal pure returns (bytes memory) {
    Call[] memory list = calls(payload);
    bytes memory transactions;
    for (uint256 i; i < list.length; ++i) {
      transactions = abi.encodePacked(
        transactions,
        uint8(0),
        list[i].to,
        uint256(0),
        list[i].data.length,
        list[i].data
      );
    }
    return abi.encodeWithSignature('multiSend(bytes)', transactions);
  }
}
