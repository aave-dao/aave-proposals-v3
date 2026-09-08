// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3BNB, AaveV3BNBAssets} from 'aave-address-book/AaveV3BNB.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('bnb'), 118138918);
    proposal = new AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3BNB.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3BNB.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3BNBAssets.wstETH_UNDERLYING);
    assertFalse(config.isFrozen, 'wstETH_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'wstETH_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'wstETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3BNBAssets.FDUSD_UNDERLYING);
    assertFalse(config.isFrozen, 'FDUSD_ALREADY_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3BNBAssets.Cake_UNDERLYING);
    assertFalse(config.isFrozen, 'Cake_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'Cake_BORROW_CAP');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](3);
    updatedAssets[0] = AaveV3BNBAssets.wstETH_UNDERLYING;
    updatedAssets[1] = AaveV3BNBAssets.FDUSD_UNDERLYING;
    updatedAssets[2] = AaveV3BNBAssets.Cake_UNDERLYING;
    reserveConfigChangesTest(AaveV3BNB.POOL, address(proposal), updatedAssets);
  }

  /**
   * @dev on v3.7 freezing a reserve also sets its LTV to 0 (the previous LTV is parked in
   * pendingLtv), which the generic freeze modeling of the test base does not cover; the
   * reserves below are the ones in scope with a non-zero LTV
   */
  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[]
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](1);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BNBAssets.wstETH_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](3);
    frozen = new bool[](3);

    assets[0] = AaveV3BNBAssets.wstETH_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3BNBAssets.FDUSD_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3BNBAssets.Cake_UNDERLYING;
    frozen[2] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory)
  {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate;
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](2);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3BNBAssets.FDUSD_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3BNBAssets.Cake_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    return capsUpdate;
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](3);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BNBAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BNBAssets.FDUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3BNBAssets.Cake_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    return borrowUpdates;
  }
}
