// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';

import {RemoteGSMLaunchXLayerSetup} from './RemoteGSMLaunchXLayerSetup.sol';

/**
 * @title Remote GSM Launch: XLayer
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178
 */
abstract contract RemoteGSMLaunchXLayerFacilitatorProposalBase is IProposalGenericExecutor {
  using SafeCast for uint256;

  function GHO_TOKEN() public view virtual returns (address);

  function GHO_CCIP_TOKEN_POOL() public view virtual returns (address);

  function execute() external {
    IGhoToken gho = IGhoToken(GHO_TOKEN());
    address ghoCcipTokenPool = GHO_CCIP_TOKEN_POOL();

    // Increase bucket capacity to allow token movements to this network, accounting for the extra
    // supply minted on Ethereum and initially bridged to XLayer in this proposal.
    (uint256 currentFacilitatorBucketCapacity, ) = gho.getFacilitatorBucket(ghoCcipTokenPool);

    gho.setFacilitatorBucketCapacity(
      ghoCcipTokenPool,
      currentFacilitatorBucketCapacity.toUint128() +
        RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT.toUint128()
    );
  }
}
