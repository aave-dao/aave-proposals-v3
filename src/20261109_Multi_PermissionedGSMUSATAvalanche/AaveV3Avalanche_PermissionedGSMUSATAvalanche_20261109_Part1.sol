// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {GhoAvalanche} from 'aave-address-book/GhoAvalanche.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IUpgradeableBurnMintTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableBurnMintTokenPool.sol';

import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';

/**
 * @title Permissioned GSM: USAT on Aave V4 Avalanche
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2
 * - Discussion: https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852
 */
contract AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1 is IProposalGenericExecutor {
  using SafeCast for uint256;

  function execute() external {
    // Bucket capacity grows by the bridged amount so the pool can mint it on Avalanche
    (uint256 currentCapacity, ) = IGhoToken(GhoAvalanche.GHO_TOKEN).getFacilitatorBucket(
      GhoAvalanche.GHO_CCIP_TOKEN_POOL
    );
    IGhoToken(GhoAvalanche.GHO_TOKEN).setFacilitatorBucketCapacity(
      GhoAvalanche.GHO_CCIP_TOKEN_POOL,
      (currentCapacity + Setup.GHO_BRIDGE_AMOUNT).toUint128()
    );

    // Temporary inbound widening (counterpart of the Ethereum Part 1 outbound step); Part 2 restores this lane only.
    // Outbound is rewritten to its current (ongoing) value.
    IUpgradeableBurnMintTokenPool(GhoAvalanche.GHO_CCIP_TOKEN_POOL).setChainRateLimiterConfig({
      remoteChainSelector: CCIPChainSelectors.ETHEREUM,
      outboundConfig: IRateLimiter.Config({
        isEnabled: true,
        capacity: Setup.DEFAULT_RATE_LIMITER_CAPACITY,
        rate: Setup.DEFAULT_LIMITER_RATE
      }),
      inboundConfig: IRateLimiter.Config({
        isEnabled: true,
        capacity: Setup.TEMP_BRIDGE_CAPACITY,
        rate: Setup.TEMP_BRIDGE_RATE
      })
    });
  }
}
