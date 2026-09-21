// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Celo, AaveV3CeloAssets} from 'aave-address-book/AaveV3Celo.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Celo_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Celo_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Celo_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Celo_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Celo_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Celo_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('celo'), 77571299);
    proposal = new AaveV3Celo_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Celo_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Celo.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](1);
    updatedAssets[0] = AaveV3CeloAssets.USDm_UNDERLYING;
    reserveConfigChangesTest(AaveV3Celo.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](1);
    frozen = new bool[](1);

    assets[0] = AaveV3CeloAssets.USDm_UNDERLYING;
    frozen[0] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3CeloAssets.USDm_UNDERLYING, 1, 1);
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](1);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3CeloAssets.USDm_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    return borrowUpdates;
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Celo.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3CeloAssets.USDm_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 9000 : 9000, 'USDm kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 500 : 0, 'USDm base');
      assertEq(rate.variableRateSlope1, afterExecution ? 400 : 400, 'USDm s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 10000 : 7500, 'USDm s2');
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Celo.ORACLE.getSourceOfAsset(AaveV3CeloAssets.USDm_UNDERLYING),
      proposal.USDm_PRICE_FEED(),
      'USDm source'
    );
    assertEq(
      AaveV3Celo.ORACLE.getAssetPrice(AaveV3CeloAssets.USDm_UNDERLYING),
      100000000,
      'USDm oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](1);
    expected[0] = AaveV3Celo.POOL.getConfiguration(AaveV3CeloAssets.USDm_UNDERLYING).data;
    assertEq((expected[0] >> 116) & ((1 << 36) - 1), 1100000, 'USDm pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[0] >> 80) & ((1 << 36) - 1), 990000, 'USDm pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[0] >> 57) & 1, 0, 'USDm pre freeze');
    expected[0] |= uint256(1) << 57;
    assertEq((expected[0] >> 64) & 65535, 1500, 'USDm pre RF');
    expected[0] = (expected[0] & ~(uint256(65535) << 64)) | (uint256(10000) << 64);
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Celo.POOL.getConfiguration(AaveV3CeloAssets.USDm_UNDERLYING).data,
      expected[0],
      'USDm configuration and untouched fields'
    );
  }
}
