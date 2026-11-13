// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {AaveV3BNB} from 'aave-address-book/AaveV3BNB.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';
import {MaintenanceReplaceLayerZeroOnADITestBase} from './MaintenanceReplaceLayerZeroOnADITestBase.sol';
import {MaintenanceReplaceLayerZeroOnADIAddresses as Addresses} from './MaintenanceReplaceLayerZeroOnADIAddresses.sol';

/**
 * @dev Test for the a.DI LayerZero replacement payload on BNB
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/AaveV3BNB_MaintenanceReplaceLayerZeroOnADI_20261111.t.sol -vv
 */
contract AaveV3BNB_MaintenanceReplaceLayerZeroOnADI_20261111_Test is
  MaintenanceReplaceLayerZeroOnADITestBase
{
  function _createFork() internal override {
    vm.createSelectFork(vm.rpcUrl('bnb'), 132849778);
  }

  function _payload() internal pure override returns (address) {
    return Addresses.BNB_PAYLOAD;
  }

  function _POOL() internal pure override returns (IPool) {
    return AaveV3BNB.POOL;
  }

  function _CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3BNB.CROSS_CHAIN_CONTROLLER;
  }

  function _reportName() internal pure override returns (string memory) {
    return 'AaveV3BNB_MaintenanceReplaceLayerZeroOnADI_20261111';
  }

  function _receiverSwaps() internal pure override returns (ReceiverSwap[] memory swaps) {
    swaps = new ReceiverSwap[](1);
    swaps[0] = ReceiverSwap(
      ChainIds.ETHEREUM,
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      Addresses.BNB_LZ_ADAPTER,
      Addresses.BNB_WORMHOLE_EXECUTOR_ADAPTER
    );
  }
}
