// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers, IPayloadsControllerCore} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4EthereumSentora} from 'aave-address-book/AaveV4EthereumSentora.sol';

import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV4EthereumSentora_SentoraMarketActivation_20261009} from './AaveV4EthereumSentora_SentoraMarketActivation_20261009.sol';

/**
 * @dev Deploy Ethereum
 * deploy-command: make deploy-ledger contract=src/20261009_AaveV4EthereumSentora_SentoraMarketActivation/SentoraMarketActivation_20261009.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/SentoraMarketActivation_20261009.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    // deploy payloads
    address payload0 = GovV3Helpers.deployDeterministic(
      type(AaveV4EthereumSentora_SentoraMarketActivation_20261009).creationCode
    );

    // compose action
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload0);

    // register action at the Sentora permissioned payloads controller (created by the Sentora payloads manager)
    GovV3Helpers.createPermissionedPayloadCalldata(
      IPayloadsControllerCore(AaveV4EthereumSentora.PERMISSIONED_PAYLOADS_CONTROLLER),
      actions
    );
  }
}
