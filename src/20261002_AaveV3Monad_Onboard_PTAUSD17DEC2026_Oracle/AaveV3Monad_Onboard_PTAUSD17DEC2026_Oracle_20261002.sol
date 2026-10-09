// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Monad, AaveV3MonadAssets, AaveV3MonadEModes} from 'aave-address-book/AaveV3Monad.sol';
import {MiscMonad} from 'aave-address-book/MiscMonad.sol';
import {AgentHubAgentActivationPayload} from '../helpers/agent-hub/AgentHubAgentActivationPayload.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';

/**
 * @title Onboard_PTAUSD17DEC2026_Oracle
 * @author LlamaRisk
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119/6
 */
contract AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002 is AgentHubAgentActivationPayload {
  function execute() external {
    AgentHubConfig memory agentHubConfig = AgentHubConfig({
      aclManager: address(AaveV3Monad.ACL_MANAGER),
      agentHub: MiscMonad.AGENT_HUB,
      rangeValidationModule: MiscMonad.RANGE_VALIDATION_MODULE,
      agentAdmin: MiscMonad.PROTOCOL_GUARDIAN,
      riskOracle: MiscMonad.LLAMARISK_RISK_ORACLE
    });

    address[] memory ptMarkets = new address[](1);
    ptMarkets[0] = AaveV3MonadAssets.PT_AUSD_17DEC2026_UNDERLYING;

    uint256 discountAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT,
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
      uint160(AaveV3MonadEModes.PT_AUSD_17DEC2026__USDT0_USDC_USDe_mUSD_GHO)
    );

    uint256 eModeAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: MiscMonad.LLAMARISK_PT_EMODE_AGENT,
        expirationPeriod: AgentHubConfigs.EMODE_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.EMODE_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.EMODE_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        // The eMode agent executes updates through the Aave ConfigEngine.
        agentContext: abi.encode(AaveV3Monad.CONFIG_ENGINE),
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
