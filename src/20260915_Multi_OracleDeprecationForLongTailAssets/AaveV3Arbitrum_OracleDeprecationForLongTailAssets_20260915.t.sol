// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';

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
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 507_750_012);
    proposal = new AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
    );
    _ratesBefore[AaveV3ArbitrumAssets.FRAX_UNDERLYING] = strategy.getInterestRateData(
      AaveV3ArbitrumAssets.FRAX_UNDERLYING
    );
    _ratesBefore[AaveV3ArbitrumAssets.LUSD_UNDERLYING] = strategy.getInterestRateData(
      AaveV3ArbitrumAssets.LUSD_UNDERLYING
    );
    _ratesBefore[AaveV3ArbitrumAssets.MAI_UNDERLYING] = strategy.getInterestRateData(
      AaveV3ArbitrumAssets.MAI_UNDERLYING
    );
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
    _validateInterestRateStrategy(
      AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3ArbitrumAssets.FRAX_UNDERLYING].optimalUsageRatio, // unchanged
        baseVariableBorrowRate: afterExecution ? 50_000_000_000_000_000_000_000_000 : 0, // 0% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ArbitrumAssets.FRAX_UNDERLYING].variableRateSlope1, // unchanged
        variableRateSlope2: afterExecution
          ? 1_000_000_000_000_000_000_000_000_000
          : 400_000_000_000_000_000_000_000_000 // 40% -> 100% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3ArbitrumAssets.LUSD_UNDERLYING].optimalUsageRatio, // unchanged
        baseVariableBorrowRate: afterExecution
          ? 50_000_000_000_000_000_000_000_000
          : 20_000_000_000_000_000_000_000_000, // 2% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ArbitrumAssets.LUSD_UNDERLYING].variableRateSlope1, // unchanged
        variableRateSlope2: afterExecution
          ? 1_000_000_000_000_000_000_000_000_000
          : 500_000_000_000_000_000_000_000_000 // 50% -> 100% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3ArbitrumAssets.MAI_UNDERLYING,
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3ArbitrumAssets.MAI_UNDERLYING].optimalUsageRatio, // unchanged
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ArbitrumAssets.MAI_UNDERLYING].variableRateSlope1, // unchanged
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER,
      AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      proposal.FRAX_PRICE_FEED()
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getAssetPrice(AaveV3ArbitrumAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER,
      AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      proposal.LUSD_PRICE_FEED()
    );
    assertEq(
      AaveV3Arbitrum.ORACLE.getAssetPrice(AaveV3ArbitrumAssets.LUSD_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'LUSD oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER,
      AaveV3ArbitrumAssets.MAI_UNDERLYING,
      proposal.MAI_PRICE_FEED()
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
    DataTypes.ReserveConfigurationMap memory expectedFRAX = AaveV3Arbitrum.POOL.getConfiguration(
      AaveV3ArbitrumAssets.FRAX_UNDERLYING
    );
    assertEq(expectedFRAX.getSupplyCap(), 1, 'FRAX pre supply cap'); // unchanged
    assertEq(expectedFRAX.getBorrowCap(), 1, 'FRAX pre borrow cap'); // unchanged
    assertEq(expectedFRAX.getFrozen(), false, 'FRAX pre freeze');
    expectedFRAX.setFrozen(true);
    assertEq(expectedFRAX.getReserveFactor(), 2_000, 'FRAX pre RF');
    expectedFRAX.setReserveFactor(10_000); // 100% (2 decimals)
    DataTypes.ReserveConfigurationMap memory expectedLUSD = AaveV3Arbitrum.POOL.getConfiguration(
      AaveV3ArbitrumAssets.LUSD_UNDERLYING
    );
    assertEq(expectedLUSD.getSupplyCap(), 1, 'LUSD pre supply cap'); // unchanged
    assertEq(expectedLUSD.getBorrowCap(), 1, 'LUSD pre borrow cap'); // unchanged
    assertEq(expectedLUSD.getFrozen(), false, 'LUSD pre freeze');
    expectedLUSD.setFrozen(true);
    assertEq(expectedLUSD.getReserveFactor(), 5_000, 'LUSD pre RF');
    expectedLUSD.setReserveFactor(10_000); // 100% (2 decimals)
    DataTypes.ReserveConfigurationMap memory expectedMAI = AaveV3Arbitrum.POOL.getConfiguration(
      AaveV3ArbitrumAssets.MAI_UNDERLYING
    );
    assertEq(expectedMAI.getSupplyCap(), 325_000, 'MAI pre supply cap');
    expectedMAI.setSupplyCap(1);
    assertEq(expectedMAI.getBorrowCap(), 250_000, 'MAI pre borrow cap');
    expectedMAI.setBorrowCap(1);
    assertEq(expectedMAI.getFrozen(), true, 'MAI pre freeze'); // unchanged
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.FRAX_UNDERLYING).data,
      expectedFRAX.data,
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.LUSD_UNDERLYING).data,
      expectedLUSD.data,
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV3Arbitrum.POOL.getConfiguration(AaveV3ArbitrumAssets.MAI_UNDERLYING).data,
      expectedMAI.data,
      'MAI configuration and untouched fields'
    );
  }
}
