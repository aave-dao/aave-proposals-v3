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
      payloads[0] = PayloadsControllerUtils.Payload({
        chain: ChainIds.ZKSYNC,
        accessLevel: PayloadsControllerUtils.AccessControl.Level_1,
        payloadsController: address(GovernanceV3ZkSync.PAYLOADS_CONTROLLER),
        payloadId: 37
      }); // Contract deployment: https://explorer.zksync.io/tx/0x546c801748682a213eae35ff708ed37d8c02ebe06af91da30800da7b5ae1b7fb
      // Playload registration: https://explorer.zksync.io/tx/0xfb9dc7d8307cf7a45b916107f0471488d869bdf2760eb0fbcc061b499f46bd4a
      // Commit used for creation: 0461421a689
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
