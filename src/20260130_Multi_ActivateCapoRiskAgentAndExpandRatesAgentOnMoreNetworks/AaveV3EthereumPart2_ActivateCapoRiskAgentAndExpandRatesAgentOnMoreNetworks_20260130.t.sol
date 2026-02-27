// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {IAaveV3ConfigEngine as IEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130} from './AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol';

import {AutomationCompatibleInterface} from '../interfaces/AutomationCompatibleInterface.sol';
import {IAgentHub} from '../interfaces/IAgentHub.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';

/**
 * @dev Test for AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol -vv
 */
contract AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130_Test is
  ProtocolV3TestBase
{
  using Strings for string;

  enum MarketType {
    STABLECOIN,
    WETH
  }
  error InvalidMarketType();

  AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130
    internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 24390711);
    proposal = new AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_validateAgentId() public view {
    string memory updateType = IAgentHub(MiscEthereum.AGENT_HUB).getUpdateType(
      proposal.CORE_RATES_AGENT_ID()
    );
    assertEq(updateType, 'RateStrategyUpdate_Core');
  }

  function test_rangeValidationConfiguration() public {
    address[4] memory markets = _getMarkets();
    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < markets.length && markets[i] != address(0); i++) {
      MarketType marketType = _getMarketType(markets[i]);
      IRangeValidationModule.RangeConfig memory slope2Config = IRangeValidationModule(
        MiscEthereum.RANGE_VALIDATION_MODULE
      ).getRangeConfigByMarket(
          MiscEthereum.AGENT_HUB,
          proposal.CORE_RATES_AGENT_ID(),
          markets[i],
          'VariableRateSlope2'
        );

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
    address[4] memory markets = _getMarkets();
    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < markets.length && markets[i] != address(0); i++) {
      address rateStrategyAddress = AaveV3Ethereum
        .AAVE_PROTOCOL_DATA_PROVIDER
        .getInterestRateStrategyAddress(markets[i]);

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
      IRiskOracle(AaveV3Ethereum.EDGE_RISK_ORACLE).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newRate),
        'RateStrategyUpdate_Core',
        markets[i],
        'additionalData'
      );

      // check injection allowed
      assertTrue(
        _checkAndPerformAutomation(
          MiscEthereum.AGENT_HUB_AUTOMATION,
          proposal.CORE_RATES_AGENT_ID()
        )
      );
    }
  }

  function test_injection_slope2_wrong_update() public {
    address[4] memory markets = _getMarkets();
    GovV3Helpers.executePayload(vm, address(proposal));

    for (uint256 i = 0; i < markets.length && markets[i] != address(0); i++) {
      address rateStrategyAddress = AaveV3Ethereum
        .AAVE_PROTOCOL_DATA_PROVIDER
        .getInterestRateStrategyAddress(markets[i]);

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
      IRiskOracle(AaveV3Ethereum.EDGE_RISK_ORACLE).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newRate),
        'RateStrategyUpdate',
        markets[i],
        'additionalData'
      );

      // check injection not allowed
      assertFalse(
        _checkAndPerformAutomation(
          MiscEthereum.AGENT_HUB_AUTOMATION,
          proposal.CORE_RATES_AGENT_ID()
        )
      );
    }
  }

  function _getMarkets() internal pure returns (address[4] memory) {
    return [
      AaveV3EthereumAssets.WETH_UNDERLYING,
      AaveV3EthereumAssets.USDC_UNDERLYING,
      AaveV3EthereumAssets.USDT_UNDERLYING,
      AaveV3EthereumAssets.USDe_UNDERLYING
    ];
  }

  function _getMarketType(address market) internal view returns (MarketType) {
    string memory symbol = IERC20(market).symbol();

    if (symbol.equal('WETH') || symbol.equal('WETH.e')) {
      return MarketType.WETH;
    } else if (
      symbol.equal('USDC') ||
      symbol.equal('USDT') ||
      symbol.equal(unicode'USD₮0') ||
      symbol.equal('USDt') ||
      symbol.equal('USDe')
    ) {
      return MarketType.STABLECOIN;
    } else {
      revert InvalidMarketType();
    }
  }

  function _checkAndPerformAutomation(
    address agentHubAutomation,
    uint256 agentId
  ) internal returns (bool) {
    uint256[] memory agentIds = new uint256[](1);
    agentIds[0] = agentId;

    (bool upkeepNeeded, bytes memory performData) = AutomationCompatibleInterface(
      agentHubAutomation
    ).checkUpkeep(abi.encode(agentIds));

    if (upkeepNeeded) {
      AutomationCompatibleInterface(agentHubAutomation).performUpkeep(performData);
    }
    return upkeepNeeded;
  }
}
