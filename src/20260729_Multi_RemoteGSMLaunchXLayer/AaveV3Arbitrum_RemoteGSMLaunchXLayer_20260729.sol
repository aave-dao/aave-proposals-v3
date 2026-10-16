// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GhoArbitrum} from 'aave-address-book/GhoArbitrum.sol';

import {RemoteGSMLaunchXLayerFacilitatorProposalBase} from './setup/RemoteGSMLaunchXLayerFacilitatorProposalBase.sol';

/**
 * @title Remote GSM Launch: XLayer
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178
 */
contract AaveV3Arbitrum_RemoteGSMLaunchXLayer_20260729 is
  RemoteGSMLaunchXLayerFacilitatorProposalBase
{
  function GHO_TOKEN() public pure override returns (address) {
    return GhoArbitrum.GHO_TOKEN;
  }

  function GHO_CCIP_TOKEN_POOL() public pure override returns (address) {
    return GhoArbitrum.GHO_CCIP_TOKEN_POOL;
  }
}
