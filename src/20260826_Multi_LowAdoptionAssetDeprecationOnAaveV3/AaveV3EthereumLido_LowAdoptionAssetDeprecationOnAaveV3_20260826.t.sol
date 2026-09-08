// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumLido, AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is
  ProtocolV3TestBase
{
  AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25837412);
    proposal = new AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3EthereumLido.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3EthereumLido.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3EthereumLidoAssets.ezETH_UNDERLYING);
    assertFalse(config.isFrozen, 'ezETH_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'ezETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumLidoAssets.USDS_UNDERLYING);
    assertFalse(config.isFrozen, 'USDS_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'USDS_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'USDS_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumLidoAssets.sUSDe_UNDERLYING);
    assertFalse(config.isFrozen, 'sUSDe_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'sUSDe_BORROW_CAP');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](3);
    updatedAssets[0] = AaveV3EthereumLidoAssets.ezETH_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumLidoAssets.USDS_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumLidoAssets.sUSDe_UNDERLYING;
    reserveConfigChangesTest(AaveV3EthereumLido.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](3);
    frozen = new bool[](3);

    assets[0] = AaveV3EthereumLidoAssets.ezETH_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3EthereumLidoAssets.USDS_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3EthereumLidoAssets.sUSDe_UNDERLYING;
    frozen[2] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory)
  {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate;
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](2);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumLidoAssets.ezETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumLidoAssets.sUSDe_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    return capsUpdate;
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](1);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumLidoAssets.USDS_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    return borrowUpdates;
  }
}
