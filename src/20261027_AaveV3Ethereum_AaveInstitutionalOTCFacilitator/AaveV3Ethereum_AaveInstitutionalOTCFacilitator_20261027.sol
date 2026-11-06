// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IGhoBucketSteward} from 'src/interfaces/IGhoBucketSteward.sol';
import {IGhoDirectFacilitator} from 'src/interfaces/IGhoDirectFacilitator.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';

/**
 * @title Aave Institutional - OTC Facilitator
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x194bd11500117aa7e0940bd0886a421a7658888af2cd04d82e07848afb8e3b79
 * - Discussion: https://governance.aave.com/t/arfc-aave-institutional/25692
 */
contract AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027 is IProposalGenericExecutor {
  // GhoDirectFacilitator, aave-dao/gho-origin
  // https://etherscan.io/address/0x647bf6b636ED76cE44d33eebF9C86d96Dfd004E9
  address public constant AAVE_INSTITUTIONAL_FACILITATOR =
    0x647bf6b636ED76cE44d33eebF9C86d96Dfd004E9;

  string public constant AAVE_INSTITUTIONAL_FACILITATOR_NAME =
    'Aave Institutional - OTC Facilitator';

  uint128 public constant AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY = 25_000_000 ether;

  function execute() external {
    IGhoToken(GhoEthereum.GHO_TOKEN).addFacilitator(
      AAVE_INSTITUTIONAL_FACILITATOR,
      AAVE_INSTITUTIONAL_FACILITATOR_NAME,
      AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY
    );

    address[] memory facilitators = new address[](1);
    facilitators[0] = AAVE_INSTITUTIONAL_FACILITATOR;
    IGhoBucketSteward(GhoEthereum.GHO_BUCKET_STEWARD).setControlledFacilitator(facilitators, true);

    IGhoDirectFacilitator facilitator = IGhoDirectFacilitator(AAVE_INSTITUTIONAL_FACILITATOR);
    facilitator.grantRole(facilitator.MINTER_ROLE(), GhoEthereum.RISK_COUNCIL);
    facilitator.grantRole(facilitator.BURNER_ROLE(), GhoEthereum.RISK_COUNCIL);
  }
}
