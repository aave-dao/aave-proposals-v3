// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

address constant PAYLOAD = 0x648E4aEc794213F42b5E839Ab409f7f14cb399DB;

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261118_AaveV3Ethereum_TempoADIPathActivation/TempoADIPathActivation_20261118.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/TempoADIPathActivation_20261118.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(PAYLOAD);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20261118_AaveV3Ethereum_TempoADIPathActivation/TempoADIPathActivation_20261118.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsEthereum[0] = GovV3Helpers.buildAction(PAYLOAD);
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      // TODO(tempo): add TempoADIPathActivation.md from the governance forum post
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261118_AaveV3Ethereum_TempoADIPathActivation/TempoADIPathActivation.md'
      )
    );
  }
}
