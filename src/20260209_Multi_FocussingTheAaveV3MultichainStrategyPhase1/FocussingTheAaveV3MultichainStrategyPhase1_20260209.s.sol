// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3ZkSync} from 'aave-address-book/GovernanceV3ZkSync.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {EthereumScript, MetisScript, SoneiumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209} from './AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol';
import {AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209} from './AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209.sol';

/**
 * @dev Deploy Metis
 * deploy-command: make deploy-ledger contract=src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/FocussingTheAaveV3MultichainStrategyPhase1_20260209.s.sol:DeployMetis chain=metis
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/FocussingTheAaveV3MultichainStrategyPhase1_20260209.s.sol/1088/run-latest.json
 */
contract DeployMetis is MetisScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209).creationCode
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
 * @dev Deploy Soneium
 * deploy-command: make deploy-ledger contract=src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/FocussingTheAaveV3MultichainStrategyPhase1_20260209.s.sol:DeploySoneium chain=soneium
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/FocussingTheAaveV3MultichainStrategyPhase1_20260209.s.sol/1868/run-latest.json
 */
contract DeploySoneium is SoneiumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209).creationCode
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
 * command: make deploy-ledger contract=src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/FocussingTheAaveV3MultichainStrategyPhase1_20260209.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](3);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMetis = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMetis[0] = GovV3Helpers.buildAction(
        type(AaveV3Metis_FocussingTheAaveV3MultichainStrategyPhase1_20260209).creationCode
      );
      payloads[0] = GovV3Helpers.buildMetisPayload(vm, actionsMetis);
    }

    {
      payloads[1] = PayloadsControllerUtils.Payload({
        chain: ChainIds.ZKSYNC,
        accessLevel: PayloadsControllerUtils.AccessControl.Level_1,
        payloadsController: address(GovernanceV3ZkSync.PAYLOADS_CONTROLLER),
        payloadId: 36
      }); // Contract deployment: https://explorer.zksync.io/tx/0xf2dbcadc1ea2f6b3e9ed103ffb9e214508a182932b11b690017e3cde0c6ef78b
      // Playload registration: https://explorer.zksync.io/tx/0xbcc13d6fa52784301cdf962565c6d2e368473978f943430345966f31602cfff7
      // Commit used for creation: f41f13a8c
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsSoneium = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsSoneium[0] = GovV3Helpers.buildAction(
        type(AaveV3Soneium_FocussingTheAaveV3MultichainStrategyPhase1_20260209).creationCode
      );
      payloads[2] = GovV3Helpers.buildSoneiumPayload(vm, actionsSoneium);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20260209_Multi_FocussingTheAaveV3MultichainStrategyPhase1/FocussingTheAaveV3MultichainStrategyPhase1.md'
      )
    );
  }
}
