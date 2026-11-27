// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Avalanche, AaveV3AvalancheEModes, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Test for AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111.t.sol -vv
 */
contract AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111_Test is ProtocolV3TestBase {
  AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 100053881);
    proposal = new AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Avalanche.POOL, address(proposal), updatedAssets);
  }

  function test_eModeUpdatesConfiguration() public {
    DataTypes.CollateralConfig memory before_0 = AaveV3Avalanche
      .POOL
      .getEModeCategoryCollateralConfig(AaveV3AvalancheEModes.USDe__USDC_USDt_GHO);
    bool beforeIsolated_0 = AaveV3Avalanche.POOL.getIsEModeCategoryIsolated(
      AaveV3AvalancheEModes.USDe__USDC_USDt_GHO
    );
    DataTypes.CollateralConfig memory before_1 = AaveV3Avalanche
      .POOL
      .getEModeCategoryCollateralConfig(AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe);
    bool beforeIsolated_1 = AaveV3Avalanche.POOL.getIsEModeCategoryIsolated(
      AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    DataTypes.CollateralConfig memory cfg_0 = AaveV3Avalanche.POOL.getEModeCategoryCollateralConfig(
      AaveV3AvalancheEModes.USDe__USDC_USDt_GHO
    );
    assertEq(cfg_0.ltv, 91_00);
    assertEq(cfg_0.liquidationThreshold, 93_00);
    assertEq(cfg_0.liquidationBonus, before_0.liquidationBonus);
    assertEq(
      AaveV3Avalanche.POOL.getIsEModeCategoryIsolated(AaveV3AvalancheEModes.USDe__USDC_USDt_GHO),
      beforeIsolated_0
    );

    DataTypes.CollateralConfig memory cfg_1 = AaveV3Avalanche.POOL.getEModeCategoryCollateralConfig(
      AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe
    );
    assertEq(cfg_1.ltv, 90_00);
    assertEq(cfg_1.liquidationThreshold, 92_00);
    assertEq(cfg_1.liquidationBonus, before_1.liquidationBonus);
    assertEq(
      AaveV3Avalanche.POOL.getIsEModeCategoryIsolated(
        AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe
      ),
      beforeIsolated_1
    );
  }

  function test_USDeNotBorrowableInSUSDeEMode() public {
    uint8 eModeId = AaveV3AvalancheEModes.sUSDe__USDC_USDt_GHO_USDe;
    uint128 usdeBit = uint128(1) <<
      AaveV3Avalanche.POOL.getReserveData(AaveV3AvalancheAssets.USDe_UNDERLYING).id;
    uint128 borrowableBefore = AaveV3Avalanche.POOL.getEModeCategoryBorrowableBitmap(eModeId);
    uint128 collateralBefore = AaveV3Avalanche.POOL.getEModeCategoryCollateralBitmap(eModeId);
    assertTrue(borrowableBefore & usdeBit != 0, 'USDe is not borrowable before');

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(
      AaveV3Avalanche.POOL.getEModeCategoryBorrowableBitmap(eModeId),
      borrowableBefore & ~usdeBit
    );
    assertEq(AaveV3Avalanche.POOL.getEModeCategoryCollateralBitmap(eModeId), collateralBefore);
  }
}
