// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Ethereum_MainnetGSMMigration_20261022} from './AaveV3Ethereum_MainnetGSMMigration_20261022.sol';
import {AaveV4Ethereum_MainnetGSMMigration_20261022} from './AaveV4Ethereum_MainnetGSMMigration_20261022.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261022_Multi_MainnetGSMMigration/MainnetGSMMigration_20261022.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/MainnetGSMMigration_20261022.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    // the V4 payload raises the TokenizationSpoke add caps the V3 payload relies on, so it executes first
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV4Ethereum_MainnetGSMMigration_20261022).creationCode
    );
    address payload1 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_MainnetGSMMigration_20261022).creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](2);
    actions[0] = GovV3Helpers.buildAction(payload0);
    actions[1] = GovV3Helpers.buildAction(payload1);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20261022_Multi_MainnetGSMMigration/MainnetGSMMigration_20261022.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](2);
      actionsEthereum[0] = GovV3Helpers.buildAction(
        type(AaveV4Ethereum_MainnetGSMMigration_20261022).creationCode
      );
      actionsEthereum[1] = GovV3Helpers.buildAction(
        type(AaveV3Ethereum_MainnetGSMMigration_20261022).creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(vm, 'src/20261022_Multi_MainnetGSMMigration/MainnetGSMMigration.md')
    );
  }
}
