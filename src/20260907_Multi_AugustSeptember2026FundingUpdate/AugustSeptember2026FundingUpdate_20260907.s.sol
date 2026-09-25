// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, BaseScript, MonadScript, PlasmaScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907.sol';
import {AaveV3Base_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Base_AugustSeptember2026FundingUpdate_20260907.sol';
import {AaveV3Monad_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Monad_AugustSeptember2026FundingUpdate_20260907.sol';
import {AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20260907_Multi_AugustSeptember2026FundingUpdate/AugustSeptember2026FundingUpdate_20260907.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/AugustSeptember2026FundingUpdate_20260907.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260907_Multi_AugustSeptember2026FundingUpdate/AugustSeptember2026FundingUpdate_20260907.s.sol:DeployBase chain=base
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/AugustSeptember2026FundingUpdate_20260907.s.sol/8453/run-latest.json
 */
contract DeployBase is BaseScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Base_AugustSeptember2026FundingUpdate_20260907).creationCode
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
 * @dev Deploy Monad
 * deploy-command: make deploy-ledger contract=src/20260907_Multi_AugustSeptember2026FundingUpdate/AugustSeptember2026FundingUpdate_20260907.s.sol:DeployMonad chain=monad
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/AugustSeptember2026FundingUpdate_20260907.s.sol/143/run-latest.json
 */
contract DeployMonad is MonadScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Monad_AugustSeptember2026FundingUpdate_20260907).creationCode
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
 * @dev Deploy Plasma
 * deploy-command: make deploy-ledger contract=src/20260907_Multi_AugustSeptember2026FundingUpdate/AugustSeptember2026FundingUpdate_20260907.s.sol:DeployPlasma chain=plasma
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/AugustSeptember2026FundingUpdate_20260907.s.sol/9745/run-latest.json
 */
contract DeployPlasma is PlasmaScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907).creationCode
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
 * command: make deploy-ledger contract=src/20260907_Multi_AugustSeptember2026FundingUpdate/AugustSeptember2026FundingUpdate_20260907.s.sol:CreateProposal chain=mainnet
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
        type(AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907).creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBase = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBase[0] = GovV3Helpers.buildAction(
        type(AaveV3Base_AugustSeptember2026FundingUpdate_20260907).creationCode
      );
      payloads[1] = GovV3Helpers.buildBasePayload(vm, actionsBase);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMonad = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMonad[0] = GovV3Helpers.buildAction(
        type(AaveV3Monad_AugustSeptember2026FundingUpdate_20260907).creationCode
      );
      payloads[2] = GovV3Helpers.buildMonadPayload(vm, actionsMonad);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPlasma = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPlasma[0] = GovV3Helpers.buildAction(
        type(AaveV3Plasma_AugustSeptember2026FundingUpdate_20260907).creationCode
      );
      payloads[3] = GovV3Helpers.buildPlasmaPayload(vm, actionsPlasma);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20260907_Multi_AugustSeptember2026FundingUpdate/AugustSeptember2026FundingUpdate.md'
      )
    );
  }
}
