// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';
import {ICrossChainForwarder} from 'aave-address-book/common/ICrossChainController.sol';
import {MaintenanceReplaceLayerZeroOnADITestBase} from './MaintenanceReplaceLayerZeroOnADITestBase.sol';
import {MaintenanceReplaceLayerZeroOnADIAddresses as Addresses} from './MaintenanceReplaceLayerZeroOnADIAddresses.sol';

/**
 * @dev Test for the a.DI LayerZero replacement payload on Ethereum
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3Ethereum_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol -vv
 */
contract AaveV3Ethereum_MaintenanceReplaceLayerZeroOnADI_20261111_Test is
  MaintenanceReplaceLayerZeroOnADITestBase
{
  function _createFork() internal override {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26387256);
  }

  function _payload() internal pure override returns (address) {
    return Addresses.ETHEREUM_PAYLOAD;
  }

  function _POOL() internal pure override returns (IPool) {
    return AaveV3Ethereum.POOL;
  }

  function _CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER;
  }

  function _reportName() internal pure override returns (string memory) {
    return 'AaveV3Ethereum_MaintenanceReplaceLayerZeroOnADI_20261111';
  }

  function _receiverSwaps() internal pure override returns (ReceiverSwap[] memory swaps) {
    swaps = new ReceiverSwap[](2);
    swaps[0] = ReceiverSwap(
      ChainIds.POLYGON,
      GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
      Addresses.ETHEREUM_LZ_ADAPTER,
      Addresses.ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER
    );
    swaps[1] = ReceiverSwap(
      ChainIds.AVALANCHE,
      GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER,
      Addresses.ETHEREUM_LZ_ADAPTER,
      Addresses.ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER
    );
  }

  function _forwarderSwaps() internal pure override returns (ForwarderSwap[] memory swaps) {
    swaps = new ForwarderSwap[](5);
    swaps[0] = ForwarderSwap(
      ChainIds.POLYGON,
      Addresses.ETHEREUM_LZ_ADAPTER,
      Addresses.ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER,
      Addresses.POLYGON_WORMHOLE_EXECUTOR_ADAPTER
    );
    swaps[1] = ForwarderSwap(
      ChainIds.AVALANCHE,
      Addresses.ETHEREUM_LZ_ADAPTER,
      Addresses.ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER,
      Addresses.AVALANCHE_WORMHOLE_EXECUTOR_ADAPTER
    );
    swaps[2] = ForwarderSwap(
      ChainIds.BNB,
      Addresses.ETHEREUM_LZ_ADAPTER,
      Addresses.ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER,
      Addresses.BNB_WORMHOLE_EXECUTOR_ADAPTER
    );
    swaps[3] = ForwarderSwap(
      ChainIds.MONAD,
      Addresses.ETHEREUM_MONAD_LZ_ADAPTER,
      Addresses.ETHEREUM_WORMHOLE_EXECUTOR_ADAPTER,
      Addresses.MONAD_WORMHOLE_EXECUTOR_ADAPTER
    );
    swaps[4] = ForwarderSwap(
      ChainIds.GNOSIS,
      Addresses.ETHEREUM_LZ_ADAPTER,
      Addresses.ETHEREUM_GNOSIS_CCIP_ADAPTER,
      Addresses.GNOSIS_CCIP_ADAPTER
    );
  }

  /// @dev Celo keeps the shared LayerZero adapter
  function test_celoPathUntouched() public {
    ICrossChainForwarder.ChainIdBridgeConfig[] memory before = _forwarders(ChainIds.CELO);
    uint256 bandwidthBefore = _bandwidth(ChainIds.CELO);
    assertTrue(_hasCurrentAdapter(before, Addresses.ETHEREUM_LZ_ADAPTER));

    executePayload(vm, _payload());

    assertEq(abi.encode(_forwarders(ChainIds.CELO)), abi.encode(before));
    assertEq(_bandwidth(ChainIds.CELO), bandwidthBefore);
  }
}
