// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Polygon, AaveV2PolygonAssets} from 'aave-address-book/AaveV2Polygon.sol';

import 'forge-std/Test.sol';
import {ProtocolV2TestBase, ReserveConfig, InterestStrategyValues} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.sol';

import {ChainlinkPolygon} from 'aave-address-book/ChainlinkPolygon.sol';
import {OracleTestUtils} from './OracleTestUtils.sol';

import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV2TestBase {
  AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 94_244_629);
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
      address strategy = AaveV2Polygon
        .POOL
        .getReserveData(AaveV2PolygonAssets.BAL_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0xA78F3bc07035422f6f69c3f2B72fcCd0487348FA
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Polygon.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Polygon
        .POOL
        .getReserveData(AaveV2PolygonAssets.GHST_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0xfe72F0c532c4E7cfA65FCbd3B92D926d26Fb73a9
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Polygon.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV2Polygon.POOL_ADDRESSES_PROVIDER,
      AaveV2PolygonAssets.BAL_UNDERLYING,
      proposal.BAL_PRICE_FEED()
    );
    assertEq(
      AaveV2Polygon.ORACLE.getAssetPrice(AaveV2PolygonAssets.BAL_UNDERLYING),
      // $0.1284 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(12_840_000, ChainlinkPolygon.ETH__USD),
      'BAL oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Polygon.POOL_ADDRESSES_PROVIDER,
      AaveV2PolygonAssets.GHST_UNDERLYING,
      proposal.GHST_PRICE_FEED()
    );
    assertEq(
      AaveV2Polygon.ORACLE.getAssetPrice(AaveV2PolygonAssets.GHST_UNDERLYING),
      // $0.0793 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(7_930_000, ChainlinkPolygon.ETH__USD),
      'GHST oracle output'
    );
  }
  function test_configurationAndUntouchedFields() public {
    uint256[] memory expected = new uint256[](2);
    expected[0] = AaveV2Polygon.POOL.getConfiguration(AaveV2PolygonAssets.BAL_UNDERLYING).data;
    expected[1] = AaveV2Polygon.POOL.getConfiguration(AaveV2PolygonAssets.GHST_UNDERLYING).data;
    GovV3Helpers.executePayload(vm, address(proposal));
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
