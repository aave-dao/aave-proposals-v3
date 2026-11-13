// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore, PayloadsControllerUtils} from 'aave-helpers/src/GovV3Helpers.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript, PolygonScript, AvalancheScript, BNBScript, MonadScript, GnosisScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {MaintenanceReplaceLayerZeroOnADIAddresses as Addresses} from './MaintenanceReplaceLayerZeroOnADIAddresses.sol';

/// @dev the payloads are already deployed, so each chain only registers its action
library ReplaceLayerZeroActions {
  function build(
    address payload
  ) internal pure returns (IPayloadsControllerCore.ExecutionAction[] memory actions) {
    actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload);
  }
}

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:DeployEthereum chain=mainnet
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    GovV3Helpers.createPayload(ReplaceLayerZeroActions.build(Addresses.ETHEREUM_PAYLOAD));
  }
}

/**
 * @dev Deploy Polygon
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:DeployPolygon chain=polygon
 */
contract DeployPolygon is PolygonScript {
  function run() external broadcast {
    GovV3Helpers.createPayload(ReplaceLayerZeroActions.build(Addresses.POLYGON_PAYLOAD));
  }
}

/**
 * @dev Deploy Avalanche
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:DeployAvalanche chain=avalanche
 */
contract DeployAvalanche is AvalancheScript {
  function run() external broadcast {
    GovV3Helpers.createPayload(ReplaceLayerZeroActions.build(Addresses.AVALANCHE_PAYLOAD));
  }
}

/**
 * @dev Deploy BNB
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:DeployBNB chain=bnb
 */
contract DeployBNB is BNBScript {
  function run() external broadcast {
    GovV3Helpers.createPayload(ReplaceLayerZeroActions.build(Addresses.BNB_PAYLOAD));
  }
}

/**
 * @dev Deploy Monad
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:DeployMonad chain=monad
 */
contract DeployMonad is MonadScript {
  function run() external broadcast {
    GovV3Helpers.createPayload(ReplaceLayerZeroActions.build(Addresses.MONAD_PAYLOAD));
  }
}

/**
 * @dev Deploy Gnosis
 * deploy-command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:DeployGnosis chain=gnosis
 */
contract DeployGnosis is GnosisScript {
  function run() external broadcast {
    GovV3Helpers.createPayload(ReplaceLayerZeroActions.build(Addresses.GNOSIS_PAYLOAD));
  }
}

/**
 * @dev Create Proposal
 * command: make deploy-ledger contract=src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI_20261111.s.sol:CreateProposal chain=mainnet
 */
contract CreateProposal is EthereumScript {
  function run() external {
    PayloadsControllerUtils.Payload[] memory payloads = new PayloadsControllerUtils.Payload[](6);

    payloads[0] = GovV3Helpers.buildMainnetPayload(
      vm,
      ReplaceLayerZeroActions.build(Addresses.ETHEREUM_PAYLOAD)
    );
    payloads[1] = GovV3Helpers.buildPolygonPayload(
      vm,
      ReplaceLayerZeroActions.build(Addresses.POLYGON_PAYLOAD)
    );
    payloads[2] = GovV3Helpers.buildAvalanchePayload(
      vm,
      ReplaceLayerZeroActions.build(Addresses.AVALANCHE_PAYLOAD)
    );
    payloads[3] = GovV3Helpers.buildBNBPayload(
      vm,
      ReplaceLayerZeroActions.build(Addresses.BNB_PAYLOAD)
    );
    payloads[4] = GovV3Helpers.buildMonadPayload(
      vm,
      ReplaceLayerZeroActions.build(Addresses.MONAD_PAYLOAD)
    );
    payloads[5] = GovV3Helpers.buildGnosisPayload(
      vm,
      ReplaceLayerZeroActions.build(Addresses.GNOSIS_PAYLOAD)
    );

    vm.startBroadcast();
    GovV3Helpers.createProposal(
      vm,
      payloads,
      GovernanceV3Ethereum.VOTING_PORTAL_ETH_AVAX,
      GovV3Helpers.ipfsHashFile(
        vm,
        'src/20261111_Multi_MaintenanceReplaceLayerZeroOnADI/MaintenanceReplaceLayerZeroOnADI.md'
      )
    );
  }
}
