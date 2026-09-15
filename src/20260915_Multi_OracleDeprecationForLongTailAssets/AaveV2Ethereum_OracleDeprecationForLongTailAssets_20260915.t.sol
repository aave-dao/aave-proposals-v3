// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';

import 'forge-std/Test.sol';
import {ProtocolV2TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';
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
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25982593);
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
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.FRAX_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'FRAX kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'FRAX base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'FRAX s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 3000000000000000000000000000 : 3000000000000000000000000000,
        'FRAX s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'6855e5544cd803bf24c9612b3f12c009116b0ee1'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'FRAX stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'FRAX stable slope2 unchanged'
      );
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.LUSD_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'LUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'LUSD base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'LUSD s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'LUSD s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'7b3217a81d1ade9b0666fea260228102e8105e99'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'LUSD stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'LUSD stable slope2 unchanged'
      );
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.TUSD_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 10000000000000000000000000 : 10000000000000000000000000,
        'TUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 10000000000000000000000000,
        'TUSD base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'TUSD s1');
      assertEq(rate.variableRateSlope2(), afterExecution ? 0 : 0, 'TUSD s2');
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'2821b41f1fa07c0270a3f0de91b24b9766f312fd'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'TUSD stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'TUSD stable slope2 unchanged'
      );
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.USDP_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'USDP kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'USDP base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'USDP s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 3000000000000000000000000000 : 3000000000000000000000000000,
        'USDP s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'6855e5544cd803bf24c9612b3f12c009116b0ee1'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'USDP stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'USDP stable slope2 unchanged'
      );
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.AMPL_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'AMPL kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 0 : 200000000000000000000000000,
        'AMPL base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'AMPL s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 0 : 3000000000000000000000000000,
        'AMPL s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'6855e5544cd803bf24c9612b3f12c009116b0ee1'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'AMPL stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'AMPL stable slope2 unchanged'
      );
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.RAI_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'RAI kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'RAI base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'RAI s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 3000000000000000000000000000 : 3000000000000000000000000000,
        'RAI s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'7b3217a81d1ade9b0666fea260228102e8105e99'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'RAI stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'RAI stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.sUSD_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'sUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 0 : 200000000000000000000000000,
        'sUSD base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'sUSD s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 0 : 3000000000000000000000000000,
        'sUSD s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'6855e5544cd803bf24c9612b3f12c009116b0ee1'))
      );
      assertEq(
        rate.stableRateSlope1(),
        previous.stableRateSlope1(),
        'sUSD stable slope1 unchanged'
      );
      assertEq(
        rate.stableRateSlope2(),
        previous.stableRateSlope2(),
        'sUSD stable slope2 unchanged'
      );
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.YFI_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'YFI kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'YFI base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'YFI s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 3000000000000000000000000000 : 3000000000000000000000000000,
        'YFI s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'2c206fa2127ab7f1ce3dc987daf683ed5b9cf069'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'YFI stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'YFI stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.BAL_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'BAL kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'BAL base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'BAL s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'BAL s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'503efa3651e247f9078c6f66bb93e2a81566ee00'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'BAL stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'BAL stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.ENJ_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'ENJ kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'ENJ base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'ENJ s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'ENJ s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'2c206fa2127ab7f1ce3dc987daf683ed5b9cf069'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'ENJ stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'ENJ stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.KNC_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'KNC kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'KNC base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'KNC s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'KNC s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'2c206fa2127ab7f1ce3dc987daf683ed5b9cf069'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'KNC stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'KNC stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.REN_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 450000000000000000000000000 : 450000000000000000000000000,
        'REN kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 200000000000000000000000000,
        'REN base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'REN s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 3000000000000000000000000000,
        'REN s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'2c206fa2127ab7f1ce3dc987daf683ed5b9cf069'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'REN stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'REN stable slope2 unchanged');
    }
    {
      IDefaultInterestRateStrategy rate = IDefaultInterestRateStrategy(
        AaveV2Ethereum
          .POOL
          .getReserveData(AaveV2EthereumAssets.ZRX_UNDERLYING)
          .interestRateStrategyAddress
      );
      assertEq(
        rate.OPTIMAL_UTILIZATION_RATE(),
        afterExecution ? 10000000000000000000000000 : 10000000000000000000000000,
        'ZRX kink'
      );
      assertEq(
        rate.baseVariableBorrowRate(),
        afterExecution ? 200000000000000000000000000 : 10000000000000000000000000,
        'ZRX base'
      );
      assertEq(rate.variableRateSlope1(), afterExecution ? 0 : 0, 'ZRX s1');
      assertEq(
        rate.variableRateSlope2(),
        afterExecution ? 400000000000000000000000000 : 0,
        'ZRX s2'
      );
      IDefaultInterestRateStrategy previous = IDefaultInterestRateStrategy(
        address(bytes20(hex'91773a61759398d33c252f25a38da77a51e0c9ff'))
      );
      assertEq(rate.stableRateSlope1(), previous.stableRateSlope1(), 'ZRX stable slope1 unchanged');
      assertEq(rate.stableRateSlope2(), previous.stableRateSlope2(), 'ZRX stable slope2 unchanged');
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.AMPL_UNDERLYING),
      proposal.AMPL_PRICE_FEED(),
      'AMPL source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.AMPL_UNDERLYING),
      ((117420000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'AMPL oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.BAL_UNDERLYING),
      proposal.BAL_PRICE_FEED(),
      'BAL source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.BAL_UNDERLYING),
      ((14240000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'BAL oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.ENJ_UNDERLYING),
      proposal.ENJ_PRICE_FEED(),
      'ENJ source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.ENJ_UNDERLYING),
      ((3720000 * 1e18) / uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'ENJ oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.FRAX_UNDERLYING),
      proposal.FRAX_PRICE_FEED(),
      'FRAX source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.FRAX_UNDERLYING),
      ((100000000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'FRAX oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.KNC_UNDERLYING),
      proposal.KNC_PRICE_FEED(),
      'KNC source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.KNC_UNDERLYING),
      ((13560000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'KNC oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.LUSD_UNDERLYING),
      proposal.LUSD_PRICE_FEED(),
      'LUSD source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.LUSD_UNDERLYING),
      ((100000000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'LUSD oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.RAI_UNDERLYING),
      proposal.RAI_PRICE_FEED(),
      'RAI source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.RAI_UNDERLYING),
      ((273390000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'RAI oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.REN_UNDERLYING),
      proposal.REN_PRICE_FEED(),
      'REN source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.REN_UNDERLYING),
      ((330000 * 1e18) / uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'REN oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.TUSD_UNDERLYING),
      proposal.TUSD_PRICE_FEED(),
      'TUSD source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.TUSD_UNDERLYING),
      ((100000000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'TUSD oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.USDP_UNDERLYING),
      proposal.USDP_PRICE_FEED(),
      'USDP source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.USDP_UNDERLYING),
      ((100000000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'USDP oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.YFI_UNDERLYING),
      proposal.YFI_PRICE_FEED(),
      'YFI source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.YFI_UNDERLYING),
      ((239681630000 * 1e18) /
        uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'YFI oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.ZRX_UNDERLYING),
      proposal.ZRX_PRICE_FEED(),
      'ZRX source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.ZRX_UNDERLYING),
      ((9660000 * 1e18) / uint256(IChainlinkAggregator(ChainlinkEthereum.ETH__USD).latestAnswer())),
      'ZRX oracle output'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getSourceOfAsset(AaveV2EthereumAssets.sUSD_UNDERLYING),
      proposal.sUSD_PRICE_FEED(),
      'sUSD source'
    );
    assertEq(
      AaveV2Ethereum.ORACLE.getAssetPrice(AaveV2EthereumAssets.sUSD_UNDERLYING),
      ((29520000 * 1e18) /
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
