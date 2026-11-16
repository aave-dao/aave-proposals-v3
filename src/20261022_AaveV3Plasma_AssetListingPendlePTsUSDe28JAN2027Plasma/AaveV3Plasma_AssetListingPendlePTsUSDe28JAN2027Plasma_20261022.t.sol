// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Plasma, AaveV3PlasmaAssets, AaveV3PlasmaEModes} from 'aave-address-book/AaveV3Plasma.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {Errors} from 'aave-v3-origin/contracts/protocol/libraries/helpers/Errors.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig, ExpectedListing} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022} from './AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022.sol';
import {IPendlePriceCapAdapter} from '../interfaces/IPendlePriceCapAdapter.sol';

/**
 * @dev Test for AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261022_AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma/AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022.t.sol -vv
 */
contract AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022_Test is ProtocolV3TestBase {
  struct EModeSnapshot {
    string label;
    DataTypes.CollateralConfig collateralConfig;
    bool isolated;
    uint128 collateralBitmap;
    uint128 borrowableBitmap;
    uint128 ltvzeroBitmap;
  }

  // eMode 25 (sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO) borrower at the fork block: only PT-sUSDe-22OCT2026 collateral, USDT0 debt
  // https://plasmascan.to/address/0x3b098f5b2208f6d4e6599fc36669621b7a347512
  string internal constant NEW_EMODE_LABEL = 'sUSDe_PT_sUSDe_28JAN2027__Stablecoins';
  address internal constant EMODE_25_BORROWER = 0x3B098f5b2208f6d4E6599Fc36669621B7A347512;

  AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 37634563);
    proposal = new AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022();
  }

  function test_executorIsPrefunded() public view {
    assertGe(
      IERC20(proposal.PT_sUSDE_28JAN2027()).balanceOf(GovernanceV3Plasma.EXECUTOR_LVL_1),
      proposal.PT_sUSDE_28JAN2027_SEED_AMOUNT(),
      'executor should hold the seed amount before execution'
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022',
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

  function test_liquidationProtocolFee() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3Plasma.AAVE_PROTOCOL_DATA_PROVIDER.getLiquidationProtocolFee(
        proposal.PT_sUSDE_28JAN2027()
      ),
      10_00
    );
  }

  function test_rates() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address asset = proposal.PT_sUSDE_28JAN2027();
    _validateInterestRateStrategy(
      asset,
      AaveV3Plasma.POOL.getReserveData(asset).interestRateStrategyAddress,
      AaveV3Plasma.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: 0.45e27,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 0.1e27,
        variableRateSlope2: 3e27
      })
    );
  }

  function test_dustBinHasPT_sUSDE_28JAN2027Funds() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address aTokenAddress = AaveV3Plasma.POOL.getReserveAToken(proposal.PT_sUSDE_28JAN2027());
    assertEq(
      IERC20(aTokenAddress).balanceOf(address(AaveV3Plasma.DUST_BIN)),
      100e18,
      'DustBin should hold exactly the seed amount'
    );
  }

  function test_priceFeedWiring() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3Plasma.ORACLE.getSourceOfAsset(proposal.PT_sUSDE_28JAN2027()),
      proposal.PT_sUSDE_28JAN2027_PRICE_FEED(),
      'PT-sUSDe should be priced by the configured linear discount oracle'
    );
    uint256 price = AaveV3Plasma.ORACLE.getAssetPrice(proposal.PT_sUSDE_28JAN2027());
    assertGt(price, 0.97e8, 'PT-sUSDe price should be within a sane discount band');
    assertLt(price, 1e8, 'PT-sUSDe should price below par (1 USD) before maturity');

    IPendlePriceCapAdapter adapter = IPendlePriceCapAdapter(
      proposal.PT_sUSDE_28JAN2027_PRICE_FEED()
    );
    assertEq(adapter.discountRatePerYear(), 0.04399e18, 'initial discount rate');
    assertEq(adapter.MAX_DISCOUNT_RATE_PER_YEAR(), 0.09047e18, 'max discount rate');
    assertEq(adapter.MATURITY(), 1801094400, 'maturity should be 28 January 2027 UTC');
    assertEq(
      adapter.PENDLE_PRINCIPAL_TOKEN(),
      proposal.PT_sUSDE_28JAN2027(),
      'oracle should price the listed PT'
    );
    assertEq(
      adapter.ASSET_TO_USD_AGGREGATOR(),
      AaveV3PlasmaAssets.USDT0_ORACLE,
      'underlying aggregator should be the Capped USDT0/USD feed'
    );
  }

  function _expectedListings() internal pure override returns (ExpectedListing[] memory listings) {
    listings = new ExpectedListing[](1);

    listings[0] = ExpectedListing({
      listing: IAaveV3ConfigEngine.Listing({
        asset: 0x257561233419039BeC3a28be717d14B4f490883D,
        assetSymbol: 'PT-sUSDE-28JAN2027',
        priceFeed: 0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f,
        enabledToBorrow: EngineFlags.DISABLED,
        flashloanable: EngineFlags.DISABLED,
        ltv: 0,
        liqThreshold: 0,
        liqBonus: 0,
        reserveFactor: 45_00,
        supplyCap: 25_000_000,
        borrowCap: 1,
        liqProtocolFee: 10_00,
        rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
          optimalUsageRatio: 45_00,
          baseVariableBorrowRate: 0,
          variableRateSlope1: 10_00,
          variableRateSlope2: 300_00
        })
      }),
      decimals: 18
    });
  }

  function test_eModeConfiguration() public {
    EModeSnapshot[] memory before_ = _snapshotEModes();

    GovV3Helpers.executePayload(vm, address(proposal));
    uint8 id = _findEModeCategoryId(NEW_EMODE_LABEL);
    assertEq(id, before_.length + 1, 'new eMode id is the next free id');
    _assertEModeCollateralConfig({
      id: id,
      ltv: 90_00,
      liquidationThreshold: 92_00,
      liquidationBonus: 100_00 + 4_95,
      isolated: false
    });

    address[] memory collaterals = new address[](3);
    collaterals[0] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    collaterals[1] = proposal.PT_sUSDE_28JAN2027();
    collaterals[2] = AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING;
    assertEq(AaveV3Plasma.POOL.getEModeCategoryCollateralBitmap(id), _toBitmap(collaterals));

    address[] memory borrowables = new address[](3);
    borrowables[0] = AaveV3PlasmaAssets.USDT0_UNDERLYING;
    borrowables[1] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    borrowables[2] = AaveV3PlasmaAssets.GHO_UNDERLYING;
    assertEq(AaveV3Plasma.POOL.getEModeCategoryBorrowableBitmap(id), _toBitmap(borrowables));

    assertEq(
      AaveV3Plasma.POOL.getEModeCategoryLtvzeroBitmap(id),
      0,
      'no asset has ltvzero in the new eMode'
    );

    for (uint8 i = 0; i < before_.length; i++) {
      _assertEModeUnchanged(i + 1, before_[i]);
    }
  }

  function test_eMode_sUSDe_supplyAndBorrow() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _supplyAndBorrowInEMode(
      NEW_EMODE_LABEL,
      AaveV3PlasmaAssets.sUSDe_UNDERLYING,
      AaveV3PlasmaAssets.USDT0_UNDERLYING
    );
  }

  function test_eMode_PT_sUSDe_28JAN2027_supplyAndBorrow() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _supplyAndBorrowInEMode(
      NEW_EMODE_LABEL,
      proposal.PT_sUSDE_28JAN2027(),
      AaveV3PlasmaAssets.USDT0_UNDERLYING
    );
  }

  function test_PT_sUSDE_28JAN2027BorrowWithoutEModeReverts() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    address user = makeAddr('borrowWithoutEModeUser');
    uint256 supplyAmount = 1_000 * 10 ** IERC20Metadata(proposal.PT_sUSDE_28JAN2027()).decimals();
    deal(proposal.PT_sUSDE_28JAN2027(), user, supplyAmount);

    vm.startPrank(user);

    IERC20(proposal.PT_sUSDE_28JAN2027()).approve(address(AaveV3Plasma.POOL), supplyAmount);
    AaveV3Plasma.POOL.supply(proposal.PT_sUSDE_28JAN2027(), supplyAmount, user, 0);

    // LTV is 0 outside the e-mode, so the borrow must revert
    vm.expectRevert(abi.encodeWithSelector(Errors.LtvValidationFailed.selector));
    AaveV3Plasma.POOL.borrow(AaveV3PlasmaAssets.USDT0_UNDERLYING, 1, 2, 0, user);

    vm.stopPrank();
  }

  function test_eMode_PT_sUSDe_22OCT2026_canBorrow() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    address asset = AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING;
    address usdt0 = AaveV3PlasmaAssets.USDT0_UNDERLYING;
    vm.prank(AaveV3Plasma.ACL_ADMIN);
    AaveV3Plasma.POOL_CONFIGURATOR.setSupplyCap(asset, 0);

    address user = makeAddr('maturedPtEModeUser');
    uint256 supplyAmount = 1_000 * 10 ** IERC20Metadata(asset).decimals();
    uint256 borrowAmount = 10 * 10 ** IERC20Metadata(usdt0).decimals();
    deal(asset, user, supplyAmount);

    vm.startPrank(user);

    AaveV3Plasma.POOL.setUserEMode(_findEModeCategoryId(NEW_EMODE_LABEL));
    IERC20(asset).approve(address(AaveV3Plasma.POOL), supplyAmount);
    AaveV3Plasma.POOL.supply(asset, supplyAmount, user, 0);
    AaveV3Plasma.POOL.borrow(usdt0, borrowAmount, 2, 0, user);

    vm.stopPrank();

    assertApproxEqAbs(
      IERC20(AaveV3Plasma.POOL.getReserveVariableDebtToken(usdt0)).balanceOf(user),
      borrowAmount,
      1
    );
  }

  function test_rollover_eMode25BorrowerToNewEMode() public {
    address usdt0 = AaveV3PlasmaAssets.USDT0_UNDERLYING;
    address borrower = EMODE_25_BORROWER;

    assertEq(
      AaveV3Plasma.POOL.getUserEMode(borrower),
      AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO
    );
    assertGt(IERC20(AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_A_TOKEN).balanceOf(borrower), 0);
    assertGt(IERC20(AaveV3Plasma.POOL.getReserveVariableDebtToken(usdt0)).balanceOf(borrower), 0);
    (, , , , , uint256 hfBefore) = AaveV3Plasma.POOL.getUserAccountData(borrower);

    GovV3Helpers.executePayload(vm, address(proposal));

    uint8 newEModeId = _findEModeCategoryId(NEW_EMODE_LABEL);
    vm.prank(borrower);
    AaveV3Plasma.POOL.setUserEMode(newEModeId);

    assertEq(AaveV3Plasma.POOL.getUserEMode(borrower), newEModeId);
    (, , , , , uint256 hfAfter) = AaveV3Plasma.POOL.getUserAccountData(borrower);
    assertEq(hfAfter, hfBefore, 'HF changed on eMode switch');
  }

  function _snapshotEModes() internal view returns (EModeSnapshot[] memory snaps) {
    uint8 count;
    while (bytes(AaveV3Plasma.POOL.getEModeCategoryLabel(count + 1)).length != 0) count++;
    snaps = new EModeSnapshot[](count);
    for (uint8 i = 0; i < count; i++) {
      uint8 id = i + 1;
      snaps[i] = EModeSnapshot({
        label: AaveV3Plasma.POOL.getEModeCategoryLabel(id),
        collateralConfig: AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(id),
        isolated: AaveV3Plasma.POOL.getIsEModeCategoryIsolated(id),
        collateralBitmap: AaveV3Plasma.POOL.getEModeCategoryCollateralBitmap(id),
        borrowableBitmap: AaveV3Plasma.POOL.getEModeCategoryBorrowableBitmap(id),
        ltvzeroBitmap: AaveV3Plasma.POOL.getEModeCategoryLtvzeroBitmap(id)
      });
    }
  }

  function _assertEModeUnchanged(uint8 id, EModeSnapshot memory snap) internal view {
    DataTypes.CollateralConfig memory cfg = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(id);
    assertEq(AaveV3Plasma.POOL.getEModeCategoryLabel(id), snap.label, 'existing eMode label');
    assertEq(cfg.ltv, snap.collateralConfig.ltv, 'existing eMode ltv changed');
    assertEq(
      cfg.liquidationThreshold,
      snap.collateralConfig.liquidationThreshold,
      'existing eMode liquidation threshold changed'
    );
    assertEq(
      cfg.liquidationBonus,
      snap.collateralConfig.liquidationBonus,
      'existing eMode liquidation bonus changed'
    );
    assertEq(AaveV3Plasma.POOL.getIsEModeCategoryIsolated(id), snap.isolated, 'isolated changed');
    assertEq(
      AaveV3Plasma.POOL.getEModeCategoryCollateralBitmap(id),
      snap.collateralBitmap,
      'existing eMode collateral bitmap changed'
    );
    assertEq(
      AaveV3Plasma.POOL.getEModeCategoryBorrowableBitmap(id),
      snap.borrowableBitmap,
      'existing eMode borrowable bitmap changed'
    );
    assertEq(
      AaveV3Plasma.POOL.getEModeCategoryLtvzeroBitmap(id),
      snap.ltvzeroBitmap,
      'existing eMode ltvzero bitmap changed'
    );
  }

  function _findEModeCategoryId(string memory label) internal view returns (uint8) {
    for (uint8 i = 1; i < 255; i++) {
      if (keccak256(bytes(AaveV3Plasma.POOL.getEModeCategoryLabel(i))) == keccak256(bytes(label))) {
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
    DataTypes.CollateralConfig memory cfg = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(id);
    assertEq(cfg.ltv, ltv);
    assertEq(cfg.liquidationThreshold, liquidationThreshold);
    assertEq(cfg.liquidationBonus, liquidationBonus);
    assertEq(AaveV3Plasma.POOL.getIsEModeCategoryIsolated(id), isolated);
  }

  function _toBitmap(address[] memory assets) internal view returns (uint128 bitmap) {
    for (uint256 i = 0; i < assets.length; i++) {
      bitmap |= uint128(1) << AaveV3Plasma.POOL.getReserveData(assets[i]).id;
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

    AaveV3Plasma.POOL.setUserEMode(eModeId);

    IERC20(collateral).approve(address(AaveV3Plasma.POOL), supplyAmount);
    AaveV3Plasma.POOL.supply(collateral, supplyAmount, user, 0);

    uint256 borrowAmount = 10 * 10 ** IERC20Metadata(borrowAsset).decimals();
    AaveV3Plasma.POOL.borrow(borrowAsset, borrowAmount, 2, 0, user);

    address vToken = AaveV3Plasma.POOL.getReserveVariableDebtToken(borrowAsset);
    assertApproxEqAbs(IERC20(vToken).balanceOf(user), borrowAmount, 1);

    IERC20(borrowAsset).approve(address(AaveV3Plasma.POOL), borrowAmount);
    AaveV3Plasma.POOL.repay(borrowAsset, borrowAmount, 2, user);
    AaveV3Plasma.POOL.withdraw(collateral, supplyAmount / 2, user);

    vm.stopPrank();
  }
}
