// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3XLayer, AaveV3XLayerAssets, AaveV3XLayerEModes} from 'aave-address-book/AaveV3XLayer.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Test for AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111.t.sol -vv
 */
contract AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111_Test is ProtocolV3TestBase {
  AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('xlayer'), 75661061);
    proposal = new AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111',
      AaveV3XLayer.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3XLayer.POOL, address(proposal), updatedAssets);
  }

  function test_ltvzeroFlags() public {
    address[] memory assets = new address[](2);
    uint8[] memory eModes = new uint8[](2);
    assets[0] = AaveV3XLayerAssets.PT_USDG_29OCT2026_UNDERLYING;
    eModes[0] = AaveV3XLayerEModes.PT_USDG_29OCT2026__USDT_USDG_GHO_USDC;
    assets[1] = AaveV3XLayerAssets.PT_USDG_29OCT2026_UNDERLYING;
    eModes[1] = AaveV3XLayerEModes.PT_USDG_29OCT2026__USDG;

    uint128[] memory collateralBefore = new uint128[](2);
    uint128[] memory borrowableBefore = new uint128[](2);
    for (uint256 i = 0; i < 2; i++) {
      uint128 bit = uint128(1) << AaveV3XLayer.POOL.getReserveData(assets[i]).id;
      collateralBefore[i] = AaveV3XLayer.POOL.getEModeCategoryCollateralBitmap(eModes[i]);
      borrowableBefore[i] = AaveV3XLayer.POOL.getEModeCategoryBorrowableBitmap(eModes[i]);
      assertTrue(collateralBefore[i] & bit != 0, 'asset is not collateral in eMode');
      assertEq(
        AaveV3XLayer.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit,
        0,
        'ltvzero already set'
      );
    }

    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < 2; i++) {
      uint128 bit = uint128(1) << AaveV3XLayer.POOL.getReserveData(assets[i]).id;
      assertTrue(
        AaveV3XLayer.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit != 0,
        'ltvzero not set'
      );
      assertEq(
        AaveV3XLayer.POOL.getEModeCategoryCollateralBitmap(eModes[i]),
        collateralBefore[i],
        'collateral bitmap changed'
      );
      assertEq(
        AaveV3XLayer.POOL.getEModeCategoryBorrowableBitmap(eModes[i]),
        borrowableBefore[i],
        'borrowable bitmap changed'
      );
    }
  }
}
