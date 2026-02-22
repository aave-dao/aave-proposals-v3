// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, AvalancheScript, ArbitrumScript, BaseScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130} from './AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol';
import {AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130} from './AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol';
import {AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130} from './AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol';
import {AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130} from './AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
        .creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload0);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Avalanche
 * deploy-command: make deploy-ledger contract=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol:DeployAvalanche chain=avalanche
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol/43114/run-latest.json
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
        .creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload0);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Arbitrum
 * deploy-command: make deploy-ledger contract=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol:DeployArbitrum chain=arbitrum
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol/42161/run-latest.json
 */
contract DeployArbitrum is ArbitrumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
        .creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload0);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Base
 * deploy-command: make deploy-ledger contract=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol:DeployBase chain=base
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol/8453/run-latest.json
 */
contract DeployBase is BaseScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130).creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload0);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](4);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsEthereum[0] = GovV3Helpers.buildAction(
        type(AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
          .creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(
        type(AaveV3Avalanche_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
          .creationCode
      );
      payloads[1] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsArbitrum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsArbitrum[0] = GovV3Helpers.buildAction(
        type(AaveV3Arbitrum_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
          .creationCode
      );
      payloads[2] = GovV3Helpers.buildArbitrumPayload(vm, actionsArbitrum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBase = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBase[0] = GovV3Helpers.buildAction(
        type(AaveV3Base_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130)
          .creationCode
      );
      payloads[3] = GovV3Helpers.buildBasePayload(vm, actionsBase);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks.md'
      )
    );
  }
}
