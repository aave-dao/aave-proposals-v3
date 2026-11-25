// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {GhoAvalanche} from 'aave-address-book/GhoAvalanche.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IUpgradeableBurnMintTokenPool, IRateLimiter} from 'src/interfaces/ccip/IUpgradeableBurnMintTokenPool.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';

import {AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1} from './AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.sol';
import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';
import {EXPECTED_BUCKET_CAPACITY} from './setup/PermissionedGsmUsatAvalancheFacilitatorProposalBaseTest.t.sol';
import {AvalancheCcipDelivery} from './setup/AvalancheCcipDelivery.sol';
import {SupportedChainsCheck} from 'src/helpers/gho-launch/tests/utils/SupportedChainsCheck.sol';

/**
 * @dev Test for AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.t.sol -vv
 */
contract AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1_Test is
  ProtocolV3TestBase,
  AvalancheCcipDelivery,
  SupportedChainsCheck
{
  uint256 internal constant FORK_BLOCK = 99954000;

  AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1 internal proposal;
  IUpgradeableBurnMintTokenPool internal pool =
    IUpgradeableBurnMintTokenPool(GhoAvalanche.GHO_CCIP_TOKEN_POOL);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), FORK_BLOCK);
    proposal = new AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
  }

  function test_bucketCapacity() public {
    (uint256 capacityBefore, uint256 levelBefore) = IGhoToken(GhoAvalanche.GHO_TOKEN)
      .getFacilitatorBucket(GhoAvalanche.GHO_CCIP_TOKEN_POOL);

    executePayload(vm, address(proposal));

    (uint256 capacityAfter, uint256 levelAfter) = IGhoToken(GhoAvalanche.GHO_TOKEN)
      .getFacilitatorBucket(GhoAvalanche.GHO_CCIP_TOKEN_POOL);
    assertEq(capacityAfter, capacityBefore + Setup.GHO_BRIDGE_AMOUNT);
    assertEq(capacityAfter, EXPECTED_BUCKET_CAPACITY);
    assertEq(levelAfter, levelBefore);
  }

  function test_inboundRateLimiter() public {
    _assertRateLimiterConfig(
      pool.getCurrentInboundRateLimiterState(CCIPChainSelectors.ETHEREUM),
      true,
      Setup.DEFAULT_RATE_LIMITER_CAPACITY,
      Setup.DEFAULT_LIMITER_RATE
    );

    executePayload(vm, address(proposal));

    IRateLimiter.TokenBucket memory bucket = pool.getCurrentInboundRateLimiterState(
      CCIPChainSelectors.ETHEREUM
    );
    assertTrue(bucket.isEnabled);
    assertEq(bucket.capacity, Setup.TEMP_BRIDGE_CAPACITY);
    assertEq(bucket.rate, Setup.TEMP_BRIDGE_RATE);
  }

  function test_outboundRateLimiterUnchanged() public {
    _assertRateLimiterConfig(
      pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.ETHEREUM),
      true,
      Setup.DEFAULT_RATE_LIMITER_CAPACITY,
      Setup.DEFAULT_LIMITER_RATE
    );

    executePayload(vm, address(proposal));

    _assertRateLimiterConfig(
      pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.ETHEREUM),
      true,
      Setup.DEFAULT_RATE_LIMITER_CAPACITY,
      Setup.DEFAULT_LIMITER_RATE
    );
  }

  function test_ccipOffRampIsRegistered() public view {
    _assertOffRampRegistered();
  }

  function test_ccipDeliveryReachesCollector() public {
    executePayload(vm, address(proposal));
    vm.warp(block.timestamp + 1); // inbound bucket refill

    uint256 collectorBefore = IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(
      address(AaveV3Avalanche.COLLECTOR)
    );
    (, uint256 levelBefore) = IGhoToken(GhoAvalanche.GHO_TOKEN).getFacilitatorBucket(
      GhoAvalanche.GHO_CCIP_TOKEN_POOL
    );

    _deliverToAvalancheCollector(Setup.GHO_BRIDGE_AMOUNT);

    assertEq(
      IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(address(AaveV3Avalanche.COLLECTOR)),
      collectorBefore + Setup.GHO_BRIDGE_AMOUNT
    );
    (, uint256 levelAfter) = IGhoToken(GhoAvalanche.GHO_TOKEN).getFacilitatorBucket(
      GhoAvalanche.GHO_CCIP_TOKEN_POOL
    );
    assertEq(levelAfter, levelBefore + Setup.GHO_BRIDGE_AMOUNT);
    assertEq(IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(GhoAvalanche.GHO_CCIP_BRIDGE), 0);
  }

  function test_ccipDeliveryRevertsWithoutPart1() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        IUpgradeableBurnMintTokenPool.TokenMaxCapacityExceeded.selector,
        Setup.DEFAULT_RATE_LIMITER_CAPACITY,
        Setup.GHO_BRIDGE_AMOUNT,
        GhoAvalanche.GHO_TOKEN
      )
    );
    _deliverToAvalancheCollector(Setup.GHO_BRIDGE_AMOUNT);
  }
}
