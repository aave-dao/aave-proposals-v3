// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';

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
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26_032_357);
    proposal = new AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY()
    );
    _ratesBefore[AaveV3EthereumAssets.BAL_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.BAL_UNDERLYING
    );
    _ratesBefore[AaveV3EthereumAssets.FRAX_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.FRAX_UNDERLYING
    );
    _ratesBefore[AaveV3EthereumAssets.FXS_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.FXS_UNDERLYING
    );
    _ratesBefore[AaveV3EthereumAssets.KNC_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.KNC_UNDERLYING
    );
    _ratesBefore[AaveV3EthereumAssets.LUSD_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.LUSD_UNDERLYING
    );
    _ratesBefore[AaveV3EthereumAssets.RPL_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.RPL_UNDERLYING
    );
    _ratesBefore[AaveV3EthereumAssets.STG_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumAssets.STG_UNDERLYING
    );
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
      reserveFactor: 100_00 // 100% (2 decimals)
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FRAX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00 // 100% (2 decimals)
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.RPL_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00 // 100% (2 decimals)
    });
    return borrowUpdates;
  }
  function _assertRates(bool afterExecution) internal view {
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.BAL_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.BAL_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution
          ? 200_000_000_000_000_000_000_000_000
          : 50_000_000_000_000_000_000_000_000, // 5% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.BAL_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 1_500_000_000_000_000_000_000_000_000 // 150% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.FRAX_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.FRAX_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 50_000_000_000_000_000_000_000_000 : 0, // 0% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.FRAX_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 1_000_000_000_000_000_000_000_000_000
          : 400_000_000_000_000_000_000_000_000 // 40% -> 100% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.FXS_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.FXS_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.FXS_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.KNC_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.KNC_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.KNC_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.LUSD_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.LUSD_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 50_000_000_000_000_000_000_000_000 : 0, // 0% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.LUSD_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 1_000_000_000_000_000_000_000_000_000
          : 500_000_000_000_000_000_000_000_000 // 50% -> 100% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.RPL_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.RPL_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 50_000_000_000_000_000_000_000_000 : 0, // 0% -> 5% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.RPL_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 1_000_000_000_000_000_000_000_000_000
          : 870_000_000_000_000_000_000_000_000 // 87% -> 100% (27 decimals)
      })
    );
    _validateInterestRateStrategy(
      AaveV3EthereumAssets.STG_UNDERLYING,
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      AaveV3Ethereum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumAssets.STG_UNDERLYING].optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumAssets.STG_UNDERLYING].variableRateSlope1,
        variableRateSlope2: afterExecution
          ? 400_000_000_000_000_000_000_000_000
          : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.BAL_UNDERLYING,
      proposal.BAL_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.BAL_UNDERLYING),
      // $0.1337 (8 decimals)
      13_370_000,
      'BAL oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.FRAX_UNDERLYING,
      proposal.FRAX_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.FXS_UNDERLYING,
      proposal.FXS_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.FXS_UNDERLYING),
      // $0.3562 (8 decimals)
      35_620_000,
      'FXS oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.KNC_UNDERLYING,
      proposal.KNC_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.KNC_UNDERLYING),
      // $0.14 (8 decimals)
      14_000_000,
      'KNC oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.LUSD_UNDERLYING,
      proposal.LUSD_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.LUSD_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'LUSD oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.RPL_UNDERLYING,
      proposal.RPL_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.RPL_UNDERLYING),
      // $1.7338 (8 decimals)
      173_380_000,
      'RPL oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumAssets.STG_UNDERLYING,
      proposal.STG_PRICE_FEED()
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.STG_UNDERLYING),
      // $0.2734 (8 decimals)
      27_340_000,
      'STG oracle output'
    );
  }
  function test_configurationAndUntouchedFields() public {
    DataTypes.ReserveConfigurationMap memory expectedBAL = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.BAL_UNDERLYING
    );
    expectedBAL.setFrozen(true);
    DataTypes.ReserveConfigurationMap memory expectedFRAX = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.FRAX_UNDERLYING
    );
    expectedFRAX.setFrozen(true);
    expectedFRAX.setReserveFactor(10_000); // 100% (2 decimals)
    DataTypes.ReserveConfigurationMap memory expectedFXS = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.FXS_UNDERLYING
    );
    expectedFXS.setSupplyCap(1);
    expectedFXS.setBorrowCap(1);
    DataTypes.ReserveConfigurationMap memory expectedKNC = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.KNC_UNDERLYING
    );
    expectedKNC.setSupplyCap(1);
    expectedKNC.setBorrowCap(1);
    DataTypes.ReserveConfigurationMap memory expectedLUSD = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.LUSD_UNDERLYING
    );
    expectedLUSD.setSupplyCap(1);
    expectedLUSD.setFrozen(true);
    expectedLUSD.setReserveFactor(10_000); // 100% (2 decimals)
    DataTypes.ReserveConfigurationMap memory expectedRPL = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.RPL_UNDERLYING
    );
    expectedRPL.setSupplyCap(1);
    expectedRPL.setFrozen(true);
    expectedRPL.setReserveFactor(10_000); // 100% (2 decimals)
    DataTypes.ReserveConfigurationMap memory expectedSTG = AaveV3Ethereum.POOL.getConfiguration(
      AaveV3EthereumAssets.STG_UNDERLYING
    );
    expectedSTG.setSupplyCap(1);
    expectedSTG.setBorrowCap(1);
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.BAL_UNDERLYING).data,
      expectedBAL.data,
      'BAL configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FRAX_UNDERLYING).data,
      expectedFRAX.data,
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.FXS_UNDERLYING).data,
      expectedFXS.data,
      'FXS configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.KNC_UNDERLYING).data,
      expectedKNC.data,
      'KNC configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.LUSD_UNDERLYING).data,
      expectedLUSD.data,
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.RPL_UNDERLYING).data,
      expectedRPL.data,
      'RPL configuration and untouched fields'
    );
    assertEq(
      AaveV3Ethereum.POOL.getConfiguration(AaveV3EthereumAssets.STG_UNDERLYING).data,
      expectedSTG.data,
      'STG configuration and untouched fields'
    );
  }
}
