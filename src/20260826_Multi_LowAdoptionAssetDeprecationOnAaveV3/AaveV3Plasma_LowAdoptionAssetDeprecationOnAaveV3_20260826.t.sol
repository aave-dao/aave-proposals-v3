// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 30782965);
    proposal = new AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3Plasma.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Plasma.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.WETH_UNDERLYING);
    assertFalse(config.isFrozen, 'WETH_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'WETH_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'WETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.weETH_UNDERLYING);
    assertFalse(config.isFrozen, 'weETH_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'weETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.wstETH_UNDERLYING);
    assertTrue(config.isFrozen, 'wstETH_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.PT_USDe_15JAN2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_15JAN2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_15JAN2026_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'PT_USDe_15JAN2026_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_15JAN2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_15JAN2026_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_15JAN2026_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.PT_sUSDE_9APR2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_9APR2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_9APR2026_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_9APR2026_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.PT_USDe_9APR2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_9APR2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_9APR2026_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'PT_USDe_9APR2026_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.PT_USDe_18JUN2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_18JUN2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_18JUN2026_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'PT_USDe_18JUN2026_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_18JUN2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_18JUN2026_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_18JUN2026_BORROW_CAP');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](9);
    updatedAssets[0] = AaveV3PlasmaAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3PlasmaAssets.weETH_UNDERLYING;
    updatedAssets[2] = AaveV3PlasmaAssets.PT_USDe_15JAN2026_UNDERLYING;
    updatedAssets[3] = AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_UNDERLYING;
    updatedAssets[4] = AaveV3PlasmaAssets.PT_sUSDE_9APR2026_UNDERLYING;
    updatedAssets[5] = AaveV3PlasmaAssets.PT_USDe_9APR2026_UNDERLYING;
    updatedAssets[6] = AaveV3PlasmaAssets.PT_USDe_18JUN2026_UNDERLYING;
    updatedAssets[7] = AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_UNDERLYING;
    updatedAssets[8] = AaveV3PlasmaAssets.wstETH_UNDERLYING;
    reserveConfigChangesTest(AaveV3Plasma.POOL, address(proposal), updatedAssets);
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
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](5);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3PlasmaAssets.WETH_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3PlasmaAssets.PT_USDe_15JAN2026_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[2] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[3] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3PlasmaAssets.PT_sUSDE_9APR2026_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[4] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3PlasmaAssets.PT_USDe_9APR2026_UNDERLYING,
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
    assets = new address[](8);
    frozen = new bool[](8);

    assets[0] = AaveV3PlasmaAssets.WETH_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3PlasmaAssets.weETH_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3PlasmaAssets.PT_USDe_15JAN2026_UNDERLYING;
    frozen[2] = true;
    assets[3] = AaveV3PlasmaAssets.PT_sUSDE_15JAN2026_UNDERLYING;
    frozen[3] = true;
    assets[4] = AaveV3PlasmaAssets.PT_sUSDE_9APR2026_UNDERLYING;
    frozen[4] = true;
    assets[5] = AaveV3PlasmaAssets.PT_USDe_9APR2026_UNDERLYING;
    frozen[5] = true;
    assets[6] = AaveV3PlasmaAssets.PT_USDe_18JUN2026_UNDERLYING;
    frozen[6] = true;
    assets[7] = AaveV3PlasmaAssets.PT_sUSDE_18JUN2026_UNDERLYING;
    frozen[7] = true;
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
      asset: AaveV3PlasmaAssets.weETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PlasmaAssets.wstETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
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
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](2);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PlasmaAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PlasmaAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    return borrowUpdates;
  }
}
