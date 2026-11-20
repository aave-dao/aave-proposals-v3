// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets, AaveV3EthereumEModes} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {Errors} from 'aave-v3-origin/contracts/protocol/libraries/helpers/Errors.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119} from './AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119.sol';

/**
 * @dev Test for AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261119_AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral/AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119.t.sol -vv
 */
contract AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119_Test is
  ProtocolV3TestBase
{
  uint8 internal constant RSETH_EMODE = AaveV3EthereumEModes.rsETH__WETH_wstETH_ETHx;
  uint8 internal constant ETH_EMODE =
    AaveV3EthereumEModes.WETH_wstETH_cbETH_rETH_weETH_osETH_ETHx__WETH;

  AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119
    internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26449568);
    proposal = new AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_RepositioningAaveV3CoreAroundEstablishedLiquidCollateral_20261119',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](14);
    updatedAssets[0] = AaveV3EthereumAssets.CRV_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.tBTC_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.rETH_UNDERLYING;
    updatedAssets[3] = AaveV3EthereumAssets.crvUSD_UNDERLYING;
    updatedAssets[4] = AaveV3EthereumAssets.FBTC_UNDERLYING;
    updatedAssets[5] = AaveV3EthereumAssets.UNI_UNDERLYING;
    updatedAssets[6] = AaveV3EthereumAssets.mUSD_UNDERLYING;
    updatedAssets[7] = AaveV3EthereumAssets.osETH_UNDERLYING;
    updatedAssets[8] = AaveV3EthereumAssets.LBTC_UNDERLYING;
    updatedAssets[9] = AaveV3EthereumAssets.eBTC_UNDERLYING;
    updatedAssets[10] = AaveV3EthereumAssets.BTCb_UNDERLYING;
    updatedAssets[11] = AaveV3EthereumAssets.tETH_UNDERLYING;
    updatedAssets[12] = AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING;
    updatedAssets[13] = AaveV3EthereumAssets.LDO_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  /// @dev pre-state of the reserves: frozen flags, LTVs and reserve factors of the AIP tables
  function test_preExecutionReserveState() public view {
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Ethereum.POOL);

    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.osETH_UNDERLYING, 0);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.LBTC_UNDERLYING, 70_00);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.rETH_UNDERLYING, 75_00);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.eBTC_UNDERLYING, 67_00);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.BTCb_UNDERLYING, 73_00);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.tETH_UNDERLYING, 0);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING, 0);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.LDO_UNDERLYING, 0);
    _assertNotFrozenWithLtv(configs, AaveV3EthereumAssets.mUSD_UNDERLYING, 0);

    // out of scope: already frozen
    assertTrue(_findReserveConfig(configs, AaveV3EthereumAssets.rsETH_UNDERLYING).isFrozen);
    assertTrue(_findReserveConfig(configs, AaveV3EthereumAssets.tBTC_UNDERLYING).isFrozen);

    _assertReserveFactor(configs, AaveV3EthereumAssets.CRV_UNDERLYING, 50_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.tBTC_UNDERLYING, 50_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.rETH_UNDERLYING, 15_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.crvUSD_UNDERLYING, 50_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.FBTC_UNDERLYING, 75_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.UNI_UNDERLYING, 50_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.mUSD_UNDERLYING, 20_00);

    // out of scope: already at 100%
    _assertReserveFactor(configs, AaveV3EthereumAssets.LUSD_UNDERLYING, 100_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.RPL_UNDERLYING, 100_00);
    _assertReserveFactor(configs, AaveV3EthereumAssets.FRAX_UNDERLYING, 100_00);
  }

  /// @dev pre-state of the E-Modes: rsETH E-Mode membership and the E-Modes of the freeze targets
  function test_preExecutionEModeState() public view {
    assertEq(RSETH_EMODE, 3);
    assertEq(AaveV3Ethereum.POOL.getEModeCategoryLabel(RSETH_EMODE), 'rsETH__ETH_wstETH_ETHx');
    assertFalse(AaveV3Ethereum.POOL.getIsEModeCategoryIsolated(RSETH_EMODE));
    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(RSETH_EMODE),
      _bit(AaveV3EthereumAssets.rsETH_UNDERLYING)
    );
    // wstETH is borrowable before execution
    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(RSETH_EMODE),
      _bit(AaveV3EthereumAssets.WETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.wstETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.ETHx_UNDERLYING)
    );
    _assertEModeCollateralConfig(RSETH_EMODE, 93_00, 95_00, 101_00);

    assertEq(ETH_EMODE, 1);
    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(ETH_EMODE),
      _bit(AaveV3EthereumAssets.osETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.rETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.cbETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.wstETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.weETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.WETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.ETHx_UNDERLYING)
    );
    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(ETH_EMODE),
      _bit(AaveV3EthereumAssets.WETH_UNDERLYING)
    );
    _assertEModeCollateralConfig(ETH_EMODE, 93_00, 95_00, 101_00);

    // E-Mode LTVs of the AIP freeze table
    assertEq(_eModeLtv(AaveV3EthereumEModes.LBTC__WBTC), 84_00);
    assertEq(_eModeLtv(AaveV3EthereumEModes.LBTC__cbBTC), 84_00);
    assertEq(_eModeLtv(AaveV3EthereumEModes.LBTC__tBTC), 84_00);
    assertEq(_eModeLtv(AaveV3EthereumEModes.eBTC__WBTC), 83_00);
    assertEq(_eModeLtv(AaveV3EthereumEModes.tETH__USDC_USDT), 72_00);
    assertEq(_eModeLtv(AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe), 90_00);
    assertEq(_eModeLtv(AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe), 92_00);

    // each freeze target is collateral exactly in its expected E-Modes, ltvzero not set yet
    (address[] memory freezeAssets, ) = _expectedFreezeChanges();
    for (uint256 i = 0; i < freezeAssets.length; i++) {
      uint128 bit = _bit(freezeAssets[i]);
      uint8[] memory expectedEModes = _expectedCollateralEModes(freezeAssets[i]);
      uint256 found;
      for (uint256 id = 1; id <= 255; id++) {
        if (AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(uint8(id)) & bit == 0) {
          continue;
        }
        assertLt(found, expectedEModes.length, 'UNEXPECTED_EMODE_COLLATERAL');
        assertEq(id, expectedEModes[found], 'UNEXPECTED_EMODE_ID');
        assertEq(
          AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(uint8(id)) & bit,
          0,
          'LTVZERO_ALREADY_SET'
        );
        found++;
      }
      assertEq(found, expectedEModes.length, 'MISSING_EMODE_COLLATERAL');
    }
  }

  /// @dev rsETH E-Mode after execution: three collaterals added, wstETH no longer borrowable
  function test_rsETHEModeChanges() public {
    executePayload(vm, address(proposal));

    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(RSETH_EMODE),
      _bit(AaveV3EthereumAssets.rsETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.wstETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.weETH_UNDERLYING) |
        _bit(AaveV3EthereumAssets.cbETH_UNDERLYING),
      'RSETH_EMODE_COLLATERAL'
    );
    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(RSETH_EMODE),
      _bit(AaveV3EthereumAssets.WETH_UNDERLYING) | _bit(AaveV3EthereumAssets.ETHx_UNDERLYING),
      'RSETH_EMODE_BORROWABLE'
    );

    // ltvzero (rsETH only), parameters, label and isolated flag are unchanged
    assertEq(
      AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(RSETH_EMODE),
      _bit(AaveV3EthereumAssets.rsETH_UNDERLYING)
    );
    _assertEModeCollateralConfig(RSETH_EMODE, 93_00, 95_00, 101_00);
    assertEq(AaveV3Ethereum.POOL.getEModeCategoryLabel(RSETH_EMODE), 'rsETH__ETH_wstETH_ETHx');
    assertFalse(AaveV3Ethereum.POOL.getIsEModeCategoryIsolated(RSETH_EMODE));
  }

  /// @dev frozen reserves get LTV 0 and ltvzero in their E-Modes, no other E-Mode bitmap moves
  function test_frozenReservesHaveZeroLtvInEveryEMode() public {
    uint128[] memory collateralBefore = new uint128[](256);
    uint128[] memory borrowableBefore = new uint128[](256);
    uint128[] memory ltvzeroBefore = new uint128[](256);
    for (uint256 id = 1; id <= 255; id++) {
      collateralBefore[id] = AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(uint8(id));
      borrowableBefore[id] = AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(uint8(id));
      ltvzeroBefore[id] = AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(uint8(id));
    }

    executePayload(vm, address(proposal));

    (address[] memory freezeAssets, ) = _expectedFreezeChanges();
    uint128 frozenBits;
    for (uint256 i = 0; i < freezeAssets.length; i++) {
      (, uint256 ltv, , , , , , , , ) = AaveV3Ethereum
        .AAVE_PROTOCOL_DATA_PROVIDER
        .getReserveConfigurationData(freezeAssets[i]);
      assertEq(ltv, 0, 'LTV_NOT_ZERO');
      uint128 bit = _bit(freezeAssets[i]);
      frozenBits |= bit;

      uint8[] memory expectedEModes = _expectedCollateralEModes(freezeAssets[i]);
      for (uint256 j = 0; j < expectedEModes.length; j++) {
        assertEq(
          AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(expectedEModes[j]) & bit,
          bit,
          'LTVZERO_NOT_SET_IN_EXPECTED_EMODE'
        );
      }
    }

    // every reserve whose reserve factor is raised to 100% is frozen after execution
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates = _expectedBorrowChanges();
    for (uint256 i = 0; i < borrowUpdates.length; i++) {
      (, , , , , , , , , bool isFrozen) = AaveV3Ethereum
        .AAVE_PROTOCOL_DATA_PROVIDER
        .getReserveConfigurationData(borrowUpdates[i].asset);
      assertTrue(isFrozen, 'RESERVE_FACTOR_ASSET_NOT_FROZEN');
    }

    // all E-Modes: only the rsETH E-Mode membership changes, ltvzero is added for frozen collateral
    uint128 addedCollateral = _bit(AaveV3EthereumAssets.wstETH_UNDERLYING) |
      _bit(AaveV3EthereumAssets.weETH_UNDERLYING) |
      _bit(AaveV3EthereumAssets.cbETH_UNDERLYING);
    uint128 removedBorrowable = _bit(AaveV3EthereumAssets.wstETH_UNDERLYING);
    for (uint256 id = 1; id <= 255; id++) {
      uint128 collateralAfter = AaveV3Ethereum.POOL.getEModeCategoryCollateralBitmap(uint8(id));
      assertEq(
        collateralAfter,
        id == RSETH_EMODE ? collateralBefore[id] | addedCollateral : collateralBefore[id],
        'EMODE_COLLATERAL_CHANGED'
      );
      assertEq(
        AaveV3Ethereum.POOL.getEModeCategoryBorrowableBitmap(uint8(id)),
        id == RSETH_EMODE ? borrowableBefore[id] & ~removedBorrowable : borrowableBefore[id],
        'EMODE_BORROWABLE_CHANGED'
      );
      assertEq(
        AaveV3Ethereum.POOL.getEModeCategoryLtvzeroBitmap(uint8(id)),
        ltvzeroBefore[id] | (collateralAfter & frozenBits),
        'EMODE_LTVZERO_MISMATCH'
      );
    }
  }

  /// @dev each added collateral backs a WETH borrow at the rsETH E-Mode parameters
  function test_borrowAgainstAddedCollateralInRsETHEMode() public {
    executePayload(vm, address(proposal));

    address[3] memory collaterals = [
      AaveV3EthereumAssets.wstETH_UNDERLYING,
      AaveV3EthereumAssets.weETH_UNDERLYING,
      AaveV3EthereumAssets.cbETH_UNDERLYING
    ];
    for (uint256 i = 0; i < collaterals.length; i++) {
      address user = _supplyInRsETHEMode(collaterals[i]);

      (, , , uint256 liquidationThreshold, uint256 ltv, ) = AaveV3Ethereum.POOL.getUserAccountData(
        user
      );
      assertEq(ltv, 93_00, 'USER_LTV');
      assertEq(liquidationThreshold, 95_00, 'USER_LIQUIDATION_THRESHOLD');

      _borrowWETHAt90PercentLtv(user);
    }
  }

  /// @dev wstETH can be borrowed in the rsETH E-Mode before execution and reverts after it
  function test_wstETHNotBorrowableInRsETHEMode() public {
    address[2] memory collaterals = [
      AaveV3EthereumAssets.wstETH_UNDERLYING,
      AaveV3EthereumAssets.cbETH_UNDERLYING
    ];

    // before: the borrow succeeds (collateral counts at its base LTV)
    uint256 snapshot = vm.snapshotState();
    for (uint256 i = 0; i < collaterals.length; i++) {
      address user = _supplyInRsETHEMode(collaterals[i]);
      vm.prank(user);
      AaveV3Ethereum.POOL.borrow(AaveV3EthereumAssets.wstETH_UNDERLYING, 0.01 ether, 2, 0, user);
    }
    vm.revertToState(snapshot);

    executePayload(vm, address(proposal));

    for (uint256 i = 0; i < collaterals.length; i++) {
      address user = _supplyInRsETHEMode(collaterals[i]);
      vm.expectRevert(Errors.NotBorrowableInEMode.selector);
      vm.prank(user);
      AaveV3Ethereum.POOL.borrow(AaveV3EthereumAssets.wstETH_UNDERLYING, 0.01 ether, 2, 0, user);

      _borrowWETHAt90PercentLtv(user);
    }
  }

  /// @dev creates an account in the rsETH E-Mode that supplies 10 units of `collateral`
  function _supplyInRsETHEMode(address collateral) internal returns (address user) {
    user = makeAddr(string.concat('rsETHEModeUser', vm.toString(collateral)));
    uint256 supplyAmount = 10 ether;
    deal(collateral, user, supplyAmount);

    vm.startPrank(user);
    AaveV3Ethereum.POOL.setUserEMode(RSETH_EMODE);
    IERC20(collateral).approve(address(AaveV3Ethereum.POOL), supplyAmount);
    AaveV3Ethereum.POOL.supply(collateral, supplyAmount, user, 0);
    vm.stopPrank();
  }

  /// @dev borrows WETH worth 90% of the collateral of `user` and checks the account stays healthy
  function _borrowWETHAt90PercentLtv(address user) internal {
    (uint256 collateralBase, , , , , ) = AaveV3Ethereum.POOL.getUserAccountData(user);
    uint256 borrowAmount = (collateralBase * 90_00 * 1 ether) /
      (100_00 * AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.WETH_UNDERLYING));
    uint256 balanceBefore = IERC20(AaveV3EthereumAssets.WETH_UNDERLYING).balanceOf(user);

    vm.prank(user);
    AaveV3Ethereum.POOL.borrow(AaveV3EthereumAssets.WETH_UNDERLYING, borrowAmount, 2, 0, user);

    (, , , , , uint256 healthFactor) = AaveV3Ethereum.POOL.getUserAccountData(user);
    assertGt(healthFactor, 1 ether, 'HEALTH_FACTOR');
    assertEq(
      IERC20(AaveV3EthereumAssets.WETH_UNDERLYING).balanceOf(user),
      balanceBefore + borrowAmount
    );
  }

  /// @dev asserts a reserve is not frozen and has the given LTV
  function _assertNotFrozenWithLtv(
    ReserveConfig[] memory configs,
    address asset,
    uint256 ltv
  ) internal pure {
    ReserveConfig memory config = _findReserveConfig(configs, asset);
    assertFalse(config.isFrozen, string.concat(config.symbol, '_ALREADY_FROZEN'));
    assertEq(config.ltv, ltv, string.concat(config.symbol, '_LTV'));
  }

  /// @dev asserts the reserve factor of a reserve
  function _assertReserveFactor(
    ReserveConfig[] memory configs,
    address asset,
    uint256 reserveFactor
  ) internal pure {
    ReserveConfig memory config = _findReserveConfig(configs, asset);
    assertEq(config.reserveFactor, reserveFactor, string.concat(config.symbol, '_RESERVE_FACTOR'));
  }

  /// @dev bit of a reserve in the E-Mode bitmaps (1 << reserve id)
  function _bit(address asset) internal view returns (uint128) {
    return uint128(1) << AaveV3Ethereum.POOL.getReserveData(asset).id;
  }

  /// @dev LTV of an E-Mode category
  function _eModeLtv(uint8 id) internal view returns (uint256) {
    return AaveV3Ethereum.POOL.getEModeCategoryCollateralConfig(id).ltv;
  }

  /// @dev asserts LTV, liquidation threshold and liquidation bonus of an E-Mode category
  function _assertEModeCollateralConfig(
    uint8 id,
    uint256 ltv,
    uint256 liquidationThreshold,
    uint256 liquidationBonus
  ) internal view {
    DataTypes.CollateralConfig memory cfg = AaveV3Ethereum.POOL.getEModeCategoryCollateralConfig(
      id
    );
    assertEq(cfg.ltv, ltv);
    assertEq(cfg.liquidationThreshold, liquidationThreshold);
    assertEq(cfg.liquidationBonus, liquidationBonus);
  }

  /// @dev E-Modes, in ascending id order, where a reserve frozen by this payload is collateral
  function _expectedCollateralEModes(address asset) internal pure returns (uint8[] memory eModes) {
    if (
      asset == AaveV3EthereumAssets.osETH_UNDERLYING ||
      asset == AaveV3EthereumAssets.rETH_UNDERLYING
    ) {
      eModes = new uint8[](1);
      eModes[0] = AaveV3EthereumEModes.WETH_wstETH_cbETH_rETH_weETH_osETH_ETHx__WETH; // 1
    } else if (asset == AaveV3EthereumAssets.LBTC_UNDERLYING) {
      eModes = new uint8[](3);
      eModes[0] = AaveV3EthereumEModes.LBTC__WBTC; // 4
      eModes[1] = AaveV3EthereumEModes.LBTC__cbBTC; // 5
      eModes[2] = AaveV3EthereumEModes.LBTC__tBTC; // 6
    } else if (asset == AaveV3EthereumAssets.eBTC_UNDERLYING) {
      eModes = new uint8[](1);
      eModes[0] = AaveV3EthereumEModes.eBTC__WBTC; // 7
    } else if (asset == AaveV3EthereumAssets.tETH_UNDERLYING) {
      eModes = new uint8[](1);
      eModes[0] = AaveV3EthereumEModes.tETH__USDC_USDT; // 21
    } else if (asset == AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING) {
      eModes = new uint8[](2);
      eModes[0] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe; // 47
      eModes[1] = AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe; // 48
    }
    // BTC.b, LDO and mUSD are not collateral in any E-Mode
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
      asset: AaveV3EthereumAssets.CRV_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.tBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.rETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.crvUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.UNI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.mUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    return borrowUpdates;
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](9);
    frozen = new bool[](9);

    assets[0] = AaveV3EthereumAssets.osETH_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3EthereumAssets.LBTC_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3EthereumAssets.rETH_UNDERLYING;
    frozen[2] = true;
    assets[3] = AaveV3EthereumAssets.eBTC_UNDERLYING;
    frozen[3] = true;
    assets[4] = AaveV3EthereumAssets.BTCb_UNDERLYING;
    frozen[4] = true;
    assets[5] = AaveV3EthereumAssets.tETH_UNDERLYING;
    frozen[5] = true;
    assets[6] = AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING;
    frozen[6] = true;
    assets[7] = AaveV3EthereumAssets.LDO_UNDERLYING;
    frozen[7] = true;
    assets[8] = AaveV3EthereumAssets.mUSD_UNDERLYING;
    frozen[8] = true;
  }
}
