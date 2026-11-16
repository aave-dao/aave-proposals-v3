// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3XLayer, AaveV3XLayerAssets} from 'aave-address-book/AaveV3XLayer.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {Errors} from 'aave-v3-origin/contracts/protocol/libraries/helpers/Errors.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig, ExpectedListing} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3XLayer_RiskParamsRecordCIListingSample_20261116} from './AaveV3XLayer_RiskParamsRecordCIListingSample_20261116.sol';

/**
 * @dev Test for AaveV3XLayer_RiskParamsRecordCIListingSample_20261116
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261116_AaveV3XLayer_RiskParamsRecordCIListingSample/AaveV3XLayer_RiskParamsRecordCIListingSample_20261116.t.sol -vv
 */
contract AaveV3XLayer_RiskParamsRecordCIListingSample_20261116_Test is ProtocolV3TestBase {
  AaveV3XLayer_RiskParamsRecordCIListingSample_20261116 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('xlayer'), 72750800);
    proposal = new AaveV3XLayer_RiskParamsRecordCIListingSample_20261116();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3XLayer_RiskParamsRecordCIListingSample_20261116',
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

  function test_dustBinHasPT_USDG_25FEB2027Funds() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address aTokenAddress = AaveV3XLayer.POOL.getReserveAToken(proposal.PT_USDG_25FEB2027());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3XLayer.DUST_BIN)),
      proposal.PT_USDG_25FEB2027_SEED_AMOUNT()
    );
  }

  function _expectedListings() internal pure override returns (ExpectedListing[] memory listings) {
    listings = new ExpectedListing[](1);

    listings[0] = ExpectedListing({
      listing: IAaveV3ConfigEngine.Listing({
        asset: 0x5eA1F184af5Ced57725213D8267B5c4C834557D4,
        assetSymbol: 'PT_USDG_25FEB2027',
        priceFeed: 0xB81f0B2cCAC262288fED924DA750CFc7CC450530,
        enabledToBorrow: EngineFlags.DISABLED,
        flashloanable: EngineFlags.ENABLED,
        ltv: 0,
        liqThreshold: 0,
        liqBonus: 0,
        reserveFactor: 20_00,
        supplyCap: 30_000_000,
        borrowCap: 1,
        liqProtocolFee: 10_00,
        rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
          optimalUsageRatio: 45_00,
          baseVariableBorrowRate: 0,
          variableRateSlope1: 10_00,
          variableRateSlope2: 300_00
        })
      }),
      decimals: 6
    });
  }

  function test_eModeConfiguration() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    uint8 eMode_PT_USDG_25FEB2027__Stablecoins = _findEModeCategoryId(
      'PT_USDG_25FEB2027__Stablecoins'
    );
    _assertEModeCollateralConfig({
      id: eMode_PT_USDG_25FEB2027__Stablecoins,
      ltv: 91_00,
      liquidationThreshold: 93_00,
      liquidationBonus: 100_00 + 2_50,
      isolated: false
    });

    address[] memory collaterals_PT_USDG_25FEB2027__Stablecoins = new address[](2);
    collaterals_PT_USDG_25FEB2027__Stablecoins[0] = proposal.PT_USDG_25FEB2027();
    collaterals_PT_USDG_25FEB2027__Stablecoins[1] = AaveV3XLayerAssets.PT_USDG_29OCT2026_UNDERLYING;
    assertEq(
      AaveV3XLayer.POOL.getEModeCategoryCollateralBitmap(eMode_PT_USDG_25FEB2027__Stablecoins),
      _toBitmap(collaterals_PT_USDG_25FEB2027__Stablecoins)
    );

    address[] memory borrowables_PT_USDG_25FEB2027__Stablecoins = new address[](3);
    borrowables_PT_USDG_25FEB2027__Stablecoins[0] = AaveV3XLayerAssets.USDT_UNDERLYING;
    borrowables_PT_USDG_25FEB2027__Stablecoins[1] = AaveV3XLayerAssets.GHO_UNDERLYING;
    borrowables_PT_USDG_25FEB2027__Stablecoins[2] = AaveV3XLayerAssets.USDC_UNDERLYING;
    assertEq(
      AaveV3XLayer.POOL.getEModeCategoryBorrowableBitmap(eMode_PT_USDG_25FEB2027__Stablecoins),
      _toBitmap(borrowables_PT_USDG_25FEB2027__Stablecoins)
    );
  }

  function test_eMode_PT_USDG_25FEB2027__Stablecoins_supplyAndBorrow() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _supplyAndBorrowInEMode(
      'PT_USDG_25FEB2027__Stablecoins',
      proposal.PT_USDG_25FEB2027(),
      AaveV3XLayerAssets.USDT_UNDERLYING
    );
  }

  function test_PT_USDG_25FEB2027BorrowWithoutEModeReverts() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    address user = makeAddr('borrowWithoutEModeUser');
    uint256 supplyAmount = 1_000 * 10 ** IERC20Metadata(proposal.PT_USDG_25FEB2027()).decimals();
    deal(proposal.PT_USDG_25FEB2027(), user, supplyAmount);

    vm.startPrank(user);

    IERC20(proposal.PT_USDG_25FEB2027()).approve(address(AaveV3XLayer.POOL), supplyAmount);
    AaveV3XLayer.POOL.supply(proposal.PT_USDG_25FEB2027(), supplyAmount, user, 0);

    // LTV is 0 outside the e-mode, so the borrow must revert
    vm.expectRevert(abi.encodeWithSelector(Errors.LtvValidationFailed.selector));
    AaveV3XLayer.POOL.borrow(AaveV3XLayerAssets.USDT_UNDERLYING, 1, 2, 0, user);

    vm.stopPrank();
  }

  function _findEModeCategoryId(string memory label) internal view returns (uint8) {
    for (uint8 i = 1; i < 255; i++) {
      if (keccak256(bytes(AaveV3XLayer.POOL.getEModeCategoryLabel(i))) == keccak256(bytes(label))) {
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
    DataTypes.CollateralConfig memory cfg = AaveV3XLayer.POOL.getEModeCategoryCollateralConfig(id);
    assertEq(cfg.ltv, ltv);
    assertEq(cfg.liquidationThreshold, liquidationThreshold);
    assertEq(cfg.liquidationBonus, liquidationBonus);
    assertEq(AaveV3XLayer.POOL.getIsEModeCategoryIsolated(id), isolated);
  }

  function _toBitmap(address[] memory assets) internal view returns (uint128 bitmap) {
    for (uint256 i = 0; i < assets.length; i++) {
      bitmap |= uint128(1) << AaveV3XLayer.POOL.getReserveData(assets[i]).id;
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

    AaveV3XLayer.POOL.setUserEMode(eModeId);

    IERC20(collateral).approve(address(AaveV3XLayer.POOL), supplyAmount);
    AaveV3XLayer.POOL.supply(collateral, supplyAmount, user, 0);

    uint256 borrowAmount = 10 * 10 ** IERC20Metadata(borrowAsset).decimals();
    AaveV3XLayer.POOL.borrow(borrowAsset, borrowAmount, 2, 0, user);

    address vToken = AaveV3XLayer.POOL.getReserveVariableDebtToken(borrowAsset);
    assertApproxEqAbs(IERC20(vToken).balanceOf(user), borrowAmount, 1);

    IERC20(borrowAsset).approve(address(AaveV3XLayer.POOL), borrowAmount);
    AaveV3XLayer.POOL.repay(borrowAsset, borrowAmount, 2, user);
    AaveV3XLayer.POOL.withdraw(collateral, supplyAmount / 2, user);

    vm.stopPrank();
  }
}
