// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, AvalancheScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV4Avalanche_OnboardUSATCoreHub_20261028} from './AaveV4Avalanche_OnboardUSATCoreHub_20261028.sol';

/**
 * @dev Deploy Avalanche
 * deploy-command: make deploy-ledger contract=src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/OnboardUSATCoreHub_20261028.s.sol:DeployAvalanche chain=avalanche
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OnboardUSATCoreHub_20261028.s.sol/43114/run-latest.json
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV4Avalanche_OnboardUSATCoreHub_20261028).creationCode
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
 * command: make deploy-ledger contract=src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/OnboardUSATCoreHub_20261028.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(
        type(AaveV4Avalanche_OnboardUSATCoreHub_20261028).creationCode
      );
      payloads[0] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/OnboardUSATCoreHub.md'
      )
    );
  }
}
