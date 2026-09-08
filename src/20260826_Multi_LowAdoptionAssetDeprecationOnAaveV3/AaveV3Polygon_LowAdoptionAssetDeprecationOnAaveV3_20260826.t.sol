// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 92679000);
    proposal = new AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3Polygon.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Polygon.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.USDC_UNDERLYING);
    assertFalse(config.isFrozen, 'USDC_ALREADY_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.EURS_UNDERLYING);
    assertFalse(config.isFrozen, 'EURS_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'EURS_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'EURS_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.MaticX_UNDERLYING);
    assertFalse(config.isFrozen, 'MaticX_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'MaticX_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.jEUR_UNDERLYING);
    assertTrue(config.isFrozen, 'jEUR_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.stMATIC_UNDERLYING);
    assertTrue(config.isFrozen, 'stMATIC_NOT_FROZEN');
    assertEq(config.borrowCap, 0, 'stMATIC_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.EURA_UNDERLYING);
    assertTrue(config.isFrozen, 'EURA_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.DPI_UNDERLYING);
    assertTrue(config.isFrozen, 'DPI_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.SUSHI_UNDERLYING);
    assertTrue(config.isFrozen, 'SUSHI_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3PolygonAssets.CRV_UNDERLYING);
    assertTrue(config.isFrozen, 'CRV_NOT_FROZEN');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](9);
    updatedAssets[0] = AaveV3PolygonAssets.USDC_UNDERLYING;
    updatedAssets[1] = AaveV3PolygonAssets.EURS_UNDERLYING;
    updatedAssets[2] = AaveV3PolygonAssets.MaticX_UNDERLYING;
    updatedAssets[3] = AaveV3PolygonAssets.jEUR_UNDERLYING;
    updatedAssets[4] = AaveV3PolygonAssets.stMATIC_UNDERLYING;
    updatedAssets[5] = AaveV3PolygonAssets.EURA_UNDERLYING;
    updatedAssets[6] = AaveV3PolygonAssets.DPI_UNDERLYING;
    updatedAssets[7] = AaveV3PolygonAssets.SUSHI_UNDERLYING;
    updatedAssets[8] = AaveV3PolygonAssets.CRV_UNDERLYING;
    reserveConfigChangesTest(AaveV3Polygon.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](3);
    frozen = new bool[](3);

    assets[0] = AaveV3PolygonAssets.USDC_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3PolygonAssets.EURS_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3PolygonAssets.MaticX_UNDERLYING;
    frozen[2] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory)
  {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate;
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](8);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.USDC_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.MaticX_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.jEUR_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[3] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.stMATIC_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[4] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.EURA_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[5] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.DPI_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[6] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.SUSHI_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[7] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3PolygonAssets.CRV_UNDERLYING,
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
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](7);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.USDC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 85_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.MaticX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.jEUR_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.EURA_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.DPI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.SUSHI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.CRV_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    return borrowUpdates;
  }
}
