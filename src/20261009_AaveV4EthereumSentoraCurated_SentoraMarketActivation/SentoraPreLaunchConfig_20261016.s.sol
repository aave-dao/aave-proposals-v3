// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from 'forge-std/console2.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';

import {EthereumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016} from './AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016.sol';
import {SentoraPreLaunchCouncilCalls} from './SentoraPreLaunchCouncilCalls.sol';

/**
 * @dev Deploy Ethereum, then print the V4 Security Council Safe transactions that execute it
 * deploy-command: make deploy-ledger contract=src/20261009_AaveV4EthereumSentoraCurated_SentoraMarketActivation/SentoraPreLaunchConfig_20261016.s.sol:DeployEthereum chain=mainnet
 * verify-command: FOUNDRY_PROFILE=deploy npx catapulta-verify -b broadcast/SentoraPreLaunchConfig_20261016.s.sol/1/run-latest.json
 */
contract DeployEthereum is EthereumScript {
  function run() external broadcast {
    address payload = GovV3Helpers.deployDeterministic(
      type(AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016).creationCode
    );

    console2.log('payload: ', payload);
    console2.log('safe: ', MiscEthereum.V4_SECURITY_COUNCIL);
    console2.log('council executor: ', MiscEthereum.V4_SECURITY_COUNCIL_EXECUTOR);
    console2.log('executor lvl1: ', GovernanceV3Ethereum.EXECUTOR_LVL_1);

    SentoraPreLaunchCouncilCalls.Call[] memory calls = SentoraPreLaunchCouncilCalls.calls(payload);
    uint64[4] memory roles = SentoraPreLaunchCouncilCalls.roles();
    for (uint256 i; i < calls.length; ++i) {
      console2.log('--- safe tx', i + 1, '(CALL, value 0) ---');
      console2.log('to: ', calls[i].to);
      if (i < roles.length) {
        console2.log(
          'decoded: AccessManager.grantRole(roleId, account, executionDelay 0), roleId',
          roles[i]
        );
      } else if (i == roles.length) {
        console2.log('decoded: Executor.executeTransaction(payload, 0, "execute()", "", true)');
      } else {
        console2.log('decoded: AccessManager.grantRole(roleId 0, executor lvl1, executionDelay 0)');
      }
      console2.log('calldata: ');
      console2.logBytes(calls[i].data);
    }

    require(
      SentoraPreLaunchCouncilCalls.MULTI_SEND_CALL_ONLY.code.length > 0,
      'MultiSendCallOnly not deployed'
    );
    console2.log('--- batch: DELEGATECALL, value 0 ---');
    console2.log('to: ', SentoraPreLaunchCouncilCalls.MULTI_SEND_CALL_ONLY);
    console2.log('calldata: ');
    console2.logBytes(SentoraPreLaunchCouncilCalls.multiSend(payload));
  }
}
