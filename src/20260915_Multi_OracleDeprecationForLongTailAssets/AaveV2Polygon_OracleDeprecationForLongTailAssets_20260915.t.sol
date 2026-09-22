// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Polygon, AaveV2PolygonAssets} from 'aave-address-book/AaveV2Polygon.sol';

import 'forge-std/Test.sol';
import {ProtocolV2TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.sol';

import {ChainlinkPolygon} from 'aave-address-book/ChainlinkPolygon.sol';
import {IChainlinkAggregator} from 'aave-helpers/src/interfaces/IChainlinkAggregator.sol';

import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV2TestBase {
  AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 94244629);
    proposal = new AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915',
      AaveV2Polygon.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Polygon
          .POOL
          .getReserveData(AaveV2PolygonAssets.BAL_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'BAL kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'BAL base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'BAL s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'BAL s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'a78f3bc07035422f6f69c3f2b72fccd0487348fa'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'BAL stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'BAL stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Polygon
          .POOL
          .getReserveData(AaveV2PolygonAssets.GHST_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'GHST kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'GHST base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'GHST s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'GHST s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'fe72f0c532c4e7cfa65fcbd3b92d926d26fb73a9'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'GHST stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'GHST stable slope2 unchanged'
      );
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV2Polygon.ORACLE.getSourceOfAsset(AaveV2PolygonAssets.BAL_UNDERLYING),
      proposal.BAL_PRICE_FEED(),
      'BAL source'
    );
    assertEq(
      AaveV2Polygon.ORACLE.getAssetPrice(AaveV2PolygonAssets.BAL_UNDERLYING),
      ((12840000 * 1e18) / uint256(IChainlinkAggregator(ChainlinkPolygon.ETH__USD).latestAnswer())),
      'BAL oracle output'
    );
    assertEq(
      AaveV2Polygon.ORACLE.getSourceOfAsset(AaveV2PolygonAssets.GHST_UNDERLYING),
      proposal.GHST_PRICE_FEED(),
      'GHST source'
    );
    assertEq(
      AaveV2Polygon.ORACLE.getAssetPrice(AaveV2PolygonAssets.GHST_UNDERLYING),
      ((7930000 * 1e18) / uint256(IChainlinkAggregator(ChainlinkPolygon.ETH__USD).latestAnswer())),
      'GHST oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](2);
    expected[0] = AaveV2Polygon.POOL.getConfiguration(AaveV2PolygonAssets.BAL_UNDERLYING).data;
    expected[1] = AaveV2Polygon.POOL.getConfiguration(AaveV2PolygonAssets.GHST_UNDERLYING).data;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV2Polygon.POOL.getConfiguration(AaveV2PolygonAssets.BAL_UNDERLYING).data,
      expected[0],
      'BAL configuration and untouched fields'
    );
    assertEq(
      AaveV2Polygon.POOL.getConfiguration(AaveV2PolygonAssets.GHST_UNDERLYING).data,
      expected[1],
      'GHST configuration and untouched fields'
    );
  }
}
