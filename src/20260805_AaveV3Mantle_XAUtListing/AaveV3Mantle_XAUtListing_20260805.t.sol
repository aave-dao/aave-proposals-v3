// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Mantle, AaveV3MantleAssets} from 'aave-address-book/AaveV3Mantle.sol';
import {GovernanceV3Mantle} from 'aave-address-book/GovernanceV3Mantle.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {Errors} from 'aave-v3-origin/contracts/protocol/libraries/helpers/Errors.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig, ExpectedListing} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Mantle_XAUtListing_20260805} from './AaveV3Mantle_XAUtListing_20260805.sol';

/**
 * @dev Test for AaveV3Mantle_XAUtListing_20260805
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260805_AaveV3Mantle_XAUtListing/AaveV3Mantle_XAUtListing_20260805.t.sol -vv
 */
contract AaveV3Mantle_XAUtListing_20260805_Test is ProtocolV3TestBase {
  AaveV3Mantle_XAUtListing_20260805 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mantle'), 99216559);
    proposal = new AaveV3Mantle_XAUtListing_20260805();
    deal(proposal.XAUt(), GovernanceV3Mantle.EXECUTOR_LVL_1, proposal.XAUt_SEED_AMOUNT());
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV3Mantle_XAUtListing_20260805', AaveV3Mantle.POOL, address(proposal));
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Mantle.POOL, address(proposal), updatedAssets);
  }

  function test_dustBinHasXAUtFunds() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address aTokenAddress = AaveV3Mantle.POOL.getReserveAToken(proposal.XAUt());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3Mantle.DUST_BIN)),
      proposal.XAUt_SEED_AMOUNT(),
      'DustBin should hold at least the seed amount'
    );
  }

  function test_priceFeedReturnsSanePrice() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3Mantle.ORACLE.getSourceOfAsset(proposal.XAUt()),
      proposal.XAUt_PRICE_FEED(),
      'XAUt should be priced by the configured XAU/USD feed'
    );
    uint256 price = AaveV3Mantle.ORACLE.getAssetPrice(proposal.XAUt());
    assertGt(price, 1_000e8, 'XAUt (gold) price should be above 1,000 USD/oz');
    assertLt(price, 100_000e8, 'XAUt price should be within a sane range');
  }

  function _expectedListings() internal pure override returns (ExpectedListing[] memory listings) {
    listings = new ExpectedListing[](1);

    listings[0] = ExpectedListing({
      listing: IAaveV3ConfigEngine.Listing({
        asset: 0x6199CCd9273A1E0e41e2cC18d9dAcd1E9382F58E,
        assetSymbol: 'XAUt',
        priceFeed: 0x23A1105fd2C26BCc9EA691725Bbda3f5F1bC0b78,
        enabledToBorrow: EngineFlags.DISABLED,
        flashloanable: EngineFlags.ENABLED,
        ltv: 0,
        liqThreshold: 0,
        liqBonus: 0,
        reserveFactor: 20_00,
        supplyCap: 4_000,
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
    uint8 eMode_XAUtStablecoins = _findEModeCategoryId('XAUt Stablecoins');
    _assertEModeCollateralConfig({
      id: eMode_XAUtStablecoins,
      ltv: 70_00,
      liquidationThreshold: 75_00,
      liquidationBonus: 100_00 + 6_00,
      isolated: false
    });

    address[] memory collaterals_XAUtStablecoins = new address[](1);
    collaterals_XAUtStablecoins[0] = proposal.XAUt();
    assertEq(
      AaveV3Mantle.POOL.getEModeCategoryCollateralBitmap(eMode_XAUtStablecoins),
      _toBitmap(collaterals_XAUtStablecoins),
      'eMode collateral bitmap should contain exactly XAUt'
    );

    address[] memory borrowables_XAUtStablecoins = new address[](3);
    borrowables_XAUtStablecoins[0] = AaveV3MantleAssets.USDT0_UNDERLYING;
    borrowables_XAUtStablecoins[1] = AaveV3MantleAssets.USDC_UNDERLYING;
    borrowables_XAUtStablecoins[2] = AaveV3MantleAssets.GHO_UNDERLYING;
    assertEq(
      AaveV3Mantle.POOL.getEModeCategoryBorrowableBitmap(eMode_XAUtStablecoins),
      _toBitmap(borrowables_XAUtStablecoins),
      'eMode borrowable bitmap should contain exactly USDT0, USDC and GHO'
    );
  }

  function test_eMode_XAUtStablecoins_supplyAndBorrow() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _supplyAndBorrowInEMode(
      'XAUt Stablecoins',
      proposal.XAUt(),
      AaveV3MantleAssets.USDT0_UNDERLYING
    );
  }

  function test_XAUtBorrowWithoutEModeReverts() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    address user = makeAddr('borrowWithoutEModeUser');
    uint256 supplyAmount = 100 * 10 ** IERC20Metadata(proposal.XAUt()).decimals();
    deal(proposal.XAUt(), user, supplyAmount);

    vm.startPrank(user);

    IERC20(proposal.XAUt()).approve(address(AaveV3Mantle.POOL), supplyAmount);
    AaveV3Mantle.POOL.supply(proposal.XAUt(), supplyAmount, user, 0);

    // LTV is 0 outside the e-mode, so the borrow must revert
    vm.expectRevert(abi.encodeWithSelector(Errors.LtvValidationFailed.selector));
    AaveV3Mantle.POOL.borrow(AaveV3MantleAssets.USDT0_UNDERLYING, 1, 2, 0, user);

    vm.stopPrank();
  }

  function _findEModeCategoryId(string memory label) internal view returns (uint8) {
    for (uint8 i = 1; i < 255; i++) {
      if (keccak256(bytes(AaveV3Mantle.POOL.getEModeCategoryLabel(i))) == keccak256(bytes(label))) {
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
    DataTypes.CollateralConfig memory cfg = AaveV3Mantle.POOL.getEModeCategoryCollateralConfig(id);
    assertEq(cfg.ltv, ltv, 'unexpected eMode ltv');
    assertEq(
      cfg.liquidationThreshold,
      liquidationThreshold,
      'unexpected eMode liquidation threshold'
    );
    assertEq(cfg.liquidationBonus, liquidationBonus, 'unexpected eMode liquidation bonus');
    assertEq(
      AaveV3Mantle.POOL.getIsEModeCategoryIsolated(id),
      isolated,
      'unexpected eMode isolation flag'
    );
  }

  function _toBitmap(address[] memory assets) internal view returns (uint128 bitmap) {
    for (uint256 i = 0; i < assets.length; i++) {
      bitmap |= uint128(1) << AaveV3Mantle.POOL.getReserveData(assets[i]).id;
    }
  }

  function _supplyAndBorrowInEMode(
    string memory label,
    address collateral,
    address borrowAsset
  ) internal {
    uint8 eModeId = _findEModeCategoryId(label);

    address user = makeAddr('eModeUser');
    uint256 supplyAmount = 100 * 10 ** IERC20Metadata(collateral).decimals();
    deal(collateral, user, supplyAmount);

    vm.startPrank(user);

    AaveV3Mantle.POOL.setUserEMode(eModeId);

    IERC20(collateral).approve(address(AaveV3Mantle.POOL), supplyAmount);
    AaveV3Mantle.POOL.supply(collateral, supplyAmount, user, 0);

    uint256 borrowAmount = 10 * 10 ** IERC20Metadata(borrowAsset).decimals();
    AaveV3Mantle.POOL.borrow(borrowAsset, borrowAmount, 2, 0, user);

    address vToken = AaveV3Mantle.POOL.getReserveVariableDebtToken(borrowAsset);
    assertApproxEqAbs(IERC20(vToken).balanceOf(user), borrowAmount, 1, 'borrowed amount mismatch');

    IERC20(borrowAsset).approve(address(AaveV3Mantle.POOL), borrowAmount);
    AaveV3Mantle.POOL.repay(borrowAsset, borrowAmount, 2, user);
    AaveV3Mantle.POOL.withdraw(collateral, supplyAmount / 2, user);

    vm.stopPrank();
  }
}
