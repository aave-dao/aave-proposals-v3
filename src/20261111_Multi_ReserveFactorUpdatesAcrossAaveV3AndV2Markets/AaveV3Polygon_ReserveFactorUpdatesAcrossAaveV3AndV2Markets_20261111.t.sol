// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111} from './AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol';

/**
 * @dev Test for AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol -vv
 */
contract AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111_Test is
  ProtocolV3TestBase
{
  uint256 internal constant USDT0_RF = 30_00;
  uint256 internal constant USDCn_RF = 25_00;
  uint256 internal constant DAI_RF = 70_00;
  uint256 internal constant WETH_RF = 25_00;
  uint256 internal constant WPOL_RF = 50_00;
  uint256 internal constant WBTC_RF = 100_00;
  uint256 internal constant wstETH_RF = 100_00;

  AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 97145514);
    proposal = new AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Polygon_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111',
      AaveV3Polygon.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](7);
    updatedAssets[0] = AaveV3PolygonAssets.USDT0_UNDERLYING;
    updatedAssets[1] = AaveV3PolygonAssets.USDCn_UNDERLYING;
    updatedAssets[2] = AaveV3PolygonAssets.DAI_UNDERLYING;
    updatedAssets[3] = AaveV3PolygonAssets.WETH_UNDERLYING;
    updatedAssets[4] = AaveV3PolygonAssets.WPOL_UNDERLYING;
    updatedAssets[5] = AaveV3PolygonAssets.WBTC_UNDERLYING;
    updatedAssets[6] = AaveV3PolygonAssets.wstETH_UNDERLYING;
    reserveConfigChangesTest(AaveV3Polygon.POOL, address(proposal), updatedAssets);
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
      asset: AaveV3PolygonAssets.USDT0_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: USDT0_RF
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.USDCn_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: USDCn_RF
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.DAI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: DAI_RF
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.WETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WETH_RF
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.WPOL_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WPOL_RF
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.WBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WBTC_RF
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3PolygonAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: wstETH_RF
    });
    return borrowUpdates;
  }
}
