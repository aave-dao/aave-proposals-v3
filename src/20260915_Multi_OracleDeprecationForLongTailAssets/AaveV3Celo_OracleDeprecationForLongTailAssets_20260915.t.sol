// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Celo, AaveV3CeloAssets} from 'aave-address-book/AaveV3Celo.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Celo_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Celo_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @dev Test for AaveV3Celo_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Celo_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Celo_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  AaveV3Celo_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('celo'), 78_171_278);
    proposal = new AaveV3Celo_OracleDeprecationForLongTailAssets_20260915();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(
      AaveV3Celo.POOL.RESERVE_INTEREST_RATE_STRATEGY()
    );
    _ratesBefore[AaveV3CeloAssets.USDm_UNDERLYING] = strategy.getInterestRateData(
      AaveV3CeloAssets.USDm_UNDERLYING
    );
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
      reserveFactor: 100_00 // 100% (2 decimals)
    });
    return borrowUpdates;
  }
  function _assertRates(bool afterExecution) internal view {
    _validateInterestRateStrategy(
      AaveV3CeloAssets.USDm_UNDERLYING,
      AaveV3Celo.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Celo.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3CeloAssets.USDm_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 50_000_000_000_000_000_000_000_000 : 0, // 0% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3CeloAssets.USDm_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 1_000_000_000_000_000_000_000_000_000
          : 750_000_000_000_000_000_000_000_000 // 75% -> 100% (27 decimals)
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3Celo.POOL_ADDRESSES_PROVIDER,
      AaveV3CeloAssets.USDm_UNDERLYING,
      proposal.USDm_PRICE_FEED()
    );
    assertEq(
      AaveV3Celo.ORACLE.getAssetPrice(AaveV3CeloAssets.USDm_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'USDm oracle output'
    );
  }
}
