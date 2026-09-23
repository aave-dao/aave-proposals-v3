// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';

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
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 94_244_629);
    proposal = new AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY()
    );
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
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3PolygonAssets.BAL_UNDERLYING].optimalUsageRatio, // unchanged
        baseVariableBorrowRate: afterExecution
          ? 200_000_000_000_000_000_000_000_000
          : 50_000_000_000_000_000_000_000_000, // 5% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3PolygonAssets.BAL_UNDERLYING].variableRateSlope1, // unchanged
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 1_500_000_000_000_000_000_000_000_000 // 150% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3PolygonAssets.GHST_UNDERLYING,
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3PolygonAssets.GHST_UNDERLYING].optimalUsageRatio, // unchanged
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3PolygonAssets.GHST_UNDERLYING].variableRateSlope1, // unchanged
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3PolygonAssets.miMATIC_UNDERLYING,
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Polygon.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3PolygonAssets.miMATIC_UNDERLYING].optimalUsageRatio, // unchanged
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3PolygonAssets.miMATIC_UNDERLYING].variableRateSlope1, // unchanged
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
  function test_payloadStateTransition() public {
    _assertRates(false);
    DataTypes.ReserveConfigurationMap memory expectedBAL = AaveV3Polygon.POOL.getConfiguration(
      AaveV3PolygonAssets.BAL_UNDERLYING
    );
    assertEq(expectedBAL.getSupplyCap(), 361_000, 'BAL pre supply cap');
    expectedBAL.setSupplyCap(1);
    assertEq(expectedBAL.getBorrowCap(), 290_000, 'BAL pre borrow cap');
    expectedBAL.setBorrowCap(1);
    assertEq(expectedBAL.getFrozen(), true, 'BAL pre freeze'); // unchanged
    DataTypes.ReserveConfigurationMap memory expectedGHST = AaveV3Polygon.POOL.getConfiguration(
      AaveV3PolygonAssets.GHST_UNDERLYING
    );
    assertEq(expectedGHST.getSupplyCap(), 1, 'GHST pre supply cap'); // unchanged
    assertEq(expectedGHST.getBorrowCap(), 1, 'GHST pre borrow cap'); // unchanged
    assertEq(expectedGHST.getFrozen(), false, 'GHST pre freeze');
    expectedGHST.setFrozen(true);
    DataTypes.ReserveConfigurationMap memory expectedmiMATIC = AaveV3Polygon.POOL.getConfiguration(
      AaveV3PolygonAssets.miMATIC_UNDERLYING
    );
    assertEq(expectedmiMATIC.getSupplyCap(), 900_000, 'miMATIC pre supply cap');
    expectedmiMATIC.setSupplyCap(1);
    assertEq(expectedmiMATIC.getBorrowCap(), 700_000, 'miMATIC pre borrow cap');
    expectedmiMATIC.setBorrowCap(1);
    assertEq(expectedmiMATIC.getFrozen(), true, 'miMATIC pre freeze'); // unchanged
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.BAL_UNDERLYING).data,
      expectedBAL.data,
      'BAL configuration and untouched fields'
    );
    assertEq(
      AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.GHST_UNDERLYING).data,
      expectedGHST.data,
      'GHST configuration and untouched fields'
    );
    assertEq(
      AaveV3Polygon.POOL.getConfiguration(AaveV3PolygonAssets.miMATIC_UNDERLYING).data,
      expectedmiMATIC.data,
      'miMATIC configuration and untouched fields'
    );
  }
}
