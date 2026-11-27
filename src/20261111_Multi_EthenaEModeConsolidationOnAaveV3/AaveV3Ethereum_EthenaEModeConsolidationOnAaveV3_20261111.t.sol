// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Ethereum, AaveV3EthereumEModes, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Test for AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111.t.sol -vv
 */
contract AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111_Test is ProtocolV3TestBase {
  AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26394174);
    proposal = new AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function test_eModeUpdatesConfiguration() public {
    DataTypes.CollateralConfig memory before_0 = AaveV3Ethereum
      .POOL
      .getEModeCategoryCollateralConfig(AaveV3EthereumEModes.USDe__USDC_USDT);
    bool beforeIsolated_0 = AaveV3Ethereum.POOL.getIsEModeCategoryIsolated(
      AaveV3EthereumEModes.USDe__USDC_USDT
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    DataTypes.CollateralConfig memory cfg_0 = AaveV3Ethereum.POOL.getEModeCategoryCollateralConfig(
      AaveV3EthereumEModes.USDe__USDC_USDT
    );
    assertEq(cfg_0.ltv, 91_00);
    assertEq(cfg_0.liquidationThreshold, 93_00);
    assertEq(cfg_0.liquidationBonus, before_0.liquidationBonus);
    assertEq(
      AaveV3Ethereum.POOL.getIsEModeCategoryIsolated(AaveV3EthereumEModes.USDe__USDC_USDT),
      beforeIsolated_0
    );
  }

  function test_ltvzeroFlags() public {
    address[] memory assets = new address[](23);
    uint8[] memory eModes = new uint8[](23);
    assets[0] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[0] = AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025__USDC_USDT;
    assets[1] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[1] = AaveV3EthereumEModes.USDe_PT_USDe_31JUL2025__USDe;
    assets[2] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[2] = 19;
    assets[3] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[3] = AaveV3EthereumEModes
      .USDe_PT_USDe_31JUL2025_PT_eUSDE_14AUG2025_PT_USDe_25SEP2025__USDe;
    assets[4] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[4] = AaveV3EthereumEModes.USDe_PT_USDe_27NOV2025_PT_USDe_5FEB2026__USDC_USDT_USDe_USDtb;
    assets[5] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[5] = AaveV3EthereumEModes.USDe_PT_USDe_27NOV2025_PT_USDe_5FEB2026__USDe;
    assets[6] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[6] = AaveV3EthereumEModes.USDe_PT_USDe_5FEB2026_PT_USDe_7MAY2026__USDC_USDT_USDe_USDtb;
    assets[7] = AaveV3EthereumAssets.USDe_UNDERLYING;
    eModes[7] = AaveV3EthereumEModes.USDe_PT_USDe_5FEB2026_PT_USDe_7MAY2026__USDe;
    assets[8] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[8] = AaveV3EthereumEModes.sUSDe_PT_sUSDE_31JUL2025__USDC_USDT;
    assets[9] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[9] = AaveV3EthereumEModes
      .sUSDe_PT_sUSDE_31JUL2025_PT_sUSDE_25SEP2025__USDC_USDT_USDe_USDtb;
    assets[10] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[10] = AaveV3EthereumEModes
      .sUSDe_PT_sUSDE_25SEP2025_PT_sUSDE_27NOV2025__USDC_USDT_USDe_USDtb;
    assets[11] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[11] = AaveV3EthereumEModes
      .sUSDe_PT_sUSDE_27NOV2025_PT_sUSDE_5FEB2026__USDC_USDT_USDe_USDtb;
    assets[12] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[12] = AaveV3EthereumEModes.sUSDe_PT_sUSDE_27NOV2025_PT_sUSDE_5FEB2026__USDe;
    assets[13] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[13] = AaveV3EthereumEModes
      .sUSDe_PT_sUSDE_5FEB2026_PT_sUSDE_7MAY2026__USDC_USDT_USDe_USDtb;
    assets[14] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[14] = AaveV3EthereumEModes.sUSDe_PT_sUSDE_5FEB2026_PT_sUSDE_7MAY2026__USDe;
    assets[15] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[15] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026__USDC_USDT_USDe;
    assets[16] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[16] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026__USDe;
    assets[17] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[17] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026_PT_srUSDe_25JUN2026__USDC_USDT_USDe;
    assets[18] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[18] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_2APR2026_PT_srUSDe_25JUN2026__USDe;
    assets[19] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[19] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe;
    assets[20] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    eModes[20] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe;
    assets[21] = AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING;
    eModes[21] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe;
    assets[22] = AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING;
    eModes[22] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe;

    uint128[] memory collateralBefore = new uint128[](23);
    uint128[] memory borrowableBefore = new uint128[](23);
    for (uint256 i = 0; i < 23; i++) {
      uint128 bit = uint128(1) << AaveV3Ethereum.POOL.getReserveData(assets[i]).id;
      collateralBefore[i] = AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(eModes[i]);
      borrowableBefore[i] = AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(eModes[i]);
      assertTrue(collateralBefore[i] & bit != 0, 'asset is not collateral in eMode');
      assertEq(
        AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit,
        0,
        'ltvzero already set'
      );
    }

    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < 23; i++) {
      uint128 bit = uint128(1) << AaveV3Ethereum.POOL.getReserveData(assets[i]).id;
      assertTrue(
        AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit != 0,
        'ltvzero not set'
      );
      assertEq(
        AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(eModes[i]),
        collateralBefore[i],
        'collateral bitmap changed'
      );
      assertEq(
        AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(eModes[i]),
        borrowableBefore[i],
        'borrowable bitmap changed'
      );
    }
  }
}
