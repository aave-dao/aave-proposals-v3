// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 507_750_012);
    proposal = new AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Arbitrum.POOL,
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
    updatedAssets[0] = AaveV3ArbitrumAssets.FRAX_UNDERLYING;
    updatedAssets[1] = AaveV3ArbitrumAssets.LUSD_UNDERLYING;
    updatedAssets[2] = AaveV3ArbitrumAssets.MAI_UNDERLYING;
    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](2);
    frozen = new bool[](2);

    assets[0] = AaveV3ArbitrumAssets.FRAX_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3ArbitrumAssets.LUSD_UNDERLYING;
    frozen[1] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3ArbitrumAssets.MAI_UNDERLYING, 1, 1);
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](2);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    return borrowUpdates;
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3ArbitrumAssets.FRAX_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        9_000, // unchanged; 90% (2 decimals)
        'FRAX kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 500 : 0, // 0% -> 5% (2 decimals)
        'FRAX base'
      );
      assertEq(
        rate.variableRateSlope1,
        550, // unchanged; 5.5% (2 decimals)
        'FRAX s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 10_000 : 4_000, // 40% -> 100% (2 decimals)
        'FRAX s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3ArbitrumAssets.LUSD_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        8_000, // unchanged; 80% (2 decimals)
        'LUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 500 : 200, // 2% -> 5% (2 decimals)
        'LUSD base'
      );
      assertEq(
        rate.variableRateSlope1,
        650, // unchanged; 6.5% (2 decimals)
        'LUSD s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 10_000 : 5_000, // 50% -> 100% (2 decimals)
        'LUSD s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3ArbitrumAssets.MAI_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'MAI kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'MAI base'
      );
      assertEq(
        rate.variableRateSlope1,
        900, // unchanged; 9% (2 decimals)
        'MAI s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'MAI s2'
      );
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Arbitrum.ORACLE.getSourceOfAsset(AaveV3ArbitrumAssets.FRAX_UNDERLYING),
      proposal.FRAX_PRICE_FEED(),
      'FRAX source'
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getAssetPrice(AaveV3ArbitrumAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getSourceOfAsset(AaveV3ArbitrumAssets.LUSD_UNDERLYING),
      proposal.LUSD_PRICE_FEED(),
      'LUSD source'
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getAssetPrice(AaveV3ArbitrumAssets.LUSD_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'LUSD oracle output'
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getSourceOfAsset(AaveV3ArbitrumAssets.MAI_UNDERLYING),
      proposal.MAI_PRICE_FEED(),
      'MAI source'
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getAssetPrice(AaveV3ArbitrumAssets.MAI_UNDERLYING),
      // $0.953 (8 decimals)
      95_300_000,
      'MAI oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](3);
    expected[0] = AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.FRAX_UNDERLYING).data;
    assertEq((expected[0] >> 116) & ((1 << 36) - 1), 1, 'FRAX pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[0] >> 80) & ((1 << 36) - 1), 1, 'FRAX pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[0] >> 57) & 1, 0, 'FRAX pre freeze');
    expected[0] |= uint256(1) << 57;
    assertEq((expected[0] >> 64) & 65_535, 2_000, 'FRAX pre RF');
    expected[0] = (expected[0] & ~(uint256(65_535) << 64)) | (uint256(10_000) << 64);
    expected[1] = AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.LUSD_UNDERLYING).data;
    assertEq((expected[1] >> 116) & ((1 << 36) - 1), 1, 'LUSD pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[1] >> 80) & ((1 << 36) - 1), 1, 'LUSD pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[1] >> 57) & 1, 0, 'LUSD pre freeze');
    expected[1] |= uint256(1) << 57;
    assertEq((expected[1] >> 64) & 65_535, 5_000, 'LUSD pre RF');
    expected[1] = (expected[1] & ~(uint256(65_535) << 64)) | (uint256(10_000) << 64);
    expected[2] = AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.MAI_UNDERLYING).data;
    assertEq((expected[2] >> 116) & ((1 << 36) - 1), 325_000, 'MAI pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[2] >> 80) & ((1 << 36) - 1), 250_000, 'MAI pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[2] >> 57) & 1, 1, 'MAI pre freeze');
    expected[2] |= uint256(1) << 57;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.FRAX_UNDERLYING).data,
      expected[0],
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.LUSD_UNDERLYING).data,
      expected[1],
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.MAI_UNDERLYING).data,
      expected[2],
      'MAI configuration and untouched fields'
    );
  }
}
