// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';

import 'forge-std/Test.sol';
import {ProtocolV2TestBase, ReserveConfig, InterestStrategyValues} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';

import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {OracleTestUtils} from './OracleTestUtils.sol';

import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

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
    _assertRates(false);
    defaultTest(
      'AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915',
      AaveV2Ethereum.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }
  function _assertRates(bool afterExecution) internal view {
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.FRAX_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.FRAX_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: previous.variableRateSlope2()
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.LUSD_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.LUSD_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.TUSD_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.TUSD_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.USDP_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.USDP_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: previous.variableRateSlope2()
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.AMPL_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.AMPL_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.RAI_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.RAI_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: previous.variableRateSlope2()
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.sUSD_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.sUSD_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.YFI_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.YFI_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(),
          stableRateSlope2: previous.stableRateSlope2(),
          optimalUsageRatio: previous.OPTIMAL_UTILIZATION_RATE(),
          baseVariableBorrowRate: previous.baseVariableBorrowRate(),
          variableRateSlope1: previous.variableRateSlope1(),
          variableRateSlope2: previous.variableRateSlope2()
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.BAL_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.BAL_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.ENJ_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.ENJ_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.KNC_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.KNC_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.REN_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.REN_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.ZRX_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = _strategiesBefore[
        AaveV2EthereumAssets.ZRX_UNDERLYING
      ];
      _validateInterestRateStrategy(
        strategy,
        strategy,
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
  function test_configurationAndUntouchedFields() public {
    uint256[] memory expected = new uint256[](13);
    expected[0] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.AMPL_UNDERLYING).data;
    expected[1] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.BAL_UNDERLYING).data;
    expected[2] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.ENJ_UNDERLYING).data;
    expected[3] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.FRAX_UNDERLYING).data;
    expected[4] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.KNC_UNDERLYING).data;
    expected[5] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.LUSD_UNDERLYING).data;
    expected[6] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.RAI_UNDERLYING).data;
    expected[7] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.REN_UNDERLYING).data;
    expected[8] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.TUSD_UNDERLYING).data;
    expected[9] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.USDP_UNDERLYING).data;
    expected[10] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.YFI_UNDERLYING).data;
    expected[11] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.ZRX_UNDERLYING).data;
    expected[12] = AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.sUSD_UNDERLYING).data;
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.AMPL_UNDERLYING).data,
      expected[0],
      'AMPL configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.BAL_UNDERLYING).data,
      expected[1],
      'BAL configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.ENJ_UNDERLYING).data,
      expected[2],
      'ENJ configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.FRAX_UNDERLYING).data,
      expected[3],
      'FRAX configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.KNC_UNDERLYING).data,
      expected[4],
      'KNC configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.LUSD_UNDERLYING).data,
      expected[5],
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.RAI_UNDERLYING).data,
      expected[6],
      'RAI configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.REN_UNDERLYING).data,
      expected[7],
      'REN configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.TUSD_UNDERLYING).data,
      expected[8],
      'TUSD configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.USDP_UNDERLYING).data,
      expected[9],
      'USDP configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.YFI_UNDERLYING).data,
      expected[10],
      'YFI configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.ZRX_UNDERLYING).data,
      expected[11],
      'ZRX configuration and untouched fields'
    );
    assertEq(
      AaveV2Ethereum.POOL.getConfiguration(AaveV2EthereumAssets.sUSD_UNDERLYING).data,
      expected[12],
      'sUSD configuration and untouched fields'
    );
  }
}
