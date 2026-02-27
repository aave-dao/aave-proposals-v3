// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';

import {AgentConfigLib} from './AgentConfigLib.sol';
import {BaseActivateRiskAgentPayload} from './BaseActivateRiskAgentPayload.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title Activate Capo Risk Agent and expand Rates Agent on more networks
 * @author BGD Labs (@bgdlabs)
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601
 */
contract AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130 is
  BaseActivateRiskAgentPayload
{
  address public constant RATES_AGENT = 0x72b89100DB6f0Bde118Ebb34E71FA95A6DC59038;
  uint96 public constant LINK_AMOUNT = 50 ether;

  function getAllowedMarkets() public pure override returns (address[] memory) {
    address[] memory markets = new address[](3);
    markets[0] = AaveV3AvalancheAssets.USDC_UNDERLYING;
    markets[1] = AaveV3AvalancheAssets.USDt_UNDERLYING;
    markets[2] = AaveV3AvalancheAssets.WETHe_UNDERLYING;

    return markets;
  }

  function _getConfig() internal pure override returns (PayloadConfig memory) {
    return
      PayloadConfig({
        admin: GovernanceV3Avalanche.EXECUTOR_LVL_1,
        riskOracle: AaveV3Avalanche.EDGE_RISK_ORACLE,
        agentAddress: RATES_AGENT,
        expirationPeriod: 8 hours,
        minimumDelay: 8 hours,
        updateType: 'RateStrategyUpdate',
        agentContext: abi.encode(AaveV3Avalanche.CONFIG_ENGINE),
        agentHub: MiscAvalanche.AGENT_HUB,
        rangeValidationModule: MiscAvalanche.RANGE_VALIDATION_MODULE,
        robotOperator: MiscAvalanche.AAVE_CL_ROBOT_OPERATOR,
        agentHubAutomation: MiscAvalanche.AGENT_HUB_AUTOMATION,
        linkToken: AaveV3AvalancheAssets.LINKe_UNDERLYING,
        linkAmount: LINK_AMOUNT,
        withdrawLinkFromCollector: true,
        pool: AaveV3Avalanche.POOL,
        collector: AaveV3Avalanche.COLLECTOR,
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
      AaveV3AvalancheAssets.WETHe_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.wethSlope2RangeConfig()
    );
    IRangeValidationModule(rangeValidationModule).setRangeConfigByMarket(
      agentHub,
      agentId,
      AaveV3AvalancheAssets.USDC_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
    IRangeValidationModule(rangeValidationModule).setRangeConfigByMarket(
      agentHub,
      agentId,
      AaveV3AvalancheAssets.USDt_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
  }

  function _grantRiskAdminPermissions(address agentAddress) internal override {
    AaveV3Avalanche.ACL_MANAGER.addRiskAdmin(agentAddress);
  }
}
