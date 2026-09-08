// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, ArbitrumScript, PlasmaScript, BaseScript, PolygonScript, AvalancheScript, OptimismScript, GnosisScript, BNBScript, MegaEthScript, SonicScript, ScrollScript, MetisScript, SoneiumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826} from './AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826.sol';
import {AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Arbitrum_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Arbitrum_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Base_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Base_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Avalanche_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Avalanche_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Optimism_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Optimism_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Gnosis_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Gnosis_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3MegaEth_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3MegaEth_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';
import {AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
    );
    address payload1 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826).creationCode
    );
    address payload2 = GovV3Helpers.deployDeterministic(
      type(AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
    );

    // each payload is registered independently (execution is order-independent); the core
    // payload is split in two so each execution stays within the payload gas ceiling
    IPayloadsControllerCore.ExecutionAction[]
      memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](1);
    actionsEthereum[0] = GovV3Helpers.buildAction(payload0);
    GovV3Helpers.createPayload(actionsEthereum);

    IPayloadsControllerCore.ExecutionAction[]
      memory actionsEthereumPart2 = new IPayloadsControllerCore.ExecutionAction[](1);
    actionsEthereumPart2[0] = GovV3Helpers.buildAction(payload1);
    GovV3Helpers.createPayload(actionsEthereumPart2);

    IPayloadsControllerCore.ExecutionAction[]
      memory actionsEthereumLido = new IPayloadsControllerCore.ExecutionAction[](1);
    actionsEthereumLido[0] = GovV3Helpers.buildAction(payload2);
    GovV3Helpers.createPayload(actionsEthereumLido);
  }
}

/**
 * @dev Deploy Arbitrum
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployArbitrum chain=arbitrum
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/42161/run-latest.json
 */
contract DeployArbitrum is ArbitrumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Arbitrum_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployPlasma chain=plasma
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/9745/run-latest.json
 */
contract DeployPlasma is PlasmaScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployBase chain=base
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/8453/run-latest.json
 */
contract DeployBase is BaseScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Base_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * @dev Deploy Polygon
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployPolygon chain=polygon
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/137/run-latest.json
 */
contract DeployPolygon is PolygonScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployAvalanche chain=avalanche
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/43114/run-latest.json
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Avalanche_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployOptimism chain=optimism
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/10/run-latest.json
 */
contract DeployOptimism is OptimismScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Optimism_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * @dev Deploy Gnosis
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployGnosis chain=gnosis
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/100/run-latest.json
 */
contract DeployGnosis is GnosisScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Gnosis_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * @dev Deploy BNB
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployBNB chain=bnb
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/56/run-latest.json
 */
contract DeployBNB is BNBScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * @dev Deploy MegaEth
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployMegaEth chain=megaeth
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/4326/run-latest.json
 */
contract DeployMegaEth is MegaEthScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3MegaEth_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * @dev Deploy Sonic
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeploySonic chain=sonic
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/146/run-latest.json
 */
contract DeploySonic is SonicScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployScroll chain=scroll
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/534352/run-latest.json
 */
contract DeployScroll is ScrollScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * @dev Deploy Metis
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeployMetis chain=metis
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/1088/run-latest.json
 */
contract DeployMetis is MetisScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:DeploySoneium chain=soneium
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol/1868/run-latest.json
 */
contract DeploySoneium is SoneiumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
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
 * command: make deploy-ledger contract=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3_20260826.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](17);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsEthereum[0] = GovV3Helpers.buildAction(
        type(AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereumPart2 = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsEthereumPart2[0] = GovV3Helpers.buildAction(
        type(AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3Part2_20260826).creationCode
      );
      payloads[1] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereumPart2);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereumLido = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsEthereumLido[0] = GovV3Helpers.buildAction(
        type(AaveV3EthereumLido_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[2] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereumLido);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsArbitrum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsArbitrum[0] = GovV3Helpers.buildAction(
        type(AaveV3Arbitrum_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[3] = GovV3Helpers.buildArbitrumPayload(vm, actionsArbitrum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPlasma = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPlasma[0] = GovV3Helpers.buildAction(
        type(AaveV3Plasma_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[4] = GovV3Helpers.buildPlasmaPayload(vm, actionsPlasma);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBase = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBase[0] = GovV3Helpers.buildAction(
        type(AaveV3Base_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[5] = GovV3Helpers.buildBasePayload(vm, actionsBase);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPolygon = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPolygon[0] = GovV3Helpers.buildAction(
        type(AaveV3Polygon_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[6] = GovV3Helpers.buildPolygonPayload(vm, actionsPolygon);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(
        type(AaveV3Avalanche_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[7] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsOptimism = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsOptimism[0] = GovV3Helpers.buildAction(
        type(AaveV3Optimism_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[8] = GovV3Helpers.buildOptimismPayload(vm, actionsOptimism);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsGnosis = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsGnosis[0] = GovV3Helpers.buildAction(
        type(AaveV3Gnosis_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[9] = GovV3Helpers.buildGnosisPayload(vm, actionsGnosis);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBNB = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBNB[0] = GovV3Helpers.buildAction(
        type(AaveV3BNB_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[10] = GovV3Helpers.buildBNBPayload(vm, actionsBNB);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMegaEth = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMegaEth[0] = GovV3Helpers.buildAction(
        type(AaveV3MegaEth_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[11] = GovV3Helpers.buildMegaEthPayload(vm, actionsMegaEth);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsSonic = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsSonic[0] = GovV3Helpers.buildAction(
        type(AaveV3Sonic_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[12] = GovV3Helpers.buildSonicPayload(vm, actionsSonic);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsScroll = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsScroll[0] = GovV3Helpers.buildAction(
        type(AaveV3Scroll_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[13] = GovV3Helpers.buildScrollPayload(vm, actionsScroll);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsZkSync = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsZkSync[0] = GovV3Helpers.buildActionZkSync(
        vm,
        'AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826'
      );
      payloads[14] = GovV3Helpers.buildZkSyncPayload(vm, actionsZkSync);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMetis = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMetis[0] = GovV3Helpers.buildAction(
        type(AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[15] = GovV3Helpers.buildMetisPayload(vm, actionsMetis);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsSoneium = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsSoneium[0] = GovV3Helpers.buildAction(
        type(AaveV3Soneium_LowAdoptionAssetDeprecationOnAaveV3_20260826).creationCode
      );
      payloads[16] = GovV3Helpers.buildSoneiumPayload(vm, actionsSoneium);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/LowAdoptionAssetDeprecationOnAaveV3.md'
      )
    );
  }
}
