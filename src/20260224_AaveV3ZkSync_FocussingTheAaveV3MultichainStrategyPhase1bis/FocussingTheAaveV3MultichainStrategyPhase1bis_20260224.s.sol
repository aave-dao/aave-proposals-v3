// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20260224_AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis/FocussingTheAaveV3MultichainStrategyPhase1bis_20260224.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](1);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsZkSync = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsZkSync[0] = GovV3Helpers.buildActionZkSync(
        vm,
        'AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis_20260224'
      );
      payloads[0] = GovV3Helpers.buildZkSyncPayload(vm, actionsZkSync);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20260224_AaveV3ZkSync_FocussingTheAaveV3MultichainStrategyPhase1bis/FocussingTheAaveV3MultichainStrategyPhase1bis.md'
      )
    );
  }
}
