// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826} from './AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826.sol';

/**
 * @dev Test for AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826.t.sol -vv
 */
contract AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826_Test is
  ProtocolV3TestBase
{
  AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25837412);
    proposal = new AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: every PT reserve in
   * scope is matured but not yet frozen, and its caps are already at 1 (which is why the
   * payload only freezes)
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Ethereum.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_eUSDE_29MAY2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_eUSDE_29MAY2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_eUSDE_29MAY2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_eUSDE_29MAY2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_sUSDE_31JUL2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_31JUL2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_31JUL2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_31JUL2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_USDe_31JUL2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_31JUL2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_31JUL2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_USDe_31JUL2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_eUSDE_14AUG2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_eUSDE_14AUG2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_eUSDE_14AUG2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_eUSDE_14AUG2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_sUSDE_25SEP2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_25SEP2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_25SEP2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_25SEP2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_USDe_25SEP2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_25SEP2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_25SEP2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_USDe_25SEP2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_sUSDE_27NOV2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_27NOV2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_27NOV2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_27NOV2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_USDe_27NOV2025_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_27NOV2025_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_27NOV2025_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_USDe_27NOV2025_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_USDe_5FEB2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_5FEB2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_5FEB2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_USDe_5FEB2026_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_sUSDE_5FEB2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_5FEB2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_5FEB2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_5FEB2026_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_srUSDe_2APR2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_srUSDe_2APR2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_srUSDe_2APR2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_srUSDe_2APR2026_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_USDe_7MAY2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDe_7MAY2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDe_7MAY2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_USDe_7MAY2026_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_sUSDE_7MAY2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_sUSDE_7MAY2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_sUSDE_7MAY2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_sUSDE_7MAY2026_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_USDG_28MAY2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_USDG_28MAY2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_USDG_28MAY2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_USDG_28MAY2026_BORROW_CAP_NOT_1');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.PT_srUSDe_25JUN2026_UNDERLYING);
    assertFalse(config.isFrozen, 'PT_srUSDe_25JUN2026_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'PT_srUSDe_25JUN2026_SUPPLY_CAP_NOT_1');
    assertEq(config.borrowCap, 1, 'PT_srUSDe_25JUN2026_BORROW_CAP_NOT_1');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](15);
    updatedAssets[0] = AaveV3EthereumAssets.PT_eUSDE_29MAY2025_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.PT_sUSDE_31JUL2025_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.PT_USDe_31JUL2025_UNDERLYING;
    updatedAssets[3] = AaveV3EthereumAssets.PT_eUSDE_14AUG2025_UNDERLYING;
    updatedAssets[4] = AaveV3EthereumAssets.PT_sUSDE_25SEP2025_UNDERLYING;
    updatedAssets[5] = AaveV3EthereumAssets.PT_USDe_25SEP2025_UNDERLYING;
    updatedAssets[6] = AaveV3EthereumAssets.PT_sUSDE_27NOV2025_UNDERLYING;
    updatedAssets[7] = AaveV3EthereumAssets.PT_USDe_27NOV2025_UNDERLYING;
    updatedAssets[8] = AaveV3EthereumAssets.PT_USDe_5FEB2026_UNDERLYING;
    updatedAssets[9] = AaveV3EthereumAssets.PT_sUSDE_5FEB2026_UNDERLYING;
    updatedAssets[10] = AaveV3EthereumAssets.PT_srUSDe_2APR2026_UNDERLYING;
    updatedAssets[11] = AaveV3EthereumAssets.PT_USDe_7MAY2026_UNDERLYING;
    updatedAssets[12] = AaveV3EthereumAssets.PT_sUSDE_7MAY2026_UNDERLYING;
    updatedAssets[13] = AaveV3EthereumAssets.PT_USDG_28MAY2026_UNDERLYING;
    updatedAssets[14] = AaveV3EthereumAssets.PT_srUSDe_25JUN2026_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](15);
    frozen = new bool[](15);

    assets[0] = AaveV3EthereumAssets.PT_eUSDE_29MAY2025_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3EthereumAssets.PT_sUSDE_31JUL2025_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3EthereumAssets.PT_USDe_31JUL2025_UNDERLYING;
    frozen[2] = true;
    assets[3] = AaveV3EthereumAssets.PT_eUSDE_14AUG2025_UNDERLYING;
    frozen[3] = true;
    assets[4] = AaveV3EthereumAssets.PT_sUSDE_25SEP2025_UNDERLYING;
    frozen[4] = true;
    assets[5] = AaveV3EthereumAssets.PT_USDe_25SEP2025_UNDERLYING;
    frozen[5] = true;
    assets[6] = AaveV3EthereumAssets.PT_sUSDE_27NOV2025_UNDERLYING;
    frozen[6] = true;
    assets[7] = AaveV3EthereumAssets.PT_USDe_27NOV2025_UNDERLYING;
    frozen[7] = true;
    assets[8] = AaveV3EthereumAssets.PT_USDe_5FEB2026_UNDERLYING;
    frozen[8] = true;
    assets[9] = AaveV3EthereumAssets.PT_sUSDE_5FEB2026_UNDERLYING;
    frozen[9] = true;
    assets[10] = AaveV3EthereumAssets.PT_srUSDe_2APR2026_UNDERLYING;
    frozen[10] = true;
    assets[11] = AaveV3EthereumAssets.PT_USDe_7MAY2026_UNDERLYING;
    frozen[11] = true;
    assets[12] = AaveV3EthereumAssets.PT_sUSDE_7MAY2026_UNDERLYING;
    frozen[12] = true;
    assets[13] = AaveV3EthereumAssets.PT_USDG_28MAY2026_UNDERLYING;
    frozen[13] = true;
    assets[14] = AaveV3EthereumAssets.PT_srUSDe_25JUN2026_UNDERLYING;
    frozen[14] = true;
  }

  /**
   * @dev on v3.7 freezing a reserve also sets its LTV to 0 (the previous LTV is parked in
   * pendingLtv), which the generic freeze modeling of the test base does not cover; the two
   * PTs below are the only ones in scope with a non-zero LTV (0.05%)
   */
  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[]
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](2);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.PT_USDe_5FEB2026_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.PT_sUSDE_5FEB2026_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }
}
