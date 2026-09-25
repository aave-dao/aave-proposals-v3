// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma, AaveV3PlasmaAssets, AaveV3PlasmaEModes} from 'aave-address-book/AaveV3Plasma.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
import {AgentHubAgentActivationPayload} from '../helpers/agent-hub/AgentHubAgentActivationPayload.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';

/**
 * @title Onboard_PTsUSDe22OCT2026_Oracle
 * @author LlamaRisk
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/5
 */
contract AaveV3Plasma_Onboard_PTsUSDe22OCT2026_Oracle_20260925 is AgentHubAgentActivationPayload {
  /// @dev Protocol guardian, so a misbehaving agent can be disabled without a governance cycle.
  ///      Registration stays governance-only: `registerAgent` and `setAgentAdmin` are `onlyOwner`.
  address public constant AGENT_ADMIN = MiscPlasma.PROTOCOL_GUARDIAN;

  /// @dev No suffix is needed because this RiskOracle is dedicated to the LlamaGuard stack.
  string public constant UPDATE_TYPE_SUFFIX = '';

  function execute() external {
    AgentHubConfig memory agentHubConfig = AgentHubConfig({
      aclManager: address(AaveV3Plasma.ACL_MANAGER),
      agentHub: MiscPlasma.AGENT_HUB,
      rangeValidationModule: MiscPlasma.RANGE_VALIDATION_MODULE,
      agentAdmin: AGENT_ADMIN,
      riskOracle: MiscPlasma.LLAMARISK_RISK_ORACLE
    });

    address discountRateAgent = MiscPlasma.LLAMARISK_PT_DISCOUNT_RATE_AGENT;

    address[] memory ptMarkets = new address[](1);
    ptMarkets[0] = AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING;

    uint256 discountAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: discountRateAgent,
        expirationPeriod: AgentHubConfigs.DISCOUNT_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.DISCOUNT_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.DISCOUNT_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        agentContext: bytes(''),
        allowedMarkets: ptMarkets
      })
    );

    address eModeAgent = MiscPlasma.LLAMARISK_PT_EMODE_AGENT;

    address[] memory eModeMarkets = new address[](2);
    // The AgentHub represents eMode category ids as address values.
    eModeMarkets[0] = address(uint160(AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO));
    eModeMarkets[1] = address(uint160(AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDe));

    uint256 eModeAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: eModeAgent,
        expirationPeriod: AgentHubConfigs.EMODE_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.EMODE_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.EMODE_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        // The eMode agent executes updates through the Aave ConfigEngine.
        agentContext: abi.encode(AaveV3Plasma.CONFIG_ENGINE),
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
