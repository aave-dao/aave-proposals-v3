// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';

import {AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1} from './AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.sol';
import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';
import {EXPECTED_BUCKET_CAPACITY, EXPECTED_TEMP_BRIDGE_CAPACITY, EXPECTED_TEMP_BRIDGE_RATE} from './setup/PermissionedGsmUsatAvalancheFacilitatorProposalBaseTest.t.sol';

/**
 * @dev Test for AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.t.sol -vv
 */
contract AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1_Test is ProtocolV3TestBase {
  AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1 internal proposal;
  IUpgradeableLockReleaseTokenPool internal pool =
    IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26405330);
    proposal = new AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_bridgeLimit() public {
    uint256 bridgeLimitBefore = pool.getBridgeLimit();

    executePayload(vm, address(proposal));

    assertEq(pool.getBridgeLimit(), bridgeLimitBefore + Setup.GHO_BRIDGE_AMOUNT);
    assertEq(pool.getBridgeLimit(), EXPECTED_BUCKET_CAPACITY);
  }

  function test_outboundRateLimiter() public {
    IRateLimiter.TokenBucket memory bucket = pool.getCurrentOutboundRateLimiterState(
      CCIPChainSelectors.AVALANCHE
    );
    assertEq(bucket.capacity, Setup.DEFAULT_RATE_LIMITER_CAPACITY, 'pre: outbound capacity');
    assertEq(bucket.rate, Setup.DEFAULT_LIMITER_RATE, 'pre: outbound rate');
    uint128 tokensBefore = bucket.tokens;

    executePayload(vm, address(proposal));

    bucket = pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.AVALANCHE);
    assertEq(bucket.capacity, EXPECTED_TEMP_BRIDGE_CAPACITY);
    assertEq(bucket.rate, EXPECTED_TEMP_BRIDGE_RATE);
    assertTrue(bucket.isEnabled);
    assertEq(bucket.tokens, tokensBefore, 'tokens do not refill in the execution second');

    vm.warp(block.timestamp + 1);

    bucket = pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.AVALANCHE);
    assertEq(bucket.tokens, tokensBefore + EXPECTED_TEMP_BRIDGE_RATE, 'one second of refill');
    assertGe(bucket.tokens, Setup.GHO_BRIDGE_AMOUNT);

    // From an empty bucket, one second refills 1 GHO short of the transfer; two seconds cover it
    assertLt(Setup.TEMP_BRIDGE_RATE, Setup.GHO_BRIDGE_AMOUNT);
    assertGe(2 * uint256(Setup.TEMP_BRIDGE_RATE), Setup.GHO_BRIDGE_AMOUNT);
  }

  function test_inboundRateLimiterUnchanged() public {
    IRateLimiter.TokenBucket memory bucket = pool.getCurrentInboundRateLimiterState(
      CCIPChainSelectors.AVALANCHE
    );
    assertTrue(bucket.isEnabled, 'pre: inbound enabled');
    assertEq(bucket.capacity, Setup.DEFAULT_RATE_LIMITER_CAPACITY, 'pre: inbound capacity');
    assertEq(bucket.rate, Setup.DEFAULT_LIMITER_RATE, 'pre: inbound rate');

    executePayload(vm, address(proposal));

    bucket = pool.getCurrentInboundRateLimiterState(CCIPChainSelectors.AVALANCHE);
    assertTrue(bucket.isEnabled);
    assertEq(bucket.capacity, Setup.DEFAULT_RATE_LIMITER_CAPACITY);
    assertEq(bucket.rate, Setup.DEFAULT_LIMITER_RATE);
  }
}
