// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {GhoXLayer} from 'aave-address-book/GhoXLayer.sol';
import {AaveV3XLayer, AaveV3XLayerAssets} from 'aave-address-book/AaveV3XLayer.sol';
import {GovernanceV3XLayer} from 'aave-address-book/GovernanceV3XLayer.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IUpgradeableBurnMintTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableBurnMintTokenPool.sol';
import {IUpgradeableBurnMintTokenPool_1_5_1} from 'src/interfaces/ccip/tokenPool/IUpgradeableBurnMintTokenPool.sol';
import {IPool as IPool_CCIP} from 'src/interfaces/ccip/tokenPool/IPool.sol';
import {IRouter} from 'src/interfaces/ccip/IRouter.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {GhoCCIPChains} from 'src/helpers/gho-launch/constants/GhoCCIPChains.sol';
import {CCIPChainRouters} from 'src/helpers/gho-launch/constants/CCIPChainRouters.sol';
import {IAaveOracle} from 'aave-address-book/AaveV2.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmFeeStrategy} from 'src/interfaces/IGsmFeeStrategy.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IGsmSteward} from 'src/interfaces/IGsmSteward.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IOracleSwapFreezer} from 'src/interfaces/IOracleSwapFreezer.sol';
import {IFixedPriceStrategy4626} from 'src/interfaces/IFixedPriceStrategy4626.sol';

import {AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1} from './AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1.sol';
import {AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2} from './AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2.sol';

import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

/**
 * @dev Test for AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260729_Multi_RemoteGSMLaunchXLayer/AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2.t.sol -vv
 */
contract AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2_Test is ProtocolV3TestBase {
  using SafeERC20 for IERC20;

  // Existing Eth->XLayer inbound rate-limiter capacity at the pinned block, before Part 1 widens it.
  // A 25M CCIP delivery exceeds this, which is what `test_ccipDeliveryRevertsWithoutPart1` asserts.
  // The lane is now normalized, so this matches the standard per-lane capacity.
  uint256 internal constant EXISTING_ETH_INBOUND_RATE_LIMITER_CAPACITY =
    RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY;

  // The USDG GSM is deployed (outside governance) with a default 20M exposure cap; the payload sets
  // it to GSM_USDG_INITIAL_EXPOSURE_CAP (currently the same value). Pinned as pre-state so the post checks can't
  // pass vacuously against a GSM redeployed already-configured (which would let a dropped payload line slip through).
  uint128 internal constant GSM_USDG_DEPLOY_EXPOSURE_CAP = 20_000_000e6;

  // Ethereum -> XLayer CCIP OffRamp on the XLayer router. `test_ccipOffRampIsRegistered` re-checks
  // that it is a registered OffRamp at the pinned block.
  // Note: The router currently has a second offramp registered (0xA1d9f24ABb611EE43b276F5EcDf65Bab6fEBd924),
  // which corresponds to the legacy 1.5 interface. `0x77FD` is the correct one for the 1.6 interface.
  // https://www.oklink.com/x-layer/evm/address/0x77FDbd20ED582794b1d9F1a8a94e4a60494D677e
  address internal constant CCIP_ETH_OFFRAMP = address(0x77FDbd20ED582794b1d9F1a8a94e4a60494D677e);

  // XLayer USDG stata token is not in AaveV3XLayerAssets yet.
  // https://www.oklink.com/x-layer/evm/address/0x97e7620A3229b3daC7049C537B0E29DA2D1021E1
  address internal constant USDG_STATA_TOKEN = address(0x97e7620A3229b3daC7049C537B0E29DA2D1021E1);

  AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1 internal part1;
  AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2 internal proposal;

  // Captured immediately before the simulated CCIP mint in setUp so tests can assert deltas
  // (the Collector and the CCIP token pool facilitator both have non-zero state at the
  // fork block).
  uint256 internal collectorGhoBalanceBeforeCcipDelivery;
  uint128 internal ccipPoolFacilitatorBucketLevelBeforeCcipDelivery;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('xlayer'), 67674936);
    part1 = new AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1();
    proposal = new AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2();

    // Run Part 1 so the GHO_CCIP_TOKEN_POOL facilitator bucket capacity is raised and the
    // Eth->XLayer inbound rate limiter is widened, mirroring the real sequencing on-chain.
    executePayload(vm, address(part1));
    vm.warp(block.timestamp + 1); // let the inbound rate limiter refill to capacity

    collectorGhoBalanceBeforeCcipDelivery = IERC20(GhoXLayer.GHO_TOKEN).balanceOf(
      address(AaveV3XLayer.COLLECTOR)
    );
    ccipPoolFacilitatorBucketLevelBeforeCcipDelivery = IGhoToken(GhoXLayer.GHO_TOKEN)
      .getFacilitator(GhoXLayer.GHO_CCIP_TOKEN_POOL)
      .bucketLevel;

    // Simulate CCIP delivery end-to-end: prank as the Eth->XLayer OffRamp and call `releaseOrMint`
    // on the GHO CCIP token pool. The pool acts as a GHO facilitator, so this routes through
    // `IGhoToken.mint` and exercises the facilitator bucket check that Part 1 just configured.
    _simulateCcipDeliveryToCollector(RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT);
  }

  /**
   * @dev executes the generic test suite. e2e is skipped (no usable XLayer collateral at the fork
   * block) — the payload does not modify pool reserves, so e2e adds no coverage.
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2',
      AaveV3XLayer.POOL,
      address(proposal),
      false,
      false
    );
  }

  function test_ghoReserveIsFunded() public {
    assertEq(IERC20(GhoXLayer.GHO_TOKEN).balanceOf(address(proposal.GHO_RESERVE())), 0);

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(GhoXLayer.GHO_TOKEN).balanceOf(address(proposal.GHO_RESERVE())),
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT
    );
  }

  function test_gsmIsRegisteredUnderGsmRegistry() public {
    IGsmRegistry registry = IGsmRegistry(proposal.GSM_REGISTRY());

    assertEq(registry.getGsmListLength(), 0);

    vm.expectRevert('INVALID_INDEX');
    registry.getGsmAtIndex(0);

    executePayload(vm, address(proposal));

    assertEq(registry.getGsmListLength(), 1);
    assertEq(registry.getGsmAtIndex(0), proposal.GSM_USDG());
  }

  function test_ccipOffRampIsRegistered() public view {
    // Guard: if CCIP rotates the Eth -> XLayer OffRamp at a future block, this test fails
    // with a clear signal before the more-opaque `releaseOrMint` revert in setUp shows up
    // elsewhere in the suite.
    assertTrue(
      IRouter(CCIPChainRouters.XLAYER).isOffRamp(CCIPChainSelectors.ETHEREUM, CCIP_ETH_OFFRAMP),
      'CCIP_ETH_OFFRAMP is no longer a registered Eth->XLayer OffRamp on XLayer CCIP router'
    );
  }

  function test_ccipDeliveryMintsToCollector() public view {
    // setUp ran Part 1 then simulated a CCIP delivery via releaseOrMint. Assert the
    // Collector and the GHO_CCIP_TOKEN_POOL facilitator both moved by BRIDGED_AMOUNT.
    // If Part 1's facilitator-capacity update is misconfigured (e.g. capacity below
    // BRIDGED_AMOUNT), setUp's `releaseOrMint` reverts and the whole suite fails at setUp.
    assertEq(
      IERC20(GhoXLayer.GHO_TOKEN).balanceOf(address(AaveV3XLayer.COLLECTOR)) -
        collectorGhoBalanceBeforeCcipDelivery,
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
      'Collector GHO balance should increase by exactly BRIDGED_AMOUNT'
    );

    IGhoToken.Facilitator memory facilitator = IGhoToken(GhoXLayer.GHO_TOKEN).getFacilitator(
      GhoXLayer.GHO_CCIP_TOKEN_POOL
    );
    assertEq(
      facilitator.bucketLevel - ccipPoolFacilitatorBucketLevelBeforeCcipDelivery,
      uint128(RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT),
      'CCIP token pool facilitator bucketLevel should increase by exactly BRIDGED_AMOUNT'
    );
  }

  function test_ccipDeliveryRevertsWithoutPart1() public {
    // Ordering guard for Part 1 -> Part 2. Part 2 depends on the 25M bridged from Ethereum landing on
    // XLayer, which is only possible once Part 1 widens the Eth->XLayer inbound rate limiter
    // (EXISTING_ETH_INBOUND_RATE_LIMITER_CAPACITY -> TEMP_BRIDGE_CAPACITY). Re-fork to discard
    // setUp's Part 1 + simulated delivery, then show the delivery reverts on the inbound rate
    // limiter without Part 1: 25M exceeds the existing capacity, so the funds cannot arrive if
    // Part 1 is skipped. (Whether the funds are actually bridged depends on the Ethereum payloads;
    // this only asserts XLayer cannot receive them until Part 1 runs.)
    vm.createSelectFork(vm.rpcUrl('xlayer'), 67674936);

    vm.expectRevert(
      abi.encodeWithSelector(
        IUpgradeableBurnMintTokenPool.TokenMaxCapacityExceeded.selector,
        EXISTING_ETH_INBOUND_RATE_LIMITER_CAPACITY,
        RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
        GhoXLayer.GHO_TOKEN
      )
    );
    _simulateCcipDeliveryToCollector(RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT);
  }

  function test_laneRateLimitRestored() public {
    // setUp() already executes Part 1 and warps 1 second; the inbound rate limiter is
    // already widened by this point.

    IRateLimiter.TokenBucket memory bucket = IUpgradeableBurnMintTokenPool(
      GhoXLayer.GHO_CCIP_TOKEN_POOL
    ).getCurrentInboundRateLimiterState(CCIPChainSelectors.ETHEREUM);

    // Before Part 2 execution, Part 1 has widened the inbound lane to the temporary bridge config.
    assertEq(
      bucket.capacity,
      RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY,
      'pre-Part2 inbound capacity should be raised to TEMP_BRIDGE_CAPACITY'
    );
    assertEq(
      bucket.rate,
      RemoteGSMLaunchXLayerSetup.TEMP_BRIDGE_CAPACITY - 1,
      'pre-Part2 inbound rate should be raised to TEMP_BRIDGE_CAPACITY - 1'
    );
    assertTrue(bucket.isEnabled, 'pre-Part2 inbound rate limiter should be enabled');

    executePayload(vm, address(proposal));

    bucket = IUpgradeableBurnMintTokenPool(GhoXLayer.GHO_CCIP_TOKEN_POOL)
      .getCurrentInboundRateLimiterState(CCIPChainSelectors.ETHEREUM);

    // The Ethereum lane is restored to the standard config after Part 2 execution.
    assertEq(
      bucket.capacity,
      RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
      'post-Part2 inbound capacity should be restored to default'
    );
    assertEq(
      bucket.rate,
      RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE,
      'post-Part2 inbound rate should be restored to default'
    );
    assertTrue(bucket.isEnabled, 'post-Part2 inbound rate limiter should be enabled');

    // The proposal restores both inbound and outbound configs; assert outbound too.
    bucket = IUpgradeableBurnMintTokenPool(GhoXLayer.GHO_CCIP_TOKEN_POOL)
      .getCurrentOutboundRateLimiterState(CCIPChainSelectors.ETHEREUM);

    assertEq(
      bucket.capacity,
      RemoteGSMLaunchXLayerSetup.DEFAULT_RATE_LIMITER_CAPACITY,
      'post-Part2 outbound capacity should be restored to default'
    );
    assertEq(
      bucket.rate,
      RemoteGSMLaunchXLayerSetup.DEFAULT_LIMITER_RATE,
      'post-Part2 outbound rate should be restored to default'
    );
    assertTrue(bucket.isEnabled, 'post-Part2 outbound rate limiter should be enabled');
  }

  function test_otherLanesUntouched() public {
    // This proposal must not change any lane other than the single XLayer <> Ethereum lane. Iterate
    // every supported chain except Ethereum (the lane the proposal temporarily widens and then restores),
    // snapshot both directions before and after execution, and assert the config is unchanged.
    // Part 1 (run in setUp) likewise only touches the Ethereum lane, so a delta here would mean the proposal
    // leaked into an unrelated lane.
    // XLayer is included in the list (the proposal's own chain), but there's no need to skip it.
    GhoCCIPChains.ChainInfo[] memory chains = GhoCCIPChains.getAllChainsExcept(
      CCIPChainSelectors.ETHEREUM,
      false
    );

    IRateLimiter.TokenBucket[] memory inboundBefore = new IRateLimiter.TokenBucket[](chains.length);
    IRateLimiter.TokenBucket[] memory outboundBefore = new IRateLimiter.TokenBucket[](
      chains.length
    );
    for (uint256 i = 0; i < chains.length; i++) {
      inboundBefore[i] = IUpgradeableBurnMintTokenPool(GhoXLayer.GHO_CCIP_TOKEN_POOL)
        .getCurrentInboundRateLimiterState(chains[i].chainSelector);
      outboundBefore[i] = IUpgradeableBurnMintTokenPool(GhoXLayer.GHO_CCIP_TOKEN_POOL)
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
    IRateLimiter.TokenBucket memory inboundAfter = IUpgradeableBurnMintTokenPool(
      GhoXLayer.GHO_CCIP_TOKEN_POOL
    ).getCurrentInboundRateLimiterState(remoteChainSelector);
    assertEq(inboundAfter.capacity, inboundBefore.capacity, 'inbound capacity changed');
    assertEq(inboundAfter.rate, inboundBefore.rate, 'inbound rate changed');
    assertEq(inboundAfter.isEnabled, inboundBefore.isEnabled, 'inbound isEnabled changed');

    IRateLimiter.TokenBucket memory outboundAfter = IUpgradeableBurnMintTokenPool(
      GhoXLayer.GHO_CCIP_TOKEN_POOL
    ).getCurrentOutboundRateLimiterState(remoteChainSelector);
    assertEq(outboundAfter.capacity, outboundBefore.capacity, 'outbound capacity changed');
    assertEq(outboundAfter.rate, outboundBefore.rate, 'outbound rate changed');
    assertEq(outboundAfter.isEnabled, outboundBefore.isEnabled, 'outbound isEnabled changed');
  }

  function test_gsmRegisteredAsEntity() public {
    executePayload(vm, address(proposal));

    assertTrue(
      IGhoReserve(address(proposal.GHO_RESERVE())).isEntity(proposal.GSM_USDG()),
      'USDG GSM not registered as entity'
    );
  }

  function test_checkGsmConfig_USDG() public {
    IGsm gsm = IGsm(proposal.GSM_USDG());
    IGhoReserve reserve = IGhoReserve(address(proposal.GHO_RESERVE()));

    // Pre-state: the payload must move each of these.
    assertEq(
      gsm.getExposureCap(),
      GSM_USDG_DEPLOY_EXPOSURE_CAP,
      'pre: exposure cap should be the deploy default'
    );
    assertEq(gsm.getFeeStrategy(), address(0), 'pre: fee strategy should be unset');
    assertEq(reserve.getLimit(address(gsm)), 0, 'pre: reserve limit should be unset');

    executePayload(vm, address(proposal));

    uint256 limit = reserve.getLimit(address(gsm));
    assertEq(
      limit,
      RemoteGSMLaunchXLayerSetup.GSM_USDG_RESERVE_LIMIT,
      'USDG GSM reserve limit not set'
    );

    assertEq(gsm.getGhoReserve(), address(reserve), 'USDG GSM reserve address wrong');

    GsmConfig memory gsmConfig = GsmConfig({
      sellFee: 0, // 0%
      buyFee: 0.001e4, // 0.1%
      exposureCap: RemoteGSMLaunchXLayerSetup.GSM_USDG_INITIAL_EXPOSURE_CAP,
      isFrozen: false,
      isSeized: false,
      freezerCanUnfreeze: true,
      freezeLowerBound: 0.99e8,
      freezeUpperBound: 1.01e8,
      unfreezeLowerBound: 0.995e8,
      unfreezeUpperBound: 1.005e8,
      feeStrategy: proposal.GSM_USDG_FEE_STRATEGY()
    });
    _checkGsmConfig(
      gsm,
      USDG_STATA_TOKEN,
      IOracleSwapFreezer(proposal.USDG_ORACLE_SWAP_FREEZER()),
      gsmConfig
    );
  }

  function test_oracleSwapFreezer_USDG() public {
    _testOracleSwapFreezer(
      IGsm(proposal.GSM_USDG()),
      IOracleSwapFreezer(proposal.USDG_ORACLE_SWAP_FREEZER()),
      AaveV3XLayerAssets.USDG_UNDERLYING
    );
  }

  function test_checkRoles_USDG() public {
    IGsm gsm = IGsm(proposal.GSM_USDG());

    // Pre-state: the payload grants these four roles. Assert they are ungranted beforehand so the
    // post-state role checks cannot pass vacuously against a pre-authorized redeploy with a
    // grantRole line dropped. (DEFAULT_ADMIN / CONFIGURATOR on the executor are set at GSM deploy,
    // not by this payload, so they are intentionally not pinned here.)
    _assertPayloadGrantedRolesUngranted(gsm);

    executePayload(vm, address(proposal));
    _checkRolesConfig(gsm);
  }

  function test_gsmIsOperational_USDG() public {
    _testGsmIsOperational(IGsm(proposal.GSM_USDG()), USDG_STATA_TOKEN);
  }

  function test_ghoGsmSteward_updateExposureCap_USDG() public {
    _testUpdateExposureCap(IGsm(proposal.GSM_USDG()));
  }

  function test_ghoGsmSteward_updateGsmBuySellFees_USDG() public {
    _testUpdateBuySellFees(IGsm(proposal.GSM_USDG()));
  }

  /**
   * @dev Simulates the destination-chain CCIP mint that delivers bridged GHO to the
   * Collector. Pranks as the Eth->XLayer OffRamp registered on the XLayer CCIP router and
   * invokes `releaseOrMint` on the GHO token pool, which routes through `IGhoToken.mint`
   * and exercises the facilitator bucket capacity raised by Part 1.
   *
   * The pool is v1.5.1, which uses the struct-based `releaseOrMint(ReleaseOrMintInV1)`
   * signature (see `src/interfaces/ccip/tokenPool/IUpgradeableBurnMintTokenPool.sol`).
   */
  function _simulateCcipDeliveryToCollector(uint256 amount) internal {
    vm.prank(CCIP_ETH_OFFRAMP);
    IUpgradeableBurnMintTokenPool_1_5_1(GhoXLayer.GHO_CCIP_TOKEN_POOL).releaseOrMint(
      IPool_CCIP.ReleaseOrMintInV1({
        originalSender: abi.encode(GovernanceV3XLayer.EXECUTOR_LVL_1),
        remoteChainSelector: CCIPChainSelectors.ETHEREUM,
        receiver: address(AaveV3XLayer.COLLECTOR),
        amount: amount,
        localToken: GhoXLayer.GHO_TOKEN,
        // Informational on the destination side; using the real Eth pool keeps it realistic.
        sourcePoolAddress: abi.encode(GhoEthereum.GHO_CCIP_TOKEN_POOL),
        sourcePoolData: new bytes(0),
        offchainTokenData: new bytes(0)
      })
    );
  }

  function _testOracleSwapFreezer(
    IGsm gsm,
    IOracleSwapFreezer freezer,
    address underlyingForOracle
  ) internal {
    // OracleSwapFreezer is not authorized before execution
    assertEq(
      gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), address(freezer)),
      false,
      'freezer should not have SWAP_FREEZER_ROLE before proposal'
    );

    (uint128 freezeLowerBound, ) = freezer.getFreezeBound();
    (uint128 unfreezeLowerBound, ) = freezer.getUnfreezeBound();

    // Price outside the price range — freezer cannot execute freeze without authorization.
    _mockAssetPrice(address(AaveV3XLayer.ORACLE), underlyingForOracle, freezeLowerBound - 1);

    (bool canPerformUpkeep, ) = freezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, false, 'checkUpkeep should report false before proposal');
    freezer.performUpkeep(bytes(''));
    assertEq(gsm.getIsFrozen(), false, 'GSM should not be frozen before proposal');

    // Explicit "cannot perform the action": calling the privileged primitive as the
    // freezer reverts because it does not yet hold SWAP_FREEZER_ROLE.
    vm.prank(address(freezer));
    vm.expectRevert();
    gsm.setSwapFreeze(true);

    // Payload execution
    executePayload(vm, address(proposal));

    // Freezer is authorized now
    assertEq(
      gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), address(freezer)),
      true,
      'freezer should hold SWAP_FREEZER_ROLE after proposal'
    );

    // Freezer freezes the GSM
    (canPerformUpkeep, ) = freezer.checkUpkeep(bytes(''));
    assertEq(
      canPerformUpkeep,
      true,
      'checkUpkeep should report true after proposal with bad price'
    );
    freezer.performUpkeep(bytes(''));
    assertEq(gsm.getIsFrozen(), true, 'GSM should be frozen after freezer performs upkeep');

    // Price back to normal
    _mockAssetPrice(address(AaveV3XLayer.ORACLE), underlyingForOracle, unfreezeLowerBound + 1);

    (canPerformUpkeep, ) = freezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true, 'checkUpkeep should report true with price back in band');
    freezer.performUpkeep(bytes(''));
    assertEq(gsm.getIsFrozen(), false, 'GSM should be unfrozen after price recovers');
  }

  function _testGsmIsOperational(IGsm gsm, address underlying) internal {
    executePayload(vm, address(proposal));

    // NOTE: `deal(STATA, true)` writes the balance slot directly *and* updates the ERC4626
    // accounting (`totalAssets`, `totalSupply`), so the 4626 preview math behind
    // `getAssetPriceInGho` stays consistent with the dealt balance. The swap outputs below are
    // checked against the price + fee strategies directly (not the swap's own return value), so a
    // mispriced strategy or wrong fee is caught.
    deal(underlying, address(this), 1_000e6, true);

    IERC20(underlying).forceApprove(address(gsm), 1_000e6);
    IERC20(GhoXLayer.GHO_TOKEN).forceApprove(address(gsm), 1_200 ether);

    uint256 amountToSell = 1_000e6;
    uint256 amountToBuy = 500e6;
    uint256 gsmBalanceBefore = IERC20(underlying).balanceOf(address(gsm));
    uint256 userUnderlyingBefore = IERC20(underlying).balanceOf(address(this));
    uint256 balanceGhoBefore = IGhoToken(GhoXLayer.GHO_TOKEN).balanceOf(address(this));

    // Expected GHO out on a sell, derived independently: selling rounds the GHO valuation down and
    // the user receives the gross value minus the sell fee.
    uint256 expectedGhoBought = _expectedGhoForSell(gsm, amountToSell);
    // Expected GHO in on a buy, derived independently: buying rounds the GHO valuation up and the
    // user pays the gross value plus the buy fee.
    uint256 expectedGhoSold = _expectedGhoForBuy(gsm, amountToBuy);

    {
      (, uint256 ghoBought) = gsm.sellAsset(amountToSell, address(this));
      assertEq(
        ghoBought,
        expectedGhoBought,
        'sellAsset GHO out does not match price + fee strategy'
      );
    }

    assertEq(
      IERC20(underlying).balanceOf(address(gsm)),
      gsmBalanceBefore + amountToSell,
      'underlying balance in GSM after sellAsset is wrong'
    );
    assertEq(
      IERC20(underlying).balanceOf(address(this)),
      userUnderlyingBefore - amountToSell,
      'user underlying balance after sellAsset is wrong'
    );
    assertEq(
      IGhoToken(GhoXLayer.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + expectedGhoBought,
      'GHO balance after sellAsset is wrong'
    );

    {
      (, uint256 ghoSold) = gsm.buyAsset(amountToBuy, address(this));
      assertEq(ghoSold, expectedGhoSold, 'buyAsset GHO in does not match price + fee strategy');
    }

    assertEq(
      IERC20(underlying).balanceOf(address(gsm)),
      gsmBalanceBefore + amountToSell - amountToBuy,
      'underlying balance in GSM after buyAsset is wrong'
    );
    assertEq(
      IERC20(underlying).balanceOf(address(this)),
      userUnderlyingBefore - amountToSell + amountToBuy,
      'user underlying balance after buyAsset is wrong'
    );
    assertEq(
      IGhoToken(GhoXLayer.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + expectedGhoBought - expectedGhoSold,
      'GHO balance after buyAsset is wrong'
    );
  }

  /// @dev GHO the user receives when selling `assetAmount` of underlying: gross value (rounded
  /// down) minus the sell fee, computed from the GSM's price and fee strategies directly.
  function _expectedGhoForSell(IGsm gsm, uint256 assetAmount) internal view returns (uint256) {
    uint256 gross = IFixedPriceStrategy4626(gsm.PRICE_STRATEGY()).getAssetPriceInGho(
      assetAmount,
      false
    );
    return gross - IGsmFeeStrategy(gsm.getFeeStrategy()).getSellFee(gross);
  }

  /// @dev GHO the user pays when buying `assetAmount` of underlying: gross value (rounded up) plus
  /// the buy fee, computed from the GSM's price and fee strategies directly.
  function _expectedGhoForBuy(IGsm gsm, uint256 assetAmount) internal view returns (uint256) {
    uint256 gross = IFixedPriceStrategy4626(gsm.PRICE_STRATEGY()).getAssetPriceInGho(
      assetAmount,
      true
    );
    return gross + IGsmFeeStrategy(gsm.getFeeStrategy()).getBuyFee(gross);
  }

  function _testUpdateExposureCap(IGsm gsm) internal {
    executePayload(vm, address(proposal));

    uint128 oldExposureCap = gsm.getExposureCap();
    uint128 newExposureCap = oldExposureCap + 1;

    vm.startPrank(GhoXLayer.RISK_COUNCIL);
    IGsmSteward(proposal.GHO_GSM_STEWARD()).updateGsmExposureCap(address(gsm), newExposureCap);
    assertEq(gsm.getExposureCap(), newExposureCap, 'exposure cap not updated by GhoGsmSteward');
  }

  function _testUpdateBuySellFees(IGsm gsm) internal {
    executePayload(vm, address(proposal));

    address feeStrategy = gsm.getFeeStrategy();
    uint256 buyFee = IGsmFeeStrategy(feeStrategy).getBuyFee(1e4);
    uint256 sellFee = IGsmFeeStrategy(feeStrategy).getSellFee(1e4);

    vm.startPrank(GhoXLayer.RISK_COUNCIL);
    IGsmSteward(proposal.GHO_GSM_STEWARD()).updateGsmBuySellFees(address(gsm), buyFee + 1, sellFee);
    address newStrategy = gsm.getFeeStrategy();
    uint256 newBuyFee = IGsmFeeStrategy(newStrategy).getBuyFee(1e4);
    assertEq(newBuyFee, buyFee + 1, 'buy fee not updated by GhoGsmSteward');
  }

  function _checkRolesConfig(IGsm gsm) internal view {
    // DAO permissions
    assertTrue(gsm.hasRole(bytes32(0), GovernanceV3XLayer.EXECUTOR_LVL_1), 'Executor is not admin');
    assertTrue(
      gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), GovernanceV3XLayer.EXECUTOR_LVL_1),
      'Executor is not swap freezer'
    );
    assertTrue(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GovernanceV3XLayer.EXECUTOR_LVL_1),
      'Executor is not configurator'
    );
    // No need to be liquidator or token rescuer at the beginning
    assertFalse(
      gsm.hasRole(gsm.LIQUIDATOR_ROLE(), GovernanceV3XLayer.EXECUTOR_LVL_1),
      'Executor should not have LIQUIDATOR_ROLE'
    );
    assertFalse(
      gsm.hasRole(gsm.TOKEN_RESCUER_ROLE(), GovernanceV3XLayer.EXECUTOR_LVL_1),
      'Executor should not have TOKEN_RESCUER_ROLE'
    );

    // GHO Steward
    assertTrue(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), proposal.GHO_GSM_STEWARD()),
      'Gho Steward not configured'
    );

    // Risk Council can update draw limit
    assertTrue(
      IGhoReserve(address(proposal.GHO_RESERVE())).hasRole(
        IGhoReserve(address(proposal.GHO_RESERVE())).LIMIT_MANAGER_ROLE(),
        GhoXLayer.RISK_COUNCIL
      ),
      'Limit manager role not granted to RiskCouncil'
    );
  }

  /// @dev Asserts the four roles this payload grants are NOT held pre-execution, so the post-state
  /// role checks in `_checkRolesConfig` guard against a dropped grantRole (rather than passing
  /// vacuously against a pre-authorized redeploy).
  function _assertPayloadGrantedRolesUngranted(IGsm gsm) internal view {
    bytes32 swapFreezerRole = gsm.SWAP_FREEZER_ROLE();
    assertFalse(
      gsm.hasRole(swapFreezerRole, proposal.USDG_ORACLE_SWAP_FREEZER()),
      'pre: swap freezer role should not be granted to the oracle swap freezer'
    );
    assertFalse(
      gsm.hasRole(swapFreezerRole, GovernanceV3XLayer.EXECUTOR_LVL_1),
      'pre: swap freezer role should not be granted to the executor'
    );
    assertFalse(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), proposal.GHO_GSM_STEWARD()),
      'pre: configurator role should not be granted to the gho gsm steward'
    );
    IGhoReserve reserve = IGhoReserve(address(proposal.GHO_RESERVE()));
    assertFalse(
      reserve.hasRole(reserve.LIMIT_MANAGER_ROLE(), GhoXLayer.RISK_COUNCIL),
      'pre: limit manager role should not be granted to the risk council'
    );
  }

  function _mockAssetPrice(address priceOracle, address asset, uint256 price) internal {
    vm.mockCall(
      priceOracle,
      abi.encodeWithSelector(IAaveOracle.getAssetPrice.selector, asset),
      abi.encode(price)
    );
  }

  // Helper struct to bundle parameters and prevent stack-too-deep.
  struct GsmConfig {
    uint256 sellFee;
    uint256 buyFee;
    uint256 exposureCap;
    bool isFrozen;
    bool isSeized;
    bool freezerCanUnfreeze;
    uint256 freezeLowerBound;
    uint256 freezeUpperBound;
    uint256 unfreezeLowerBound;
    uint256 unfreezeUpperBound;
    address feeStrategy;
  }

  function _checkGsmConfig(
    IGsm gsm,
    address underlying,
    IOracleSwapFreezer freezer,
    GsmConfig memory config
  ) internal view {
    assertEq(gsm.UNDERLYING_ASSET(), underlying, 'wrong underlying asset');
    assertEq(gsm.getAvailableUnderlyingExposure(), config.exposureCap, 'wrong exposure cap');
    assertEq(gsm.getIsFrozen(), config.isFrozen, 'wrong freeze state');
    assertEq(gsm.getIsSeized(), config.isSeized, 'wrong seized state');

    // Fee Strategy
    assertEq(gsm.getFeeStrategy(), config.feeStrategy, 'wrong fee strategy address');
    IGsmFeeStrategy feeStrategy = IGsmFeeStrategy(gsm.getFeeStrategy());
    assertEq(feeStrategy.getSellFee(10000), config.sellFee, 'wrong sell fee');
    assertEq(feeStrategy.getBuyFee(10000), config.buyFee, 'wrong buy fee');

    // Price Strategy
    IFixedPriceStrategy4626 priceStrategy = IFixedPriceStrategy4626(gsm.PRICE_STRATEGY());
    assertEq(
      IERC4626(underlying).previewMint(1e6) * 10 ** 12,
      priceStrategy.getAssetPriceInGho(1e6, true),
      'asset price in GHO does not match preview'
    );
    assertEq(
      IERC4626(underlying).previewWithdraw(1 ether) / 10 ** 12,
      priceStrategy.getGhoPriceInAsset(1 ether, false),
      'GHO price in asset does not match preview'
    );

    assertEq(
      gsm.getGhoTreasury(),
      address(AaveV3XLayer.COLLECTOR),
      'GhoTreasury should be AaveV3XLayer.COLLECTOR'
    );

    // Oracle freezer
    assertEq(freezer.getCanUnfreeze(), config.freezerCanUnfreeze, 'wrong freezer config');
    (uint256 lowerBound, uint256 upperBound) = freezer.getFreezeBound();
    assertEq(lowerBound, config.freezeLowerBound, 'wrong freeze lower bound');
    assertEq(upperBound, config.freezeUpperBound, 'wrong freeze upper bound');
    (lowerBound, upperBound) = freezer.getUnfreezeBound();
    assertEq(lowerBound, config.unfreezeLowerBound, 'wrong unfreeze lower bound');
    assertEq(upperBound, config.unfreezeUpperBound, 'wrong unfreeze upper bound');

    assertEq(
      freezer.ADDRESS_PROVIDER(),
      address(AaveV3XLayer.POOL_ADDRESSES_PROVIDER),
      'freezer address provider mismatch'
    );
    assertEq(freezer.GSM(), address(gsm), 'freezer GSM mismatch');
  }
}
