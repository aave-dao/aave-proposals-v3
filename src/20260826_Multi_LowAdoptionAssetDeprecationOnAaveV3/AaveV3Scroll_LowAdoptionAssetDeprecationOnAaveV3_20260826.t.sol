// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Scroll, AaveV3ScrollAssets} from 'aave-address-book/AaveV3Scroll.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('scroll'), 34797720);
    proposal = new AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3Scroll.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Scroll.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3ScrollAssets.WETH_UNDERLYING);
    assertTrue(config.isFrozen, 'WETH_NOT_FROZEN');
    assertEq(config.supplyCap, 1, 'WETH_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'WETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3ScrollAssets.USDC_UNDERLYING);
    assertTrue(config.isFrozen, 'USDC_NOT_FROZEN');
    assertEq(config.supplyCap, 1, 'USDC_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'USDC_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3ScrollAssets.wstETH_UNDERLYING);
    assertTrue(config.isFrozen, 'wstETH_NOT_FROZEN');
    assertEq(config.supplyCap, 1, 'wstETH_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'wstETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3ScrollAssets.weETH_UNDERLYING);
    assertTrue(config.isFrozen, 'weETH_NOT_FROZEN');
    assertEq(config.supplyCap, 1, 'weETH_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'weETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3ScrollAssets.SCR_UNDERLYING);
    assertTrue(config.isFrozen, 'SCR_NOT_FROZEN');
    assertEq(config.supplyCap, 1, 'SCR_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'SCR_BORROW_CAP');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](5);
    updatedAssets[0] = AaveV3ScrollAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3ScrollAssets.weETH_UNDERLYING;
    updatedAssets[2] = AaveV3ScrollAssets.wstETH_UNDERLYING;
    updatedAssets[3] = AaveV3ScrollAssets.USDC_UNDERLYING;
    updatedAssets[4] = AaveV3ScrollAssets.SCR_UNDERLYING;
    reserveConfigChangesTest(AaveV3Scroll.POOL, address(proposal), updatedAssets);
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](5);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ScrollAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ScrollAssets.weETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ScrollAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ScrollAssets.USDC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ScrollAssets.SCR_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    return borrowUpdates;
  }
}
