// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Monad, AaveV3MonadAssets, AaveV3MonadEModes} from 'aave-address-book/AaveV3Monad.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Test for AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111.t.sol -vv
 * forge-config: default.networks.network = "monad"
 * forge-config: default.hardfork = "monad:MonadTen"
 */
contract AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111_Test is ProtocolV3TestBase {
  AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('monad'), 121417398);
    proposal = new AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111',
      AaveV3Monad.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Monad.POOL, address(proposal), updatedAssets);
  }

  function test_eModeConfiguration() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint8 eMode_USDeStablecoins = _findEModeCategoryId('USDe Stablecoins');
    _assertEModeCollateralConfig({
      id: eMode_USDeStablecoins,
      ltv: 91_00,
      liquidationThreshold: 93_00,
      liquidationBonus: 100_00 + 2_00,
      isolated: false
    });

    address[] memory collaterals_USDeStablecoins = new address[](1);
    collaterals_USDeStablecoins[0] = AaveV3MonadAssets.USDe_UNDERLYING;
    assertEq(
      AaveV3Monad.POOL.getEModeCategoryCollateralBitmap(eMode_USDeStablecoins),
      _toBitmap(collaterals_USDeStablecoins)
    );

    address[] memory borrowables_USDeStablecoins = new address[](4);
    borrowables_USDeStablecoins[0] = AaveV3MonadAssets.USDT0_UNDERLYING;
    borrowables_USDeStablecoins[1] = AaveV3MonadAssets.USDC_UNDERLYING;
    borrowables_USDeStablecoins[2] = AaveV3MonadAssets.AUSD_UNDERLYING;
    borrowables_USDeStablecoins[3] = AaveV3MonadAssets.GHO_UNDERLYING;
    assertEq(
      AaveV3Monad.POOL.getEModeCategoryBorrowableBitmap(eMode_USDeStablecoins),
      _toBitmap(borrowables_USDeStablecoins)
    );
  }

  function test_eMode_USDeStablecoins_supplyAndBorrow() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _supplyAndBorrowInEMode(
      'USDe Stablecoins',
      AaveV3MonadAssets.USDe_UNDERLYING,
      AaveV3MonadAssets.USDT0_UNDERLYING
    );
  }

  function _findEModeCategoryId(string memory label) internal view returns (uint8) {
    for (uint8 i = 1; i < 255; i++) {
      if (keccak256(bytes(AaveV3Monad.POOL.getEModeCategoryLabel(i))) == keccak256(bytes(label))) {
        return i;
      }
    }
    revert('eMode category not found');
  }

  function _assertEModeCollateralConfig(
    uint8 id,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus,
    bool isolated
  ) internal view {
    DataTypes.CollateralConfig memory cfg = AaveV3Monad.POOL.getEModeCategoryCollateralConfig(id);
    assertEq(cfg.ltv, ltv);
    assertEq(cfg.liquidationThreshold, liquidationThreshold);
    assertEq(cfg.liquidationBonus, liquidationBonus);
    assertEq(AaveV3Monad.POOL.getIsEModeCategoryIsolated(id), isolated);
  }

  function _toBitmap(address[] memory assets) internal view returns (uint128 bitmap) {
    for (uint256 i = 0; i < assets.length; i++) {
      bitmap |= uint128(1) << AaveV3Monad.POOL.getReserveData(assets[i]).id;
    }
  }

  function _supplyAndBorrowInEMode(
    string memory label,
    address collateral,
    address borrowAsset
  ) internal {
    uint8 eModeId = _findEModeCategoryId(label);

    address user = makeAddr('eModeUser');
    uint256 supplyAmount = 1_000 * 10 ** IERC20Metadata(collateral).decimals();
    deal(collateral, user, supplyAmount);

    vm.startPrank(user);

    AaveV3Monad.POOL.setUserEMode(eModeId);

    IERC20(collateral).approve(address(AaveV3Monad.POOL), supplyAmount);
    AaveV3Monad.POOL.supply(collateral, supplyAmount, user, 0);

    uint256 borrowAmount = 10 * 10 ** IERC20Metadata(borrowAsset).decimals();
    AaveV3Monad.POOL.borrow(borrowAsset, borrowAmount, 2, 0, user);

    address vToken = AaveV3Monad.POOL.getReserveVariableDebtToken(borrowAsset);
    assertApproxEqAbs(IERC20(vToken).balanceOf(user), borrowAmount, 1);

    IERC20(borrowAsset).approve(address(AaveV3Monad.POOL), borrowAmount);
    AaveV3Monad.POOL.repay(borrowAsset, borrowAmount, 2, user);
    AaveV3Monad.POOL.withdraw(collateral, supplyAmount / 2, user);

    vm.stopPrank();
  }

  function test_ltvzeroFlags() public {
    address[] memory assets = new address[](1);
    uint8[] memory eModes = new uint8[](1);
    assets[0] = AaveV3MonadAssets.PT_AUSD_8OCT2026_UNDERLYING;
    eModes[0] = AaveV3MonadEModes.PT_AUSD_8OCT2026__USDT0_USDC_USDe_GHO;

    uint128[] memory collateralBefore = new uint128[](1);
    uint128[] memory borrowableBefore = new uint128[](1);
    for (uint256 i = 0; i < 1; i++) {
      uint128 bit = uint128(1) << AaveV3Monad.POOL.getReserveData(assets[i]).id;
      collateralBefore[i] = AaveV3Monad.POOL.getEModeCategoryCollateralBitmap(eModes[i]);
      borrowableBefore[i] = AaveV3Monad.POOL.getEModeCategoryBorrowableBitmap(eModes[i]);
      assertTrue(collateralBefore[i] & bit != 0, 'asset is not collateral in eMode');
      assertEq(
        AaveV3Monad.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit,
        0,
        'ltvzero already set'
      );
    }

    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < 1; i++) {
      uint128 bit = uint128(1) << AaveV3Monad.POOL.getReserveData(assets[i]).id;
      assertTrue(
        AaveV3Monad.POOL.getEModeCategoryLtvzeroBitmap(eModes[i]) & bit != 0,
        'ltvzero not set'
      );
      assertEq(
        AaveV3Monad.POOL.getEModeCategoryCollateralBitmap(eModes[i]),
        collateralBefore[i],
        'collateral bitmap changed'
      );
      assertEq(
        AaveV3Monad.POOL.getEModeCategoryBorrowableBitmap(eModes[i]),
        borrowableBefore[i],
        'borrowable bitmap changed'
      );
    }
  }
}
