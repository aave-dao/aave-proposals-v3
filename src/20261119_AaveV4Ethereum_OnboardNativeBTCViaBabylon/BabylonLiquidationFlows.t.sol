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
import {IAaveAdapterConfig, ICapPolicy} from 'src/interfaces/babylon/IBabylonPolicies.sol';
import {TokenAmount, AddressBTCKeyPair, ApplicationCapParams, EscrowedVaultPreviewResult} from 'src/interfaces/babylon/BabylonTypes.sol';
import {BabylonPegInHelper} from './BabylonPegInHelper.sol';
import {BabylonMainnet} from './BabylonMainnet.sol';

/**
 * @dev Drives Babylon's deployed AaveAdapter and BTCVaultSwap against the Babylon Spoke after the
 * proposal: vault activation, borrow, repay, both liquidation paths and the arbitrage that repays
 * the Core Hub. Vaults are pegged in through Babylon's deployed BTCVaultRegistry by
 * `BabylonPegInHelper`, so activations and redemptions run the registry as deployed. Only Chainlink
 * answers are mocked, to move prices.
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/BabylonLiquidationFlows.t.sol -vv
 */
contract BabylonLiquidationFlowsTest is BabylonPegInHelper {
  // every vault in these tests holds 1 BTC
  uint256 internal constant VAULT_AMOUNT = 1e8;

  // AaveAdapter vault usage status
  uint8 internal constant VAULT_LLP_OWNED = 2;
  uint8 internal constant VAULT_REDEEMED = 3;

  // BTCVaultSwap escrowed vault status
  uint8 internal constant ESCROW_ACTIVE = 1;
  uint8 internal constant ESCROW_REDEEMED = 2;

  // lowest BTC price of the fuzz tests, relative to the price at the fork block
  uint256 internal constant FUZZ_MIN_PRICE_BPS = 30_00;

  // AaveAdapter pause state
  uint8 internal constant ADAPTER_ACTIVE = 0;
  uint8 internal constant ADAPTER_FROZEN = 1;
  uint8 internal constant ADAPTER_PAUSED = 2;

  IAaveAdapter internal adapter = IAaveAdapter(BABYLON_AAVE_ADAPTER);
  IBTCVaultSwap internal swap = IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE);
  // ids of the vaults pegged in by a test, in activation order
  bytes32 internal vault1;
  bytes32 internal vault2;
  // a direct liquidation can only redeem to the BTC key of a registered vault keeper
  bytes32 internal claimerBtcKey;
  address internal liquidator = makeAddr('liquidator');
  address internal arbitrageur = makeAddr('arbitrageur');

  uint256 internal _debt;
  uint256 internal _healthFactor;
  uint256 internal _fee;
  uint256 internal _fairness;
  uint256 internal _payout;

  function setUp() public override {
    super.setUp();
    assertEq(adapter.BTC_VAULT_REGISTRY(), address(registry), 'registry');
    assertEq(adapter.APP_REGISTRY(), address(applicationRegistry), 'application registry');
    _setUpPegIns(user);
    claimerBtcKey = _btcKey(vaultKeeper);
  }

  function test_activateVault_revertsBeforeTheProposal() public {
    vault1 = _pegInUntilVerified(user, VAULT_AMOUNT);
    _passActivationDelay(vault1);
    bytes32 secret = _pegInSecrets[vault1];
    vm.expectRevert(IHub.SpokeNotActive.selector);
    vm.prank(user);
    registry.activateVaultWithSecret(vault1, secret, '');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_VERIFIED, 'vault stays verified');
  }

  /// @dev Babylon keeps the AaveAdapter frozen until the proposal executes. A frozen adapter still
  /// activates and withdraws vaults and only blocks new borrows.
  function test_activateAndWithdrawWhileAdapterFrozen() public {
    _executePayload();
    assertEq(adapter.pauseState(), ADAPTER_FROZEN, 'adapter frozen');
    vault1 = _activate(VAULT_AMOUNT);
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

    vm.expectCall(
      address(registry),
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForDepositor, (vault1))
    );
    vm.prank(user);
    adapter.withdrawCollaterals(_one(vault1));
    assertEq(IERC20(VAULT_BTC).totalSupply(), 0, 'vaultBTC burned');
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_REDEEMED, 'redeemed');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
    assertEq(_capUsage(user), 0, 'cap usage released');
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
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'active in the registry');
    vm.expectCall(
      address(registry),
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForAVK, (vault1, claimerBtcKey))
    );
    vm.prank(liquidator);
    (bytes32 vaultId, uint256 seized) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: claimerBtcKey
    });

    assertEq(vaultId, vault1, 'vault');
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
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_REDEEMED, 'redeemed');
    assertEq(adapter.getPosition(user).vaultIds.length, 0, 'vaults left');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
    assertEq(adapter.vaultOwner(vault1), address(0), 'vault owner cleared');
    assertEq(_capUsage(user), 0, 'cap usage released');
  }

  /// @dev A healthy position cannot be liquidated on either path, so it never leaves a deficit.
  function test_liquidate_revertsWith_healthyPosition() public {
    _openAndBorrow(75_00);
    address proxy = _proxy();
    assertGe(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'healthy');
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});

    vm.startPrank(liquidator);
    vm.expectRevert(ISpoke.HealthFactorNotBelowThreshold.selector);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: claimerBtcKey
    });
    vm.expectRevert(ISpoke.HealthFactorNotBelowThreshold.selector);
    adapter.liquidateWithLLP({
      borrower: user,
      llp: BABYLON_BTC_VAULT_SWAP_SPOKE,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      minPayouts: new TokenAmount[](0)
    });
    vm.stopPrank();

    assertEq(_usdcDebt(proxy), _debt, 'debt');
    assertEq(_suppliedVaultBtc(proxy), VAULT_AMOUNT, 'collateral');
    assertEq(IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE), 0, 'deficit');
  }

  /// @dev The registry redeems a liquidated vault only to the BTC key of a vault keeper in the
  /// roster the vault is bound to, so a liquidator cannot name a key of its own.
  function test_liquidateDirect_revertsWith_unregisteredClaimerKey() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _debt = _usdcDebt(_proxy());
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    vm.expectRevert(IApplicationRegistry.UnauthorizedVaultKeeper.selector);
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: _btcKey(depositorBtcWallet)
    });
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'active in the registry');
  }

  /// @dev `maxExitBtc` caps the WBTC the liquidator pays for the fee and the fairness payment.
  function test_liquidateDirect_revertsWith_excessiveExitBtcPayment() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _debt = _usdcDebt(_proxy());
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    uint256 snapshot = vm.snapshotState();
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: claimerBtcKey
    });
    uint256 paid = 1e8 - IERC20(WBTC).balanceOf(liquidator);
    assertGt(paid, 0, 'paid');
    vm.revertToState(snapshot);

    vm.expectRevert(IAaveAdapter.ExcessiveExitBtcPayment.selector);
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: paid - 1,
      claimerBtcPubKey: claimerBtcKey
    });

    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: paid,
      claimerBtcPubKey: claimerBtcKey
    });
    assertEq(1e8 - IERC20(WBTC).balanceOf(liquidator), paid, 'liquidator WBTC paid');
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
      'first freezer holds the role since deployment'
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
        'freezer is a pause guardian'
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
    (uint128 amountVault, uint128 drawn, uint128 sharesOwed, ) = swap.vaultsInfo(vault1);
    assertEq(amountVault, VAULT_AMOUNT, 'escrowed vault');
    assertEq(drawn, _payout, 'escrow drawn');
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      sharesOwed,
      'escrow shares'
    );
    assertEq(adapter.vaultOwner(vault1), BABYLON_BTC_VAULT_SWAP_SPOKE, 'vault owner');
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_LLP_OWNED, 'vault held by the swap');
    assertEq(_suppliedVaultBtc(_proxy()), 0, 'collateral left');
    assertEq(swap.sellDiscountBps(), 2_00, 'sell discount');
    assertEq(swap.minimumProfitThresholdBps(), 50, 'minimum profit threshold');
    assertApproxEqAbs(
      _payout,
      vaultValue - (vaultValue * swap.sellDiscountBps()) / 100_00,
      3,
      'payout net of the sell discount'
    );
    assertGt(sharesOwed, 0, 'escrow shares');
    // an escrowed vault stays active in the registry and keeps using the depositor's cap
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'active in the registry');
    assertEq(_capUsage(user), VAULT_AMOUNT, 'cap usage');
    assertEq(_escrowStatus(vault1), ESCROW_ACTIVE, 'escrow active');

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
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_REDEEMED, 'redeemed');
    _assertEscrowSettled();
  }

  /// @dev BTCVaultSwap sets no waiting period: the keeper can buy the vault in the block it was
  /// escrowed, for the amount drawn. `maxExitBtc` caps what the keeper pays.
  function test_arbitrage_inTheEscrowBlock() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    assertLe(swap.previewVaultInterest(vault1), 1, 'interest');
    EscrowedVaultPreviewResult memory preview = swap.previewEscrowedVaults(_one(vault1))[0];
    assertApproxEqAbs(preview.amountExitBtcToAcquire, _payout, 1, 'price is the draw');

    AddressBTCKeyPair memory keeper = _vaultKeeper();
    deal(WBTC, keeper.ethAddress, 2e8);
    vm.startPrank(keeper.ethAddress);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    vm.expectRevert(
      abi.encodeWithSelector(
        IBTCVaultSwap.SlippageExceeded.selector,
        preview.amountExitBtcToAcquire - 1,
        preview.amountExitBtcToAcquire
      )
    );
    swap.swapExitBtcForVault(vault1, preview.amountExitBtcToAcquire - 1);
    vm.expectCall(
      address(registry),
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForAVK, (vault1, keeper.btcPubKey))
    );
    uint256 paid = swap.swapExitBtcForVault(vault1, preview.amountExitBtcToAcquire);
    vm.stopPrank();
    assertEq(paid, preview.amountExitBtcToAcquire, 'paid');
    assertEq(2e8 - IERC20(WBTC).balanceOf(keeper.ethAddress), paid, 'keeper WBTC paid');
    _assertEscrowSettled();

    vm.expectRevert(IBTCVaultSwap.VaultNotAcquirable.selector);
    vm.prank(keeper.ethAddress);
    swap.swapExitBtcForVault(vault1, UINT256_MAX);
  }

  /// @dev Anyone can pay for an escrowed vault on behalf of a vault keeper. The vault is redeemed
  /// to the keeper's BTC key, never to the payer.
  function test_arbitrage_onBehalfOfVaultKeeper() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    skip(4 days);
    AddressBTCKeyPair memory keeper = _vaultKeeper();
    deal(WBTC, arbitrageur, 2e8);
    vm.startPrank(arbitrageur);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    vm.expectRevert(IApplicationRegistry.UnauthorizedVaultKeeper.selector);
    swap.swapExitBtcForVaultOnBehalf(vault1, UINT256_MAX, arbitrageur);
    vm.expectCall(
      address(registry),
      abi.encodeCall(IBTCVaultRegistry.redeemVaultForAVK, (vault1, keeper.btcPubKey))
    );
    uint256 paid = swap.swapExitBtcForVaultOnBehalf(vault1, UINT256_MAX, keeper.ethAddress);
    vm.stopPrank();
    assertGe(paid, _payout, 'payer repays at least the draw');
    assertEq(2e8 - IERC20(WBTC).balanceOf(arbitrageur), paid, 'payer WBTC paid');
    _assertEscrowSettled();
  }

  /// @dev Anyone can repay part of an escrow's Core Hub debt, which lowers the price of the vault
  /// by the same amount. The debt is only closed by buying the vault.
  function test_repayVaultDebt() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    skip(4 days);
    uint256 owed = IHub(CORE_HUB).getSpokeTotalOwed(
      CORE_WBTC_ASSET_ID,
      BABYLON_BTC_VAULT_SWAP_SPOKE
    );
    assertEq(
      owed,
      _payout + swap.previewVaultInterest(vault1),
      'debt is the draw and its interest'
    );
    (, , uint128 sharesBefore, ) = swap.vaultsInfo(vault1);

    uint256 repaid = _payout / 2;
    deal(WBTC, arbitrageur, 2e8);
    vm.startPrank(arbitrageur);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    vm.expectRevert(IBTCVaultSwap.VaultDebtRepaymentExceeded.selector);
    swap.repayVaultDebt(vault1, owed);
    swap.repayVaultDebt(vault1, repaid);
    vm.stopPrank();

    (, uint128 drawn, uint128 sharesAfter, ) = swap.vaultsInfo(vault1);
    assertEq(drawn, _payout, 'escrow drawn');
    assertLt(sharesAfter, sharesBefore, 'escrow shares');
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      sharesAfter,
      'drawn shares'
    );
    assertApproxEqAbs(
      IHub(CORE_HUB).getSpokeTotalOwed(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      owed - repaid,
      2,
      'debt after the repayment'
    );
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_LLP_OWNED, 'vault held by the swap');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'active in the registry');

    address keeper = _vaultKeeper().ethAddress;
    deal(WBTC, keeper, 2e8);
    vm.startPrank(keeper);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    uint256 paid = swap.swapExitBtcForVault(vault1, UINT256_MAX);
    vm.stopPrank();
    assertApproxEqAbs(paid, owed - repaid, 2, 'keeper pays the remaining debt');
    _assertEscrowSettled();
  }

  /// @dev When vaultBTC loses value against WBTC after the escrow, the keeper pays the WBTC value
  /// of the vault less the minimum profit, and BTCVaultSwap reports the rest of its debt as a
  /// deficit on the Core Hub.
  function test_arbitrage_reportsDeficitWhenVaultIsWorthLessThanItsDebt() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    uint256 owed = IHub(CORE_HUB).getSpokeTotalOwed(
      CORE_WBTC_ASSET_ID,
      BABYLON_BTC_VAULT_SWAP_SPOKE
    );
    _scaleVaultBtcPrice(90_00);
    uint256 vaultValue = (VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID)) /
      _price(BABYLON_WBTC_RESERVE_ID);
    uint256 price = vaultValue - (vaultValue * swap.minimumProfitThresholdBps()) / 100_00;
    assertLt(price, owed, 'vault worth less than its debt');

    address keeper = _vaultKeeper().ethAddress;
    deal(WBTC, keeper, 2e8);
    vm.startPrank(keeper);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    uint256 paid = swap.swapExitBtcForVault(vault1, UINT256_MAX);
    vm.stopPrank();
    assertApproxEqAbs(paid, price, 2, 'keeper pays the vault value less the minimum profit');
    assertApproxEqAbs(
      IHub(CORE_HUB).getSpokeDeficitRay(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE) / 1e27,
      owed - paid,
      2,
      'deficit'
    );
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'drawn'
    );
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
    assertEq(_escrowStatus(vault1), ESCROW_REDEEMED, 'escrow redeemed');
  }

  /// @dev Interest accrues on the escrow's Core Hub debt. Once the debt exceeds the vault value less
  /// the keeper's minimum profit, the keeper pays that capped price and the rest is reported as a
  /// WBTC deficit.
  function test_arbitrage_reportsDeficitOnceInterestExceedsTheDiscount() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    uint256 vaultValue = (VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID)) /
      _price(BABYLON_WBTC_RESERVE_ID);
    uint256 price = vaultValue - (vaultValue * swap.minimumProfitThresholdBps()) / 100_00;
    assertLt(
      IHub(CORE_HUB).getSpokeTotalOwed(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      price,
      'debt above the capped price at escrow'
    );
    uint256 yearsPassed;
    while (
      IHub(CORE_HUB).getSpokeTotalOwed(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE) <= price
    ) {
      skip(365 days);
      assertLt(++yearsPassed, 100, 'debt never reaches the capped price');
    }
    uint256 owed = IHub(CORE_HUB).getSpokeTotalOwed(
      CORE_WBTC_ASSET_ID,
      BABYLON_BTC_VAULT_SWAP_SPOKE
    );
    EscrowedVaultPreviewResult memory preview = swap.previewEscrowedVaults(_one(vault1))[0];
    assertEq(preview.amountDebt, owed, 'previewed debt');
    // the swap rounds the vault value up
    assertApproxEqAbs(preview.amountExitBtcToAcquire, price, 2, 'previewed price');
    assertEq(preview.amountDeficitEst, owed - preview.amountExitBtcToAcquire, 'previewed deficit');

    address keeper = _vaultKeeper().ethAddress;
    deal(WBTC, keeper, 2e8);
    vm.startPrank(keeper);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    uint256 paid = swap.swapExitBtcForVault(vault1, UINT256_MAX);
    vm.stopPrank();
    assertEq(paid, preview.amountExitBtcToAcquire, 'keeper pays the previewed price');
    assertApproxEqAbs(paid, price, 2, 'keeper pays the vault value less the minimum profit');
    assertLt(paid, owed, 'keeper repaid the whole debt');
    assertApproxEqAbs(
      IHub(CORE_HUB).getSpokeDeficitRay(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE) / 1e27,
      owed - paid,
      2,
      'deficit'
    );
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'drawn'
    );
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
    assertEq(_escrowStatus(vault1), ESCROW_REDEEMED, 'escrow redeemed');
  }

  /// @dev An underwater position liquidated through BTCVaultSwap leaves a USDC deficit on the
  /// Babylon Spoke credit line. The escrow still settles in full, since vaultBTC and WBTC fell
  /// together.
  function test_liquidateUnderwaterWithBtcVaultSwap_escrowSettlesInFull() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(70_00);
    _liquidateWithBtcVaultSwap();
    address proxy = _proxy();
    assertEq(_suppliedVaultBtc(proxy), 0, 'collateral left');
    assertEq(_usdcDebt(proxy), 0, 'debt left');
    assertLt(_debt * 2 - IERC20(USDC).balanceOf(liquidator), _debt, 'liquidator repaid less');
    assertGt(
      IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE),
      0,
      'USDC deficit'
    );
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_LLP_OWNED, 'vault held by the swap');

    _arbitrage();
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'drawn'
    );
    assertEq(
      IHub(CORE_HUB).getSpokeDeficitRay(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'WBTC deficit'
    );
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
    assertEq(_escrowStatus(vault1), ESCROW_REDEEMED, 'escrow redeemed');
  }

  function test_arbitrage_revertsWith_notVaultKeeper() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    skip(4 days);
    deal(WBTC, arbitrageur, 2e8);
    vm.startPrank(arbitrageur);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    vm.expectRevert(IApplicationRegistry.UnauthorizedVaultKeeper.selector);
    swap.swapExitBtcForVault(vault1, UINT256_MAX);
    vm.stopPrank();
  }

  /// @dev While BTCVaultSwap is paused nobody can buy an escrowed vault, so its Core Hub debt
  /// stays open until a guardian unpauses.
  function test_arbitrage_blockedWhileBtcVaultSwapPaused() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    skip(4 days);
    address keeper = _vaultKeeper().ethAddress;
    deal(WBTC, keeper, 2e8);
    vm.prank(keeper);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);

    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE).pause();
    vm.expectRevert(IBTCVaultSwap.EnforcedPause.selector);
    vm.prank(keeper);
    swap.swapExitBtcForVault(vault1, UINT256_MAX);
    assertGt(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'debt'
    );

    vm.prank(V4_SECURITY_COUNCIL);
    IBTCVaultSwap(BABYLON_BTC_VAULT_SWAP_SPOKE).unpause();
    vm.prank(keeper);
    swap.swapExitBtcForVault(vault1, UINT256_MAX);
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'repaid'
    );
  }

  /// @dev The adapter redeems an escrowed vault for BTCVaultSwap, so a paused AaveAdapter also
  /// blocks the keeper and BTCVaultSwap's Core Hub debt stays open.
  function test_arbitrage_blockedWhileAdapterPaused() public {
    _openAndBorrow(75_00);
    _scaleBtcPrices(94_00);
    _liquidateWithBtcVaultSwap();
    address keeper = _vaultKeeper().ethAddress;
    deal(WBTC, keeper, 2e8);
    vm.prank(keeper);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);

    vm.prank(V4_SECURITY_COUNCIL);
    adapter.pause();
    vm.expectRevert(IAaveAdapter.TBV_Paused.selector);
    vm.prank(keeper);
    swap.swapExitBtcForVault(vault1, UINT256_MAX);
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'active in the registry');

    vm.prank(V4_SECURITY_COUNCIL);
    adapter.unpause();
    vm.prank(keeper);
    swap.swapExitBtcForVault(vault1, UINT256_MAX);
    _assertEscrowSettled();
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
    adapter.withdrawCollaterals(_one(vault1));
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
      claimerBtcPubKey: claimerBtcKey
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
      claimerBtcPubKey: claimerBtcKey
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
      claimerBtcPubKey: claimerBtcKey
    });
    assertEq(_suppliedVaultBtc(proxy), 0, 'collateral left');
    assertEq(_usdcDebt(proxy), 0, 'debt left');
    assertLt(_debt * 2 - IERC20(USDC).balanceOf(liquidator), _debt, 'liquidator repaid less');
    assertGt(IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE), 0, 'deficit');
  }

  /// @dev A deficit does not need an underwater position. The vault is worth more than the debt
  /// but less than the debt and the liquidation bonus, so the Spoke seizes all of it for less than
  /// the debt and reports the rest.
  function test_liquidate_reportsDeficitWhenVaultIsWorthLessThanDebtAndBonus() public {
    _openAndBorrow(75_00);
    uint256 maxExitBtc = _dropToLiquidatablePrice(77_00);
    uint256 collateralValue = VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID);
    uint256 debtValue = _debt * _price(CORE_USDC_RESERVE_ID) * 100;
    assertGt(collateralValue, debtValue, 'underwater');
    assertLt(
      collateralValue * 100_00,
      debtValue *
        ISpoke(BABYLON_SPOKE).getLiquidationBonus(VAULT_BTC_RESERVE_ID, _proxy(), _healthFactor),
      'vault covers the debt and the bonus'
    );

    _fundLiquidator({usdc: _debt * 2, wbtc: maxExitBtc});
    uint256 recipientBefore = IERC20(WBTC).balanceOf(adapter.applicationRecipient());
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: maxExitBtc,
      claimerBtcPubKey: claimerBtcKey
    });
    _fee = IERC20(WBTC).balanceOf(adapter.applicationRecipient()) - recipientBefore;
    _fairness = IERC20(WBTC).balanceOf(user);
    _assertLiquidationInvariants();
    assertGt(IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE), 0, 'deficit');
  }

  /// @dev Vaults are seized whole and in order, so a liquidation takes the first vault only.
  function test_liquidateFirstOfTwoVaults() public {
    _executePayload();
    vault1 = _activate(VAULT_AMOUNT);
    vault2 = _activate(VAULT_AMOUNT);
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
      claimerBtcPubKey: claimerBtcKey
    });

    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: claimerBtcKey
    });
    assertEq(_suppliedVaultBtc(proxy), VAULT_AMOUNT, 'one vault left');
    assertEq(adapter.getPosition(user).vaultIds.length, 1, 'vault count');
    assertEq(adapter.getPosition(user).vaultIds[0], vault2, 'second vault left');
    assertEq(IERC20(VAULT_BTC).totalSupply(), VAULT_AMOUNT, 'vaultBTC supply');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'first vault redeemed');
    assertEq(_registryVaultStatus(vault2), REGISTRY_VAULT_ACTIVE, 'second vault active');
    assertGe(
      ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor,
      1e18,
      'healthy after the liquidation'
    );
  }

  /// @dev A vault can be activated on an unhealthy position. It joins the tail of the vault list,
  /// so a liquidation still seizes the vault that was first.
  function test_vaultActivatedWhileUnhealthy_isAppended_headIsLiquidated() public {
    _openAndBorrow(75_00);
    address proxy = _proxy();
    _scaleBtcPrices(94_00);
    assertLt(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'unhealthy');

    vault2 = _activate(VAULT_AMOUNT);
    bytes32[] memory vaultIds = adapter.getPosition(user).vaultIds;
    assertEq(vaultIds.length, 2, 'vault count');
    assertEq(vaultIds[0], vault1, 'head');
    assertEq(vaultIds[1], vault2, 'tail');
    assertEq(_suppliedVaultBtc(proxy), 2 * VAULT_AMOUNT, 'supplied');

    // the second vault restored the health factor, so prices fall further
    assertGe(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'healthy');
    _scaleBtcPrices(48_00);
    assertLt(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'liquidatable');
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    vm.prank(liquidator);
    (bytes32 vaultId, uint256 seized) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: claimerBtcKey
    });
    assertEq(vaultId, vault1, 'head vault seized');
    assertEq(seized, VAULT_AMOUNT, 'whole vault seized');
    vaultIds = adapter.getPosition(user).vaultIds;
    assertEq(vaultIds.length, 1, 'vault count');
    assertEq(vaultIds[0], vault2, 'tail vault left');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'head redeemed');
    assertEq(_registryVaultStatus(vault2), REGISTRY_VAULT_ACTIVE, 'tail active');
  }

  /// @dev The borrower chooses which vault is liquidated first by ordering the list, but only
  /// while the position is healthy.
  function test_reorderVaults_revertsWith_positionNotHealthy() public {
    _executePayload();
    vault1 = _activate(VAULT_AMOUNT);
    vault2 = _activate(VAULT_AMOUNT);
    _unfreezeAdapter();
    uint256 borrowed = (2 * _price(VAULT_BTC_RESERVE_ID) * 75_00) / 10_000 / 100;
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, borrowed, user);
    address proxy = _proxy();
    bytes32[] memory reordered = new bytes32[](2);
    reordered[0] = vault2;
    reordered[1] = vault1;

    _scaleBtcPrices(94_00);
    assertLt(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'unhealthy');
    vm.expectRevert(IAaveAdapter.PositionNotHealthy.selector);
    vm.prank(user);
    adapter.reorderVaults(reordered);
    assertEq(adapter.getPosition(user).vaultIds[0], vault1, 'order unchanged');

    _scaleBtcPrices(110_00);
    assertGe(ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor, 1e18, 'healthy');
    vm.prank(user);
    adapter.reorderVaults(reordered);
    assertEq(adapter.getPosition(user).vaultIds[0], vault2, 'new head');
    assertEq(adapter.getPosition(user).vaultIds[1], vault1, 'new tail');

    _scaleBtcPrices(85_00);
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});
    vm.prank(liquidator);
    (bytes32 vaultId, ) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: UINT256_MAX,
      claimerBtcPubKey: claimerBtcKey
    });
    assertEq(vaultId, vault2, 'new head seized');
    assertEq(_registryVaultStatus(vault2), REGISTRY_VAULT_REDEEMED, 'new head redeemed');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'new tail active');
  }

  /// forge-config: test.fuzz.runs = 24
  function testFuzz_liquidateDirect(uint256 priceBps) public {
    _openAndBorrow(75_00);
    uint256 maxExitBtc = _dropToLiquidatablePrice(priceBps);
    _fundLiquidator({usdc: _debt * 2, wbtc: maxExitBtc});
    uint256 recipientBefore = IERC20(WBTC).balanceOf(adapter.applicationRecipient());
    vm.prank(liquidator);
    (bytes32 vaultId, uint256 seized) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: maxExitBtc,
      claimerBtcPubKey: claimerBtcKey
    });
    assertEq(vaultId, vault1, 'vault');
    assertEq(seized, VAULT_AMOUNT, 'whole vault seized');
    _fee = IERC20(WBTC).balanceOf(adapter.applicationRecipient()) - recipientBefore;
    _fairness = IERC20(WBTC).balanceOf(user);
    uint256 paid = maxExitBtc - IERC20(WBTC).balanceOf(liquidator);
    assertEq(paid, _fee + _fairness, 'liquidator WBTC paid');
    assertLe(paid, maxExitBtc, 'paid above maxExitBtc');
    _assertLiquidationInvariants();
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_REDEEMED, 'redeemed');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
  }

  /// forge-config: test.fuzz.runs = 24
  function testFuzz_liquidateWithBtcVaultSwap(uint256 priceBps) public {
    uint256 recipientBefore = IERC20(WBTC).balanceOf(adapter.applicationRecipient());
    _openAndBorrow(75_00);
    uint256 maxExitBtc = _dropToLiquidatablePrice(priceBps);
    _fundLiquidator({usdc: _debt * 2, wbtc: 0});
    vm.prank(liquidator);
    (bytes32 vaultId, uint256 seized, TokenAmount[] memory payouts) = adapter.liquidateWithLLP({
      borrower: user,
      llp: BABYLON_BTC_VAULT_SWAP_SPOKE,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: maxExitBtc,
      minPayouts: new TokenAmount[](0)
    });
    assertEq(vaultId, vault1, 'vault');
    assertEq(seized, VAULT_AMOUNT, 'whole vault seized');
    _payout = payouts[0].amount;
    _fee = IERC20(WBTC).balanceOf(adapter.applicationRecipient()) - recipientBefore;
    _fairness = IERC20(WBTC).balanceOf(user);
    uint256 paid = _payout - IERC20(WBTC).balanceOf(liquidator);
    assertEq(paid, _fee + _fairness, 'liquidator WBTC paid');
    assertLe(paid, maxExitBtc, 'paid above maxExitBtc');
    _assertLiquidationInvariants();

    // prices of vaultBTC and WBTC fell together, so the payout does not depend on the drop
    assertApproxEqAbs(
      _payout,
      maxExitBtc - (maxExitBtc * swap.sellDiscountBps()) / 100_00,
      3,
      'payout net of the sell discount'
    );
    (uint128 amountVault, uint128 drawn, uint128 sharesOwed, ) = swap.vaultsInfo(vault1);
    assertEq(amountVault, VAULT_AMOUNT, 'escrowed vault');
    assertEq(drawn, _payout, 'escrow drawn');
    assertGt(sharesOwed, 0, 'escrow shares');
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      sharesOwed,
      'drawn shares'
    );
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_LLP_OWNED, 'vault held by the swap');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_ACTIVE, 'active in the registry');
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
      claimerBtcPubKey: claimerBtcKey
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
  /// the 20 WBTC credit line. The registry enforces it before the adapter: a peg-in is at most
  /// 1 BTC and a depositor's active vaults are capped at the adapter's position limit.
  function test_positionAboveBabylonLimitCannotBeOpened() public {
    _executePayload();
    uint256 maxPegIn = protocolParams.getTBVProtocolParams().maxPegInAmount;
    PegInRequest memory request = _buildPegIn(user, maxPegIn + 1);
    vm.expectRevert(
      abi.encodeWithSelector(IBTCVaultRegistry.VaultAboveMaximum.selector, maxPegIn + 1, maxPegIn)
    );
    _submitPegIn(request);

    (uint256 maxPositionBtc, ) = IAaveAdapterConfig(BabylonMainnet.AAVE_ADAPTER_CONFIG)
      .getPositionSizeParams();
    assertEq(maxPositionBtc, 2e8, 'adapter position limit');
    assertFalse(adapter.allowedToDeposit(user, 1, 20e8), '20 BTC position allowed');
    assertTrue(adapter.allowedToDeposit(user, 1, maxPositionBtc), 'position at the limit refused');
    assertFalse(adapter.allowedToDeposit(user, 1, maxPositionBtc + 1), 'position above the limit');

    vault1 = _activate(VAULT_AMOUNT);
    vault2 = _activate(VAULT_AMOUNT);
    assertEq(_suppliedVaultBtc(_proxy()), 2e8, 'position at the limit');
    assertFalse(adapter.allowedToDeposit(user, 1, 1), 'position above the limit');

    ApplicationCapParams memory caps = ICapPolicy(BabylonMainnet.CAP_POLICY).getApplicationCaps(
      BABYLON_AAVE_ADAPTER
    );
    assertEq(caps.perAddressCapBTC, maxPositionBtc, 'registry cap per depositor');
    assertEq(_capUsage(user), caps.perAddressCapBTC, 'cap used');
    request = _buildPegIn(user, VAULT_AMOUNT);
    vm.expectRevert(IBTCVaultRegistry.CapExceeded.selector);
    _submitPegIn(request);
  }

  // ─── helpers ───

  function _openAndBorrow(uint256 ltvBps) internal returns (uint256 borrowed) {
    _executePayload();
    vault1 = _activate(VAULT_AMOUNT);
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

  /// @dev Only a vault keeper of the roster the vault is bound to can buy an escrowed vault, and
  /// the registry redeems it to the BTC key that keeper registered.
  function _arbitrage() internal {
    skip(4 days);
    AddressBTCKeyPair memory keeper = _vaultKeeper();
    bytes memory redeemCall = abi.encodeCall(
      IBTCVaultRegistry.redeemVaultForAVK,
      (vault1, keeper.btcPubKey)
    );
    deal(WBTC, keeper.ethAddress, 2e8);
    vm.startPrank(keeper.ethAddress);
    IERC20(WBTC).approve(BABYLON_BTC_VAULT_SWAP_SPOKE, UINT256_MAX);
    // the escrow owes the Core Hub the draw and the interest accrued since
    EscrowedVaultPreviewResult memory preview = swap.previewEscrowedVaults(_one(vault1))[0];
    assertGt(preview.amountInterest, 0, 'interest');
    assertEq(preview.amountDebt, _payout + preview.amountInterest, 'debt');
    uint256 vaultValue = (VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID)) /
      _price(BABYLON_WBTC_RESERVE_ID);
    assertLt(
      preview.amountDebt,
      vaultValue - (vaultValue * swap.minimumProfitThresholdBps()) / 100_00,
      'debt leaves the keeper its minimum profit'
    );
    vm.expectCall(address(registry), redeemCall);
    uint256 paid = swap.swapExitBtcForVault(vault1, UINT256_MAX);
    vm.stopPrank();
    assertGe(paid, _payout, 'keeper repays at least the draw');
    assertEq(paid, preview.amountDebt, 'keeper repays the debt');
    assertEq(2e8 - IERC20(WBTC).balanceOf(keeper.ethAddress), paid, 'keeper WBTC paid');
  }

  function _vaultKeeper() internal view returns (AddressBTCKeyPair memory) {
    AddressBTCKeyPair[] memory keepers = applicationRegistry.getCurrentVaultKeepers(
      BABYLON_AAVE_ADAPTER
    );
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

  /// @dev Pegs a vault in. The registry activates it on the adapter.
  function _activate(uint256 amount) internal returns (bytes32 vaultId) {
    uint256 capUsageBefore = _capUsage(user);
    vaultId = _pegIn(user, amount);
    assertEq(_registryVaultStatus(vaultId), REGISTRY_VAULT_ACTIVE, 'active in the registry');
    assertEq(registry.getBtcVaultBasicInfo(vaultId).amount, amount, 'vault amount');
    assertEq(adapter.vaultOwner(vaultId), user, 'vault owner');
    assertEq(_capUsage(user) - capUsageBefore, amount, 'cap usage');
  }

  function _capUsage(address depositor) internal view returns (uint256) {
    return
      ICapPolicy(BabylonMainnet.CAP_POLICY).getApplicationUserBTC(BABYLON_AAVE_ADAPTER, depositor);
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

  /// @dev Scales the Chainlink answer behind vaultBTC only.
  function _scaleVaultBtcPrice(uint256 bps) internal {
    uint256 wbtcPrice = _price(BABYLON_WBTC_RESERVE_ID);
    vm.mockCall(
      BTC_USD_SVR_FEED,
      abi.encodeWithSignature('latestAnswer()'),
      abi.encode(int256((_price(VAULT_BTC_RESERVE_ID) * bps) / 100_00))
    );
    assertEq(_price(BABYLON_WBTC_RESERVE_ID), wbtcPrice, 'WBTC price moved');
  }

  /// @dev Bounds `priceBps` between `FUZZ_MIN_PRICE_BPS` and the highest price at which the
  /// position is liquidatable, drops prices to it and records the position. Returns the WBTC
  /// value of the vault, which bounds what a liquidator can owe for it.
  function _dropToLiquidatablePrice(uint256 priceBps) internal returns (uint256 vaultValue) {
    address proxy = _proxy();
    // collateral is BTC only, so the health factor is linear in the BTC price
    uint256 healthFactor = ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor;
    priceBps = bound(priceBps, FUZZ_MIN_PRICE_BPS, (1e18 * 100_00) / healthFactor - 1);
    _scaleBtcPrices(priceBps);
    _healthFactor = ISpoke(BABYLON_SPOKE).getUserAccountData(proxy).healthFactor;
    assertLt(_healthFactor, 1e18, 'liquidatable');
    _debt = _usdcDebt(proxy);
    vaultValue = (VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID)) / _price(BABYLON_WBTC_RESERVE_ID);
  }

  /// @dev After the liquidation of a one vault position. The vault pays the debt and the
  /// liquidation bonus in full when its value is at least the debt times the bonus. Below that
  /// the Spoke seizes all of it for less than the debt and reports the rest as a deficit.
  function _assertLiquidationInvariants() internal view {
    address proxy = _proxy();
    assertEq(_suppliedVaultBtc(proxy), 0, 'collateral left');
    assertEq(_usdcDebt(proxy), 0, 'debt left');
    assertEq(IERC20(VAULT_BTC).totalSupply(), 0, 'vaultBTC burned');
    assertEq(
      IHub(BABYLON_HUB).getAddedAssets(BABYLON_VAULT_BTC_ASSET_ID),
      IHub(BABYLON_HUB).getAddedShares(BABYLON_VAULT_BTC_ASSET_ID),
      'vaultBTC share price'
    );

    uint256 bonus = ISpoke(BABYLON_SPOKE).getLiquidationBonus(
      VAULT_BTC_RESERVE_ID,
      proxy,
      _healthFactor
    );
    // both in USD with 16 decimals
    uint256 collateralValue = VAULT_AMOUNT * _price(VAULT_BTC_RESERVE_ID);
    uint256 debtValue = _debt * _price(CORE_USDC_RESERVE_ID) * 100;
    uint256 repaid = _debt * 2 - IERC20(USDC).balanceOf(liquidator);
    uint256 deficit = IHub(CORE_HUB).getSpokeDeficitRay(CORE_USDC_ASSET_ID, BABYLON_SPOKE);
    // max bonus times collateral factor is below the health factor for max bonus, so a position
    // liquidated before the max bonus applies never leaves a deficit
    if (_healthFactor >= ISpoke(BABYLON_SPOKE).getLiquidationConfig().healthFactorForMaxBonus) {
      assertEq(deficit, 0, 'deficit above the health factor for max bonus');
    }
    if (collateralValue * 100_00 >= debtValue * bonus) {
      assertEq(deficit, 0, 'deficit on a covered position');
      assertEq(repaid, _debt, 'debt repaid by liquidator');
      _assertFeeAndFairness();
    } else {
      assertGt(deficit, 0, 'deficit');
      assertLt(repaid, _debt, 'liquidator repaid less');
      assertEq(_fairness, 0, 'fairness payment');
      uint256 expectedFee = (collateralValue * (bonus - 100_00) * 10_00) /
        (bonus * 100_00) /
        _price(BABYLON_WBTC_RESERVE_ID);
      assertApproxEqAbs(_fee, expectedFee, 2, 'fee is 10% of the bonus');
    }
  }

  function _escrowStatus(bytes32 vaultId) internal view returns (uint8 status) {
    (, , , status) = swap.vaultsInfo(vaultId);
  }

  /// @dev The keeper bought the only escrowed vault: BTCVaultSwap owes the Core Hub nothing and
  /// the registry redeemed the vault.
  function _assertEscrowSettled() internal view {
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'repaid'
    );
    assertEq(
      IHub(CORE_HUB).getSpokeTotalOwed(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'owed'
    );
    assertEq(
      IHub(CORE_HUB).getSpokeDeficitRay(CORE_WBTC_ASSET_ID, BABYLON_BTC_VAULT_SWAP_SPOKE),
      0,
      'deficit'
    );
    (, , uint128 sharesOwed, uint8 status) = swap.vaultsInfo(vault1);
    assertEq(sharesOwed, 0, 'escrow shares');
    assertEq(status, ESCROW_REDEEMED, 'escrow redeemed');
    assertEq(adapter.getVaultUsageStatus(vault1), VAULT_REDEEMED, 'redeemed');
    assertEq(adapter.vaultOwner(vault1), address(0), 'vault owner cleared');
    assertEq(_registryVaultStatus(vault1), REGISTRY_VAULT_REDEEMED, 'redeemed in the registry');
    assertEq(_capUsage(user), 0, 'cap usage released');
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
