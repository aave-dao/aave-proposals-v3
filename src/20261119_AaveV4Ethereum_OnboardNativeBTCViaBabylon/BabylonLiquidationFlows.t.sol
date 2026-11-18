// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {IHubConfigurator} from 'aave-v4/hub/interfaces/IHubConfigurator.sol';
import {IAaveAdapter} from 'src/interfaces/babylon/IAaveAdapter.sol';
import {IBTCVaultSwap} from 'src/interfaces/babylon/IBTCVaultSwap.sol';
import {IBTCVaultRegistry} from 'src/interfaces/babylon/IBTCVaultRegistry.sol';
import {IApplicationRegistry} from 'src/interfaces/babylon/IApplicationRegistry.sol';
import {BTCVaultBasicInfo, BTCVaultProtocolInfo, TokenAmount, MarketPosition, AddressBTCKeyPair} from 'src/interfaces/babylon/BabylonTypes.sol';
import {BabylonTestBase} from './BabylonTestBase.sol';
import {BabylonMainnet} from './BabylonMainnet.sol';

/**
 * @dev Drives Babylon's deployed AaveAdapter and BTCVaultSwap against the Babylon Spoke after the
 * proposal: vault activation, borrow, repay, both liquidation paths and the arbitrage that repays
 * the Core Hub. No BTC is pegged in on the fork, so the reads and redemptions of Babylon's
 * BTCVaultRegistry and ApplicationRegistry are mocked, and Chainlink answers are mocked to move
 * prices. Everything on the Aave side and in the adapter and the swap runs as deployed.
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/BabylonLiquidationFlows.t.sol -vv
 */
contract BabylonLiquidationFlowsTest is BabylonTestBase {
  bytes32 internal constant VAULT_1 = keccak256('vault-1');
  bytes32 internal constant VAULT_2 = keccak256('vault-2');
  bytes32 internal constant CLAIMER_BTC_KEY = bytes32(uint256(7));

  // every vault in these tests holds 1 BTC
  uint256 internal constant VAULT_AMOUNT = 1e8;

  // AaveAdapter vault usage status
  uint8 internal constant VAULT_LLP_OWNED = 2;
  uint8 internal constant VAULT_REDEEMED = 3;

  // AaveAdapter pause state
  uint8 internal constant ADAPTER_ACTIVE = 0;
  uint8 internal constant ADAPTER_FROZEN = 1;
  uint8 internal constant ADAPTER_PAUSED = 2;

  IAaveAdapter internal adapter = IAaveAdapter(BABYLON_AAVE_ADAPTER);
  IBTCVaultSwap internal swap = IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE);
  address internal registry;
  address internal applicationRegistry;
  address internal liquidator = makeAddr('liquidator');
  address internal arbitrageur = makeAddr('arbitrageur');

  uint256 internal _debt;
  uint256 internal _healthFactor;
  uint256 internal _fee;
  uint256 internal _fairness;
  uint256 internal _payout;

  function setUp() public override {
    super.setUp();
    registry = adapter.BTC_VAULT_REGISTRY();
    applicationRegistry = adapter.APP_REGISTRY();
  }

  function test_activateVault_revertsBeforeTheProposal() public {
    BTCVaultBasicInfo memory info = _vaultInfo(user, VAULT_AMOUNT);
    _mockRegistryForVault(VAULT_1, info);
    vm.expectRevert(IHub.SpokeNotActive.selector);
    vm.prank(registry);
    adapter.activateVault(VAULT_1, info, '');
  }

  /// @dev Babylon keeps the AaveAdapter frozen until the proposal executes. A frozen adapter still
  /// activates and withdraws vaults and only blocks new borrows.
  function test_activateAndWithdrawWhileAdapterFrozen() public {
    _executePayload();
    assertEq(adapter.pauseState(), ADAPTER_FROZEN, 'adapter frozen');
    _activate(VAULT_1, VAULT_AMOUNT);
    address proxy = _proxy();
    assertEq(_suppliedVaultBtc(proxy), VAULT_AMOUNT, 'supplied');
    assertEq(IERC20(VAULT_BTC).totalSupply(), VAULT_AMOUNT, 'vaultBTC minted');
    (bool isCollateral, bool isBorrowing) = ISpoke(BABYLON_SPOKE).getUserReserveStatus(
      VAULT_BTC_RESERVE_ID,
      proxy
    );
    assertTrue(isCollateral, 'collateral enabled');
    assertFalse(isBorrowing, 'borrowing');

    vm.expectRevert(IAaveAdapter.TBV_Frozen.selector);
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, 1e6, user);

    _mockVaultAmounts(_one(VAULT_1), _one(VAULT_AMOUNT));
    vm.prank(user);
    adapter.withdrawCollaterals(_one(VAULT_1));
    assertEq(IERC20(VAULT_BTC).totalSupply(), 0, 'vaultBTC burned');
    assertEq(adapter.getVaultUsageStatus(VAULT_1), VAULT_REDEEMED, 'redeemed');
  }

  function test_borrowAndRepayThroughAdapter() public {
    uint256 borrowed = _openAndBorrow(70_00);
    address proxy = _proxy();
    assertEq(IERC20(USDC).balanceOf(user), borrowed, 'borrowed');
    assertGe(_usdcDebt(proxy), borrowed, 'debt');

    skip(1 days);
    deal(USDC, user, borrowed * 2);
    vm.startPrank(user);
    IERC20(USDC).approve(BABYLON_AAVE_ADAPTER, UINT256_MAX);
    adapter.repayToCorePosition(user, CORE_USDC_RESERVE_ID, borrowed * 2);
    vm.stopPrank();
    assertEq(_usdcDebt(proxy), 0, 'debt repaid');
    (, bool isBorrowing) = ISpoke(BABYLON_SPOKE).getUserReserveStatus(CORE_USDC_RESERVE_ID, proxy);
    assertFalse(isBorrowing, 'borrowing flag cleared');
  }

  function test_liquidateDirect() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    address proxy = _proxy();
    _healthFactor = ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor;
    assertLt(_healthFactor, 1e18, 'liquidatable');
    _debt = _usdcDebt(proxy);

    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    uint256 recipientBefore = IERC20(WBTC).balanceOf(adapter.applicationRecipient());
    vm.expectCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForAVK, (VAULT_1, CLAIMER_BTC_KEY))
    );
    vm.prank(liquidator);
    (bytes32 vaultId, uint256 seized) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });

    assertEq(vaultId, VAULT_1, 'vault');
    assertEq(seized, VAULT_AMOUNT, 'whole vault seized');
    _fee = IERC20(WBTC).balanceOf(adapter.applicationRecipient()) - recipientBefore;
    _fairness = IERC20(WBTC).balanceOf(user);
    assertEq(1e8 - IERC20(WBTC).balanceOf(liquidator), _fee + _fairness, 'liquidator WBTC paid');
    assertEq(_debt * 2 - IERC20(USDC).balanceOf(liquidator), _debt, 'debt repaid by liquidator');
    _assertFeeAndFairness();

    assertEq(_suppliedVaultBtc(proxy), 0, 'collateral left');
    assertEq(_usdcDebt(proxy), 0, 'debt left');
    assertEq(IERC20(VAULT_BTC).totalSupply(), 0, 'vaultBTC burned');
    assertEq(
      IHub(BABYLON_HUB).getAddedAssets(BABYLON_VAULT_BTC_ASSET_ID),
      IHub(BABYLON_HUB).getAddedShares(BABYLON_VAULT_BTC_ASSET_ID),
      'vaultBTC share price'
    );
    assertEq(IHub(CORE_HUB).getSpokeDrawnShares(CORE_USDC_ASSET_ID, BABYLON_SPOKE), 0, 'drawn');
    assertEq(IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE), 0, 'deficit');
    assertEq(adapter.getVaultUsageStatus(VAULT_1), VAULT_REDEEMED, 'redeemed');
    assertEq(adapter.getPosition(user).vaultIds.length, 0, 'vaults left');
  }

  /// @dev Babylon's queued timelock batch moves both adapter fees to a new recipient. The
  /// liquidation fee then goes there, and nothing goes to the previous recipient.
  function test_liquidateDirect_feeGoesToQueuedRecipient() public {
    address previousRecipient = adapter.applicationRecipient();
    assertEq(previousRecipient, BabylonMainnet.FEE_RECIPIENT, 'recipient before the batch');
    vm.startPrank(BABYLON_APPLICATION_TIMELOCK);
    adapter.setApplicationRecipient(BabylonMainnet.QUEUED_FEE_RECIPIENT);
    adapter.setInterestFeeRecipient(BabylonMainnet.QUEUED_FEE_RECIPIENT);
    vm.stopPrank();
    assertEq(
      adapter.applicationRecipient(),
      BabylonMainnet.QUEUED_FEE_RECIPIENT,
      'application recipient'
    );
    assertEq(
      adapter.interestFeeRecipient(),
      BabylonMainnet.QUEUED_FEE_RECIPIENT,
      'interest fee recipient'
    );

    uint256 recipientBefore = IERC20(WBTC).balanceOf(BabylonMainnet.QUEUED_FEE_RECIPIENT);
    uint256 previousBefore = IERC20(WBTC).balanceOf(previousRecipient);
    test_liquidateDirect();
    assertGt(_fee, 0, 'fee');
    assertEq(
      IERC20(WBTC).balanceOf(BabylonMainnet.QUEUED_FEE_RECIPIENT) - recipientBefore,
      _fee,
      'new recipient fee'
    );
    assertEq(IERC20(WBTC).balanceOf(previousRecipient), previousBefore, 'previous recipient');
  }

  /// @dev Babylon's freeze-only guardians can freeze the adapter and nothing else. The Aave V4
  /// Security Council lifts each freeze.
  function test_freezeOnlyGuardiansFreeze_securityCouncilUnfreezes() public {
    address[3] memory freezers = [
      BabylonMainnet.FREEZE_GUARDIAN_1,
      BabylonMainnet.FREEZE_GUARDIAN_2,
      BabylonMainnet.FREEZE_GUARDIAN_3
    ];
    assertTrue(
      adapter.hasRole(BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE, freezers[0]),
      'first freeze guardian holds the role since deployment'
    );
    // the other two are granted by Babylon's queued timelock batch
    vm.startPrank(BABYLON_APPLICATION_TIMELOCK);
    adapter.grantRole(BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE, freezers[1]);
    adapter.grantRole(BABYLON_APPLICATION_FREEZE_GUARDIAN_ROLE, freezers[2]);
    vm.stopPrank();
    _unfreezeAdapter();

    for (uint256 i; i < freezers.length; ++i) {
      assertFalse(
        adapter.hasRole(BABYLON_APPLICATION_PAUSE_GUARDIAN_ROLE, freezers[i]),
        'freeze guardian is a pause guardian'
      );
      vm.startPrank(freezers[i]);
      vm.expectRevert(IAaveAdapter.TBV_Unauthorized.selector);
      adapter.pause();
      adapter.freeze();
      assertEq(adapter.pauseState(), ADAPTER_FROZEN, 'frozen');
      vm.expectRevert(IAaveAdapter.TBV_Unauthorized.selector);
      adapter.unfreeze();
      vm.stopPrank();

      vm.prank(V4_SECURITY_COUNCIL);
      adapter.unfreeze();
      assertEq(adapter.pauseState(), ADAPTER_ACTIVE, 'unfrozen by the Security Council');
    }
  }

  /// @dev The liquidator is paid in WBTC drawn from the Core Hub credit line the proposal opens,
  /// and an arbitrageur later buys the escrowed vault and repays the Hub.
  function test_liquidateWithBtcVaultSwapAndArbitrage() public {
    uint256 liquidityBefore = IHub(CORE_HUB).getAssetLiquidity(CORE_WBTC_ASSET_ID);
    uint256 recipientBefore = IERC20(WBTC).balanceOf(adapter.applicationRecipient());
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();

    _fee = IERC20(WBTC).balanceOf(adapter.applicationRecipient()) - recipientBefore;
    _fairness = IERC20(WBTC).balanceOf(user);
    assertEq(
      IERC20(WBTC).balanceOf(liquidator) + _fee + _fairness,
      _payout,
      'payout covers the fee and the fairness payment'
    );
    assertEq(_debt * 2 - IERC20(USDC).balanceOf(liquidator), _debt, 'debt repaid by liquidator');
    _assertFeeAndFairness();

    // the swap pays 98% of the vault value, the 2% sell discount is the arbitrageur's margin
    uint256 vaultValue = (VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID)) /
      _price(BABYLON_WBTC_RESERVE_ID);
    assertApproxEqAbs(_payout, (vaultValue * 98) / 100, 3, 'payout');
    assertEq(
      liquidityBefore - IHub(CORE_HUB).getAssetLiquidity(CORE_WBTC_ASSET_ID),
      _payout,
      'core hub liquidity drawn'
    );
    assertApproxEqAbs(
      IHub(CORE_HUB).getSpokeTotalOwed(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      _payout,
      2,
      'swap debt on the core hub'
    );
    (uint128 amountVault, uint128 drawn, uint128 sharesOwed, ) = swap.vaultsInfo(VAULT_1);
    assertEq(amountVault, VAULT_AMOUNT, 'escrowed vault');
    assertEq(drawn, _payout, 'escrow drawn');
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      sharesOwed,
      'escrow shares'
    );
    assertEq(adapter.vaultOwner(VAULT_1), BABYLON_BTC_VAULT_SWAP_SPOKE, 'vault owner');
    assertEq(adapter.getVaultUsageStatus(VAULT_1), VAULT_LLP_OWNED, 'vault held by the swap');
    assertEq(_suppliedVaultBtc(_proxy()), 0, 'collateral left');

    _arbitrage();
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'repaid'
    );
    assertEq(
      IHub(CORE_HUB).getSpokeDeficitRay(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'deficit'
    );
    assertGe(
      IHub(CORE_HUB).getAssetLiquidity(CORE_WBTC_ASSET_ID),
      liquidityBefore,
      'core hub liquidity restored'
    );
    assertEq(adapter.getVaultUsageStatus(VAULT_1), VAULT_REDEEMED, 'redeemed');
  }

  function test_arbitrage_revertsWith_notVaultKeeper() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    skip(4 days);
    _mockVaultProtocolInfo(VAULT_1);
    deal(WBTC, arbitrageur, 2e8);
    vm.startPrank(arbitrageur);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    vm.expectRevert(IApplicationRegistry.UnauthorizedVaultKeeper.selector);
    swap.swapExitBtcForVault(VAULT_1, UINT256_MAX);
    vm.stopPrank();
  }

  /// @dev While BTCVaultSwap is paused nobody can buy an escrowed vault, so its Core Hub debt
  /// stays open until a guardian unpauses.
  function test_arbitrage_blockedWhileBtcVaultSwapPaused() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    skip(4 days);
    _mockVaultProtocolInfo(VAULT_1);
    AddressBTCKeyPair memory keeperPair = _vaultKeeper();
    address keeper = keeperPair.ethAddress;
    vm.mockCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForAVK, (VAULT_1, keeperPair.btcPubKey)),
      ''
    );
    deal(WBTC, keeper, 2e8);
    vm.prank(keeper);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);

    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE).pause();
    vm.expectRevert(IBTCVaultSwap.EnforcedPause.selector);
    vm.prank(keeper);
    swap.swapExitBtcForVault(VAULT_1, UINT256_MAX);
    assertGt(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'debt'
    );

    vm.prank(V4_SECURITY_COUNCIL);
    IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE).unpause();
    vm.prank(keeper);
    swap.swapExitBtcForVault(VAULT_1, UINT256_MAX);
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'repaid'
    );
  }

  /// @dev A paused AaveAdapter blocks every position action, exits included. The Aave V4 Security
  /// Council pauses, and Babylon's Interim Governance, which also holds the pause guardian role,
  /// can undo it.
  function test_adapterPaused_blocksPositionActions() public {
    uint256 borrowed = _openAndBorrow(75_00);
    address proxy = _proxy();
    vm.prank(V4_SECURITY_COUNCIL);
    adapter.pause();
    assertEq(adapter.pauseState(), ADAPTER_PAUSED, 'adapter paused');

    deal(USDC, user, borrowed * 2);
    vm.startPrank(user);
    IERC20(USDC).approve(BABYLON_AAVE_ADAPTER, UINT256_MAX);
    vm.expectRevert(IAaveAdapter.TBV_Paused.selector);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, 1e6, user);
    vm.expectRevert(IAaveAdapter.TBV_Paused.selector);
    adapter.repayToCorePosition(user, CORE_USDC_RESERVE_ID, borrowed * 2);
    vm.expectRevert(IAaveAdapter.TBV_Paused.selector);
    adapter.withdrawCollaterals(_one(VAULT_1));
    vm.stopPrank();

    _scaleBtcPrices(94_00);
    assertLt(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'liquidatable');
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    vm.startPrank(liquidator);
    vm.expectRevert(IAaveAdapter.TBV_Paused.selector);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });
    vm.expectRevert(IAaveAdapter.TBV_Paused.selector);
    adapter.liquidateWithLLP({
      borrower: user,
      llp: BABYLON_BTC_VAULT_SWAP_SPOKE,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      minPayouts: new TokenAmount[](0)
    });
    vm.stopPrank();

    vm.prank(BABYLON_INTERIM_GOVERNANCE);
    adapter.unpause();
    assertEq(adapter.pauseState(), ADAPTER_ACTIVE, 'adapter unpaused');
    vm.prank(user);
    adapter.repayToCorePosition(user, CORE_USDC_RESERVE_ID, borrowed * 2);
    assertEq(_usdcDebt(proxy), 0, 'debt repaid');
  }

  /// @dev A frozen AaveAdapter blocks new borrows only. Repayment and liquidation stay open. The
  /// Aave V4 Security Council freezes, and Babylon's Interim Governance can undo it.
  function test_adapterFrozen_blocksBorrowsOnly() public {
    _openAndBorrow(75_00);
    address proxy = _proxy();
    vm.prank(V4_SECURITY_COUNCIL);
    adapter.freeze();
    assertEq(adapter.pauseState(), ADAPTER_FROZEN, 'adapter frozen');

    vm.expectRevert(IAaveAdapter.TBV_Frozen.selector);
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, 1e6, user);

    deal(USDC, user, 1e6);
    vm.startPrank(user);
    IERC20(USDC).approve(BABYLON_AAVE_ADAPTER, UINT256_MAX);
    uint256 debtBefore = _usdcDebt(proxy);
    adapter.repayToCorePosition(user, CORE_USDC_RESERVE_ID, 1e6);
    vm.stopPrank();
    assertLt(_usdcDebt(proxy), debtBefore, 'debt repaid while frozen');

    _scaleBtcPrices(94_00);
    assertLt(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'liquidatable');
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    vm.prank(liquidator);
    (, uint256 seized) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });
    assertEq(seized, VAULT_AMOUNT, 'liquidated while frozen');
    assertEq(_usdcDebt(proxy), 0, 'debt left');

    vm.prank(BABYLON_INTERIM_GOVERNANCE);
    adapter.unfreeze();
    assertEq(adapter.pauseState(), ADAPTER_ACTIVE, 'adapter unfrozen');
  }

  /// @dev A position worth less than its debt is liquidated in full and the shortfall is reported
  /// as a deficit on the Core Hub credit line.
  function test_liquidateUnderwater() public {
    _openAndBorrow(75_00);
    address proxy = _proxy();
    _scaleBtcPrices(70_00);
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });
    assertEq(_suppliedVaultBtc(proxy), 0, 'collateral left');
    assertEq(_usdcDebt(proxy), 0, 'debt left');
    assertLt(_debt * 2 - IERC20(USDC).balanceOf(liquidator), _debt, 'liquidator repaid less');
    assertGt(IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE), 0, 'deficit');
  }

  /// @dev Vaults are seized whole and in order, so a liquidation takes the first vault only.
  function test_liquidateFirstOfTwoVaults() public {
    _executePayload();
    _activate(VAULT_1, VAULT_AMOUNT);
    _mockVaultAmounts(_one(VAULT_1), _one(VAULT_AMOUNT));
    _activate(VAULT_2, VAULT_AMOUNT);
    bytes32[] memory vaultIds = new bytes32[](2);
    vaultIds[0] = VAULT_1;
    vaultIds[1] = VAULT_2;
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = VAULT_AMOUNT;
    amounts[1] = VAULT_AMOUNT;
    _mockVaultAmounts(vaultIds, amounts);
    _mockVaultAmounts(_one(VAULT_2), _one(VAULT_AMOUNT));
    _unfreezeAdapter();

    uint256 borrowed = (2 * _price(VAULT_BTC_RESERVE_ID) * 75_00) / 10_000 / 100;
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, borrowed, user);
    _scaleBtcPrices(94_00);
    address proxy = _proxy();
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});

    // too little debt to consume the first vault
    vm.expectRevert(IAaveAdapter.InvalidPostLiquidationState.selector);
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: 1_000e6,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });

    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });
    assertEq(_suppliedVaultBtc(proxy), VAULT_AMOUNT, 'one vault left');
    assertEq(adapter.getPosition(user).vaultIds.length, 1, 'vault count');
    assertEq(adapter.getPosition(user).vaultIds[0], VAULT_2, 'second vault left');
    assertEq(IERC20(VAULT_BTC).totalSupply(), VAULT_AMOUNT, 'vaultBTC supply');
    assertGe(
      ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor,
      1e18,
      'healthy after the liquidation'
    );
  }

  /// @dev Freezing BTCVaultSwap with the guardian role stops liquidations through it and leaves
  /// direct liquidations open.
  function test_frozenBtcVaultSwapBlocksOnlyItsOwnPath() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _debt = _usdcDebt(_proxy());
    _fundLiquidator({usdc: _debt * 4, wbtc: 1e8});

    vm.prank(V4_SECURITY_COUNCIL);
    IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE).freeze();

    vm.expectRevert(IBTCVaultSwap.EnforcedFreeze.selector);
    vm.prank(liquidator);
    adapter.liquidateWithLLP({
      borrower: user,
      llp: BABYLON_BTC_VAULT_SWAP_SPOKE,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      minPayouts: new TokenAmount[](0)
    });

    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });
    assertEq(_usdcDebt(_proxy()), 0, 'debt left');
  }

  /// @dev Governance can stop liquidations through BTCVaultSwap by cutting its credit line.
  function test_zeroDrawCapBlocksBtcVaultSwapLiquidation() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _debt = _usdcDebt(_proxy());
    _fundLiquidator({usdc: _debt * 2, wbtc: 0});

    vm.prank(EXECUTOR_LVL_1);
    IHubConfigurator(HUB_CONFIGURATOR).updateSpokeDrawCap({
      hub: CORE_HUB,
      assetId: CORE_WBTC_ASSET_ID,
      spoke: BABYLON_BTC_VAULT_SWAP_SPOKE,
      drawCap: 0
    });

    vm.expectRevert(abi.encodeWithSelector(IHub.DrawCapExceeded.selector, 0));
    vm.prank(liquidator);
    adapter.liquidateWithLLP({
      borrower: user,
      llp: BABYLON_BTC_VAULT_SWAP_SPOKE,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      minPayouts: new TokenAmount[](0)
    });
  }

  /// @dev Babylon caps a position at 2 BTC at launch, so a single escrow uses at most a tenth of
  /// the 20 WBTC credit line.
  function test_positionAboveBabylonLimitCannotBeOpened() public {
    _executePayload();
    BTCVaultBasicInfo memory info = _vaultInfo(user, 20e8);
    _mockRegistryForVault(VAULT_1, info);
    vm.expectRevert(IAaveAdapter.InvalidPositionSizes.selector);
    vm.prank(registry);
    adapter.activateVault(VAULT_1, info, '');

    _activate(VAULT_1, VAULT_AMOUNT);
    _mockVaultAmounts(_one(VAULT_1), _one(VAULT_AMOUNT));
    _activate(VAULT_2, VAULT_AMOUNT);
    assertEq(_suppliedVaultBtc(_proxy()), 2e8, 'position at the limit');
  }

  // ─── helpers ───

  function _openAndBorrow(uint256 ltvBps) internal returns (uint256 borrowed) {
    _executePayload();
    _activate(VAULT_1, VAULT_AMOUNT);
    _mockVaultAmounts(_one(VAULT_1), _one(VAULT_AMOUNT));
    _unfreezeAdapter();
    // 1 BTC of collateral, prices have 8 decimals and USDC has 6
    borrowed = (_price(VAULT_BTC_RESERVE_ID) * ltvBps) / 10_000 / 100;
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, borrowed, user);
  }

  function _liquidateWithBtcVaultSwap() internal {
    address proxy = _proxy();
    _healthFactor = ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor;
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 0});
    vm.prank(liquidator);
    (, , TokenAmount[] memory payouts) = adapter.liquidateWithLLP({
      borrower: user,
      llp: BABYLON_BTC_VAULT_SWAP_SPOKE,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      minPayouts: new TokenAmount[](0)
    });
    assertEq(payouts[0].token, WBTC, 'payout token');
    _payout = payouts[0].amount;
  }

  /// @dev Only a vault keeper registered for the AaveAdapter in Babylon's ApplicationRegistry can
  /// buy an escrowed vault. The registry is read as deployed and only the vault's protocol record,
  /// which a peg-in would write, is mocked.
  function _arbitrage() internal {
    skip(4 days);
    _mockVaultProtocolInfo(VAULT_1);
    AddressBTCKeyPair memory keeper = _vaultKeeper();
    // the vault is redeemed to the BTC key the keeper registered in the ApplicationRegistry
    bytes memory redeemCall = abi.encodeCall(
      IBTCVaultRegistry.redeemVaultForAVK,
      (VAULT_1, keeper.btcPubKey)
    );
    vm.mockCall(registry, redeemCall, '');
    deal(WBTC, keeper.ethAddress, 2e8);
    vm.startPrank(keeper.ethAddress);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    vm.expectCall(registry, redeemCall);
    uint256 paid = swap.swapExitBtcForVault(VAULT_1, UINT256_MAX);
    vm.stopPrank();
    assertGe(paid, _payout, 'keeper repays at least the draw');
  }

  /// @dev The vault is recorded under the current vault keeper roster.
  function _mockVaultProtocolInfo(bytes32 vaultId) internal {
    BTCVaultProtocolInfo memory protocolInfo;
    protocolInfo.appVaultKeepersVersion = IApplicationRegistry(applicationRegistry)
      .getCurrentVaultKeepersVersion(BABYLON_AAVE_ADAPTER);
    vm.mockCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.getBtcVaultProtocolInfo, (vaultId)),
      abi.encode(protocolInfo)
    );
  }

  function _vaultKeeper() internal view returns (AddressBTCKeyPair memory) {
    AddressBTCKeyPair[] memory keepers = IApplicationRegistry(applicationRegistry)
      .getCurrentVaultKeepers(BABYLON_AAVE_ADAPTER);
    assertGt(keepers.length, 0, 'no vault keeper registered');
    return keepers[0];
  }

  /// @dev Computed without the adapter: the fee is 10% of the bonus on the whole vault, and the
  /// fairness payment is the collateral the Spoke left, discounted by the bonus. Both in WBTC.
  function _assertFeeAndFairness() internal view {
    uint256 bonus = ISpoke(BABYLON_SPOKE).getLiquidationBonus(
      VAULT_BTC_RESERVE_ID,
      _proxy(),
      _healthFactor
    );
    uint256 vaultBtcPrice = _price(VAULT_BTC_RESERVE_ID);
    uint256 wbtcPrice = _price(BABYLON_WBTC_RESERVE_ID);
    uint256 expectedFee = (VAULT_AMOUNT * vaultBtcPrice * (bonus - 100_00) * 10_00) /
      (bonus * 100_00) /
      wbtcPrice;
    assertApproxEqAbs(_fee, expectedFee, 2, 'fee is 10% of the bonus');

    // debt value at the oracle USDC price, 8 decimals, USDC has 6
    uint256 seizedBySpoke = (_debt * _price(CORE_USDC_RESERVE_ID) * bonus * 1e8) /
      (vaultBtcPrice * 100_00 * 1e6);
    uint256 expectedFairness = ((VAULT_AMOUNT - seizedBySpoke) * 100_00 * vaultBtcPrice) /
      bonus /
      wbtcPrice;
    assertApproxEqRel(_fairness, expectedFairness, 1e14, 'fairness payment');
  }

  function _vaultInfo(
    address depositor,
    uint256 amount
  ) internal view returns (BTCVaultBasicInfo memory) {
    return
      BTCVaultBasicInfo({
        depositor: depositor,
        depositorBtcPubKey: bytes32(uint256(1)),
        amount: amount,
        vaultProvider: address(0xBEEF),
        status: 2,
        applicationEntryPoint: BABYLON_AAVE_ADAPTER,
        createdAt: block.number
      });
  }

  /// @dev Mocks the registry reads of a pegged-in vault and its two redemption calls.
  function _mockRegistryForVault(bytes32 vaultId, BTCVaultBasicInfo memory info) internal {
    vm.mockCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.getBtcVaultBasicInfo, (vaultId)),
      abi.encode(info)
    );
    vm.mockCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForAVK, (vaultId, CLAIMER_BTC_KEY)),
      ''
    );
    vm.mockCall(registry, abi.encodeCall(IBTCVaultRegistry.redeemVaultForDepositor, (vaultId)), '');
  }

  /// @dev The registry activates a vault on the adapter once its peg-in is verified.
  function _activate(bytes32 vaultId, uint256 amount) internal {
    BTCVaultBasicInfo memory info = _vaultInfo(user, amount);
    _mockRegistryForVault(vaultId, info);
    vm.prank(registry);
    adapter.activateVault(vaultId, info, '');
  }

  function _mockVaultAmounts(bytes32[] memory vaultIds, uint256[] memory amounts) internal {
    vm.mockCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.getBTCVaultAmountsBatch, (vaultIds)),
      abi.encode(amounts)
    );
  }

  /// @dev Babylon unfreezes the AaveAdapter once the proposal has executed.
  function _unfreezeAdapter() internal {
    vm.prank(BABYLON_INTERIM_GOVERNANCE);
    adapter.unfreeze();
  }

  /// @dev Scales the Chainlink answers behind vaultBTC and WBTC by the same factor.
  function _scaleBtcPrices(uint256 bps) internal {
    uint256 vaultBtcPrice = _price(VAULT_BTC_RESERVE_ID);
    uint256 wbtcPrice = _price(BABYLON_WBTC_RESERVE_ID);
    vm.mockCall(
      BTC_USD_SVR_FEED,
      abi.encodeWithSignature('latestAnswer()'),
      abi.encode(int256((vaultBtcPrice * bps) / 100_00))
    );
    vm.mockCall(
      WBTC_FEED,
      abi.encodeWithSignature('latestAnswer()'),
      abi.encode(int256((wbtcPrice * bps) / 100_00))
    );
  }

  function _fundLiquidator(uint256 usdc, uint256 wbtc) internal {
    deal(USDC, liquidator, usdc);
    deal(WBTC, liquidator, wbtc);
    vm.startPrank(liquidator);
    IERC20(USDC).approve(BABYLON_AAVE_ADAPTER, UINT256_MAX);
    IERC20(WBTC).approve(BABYLON_AAVE_ADAPTER, UINT256_MAX);
    vm.stopPrank();
  }

  function _price(uint256 reserveId) internal view returns (uint256) {
    return IAaveOracle(BABYLON_SPOKE_ORACLE).getReservePrice(reserveId);
  }

  function _proxy() internal view returns (address) {
    return adapter.getPosition(user).proxyContract;
  }

  function _suppliedVaultBtc(address account) internal view returns (uint256) {
    return ISpoke(BABYLON_SPOKE).getUserSuppliedAssets(VAULT_BTC_RESERVE_ID, account);
  }

  function _usdcDebt(address account) internal view returns (uint256) {
    return ISpoke(BABYLON_SPOKE).getUserTotalDebt(CORE_USDC_RESERVE_ID, account);
  }

  function _one(bytes32 value) internal pure returns (bytes32[] memory values) {
    values = new bytes32[](1);
    values[0] = value;
  }

  function _one(uint256 value) internal pure returns (uint256[] memory values) {
    values = new uint256[](1);
    values[0] = value;
  }
}
