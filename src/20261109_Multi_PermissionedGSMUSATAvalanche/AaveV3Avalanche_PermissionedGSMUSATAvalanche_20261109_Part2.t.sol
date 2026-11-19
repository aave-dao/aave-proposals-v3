// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {stdError} from 'forge-std/StdError.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import {IExecutor} from 'aave-address-book/governance-v3/IExecutor.sol';
import {Errors} from 'aave-address-book/governance-v3/Errors.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {GhoAvalanche} from 'aave-address-book/GhoAvalanche.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {ProxyHelpers} from 'aave-v3-origin-tests/utils/ProxyHelpers.sol';
import {IUpgradeableBurnMintTokenPool} from 'src/interfaces/ccip/IUpgradeableBurnMintTokenPool.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IGsmSteward} from 'src/interfaces/IGsmSteward.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IPermissionedGsm} from 'src/interfaces/IPermissionedGsm.sol';
import {IFixedPriceStrategy4626} from 'src/interfaces/IFixedPriceStrategy4626.sol';

import {AaveV4Avalanche_OnboardUSATCoreHub_20261028} from '../20261028_AaveV4Avalanche_OnboardUSATCoreHub/AaveV4Avalanche_OnboardUSATCoreHub_20261028.sol';
import {AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1} from './AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1.sol';
import {AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2} from './AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2.sol';
import {PermissionedGSMUSATAvalancheSetup as Setup} from './setup/PermissionedGSMUSATAvalancheSetup.sol';
import {AvalancheCcipDelivery} from './setup/AvalancheCcipDelivery.sol';
import {SupportedChainsCheck} from './setup/SupportedChainsCheck.sol';

/**
 * @dev Test for AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261109_Multi_PermissionedGSMUSATAvalanche/AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2.t.sol -vv
 *
 * setUp executes the USAT onboarding payload (AaveV4Avalanche_OnboardUSATCoreHub_20261028) first,
 * because this AIP depends on it. It lists waCoreUSAT on the Core Hub.
 */
contract AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2_Test is
  ProtocolV3TestBase,
  AvalancheCcipDelivery,
  SupportedChainsCheck
{
  uint256 internal constant FORK_BLOCK = 99954000;
  // waCoreUSAT shares, 6 decimals (TokenizationSpoke decimals = underlying decimals); set at GSM deployment
  uint128 internal constant GSM_EXPOSURE_CAP = 20_000_000e6;
  // Aave V4 TokenizationSpoke for USAT
  // https://snowscan.xyz/address/0x653F2541E7d51a846e92fA6F7866bA92e465a379
  address internal constant WA_CORE_USAT = 0x653F2541E7d51a846e92fA6F7866bA92e465a379;
  // FixedPriceStrategy4626, ratio 1e18
  // https://snowscan.xyz/address/0x863F2106C5543266b43991Fe842551B0E30FBF0d
  address internal constant PRICE_STRATEGY = 0x863F2106C5543266b43991Fe842551B0E30FBF0d;
  // https://snowscan.xyz/address/0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b
  address internal constant USAT = 0x9A5926fd88F747c357738b1e82aFB46AB80f0A6b;
  // Largest USAT holder on Avalanche (EOA, 3 USAT on 2026-11-13), the source of the swap funds
  // https://snowscan.xyz/address/0x3e4C6460aa00c11C81e3C5b95b15d612F5F2d9C7
  address internal constant USAT_HOLDER = 0x3e4C6460aa00c11C81e3C5b95b15d612F5F2d9C7;
  // USAT 6 decimals -> GHO 18 decimals, FixedPriceStrategy4626 price ratio 1e18
  uint256 internal constant USAT_TO_GHO_SCALE = 1e12;

  AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1 internal part1;
  AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2 internal proposal;
  IUpgradeableBurnMintTokenPool internal pool =
    IUpgradeableBurnMintTokenPool(GhoAvalanche.GHO_CCIP_TOKEN_POOL);
  IPermissionedGsm internal gsm;
  uint256 internal preDeliveryState;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), FORK_BLOCK);
    executePayload(vm, address(new AaveV4Avalanche_OnboardUSATCoreHub_20261028()));

    part1 = new AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part1();
    proposal = new AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2();
    gsm = proposal.GSM_USAT();

    executePayload(vm, address(part1));
    vm.warp(block.timestamp + 1); // inbound bucket refill
    preDeliveryState = vm.snapshotState();
    _deliverToAvalancheCollector(Setup.GHO_BRIDGE_AMOUNT);
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Avalanche_PermissionedGSMUSATAvalanche_20261109_Part2',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
  }

  /// @dev Part 2 reverts while the bridged GHO has not reached the Collector
  function test_executionFailsNoFunds() public {
    vm.revertToState(preDeliveryState);
    assertLt(
      IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(address(AaveV3Avalanche.COLLECTOR)),
      Setup.GHO_BRIDGE_AMOUNT
    );

    address reserve = address(proposal.GHO_RESERVE());
    IERC20 gho = IERC20(GhoAvalanche.GHO_TOKEN);

    // The GHO transfer out of the Collector underflows
    vm.prank(GovernanceV3Avalanche.EXECUTOR_LVL_1);
    vm.expectRevert(stdError.arithmeticError);
    AaveV3Avalanche.COLLECTOR.transfer(gho, reserve, Setup.GHO_BRIDGE_AMOUNT);

    // The executor reverts every failed action with '29' and hides the cause.
    // expectCall only checks that execution reaches the Collector transfer.
    vm.expectCall(
      address(AaveV3Avalanche.COLLECTOR),
      abi.encodeCall(AaveV3Avalanche.COLLECTOR.transfer, (gho, reserve, Setup.GHO_BRIDGE_AMOUNT))
    );
    vm.prank(address(GovernanceV3Avalanche.PAYLOADS_CONTROLLER));
    vm.expectRevert(bytes(Errors.FAILED_ACTION_EXECUTION));
    IExecutor(GovernanceV3Avalanche.EXECUTOR_LVL_1).executeTransaction(
      address(proposal),
      0,
      'execute()',
      '',
      true
    );
  }

  function test_reserveFunded() public {
    address reserve = address(proposal.GHO_RESERVE());
    uint256 collectorBefore = IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(
      address(AaveV3Avalanche.COLLECTOR)
    );
    uint256 reserveBefore = IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(reserve);

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(address(AaveV3Avalanche.COLLECTOR)),
      collectorBefore - Setup.GHO_BRIDGE_AMOUNT
    );
    assertEq(
      IERC20(GhoAvalanche.GHO_TOKEN).balanceOf(reserve),
      reserveBefore + Setup.GHO_BRIDGE_AMOUNT
    );
  }

  function test_gsmConfig() public {
    assertFalse(proposal.GHO_RESERVE().isEntity(address(gsm)), 'pre: GSM is no reserve entity');
    assertEq(proposal.GHO_RESERVE().getLimit(address(gsm)), 0, 'pre: GSM has no reserve limit');

    executePayload(vm, address(proposal));

    assertEq(gsm.getGhoReserve(), address(proposal.GHO_RESERVE()));
    assertTrue(proposal.GHO_RESERVE().isEntity(address(gsm)));
    assertEq(proposal.GHO_RESERVE().getLimit(address(gsm)), 25_000_000e18);
    assertEq(gsm.getExposureCap(), GSM_EXPOSURE_CAP);
    assertEq(gsm.getFeeStrategy(), address(0), 'fees are 0/0, no strategy');
    assertEq(gsm.GHO_TOKEN(), GhoAvalanche.GHO_TOKEN);
    assertFalse(gsm.getIsFrozen());
    assertFalse(gsm.getIsSeized());
    assertFalse(gsm.getIsBuyAccessOpen());
    assertFalse(gsm.getIsSellAccessOpen());
  }

  function test_roles() public {
    IAccessControl reserve = IAccessControl(address(proposal.GHO_RESERVE()));
    bytes32 limitManager = proposal.GHO_RESERVE().LIMIT_MANAGER_ROLE();
    assertFalse(reserve.hasRole(limitManager, GhoAvalanche.RISK_COUNCIL));
    assertFalse(gsm.hasRole(gsm.CONFIGURATOR_ROLE(), proposal.GHO_GSM_STEWARD()));
    assertFalse(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1));
    assertFalse(gsm.hasRole(gsm.SWAP_ACCESS_MANAGER_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1));
    assertFalse(gsm.hasRole(gsm.SWAP_ACCESS_MANAGER_ROLE(), GhoAvalanche.RISK_COUNCIL));
    assertFalse(gsm.hasRole(gsm.BUY_ASSET_ROLE(), MiscAvalanche.AFC_SAFE));
    assertFalse(gsm.hasRole(gsm.SELL_ASSET_ROLE(), MiscAvalanche.AFC_SAFE));

    executePayload(vm, address(proposal));

    assertTrue(
      reserve.hasRole(proposal.GHO_RESERVE().LIMIT_MANAGER_ROLE(), GhoAvalanche.RISK_COUNCIL)
    );

    assertTrue(gsm.hasRole(gsm.CONFIGURATOR_ROLE(), proposal.GHO_GSM_STEWARD()));
    assertTrue(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1));
    assertTrue(gsm.hasRole(gsm.SWAP_ACCESS_MANAGER_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1));
    assertTrue(gsm.hasRole(gsm.SWAP_ACCESS_MANAGER_ROLE(), GhoAvalanche.RISK_COUNCIL));

    assertTrue(gsm.hasRole(gsm.BUY_ASSET_ROLE(), MiscAvalanche.AFC_SAFE));
    assertTrue(gsm.hasRole(gsm.SELL_ASSET_ROLE(), MiscAvalanche.AFC_SAFE));
  }

  /// @dev Seizure and token rescue need a later AIP that grants these roles first
  function test_executorHasNoLiquidatorOrRescuerRole() public {
    executePayload(vm, address(proposal));

    assertFalse(gsm.hasRole(gsm.LIQUIDATOR_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1));
    assertFalse(gsm.hasRole(gsm.TOKEN_RESCUER_ROLE(), GovernanceV3Avalanche.EXECUTOR_LVL_1));
  }

  /// @dev Price strategy output against waCoreUSAT's own ERC4626 previews
  function test_priceStrategyMatchesWaCoreUsat() public view {
    IFixedPriceStrategy4626 priceStrategy = IFixedPriceStrategy4626(gsm.PRICE_STRATEGY());
    IERC4626 waCoreUsat = IERC4626(WA_CORE_USAT);
    assertEq(
      priceStrategy.getAssetPriceInGho(1e6, true),
      waCoreUsat.previewMint(1e6) * USAT_TO_GHO_SCALE
    );
    assertEq(
      priceStrategy.getGhoPriceInAsset(1 ether, false),
      waCoreUsat.convertToShares(1 ether / USAT_TO_GHO_SCALE)
    );
  }

  /// @dev The GSM is deployed already pointing at the reserve with the 20M cap; the payload does not set them
  function test_deploymentState() public view {
    assertEq(gsm.UNDERLYING_ASSET(), WA_CORE_USAT);
    assertEq(gsm.PRICE_STRATEGY(), PRICE_STRATEGY);
    assertEq(gsm.getGhoReserve(), address(proposal.GHO_RESERVE()));
    assertEq(gsm.getExposureCap(), GSM_EXPOSURE_CAP);
    assertEq(gsm.getFeeStrategy(), address(0));
    assertEq(gsm.getGhoTreasury(), address(AaveV3Avalanche.COLLECTOR));
    assertEq(
      Ownable(ProxyHelpers.getOzV5ProxyAdminAddress(address(gsm))).owner(),
      GovernanceV3Avalanche.EXECUTOR_LVL_1
    );
    assertEq(
      Ownable(ProxyHelpers.getOzV5ProxyAdminAddress(address(proposal.GHO_RESERVE()))).owner(),
      GovernanceV3Avalanche.EXECUTOR_LVL_1
    );
    assertTrue(gsm.hasRole(bytes32(0), GovernanceV3Avalanche.EXECUTOR_LVL_1));
    assertTrue(
      IAccessControl(address(proposal.GHO_RESERVE())).hasRole(
        bytes32(0),
        GovernanceV3Avalanche.EXECUTOR_LVL_1
      )
    );
    assertEq(Ownable(proposal.GSM_REGISTRY()).owner(), GovernanceV3Avalanche.EXECUTOR_LVL_1);
  }

  function test_gsmIsRegisteredUnderGsmRegistry() public {
    IGsmRegistry registry = IGsmRegistry(proposal.GSM_REGISTRY());

    assertEq(registry.getGsmListLength(), 0);

    vm.expectRevert('INVALID_INDEX');
    registry.getGsmAtIndex(0);

    executePayload(vm, address(proposal));

    assertEq(registry.getGsmListLength(), 1);
    assertEq(registry.getGsmAtIndex(0), address(gsm));
  }

  /// @dev With no fee strategy, the steward cannot set fees; governance must call updateFeeStrategy first
  function test_stewardCannotSetFeesWithoutStrategy() public {
    executePayload(vm, address(proposal));

    IGsmSteward steward = IGsmSteward(proposal.GHO_GSM_STEWARD());
    vm.prank(GhoAvalanche.RISK_COUNCIL);
    vm.expectRevert(bytes('FIXED_FEE_STRATEGY_NOT_FOUND'));
    steward.updateGsmBuySellFees(address(gsm), 10, 0);
  }

  /// @dev Funded from real state: a USAT holder's balance, deposited into waCoreUSAT by the safe
  function test_permissionedSwap() public {
    executePayload(vm, address(proposal));

    address safe = MiscAvalanche.AFC_SAFE;
    IERC20 usat = IERC20(USAT);
    IERC4626 waCoreUsat = IERC4626(WA_CORE_USAT);
    IERC20 gho = IERC20(GhoAvalanche.GHO_TOKEN);

    uint256 usatAmount = usat.balanceOf(USAT_HOLDER);
    assertGt(usatAmount, 0, 'USAT_HOLDER has no USAT at FORK_BLOCK');
    vm.prank(USAT_HOLDER);
    usat.transfer(safe, usatAmount);

    vm.startPrank(safe);
    usat.approve(WA_CORE_USAT, usatAmount);
    uint256 shares = waCoreUsat.deposit(usatAmount, safe);
    uint256 expectedGho = waCoreUsat.convertToAssets(shares) * USAT_TO_GHO_SCALE;

    waCoreUsat.approve(address(gsm), shares);
    (, uint256 ghoBought) = gsm.sellAsset(shares, safe);
    assertEq(ghoBought, expectedGho);
    assertEq(gho.balanceOf(safe), expectedGho);
    assertEq(proposal.GHO_RESERVE().getUsed(address(gsm)), expectedGho);

    // The buy rounds against the buyer (Gsm._calculateGhoAmountForBuyAsset, FixedPriceStrategy4626
    // previewMint, ceil) and the reserve restores at most what it used, so the GHO from the sell buys
    // back the shares that `expectedGho` covers: convertToShares floors, as getGhoPriceInAsset(_, false)
    uint256 buyShares = waCoreUsat.convertToShares(expectedGho / USAT_TO_GHO_SCALE);
    uint256 buyCost = waCoreUsat.previewMint(buyShares) * USAT_TO_GHO_SCALE;
    assertLe(buyCost, expectedGho, 'the sell proceeds cover the buy');
    assertApproxEqAbs(buyShares, shares, 1, 'round trip loses at most one share unit');

    gho.approve(address(gsm), buyCost);
    (uint256 assetBought, uint256 ghoSold) = gsm.buyAsset(buyShares, safe);
    vm.stopPrank();

    assertEq(assetBought, buyShares);
    assertEq(ghoSold, buyCost);
    assertEq(gho.balanceOf(safe), expectedGho - buyCost);
    assertEq(IERC20(WA_CORE_USAT).balanceOf(safe), buyShares);
    assertEq(proposal.GHO_RESERVE().getUsed(address(gsm)), expectedGho - buyCost);
  }

  /// @dev The role check runs before any token transfer, so the stranger needs no funds
  function test_unapprovedCallerCannotSwap() public {
    executePayload(vm, address(proposal));

    address stranger = makeAddr('stranger');
    bytes32 sellRole = gsm.SELL_ASSET_ROLE();
    bytes32 buyRole = gsm.BUY_ASSET_ROLE();

    vm.startPrank(stranger);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        stranger,
        sellRole
      )
    );
    gsm.sellAsset(1, stranger);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        stranger,
        buyRole
      )
    );
    gsm.buyAsset(1, stranger);
    vm.stopPrank();
  }

  function test_riskCouncilManagesAccess() public {
    executePayload(vm, address(proposal));

    address newCounterparty = makeAddr('newCounterparty');
    vm.startPrank(GhoAvalanche.RISK_COUNCIL);
    gsm.grantRole(gsm.SELL_ASSET_ROLE(), newCounterparty);
    gsm.revokeRole(gsm.BUY_ASSET_ROLE(), MiscAvalanche.AFC_SAFE);
    gsm.setBuyAccessOpen(true);
    gsm.setSellAccessOpen(true);
    vm.stopPrank();

    assertTrue(gsm.hasRole(gsm.SELL_ASSET_ROLE(), newCounterparty));
    assertFalse(gsm.hasRole(gsm.BUY_ASSET_ROLE(), MiscAvalanche.AFC_SAFE));
    assertTrue(gsm.getIsBuyAccessOpen());
    assertTrue(gsm.getIsSellAccessOpen());
  }

  function test_stewardUpdatesExposureCap() public {
    executePayload(vm, address(proposal));

    uint128 newCap = GSM_EXPOSURE_CAP * 2;
    IGsmSteward steward = IGsmSteward(proposal.GHO_GSM_STEWARD());
    vm.prank(GhoAvalanche.RISK_COUNCIL);
    steward.updateGsmExposureCap(address(gsm), newCap);
    assertEq(gsm.getExposureCap(), newCap);
  }

  function test_bridgeLaneRestored() public {
    assertEq(
      pool.getCurrentInboundRateLimiterState(CCIPChainSelectors.ETHEREUM).capacity,
      Setup.TEMP_BRIDGE_CAPACITY,
      'pre: Part 1 widened the inbound lane'
    );

    executePayload(vm, address(proposal));

    _assertDefault(pool.getCurrentInboundRateLimiterState(CCIPChainSelectors.ETHEREUM));
    _assertDefault(pool.getCurrentOutboundRateLimiterState(CCIPChainSelectors.ETHEREUM));
  }

  /// @dev Only the widened lane is restored; every other lane keeps its config
  function test_otherLanesUntouched() public {
    bytes32 before = _laneConfigHash(
      GhoAvalanche.GHO_CCIP_TOKEN_POOL,
      CCIPChainSelectors.AVALANCHE,
      CCIPChainSelectors.ETHEREUM
    );

    executePayload(vm, address(proposal));

    assertEq(
      _laneConfigHash(
        GhoAvalanche.GHO_CCIP_TOKEN_POOL,
        CCIPChainSelectors.AVALANCHE,
        CCIPChainSelectors.ETHEREUM
      ),
      before
    );
  }

  function test_supportedChainsMatchLibrary() public view {
    _assertSupportedChainsMatchLibrary(
      GhoAvalanche.GHO_CCIP_TOKEN_POOL,
      CCIPChainSelectors.AVALANCHE
    );
  }
}
