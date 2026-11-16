// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';

import {PermissionedGSMUSATAvalancheSetup as Setup} from './PermissionedGSMUSATAvalancheSetup.sol';

/**
 * @title Permissioned GSM: USAT on Aave V4 Avalanche
 * @author TokenLogic
 * - Snapshot: TBA
 * - Discussion: https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852
 * @dev Payload for every remote GHO network other than Avalanche.
 */
abstract contract PermissionedGSMUSATAvalancheFacilitatorProposalBase is IProposalGenericExecutor {
  using SafeCast for uint256;

  function GHO_TOKEN() public view virtual returns (address);

  function GHO_CCIP_TOKEN_POOL() public view virtual returns (address);

  function execute() external {
    // The bucket grows by the GHO newly minted on Ethereum, so it can move to this network too
    IGhoToken gho = IGhoToken(GHO_TOKEN());
    (uint256 currentCapacity, ) = gho.getFacilitatorBucket(GHO_CCIP_TOKEN_POOL());
    gho.setFacilitatorBucketCapacity(
      GHO_CCIP_TOKEN_POOL(),
      (currentCapacity + Setup.GHO_BRIDGE_AMOUNT).toUint128()
    );
  }
}
