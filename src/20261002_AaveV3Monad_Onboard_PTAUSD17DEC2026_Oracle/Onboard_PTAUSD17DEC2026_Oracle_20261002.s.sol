// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, MonadScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002} from './AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002.sol';

/**
 * @dev Deploy Monad
 * deploy-command: make deploy-ledger contract=src/20261002_AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle/Onboard_PTAUSD17DEC2026_Oracle_20261002.s.sol:DeployMonad chain=monad
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/Onboard_PTAUSD17DEC2026_Oracle_20261002.s.sol/143/run-latest.json
 */
contract DeployMonad is MonadScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002).creationCode
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
 * command: make deploy-ledger contract=src/20261002_AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle/Onboard_PTAUSD17DEC2026_Oracle_20261002.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMonad = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMonad[0] = GovV3Helpers.buildAction(
        type(AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002).creationCode
      );
      payloads[0] = GovV3Helpers.buildMonadPayload(vm, actionsMonad);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261002_AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle/Onboard_PTAUSD17DEC2026_Oracle.md'
      )
    );
  }
}
