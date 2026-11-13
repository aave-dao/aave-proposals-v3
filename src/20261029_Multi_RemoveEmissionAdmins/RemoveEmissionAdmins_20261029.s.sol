// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, PolygonScript, AvalancheScript, OptimismScript, ArbitrumScript, BaseScript, GnosisScript, BNBScript, LineaScript, CeloScript, PlasmaScript, MantleScript, MegaEthScript, XLayerScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Ethereum_RemoveEmissionAdmins_20261029} from './AaveV3Ethereum_RemoveEmissionAdmins_20261029.sol';
import {AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029} from './AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Polygon_RemoveEmissionAdmins_20261029} from './AaveV3Polygon_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Avalanche_RemoveEmissionAdmins_20261029} from './AaveV3Avalanche_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Optimism_RemoveEmissionAdmins_20261029} from './AaveV3Optimism_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Arbitrum_RemoveEmissionAdmins_20261029} from './AaveV3Arbitrum_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Base_RemoveEmissionAdmins_20261029} from './AaveV3Base_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Gnosis_RemoveEmissionAdmins_20261029} from './AaveV3Gnosis_RemoveEmissionAdmins_20261029.sol';
import {AaveV3BNB_RemoveEmissionAdmins_20261029} from './AaveV3BNB_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Linea_RemoveEmissionAdmins_20261029} from './AaveV3Linea_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Celo_RemoveEmissionAdmins_20261029} from './AaveV3Celo_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Plasma_RemoveEmissionAdmins_20261029} from './AaveV3Plasma_RemoveEmissionAdmins_20261029.sol';
import {AaveV3Mantle_RemoveEmissionAdmins_20261029} from './AaveV3Mantle_RemoveEmissionAdmins_20261029.sol';
import {AaveV3MegaEth_RemoveEmissionAdmins_20261029} from './AaveV3MegaEth_RemoveEmissionAdmins_20261029.sol';
import {AaveV3XLayer_RemoveEmissionAdmins_20261029} from './AaveV3XLayer_RemoveEmissionAdmins_20261029.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Ethereum_RemoveEmissionAdmins_20261029).creationCode
    );
    address payload1 = GovV3Helpers.deployDeterministic(
      type(AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029).creationCode
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
 * @dev Deploy Polygon
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployPolygon chain=polygon
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/137/run-latest.json
 */
contract DeployPolygon is PolygonScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Polygon_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployAvalanche chain=avalanche
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/43114/run-latest.json
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Avalanche_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployOptimism chain=optimism
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/10/run-latest.json
 */
contract DeployOptimism is OptimismScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Optimism_RemoveEmissionAdmins_20261029).creationCode
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
 * @dev Deploy Arbitrum
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployArbitrum chain=arbitrum
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/42161/run-latest.json
 */
contract DeployArbitrum is ArbitrumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Arbitrum_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployBase chain=base
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/8453/run-latest.json
 */
contract DeployBase is BaseScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Base_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployGnosis chain=gnosis
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/100/run-latest.json
 */
contract DeployGnosis is GnosisScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Gnosis_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployBNB chain=bnb
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/56/run-latest.json
 */
contract DeployBNB is BNBScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3BNB_RemoveEmissionAdmins_20261029).creationCode
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
 * @dev Deploy Linea
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployLinea chain=linea
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/59144/run-latest.json
 */
contract DeployLinea is LineaScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Linea_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployCelo chain=celo
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/42220/run-latest.json
 */
contract DeployCelo is CeloScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Celo_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployPlasma chain=plasma
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/9745/run-latest.json
 */
contract DeployPlasma is PlasmaScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Plasma_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployMantle chain=mantle
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/5000/run-latest.json
 */
contract DeployMantle is MantleScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3Mantle_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployMegaEth chain=megaeth
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/4326/run-latest.json
 */
contract DeployMegaEth is MegaEthScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3MegaEth_RemoveEmissionAdmins_20261029).creationCode
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
 * deploy-command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:DeployXLayer chain=xlayer
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/RemoveEmissionAdmins_20261029.s.sol/196/run-latest.json
 */
contract DeployXLayer is XLayerScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV3XLayer_RemoveEmissionAdmins_20261029).creationCode
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
 * command: make deploy-ledger contract=src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins_20261029.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](14);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](2);
      actionsEthereum[0] = GovV3Helpers.buildAction(
        type(AaveV3Ethereum_RemoveEmissionAdmins_20261029).creationCode
      );
      actionsEthereum[1] = GovV3Helpers.buildAction(
        type(AaveV3EthereumHorizon_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPolygon = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPolygon[0] = GovV3Helpers.buildAction(
        type(AaveV3Polygon_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[1] = GovV3Helpers.buildPolygonPayload(vm, actionsPolygon);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(
        type(AaveV3Avalanche_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[2] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsOptimism = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsOptimism[0] = GovV3Helpers.buildAction(
        type(AaveV3Optimism_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[3] = GovV3Helpers.buildOptimismPayload(vm, actionsOptimism);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsArbitrum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsArbitrum[0] = GovV3Helpers.buildAction(
        type(AaveV3Arbitrum_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[4] = GovV3Helpers.buildArbitrumPayload(vm, actionsArbitrum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBase = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBase[0] = GovV3Helpers.buildAction(
        type(AaveV3Base_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[5] = GovV3Helpers.buildBasePayload(vm, actionsBase);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsGnosis = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsGnosis[0] = GovV3Helpers.buildAction(
        type(AaveV3Gnosis_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[6] = GovV3Helpers.buildGnosisPayload(vm, actionsGnosis);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBNB = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBNB[0] = GovV3Helpers.buildAction(
        type(AaveV3BNB_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[7] = GovV3Helpers.buildBNBPayload(vm, actionsBNB);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsLinea = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsLinea[0] = GovV3Helpers.buildAction(
        type(AaveV3Linea_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[8] = GovV3Helpers.buildLineaPayload(vm, actionsLinea);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsCelo = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsCelo[0] = GovV3Helpers.buildAction(
        type(AaveV3Celo_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[9] = GovV3Helpers.buildCeloPayload(vm, actionsCelo);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPlasma = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPlasma[0] = GovV3Helpers.buildAction(
        type(AaveV3Plasma_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[10] = GovV3Helpers.buildPlasmaPayload(vm, actionsPlasma);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMantle = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMantle[0] = GovV3Helpers.buildAction(
        type(AaveV3Mantle_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[11] = GovV3Helpers.buildMantlePayload(vm, actionsMantle);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMegaEth = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMegaEth[0] = GovV3Helpers.buildAction(
        type(AaveV3MegaEth_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[12] = GovV3Helpers.buildMegaEthPayload(vm, actionsMegaEth);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsXLayer = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsXLayer[0] = GovV3Helpers.buildAction(
        type(AaveV3XLayer_RemoveEmissionAdmins_20261029).creationCode
      );
      payloads[13] = GovV3Helpers.buildXLayerPayload(vm, actionsXLayer);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261029_Multi_RemoveEmissionAdmins/RemoveEmissionAdmins.md'
      )
    );
  }
}
