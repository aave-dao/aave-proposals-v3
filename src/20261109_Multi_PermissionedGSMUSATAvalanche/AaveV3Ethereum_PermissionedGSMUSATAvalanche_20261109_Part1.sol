// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';

import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';

import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';

/**
 * @title Permissioned GSM: USAT on Aave V4 Avalanche
 * @author TokenLogic
 * - Snapshot: TBA
 * - Discussion: https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852
 */
contract AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1 is IProposalGenericExecutor {
  function execute() external {
    IUpgradeableLockReleaseTokenPool pool = IUpgradeableLockReleaseTokenPool(
      GhoEthereum.GHO_CCIP_TOKEN_POOL
    );

    // Permanent: the bridged GHO stays locked in the pool
    pool.setBridgeLimit(pool.getBridgeLimit() + Setup.GHO_BRIDGE_AMOUNT);

    // Temporary outbound widening for the one-off transfer; Part 2 restores this lane only.
    // Inbound is rewritten to its current (ongoing) value.
    pool.setChainRateLimiterConfig({
      remoteChainSelector: CCIPChainSelectors.AVALANCHE,
      outboundConfig: IRateLimiter.Config({
        isEnabled: true,
        capacity: Setup.TEMP_BRIDGE_CAPACITY,
        rate: Setup.TEMP_BRIDGE_RATE
      }),
      inboundConfig: IRateLimiter.Config({
        isEnabled: true,
        capacity: Setup.DEFAULT_RATE_LIMITER_CAPACITY,
        rate: Setup.DEFAULT_LIMITER_RATE
      })
    });
  }
}
