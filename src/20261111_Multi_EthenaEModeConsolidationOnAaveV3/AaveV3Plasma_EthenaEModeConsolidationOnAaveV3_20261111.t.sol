// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Plasma, AaveV3PlasmaEModes, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Test for AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111.t.sol -vv
 */
contract AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111_Test is ProtocolV3TestBase {
  AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 37486717);
    proposal = new AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111',
      AaveV3Plasma.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Plasma.POOL, address(proposal), updatedAssets);
  }

  function test_eModeUpdatesConfiguration() public {
    DataTypes.CollateralConfig memory before_0 = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      AaveV3PlasmaEModes.USDe__USDT0
    );
    bool beforeIsolated_0 = AaveV3Plasma.POOL.getIsEModeCategoryIsolated(
      AaveV3PlasmaEModes.USDe__USDT0
    );
    DataTypes.CollateralConfig memory before_1 = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO
    );
    bool beforeIsolated_1 = AaveV3Plasma.POOL.getIsEModeCategoryIsolated(
      AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO
    );
    DataTypes.CollateralConfig memory before_2 = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO
    );
    bool beforeIsolated_2 = AaveV3Plasma.POOL.getIsEModeCategoryIsolated(
      AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    DataTypes.CollateralConfig memory cfg_0 = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      AaveV3PlasmaEModes.USDe__USDT0
    );
    assertEq(cfg_0.ltv, 91_00);
    assertEq(cfg_0.liquidationThreshold, 93_00);
    assertEq(cfg_0.liquidationBonus, before_0.liquidationBonus);
    assertEq(
      AaveV3Plasma.POOL.getIsEModeCategoryIsolated(AaveV3PlasmaEModes.USDe__USDT0),
      beforeIsolated_0
    );

    DataTypes.CollateralConfig memory cfg_1 = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO
    );
    assertEq(cfg_1.ltv, before_1.ltv);
    assertEq(cfg_1.liquidationThreshold, 93_00);
    assertEq(cfg_1.liquidationBonus, before_1.liquidationBonus);
    assertEq(
      AaveV3Plasma.POOL.getIsEModeCategoryIsolated(
        AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO
      ),
      beforeIsolated_1
    );

    DataTypes.CollateralConfig memory cfg_2 = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO
    );
    assertEq(cfg_2.ltv, 90_00);
    assertEq(cfg_2.liquidationThreshold, 92_00);
    assertEq(cfg_2.liquidationBonus, before_2.liquidationBonus);
    assertEq(
      AaveV3Plasma.POOL.getIsEModeCategoryIsolated(
        AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO
      ),
      beforeIsolated_2
    );
  }

  function test_ltvzeroFlags() public {
    address[] memory assets = new address[](12);
    uint8[] memory eModes = new uint8[](12);
    assets[0] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    eModes[0] = AaveV3PlasmaEModes.USDe_PT_USDe_15JAN2026_PT_USDe_9APR2026__USDT0_USDe_GHO;
    assets[1] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    eModes[1] = AaveV3PlasmaEModes.USDe_PT_USDe_15JAN2026_PT_USDe_9APR2026__USDe;
    assets[2] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    eModes[2] = AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDT0_USDe_GHO;
    assets[3] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    eModes[3] = AaveV3PlasmaEModes.USDe_PT_USDe_9APR2026_PT_USDe_18JUN2026__USDe;
    assets[4] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    eModes[4] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_15JAN2026_PT_sUSDE_9APR2026__USDT0_USDe_GHO;
    assets[5] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    eModes[5] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_15JAN2026_PT_sUSDE_9APR2026__USDe;
    assets[6] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    eModes[6] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDT0_USDe_GHO;
    assets[7] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    eModes[7] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_9APR2026_PT_sUSDE_18JUN2026__USDe;
    assets[8] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    eModes[8] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO;
    assets[9] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    eModes[9] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe;
    assets[10] = AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING;
    eModes[10] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO;
    assets[11] = AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING;
    eModes[11] = AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe;

    uint128[] memory collateralBefore = new uint128[](12);
    uint128[] memory borrowableBefore = new uint128[](12);
    for (uint256 i = 0; i < 12; i++) {
      uint128 bit = uint128(1) << AaveV3Plasma.POOL.getReserveData(assets[i]).id;
      collateralBefore[i] = AaveV3Plasma.POOL.getEModeCategoryCollateralBitmap(eModes[i]);
      borrowableBefore[i] = AaveV3Plasma.POOL.getEModeCategoryBorrowableBitmap(eModes[i]);
      assertTrue(collateralBefore[i] & bit != 0, 'asset is not collateral in eMode');
      assertEq(
        AaveV3Plasma.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit,
        0,
        'ltvzero already set'
      );
    }

    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < 12; i++) {
      uint128 bit = uint128(1) << AaveV3Plasma.POOL.getReserveData(assets[i]).id;
      assertTrue(
        AaveV3Plasma.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit != 0,
        'ltvzero not set'
      );
      assertEq(
        AaveV3Plasma.POOL.getEModeCategoryCollateralBitmap(eModes[i]),
        collateralBefore[i],
        'collateral bitmap changed'
      );
      assertEq(
        AaveV3Plasma.POOL.getEModeCategoryBorrowableBitmap(eModes[i]),
        borrowableBefore[i],
        'borrowable bitmap changed'
      );
    }
  }
}
