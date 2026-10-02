// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Monad} from 'aave-address-book/AaveV3Monad.sol';
import {MiscMonad} from 'aave-address-book/MiscMonad.sol';
import {AgentHubAgentActivationPayload} from '../helpers/agent-hub/AgentHubAgentActivationPayload.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';

/**
 * @dev Addresses not yet in the address book. Names match the address book keys, so each one is
 *      swapped for its `MiscMonad`, `AaveV3MonadAssets` or `AaveV3MonadEModes` entry once it lands.
 */
library MonadLlamaGuard {
  // https://monadscan.com/address/0xa1Cf1e3D3fC743c0fd0e38f631A843372b7169DB
  address internal constant AGENT_HUB = 0xa1Cf1e3D3fC743c0fd0e38f631A843372b7169DB;

  // https://monadscan.com/address/0x863D5B3f24E6b84564432dd20606a82bB1C61dC5
  address internal constant RANGE_VALIDATION_MODULE = 0x863D5B3f24E6b84564432dd20606a82bB1C61dC5;

  // https://monadscan.com/address/0x4b00A38ee9396E952d07F81B26Ed1514e480dCFC
  address internal constant LLAMARISK_RISK_ORACLE = 0x4b00A38ee9396E952d07F81B26Ed1514e480dCFC;

  // https://monadscan.com/address/0x8fDdd4Ab11Ecd6A95F6d67f13166031604624B71
  address internal constant LLAMARISK_RISK_ORACLE_ROUTER =
    0x8fDdd4Ab11Ecd6A95F6d67f13166031604624B71;

  // https://monadscan.com/address/0x9047f3084Dd26d0d8a6b0Ef9Bb8643b01dA726D3
  address internal constant LLAMARISK_PT_DISCOUNT_RATE_AGENT =
    0x9047f3084Dd26d0d8a6b0Ef9Bb8643b01dA726D3;

  // https://monadscan.com/address/0xa89C6f877380af190AFD839c0F9cBF57474162f1
  address internal constant LLAMARISK_PT_EMODE_AGENT = 0xa89C6f877380af190AFD839c0F9cBF57474162f1;

  /// @dev Listed by the PT-AUSD-17DEC2026 onboarding AIP (aave-dao/aave-proposals-v3#1210).
  // https://monadscan.com/address/0x8B562578b2f9Aa8C14cCda3c5d6CBCEaD3B06a57
  address internal constant PT_AUSD_17DEC2026_UNDERLYING =
    0x8B562578b2f9Aa8C14cCda3c5d6CBCEaD3B06a57;

  /// @dev Created by the same onboarding AIP. Assumes no other eMode category is created first.
  uint8 internal constant PT_AUSD_17DEC2026__STABLECOINS = 6;
}

/**
 * @title Onboard_PTAUSD17DEC2026_Oracle
 * @author LlamaRisk
 * - Snapshot: direct-to-AIP
 * - Discussion: https://governance.aave.com/t/arfc-upgrade-pt-risk-oracle-to-protocol-owned-infrastructure-on-cre/25119
 */
contract AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002 is AgentHubAgentActivationPayload {
  /// @dev Protocol guardian, so a misbehaving agent can be disabled without a governance cycle.
  ///      Registration stays governance-only: `registerAgent` and `setAgentAdmin` are `onlyOwner`.
  address public constant AGENT_ADMIN = MiscMonad.PROTOCOL_GUARDIAN;

  function execute() external {
    AgentHubConfig memory agentHubConfig = AgentHubConfig({
      aclManager: address(AaveV3Monad.ACL_MANAGER),
      agentHub: MonadLlamaGuard.AGENT_HUB,
      rangeValidationModule: MonadLlamaGuard.RANGE_VALIDATION_MODULE,
      agentAdmin: AGENT_ADMIN,
      riskOracle: MonadLlamaGuard.LLAMARISK_RISK_ORACLE
    });

    address[] memory ptMarkets = new address[](1);
    ptMarkets[0] = MonadLlamaGuard.PT_AUSD_17DEC2026_UNDERLYING;

    uint256 discountAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: MonadLlamaGuard.LLAMARISK_PT_DISCOUNT_RATE_AGENT,
        expirationPeriod: AgentHubConfigs.DISCOUNT_EXPIRATION_PERIOD,
        minimumDelay: AgentHubConfigs.DISCOUNT_MINIMUM_DELAY,
        updateType: string.concat(AgentHubConfigs.DISCOUNT_UPDATE_TYPE, UPDATE_TYPE_SUFFIX),
        agentContext: bytes(''),
        allowedMarkets: ptMarkets
      })
    );

    address[] memory eModeMarkets = new address[](1);
    // The AgentHub represents eMode category ids as address values.
    eModeMarkets[0] = address(uint160(MonadLlamaGuard.PT_AUSD_17DEC2026__STABLECOINS));

    uint256 eModeAgentId = _registerAgentAndGrantRole(
      agentHubConfig,
      AgentActivationInput({
        agentAddress: MonadLlamaGuard.LLAMARISK_PT_EMODE_AGENT,
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
