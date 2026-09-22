// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26_032_357);
    proposal = new AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](7);
    updatedAssets[0] = AaveV3EthereumAssets.BAL_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.FRAX_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.LUSD_UNDERLYING;
    updatedAssets[3] = AaveV3EthereumAssets.RPL_UNDERLYING;
    updatedAssets[4] = AaveV3EthereumAssets.FXS_UNDERLYING;
    updatedAssets[5] = AaveV3EthereumAssets.KNC_UNDERLYING;
    updatedAssets[6] = AaveV3EthereumAssets.STG_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](4);
    frozen = new bool[](4);

    assets[0] = AaveV3EthereumAssets.BAL_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3EthereumAssets.FRAX_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3EthereumAssets.LUSD_UNDERLYING;
    frozen[2] = true;
    assets[3] = AaveV3EthereumAssets.RPL_UNDERLYING;
    frozen[3] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](5);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3EthereumAssets.FXS_UNDERLYING, 1, 1);
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate(AaveV3EthereumAssets.KNC_UNDERLYING, 1, 1);
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate(
      AaveV3EthereumAssets.LUSD_UNDERLYING,
      1,
      EngineFlags.KEEP_CURRENT
    );
    capsUpdate[3] = IAaveV3ConfigEngine.CapsUpdate(
      AaveV3EthereumAssets.RPL_UNDERLYING,
      1,
      EngineFlags.KEEP_CURRENT
    );
    capsUpdate[4] = IAaveV3ConfigEngine.CapsUpdate(AaveV3EthereumAssets.STG_UNDERLYING, 1, 1);
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](3);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.LUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FRAX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.RPL_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    return borrowUpdates;
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.BAL_UNDERLYING);
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
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.FRAX_UNDERLYING);
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
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.FXS_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'FXS kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'FXS base'
      );
      assertEq(
        rate.variableRateSlope1,
        900, // unchanged; 9% (2 decimals)
        'FXS s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'FXS s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.KNC_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'KNC kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'KNC base'
      );
      assertEq(
        rate.variableRateSlope1,
        900, // unchanged; 9% (2 decimals)
        'KNC s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'KNC s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.LUSD_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        8_000, // unchanged; 80% (2 decimals)
        'LUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 500 : 0, // 0% -> 5% (2 decimals)
        'LUSD base'
      );
      assertEq(
        rate.variableRateSlope1,
        500, // unchanged; 5% (2 decimals)
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
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.RPL_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        8_000, // unchanged; 80% (2 decimals)
        'RPL kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 500 : 0, // 0% -> 5% (2 decimals)
        'RPL base'
      );
      assertEq(
        rate.variableRateSlope1,
        850, // unchanged; 8.5% (2 decimals)
        'RPL s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 10_000 : 8_700, // 87% -> 100% (2 decimals)
        'RPL s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.STG_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'STG kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'STG base'
      );
      assertEq(
        rate.variableRateSlope1,
        700, // unchanged; 7% (2 decimals)
        'STG s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'STG s2'
      );
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.BAL_UNDERLYING),
      proposal.BAL_PRICE_FEED(),
      'BAL source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.BAL_UNDERLYING),
      // $0.1337 (8 decimals)
      13_370_000,
      'BAL oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.FRAX_UNDERLYING),
      proposal.FRAX_PRICE_FEED(),
      'FRAX source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.FXS_UNDERLYING),
      proposal.FXS_PRICE_FEED(),
      'FXS source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.FXS_UNDERLYING),
      // $0.3562 (8 decimals)
      35_620_000,
      'FXS oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.KNC_UNDERLYING),
      proposal.KNC_PRICE_FEED(),
      'KNC source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.KNC_UNDERLYING),
      // $0.14 (8 decimals)
      14_000_000,
      'KNC oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.LUSD_UNDERLYING),
      proposal.LUSD_PRICE_FEED(),
      'LUSD source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.LUSD_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'LUSD oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.RPL_UNDERLYING),
      proposal.RPL_PRICE_FEED(),
      'RPL source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.RPL_UNDERLYING),
      // $1.7338 (8 decimals)
      173_380_000,
      'RPL oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.STG_UNDERLYING),
      proposal.STG_PRICE_FEED(),
      'STG source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.STG_UNDERLYING),
      // $0.2734 (8 decimals)
      27_340_000,
      'STG oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    uint256[] memory expected = new uint256[](7);
    expected[0] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.BAL_UNDERLYING).data;
    assertEq((expected[0] >> 116) & ((1 << 36) - 1), 1, 'BAL pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[0] >> 80) & ((1 << 36) - 1), 1, 'BAL pre cap');
    expected[0] = (expected[0] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[0] >> 57) & 1, 0, 'BAL pre freeze');
    expected[0] |= uint256(1) << 57;
    expected[1] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FRAX_UNDERLYING).data;
    assertEq((expected[1] >> 116) & ((1 << 36) - 1), 1, 'FRAX pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[1] >> 80) & ((1 << 36) - 1), 1, 'FRAX pre cap');
    expected[1] = (expected[1] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[1] >> 57) & 1, 0, 'FRAX pre freeze');
    expected[1] |= uint256(1) << 57;
    assertEq((expected[1] >> 64) & 65_535, 2_000, 'FRAX pre RF');
    expected[1] = (expected[1] & ~(uint256(65_535) << 64)) | (uint256(10_000) << 64);
    expected[2] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FXS_UNDERLYING).data;
    assertEq((expected[2] >> 116) & ((1 << 36) - 1), 1_200_000, 'FXS pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[2] >> 80) & ((1 << 36) - 1), 330_000, 'FXS pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[2] >> 57) & 1, 1, 'FXS pre freeze');
    expected[2] |= uint256(1) << 57;
    expected[3] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.KNC_UNDERLYING).data;
    assertEq((expected[3] >> 116) & ((1 << 36) - 1), 1_200_000, 'KNC pre cap');
    expected[3] = (expected[3] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[3] >> 80) & ((1 << 36) - 1), 350_000, 'KNC pre cap');
    expected[3] = (expected[3] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[3] >> 57) & 1, 1, 'KNC pre freeze');
    expected[3] |= uint256(1) << 57;
    expected[4] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.LUSD_UNDERLYING).data;
    assertEq((expected[4] >> 116) & ((1 << 36) - 1), 5_000_000, 'LUSD pre cap');
    expected[4] = (expected[4] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[4] >> 80) & ((1 << 36) - 1), 1, 'LUSD pre cap');
    expected[4] = (expected[4] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[4] >> 57) & 1, 0, 'LUSD pre freeze');
    expected[4] |= uint256(1) << 57;
    assertEq((expected[4] >> 64) & 65_535, 2_000, 'LUSD pre RF');
    expected[4] = (expected[4] & ~(uint256(65_535) << 64)) | (uint256(10_000) << 64);
    expected[5] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.RPL_UNDERLYING).data;
    assertEq((expected[5] >> 116) & ((1 << 36) - 1), 550_000, 'RPL pre cap');
    expected[5] = (expected[5] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[5] >> 80) & ((1 << 36) - 1), 1, 'RPL pre cap');
    expected[5] = (expected[5] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[5] >> 57) & 1, 0, 'RPL pre freeze');
    expected[5] |= uint256(1) << 57;
    assertEq((expected[5] >> 64) & 65_535, 2_000, 'RPL pre RF');
    expected[5] = (expected[5] & ~(uint256(65_535) << 64)) | (uint256(10_000) << 64);
    expected[6] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.STG_UNDERLYING).data;
    assertEq((expected[6] >> 116) & ((1 << 36) - 1), 10_000_000, 'STG pre cap');
    expected[6] = (expected[6] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[6] >> 80) & ((1 << 36) - 1), 3_200_000, 'STG pre cap');
    expected[6] = (expected[6] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[6] >> 57) & 1, 1, 'STG pre freeze');
    expected[6] |= uint256(1) << 57;
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.BAL_UNDERLYING).data,
      expected[0],
      'BAL configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FRAX_UNDERLYING).data,
      expected[1],
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FXS_UNDERLYING).data,
      expected[2],
      'FXS configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.KNC_UNDERLYING).data,
      expected[3],
      'KNC configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.LUSD_UNDERLYING).data,
      expected[4],
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.RPL_UNDERLYING).data,
      expected[5],
      'RPL configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.STG_UNDERLYING).data,
      expected[6],
      'STG configuration and untouched fields'
    );
  }
}
