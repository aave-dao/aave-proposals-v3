// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Base, AaveV3BaseAssets, AaveV3BaseEModes} from 'aave-address-book/AaveV3Base.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Base_ETHAndBTCCollateralEfficiency_20261016} from './AaveV3Base_ETHAndBTCCollateralEfficiency_20261016.sol';

/**
 * @dev Test for AaveV3Base_ETHAndBTCCollateralEfficiency_20261016
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Base_ETHAndBTCCollateralEfficiency_20261016.t.sol -vv
 */
contract AaveV3Base_ETHAndBTCCollateralEfficiency_20261016_Test is ProtocolV3TestBase {
  AaveV3Base_ETHAndBTCCollateralEfficiency_20261016 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 52680008);
    proposal = new AaveV3Base_ETHAndBTCCollateralEfficiency_20261016();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Base_ETHAndBTCCollateralEfficiency_20261016',
      AaveV3Base.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations stay unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](2);
    updatedAssets[0] = AaveV3BaseAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3BaseAssets.cbBTC_UNDERLYING;
    reserveConfigChangesTest(AaveV3Base.POOL, address(proposal), updatedAssets);
  }

  function test_eModeUpdatesConfiguration() public {
    uint8 categoryId = AaveV3BaseEModes.cbBTC__USDC_GHO;
    uint128 collateralBitmap = AaveV3Base.POOL.getEModeCategoryCollateralBitmap(categoryId);
    uint128 borrowableBitmap = AaveV3Base.POOL.getEModeCategoryBorrowableBitmap(categoryId);
    uint128 ltvzeroBitmap = AaveV3Base.POOL.getEModeCategoryLtvzeroBitmap(categoryId);
    string memory label = AaveV3Base.POOL.getEModeCategoryLabel(categoryId);
    DataTypes.CollateralConfig memory before_0 = AaveV3Base.POOL.getEModeCategoryCollateralConfig(
      AaveV3BaseEModes.cbBTC__USDC_GHO
    );
    assertEq(before_0.ltv, 80_00);
    assertEq(before_0.liquidationThreshold, 83_00);
    assertEq(before_0.liquidationBonus, 104_00);
    assertEq(collateralBitmap, 64);
    assertEq(borrowableBitmap, 272);
    assertEq(label, 'cbBTC Stablecoins');
    bool beforeIsolated_0 = AaveV3Base.POOL.getIsEModeCategoryIsolated(
      AaveV3BaseEModes.cbBTC__USDC_GHO
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    DataTypes.CollateralConfig memory cfg_0 = AaveV3Base.POOL.getEModeCategoryCollateralConfig(
      AaveV3BaseEModes.cbBTC__USDC_GHO
    );
    assertEq(AaveV3Base.POOL.getEModeCategoryCollateralBitmap(categoryId), collateralBitmap);
    assertEq(AaveV3Base.POOL.getEModeCategoryBorrowableBitmap(categoryId), borrowableBitmap);
    assertEq(AaveV3Base.POOL.getEModeCategoryLtvzeroBitmap(categoryId), ltvzeroBitmap);
    assertEq(AaveV3Base.POOL.getEModeCategoryLabel(categoryId), label);
    assertEq(cfg_0.ltv, 82_00);
    assertEq(cfg_0.liquidationThreshold, 85_00);
    assertEq(cfg_0.liquidationBonus, before_0.liquidationBonus);
    assertEq(
      AaveV3Base.POOL.getIsEModeCategoryIsolated(AaveV3BaseEModes.cbBTC__USDC_GHO),
      beforeIsolated_0
    );
  }

  function test_preProposalCollateralConfig() public view {
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Base.POOL);
    ReserveConfig memory WETHConfig = _findReserveConfig(configs, AaveV3BaseAssets.WETH_UNDERLYING);
    assertEq(WETHConfig.ltv, 80_00);
    assertEq(WETHConfig.liquidationThreshold, 83_00);
    assertEq(WETHConfig.liquidationBonus, 105_00);
    assertEq(WETHConfig.liquidationProtocolFee, 10_00);
    ReserveConfig memory cbBTCConfig = _findReserveConfig(
      configs,
      AaveV3BaseAssets.cbBTC_UNDERLYING
    );
    assertEq(cbBTCConfig.ltv, 73_00);
    assertEq(cbBTCConfig.liquidationThreshold, 78_00);
    assertEq(cbBTCConfig.liquidationBonus, 107_50);
    assertEq(cbBTCConfig.liquidationProtocolFee, 10_00);
  }

  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[] memory collateralUpdate;
    collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](2);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.WETH_UNDERLYING,
      ltv: 81_00,
      liqThreshold: 84_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.cbBTC_UNDERLYING,
      ltv: 81_00,
      liqThreshold: 84_00,
      liqBonus: 6_00,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }
}
