// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {IAaveV3ConfigEngine as IEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {GovV3Helpers} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';

import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';
import {BaseActivateRiskAgentTest} from './BaseActivateRiskAgentTest.t.sol';

/**
 * @dev Base test contract for rates agent activation tests
 * Provides common test logic for Avalanche, Arbitrum, and Base networks
 * Extends BaseActivateRiskAgentTest with rates-specific tests
 */
abstract contract BaseActivateRatesRiskAgentTest is BaseActivateRiskAgentTest {
  using Strings for string;

  enum MarketType {
    STABLECOIN,
    WETH
  }
  error InvalidMarketType();

  function test_rangeValidationConfiguration() public {
    TestConfig memory config = _getConfig();
    address[] memory markets = config.assetsToEnable;
    GovV3Helpers.executePayload(vm, config.proposal);

    for (uint256 i = 0; i < markets.length && markets[i] != address(0); i++) {
      MarketType marketType = _getMarketType(markets[i]);
      IRangeValidationModule.RangeConfig memory slope2Config = IRangeValidationModule(
        config.rangeValidationModule
      ).getRangeConfigByMarket(config.agentHub, config.agentId, markets[i], 'VariableRateSlope2');

      assertEq(slope2Config.isIncreaseRelative, false);
      assertEq(slope2Config.isDecreaseRelative, false);

      if (marketType == MarketType.WETH) {
        assertEq(slope2Config.maxIncrease, 1_50);
        assertEq(slope2Config.maxDecrease, 1_50);
      } else if (marketType == MarketType.STABLECOIN) {
        assertEq(slope2Config.maxIncrease, 2_00);
        assertEq(slope2Config.maxDecrease, 2_00);
      }
    }
  }

  function test_injection_slope2() public {
    TestConfig memory config = _getConfig();
    address[] memory markets = config.assetsToEnable;
    GovV3Helpers.executePayload(vm, config.proposal);

    for (uint256 i = 0; i < markets.length && markets[i] != address(0); i++) {
      address rateStrategyAddress = config.protocolDataProvider.getInterestRateStrategyAddress(
        markets[i]
      );

      IDefaultInterestRateStrategyV2.InterestRateData
        memory currentRate = IDefaultInterestRateStrategyV2(rateStrategyAddress)
          .getInterestRateDataBps(markets[i]);

      MarketType marketType = _getMarketType(markets[i]);
      IEngine.InterestRateInputData memory newRate;

      if (marketType == MarketType.WETH) {
        newRate = IEngine.InterestRateInputData({
          optimalUsageRatio: currentRate.optimalUsageRatio,
          baseVariableBorrowRate: currentRate.baseVariableBorrowRate,
          variableRateSlope1: currentRate.variableRateSlope1,
          variableRateSlope2: currentRate.variableRateSlope2 + 1_50 // 1.5% increase
        });
      } else if (marketType == MarketType.STABLECOIN) {
        newRate = IEngine.InterestRateInputData({
          optimalUsageRatio: currentRate.optimalUsageRatio,
          baseVariableBorrowRate: currentRate.baseVariableBorrowRate,
          variableRateSlope1: currentRate.variableRateSlope1,
          variableRateSlope2: currentRate.variableRateSlope2 + 2_00 // 2% increase
        });
      }

      vm.prank(0x42939e82DF15afc586bb95f7dD69Afb6Dc24A6f9);
      IRiskOracle(config.edgeRiskOracle).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newRate),
        'RateStrategyUpdate',
        markets[i],
        'additionalData'
      );

      // check injection allowed
      assertTrue(_checkAndPerformAutomation(config.agentHubAutomation, config.agentId));
    }
  }

  function test_injection_slope2_wrong_update() public {
    TestConfig memory config = _getConfig();
    address[] memory markets = config.assetsToEnable;
    GovV3Helpers.executePayload(vm, config.proposal);

    for (uint256 i = 0; i < markets.length && markets[i] != address(0); i++) {
      address rateStrategyAddress = config.protocolDataProvider.getInterestRateStrategyAddress(
        markets[i]
      );

      IDefaultInterestRateStrategyV2.InterestRateData
        memory currentRate = IDefaultInterestRateStrategyV2(rateStrategyAddress)
          .getInterestRateDataBps(markets[i]);

      MarketType marketType = _getMarketType(markets[i]);
      IEngine.InterestRateInputData memory newRate;

      if (marketType == MarketType.WETH) {
        newRate = IEngine.InterestRateInputData({
          optimalUsageRatio: currentRate.optimalUsageRatio,
          baseVariableBorrowRate: currentRate.baseVariableBorrowRate,
          variableRateSlope1: currentRate.variableRateSlope1,
          variableRateSlope2: currentRate.variableRateSlope2 + 1_51 // 1.51% increase
        });
      } else if (marketType == MarketType.STABLECOIN) {
        newRate = IEngine.InterestRateInputData({
          optimalUsageRatio: currentRate.optimalUsageRatio,
          baseVariableBorrowRate: currentRate.baseVariableBorrowRate,
          variableRateSlope1: currentRate.variableRateSlope1,
          variableRateSlope2: currentRate.variableRateSlope2 + 2_01 // 2.1% increase
        });
      }

      vm.prank(0x42939e82DF15afc586bb95f7dD69Afb6Dc24A6f9);
      IRiskOracle(config.edgeRiskOracle).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newRate),
        'RateStrategyUpdate',
        config.assetsToEnable[i],
        'additionalData'
      );

      // check injection not allowed
      assertFalse(_checkAndPerformAutomation(config.agentHubAutomation, config.agentId));
    }
  }

  function _getMarketType(address market) internal view returns (MarketType) {
    string memory symbol = IERC20(market).symbol();

    if (symbol.equal('WETH') || symbol.equal('WETH.e')) {
      return MarketType.WETH;
    } else if (
      symbol.equal('USDC') ||
      symbol.equal('USDT') ||
      symbol.equal(unicode'USD₮0') ||
      symbol.equal(unicode'USDt')
    ) {
      return MarketType.STABLECOIN;
    } else {
      revert InvalidMarketType();
    }
  }
}
