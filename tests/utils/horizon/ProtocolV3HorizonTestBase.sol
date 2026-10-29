// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from 'forge-std/console2.sol';
import {IERC20} from 'aave-helpers/lib/aave-address-book/lib/aave-v3-origin/lib/forge-std/src/interfaces/IERC20.sol';
import {IPool} from 'aave-v3-origin/contracts/interfaces/IPool.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IPoolAddressesProvider} from 'aave-v3-origin/contracts/interfaces/IPoolAddressesProvider.sol';
import {IAaveOracle} from 'aave-v3-origin/contracts/interfaces/IAaveOracle.sol';
import {IPoolConfigurator} from 'aave-v3-origin/contracts/interfaces/IPoolConfigurator.sol';
import {IACLManager} from 'aave-v3-origin/contracts/interfaces/IACLManager.sol';
import {AaveV3EthereumHorizonCustom} from './AaveV3EthereumHorizonCustom.sol';
import {AaveHorizonGovV3Helpers} from './AaveHorizonGovV3Helpers.sol';
import {HorizonRwaWhitelistHelper} from './HorizonRwaWhitelistHelper.sol';
import {HorizonConfigAssertionHelper} from './HorizonConfigAssertionHelper.sol';
import {Errors} from './Errors.sol';
import {ISafeAccount} from './ISafeAccount.sol';

/**
 * @dev Adapted from ProtocolV3TestBase for the Horizon market (currently at Aave v3.3).
 * - GHO is listed as a normal reserve like prime market, removes special branches.
 * - Enable eMode before supplying if available.
 * - Skip liquidation with receiveAToken=true when collateral is RWA, since it is disabled.
 * - Adds helper to return all actors used in E2E test such that they may be whitelisted to hold RWA tokens.
 * - Update errors to v3.3 string format.
 */
abstract contract ProtocolV3HorizonTestBase is
  ProtocolV3TestBase,
  HorizonRwaWhitelistHelper,
  HorizonConfigAssertionHelper
{
  struct E2ETestAssetLocalVars {
    uint256 collateralAssetAmount;
    uint256 testAssetAmount;
    uint256 aTokenTotalSupply;
    uint256 variableDebtTokenTotalSupply;
    uint256 borrowAmount;
  }

  // E2E test actors, reused across all asset tests
  address internal emodeCollateralSupplier;
  address internal regularCollateralSupplier;
  address internal testAssetSupplier;
  address internal liquidator;

  /**
   * @dev runs the default test suite that should run on any proposal touching the aave protocol which includes:
   * - diffing the config
   * - checking if the changes are plausible (no conflicting config changes etc)
   * - running an e2e testsuite over all assets
   * @param reportName the name of the report
   * @param pool the pool that should be tested
   * @param executeTx the function that will execute the transaction that is being tested
   */
  function defaultTest_v3_3(
    string memory reportName,
    IPool pool,
    function() internal executeTx
  ) internal returns (ReserveConfig[] memory, ReserveConfig[] memory) {
    string memory beforeString = string(abi.encodePacked(reportName, '_before'));
    ReserveConfig[] memory configBefore = createConfigurationSnapshot(beforeString, pool);

    uint256 startGas = gasleft();

    vm.startStateDiffRecording();
    vm.recordLogs();
    executeTx(); // execute the transaction that is being tested
    string memory rawDiff = vm.getStateDiffJson();
    string memory logsJson = vm.getRecordedLogsJson();

    uint256 gasUsed = startGas - gasleft();
    assertLt(gasUsed, (block.gaslimit * 95) / 100, 'BLOCK_GAS_LIMIT_EXCEEDED'); // 5% is kept as a buffer

    string memory afterString = string(abi.encodePacked(reportName, '_after'));
    ReserveConfig[] memory configAfter = createConfigurationSnapshot(afterString, pool);
    // write into the snapshot instead of overwriting it, as aave-helpers' defaultTest does
    vm.writeJson(rawDiff, string(abi.encodePacked('./reports/', afterString, '.json')), '$.raw');
    vm.writeJson(logsJson, string(abi.encodePacked('./reports/', afterString, '.json')), '$.logs');

    diffReports(beforeString, afterString);

    // pool-wide validations
    _runHorizonValidations(pool, configAfter);

    configChangePlausibilityTest(pool, configBefore, configAfter);

    // whitelist E2E actors + aTokens on RWA compliance systems before running E2E
    _initTestActors();
    _whitelistRwaUsers(_testActorsArray());
    _whitelistRwaPool(pool);

    e2eTest_v3_3(pool);
    return (configBefore, configAfter);
  }

  /**
   * @dev Post-execution test suite. Forks after the payload has already been executed
   *      on mainnet and validates live state + runs full E2E without executing a payload.
   *      Skips aToken whitelisting since they are already whitelisted on mainnet.
   */
  function defaultTest_v3_3_postExecution(IPool pool) public {
    ReserveConfig[] memory configs = _getReservesConfigs(pool);
    _runHorizonValidations(pool, configs);

    _initTestActors();
    _whitelistRwaUsers(_testActorsArray());
    _whitelistRwaPool(pool);

    e2eTest_v3_3(pool);
  }

  /**
   * @dev Makes a e2e test including withdrawals/borrows and supplies to various reserves.
   * @param pool the pool that should be tested
   */
  function e2eTest_v3_3(IPool pool) public {
    ReserveConfig[] memory configs = _getReservesConfigs(pool);
    uint256 snapshot = vm.snapshotState();
    for (uint256 c; c < configs.length; c++) {
      if (!_isGoodCollateral(configs[c])) {
        continue;
      }
      for (uint256 i; i < configs.length; i++) {
        if (_includeInE2e(configs[i])) {
          e2eTestAsset_v3_3(pool, configs[c], configs[i]);
          vm.revertToState(snapshot);
        } else {
          console.log('E2E: TestAsset %s SKIPPED', configs[i].symbol);
        }
      }
    }
  }

  function e2eTestAsset_v3_3(
    IPool pool,
    ReserveConfig memory collateralConfig,
    ReserveConfig memory testAssetConfig
  ) public {
    console.log(
      'E2E: Collateral %s, TestAsset %s',
      collateralConfig.symbol,
      testAssetConfig.symbol
    );
    E2ETestAssetLocalVars memory vars;
    require(collateralConfig.usageAsCollateralEnabled, 'COLLATERAL_CONFIG_MUST_BE_COLLATERAL');
    vars.collateralAssetAmount = _getTokenAmountByDollarValue(pool, collateralConfig, 100_000);
    vars.testAssetAmount = _getTokenAmountByDollarValue(pool, testAssetConfig, 10_000);

    // remove caps as they should not prevent testing
    IPoolAddressesProvider addressesProvider = IPoolAddressesProvider(pool.ADDRESSES_PROVIDER());
    IPoolConfigurator poolConfigurator = IPoolConfigurator(addressesProvider.getPoolConfigurator());
    vm.startPrank(addressesProvider.getACLAdmin());
    if (collateralConfig.supplyCap != 0) {
      poolConfigurator.setSupplyCap(collateralConfig.underlying, 0);
    }
    if (testAssetConfig.supplyCap != 0) {
      poolConfigurator.setSupplyCap(testAssetConfig.underlying, 0);
    }
    if (testAssetConfig.borrowCap != 0) {
      poolConfigurator.setBorrowCap(testAssetConfig.underlying, 0);
    }
    vm.stopPrank();

    // eMode supplier enters eMode; regular supplier stays in eMode 0
    _enableIfEMode(collateralConfig, pool, emodeCollateralSupplier);
    _supply(collateralConfig, pool, emodeCollateralSupplier, vars.collateralAssetAmount);
    _supply(collateralConfig, pool, regularCollateralSupplier, vars.collateralAssetAmount);
    _supply(testAssetConfig, pool, testAssetSupplier, vars.testAssetAmount);

    uint256 snapshotAfterDeposits = vm.snapshotState();

    // test deposits and withdrawals
    vars.aTokenTotalSupply = IERC20(testAssetConfig.aToken).totalSupply();
    vars.variableDebtTokenTotalSupply = IERC20(testAssetConfig.variableDebtToken).totalSupply();

    uint256 borrowCap = vars.variableDebtTokenTotalSupply / 10 ** testAssetConfig.decimals + 1;

    vm.prank(addressesProvider.getACLAdmin());
    poolConfigurator.setSupplyCap(
      testAssetConfig.underlying,
      vars.aTokenTotalSupply / 10 ** testAssetConfig.decimals + 1
    );
    vm.prank(addressesProvider.getACLAdmin());
    poolConfigurator.setBorrowCap(testAssetConfig.underlying, borrowCap);

    // caps should revert when supplying slightly more
    vm.expectRevert(bytes(Errors.SUPPLY_CAP_EXCEEDED));
    vm.prank(testAssetSupplier);
    pool.supply({
      asset: testAssetConfig.underlying,
      amount: 11 ** testAssetConfig.decimals,
      onBehalfOf: testAssetSupplier,
      referralCode: 0
    });
    if (testAssetConfig.borrowingEnabled) {
      // enough to exceed borrow cap
      vars.borrowAmount = 11 ** testAssetConfig.decimals;

      if (vars.aTokenTotalSupply < vars.borrowAmount) {
        vm.prank(addressesProvider.getACLAdmin());
        poolConfigurator.setSupplyCap(testAssetConfig.underlying, 0);

        _supply(
          testAssetConfig,
          pool,
          testAssetSupplier,
          vars.borrowAmount - vars.aTokenTotalSupply
        );

        _supply(
          collateralConfig,
          pool,
          regularCollateralSupplier,
          (vars.collateralAssetAmount * vars.borrowAmount) / vars.aTokenTotalSupply
        );
      }

      vm.expectRevert(bytes(Errors.BORROW_CAP_EXCEEDED));
      vm.prank(regularCollateralSupplier);
      pool.borrow({
        asset: testAssetConfig.underlying,
        amount: vars.borrowAmount,
        interestRateMode: 2,
        referralCode: 0,
        onBehalfOf: regularCollateralSupplier
      });
    }

    vm.revertToState(snapshotAfterDeposits);

    _withdraw(testAssetConfig, pool, testAssetSupplier, vars.testAssetAmount / 2);
    _withdraw(testAssetConfig, pool, testAssetSupplier, UINT256_MAX);

    vm.revertToState(snapshotAfterDeposits);

    // non-emode borrow/repay/liquidation, only when the collateral's default-mode LTV can back
    // the borrow. Collateral usable only within an eMode is exercised by the eMode branch below.
    (, , uint256 availableBorrowsBase, , , ) = pool.getUserAccountData(regularCollateralSupplier);
    if (
      testAssetConfig.borrowingEnabled &&
      availableBorrowsBase >= _baseValueOf(pool, testAssetConfig, vars.testAssetAmount)
    ) {
      _testBorrowRepayLiquidation(
        pool,
        collateralConfig,
        testAssetConfig,
        regularCollateralSupplier,
        vars.testAssetAmount,
        snapshotAfterDeposits
      );
    } else if (testAssetConfig.borrowingEnabled) {
      console.log('E2E: non-emode borrow SKIPPED for collateral %s', collateralConfig.symbol);
    }

    // eMode: additional borrow/repay test if asset is eMode-borrowable
    if (
      testAssetConfig.borrowingEnabled &&
      _isBorrowableInCollateralEMode(pool, collateralConfig, testAssetConfig)
    ) {
      vm.revertToState(snapshotAfterDeposits);
      _testBorrowRepayLiquidation(
        pool,
        collateralConfig,
        testAssetConfig,
        emodeCollateralSupplier,
        vars.testAssetAmount,
        snapshotAfterDeposits
      );
    }

    vm.revertToState(snapshotAfterDeposits);

    // test flashloans
    if (testAssetConfig.isFlashloanable) {
      _flashLoan({
        config: testAssetConfig,
        pool: pool,
        user: regularCollateralSupplier,
        receiverAddress: address(this),
        amount: vars.testAssetAmount,
        interestRateMode: 0
      });

      if (testAssetConfig.borrowingEnabled) {
        _flashLoan({
          config: testAssetConfig,
          pool: pool,
          user: regularCollateralSupplier,
          receiverAddress: address(this),
          amount: vars.testAssetAmount,
          interestRateMode: 2
        });
      }
    }
  }

  function _pool() internal pure returns (IPool) {
    return IPool(AaveV3EthereumHorizonCustom.POOL);
  }

  /**
   * @dev Returns the value of `amount` of `config`'s underlying in the oracle base currency (8 decimals),
   *      matching the units returned by `IPool.getUserAccountData`.
   */
  function _baseValueOf(
    IPool pool,
    ReserveConfig memory config,
    uint256 amount
  ) internal view returns (uint256) {
    IAaveOracle oracle = IAaveOracle(
      IPoolAddressesProvider(pool.ADDRESSES_PROVIDER()).getPriceOracle()
    );
    return (amount * oracle.getAssetPrice(config.underlying)) / 10 ** config.decimals;
  }

  /**
   * @dev Execute a Horizon payload through the real executor path.
   * HORIZON_EMERGENCY calls HORIZON_EXECUTOR.executeTransaction() which delegatecalls
   * the payload. Matches the production multisig execution flow exactly.
   */
  function _executeHorizonPayload(address payload) internal {
    (address to, bytes memory data, ) = AaveHorizonGovV3Helpers.createExecutorCalldata(payload);

    vm.startPrank(AaveV3EthereumHorizonCustom.HORIZON_EMERGENCY);
    (bool success, bytes memory resultData) = to.call(data);
    vm.stopPrank();
    if (!success) {
      if (resultData.length > 0) {
        assembly {
          revert(add(resultData, 32), mload(resultData))
        }
      }
      revert('_executeHorizonPayload: unknown error');
    }
  }

  function _initTestActors() internal {
    emodeCollateralSupplier = makeAddr('emodeCollateralSupplier');
    regularCollateralSupplier = makeAddr('regularCollateralSupplier');
    testAssetSupplier = makeAddr('testAssetSupplier');
    liquidator = makeAddr('liquidator');
  }

  function _testActorsArray() internal view returns (address[] memory actors) {
    actors = new address[](4);
    actors[0] = emodeCollateralSupplier;
    actors[1] = regularCollateralSupplier;
    actors[2] = testAssetSupplier;
    actors[3] = liquidator;
  }

  function _testBorrowRepayLiquidation(
    IPool pool,
    ReserveConfig memory collateralConfig,
    ReserveConfig memory testAssetConfig,
    address borrower,
    uint256 testAssetAmount,
    uint256 snapshotAfterDeposits
  ) internal {
    // borrow and repay
    _borrow({config: testAssetConfig, pool: pool, user: borrower, amount: testAssetAmount});

    uint256 snapshotBeforeRepay = vm.snapshotState();

    _repay({
      config: testAssetConfig,
      pool: pool,
      user: borrower,
      amount: testAssetAmount,
      withATokens: false
    });

    vm.revertToState(snapshotBeforeRepay);

    _repay({
      config: testAssetConfig,
      pool: pool,
      user: borrower,
      amount: testAssetAmount,
      withATokens: true
    });

    vm.revertToState(snapshotAfterDeposits);

    // liquidation
    _borrow({config: testAssetConfig, pool: pool, user: borrower, amount: testAssetAmount});

    if (testAssetConfig.underlying != collateralConfig.underlying) {
      _changeAssetPrice(pool, testAssetConfig, 1000_00);
    } else {
      _setAssetLtvAndLiquidationThreshold({
        pool: pool,
        config: testAssetConfig,
        newLtv: 5_00,
        newLiquidationThreshold: 5_00
      });
    }

    uint256 snapshotBeforeLiquidation = vm.snapshotState();

    _liquidationCall({
      collateralConfig: collateralConfig,
      debtConfig: testAssetConfig,
      pool: pool,
      liquidator: liquidator,
      borrower: borrower,
      debtToCover: UINT256_MAX,
      receiveAToken: false
    });

    vm.revertToState(snapshotBeforeLiquidation);

    if (!_isRwaToken(collateralConfig)) {
      _liquidationCall({
        collateralConfig: collateralConfig,
        debtConfig: testAssetConfig,
        pool: pool,
        liquidator: liquidator,
        borrower: borrower,
        debtToCover: UINT256_MAX,
        receiveAToken: true
      });
    } else {
      // attempting to borrow RWA should revert (borrowing disabled)
      vm.expectRevert(bytes(Errors.BORROWING_NOT_ENABLED));
      vm.prank(borrower);
      pool.borrow({
        asset: collateralConfig.underlying,
        amount: 1,
        interestRateMode: 2,
        referralCode: 0,
        onBehalfOf: borrower
      });
    }
  }

  function _isRwaToken(ReserveConfig memory config) internal view returns (bool) {
    return _isRwaAToken(config.aToken);
  }

  function _enableIfEMode(ReserveConfig memory config, IPool pool, address user) internal {
    vm.prank(user);
    pool.setUserEMode(0);

    // eMode id 0 is skipped intentionally as it is the reserved default
    for (uint256 id = 1; id <= 255; ++id) {
      uint256 reserveId = pool.getReserveData(config.underlying).id;
      if ((pool.getEModeCategoryCollateralBitmap(uint8(id)) >> reserveId) & 1 != 0) {
        vm.prank(user);
        pool.setUserEMode(uint8(id));
        break;
      }
    }
  }

  function _isGoodCollateral(ReserveConfig memory config) internal pure returns (bool) {
    return _includeInE2e(config) && config.usageAsCollateralEnabled && config.ltv != 0;
  }

  /**
   * @dev Overrides `_deposit` to use whale transfers for tokens incompatible with
   *      foundry's `deal` (e.g. Securitize DSTokens that store balances in an external data store).
   */
  function _supply(
    ReserveConfig memory config,
    IPool pool,
    address user,
    uint256 amount
  ) internal virtual {
    if (_needsWhaleDeal(config.underlying)) {
      require(!config.isFrozen, 'DEPOSIT(): FROZEN_RESERVE');
      require(config.isActive, 'DEPOSIT(): INACTIVE_RESERVE');
      require(!config.isPaused, 'DEPOSIT(): PAUSED_RESERVE');

      uint256 aTokenBefore = IERC20(config.aToken).balanceOf(user);

      _dealRwaToken(config.underlying, user, amount);

      vm.startPrank(user);
      IERC20(config.underlying).approve(address(pool), amount);
      console.log('SUPPLY: %s, Amount: %s', config.symbol, amount);
      pool.supply(config.underlying, amount, user, 0);
      vm.stopPrank();

      uint256 aTokenAfter = IERC20(config.aToken).balanceOf(user);
      assertApproxEqAbs(aTokenAfter, aTokenBefore + amount, 2);
    } else {
      _deposit(config, pool, user, amount);
    }
  }

  /**
   * @dev Checks if testAsset is borrowable in any eMode where collateral is accepted.
   */
  function _isBorrowableInCollateralEMode(
    IPool pool,
    ReserveConfig memory collateralConfig,
    ReserveConfig memory testAssetConfig
  ) internal view returns (bool) {
    uint256 collateralReserveId = pool.getReserveData(collateralConfig.underlying).id;
    uint256 testReserveId = pool.getReserveData(testAssetConfig.underlying).id;
    for (uint256 id = 1; id <= 255; ++id) {
      bool collateralInEMode = (pool.getEModeCategoryCollateralBitmap(uint8(id)) >>
        collateralReserveId) &
        1 !=
        0;
      bool borrowableInEMode = (pool.getEModeCategoryBorrowableBitmap(uint8(id)) >> testReserveId) &
        1 !=
        0;
      if (collateralInEMode && borrowableInEMode) return true;
    }
    return false;
  }

  function _setExpectedConfig() internal virtual {}

  // ---------------------------------------------------------------------------
  // Gnosis Safe multisig transaction helpers
  // ---------------------------------------------------------------------------

  /**
   * @dev Execute a transaction as the HORIZON_EMERGENCY multisig.
   * @param to      The `to` address of the Safe transaction.
   * @param data    The calldata of the Safe transaction.
   * @param operation 0 = call, 1 = delegatecall.
   */
  function _executeEmergencyMultisigTx(
    address to,
    bytes memory data,
    uint8 operation,
    uint256 nonce
  ) internal {
    _executeSafeTx({
      safe: AaveV3EthereumHorizonCustom.HORIZON_EMERGENCY,
      to: to,
      data: data,
      operation: operation,
      nonce: nonce
    });
  }

  /**
   * @dev Execute a transaction as the HORIZON_OPS multisig.
   * @param to        The `to` address of the Safe transaction.
   * @param data      The calldata of the Safe transaction.
   * @param operation 0 = call, 1 = delegatecall.
   * @param nonce     The Safe nonce to set before execution.
   */
  function _executeOpsMultisigTx(
    address to,
    bytes memory data,
    uint8 operation,
    uint256 nonce
  ) internal {
    _executeSafeTx({
      safe: AaveV3EthereumHorizonCustom.HORIZON_OPS,
      to: to,
      data: data,
      operation: operation,
      nonce: nonce
    });
  }

  /**
   * @dev Core Safe execution: sets threshold to 1 and nonce, picks the first owner,
   *      and calls execTransaction with a minimal pre-approved signature.
   */
  function _executeSafeTx(
    address safe,
    address to,
    bytes memory data,
    uint8 operation,
    uint256 nonce
  ) internal {
    // reset signer threshold to 1 (slot 4) and set nonce (slot 5)
    vm.store(safe, bytes32(uint256(4)), bytes32(uint256(1)));
    // force set nonce for simulation
    vm.store(safe, bytes32(uint256(5)), bytes32(nonce));
    address signer = ISafeAccount(safe).getOwners()[0];

    vm.prank(signer);
    (bool ok, bytes memory ret) = safe.call(
      abi.encodeCall(
        ISafeAccount.execTransaction,
        (
          to, // to
          0, // value
          data,
          operation,
          0, // safeTxGas
          0, // baseGas
          0, // gasPrice
          address(0), // gasToken
          payable(address(0)), // refundReceiver
          abi.encodePacked(bytes32(uint256(uint160(signer))), bytes32(0), uint8(1)) // r, s, v
        )
      )
    );

    if (!ok) {
      if (ret.length > 0) {
        assembly {
          revert(add(ret, 32), mload(ret))
        }
      }
      revert('_executeSafeTx: unknown error');
    }
  }
}
