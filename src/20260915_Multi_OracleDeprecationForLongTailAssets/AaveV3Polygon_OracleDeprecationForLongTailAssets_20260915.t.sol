// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 94_244_629);
    proposal = new AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915();
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
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3PolygonAssets.BAL_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'BAL kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 500, // 5% -> 20% (2 decimals)
        'BAL base'
      );
      assertEq(
        rate.variableRateSlope1,
        1_500, // unchanged; 15% (2 decimals)
        'BAL s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 15_000, // 150% -> 40% (2 decimals)
        'BAL s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3PolygonAssets.GHST_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'GHST kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'GHST base'
      );
      assertEq(
        rate.variableRateSlope1,
        700, // unchanged; 7% (2 decimals)
        'GHST s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'GHST s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3PolygonAssets.miMATIC_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'miMATIC kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'miMATIC base'
      );
      assertEq(
        rate.variableRateSlope1,
        900, // unchanged; 9% (2 decimals)
        'miMATIC s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'miMATIC s2'
      );
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Polygon.ORACLE.getSourceOfAsset(AaveV3PolygonAssets.BAL_UNDERLYING),
      proposal.BAL_PRICE_FEED(),
      'BAL source'
    );
    assertEq(
      AaveV3Polygon.ORACLE.getAssetPrice(AaveV3PolygonAssets.BAL_UNDERLYING),
      // $0.1316 (8 decimals)
      13_160_000,
      'BAL oracle output'
    );
    assertEq(
      AaveV3Polygon.ORACLE.getSourceOfAsset(AaveV3PolygonAssets.GHST_UNDERLYING),
      proposal.GHST_PRICE_FEED(),
      'GHST source'
    );
    assertEq(
      AaveV3Polygon.ORACLE.getAssetPrice(AaveV3PolygonAssets.GHST_UNDERLYING),
      // $0.0828 (8 decimals)
      8_280_000,
      'GHST oracle output'
    );
    assertEq(
      AaveV3Polygon.ORACLE.getSourceOfAsset(AaveV3PolygonAssets.miMATIC_UNDERLYING),
      proposal.miMATIC_PRICE_FEED(),
      'miMATIC source'
    );
    assertEq(
      AaveV3Polygon.ORACLE.getAssetPrice(AaveV3PolygonAssets.miMATIC_UNDERLYING),
      // $0.953 (8 decimals)
      95_300_000,
      'miMATIC oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](3);
    expected[0] = AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.BAL_UNDERLYING).data;
    assertEq((expected[0] >> 116) & ((1 << 36) - 1), 361_000, 'BAL pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[0] >> 80) & ((1 << 36) - 1), 290_000, 'BAL pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[0] >> 57) & 1, 1, 'BAL pre freeze');
    expected[0] |= uint256(1) << 57;
    expected[1] = AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.GHST_UNDERLYING).data;
    assertEq((expected[1] >> 116) & ((1 << 36) - 1), 1, 'GHST pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[1] >> 80) & ((1 << 36) - 1), 1, 'GHST pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[1] >> 57) & 1, 0, 'GHST pre freeze');
    expected[1] |= uint256(1) << 57;
    expected[2] = AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.miMATIC_UNDERLYING).data;
    assertEq((expected[2] >> 116) & ((1 << 36) - 1), 900_000, 'miMATIC pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[2] >> 80) & ((1 << 36) - 1), 700_000, 'miMATIC pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[2] >> 57) & 1, 1, 'miMATIC pre freeze');
    expected[2] |= uint256(1) << 57;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.BAL_UNDERLYING).data,
      expected[0],
      'BAL configuration and untouched fields'
    );
    assertEq(
      AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.GHST_UNDERLYING).data,
      expected[1],
      'GHST configuration and untouched fields'
    );
    assertEq(
      AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.miMATIC_UNDERLYING).data,
      expected[2],
      'miMATIC configuration and untouched fields'
    );
  }
}
