// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV2TestBase, ReserveConfig, InterestStrategyValues} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';

import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {OracleTestUtils} from './OracleTestUtils.sol';

import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';
import {IAaveV2ConfigEngine} from 'aave-helpers/src/v2-config-engine/IAaveV2ConfigEngine.sol';
import {IV2RateStrategyFactory} from 'aave-helpers/src/v2-config-engine/IV2RateStrategyFactory.sol';

/**
 * @dev Test for AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV2TestBase {
  AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategy) internal _strategiesBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26_032_357);
    proposal = new AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915();
    _strategiesBefore[AaveV2EthereumAssets.FRAX_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.FRAX_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.LUSD_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.LUSD_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.TUSD_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.TUSD_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.USDP_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.USDP_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.AMPL_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.AMPL_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.RAI_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.RAI_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.sUSD_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.sUSD_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.YFI_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.YFI_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.BAL_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.BAL_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.ENJ_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.ENJ_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.KNC_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.KNC_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.REN_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.REN_UNDERLYING)
        .interestRateStrategyAddress
    );
    _strategiesBefore[AaveV2EthereumAssets.ZRX_UNDERLYING] = IDefaultInterestRateStrategy(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.ZRX_UNDERLYING)
        .interestRateStrategyAddress
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915',
      AaveV2Ethereum.POOL,
      address(proposal)
    );
  }

  function test_rateStrategies() public {
    _assertRates(false);
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
  }

  function test_oracles() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertOracles();
  }
  function _assertRates(bool afterExecution) internal view {
    assertEq(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.FRAX_UNDERLYING)
        .interestRateStrategyAddress,
      address(_strategiesBefore[AaveV2EthereumAssets.FRAX_UNDERLYING]),
      'FRAX strategy changed'
    );
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.LUSD_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.LUSD_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.TUSD_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.TUSD_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: afterExecution
            ? 200_000_000_000_000_000_000_000_000
            : 10_000_000_000_000_000_000_000_000, // 1% -> 20% (27 decimals)
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: previous.variableRateSlope2()
        })
      );
    }
    assertEq(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.USDP_UNDERLYING)
        .interestRateStrategyAddress,
      address(_strategiesBefore[AaveV2EthereumAssets.USDP_UNDERLYING]),
      'USDP strategy changed'
    );
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.AMPL_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.AMPL_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: afterExecution ? 0 : 200_000_000_000_000_000_000_000_000, // 20% -> 0% (27 decimals)
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution ? 0 : 3_000_000_000_000_000_000_000_000_000 // 300% -> 0% (27 decimals)
        })
      );
    }
    assertEq(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.RAI_UNDERLYING)
        .interestRateStrategyAddress,
      address(_strategiesBefore[AaveV2EthereumAssets.RAI_UNDERLYING]),
      'RAI strategy changed'
    );
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.sUSD_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.sUSD_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: afterExecution ? 0 : 200_000_000_000_000_000_000_000_000, // 20% -> 0% (27 decimals)
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution ? 0 : 3_000_000_000_000_000_000_000_000_000 // 300% -> 0% (27 decimals)
        })
      );
    }
    assertEq(
      AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.YFI_UNDERLYING)
        .interestRateStrategyAddress,
      address(_strategiesBefore[AaveV2EthereumAssets.YFI_UNDERLYING]),
      'YFI strategy changed'
    );
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.BAL_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.BAL_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.ENJ_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.ENJ_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.KNC_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.KNC_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.REN_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.REN_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution
            ? 400_000_000_000_000_000_000_000_000
            : 3_000_000_000_000_000_000_000_000_000 // 300% -> 40% (27 decimals)
        })
      );
    }
    {
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.ZRX_UNDERLYING
      ];
      _validateRates(
        AaveV2EthereumAssets.ZRX_UNDERLYING,
        afterExecution,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: afterExecution
            ? 200_000_000_000_000_000_000_000_000
            : 10_000_000_000_000_000_000_000_000, // 1% -> 20% (27 decimals)
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: afterExecution ? 400_000_000_000_000_000_000_000_000 : 0 // 0% -> 40% (27 decimals)
        })
      );
    }
  }
  function _validateRates(
    address asset,
    bool afterExecution,
    InterestStrategyValues memory expected
  ) internal view {
    address expectedStrategy = address(_strategiesBefore[asset]);
    if (afterExecution) {
      expectedStrategy = IAaveV2ConfigEngine(AaveV2Ethereum.CONFIG_ENGINE)
        .RATE_STRATEGIES_FACTORY()
        .getStrategyByParams(
          IV2RateStrategyFactory.RateStrategyParams({
            optimalUtilizationRate: expected.optimalUsageRatio,
            baseVariableBorrowRate: expected.baseVariableBorrowRate,
            variableRateSlope1: expected.variableRateSlope1,
            variableRateSlope2: expected.variableRateSlope2,
            stableRateSlope1: expected.stableRateSlope1,
            stableRateSlope2: expected.stableRateSlope2
          })
        );
      assertNotEq(expectedStrategy, address(0), 'Expected strategy missing from factory');
    }
    _validateInterestRateStrategy(
      AaveV2Ethereum.POOL.getReserveData(asset).interestRateStrategyAddress,
      expectedStrategy,
      expected
    );
  }

  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.AMPL_UNDERLYING,
      proposal.AMPL_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.AMPL_UNDERLYING),
      // $1.2396 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(123_960_000, ChainlinkEthereum.ETH__USD),
      'AMPL oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.BAL_UNDERLYING,
      proposal.BAL_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.BAL_UNDERLYING),
      // $0.1317 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(13_170_000, ChainlinkEthereum.ETH__USD),
      'BAL oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.ENJ_UNDERLYING,
      proposal.ENJ_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.ENJ_UNDERLYING),
      // $0.0461 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(4_610_000, ChainlinkEthereum.ETH__USD),
      'ENJ oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.FRAX_UNDERLYING,
      proposal.FRAX_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.FRAX_UNDERLYING),
      // $1 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(100_000_000, ChainlinkEthereum.ETH__USD),
      'FRAX oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.KNC_UNDERLYING,
      proposal.KNC_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.KNC_UNDERLYING),
      // $0.1401 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(14_010_000, ChainlinkEthereum.ETH__USD),
      'KNC oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.LUSD_UNDERLYING,
      proposal.LUSD_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.LUSD_UNDERLYING),
      // $1 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(100_000_000, ChainlinkEthereum.ETH__USD),
      'LUSD oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.RAI_UNDERLYING,
      proposal.RAI_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.RAI_UNDERLYING),
      // $2.6587 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(265_870_000, ChainlinkEthereum.ETH__USD),
      'RAI oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.REN_UNDERLYING,
      proposal.REN_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.REN_UNDERLYING),
      // $0.0033 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(330_000, ChainlinkEthereum.ETH__USD),
      'REN oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.TUSD_UNDERLYING,
      proposal.TUSD_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.TUSD_UNDERLYING),
      // $1 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(100_000_000, ChainlinkEthereum.ETH__USD),
      'TUSD oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.USDP_UNDERLYING,
      proposal.USDP_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.USDP_UNDERLYING),
      // $1 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(100_000_000, ChainlinkEthereum.ETH__USD),
      'USDP oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.YFI_UNDERLYING,
      proposal.YFI_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.YFI_UNDERLYING),
      // $2286.6368 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(228_663_680_000, ChainlinkEthereum.ETH__USD),
      'YFI oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.ZRX_UNDERLYING,
      proposal.ZRX_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.ZRX_UNDERLYING),
      // $0.0981 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(9_810_000, ChainlinkEthereum.ETH__USD),
      'ZRX oracle output'
    );
    _validateAssetSourceOnOracle(
      AaveV2Ethereum.POOL_ADDRESSES_PROVIDER,
      AaveV2EthereumAssets.sUSD_UNDERLYING,
      proposal.sUSD_PRICE_FEED()
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.sUSD_UNDERLYING),
      // $0.378 (8 decimals); converted to ETH (18 decimals)
      OracleTestUtils.usdToEth(37_800_000, ChainlinkEthereum.ETH__USD),
      'sUSD oracle output'
    );
  }
}
