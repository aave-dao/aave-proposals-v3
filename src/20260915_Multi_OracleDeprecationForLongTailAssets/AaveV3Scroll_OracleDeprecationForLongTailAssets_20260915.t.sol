// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Scroll, AaveV3ScrollAssets} from 'aave-address-book/AaveV3Scroll.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('scroll'), 35039319);
    proposal = new AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915();
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
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Scroll.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3ScrollAssets.SCR_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'SCR kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'SCR base');
      assertEq(rate.variableRateSlope1, afterExecution ? 700 : 700, 'SCR s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 30000, 'SCR s2');
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Scroll.ORACLE.getSourceOfAsset(AaveV3ScrollAssets.SCR_UNDERLYING),
      proposal.SCR_PRICE_FEED(),
      'SCR source'
    );
    assertEq(
      AaveV3Scroll.ORACLE.getAssetPrice(AaveV3ScrollAssets.SCR_UNDERLYING),
      3350000,
      'SCR oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](1);
    expected[0] = AaveV3Scroll.POOL.getConfiguration(AaveV3ScrollAssets.SCR_UNDERLYING).data;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Scroll.POOL.getConfiguration(AaveV3ScrollAssets.SCR_UNDERLYING).data,
      expected[0],
      'SCR configuration and untouched fields'
    );
  }
}
