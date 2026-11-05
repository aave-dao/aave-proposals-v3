// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3XLayer, AaveV3XLayerAssets, AaveV3XLayerEModes} from 'aave-address-book/AaveV3XLayer.sol';
import {MiscXLayer} from 'aave-address-book/MiscXLayer.sol';
import {AgentHubAgentActivationPayload} from '../helpers/agent-hub/AgentHubAgentActivationPayload.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';

/**
 * @title Onboard_PTUSDG25FEB2027_Oracle
 * @author LlamaRisk
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/7
 */
contract AaveV3XLayer_Onboard_PTUSDG25FEB2027_Oracle_20261021 is AgentHubAgentActivationPayload {
  function execute() external {
    AgentHubConfig memory agentHubConfig = AgentHubConfig({
      aclManager: address(AaveV3XLayer.ACL_MANAGER),
      agentHub: MiscXLayer.AGENT_HUB,
      rangeValidationModule: MiscXLayer.RANGE_VALIDATION_MODULE,
      agentAdmin: MiscXLayer.PROTOCOL_GUARDIAN,
      riskOracle: MiscXLayer.LLAMARISK_RISK_ORACLE
    });

    address[] memory ptMarkets = new address[](1);
    ptMarkets[0] = AaveV3XLayerAssets.PT_USDG_25FEB2027_UNDERLYING;

    uint256 discountAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: MiscXLayer.LLAMARISK_PT_DISCOUNT_RATE_AGENT,
        expirationPeriod: AgentHubConfigs.DISCOUNT_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.DISCOUNT_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.DISCOUNT_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        agentContext: bytes(''),
        allowedMarkets: ptMarkets
      })
    );

    address[] memory eModeMarkets = new address[](1);
    // The AgentHub represents eMode category ids as address values.
    eModeMarkets[0] = address(
      uint160(AaveV3XLayerEModes.PT_USDG_29OCT2026_PT_USDG_25FEB2027__USDT_GHO_USDC)
    );

    uint256 eModeAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: MiscXLayer.LLAMARISK_PT_EMODE_AGENT,
        expirationPeriod: AgentHubConfigs.EMODE_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.EMODE_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.EMODE_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        // The eMode agent executes updates through the Aave ConfigEngine.
        agentContext: abi.encode(AaveV3XLayer.CONFIG_ENGINE),
        allowedMarkets: eModeMarkets
      })
    );

    // Fresh agent ids require default ranges before they can inject updates.
    _setDefaultRange(
      agentHubConfig,
      discountAgentId,
      string.concat(AgentHubConfigs.DISCOUNT_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
      AgentHubConfigs.DISCOUNT_RANGE_ABS
    );
    _setDefaultRange(agentHubConfig, eModeAgentId, 'EModeLTV', AgentHubConfigs.EMODE_RANGE_ABS_BPS);
    _setDefaultRange(
      agentHubConfig,
      eModeAgentId,
      'EModeLiquidationThreshold',
      AgentHubConfigs.EMODE_RANGE_ABS_BPS
    );
    _setDefaultRange(
      agentHubConfig,
      eModeAgentId,
      'EModeLiquidationBonus',
      AgentHubConfigs.EMODE_RANGE_ABS_BPS
    );
  }
}
