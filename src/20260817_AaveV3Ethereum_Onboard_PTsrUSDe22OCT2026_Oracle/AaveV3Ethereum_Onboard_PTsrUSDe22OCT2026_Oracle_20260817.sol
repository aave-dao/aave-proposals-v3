// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets, AaveV3EthereumEModes} from 'aave-address-book/AaveV3Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {AgentHubAgentActivationPayload} from '../helpers/agent-hub/AgentHubAgentActivationPayload.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';

/**
 * @title Onboard_PTsrUSDe22OCT2026_Oracle
 * @author LlamaRisk
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119
 */
contract AaveV3Ethereum_Onboard_PTsrUSDe22OCT2026_Oracle_20260817 is
  AgentHubAgentActivationPayload
{
  /// @dev Protocol guardian, so a misbehaving agent can be disabled without a governance cycle.
  ///      Registration stays governance-only: `registerAgent` and `setAgentAdmin` are `onlyOwner`.
  address public constant AGENT_ADMIN = MiscEthereum.PROTOCOL_GUARDIAN;

  function execute() external {
    AgentHubConfig memory agentHubConfig = AgentHubConfig({
      aclManager: address(AaveV3Ethereum.ACL_MANAGER),
      agentHub: MiscEthereum.AGENT_HUB,
      rangeValidationModule: MiscEthereum.RANGE_VALIDATION_MODULE,
      agentAdmin: AGENT_ADMIN,
      riskOracle: MiscEthereum.LLAMARISK_RISK_ORACLE
    });

    address discountRateAgent = MiscEthereum.LLAMARISK_PT_DISCOUNT_RATE_AGENT;

    address[] memory ptMarkets = new address[](1);
    ptMarkets[0] = AaveV3EthereumAssets.PT_srUSDe_22OCT2026_UNDERLYING;

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

    address eModeAgent = MiscEthereum.LLAMARISK_PT_EMODE_AGENT;

    address[] memory eModeMarkets = new address[](2);
    // The AgentHub represents eMode category ids as address values.
    eModeMarkets[0] = address(
      uint160(AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDC_USDT_USDe)
    );
    eModeMarkets[1] = address(uint160(AaveV3EthereumEModes.sUSDe_PT_srUSDe_22OCT2026__USDe));

    uint256 eModeAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: eModeAgent,
        expirationPeriod: AgentHubConfigs.EMODE_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.EMODE_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.EMODE_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        // The eMode agent executes updates through the Aave ConfigEngine.
        agentContext: abi.encode(AaveV3Ethereum.CONFIG_ENGINE),
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
