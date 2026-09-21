// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 156936640);
    proposal = new AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Optimism.POOL,
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
    updatedAssets[0] = AaveV3OptimismAssets.LUSD_UNDERLYING;
    updatedAssets[1] = AaveV3OptimismAssets.sUSD_UNDERLYING;
    updatedAssets[2] = AaveV3OptimismAssets.MAI_UNDERLYING;
    reserveConfigChangesTest(AaveV3Optimism.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](2);
    frozen = new bool[](2);

    assets[0] = AaveV3OptimismAssets.LUSD_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3OptimismAssets.sUSD_UNDERLYING;
    frozen[1] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3OptimismAssets.MAI_UNDERLYING, 1, 1);
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Optimism.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3OptimismAssets.LUSD_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 8000 : 8000, 'LUSD kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 200, 'LUSD base');
      assertEq(rate.variableRateSlope1, afterExecution ? 550 : 550, 'LUSD s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 5000, 'LUSD s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Optimism.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3OptimismAssets.MAI_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'MAI kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'MAI base');
      assertEq(rate.variableRateSlope1, afterExecution ? 550 : 550, 'MAI s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 30000, 'MAI s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Optimism.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3OptimismAssets.sUSD_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 8000 : 8000, 'sUSD kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 0 : 0, 'sUSD base');
      assertEq(rate.variableRateSlope1, afterExecution ? 0 : 550, 'sUSD s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 0 : 5000, 'sUSD s2');
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Optimism.ORACLE.getSourceOfAsset(AaveV3OptimismAssets.LUSD_UNDERLYING),
      proposal.LUSD_PRICE_FEED(),
      'LUSD source'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getAssetPrice(AaveV3OptimismAssets.LUSD_UNDERLYING),
      100000000,
      'LUSD oracle output'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getSourceOfAsset(AaveV3OptimismAssets.MAI_UNDERLYING),
      proposal.MAI_PRICE_FEED(),
      'MAI source'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getAssetPrice(AaveV3OptimismAssets.MAI_UNDERLYING),
      95300000,
      'MAI oracle output'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getSourceOfAsset(AaveV3OptimismAssets.sUSD_UNDERLYING),
      proposal.sUSD_PRICE_FEED(),
      'sUSD source'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getAssetPrice(AaveV3OptimismAssets.sUSD_UNDERLYING),
      30290000,
      'sUSD oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](3);
    expected[0] = AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.LUSD_UNDERLYING).data;
    assertEq((expected[0] >> 116) & ((1 << 36) - 1), 1, 'LUSD pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[0] >> 80) & ((1 << 36) - 1), 1, 'LUSD pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[0] >> 57) & 1, 0, 'LUSD pre freeze');
    expected[0] |= uint256(1) << 57;
    expected[1] = AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.MAI_UNDERLYING).data;
    assertEq((expected[1] >> 116) & ((1 << 36) - 1), 650000, 'MAI pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[1] >> 80) & ((1 << 36) - 1), 525000, 'MAI pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[1] >> 57) & 1, 1, 'MAI pre freeze');
    expected[1] |= uint256(1) << 57;
    expected[2] = AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.sUSD_UNDERLYING).data;
    assertEq((expected[2] >> 116) & ((1 << 36) - 1), 1, 'sUSD pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[2] >> 80) & ((1 << 36) - 1), 1, 'sUSD pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[2] >> 57) & 1, 0, 'sUSD pre freeze');
    expected[2] |= uint256(1) << 57;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.LUSD_UNDERLYING).data,
      expected[0],
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.MAI_UNDERLYING).data,
      expected[1],
      'MAI configuration and untouched fields'
    );
    assertEq(
      AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.sUSD_UNDERLYING).data,
      expected[2],
      'sUSD configuration and untouched fields'
    );
  }
}
