// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IAaveGhoCcipBridge} from 'aave-helpers/src/bridges/ccip/interfaces/IAaveGhoCcipBridge.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {GhoCCIPChains} from 'src/helpers/gho-launch/constants/GhoCCIPChains.sol';
import {IUpgradeableLockReleaseTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';

import {AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1} from './AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1.sol';
import {AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2} from './AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2.sol';

import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

/**
 * @dev Test for AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2.t.sol -vv
 */
contract AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2_Test is ProtocolV3TestBase {
  AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1 internal part1;
  AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25731136);
    part1 = new AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1();
    proposal = new AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2();

    // Run Part 1 so the GHO_CCIP_TOKEN_POOL bridge limit and outbound rate limiter are
    // raised before any Part 2 test runs. Without this, Part 2's `IAaveGhoCcipBridge.send`
    // would revert (rate-limit exceeded). Mirrors the real on-chain sequencing.
    executePayload(vm, address(part1));
    vm.warp(block.timestamp + 1); // let the outbound rate limiter refill to capacity
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_directFacilitatorName() public {
    executePayload(vm, address(proposal));

    assertEq(
      IGhoToken(AaveV3EthereumAssets.GHO_UNDERLYING)
        .getFacilitator(proposal.DIRECT_FACILITATOR())
        .label,
      proposal.DIRECT_FACILITATOR_NAME(),
      'direct facilitator name mismatch'
    );
  }

  /// @dev Confirms CCIP_BRIDGE is the AaveGhoCcipBridge that carries the Ethereum -> XLayer GHO lane
  function test_ccipBridgeIdentity() public view {
    IAaveGhoCcipBridge bridge = IAaveGhoCcipBridge(proposal.CCIP_BRIDGE());

    assertEq(
      bridge.GHO_TOKEN(),
      AaveV3EthereumAssets.GHO_UNDERLYING,
      'bridge does not move mainnet GHO'
    );
    assertEq(
      bridge.COLLECTOR(),
      address(AaveV3Ethereum.COLLECTOR),
      'bridge collector is not the Ethereum Collector'
    );
    assertEq(
      bridge.ROUTER(),
      IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL).getRouter(),
      'bridge router is not the router GHO_CCIP_TOKEN_POOL is registered under'
    );
    assertEq(
      IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL).getToken(),
      AaveV3EthereumAssets.GHO_UNDERLYING,
      'GHO_CCIP_TOKEN_POOL does not serve mainnet GHO'
    );
  }

  function test_ccipBridgeDestinationChainSetUp() public {
    IAaveGhoCcipBridge bridge = IAaveGhoCcipBridge(proposal.CCIP_BRIDGE());

    IAaveGhoCcipBridge.RemoteChainConfig memory config = bridge.getDestinationRemoteConfig(
      CCIPChainSelectors.XLAYER
    );

    assertEq(config.destination, new bytes(0));
    assertEq(config.extraArgsOverride, new bytes(0));
    assertEq(config.gasLimit, 0);

    executePayload(vm, address(proposal));

    config = bridge.getDestinationRemoteConfig(CCIPChainSelectors.XLAYER);

    assertEq(config.destination, abi.encode(proposal.XLAYER_BRIDGE_DESTINATION()));
    assertEq(config.extraArgsOverride, new bytes(0));
    assertEq(config.gasLimit, proposal.XLAYER_BRIDGE_GAS_LIMIT());
  }

  function test_bridgeLaneRestored() public {
    // setUp already executed Part 1, which raised the outbound rate limiter for the XLayer lane to
    // (capacity = TEMP_BRIDGE_CAPACITY, rate = TEMP_BRIDGE_CAPACITY - 1) and warped 1 second so
    // the bucket refilled to capacity.
    IRateLimiter.TokenBucket memory bucket = IUpgradeableLockReleaseTokenPool(
      GhoEthereum.GHO_CCIP_TOKEN_POOL
    ).getCurrentOutboundRateLimiterState(CCIPChainSelectors.XLAYER);

    assertEq(
      bucket.capacity,
      RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY,
      'pre-proposal outbound capacity should be raised to TEMP_BRIDGE_CAPACITY'
    );

    executePayload(vm, address(proposal));

    // The XLayer lane finishes restored to the standard config after executing the proposal.
    bucket = IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL)
      .getCurrentOutboundRateLimiterState(CCIPChainSelectors.XLAYER);

    assertEq(
      bucket.capacity,
      RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
      'post-proposal outbound capacity should be restored to standard'
    );
    assertEq(
      bucket.rate,
      RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE,
      'post-proposal outbound rate should be restored to standard'
    );
    assertTrue(bucket.isEnabled, 'post-proposal outbound rate limiter should be enabled');

    // The proposal restores both outbound and inbound configs; assert inbound too.
    bucket = IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL)
      .getCurrentInboundRateLimiterState(CCIPChainSelectors.XLAYER);

    assertEq(
      bucket.capacity,
      RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
      'post-proposal inbound capacity should be restored to standard'
    );
    assertEq(
      bucket.rate,
      RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE,
      'post-proposal inbound rate should be restored to standard'
    );
    assertTrue(bucket.isEnabled, 'post-proposal inbound rate limiter should be enabled');
  }

  function test_bridge() public {
    // setUp already executed Part 1, raising the bridge limit and outbound rate limiter
    // on the GHO_CCIP_TOKEN_POOL so Part 2's bridge step has the headroom it needs.
    IGhoToken.Facilitator memory facilitator = IGhoToken(AaveV3EthereumAssets.GHO_UNDERLYING)
      .getFacilitator(proposal.DIRECT_FACILITATOR());

    assertEq(facilitator.bucketCapacity, 0, 'facilitator should not be registered before proposal');
    assertEq(facilitator.bucketLevel, 0, 'facilitator bucket level should be 0 before proposal');

    // messageId is unknown ahead of time, so leave the first indexed topic unchecked.
    vm.expectEmit(false, true, true, true, proposal.CCIP_BRIDGE());
    emit IAaveGhoCcipBridge.BridgeMessageInitiated(
      bytes32(0),
      CCIPChainSelectors.XLAYER,
      GovernanceV3Ethereum.EXECUTOR_LVL_1,
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT
    );

    executePayload(vm, address(proposal));

    facilitator = IGhoToken(AaveV3EthereumAssets.GHO_UNDERLYING).getFacilitator(
      proposal.DIRECT_FACILITATOR()
    );

    assertEq(
      facilitator.bucketCapacity,
      RemoteGSMLaunchXLayerSetup.DIRECT_FACILITATOR_CAPACITY,
      'facilitator capacity not set to DIRECT_FACILITATOR_CAPACITY'
    );
    assertEq(
      facilitator.bucketLevel,
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
      'facilitator bucket level should match bridged amount'
    );

    assertEq(
      IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).balanceOf(address(proposal)),
      0,
      'left over GHO on payload'
    );
    assertEq(
      IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).allowance(
        address(proposal),
        proposal.CCIP_BRIDGE()
      ),
      0,
      'left over allowance on payload'
    );
  }

  function test_otherLanesUntouched() public {
    // This proposal must not change any lane other than the single Ethereum <> XLayer lane. Iterate
    // every supported chain except XLayer (the lane the proposal temporarily widens and then restores),
    // snapshot both directions before and after execution, and assert the config is unchanged.
    // Part 1 (run in setUp) likewise only touches the XLayer lane, so a delta here would mean the proposal leaked
    // into an unrelated lane.
    // Ethereum is included in the list (the proposal's own chain), but there's no need to skip it.
    GhoCCIPChains.ChainInfo[] memory chains = GhoCCIPChains.getAllChainsExcept(
      CCIPChainSelectors.XLAYER,
      false
    );

    IRateLimiter.TokenBucket[] memory inboundBefore = new IRateLimiter.TokenBucket[](chains.length);
    IRateLimiter.TokenBucket[] memory outboundBefore = new IRateLimiter.TokenBucket[](
      chains.length
    );
    for (uint256 i = 0; i < chains.length; i++) {
      inboundBefore[i] = IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL)
        .getCurrentInboundRateLimiterState(chains[i].chainSelector);
      outboundBefore[i] = IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL)
        .getCurrentOutboundRateLimiterState(chains[i].chainSelector);
    }

    executePayload(vm, address(proposal));

    for (uint256 i = 0; i < chains.length; i++) {
      _assertLaneUnchanged(chains[i].chainSelector, inboundBefore[i], outboundBefore[i]);
    }
  }

  /// @dev Asserts the inbound/outbound rate-limit config of `remoteChainSelector` matches the
  /// pre-execution snapshot (capacity, rate and isEnabled — the fields the proposal could change).
  function _assertLaneUnchanged(
    uint64 remoteChainSelector,
    IRateLimiter.TokenBucket memory inboundBefore,
    IRateLimiter.TokenBucket memory outboundBefore
  ) internal view {
    IRateLimiter.TokenBucket memory inboundAfter = IUpgradeableLockReleaseTokenPool(
      GhoEthereum.GHO_CCIP_TOKEN_POOL
    ).getCurrentInboundRateLimiterState(remoteChainSelector);
    assertEq(inboundAfter.capacity, inboundBefore.capacity, 'inbound capacity changed');
    assertEq(inboundAfter.rate, inboundBefore.rate, 'inbound rate changed');
    assertEq(inboundAfter.isEnabled, inboundBefore.isEnabled, 'inbound isEnabled changed');

    IRateLimiter.TokenBucket memory outboundAfter = IUpgradeableLockReleaseTokenPool(
      GhoEthereum.GHO_CCIP_TOKEN_POOL
    ).getCurrentOutboundRateLimiterState(remoteChainSelector);
    assertEq(outboundAfter.capacity, outboundBefore.capacity, 'outbound capacity changed');
    assertEq(outboundAfter.rate, outboundBefore.rate, 'outbound rate changed');
    assertEq(outboundAfter.isEnabled, outboundBefore.isEnabled, 'outbound isEnabled changed');
  }
}
