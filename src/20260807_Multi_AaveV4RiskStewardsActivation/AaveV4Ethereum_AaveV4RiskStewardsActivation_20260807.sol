// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4Ethereum} from 'aave-address-book/AaveV4Ethereum.sol';
import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';
import {RiskStewardV4Config} from 'src/helpers/risk-stewards/RiskStewardV4Config.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';

/**
 * @title AaveV4RiskStewardsActivation
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xf736fa5f6dd1532d0e2825fe528262479949a923427989384e313490ca9d9f18
 * - Discussion: https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510
 */
contract AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807 is IProposalGenericExecutor {
  function execute() external override {
    AaveV4Ethereum.ACCESS_MANAGER.grantRole({
      roleId: Roles.HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      account: AaveV4Ethereum.RISK_STEWARD,
      executionDelay: 0
    });
    AaveV4Ethereum.ACCESS_MANAGER.grantRole({
      roleId: Roles.SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE,
      account: AaveV4Ethereum.RISK_STEWARD,
      executionDelay: 0
    });
    // the CAPO adapters behind the v4 price sources gate setCapParameters on the v3 ACL manager
    AaveV3Ethereum.ACL_MANAGER.addRiskAdmin(AaveV4Ethereum.RISK_STEWARD);

    IRiskStewardV4(AaveV4Ethereum.RISK_STEWARD).setConfig(
      RiskStewardV4Config.defaultConfig({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR
      })
    );
  }
}
