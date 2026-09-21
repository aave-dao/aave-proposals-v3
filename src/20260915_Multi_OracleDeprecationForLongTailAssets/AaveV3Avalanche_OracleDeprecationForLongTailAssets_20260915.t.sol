// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 95341470);
    proposal = new AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](2);
    updatedAssets[0] = AaveV3AvalancheAssets.FRAX_UNDERLYING;
    updatedAssets[1] = AaveV3AvalancheAssets.MAI_UNDERLYING;
    reserveConfigChangesTest(AaveV3Avalanche.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](1);
    frozen = new bool[](1);

    assets[0] = AaveV3AvalancheAssets.FRAX_UNDERLYING;
    frozen[0] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3AvalancheAssets.MAI_UNDERLYING, 1, 1);
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3AvalancheAssets.FRAX_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 9000 : 9000, 'FRAX kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'FRAX base');
      assertEq(rate.variableRateSlope1, afterExecution ? 550 : 550, 'FRAX s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 4000, 'FRAX s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3AvalancheAssets.MAI_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'MAI kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'MAI base');
      assertEq(rate.variableRateSlope1, afterExecution ? 900 : 900, 'MAI s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 30000, 'MAI s2');
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Avalanche.ORACLE.getSourceOfAsset(AaveV3AvalancheAssets.FRAX_UNDERLYING),
      proposal.FRAX_PRICE_FEED(),
      'FRAX source'
    );
    assertEq(
      AaveV3Avalanche.ORACLE.getAssetPrice(AaveV3AvalancheAssets.FRAX_UNDERLYING),
      100000000,
      'FRAX oracle output'
    );
    assertEq(
      AaveV3Avalanche.ORACLE.getSourceOfAsset(AaveV3AvalancheAssets.MAI_UNDERLYING),
      proposal.MAI_PRICE_FEED(),
      'MAI source'
    );
    assertEq(
      AaveV3Avalanche.ORACLE.getAssetPrice(AaveV3AvalancheAssets.MAI_UNDERLYING),
      95300000,
      'MAI oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](2);
    expected[0] = AaveV3Avalanche.POOL.getConfiguration(AaveV3AvalancheAssets.FRAX_UNDERLYING).data;
    assertEq((expected[0] >> 116) & ((1 << 36) - 1), 1, 'FRAX pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[0] >> 80) & ((1 << 36) - 1), 1, 'FRAX pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[0] >> 57) & 1, 0, 'FRAX pre freeze');
    expected[0] |= uint256(1) << 57;
    expected[1] = AaveV3Avalanche.POOL.getConfiguration(AaveV3AvalancheAssets.MAI_UNDERLYING).data;
    assertEq((expected[1] >> 116) & ((1 << 36) - 1), 20000, 'MAI pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[1] >> 80) & ((1 << 36) - 1), 10000, 'MAI pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[1] >> 57) & 1, 1, 'MAI pre freeze');
    expected[1] |= uint256(1) << 57;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Avalanche.POOL.getConfiguration(AaveV3AvalancheAssets.FRAX_UNDERLYING).data,
      expected[0],
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV3Avalanche.POOL.getConfiguration(AaveV3AvalancheAssets.MAI_UNDERLYING).data,
      expected[1],
      'MAI configuration and untouched fields'
    );
  }
}
