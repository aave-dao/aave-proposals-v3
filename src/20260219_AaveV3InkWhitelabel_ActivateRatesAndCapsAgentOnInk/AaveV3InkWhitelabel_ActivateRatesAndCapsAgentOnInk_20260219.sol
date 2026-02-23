// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {GovernanceV3InkWhitelabel} from 'aave-address-book/GovernanceV3InkWhitelabel.sol';
import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {MiscInkWhitelabel} from 'aave-address-book/MiscInkWhitelabel.sol';

import {IAgentHub, IAgentConfigurator} from '../interfaces/IAgentHub.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title Activate Rates and Caps Agent on Ink
 * @author BGD Labs (@bgdlabs)
 */
contract AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219 is IProposalGenericExecutor {
  address public constant RISK_ORACLE = 0x2e4d168044b4532B4182dc00434498082e13e0bf;

  address public constant SUPPLY_CAP_AGENT = 0xA2430ab7Ac492D70C2Bd4EA83FeAf6F8AF3e165C;
  address public constant BORROW_CAP_AGENT = 0x32fF33C9857A89b22207550FD75503A4A6BAbE12;
  address public constant RATES_AGENT = 0x050E8Fc96Dd6C1Ba971E3633C0B340680043661E;

  function execute() external {
    // 1. register agents on the agent-hub and grant roles
    uint256 supplyCapAgentId = _registerAgentAndGrantRole(
      SUPPLY_CAP_AGENT, // agentAddress
      3 days, // expiration period
      3 days, // min delay
      'SupplyCapUpdate', // update type
      abi.encode(AaveV3InkWhitelabel.CONFIG_ENGINE), // agent context
      getAllowedMarketsForSupplyCap() // allowed markets
    );
    uint256 borrowCapAgentId = _registerAgentAndGrantRole(
      BORROW_CAP_AGENT, // agentAddress
      3 days, // expiration period
      3 days, // min delay
      'BorrowCapUpdate', // update type
      abi.encode(AaveV3InkWhitelabel.CONFIG_ENGINE), // agent context
      getAllowedMarketsForBorrowCap() // allowed markets
    );
    uint256 ratesCapAgentId = _registerAgentAndGrantRole(
      RATES_AGENT, // agentAddress
      8 hours, // expiration period
      8 hours, // min delay
      'RateStrategyUpdate', // update type
      abi.encode(AaveV3InkWhitelabel.CONFIG_ENGINE), // agent context
      getAllowedMarketsForRates() // allowed markets
    );

    // 2. configure range constrains on the range-validation-module
    IRangeValidationModule.RangeConfig memory capsRangeConfig = IRangeValidationModule.RangeConfig({
      maxIncrease: 30_00, // 30% increase
      maxDecrease: 30_00, // 30% decrease
      isIncreaseRelative: true,
      isDecreaseRelative: true
    });
    IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setDefaultRangeConfig(
      MiscInkWhitelabel.AGENT_HUB,
      supplyCapAgentId,
      'SupplyCapUpdate',
      capsRangeConfig
    );
    IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setDefaultRangeConfig(
      MiscInkWhitelabel.AGENT_HUB,
      borrowCapAgentId,
      'BorrowCapUpdate',
      capsRangeConfig
    );

    // for rates, we configure max change constrains per market on the range validation module.
    // range validation module checks first if constrains exists per market and then fallbacks to default if it doesn't
    address[] memory marketsForRates = getAllowedMarketsForRates();

    for (uint256 i = 0; i < marketsForRates.length; i++) {
      address market = marketsForRates[i];
      IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
        MiscInkWhitelabel.AGENT_HUB,
        ratesCapAgentId,
        market,
        'OptimalUsageRatio',
        IRangeValidationModule.RangeConfig({
          maxIncrease: 1_00, // 1% increase
          maxDecrease: 1_00, // 1% decrease
          isIncreaseRelative: false,
          isDecreaseRelative: false
        })
      );
      IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
        MiscInkWhitelabel.AGENT_HUB,
        ratesCapAgentId,
        market,
        'BaseVariableBorrowRate',
        IRangeValidationModule.RangeConfig({
          maxIncrease: 50, // 0.5% increase
          maxDecrease: 50, // 0.5% decrease
          isIncreaseRelative: false,
          isDecreaseRelative: false
        })
      );

      // slope1 and slope2 constrains are different for WETH, kBTC vs other assets.
      if (
        market == AaveV3InkWhitelabelAssets.kBTC_UNDERLYING ||
        market == AaveV3InkWhitelabelAssets.WETH_UNDERLYING
      ) {
        IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
          MiscInkWhitelabel.AGENT_HUB,
          ratesCapAgentId,
          market,
          'VariableRateSlope1',
          IRangeValidationModule.RangeConfig({
            maxIncrease: 15, // 0.15% increase
            maxDecrease: 15, // 0.15% decrease
            isIncreaseRelative: false,
            isDecreaseRelative: false
          })
        );
        IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
          MiscInkWhitelabel.AGENT_HUB,
          ratesCapAgentId,
          market,
          'VariableRateSlope2',
          IRangeValidationModule.RangeConfig({
            maxIncrease: 1_50, // 1.5% increase
            maxDecrease: 1_50, // 1.5% decrease
            isIncreaseRelative: false,
            isDecreaseRelative: false
          })
        );
      } else {
        IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
          MiscInkWhitelabel.AGENT_HUB,
          ratesCapAgentId,
          market,
          'VariableRateSlope1',
          IRangeValidationModule.RangeConfig({
            maxIncrease: 20, // 0.2% increase
            maxDecrease: 20, // 0.2% decrease
            isIncreaseRelative: false,
            isDecreaseRelative: false
          })
        );
        IRangeValidationModule(MiscInkWhitelabel.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
          MiscInkWhitelabel.AGENT_HUB,
          ratesCapAgentId,
          market,
          'VariableRateSlope2',
          IRangeValidationModule.RangeConfig({
            maxIncrease: 2_00, // 2% increase
            maxDecrease: 2_00, // 2% decrease
            isIncreaseRelative: false,
            isDecreaseRelative: false
          })
        );
      }
    }
  }

  function getAllowedMarketsForSupplyCap() public view returns (address[] memory) {
    return AaveV3InkWhitelabel.POOL.getReservesList();
  }

  /// @dev we do not return all assets like supply cap, as some assets are not borrowable like wrsETH, rzETH, weETH
  function getAllowedMarketsForBorrowCap() public pure returns (address[] memory) {
    address[] memory markets = new address[](6);
    markets[0] = AaveV3InkWhitelabelAssets.USDT_UNDERLYING;
    markets[1] = AaveV3InkWhitelabelAssets.USDC_UNDERLYING;
    markets[2] = AaveV3InkWhitelabelAssets.USDG_UNDERLYING;
    markets[3] = AaveV3InkWhitelabelAssets.GHO_UNDERLYING;
    markets[4] = AaveV3InkWhitelabelAssets.kBTC_UNDERLYING;
    markets[5] = AaveV3InkWhitelabelAssets.WETH_UNDERLYING;

    return markets;
  }

  function getAllowedMarketsForRates() public pure returns (address[] memory) {
    address[] memory markets = new address[](6);
    markets[0] = AaveV3InkWhitelabelAssets.USDT_UNDERLYING;
    markets[1] = AaveV3InkWhitelabelAssets.USDC_UNDERLYING;
    markets[2] = AaveV3InkWhitelabelAssets.USDG_UNDERLYING;
    markets[3] = AaveV3InkWhitelabelAssets.GHO_UNDERLYING;
    markets[4] = AaveV3InkWhitelabelAssets.kBTC_UNDERLYING;
    markets[5] = AaveV3InkWhitelabelAssets.WETH_UNDERLYING;

    return markets;
  }

  function _registerAgentAndGrantRole(
    address agentAddress,
    uint256 expirationPeriod,
    uint256 minDelay,
    string memory updateType,
    bytes memory agentContext,
    address[] memory allowedMarkets
  ) internal returns (uint256 agentId) {
    // give risk admin role to the agent contract
    AaveV3InkWhitelabel.ACL_MANAGER.addRiskAdmin(agentAddress);

    return
      IAgentHub(MiscInkWhitelabel.AGENT_HUB).registerAgent(
        IAgentConfigurator.AgentRegistrationInput({
          admin: GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER_EXECUTOR,
          riskOracle: RISK_ORACLE,
          isAgentEnabled: true, // default
          isAgentPermissioned: false, // default
          isMarketsFromAgentEnabled: false, // default
          agentAddress: agentAddress,
          expirationPeriod: expirationPeriod,
          minimumDelay: minDelay,
          updateType: updateType,
          agentContext: agentContext,
          allowedMarkets: allowedMarkets,
          restrictedMarkets: new address[](0), // default
          permissionedSenders: new address[](0) // default
        })
      );
  }
}
