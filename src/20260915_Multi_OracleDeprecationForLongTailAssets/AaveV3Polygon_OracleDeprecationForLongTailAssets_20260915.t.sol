// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @dev Test for AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  address internal _strategyBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 94_244_629);
    proposal = new AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915();
    _strategyBefore = AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(_strategyBefore);
    _ratesBefore[AaveV3PolygonAssets.BAL_UNDERLYING] = strategy.getInterestRateData(
      AaveV3PolygonAssets.BAL_UNDERLYING
    );
    _ratesBefore[AaveV3PolygonAssets.GHST_UNDERLYING] = strategy.getInterestRateData(
      AaveV3PolygonAssets.GHST_UNDERLYING
    );
    _ratesBefore[AaveV3PolygonAssets.miMATIC_UNDERLYING] = strategy.getInterestRateData(
      AaveV3PolygonAssets.miMATIC_UNDERLYING
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Polygon.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](3);
    updatedAssets[0] = AaveV3PolygonAssets.BAL_UNDERLYING;
    updatedAssets[1] = AaveV3PolygonAssets.GHST_UNDERLYING;
    updatedAssets[2] = AaveV3PolygonAssets.miMATIC_UNDERLYING;
    reserveConfigChangesTest(AaveV3Polygon.POOL, address(proposal), updatedAssets);
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](2);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3PolygonAssets.BAL_UNDERLYING, 1, 1);
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate(AaveV3PolygonAssets.miMATIC_UNDERLYING, 1, 1);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](1);
    frozen = new bool[](1);

    assets[0] = AaveV3PolygonAssets.GHST_UNDERLYING;
    frozen[0] = true;
  }
  function _assertRates(bool afterExecution) internal view {
    _validateInterestRateStrategy(
      AaveV3PolygonAssets.BAL_UNDERLYING,
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      _strategyBefore,
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3PolygonAssets.BAL_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution
          ? 200_000_000_000_000_000_000_000_000
          : 50_000_000_000_000_000_000_000_000, // 5% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3PolygonAssets.BAL_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 1_500_000_000_000_000_000_000_000_000 // 150% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3PolygonAssets.GHST_UNDERLYING,
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      _strategyBefore,
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3PolygonAssets.GHST_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3PolygonAssets.GHST_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3PolygonAssets.miMATIC_UNDERLYING,
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      _strategyBefore,
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3PolygonAssets.miMATIC_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3PolygonAssets.miMATIC_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
      AaveV3PolygonAssets.BAL_UNDERLYING,
      proposal.BAL_PRICE_FEED()
    );
    assertEq(
      AaveV3Polygon.ORACLE.getAssetPrice(AaveV3PolygonAssets.BAL_UNDERLYING),
      // $0.1316 (8 decimals)
      13_160_000,
      'BAL oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
      AaveV3PolygonAssets.GHST_UNDERLYING,
      proposal.GHST_PRICE_FEED()
    );
    assertEq(
      AaveV3Polygon.ORACLE.getAssetPrice(AaveV3PolygonAssets.GHST_UNDERLYING),
      // $0.0828 (8 decimals)
      8_280_000,
      'GHST oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
      AaveV3PolygonAssets.miMATIC_UNDERLYING,
      proposal.miMATIC_PRICE_FEED()
    );
    assertEq(
      AaveV3Polygon.ORACLE.getAssetPrice(AaveV3PolygonAssets.miMATIC_UNDERLYING),
      // $0.953 (8 decimals)
      95_300_000,
      'miMATIC oracle output'
    );
  }
}
