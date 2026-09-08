// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ZkSync, AaveV3ZkSyncAssets} from 'aave-address-book/AaveV3ZkSync.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/zksync/src/ProtocolV3TestBase.sol';
import {AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=zksync forge test --zksync --match-path=zksync/src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public override {
    vm.createSelectFork(vm.rpcUrl('zksync'), 71724909);
    proposal = new AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826();

    super.setUp();
  }

  /**
   * @dev executes the generic test suite including config snapshots; the e2e suite is
   * skipped as every reserve on the instance is frozen, so no usable collateral exists
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3ZkSync.POOL,
      address(proposal),
      false,
      false
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: every reserve in
   * scope is already frozen with a borrow cap of 1, which is why the payload only reduces
   * supply caps and adjusts RF/IRM
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3ZkSync.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.WETH_UNDERLYING);
    assertTrue(config.isFrozen, 'WETH_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'WETH_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.weETH_UNDERLYING);
    assertTrue(config.isFrozen, 'weETH_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'weETH_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.wstETH_UNDERLYING);
    assertTrue(config.isFrozen, 'wstETH_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'wstETH_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.ZK_UNDERLYING);
    assertTrue(config.isFrozen, 'ZK_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'ZK_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.USDC_UNDERLYING);
    assertTrue(config.isFrozen, 'USDC_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'USDC_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.USDT_UNDERLYING);
    assertTrue(config.isFrozen, 'USDT_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'USDT_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3ZkSyncAssets.sUSDe_UNDERLYING);
    assertTrue(config.isFrozen, 'sUSDe_NOT_FROZEN');
    assertEq(config.borrowCap, 1, 'sUSDe_BORROW_CAP_NOT_1');
  }
}
