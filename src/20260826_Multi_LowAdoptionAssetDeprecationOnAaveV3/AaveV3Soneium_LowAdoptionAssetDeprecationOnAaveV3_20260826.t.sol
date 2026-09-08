// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Soneium, AaveV3SoneiumAssets} from 'aave-address-book/AaveV3Soneium.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('soneium'), 27294389);
    proposal = new AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3Soneium.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Soneium.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3SoneiumAssets.WETH_UNDERLYING);
    assertTrue(config.isFrozen, 'WETH_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3SoneiumAssets.USDCe_UNDERLYING);
    assertTrue(config.isFrozen, 'USDCe_NOT_FROZEN');
    config = _findReserveConfig(allConfigs, AaveV3SoneiumAssets.USDT_UNDERLYING);
    assertTrue(config.isFrozen, 'USDT_NOT_FROZEN');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](3);
    updatedAssets[0] = AaveV3SoneiumAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3SoneiumAssets.USDCe_UNDERLYING;
    updatedAssets[2] = AaveV3SoneiumAssets.USDT_UNDERLYING;
    reserveConfigChangesTest(AaveV3Soneium.POOL, address(proposal), updatedAssets);
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory)
  {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](3);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SoneiumAssets.WETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SoneiumAssets.USDCe_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3SoneiumAssets.USDT_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    return capsUpdate;
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](3);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3SoneiumAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3SoneiumAssets.USDCe_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3SoneiumAssets.USDT_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    return borrowUpdates;
  }
}
