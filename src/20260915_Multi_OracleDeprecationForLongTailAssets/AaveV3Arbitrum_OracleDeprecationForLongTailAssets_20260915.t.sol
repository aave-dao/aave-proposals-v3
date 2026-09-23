// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @dev Test for AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
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
      reserveFactor: 100_00 // 100% (2 decimals)
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00 // 100% (2 decimals)
    });
    return borrowUpdates;
  }
  function _assertRates(bool afterExecution) internal view {
    _validateInterestRateStrategy(
      AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3ArbitrumAssets.FRAX_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 50_000_000_000_000_000_000_000_000 : 0, // 0% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ArbitrumAssets.FRAX_UNDERLYING].variableRateSlope1,
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
        optimalUsageRatio: _ratesBefore[AaveV3ArbitrumAssets.LUSD_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution
          ? 50_000_000_000_000_000_000_000_000
          : 20_000_000_000_000_000_000_000_000, // 2% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ArbitrumAssets.LUSD_UNDERLYING].variableRateSlope1,
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
        optimalUsageRatio: _ratesBefore[AaveV3ArbitrumAssets.MAI_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3ArbitrumAssets.MAI_UNDERLYING].variableRateSlope1,
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
}
