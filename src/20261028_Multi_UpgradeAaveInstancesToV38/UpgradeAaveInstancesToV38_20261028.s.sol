// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3InkWhitelabel} from 'aave-address-book/GovernanceV3InkWhitelabel.sol';

import {EthereumScript, PlasmaScript, AvalancheScript, BNBScript, MonadScript, BaseScript, ArbitrumScript, MantleScript, XLayerScript, PolygonScript, LineaScript, OptimismScript, GnosisScript, MegaEthScript, CeloScript, InkScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {Deployments} from './Deployments.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployEthereum chain=mainnet
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](2);
    actions[0] = GovV3Helpers.buildAction(Deployments.MAINNET_CORE);
    actions[1] = GovV3Helpers.buildAction(Deployments.MAINNET_LIDO);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Plasma
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployPlasma chain=plasma
 */
contract DeployPlasma is PlasmaScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.PLASMA);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Avalanche
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployAvalanche chain=avalanche
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.AVALANCHE);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy BNB
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployBNB chain=bnb
 */
contract DeployBNB is BNBScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.BNB);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Monad
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployMonad chain=monad
 */
contract DeployMonad is MonadScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.MONAD);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Base
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployBase chain=base
 */
contract DeployBase is BaseScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.BASE);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Arbitrum
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployArbitrum chain=arbitrum
 */
contract DeployArbitrum is ArbitrumScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.ARBITRUM);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Mantle
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployMantle chain=mantle
 */
contract DeployMantle is MantleScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.MANTLE);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy XLayer
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployXLayer chain=xlayer
 */
contract DeployXLayer is XLayerScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.XLAYER);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Polygon
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployPolygon chain=polygon
 */
contract DeployPolygon is PolygonScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.POLYGON);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Linea
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployLinea chain=linea
 */
contract DeployLinea is LineaScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.LINEA);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Optimism
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployOptimism chain=optimism
 */
contract DeployOptimism is OptimismScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.OPTIMISM);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Gnosis
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployGnosis chain=gnosis
 */
contract DeployGnosis is GnosisScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.GNOSIS);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy MegaEth
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployMegaEth chain=megaeth
 */
contract DeployMegaEth is MegaEthScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.MEGAETH);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Deploy Celo
 * deploy-command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployCelo chain=celo
 */
contract DeployCelo is CeloScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.CELO);

    // register action at payloadsController
    GovV3Helpers.createPayload(actions);
  }
}

/**
 * @dev Ink whitelabel: prints the safe, target and calldata to register the payload at its permissioned payloadsController
 * command: forge script src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:DeployInk --rpc-url ink
 */
contract DeployInk is InkScript {
  function run() external broadcast {
    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(Deployments.INK);

    GovV3Helpers.createPermissionedPayloadCalldata(
      GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER,
      actions
    );
  }
}

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38_20261028.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    // create payloads
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](15);

    // compose actions for validation
    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsEthereum = new IPayloadsControllerCore.ExecutionAction[](2);
      actionsEthereum[0] = GovV3Helpers.buildAction(Deployments.MAINNET_CORE);
      actionsEthereum[1] = GovV3Helpers.buildAction(Deployments.MAINNET_LIDO);
      payloads[0] = GovV3Helpers.buildMainnetPayload(vm, actionsEthereum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPlasma = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPlasma[0] = GovV3Helpers.buildAction(Deployments.PLASMA);
      payloads[1] = GovV3Helpers.buildPlasmaPayload(vm, actionsPlasma);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsAvalanche = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsAvalanche[0] = GovV3Helpers.buildAction(Deployments.AVALANCHE);
      payloads[2] = GovV3Helpers.buildAvalanchePayload(vm, actionsAvalanche);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBNB = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBNB[0] = GovV3Helpers.buildAction(Deployments.BNB);
      payloads[3] = GovV3Helpers.buildBNBPayload(vm, actionsBNB);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMonad = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMonad[0] = GovV3Helpers.buildAction(Deployments.MONAD);
      payloads[4] = GovV3Helpers.buildMonadPayload(vm, actionsMonad);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsBase = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsBase[0] = GovV3Helpers.buildAction(Deployments.BASE);
      payloads[5] = GovV3Helpers.buildBasePayload(vm, actionsBase);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsArbitrum = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsArbitrum[0] = GovV3Helpers.buildAction(Deployments.ARBITRUM);
      payloads[6] = GovV3Helpers.buildArbitrumPayload(vm, actionsArbitrum);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMantle = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMantle[0] = GovV3Helpers.buildAction(Deployments.MANTLE);
      payloads[7] = GovV3Helpers.buildMantlePayload(vm, actionsMantle);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsXLayer = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsXLayer[0] = GovV3Helpers.buildAction(Deployments.XLAYER);
      payloads[8] = GovV3Helpers.buildXLayerPayload(vm, actionsXLayer);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsPolygon = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsPolygon[0] = GovV3Helpers.buildAction(Deployments.POLYGON);
      payloads[9] = GovV3Helpers.buildPolygonPayload(vm, actionsPolygon);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsLinea = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsLinea[0] = GovV3Helpers.buildAction(Deployments.LINEA);
      payloads[10] = GovV3Helpers.buildLineaPayload(vm, actionsLinea);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsOptimism = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsOptimism[0] = GovV3Helpers.buildAction(Deployments.OPTIMISM);
      payloads[11] = GovV3Helpers.buildOptimismPayload(vm, actionsOptimism);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsGnosis = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsGnosis[0] = GovV3Helpers.buildAction(Deployments.GNOSIS);
      payloads[12] = GovV3Helpers.buildGnosisPayload(vm, actionsGnosis);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsMegaEth = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsMegaEth[0] = GovV3Helpers.buildAction(Deployments.MEGAETH);
      payloads[13] = GovV3Helpers.buildMegaEthPayload(vm, actionsMegaEth);
    }

    {
      IPayloadsControllerCore.ExecutionAction[]
        memory actionsCelo = new IPayloadsControllerCore.ExecutionAction[](1);
      actionsCelo[0] = GovV3Helpers.buildAction(Deployments.CELO);
      payloads[14] = GovV3Helpers.buildCeloPayload(vm, actionsCelo);
    }

    // create proposal
    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261028_Multi_UpgradeAaveInstancesToV38/UpgradeAaveInstancesToV38.md'
      )
    );
  }
}
