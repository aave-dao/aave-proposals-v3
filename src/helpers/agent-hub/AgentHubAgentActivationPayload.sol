// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IAgentHub, IAgentConfigurator} from '../../interfaces/IAgentHub.sol';
import {IRangeValidationModule} from '../../interfaces/IRangeValidationModule.sol';

abstract contract AgentHubAgentActivationPayload is IProposalGenericExecutor {
  /// @dev No suffix is needed while each RiskOracle is dedicated to a single LlamaGuard stack.
  string public constant UPDATE_TYPE_SUFFIX = '';

  struct AgentHubConfig {
    address aclManager;
    address agentHub;
    address rangeValidationModule;
    address agentAdmin;
    address riskOracle;
  }

  struct AgentActivationInput {
    address agentAddress;
    uint256 expirationPeriod;
    uint256 minimumDelay;
    string updateType;
    bytes agentContext;
    address[] allowedMarkets;
  }

  function _registerAgentAndGrantRole(
    AgentHubConfig memory config,
    AgentActivationInput memory input
  ) internal returns (uint256 agentId) {
    IACLManager(config.aclManager).addRiskAdmin(input.agentAddress);

    return
      IAgentHub(config.agentHub).registerAgent(
        IAgentConfigurator.AgentRegistrationInput({
          admin: config.agentAdmin,
          riskOracle: config.riskOracle,
          isAgentEnabled: true,
          isAgentPermissioned: false,
          isMarketsFromAgentEnabled: false,
          agentAddress: input.agentAddress,
          expirationPeriod: input.expirationPeriod,
          minimumDelay: input.minimumDelay,
          updateType: input.updateType,
          agentContext: input.agentContext,
          allowedMarkets: input.allowedMarkets,
          restrictedMarkets: new address[](0),
          permissionedSenders: new address[](0)
        })
      );
  }

  function _setDefaultRange(
    AgentHubConfig memory config,
    uint256 agentId,
    string memory updateType,
    uint120 bound
  ) internal {
    IRangeValidationModule(config.rangeValidationModule).setDefaultRangeConfig(
      config.agentHub,
      agentId,
      updateType,
      IRangeValidationModule.RangeConfig({
        maxIncrease: bound,
        maxDecrease: bound,
        isIncreaseRelative: false,
        isDecreaseRelative: false
      })
    );
  }
}
