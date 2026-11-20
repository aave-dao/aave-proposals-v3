// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from 'forge-std/Vm.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';
import {IOwnable} from 'aave-address-book/common/IOwnable.sol';
import {IBaseAdapter} from 'aave-address-book/common/IBaseAdapter.sol';
import {ICrossChainForwarder, ICrossChainReceiver} from 'aave-address-book/common/ICrossChainController.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

interface IOptimalBandwidth {
  struct OptimalBandwidthByChain {
    uint256 chainId;
    uint256 optimalBandwidth;
  }

  function getOptimalBandwidthByChain(uint256 chainId) external view returns (uint256);

  function updateOptimalBandwidthByChain(OptimalBandwidthByChain[] memory) external;
}

/**
 * @dev Common base for the per-chain "Replace LayerZero bridge adapter on a.DI" tests. Each chain provides
 *      its fork, payload and the adapter swaps it expects; the assertions live here.
 */
abstract contract MaintenanceReplaceLayerZeroOnADITestBase is ProtocolV3TestBase {
  struct ReceiverSwap {
    uint256 originChainId;
    address originCrossChainController;
    address removedAdapter;
    address addedAdapter;
  }

  struct ForwarderSwap {
    uint256 destinationChainId;
    address removedCurrentAdapter;
    address addedCurrentAdapter;
    address addedDestinationAdapter;
  }

  function _createFork() internal virtual;

  function _payload() internal pure virtual returns (address);

  function _POOL() internal pure virtual returns (IPool);

  function _CROSS_CHAIN_CONTROLLER() internal pure virtual returns (address);

  function _reportName() internal pure virtual returns (string memory);

  function _receiverSwaps() internal pure virtual returns (ReceiverSwap[] memory);

  function _forwarderSwaps() internal pure virtual returns (ForwarderSwap[] memory) {
    return new ForwarderSwap[](0);
  }

  function setUp() public virtual {
    _createFork();
  }

  /// @dev executes the generic test suite including e2e and config snapshots
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(_reportName(), _POOL(), _payload());
  }

  /// @dev LayerZero is swapped for the new adapter; adapter count and required confirmations are unchanged
  function test_receiverSwaps() public {
    ReceiverSwap[] memory swaps = _receiverSwaps();
    uint256[] memory countsBefore = new uint256[](swaps.length);
    uint8[] memory confirmationsBefore = new uint8[](swaps.length);
    for (uint256 i = 0; i < swaps.length; i++) {
      countsBefore[i] = _receiver().getReceiverBridgeAdaptersByChain(swaps[i].originChainId).length;
      confirmationsBefore[i] = _requiredConfirmations(swaps[i].originChainId);
      assertTrue(
        _receiver().isReceiverBridgeAdapterAllowed(swaps[i].removedAdapter, swaps[i].originChainId)
      );
      assertFalse(
        _receiver().isReceiverBridgeAdapterAllowed(swaps[i].addedAdapter, swaps[i].originChainId)
      );
    }

    executePayload(vm, _payload());

    for (uint256 i = 0; i < swaps.length; i++) {
      assertFalse(
        _receiver().isReceiverBridgeAdapterAllowed(swaps[i].removedAdapter, swaps[i].originChainId)
      );
      assertTrue(
        _receiver().isReceiverBridgeAdapterAllowed(swaps[i].addedAdapter, swaps[i].originChainId)
      );
      assertEq(
        _receiver().getReceiverBridgeAdaptersByChain(swaps[i].originChainId).length,
        countsBefore[i]
      );
      assertEq(_requiredConfirmations(swaps[i].originChainId), confirmationsBefore[i]);
    }
  }

  /// @dev the new receiving adapters only accept messages from the origin chain's CrossChainController
  function test_addedAdaptersTrustOriginCrossChainController() public {
    ReceiverSwap[] memory swaps = _receiverSwaps();
    for (uint256 i = 0; i < swaps.length; i++) {
      assertEq(
        IBaseAdapter(swaps[i].addedAdapter).getTrustedRemoteByChainId(swaps[i].originChainId),
        swaps[i].originCrossChainController
      );
      assertEq(
        address(IBaseAdapter(swaps[i].addedAdapter).CROSS_CHAIN_CONTROLLER()),
        _CROSS_CHAIN_CONTROLLER()
      );
    }
  }

  /// @dev LayerZero is swapped for the new adapter pair; adapter count and optimal bandwidth are unchanged
  function test_forwarderSwaps() public {
    ForwarderSwap[] memory swaps = _forwarderSwaps();
    uint256[] memory countsBefore = new uint256[](swaps.length);
    uint256[] memory bandwidthBefore = new uint256[](swaps.length);
    for (uint256 i = 0; i < swaps.length; i++) {
      ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders = _forwarders(
        swaps[i].destinationChainId
      );
      countsBefore[i] = forwarders.length;
      bandwidthBefore[i] = _bandwidth(swaps[i].destinationChainId);
      assertTrue(_hasCurrentAdapter(forwarders, swaps[i].removedCurrentAdapter));
    }

    executePayload(vm, _payload());

    for (uint256 i = 0; i < swaps.length; i++) {
      ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders = _forwarders(
        swaps[i].destinationChainId
      );
      assertFalse(_hasCurrentAdapter(forwarders, swaps[i].removedCurrentAdapter));
      assertTrue(
        _hasPair(forwarders, swaps[i].addedCurrentAdapter, swaps[i].addedDestinationAdapter)
      );
      assertEq(forwarders.length, countsBefore[i]);
      assertEq(_bandwidth(swaps[i].destinationChainId), bandwidthBefore[i]);
    }
  }

  /// @dev after execution, a message sent through every adapter of each path succeeds, the new one included
  function test_forwardThroughAllAdapters() public {
    ForwarderSwap[] memory swaps = _forwarderSwaps();
    executePayload(vm, _payload());

    address owner = IOwnable(_CROSS_CHAIN_CONTROLLER()).owner();
    address[] memory senders = new address[](1);
    senders[0] = address(this);
    vm.prank(owner);
    _forwarder().approveSenders(senders);

    for (uint256 i = 0; i < swaps.length; i++) {
      // bandwidth 0 sends through every adapter, so the new one is always used
      IOptimalBandwidth.OptimalBandwidthByChain[]
        memory bandwidth = new IOptimalBandwidth.OptimalBandwidthByChain[](1);
      bandwidth[0] = IOptimalBandwidth.OptimalBandwidthByChain(swaps[i].destinationChainId, 0);
      vm.prank(owner);
      IOptimalBandwidth(_CROSS_CHAIN_CONTROLLER()).updateOptimalBandwidthByChain(bandwidth);

      vm.recordLogs();
      _forwarder().forwardMessage(
        swaps[i].destinationChainId,
        address(this),
        300_000,
        abi.encode('replace layerzero')
      );
      _assertAllForwardingSucceeded(
        vm.getRecordedLogs(),
        _forwarders(swaps[i].destinationChainId).length,
        swaps[i].addedCurrentAdapter
      );
    }
  }

  function _assertAllForwardingSucceeded(
    Vm.Log[] memory logs,
    uint256 expectedAttempts,
    address expectedAdapter
  ) internal pure {
    bytes32 topic = ICrossChainForwarder.TransactionForwardingAttempted.selector;
    uint256 attempts;
    bool expectedAdapterUsed;
    for (uint256 i = 0; i < logs.length; i++) {
      if (logs[i].topics.length == 0 || logs[i].topics[0] != topic) continue;
      attempts++;
      assertEq(uint256(logs[i].topics[3]), 1, 'bridge adapter forwarding failed');
      if (address(uint160(uint256(logs[i].topics[2]))) == expectedAdapter) {
        expectedAdapterUsed = true;
      }
    }
    assertEq(attempts, expectedAttempts);
    assertTrue(expectedAdapterUsed, 'new adapter not used');
  }

  function _receiver() internal pure returns (ICrossChainReceiver) {
    return ICrossChainReceiver(_CROSS_CHAIN_CONTROLLER());
  }

  function _forwarder() internal pure returns (ICrossChainForwarder) {
    return ICrossChainForwarder(_CROSS_CHAIN_CONTROLLER());
  }

  function _requiredConfirmations(uint256 chainId) internal view returns (uint8) {
    return _receiver().getConfigurationByChain(chainId).requiredConfirmation;
  }

  function _forwarders(
    uint256 chainId
  ) internal view returns (ICrossChainForwarder.ChainIdBridgeConfig[] memory) {
    return _forwarder().getForwarderBridgeAdaptersByChain(chainId);
  }

  function _bandwidth(uint256 chainId) internal view returns (uint256) {
    return IOptimalBandwidth(_CROSS_CHAIN_CONTROLLER()).getOptimalBandwidthByChain(chainId);
  }

  function _hasCurrentAdapter(
    ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders,
    address adapter
  ) internal pure returns (bool) {
    for (uint256 i = 0; i < forwarders.length; i++) {
      if (forwarders[i].currentChainBridgeAdapter == adapter) return true;
    }
    return false;
  }

  function _hasPair(
    ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders,
    address currentAdapter,
    address destinationAdapter
  ) internal pure returns (bool) {
    for (uint256 i = 0; i < forwarders.length; i++) {
      if (
        forwarders[i].currentChainBridgeAdapter == currentAdapter &&
        forwarders[i].destinationBridgeAdapter == destinationAdapter
      ) return true;
    }
    return false;
  }
}
