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
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25982593);
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
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'BAL kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 500, 'BAL base');
      assertEq(rate.variableRateSlope1, afterExecution ? 1500 : 1500, 'BAL s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 15000, 'BAL s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.FRAX_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 9000 : 9000, 'FRAX kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 500 : 0, 'FRAX base');
      assertEq(rate.variableRateSlope1, afterExecution ? 550 : 550, 'FRAX s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 10000 : 4000, 'FRAX s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.FXS_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'FXS kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'FXS base');
      assertEq(rate.variableRateSlope1, afterExecution ? 900 : 900, 'FXS s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 30000, 'FXS s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.KNC_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'KNC kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'KNC base');
      assertEq(rate.variableRateSlope1, afterExecution ? 900 : 900, 'KNC s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 30000, 'KNC s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.LUSD_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 8000 : 8000, 'LUSD kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 500 : 0, 'LUSD base');
      assertEq(rate.variableRateSlope1, afterExecution ? 500 : 500, 'LUSD s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 10000 : 5000, 'LUSD s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.RPL_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 8000 : 8000, 'RPL kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 500 : 0, 'RPL base');
      assertEq(rate.variableRateSlope1, afterExecution ? 850 : 850, 'RPL s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 10000 : 8700, 'RPL s2');
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumAssets.STG_UNDERLYING);
      assertEq(rate.optimalUsageRatio, afterExecution ? 4500 : 4500, 'STG kink');
      assertEq(rate.baseVariableBorrowRate, afterExecution ? 2000 : 0, 'STG base');
      assertEq(rate.variableRateSlope1, afterExecution ? 700 : 700, 'STG s1');
      assertEq(rate.variableRateSlope2, afterExecution ? 4000 : 30000, 'STG s2');
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
      13370000,
      'BAL oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.FRAX_UNDERLYING),
      proposal.FRAX_PRICE_FEED(),
      'FRAX source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.FRAX_UNDERLYING),
      100000000,
      'FRAX oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.FXS_UNDERLYING),
      proposal.FXS_PRICE_FEED(),
      'FXS source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.FXS_UNDERLYING),
      35620000,
      'FXS oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.KNC_UNDERLYING),
      proposal.KNC_PRICE_FEED(),
      'KNC source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.KNC_UNDERLYING),
      14000000,
      'KNC oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.LUSD_UNDERLYING),
      proposal.LUSD_PRICE_FEED(),
      'LUSD source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.LUSD_UNDERLYING),
      100000000,
      'LUSD oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.RPL_UNDERLYING),
      proposal.RPL_PRICE_FEED(),
      'RPL source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.RPL_UNDERLYING),
      173380000,
      'RPL oracle output'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getSourceOfAsset(AaveV3EthereumAssets.STG_UNDERLYING),
      proposal.STG_PRICE_FEED(),
      'STG source'
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.STG_UNDERLYING),
      27340000,
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
    assertEq((expected[1] >> 64) & 65535, 2000, 'FRAX pre RF');
    expected[1] = (expected[1] & ~(uint256(65535) << 64)) | (uint256(10000) << 64);
    expected[2] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FXS_UNDERLYING).data;
    assertEq((expected[2] >> 116) & ((1 << 36) - 1), 1200000, 'FXS pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[2] >> 80) & ((1 << 36) - 1), 330000, 'FXS pre cap');
    expected[2] = (expected[2] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[2] >> 57) & 1, 1, 'FXS pre freeze');
    expected[2] |= uint256(1) << 57;
    expected[3] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.KNC_UNDERLYING).data;
    assertEq((expected[3] >> 116) & ((1 << 36) - 1), 1200000, 'KNC pre cap');
    expected[3] = (expected[3] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[3] >> 80) & ((1 << 36) - 1), 350000, 'KNC pre cap');
    expected[3] = (expected[3] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[3] >> 57) & 1, 1, 'KNC pre freeze');
    expected[3] |= uint256(1) << 57;
    expected[4] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.LUSD_UNDERLYING).data;
    assertEq((expected[4] >> 116) & ((1 << 36) - 1), 5000000, 'LUSD pre cap');
    expected[4] = (expected[4] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[4] >> 80) & ((1 << 36) - 1), 1, 'LUSD pre cap');
    expected[4] = (expected[4] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[4] >> 57) & 1, 0, 'LUSD pre freeze');
    expected[4] |= uint256(1) << 57;
    assertEq((expected[4] >> 64) & 65535, 2000, 'LUSD pre RF');
    expected[4] = (expected[4] & ~(uint256(65535) << 64)) | (uint256(10000) << 64);
    expected[5] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.RPL_UNDERLYING).data;
    assertEq((expected[5] >> 116) & ((1 << 36) - 1), 550000, 'RPL pre cap');
    expected[5] = (expected[5] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[5] >> 80) & ((1 << 36) - 1), 1, 'RPL pre cap');
    expected[5] = (expected[5] & ~(((uint256(1) << 36) - 1) << 80)) | (uint256(1) << 80);
    assertEq((expected[5] >> 57) & 1, 0, 'RPL pre freeze');
    expected[5] |= uint256(1) << 57;
    assertEq((expected[5] >> 64) & 65535, 2000, 'RPL pre RF');
    expected[5] = (expected[5] & ~(uint256(65535) << 64)) | (uint256(10000) << 64);
    expected[6] = AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.STG_UNDERLYING).data;
    assertEq((expected[6] >> 116) & ((1 << 36) - 1), 10000000, 'STG pre cap');
    expected[6] = (expected[6] & ~(((uint256(1) << 36) - 1) << 116)) | (uint256(1) << 116);
    assertEq((expected[6] >> 80) & ((1 << 36) - 1), 3200000, 'STG pre cap');
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
