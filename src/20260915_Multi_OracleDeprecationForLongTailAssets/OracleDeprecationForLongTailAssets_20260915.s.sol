// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, PolygonScript, ArbitrumScript, AvalancheScript, CeloScript, OptimismScript, ScrollScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Celo_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Celo_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915} from './AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915.sol';
import {AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915).creationCode
    );
    address payload1 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915).creationCode
    );
    address payload2 = GovV3Helpers.deployDeterministic(
      type(AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915).creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](3);
    actions[0] = GovV3Helpers.buildAction(payload0);
    actions[1] = GovV3Helpers.buildAction(payload1);
    actions[2] = GovV3Helpers.buildAction(payload2);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Polygon
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployPolygon chain=polygon
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/137/run-latest.json
 */
contract DeployPolygon is PolygonScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915).creationCode
    );
    address payload1 = GovV3Helpers.deployDeterministic(
      type(AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915).creationCode
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
 * @dev Deploy Arbitrum
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployArbitrum chain=arbitrum
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/42161/run-latest.json
 */
contract DeployArbitrum is ArbitrumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployAvalanche chain=avalanche
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/43114/run-latest.json
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915).creationCode
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
 * @dev Deploy Celo
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployCelo chain=celo
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/42220/run-latest.json
 */
contract DeployCelo is CeloScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Celo_OracleDeprecationForLongTailAssets_20260915).creationCode
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
 * @dev Deploy Optimism
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployOptimism chain=optimism
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/10/run-latest.json
 */
contract DeployOptimism is OptimismScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915).creationCode
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
 * @dev Deploy Scroll
 * deploy-command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:DeployScroll chain=scroll
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/OracleDeprecationForLongTailAssets_20260915.s.sol/534352/run-latest.json
 */
contract DeployScroll is ScrollScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915).creationCode
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
 * command: make deploy-ledger contract=src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets_20260915.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](7);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](3);
      actionsEthereum[0] = GovV3Helpers.buildAction(
        type(AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      actionsEthereum[1] = GovV3Helpers.buildAction(
        type(AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      actionsEthereum[2] = GovV3Helpers.buildAction(
        type(AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPolygon = new IPayloadsControllerCore.ExecutionAction[](2);
      actionsPolygon[0] = GovV3Helpers.buildAction(
        type(AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      actionsPolygon[1] = GovV3Helpers.buildAction(
        type(AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[1] = GovV3Helpers.buildPolygonPayload(vm, actionsPolygon);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsArbitrum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsArbitrum[0] = GovV3Helpers.buildAction(
        type(AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[2] = GovV3Helpers.buildArbitrumPayload(vm, actionsArbitrum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(
        type(AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[3] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsCelo = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsCelo[0] = GovV3Helpers.buildAction(
        type(AaveV3Celo_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[4] = GovV3Helpers.buildCeloPayload(vm, actionsCelo);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsOptimism = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsOptimism[0] = GovV3Helpers.buildAction(
        type(AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[5] = GovV3Helpers.buildOptimismPayload(vm, actionsOptimism);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsScroll = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsScroll[0] = GovV3Helpers.buildAction(
        type(AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915).creationCode
      );
      payloads[6] = GovV3Helpers.buildScrollPayload(vm, actionsScroll);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20260915_Multi_OracleDeprecationForLongTailAssets/OracleDeprecationForLongTailAssets.md'
      )
    );
  }
}
