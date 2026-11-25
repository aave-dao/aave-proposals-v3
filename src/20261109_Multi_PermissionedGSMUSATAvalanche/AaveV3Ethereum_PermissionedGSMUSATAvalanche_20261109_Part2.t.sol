// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {IExecutor} from 'aave-address-book/governance-v3/IExecutor.sol';
import {Errors} from 'aave-address-book/governance-v3/Errors.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {GhoAvalanche} from 'aave-address-book/GhoAvalanche.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IAaveGhoCcipBridge} from 'aave-helpers/src/bridges/ccip/interfaces/IAaveGhoCcipBridge.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IUpgradeableLockReleaseTokenPool} from 'src/interfaces/ccip/IUpgradeableLockReleaseTokenPool.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGhoDirectFacilitator} from 'src/interfaces/IGhoDirectFacilitator.sol';

import {AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1} from './AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1.sol';
import {AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2} from './AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2.sol';
import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';
import {EXPECTED_TEMP_BRIDGE_CAPACITY} from './setup/PermissionedGSMUSATAvalancheExpected.sol';
import {SupportedChainsCheck} from 'src/helpers/gho-launch/tests/utils/SupportedChainsCheck.sol';

/**
 * @dev Test for AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2.t.sol -vv
 */
contract AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2_Test is
  ProtocolV3TestBase,
  SupportedChainsCheck
{
  AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1 internal part1;
  AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2 internal proposal;
  // GhoDirectFacilitator registered for the Monad remote GSM (aave-proposals-v3 PR 1158)
  // https://etherscan.io/address/0x0cB7C2A2Ab38Aed3e6096631D7Dba3DaBf237134
  address internal constant MONAD_DIRECT_FACILITATOR = 0x0cB7C2A2Ab38Aed3e6096631D7Dba3DaBf237134;
  // https://etherscan.io/tx/0x5fc812349332acdbdf85a27051dd44b50923e1d81e93e69dac332ea399c9db1f
  address internal constant DIRECT_FACILITATOR_DEPLOYER =
    0x0000087348027Bb9826303C9519781e1AfFA7994;
  uint256 internal constant EXPECTED_BRIDGE_GAS_LIMIT = 750_000;
  uint256 internal constant EXPECTED_FACILITATOR_CAPACITY = 65_000_000 ether;
  string internal constant EXPECTED_FACILITATOR_LABEL = 'GhoDirectFacilitator GSM Avalanche';

  IUpgradeableLockReleaseTokenPool internal pool =
    IUpgradeableLockReleaseTokenPool(GhoEthereum.GHO_CCIP_TOKEN_POOL);
  uint256 internal prePart1State;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26405330);
    part1 = new AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part1();
    proposal = new AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2();

    prePart1State = vm.snapshotState();
    executePayload(vm, address(part1));
    vm.warp(block.timestamp + 1); // outbound bucket refill
  }

  /// @dev Part 2 reverts while Part 1 has not widened the outbound lane
  function test_executionFailsWithoutPart1() public {
    vm.revertToState(prePart1State);
    assertLt(
      pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.AVALANCHE).capacity,
      Setup.GHO_BRIDGE_AMOUNT
    );

    // The executor reverts every failed action with '29' and hides the cause.
    // expectCall only checks that execution reaches the bridge send.
    vm.expectCall(
      GhoEthereum.GHO_CCIP_BRIDGE,
      abi.encodeCall(
        IAaveGhoCcipBridge.send,
        (
          CCIPChainSelectors.AVALANCHE,
          Setup.GHO_BRIDGE_AMOUNT,
          AaveV3EthereumAssets.LINK_UNDERLYING
        )
      )
    );
    vm.prank(address(GovernanceV3Ethereum.PAYLOADS_CONTROLLER));
    vm.expectRevert(bytes(Errors.FAILED_ACTION_EXECUTION));
    IExecutor(GovernanceV3Ethereum.EXECUTOR_LVL_1).executeTransaction(
      address(proposal),
      0,
      'execute()',
      '',
      true
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_PermissionedGSMUSATAvalanche_20261109_Part2',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_directFacilitatorDeployment() public {
    IGhoDirectFacilitator facilitator = IGhoDirectFacilitator(proposal.DIRECT_FACILITATOR());
    assertTrue(facilitator.hasRole(bytes32(0), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertTrue(facilitator.hasRole(facilitator.MINTER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertTrue(facilitator.hasRole(facilitator.BURNER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertEq(
      address(facilitator).codehash,
      MONAD_DIRECT_FACILITATOR.codehash,
      'bytecode differs from the governance-registered Monad facilitator'
    );
  }

  function test_directFacilitatorDeployerHasNoRoles() public view {
    IGhoDirectFacilitator facilitator = IGhoDirectFacilitator(proposal.DIRECT_FACILITATOR());
    assertFalse(facilitator.hasRole(bytes32(0), DIRECT_FACILITATOR_DEPLOYER));
    assertFalse(facilitator.hasRole(facilitator.MINTER_ROLE(), DIRECT_FACILITATOR_DEPLOYER));
    assertFalse(facilitator.hasRole(facilitator.BURNER_ROLE(), DIRECT_FACILITATOR_DEPLOYER));
  }

  function test_ccipBridgeIdentity() public view {
    IAaveGhoCcipBridge bridge = IAaveGhoCcipBridge(GhoEthereum.GHO_CCIP_BRIDGE);
    assertEq(bridge.GHO_TOKEN(), AaveV3EthereumAssets.GHO_UNDERLYING);
    assertEq(bridge.COLLECTOR(), address(AaveV3Ethereum.COLLECTOR));
    assertEq(bridge.ROUTER(), pool.getRouter());
    assertEq(pool.getToken(), AaveV3EthereumAssets.GHO_UNDERLYING);
  }

  /// @dev The fee is paid from the bridge's own LINK balance; the payload sends none
  function test_bridgeLinkCoversFee() public {
    IAaveGhoCcipBridge bridge = IAaveGhoCcipBridge(GhoEthereum.GHO_CCIP_BRIDGE);
    uint32 gasLimit = proposal.AVALANCHE_BRIDGE_GAS_LIMIT();
    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    bridge.setDestinationChain({
      chainSelector: CCIPChainSelectors.AVALANCHE,
      destination: abi.encode(GhoAvalanche.GHO_CCIP_BRIDGE),
      extraArgs: bytes(''),
      gasLimit: gasLimit
    });

    uint256 fee = bridge.quoteBridge(
      CCIPChainSelectors.AVALANCHE,
      Setup.GHO_BRIDGE_AMOUNT,
      AaveV3EthereumAssets.LINK_UNDERLYING
    );
    uint256 linkBalance = IERC20(AaveV3EthereumAssets.LINK_UNDERLYING).balanceOf(address(bridge));
    emit log_named_decimal_uint('CCIP fee (LINK)', fee, 18);
    emit log_named_decimal_uint('bridge LINK balance', linkBalance, 18);
    assertGe(linkBalance, fee, 'bridge LINK balance below the CCIP fee');
  }

  function test_ccipBridgeDestinationChainSetUp() public {
    IAaveGhoCcipBridge bridge = IAaveGhoCcipBridge(GhoEthereum.GHO_CCIP_BRIDGE);
    assertEq(
      bridge.getDestinationRemoteConfig(CCIPChainSelectors.AVALANCHE).destination,
      new bytes(0),
      'pre: Avalanche destination unset'
    );

    executePayload(vm, address(proposal));

    IAaveGhoCcipBridge.RemoteChainConfig memory config = bridge.getDestinationRemoteConfig(
      CCIPChainSelectors.AVALANCHE
    );
    assertEq(config.destination, abi.encode(GhoAvalanche.GHO_CCIP_BRIDGE));
    assertEq(config.extraArgsOverride, new bytes(0));
    assertEq(config.gasLimit, EXPECTED_BRIDGE_GAS_LIMIT);
  }

  function test_bridge() public {
    IGhoToken gho = IGhoToken(AaveV3EthereumAssets.GHO_UNDERLYING);
    assertEq(gho.getFacilitator(proposal.DIRECT_FACILITATOR()).bucketCapacity, 0);
    uint256 poolGhoBefore = IERC20(address(gho)).balanceOf(GhoEthereum.GHO_CCIP_TOKEN_POOL);

    vm.expectEmit(false, true, true, true, GhoEthereum.GHO_CCIP_BRIDGE);
    emit IAaveGhoCcipBridge.BridgeMessageInitiated(
      bytes32(0),
      CCIPChainSelectors.AVALANCHE,
      GovernanceV3Ethereum.EXECUTOR_LVL_1,
      Setup.GHO_BRIDGE_AMOUNT
    );

    executePayload(vm, address(proposal));

    IGhoToken.Facilitator memory facilitator = gho.getFacilitator(proposal.DIRECT_FACILITATOR());
    assertEq(facilitator.bucketCapacity, EXPECTED_FACILITATOR_CAPACITY);
    assertEq(facilitator.bucketLevel, Setup.GHO_BRIDGE_AMOUNT);
    assertEq(facilitator.label, EXPECTED_FACILITATOR_LABEL);
    assertEq(
      IERC20(address(gho)).balanceOf(GhoEthereum.GHO_CCIP_TOKEN_POOL),
      poolGhoBefore + Setup.GHO_BRIDGE_AMOUNT,
      'GHO not locked in the token pool'
    );
    assertEq(IERC20(address(gho)).balanceOf(GovernanceV3Ethereum.EXECUTOR_LVL_1), 0);
    assertEq(
      IERC20(address(gho)).allowance(
        GovernanceV3Ethereum.EXECUTOR_LVL_1,
        GhoEthereum.GHO_CCIP_BRIDGE
      ),
      0
    );
  }

  function test_bridgeLaneRestored() public {
    assertEq(
      pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.AVALANCHE).capacity,
      EXPECTED_TEMP_BRIDGE_CAPACITY,
      'pre: Part 1 widened the outbound lane'
    );

    executePayload(vm, address(proposal));

    _assertRateLimiterConfig(
      pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.AVALANCHE),
      true,
      Setup.DEFAULT_RATE_LIMITER_CAPACITY,
      Setup.DEFAULT_LIMITER_RATE
    );
    _assertRateLimiterConfig(
      pool.getCurrentInboundRateLimiterState(CCIPChainSelectors.AVALANCHE),
      true,
      Setup.DEFAULT_RATE_LIMITER_CAPACITY,
      Setup.DEFAULT_LIMITER_RATE
    );
  }

  /// @dev Only the widened lane is restored; every other lane keeps its config
  function test_otherLanesUntouched() public {
    bytes32 before = _laneConfigHash(
      GhoEthereum.GHO_CCIP_TOKEN_POOL,
      CCIPChainSelectors.ETHEREUM,
      CCIPChainSelectors.AVALANCHE
    );

    executePayload(vm, address(proposal));

    assertEq(
      _laneConfigHash(
        GhoEthereum.GHO_CCIP_TOKEN_POOL,
        CCIPChainSelectors.ETHEREUM,
        CCIPChainSelectors.AVALANCHE
      ),
      before
    );
  }

  function test_supportedChainsMatchLibrary() public view {
    _assertSupportedChainsMatchLibrary(
      GhoEthereum.GHO_CCIP_TOKEN_POOL,
      CCIPChainSelectors.ETHEREUM
    );
  }
}
