// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, PlasmaScript, MantleScript, MonadScript, AvalancheScript, XLayerScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111.sol';
import {AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111.sol';
import {AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111.sol';
import {AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111.sol';
import {AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111.sol';
import {AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/EthenaEModeConsolidationOnAaveV3_20261111.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:DeployPlasma chain=plasma
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/EthenaEModeConsolidationOnAaveV3_20261111.s.sol/9745/run-latest.json
 */
contract DeployPlasma is PlasmaScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
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
 * @dev Deploy Mantle
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:DeployMantle chain=mantle
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/EthenaEModeConsolidationOnAaveV3_20261111.s.sol/5000/run-latest.json
 */
contract DeployMantle is MantleScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:DeployMonad chain=monad
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/EthenaEModeConsolidationOnAaveV3_20261111.s.sol/143/run-latest.json
 */
contract DeployMonad is MonadScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:DeployAvalanche chain=avalanche
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/EthenaEModeConsolidationOnAaveV3_20261111.s.sol/43114/run-latest.json
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
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
 * @dev Deploy XLayer
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:DeployXLayer chain=xlayer
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/EthenaEModeConsolidationOnAaveV3_20261111.s.sol/196/run-latest.json
 */
contract DeployXLayer is XLayerScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
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
 * command: make deploy-ledger contract=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3_20261111.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](6);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsEthereum[0] = GovV3Helpers.buildAction(
        type(AaveV3Ethereum_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPlasma = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPlasma[0] = GovV3Helpers.buildAction(
        type(AaveV3Plasma_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
      );
      payloads[1] = GovV3Helpers.buildPlasmaPayload(vm, actionsPlasma);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMantle = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMantle[0] = GovV3Helpers.buildAction(
        type(AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
      );
      payloads[2] = GovV3Helpers.buildMantlePayload(vm, actionsMantle);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMonad = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMonad[0] = GovV3Helpers.buildAction(
        type(AaveV3Monad_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
      );
      payloads[3] = GovV3Helpers.buildMonadPayload(vm, actionsMonad);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(
        type(AaveV3Avalanche_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
      );
      payloads[4] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsXLayer = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsXLayer[0] = GovV3Helpers.buildAction(
        type(AaveV3XLayer_EthenaEModeConsolidationOnAaveV3_20261111).creationCode
      );
      payloads[5] = GovV3Helpers.buildXLayerPayload(vm, actionsXLayer);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/EthenaEModeConsolidationOnAaveV3.md'
      )
    );
  }
}
