// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';

import 'forge-std/Test.sol';
import {ProtocolV2TestBase, ReserveConfig, InterestStrategyValues} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';

import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {IChainlinkAggregator} from 'aave-helpers/src/interfaces/IChainlinkAggregator.sol';

import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV2TestBase {
  AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26_032_357);
    proposal = new AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915();
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
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x6855E5544Cd803BF24c9612b3F12C009116B0ee1
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: 3_000_000_000_000_000_000_000_000_000 // unchanged; 300% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.LUSD_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x7B3217A81D1ADe9B0666feA260228102E8105e99
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
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
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x2821B41F1fA07c0270A3f0de91B24B9766F312FD
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 10_000_000_000_000_000_000_000_000, // unchanged; 1% (27 decimals)
          baseVariableBorrowRate: afterExecution
            ? 200_000_000_000_000_000_000_000_000
            : 10_000_000_000_000_000_000_000_000, // 1% -> 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: 0 // unchanged; 0% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.USDP_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x6855E5544Cd803BF24c9612b3F12C009116B0ee1
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: 3_000_000_000_000_000_000_000_000_000 // unchanged; 300% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.AMPL_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x6855E5544Cd803BF24c9612b3F12C009116B0ee1
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: afterExecution ? 0 : 200_000_000_000_000_000_000_000_000, // 20% -> 0% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: afterExecution ? 0 : 3_000_000_000_000_000_000_000_000_000 // 300% -> 0% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.RAI_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x7B3217A81D1ADe9B0666feA260228102E8105e99
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: 3_000_000_000_000_000_000_000_000_000 // unchanged; 300% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.sUSD_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x6855E5544Cd803BF24c9612b3F12C009116B0ee1
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: afterExecution ? 0 : 200_000_000_000_000_000_000_000_000, // 20% -> 0% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: afterExecution ? 0 : 3_000_000_000_000_000_000_000_000_000 // 300% -> 0% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.YFI_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x2c206fa2127aB7f1CE3dc987daf683Ed5B9CF069
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
          variableRateSlope2: 3_000_000_000_000_000_000_000_000_000 // unchanged; 300% (27 decimals)
        })
      );
    }
    {
      address strategy = AaveV2Ethereum
        .POOL
        .getReserveData(AaveV2EthereumAssets.BAL_UNDERLYING)
        .interestRateStrategyAddress;
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x503eFA3651E247F9078C6F66bb93E2a81566EE00
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
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
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x2c206fa2127aB7f1CE3dc987daf683Ed5B9CF069
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
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
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x2c206fa2127aB7f1CE3dc987daf683Ed5B9CF069
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
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
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x2c206fa2127aB7f1CE3dc987daf683Ed5B9CF069
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 450_000_000_000_000_000_000_000_000, // unchanged; 45% (27 decimals)
          baseVariableBorrowRate: 200_000_000_000_000_000_000_000_000, // unchanged; 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
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
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        0x91773a61759398d33C252F25A38DA77a51e0c9Ff
      );
      _validateInterestRateStrategy(
        strategy,
        strategy,
        InterestStrategyValues({
          addressesProvider: address(AaveV2Ethereum.POOL_ADDRESSES_PROVIDER),
          stableRateSlope1: previous.stableRateSlope1(), // unchanged
          stableRateSlope2: previous.stableRateSlope2(), // unchanged
          optimalUsageRatio: 10_000_000_000_000_000_000_000_000, // unchanged; 1% (27 decimals)
          baseVariableBorrowRate: afterExecution
            ? 200_000_000_000_000_000_000_000_000
            : 10_000_000_000_000_000_000_000_000, // 1% -> 20% (27 decimals)
          variableRateSlope1: 0, // unchanged; 0% (27 decimals)
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
      ((123_960_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((13_170_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((4_610_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((100_000_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((14_010_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((100_000_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((265_870_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((330_000 * 1e18) / uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((100_000_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((100_000_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((228_663_680_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((9_810_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
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
      ((37_800_000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'sUSD oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
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
    _assertRates(true);
    _assertOracles();
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
