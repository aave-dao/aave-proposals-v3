// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';

import {AgentConfigLib} from './AgentConfigLib.sol';
import {BaseActivateRiskAgentPayload} from './BaseActivateRiskAgentPayload.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title Activate Capo Risk Agent and expand Rates Agent on more networks
 * @author BGD Labs (@bgdlabs)
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601
 */
contract AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130 is
  BaseActivateRiskAgentPayload
{
  address public constant RATES_AGENT = 0xAD83c71619368390c4C4fd1Aa472235FD4Ea3F32;
  address public constant LINK_TOKEN = 0x88Fb150BDc53A65fe94Dea0c9BA0a6dAf8C6e196;
  uint96 public constant LINK_AMOUNT = 30 ether;

  function getAllowedMarkets() public pure override returns (address[] memory) {
    address[] memory markets = new address[](2);
    markets[0] = AaveV3BaseAssets.USDC_UNDERLYING;
    markets[1] = AaveV3BaseAssets.WETH_UNDERLYING;

    return markets;
  }

  function _getConfig() internal pure override returns (PayloadConfig memory) {
    return
      PayloadConfig({
        admin: GovernanceV3Base.EXECUTOR_LVL_1,
        riskOracle: AaveV3Base.EDGE_RISK_ORACLE,
        agentAddress: RATES_AGENT,
        expirationPeriod: 8 hours,
        minimumDelay: 8 hours,
        updateType: 'RateStrategyUpdate',
        agentContext: abi.encode(AaveV3Base.CONFIG_ENGINE),
        agentHub: MiscBase.AGENT_HUB,
        rangeValidationModule: MiscBase.RANGE_VALIDATION_MODULE,
        robotOperator: MiscBase.AAVE_CL_ROBOT_OPERATOR,
        agentHubAutomation: MiscBase.AGENT_HUB_AUTOMATION,
        linkToken: LINK_TOKEN,
        linkAmount: LINK_AMOUNT,
        withdrawLinkFromCollector: false,
        pool: AaveV3Base.POOL,
        collector: AaveV3Base.COLLECTOR,
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
      AaveV3BaseAssets.WETH_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.wethSlope2RangeConfig()
    );
    IRangeValidationModule(rangeValidationModule).setRangeConfigByMarket(
      agentHub,
      agentId,
      AaveV3BaseAssets.USDC_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
  }

  function _grantRiskAdminPermissions(address agentAddress) internal override {
    AaveV3Base.ACL_MANAGER.addRiskAdmin(agentAddress);
  }
}
