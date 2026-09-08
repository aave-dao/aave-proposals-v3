// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Sonic, AaveV3SonicAssets} from 'aave-address-book/AaveV3Sonic.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('sonic'), 78180833);
    proposal = new AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3Sonic.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Sonic.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3SonicAssets.WETH_UNDERLYING);
    assertFalse(config.isFrozen, 'WETH_ALREADY_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3SonicAssets.USDC_UNDERLYING);
    assertFalse(config.isFrozen, 'USDC_ALREADY_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3SonicAssets.wS_UNDERLYING);
    assertFalse(config.isFrozen, 'wS_ALREADY_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3SonicAssets.stS_UNDERLYING);
    assertFalse(config.isFrozen, 'stS_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'stS_BORROW_CAP');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](4);
    updatedAssets[0] = AaveV3SonicAssets.USDC_UNDERLYING;
    updatedAssets[1] = AaveV3SonicAssets.wS_UNDERLYING;
    updatedAssets[2] = AaveV3SonicAssets.stS_UNDERLYING;
    updatedAssets[3] = AaveV3SonicAssets.WETH_UNDERLYING;
    reserveConfigChangesTest(AaveV3Sonic.POOL, address(proposal), updatedAssets);
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
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](4);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3SonicAssets.WETH_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3SonicAssets.USDC_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[2] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3SonicAssets.wS_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[3] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3SonicAssets.stS_UNDERLYING,
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
    assets = new address[](4);
    frozen = new bool[](4);

    assets[0] = AaveV3SonicAssets.USDC_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3SonicAssets.wS_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3SonicAssets.stS_UNDERLYING;
    frozen[2] = true;
    assets[3] = AaveV3SonicAssets.WETH_UNDERLYING;
    frozen[3] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory)
  {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate;
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](4);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SonicAssets.USDC_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SonicAssets.wS_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SonicAssets.stS_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[3] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SonicAssets.WETH_UNDERLYING,
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
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](3);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3SonicAssets.USDC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3SonicAssets.wS_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3SonicAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    return borrowUpdates;
  }
}
