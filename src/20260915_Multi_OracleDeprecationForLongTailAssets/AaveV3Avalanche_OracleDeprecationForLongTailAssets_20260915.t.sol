// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 95_905_103);
    proposal = new AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(
      AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY()
    );
    _ratesBefore[AaveV3AvalancheAssets.FRAX_UNDERLYING] = strategy.getInterestRateData(
      AaveV3AvalancheAssets.FRAX_UNDERLYING
    );
    _ratesBefore[AaveV3AvalancheAssets.MAI_UNDERLYING] = strategy.getInterestRateData(
      AaveV3AvalancheAssets.MAI_UNDERLYING
    );
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
    _validateInterestRateStrategy(
      AaveV3AvalancheAssets.FRAX_UNDERLYING,
      AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3AvalancheAssets.FRAX_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3AvalancheAssets.FRAX_UNDERLYING].variableRateSlope1,
        variableRateSlope2: _ratesBefore[AaveV3AvalancheAssets.FRAX_UNDERLYING].variableRateSlope2
      })
    );
    _validateInterestRateStrategy(
      AaveV3AvalancheAssets.MAI_UNDERLYING,
      AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Avalanche.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3AvalancheAssets.MAI_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3AvalancheAssets.MAI_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3Avalanche.POOL_ADDRESSES_PROVIDER,
      AaveV3AvalancheAssets.FRAX_UNDERLYING,
      proposal.FRAX_PRICE_FEED()
    );
    assertEq(
      AaveV3Avalanche.ORACLE.getAssetPrice(AaveV3AvalancheAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Avalanche.POOL_ADDRESSES_PROVIDER,
      AaveV3AvalancheAssets.MAI_UNDERLYING,
      proposal.MAI_PRICE_FEED()
    );
    assertEq(
      AaveV3Avalanche.ORACLE.getAssetPrice(AaveV3AvalancheAssets.MAI_UNDERLYING),
      // $0.953 (8 decimals)
      95_300_000,
      'MAI oracle output'
    );
  }
  function test_configurationAndUntouchedFields() public {
    DataTypes.ReserveConfigurationMap memory expectedFRAX = AaveV3Avalanche.POOL.getConfiguration(
      AaveV3AvalancheAssets.FRAX_UNDERLYING
    );
    expectedFRAX.setFrozen(true);
    DataTypes.ReserveConfigurationMap memory expectedMAI = AaveV3Avalanche.POOL.getConfiguration(
      AaveV3AvalancheAssets.MAI_UNDERLYING
    );
    expectedMAI.setSupplyCap(1);
    expectedMAI.setBorrowCap(1);
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3Avalanche.POOL.getConfiguration(AaveV3AvalancheAssets.FRAX_UNDERLYING).data,
      expectedFRAX.data,
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV3Avalanche.POOL.getConfiguration(AaveV3AvalancheAssets.MAI_UNDERLYING).data,
      expectedMAI.data,
      'MAI configuration and untouched fields'
    );
  }
}
