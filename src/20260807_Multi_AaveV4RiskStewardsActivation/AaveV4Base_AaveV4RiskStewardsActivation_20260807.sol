// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Base} from 'aave-address-book/AaveV3Base.sol';
import {AaveV4Base} from 'aave-address-book/AaveV4Base.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';

/**
 * @title AaveV4RiskStewardsActivation
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xf736fa5f6dd1532d0e2825fe528262479949a923427989384e313490ca9d9f18
 * - Discussion: https://governance.aave.com/t/arfc-activate-aave-risk-stewards-on-aave-v4/25510
 */
contract AaveV4Base_AaveV4RiskStewardsActivation_20260807 is IProposalGenericExecutor {
  function execute() external override {
    IRiskStewardV4(AaveV4Base.RISK_STEWARD).acceptOwnership();
    // the CAPO adapters behind the v4 price sources gate setPriceCap on the v3 ACL manager
    AaveV3Base.ACL_MANAGER.addRiskAdmin(AaveV4Base.RISK_STEWARD);
  }
}
