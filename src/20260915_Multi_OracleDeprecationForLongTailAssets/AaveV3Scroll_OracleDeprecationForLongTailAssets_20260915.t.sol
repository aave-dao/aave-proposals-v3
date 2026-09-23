// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Scroll, AaveV3ScrollAssets} from 'aave-address-book/AaveV3Scroll.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @dev Test for AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  address internal _strategyBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('scroll'), 35_135_956);
    proposal = new AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915();
    _strategyBefore = AaveV3Scroll.POOL.RESERVE_INTEREST_RATE_STRATEGY();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(_strategyBefore);
    _ratesBefore[AaveV3ScrollAssets.SCR_UNDERLYING] = strategy.getInterestRateData(
      AaveV3ScrollAssets.SCR_UNDERLYING
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Scroll.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Scroll.POOL, address(proposal), updatedAssets);
  }
  function _assertRates(bool afterExecution) internal view {
    _validateInterestRateStrategy(
      AaveV3ScrollAssets.SCR_UNDERLYING,
      AaveV3Scroll.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      _strategyBefore,
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3ScrollAssets.SCR_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution
          ? 200_000_000_000_000_000_000_000_000
          : 50_000_000_000_000_000_000_000_000, // 5% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ScrollAssets.SCR_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3Scroll.POOL_ADDRESSES_PROVIDER,
      AaveV3ScrollAssets.SCR_UNDERLYING,
      proposal.SCR_PRICE_FEED()
    );
    assertEq(
      AaveV3Scroll.ORACLE.getAssetPrice(AaveV3ScrollAssets.SCR_UNDERLYING),
      // $0.0335 (8 decimals)
      3_350_000,
      'SCR oracle output'
    );
  }
}
