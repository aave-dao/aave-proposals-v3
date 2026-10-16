// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, BaseScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV4Base_OnboardSPCXEquitiesHub_20261016} from './AaveV4Base_OnboardSPCXEquitiesHub_20261016.sol';

/**
 * @dev Deploy Base
 * deploy-command: make deploy-ledger contract=src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/OnboardSPCXEquitiesHub_20261016.s.sol:DeployBase chain=base
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OnboardSPCXEquitiesHub_20261016.s.sol/8453/run-latest.json
 */
contract DeployBase is BaseScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV4Base_OnboardSPCXEquitiesHub_20261016).creationCode
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
 * command: make deploy-ledger contract=src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/OnboardSPCXEquitiesHub_20261016.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBase = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBase[0] = GovV3Helpers.buildAction(
        type(AaveV4Base_OnboardSPCXEquitiesHub_20261016).creationCode
      );
      payloads[0] = GovV3Helpers.buildBasePayload(vm, actionsBase);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261016_AaveV4Base_OnboardSPCXEquitiesHub/OnboardSPCXEquitiesHub.md'
      )
    );
  }
}
