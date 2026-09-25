// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Polygon, AaveV2PolygonAssets} from 'aave-address-book/AaveV2Polygon.sol';

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {WadRayMath} from 'aave-v4/libraries/math/WadRayMath.sol';
import {ProtocolV2TestBase, ReserveConfig, InterestStrategyValues} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.sol';

import {ChainlinkPolygon} from 'aave-address-book/ChainlinkPolygon.sol';
import {OracleTestUtils} from './OracleTestUtils.sol';

import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';
import {IAaveV2ConfigEngine} from 'aave-helpers/src/v2-config-engine/IAaveV2ConfigEngine.sol';
import {IV2RateStrategyFactory} from 'aave-helpers/src/v2-config-engine/IV2RateStrategyFactory.sol';

/**
 * @dev Test for AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV2TestBase {
  AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategy) internal _strategiesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 94_244_629);
    proposal = new AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915();
    _strategiesBefore[AaveV2PolygonAssets.BAL_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Polygon
        .POOL
        .getReserveData(AaveV2PolygonAssets.BAL_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2PolygonAssets.GHST_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Polygon
        .POOL
        .getReserveData(AaveV2PolygonAssets.GHST_UNDERLYING)
        .interestRateStrategyAddress
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915',
      AaveV2Polygon.POOL,
      address(proposal)
    );
  }

  function test_rateStrategies() public {
    _assertRates(false);
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
  }

  function test_oracles() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertOracles();
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[AaveV2PolygonAssets.BAL_UNDERLYING];
      _validateRates(
        AaveV2PolygonAssets.BAL_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Polygon.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: WadRayMath.bpsToRay(afterExecution ? 40_00 : 300_00) // 300% -> 40% (2 decimals converted to 27 decimals)
        })
      );
    }
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2PolygonAssets.GHST_UNDERLYING
      ];
      _validateRates(
        AaveV2PolygonAssets.GHST_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Polygon.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: WadRayMath.bpsToRay(afterExecution ? 40_00 : 300_00) // 300% -> 40% (2 decimals converted to 27 decimals)
        })
      );
    }
  }
  function _validateRates(
    address asset,
    bool afterExecution,
    InterestStrategyValues memory expected
  ) internal view {
    address expectedStrategy = address(_strategiesBefore[asset]);
    if (afterExecution) {
      expectedStrategy = IAaveV2ConfigEngine(AaveV2Polygon.CONFIG_ENGINE)
        .RATE_STRATEGIES_FACTORY()
        .getStrategyByParams(
          IV2RateStrategyFactory.RateStrategyParams({
            optimalUtilizationRate: expected.optimalUsageRatio,
            baseVariableBorrowRate: expected.baseVariableBorrowRate,
            variableRateSlope1: expected.variableRateSlope1,
            variableRateSlope2: expected.variableRateSlope2,
            stableRateSlope1: expected.stableRateSlope1,
            stableRateSlope2: expected.stableRateSlope2
          })
        );
      assertNotEq(expectedStrategy, address(0), 'Expected strategy missing from factory');
    }
    _validateInterestRateStrategy(
      AaveV2Polygon.POOL.getReserveData(asset).interestRateStrategyAddress,
      expectedStrategy,
      expected
    );
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
}
