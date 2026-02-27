// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';

import {AgentConfigLib} from './AgentConfigLib.sol';
import {BaseActivateRiskAgentPayload} from './BaseActivateRiskAgentPayload.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title Activate Capo Risk Agent and expand Rates Agent on more networks
 * @author BGD Labs (@bgdlabs)
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601
 */
contract AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130 is
  BaseActivateRiskAgentPayload
{
  address public constant RATES_AGENT = 0xc42f40Bc50e7342867Be7F823a4358cba5089063;
  uint96 public constant LINK_AMOUNT = 50 ether;

  function getAllowedMarkets() public pure override returns (address[] memory) {
    address[] memory markets = new address[](3);
    markets[0] = AaveV3ArbitrumAssets.USDCn_UNDERLYING;
    markets[1] = AaveV3ArbitrumAssets.USDT_UNDERLYING;
    markets[2] = AaveV3ArbitrumAssets.WETH_UNDERLYING;

    return markets;
  }

  function _getConfig() internal pure override returns (PayloadConfig memory) {
    return
      PayloadConfig({
        admin: GovernanceV3Arbitrum.EXECUTOR_LVL_1,
        riskOracle: AaveV3Arbitrum.EDGE_RISK_ORACLE,
        agentAddress: RATES_AGENT,
        expirationPeriod: 8 hours,
        minimumDelay: 8 hours,
        updateType: 'RateStrategyUpdate',
        agentContext: abi.encode(AaveV3Arbitrum.CONFIG_ENGINE),
        agentHub: MiscArbitrum.AGENT_HUB,
        rangeValidationModule: MiscArbitrum.RANGE_VALIDATION_MODULE,
        robotOperator: MiscArbitrum.AAVE_CL_ROBOT_OPERATOR,
        agentHubAutomation: MiscArbitrum.AGENT_HUB_AUTOMATION,
        linkToken: AaveV3ArbitrumAssets.LINK_UNDERLYING,
        linkAmount: LINK_AMOUNT,
        withdrawLinkFromCollector: true,
        pool: AaveV3Arbitrum.POOL,
        collector: AaveV3Arbitrum.COLLECTOR,
        automationName: 'Interest Rate Agent'
      });
  }

  function _configureRangeValidation(
    address rangeValidationModule,
    address agentHub,
    uint256 agentId
  ) internal override {
    IRangeValidationModule(rangeValidationModule).setRangeConfigByMarket(
      agentHub,
      agentId,
      AaveV3ArbitrumAssets.WETH_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.wethSlope2RangeConfig()
    );
    IRangeValidationModule(rangeValidationModule).setRangeConfigByMarket(
      agentHub,
      agentId,
      AaveV3ArbitrumAssets.USDCn_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
    IRangeValidationModule(rangeValidationModule).setRangeConfigByMarket(
      agentHub,
      agentId,
      AaveV3ArbitrumAssets.USDT_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
  }

  function _grantRiskAdminPermissions(address agentAddress) internal override {
    AaveV3Arbitrum.ACL_MANAGER.addRiskAdmin(agentAddress);
  }
}
