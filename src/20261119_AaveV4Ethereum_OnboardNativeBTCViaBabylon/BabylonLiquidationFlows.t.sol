// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {IHubConfigurator} from 'aave-v4/hub/interfaces/IHubConfigurator.sol';
import {IBTCVaultSwap} from './IBTCVaultSwap.sol';
import {BabylonTestBase} from './BabylonTestBase.sol';

struct BTCVaultBasicInfo {
  address depositor;
  bytes32 depositorBtcPubKey;
  uint256 amount;
  address vaultProvider;
  uint8 status;
  address applicationEntryPoint;
  uint256 createdAt;
}

struct BTCVaultProtocolInfo {
  bytes depositorSignedPeginTx;
  uint16 universalChallengersVersion;
  uint16 appVaultKeepersVersion;
  uint16 offchainParamsVersion;
  uint256 verifiedAt;
  bytes32 depositorWotsPkHash;
  bytes32 hashlock;
  uint8 htlcVout;
  bytes depositorPopSignature;
  bytes32 prePeginTxHash;
  uint16 vaultProviderCommissionBps;
  uint256 claimExpiredUntil;
  uint16 vaultCoreVersion;
  uint64 vpKeyEpoch;
  uint64 appKeeperKeyEpoch;
  uint64 ucKeyEpoch;
}

struct TokenAmount {
  address token;
  uint256 amount;
}

struct MarketPosition {
  bytes32[] vaultIds;
  uint256 totalCollateralBTC;
  address proxyContract;
}

interface IAaveAdapterFlows {
  error InvalidPositionSizes();

  error InvalidPostLiquidationState();

  error TBV_Frozen();

  function activateVault(
    bytes32 vaultId,
    BTCVaultBasicInfo memory info,
    bytes memory data
  ) external;

  function borrowFromCorePosition(
    uint256 debtReserveId,
    uint256 amount,
    address receiver
  ) external returns (uint256, uint256);

  function repayToCorePosition(
    address borrower,
    uint256 debtReserveId,
    uint256 amount
  ) external returns (uint256, uint256, uint256);

  function liquidate(
    address borrower,
    uint256 debtReserveId,
    uint256 maxDebtToRepay,
    uint256 maxExitBtc,
    bytes32 claimerBtcPubKey
  ) external returns (bytes32, uint256);

  function liquidateWithLLP(
    address borrower,
    address llp,
    uint256 debtReserveId,
    uint256 maxDebtToRepay,
    uint256 maxExitBtc,
    TokenAmount[] memory minPayouts
  ) external returns (bytes32, uint256, TokenAmount[] memory);

  function withdrawCollaterals(bytes32[] memory vaultIds) external returns (uint256);

  function getPosition(address borrower) external view returns (MarketPosition memory);

  function pauseState() external view returns (uint8);

  function unfreeze() external;

  function applicationRecipient() external view returns (address);

  function BTC_VAULT_REGISTRY() external view returns (address);

  function APP_REGISTRY() external view returns (address);

  function getVaultUsageStatus(bytes32 vaultId) external view returns (uint8);

  function vaultOwner(bytes32 vaultId) external view returns (address);
}

interface IBTCVaultSwapFlows {
  error EnforcedPause();

  error EnforcedFreeze();

  function vaultsInfo(bytes32 vaultId) external view returns (uint128, uint128, uint128, uint8);

  function swapExitBtcForVault(bytes32 vaultId, uint256 maxExitBtc) external returns (uint256);
}

interface IBTCVaultRegistry {
  function getBtcVaultBasicInfo(bytes32 vaultId) external view returns (BTCVaultBasicInfo memory);

  function getBTCVaultAmountsBatch(
    bytes32[] calldata vaultIds
  ) external view returns (uint256[] memory);

  function redeemVaultForAVK(bytes32 vaultId, bytes32 claimerBtcPubKey) external;

  function redeemVaultForDepositor(bytes32 vaultId) external;

  function getBtcVaultProtocolInfo(
    bytes32 vaultId
  ) external view returns (BTCVaultProtocolInfo memory);
}

struct AddressBTCKeyPair {
  address ethAddress;
  bytes32 btcPubKey;
}

interface IApplicationRegistry {
  error UnauthorizedVaultKeeper();

  function getCurrentVaultKeepers(
    address appEntryPoint
  ) external view returns (AddressBTCKeyPair[] memory);

  function getCurrentVaultKeepersVersion(address appEntryPoint) external view returns (uint16);
}

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

  // AaveAdapter vault usage status
  uint8 internal constant VAULT_LLP_OWNED = 2;
  uint8 internal constant VAULT_REDEEMED = 3;

  IAaveAdapterFlows internal adapter = IAaveAdapterFlows(AAVE_ADAPTER);
  IBTCVaultSwapFlows internal swap = IBTCVaultSwapFlows(BTC_VAULT_SWAP);
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
    BTCVaultBasicInfo memory info = _vaultInfo(user, 1e8);
    _mockRegistryForVault(VAULT_1, info);
    vm.expectRevert(IHub.SpokeNotActive.selector);
    vm.prank(registry);
    adapter.activateVault(VAULT_1, info, '');
  }

  /// @dev Babylon keeps the AaveAdapter frozen until the proposal executes. A frozen adapter still
  /// activates and withdraws vaults and only blocks new borrows.
  function test_activateAndWithdrawWhileAdapterFrozen() public {
    _executePayload();
    assertEq(adapter.pauseState(), 1, 'adapter frozen');
    _activate(VAULT_1, 1e8);
    address proxy = _proxy();
    assertEq(_suppliedVaultBtc(proxy), 1e8, 'supplied');
    assertEq(IERC20(VAULT_BTC).totalSupply(), 1e8, 'vaultBTC minted');
    (bool isCollateral, bool isBorrowing) = ISpoke(BABYLON_SPOKE).getUserReserveStatus(
      VAULT_BTC_RESERVE_ID,
      proxy
    );
    assertTrue(isCollateral, 'collateral enabled');
    assertFalse(isBorrowing, 'borrowing');

    vm.expectRevert(IAaveAdapterFlows.TBV_Frozen.selector);
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, 1e6, user);

    _mockVaultAmounts(_one(VAULT_1), _one(1e8));
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
    IERC20(USDC).approve(AAVE_ADAPTER, type(uint256).max);
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
    vm.prank(liquidator);
    (bytes32 vaultId, uint256 seized) = adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: type(uint256).max,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });

    assertEq(vaultId, VAULT_1, 'vault');
    assertEq(seized, 1e8, 'whole vault seized');
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
    uint256 vaultValue = (1e8 * _price(VAULT_BTC_RESERVE_ID)) / _price(BABYLON_WBTC_RESERVE_ID);
    assertApproxEqAbs(_payout, (vaultValue * 98) / 100, 3, 'payout');
    assertEq(
      liquidityBefore - IHub(CORE_HUB).getAssetLiquidity(CORE_WBTC_ASSET_ID),
      _payout,
      'core hub liquidity drawn'
    );
    assertApproxEqAbs(
      IHub(CORE_HUB).getSpokeTotalOwed(CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP),
      _payout,
      2,
      'swap debt on the core hub'
    );
    (uint128 amountVault, uint128 drawn, uint128 sharesOwed, ) = swap.vaultsInfo(VAULT_1);
    assertEq(amountVault, 1e8, 'escrowed vault');
    assertEq(drawn, _payout, 'escrow drawn');
    assertEq(
      IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP),
      sharesOwed,
      'escrow shares'
    );
    assertEq(adapter.vaultOwner(VAULT_1), BTC_VAULT_SWAP, 'vault owner');
    assertEq(adapter.getVaultUsageStatus(VAULT_1), VAULT_LLP_OWNED, 'vault held by the swap');
    assertEq(_suppliedVaultBtc(_proxy()), 0, 'collateral left');

    _arbitrage();
    assertEq(IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP), 0, 'repaid');
    assertEq(IHub(CORE_HUB).getSpokeDeficitRay(CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP), 0, 'deficit');
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
    IERC20(WBTC).approve(BTC_VAULT_SWAP, type(uint256).max);
    vm.expectRevert(IApplicationRegistry.UnauthorizedVaultKeeper.selector);
    swap.swapExitBtcForVault(VAULT_1, type(uint256).max);
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
    address keeper = _vaultKeeper();
    deal(WBTC, keeper, 2e8);
    vm.prank(keeper);
    IERC20(WBTC).approve(BTC_VAULT_SWAP, type(uint256).max);

    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).pause();
    vm.expectRevert(IBTCVaultSwapFlows.EnforcedPause.selector);
    vm.prank(keeper);
    swap.swapExitBtcForVault(VAULT_1, type(uint256).max);
    assertGt(IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP), 0, 'debt');

    vm.prank(V4_SECURITY_COUNCIL);
    IBTCVaultSwap(BTC_VAULT_SWAP).unpause();
    vm.prank(keeper);
    swap.swapExitBtcForVault(VAULT_1, type(uint256).max);
    assertEq(IHub(CORE_HUB).getSpokeDrawnShares(CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP), 0, 'repaid');
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
      maxExitBtc: type(uint256).max,
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
    _activate(VAULT_1, 1e8);
    _mockVaultAmounts(_one(VAULT_1), _one(1e8));
    _activate(VAULT_2, 1e8);
    bytes32[] memory vaultIds = new bytes32[](2);
    vaultIds[0] = VAULT_1;
    vaultIds[1] = VAULT_2;
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1e8;
    amounts[1] = 1e8;
    _mockVaultAmounts(vaultIds, amounts);
    _mockVaultAmounts(_one(VAULT_2), _one(1e8));
    _unfreezeAdapter();

    uint256 borrowed = (2 * _price(VAULT_BTC_RESERVE_ID) * 75_00) / 10_000 / 100;
    vm.prank(user);
    adapter.borrowFromCorePosition(CORE_USDC_RESERVE_ID, borrowed, user);
    _scaleBtcPrices(94_00);
    address proxy = _proxy();
    _debt = _usdcDebt(proxy);
    _fundLiquidator({usdc: _debt * 2, wbtc: 1e8});

    // too little debt to consume the first vault
    vm.expectRevert(IAaveAdapterFlows.InvalidPostLiquidationState.selector);
    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: 1_000e6,
      maxExitBtc: type(uint256).max,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });

    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: type(uint256).max,
      claimerBtcPubKey: CLAIMER_BTC_KEY
    });
    assertEq(_suppliedVaultBtc(proxy), 1e8, 'one vault left');
    assertEq(adapter.getPosition(user).vaultIds.length, 1, 'vault count');
    assertEq(adapter.getPosition(user).vaultIds[0], VAULT_2, 'second vault left');
    assertEq(IERC20(VAULT_BTC).totalSupply(), 1e8, 'vaultBTC supply');
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
    IBTCVaultSwap(BTC_VAULT_SWAP).freeze();

    vm.expectRevert(IBTCVaultSwapFlows.EnforcedFreeze.selector);
    vm.prank(liquidator);
    adapter.liquidateWithLLP({
      borrower: user,
      llp: BTC_VAULT_SWAP,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: type(uint256).max,
      minPayouts: new TokenAmount[](0)
    });

    vm.prank(liquidator);
    adapter.liquidate({
      borrower: user,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: type(uint256).max,
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
      spoke: BTC_VAULT_SWAP,
      drawCap: 0
    });

    vm.expectRevert(abi.encodeWithSelector(IHub.DrawCapExceeded.selector, 0));
    vm.prank(liquidator);
    adapter.liquidateWithLLP({
      borrower: user,
      llp: BTC_VAULT_SWAP,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: type(uint256).max,
      minPayouts: new TokenAmount[](0)
    });
  }

  /// @dev Babylon caps a position at 2 BTC at launch, so a single escrow uses at most a tenth of
  /// the 20 WBTC credit line.
  function test_positionAboveBabylonLimitCannotBeOpened() public {
    _executePayload();
    BTCVaultBasicInfo memory info = _vaultInfo(user, 20e8);
    _mockRegistryForVault(VAULT_1, info);
    vm.expectRevert(IAaveAdapterFlows.InvalidPositionSizes.selector);
    vm.prank(registry);
    adapter.activateVault(VAULT_1, info, '');

    _activate(VAULT_1, 1e8);
    _mockVaultAmounts(_one(VAULT_1), _one(1e8));
    _activate(VAULT_2, 1e8);
    assertEq(_suppliedVaultBtc(_proxy()), 2e8, 'position at the limit');
  }

  // ─── helpers ───

  function _openAndBorrow(uint256 ltvBps) internal returns (uint256 borrowed) {
    _executePayload();
    _activate(VAULT_1, 1e8);
    _mockVaultAmounts(_one(VAULT_1), _one(1e8));
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
      llp: BTC_VAULT_SWAP,
      debtReserveId: CORE_USDC_RESERVE_ID,
      maxDebtToRepay: _debt * 2,
      maxExitBtc: type(uint256).max,
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
    address keeper = _vaultKeeper();
    deal(WBTC, keeper, 2e8);
    vm.startPrank(keeper);
    IERC20(WBTC).approve(BTC_VAULT_SWAP, type(uint256).max);
    uint256 paid = swap.swapExitBtcForVault(VAULT_1, type(uint256).max);
    vm.stopPrank();
    assertGe(paid, _payout, 'keeper repays at least the draw');
  }

  /// @dev The vault is recorded under the current vault keeper roster.
  function _mockVaultProtocolInfo(bytes32 vaultId) internal {
    BTCVaultProtocolInfo memory protocolInfo;
    protocolInfo.appVaultKeepersVersion = IApplicationRegistry(applicationRegistry)
      .getCurrentVaultKeepersVersion(AAVE_ADAPTER);
    vm.mockCall(
      registry,
      abi.encodeCall(IBTCVaultRegistry.getBtcVaultProtocolInfo, (vaultId)),
      abi.encode(protocolInfo)
    );
  }

  function _vaultKeeper() internal view returns (address) {
    AddressBTCKeyPair[] memory keepers = IApplicationRegistry(applicationRegistry)
      .getCurrentVaultKeepers(AAVE_ADAPTER);
    assertGt(keepers.length, 0, 'no vault keeper registered');
    return keepers[0].ethAddress;
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
    uint256 expectedFee = (1e8 * vaultBtcPrice * (bonus - 100_00) * 10_00) /
      (bonus * 100_00) /
      wbtcPrice;
    assertApproxEqAbs(_fee, expectedFee, 2, 'fee is 10% of the bonus');

    // debt value at the oracle USDC price, 8 decimals, USDC has 6
    uint256 seizedBySpoke = (_debt * _price(CORE_USDC_RESERVE_ID) * bonus * 1e8) /
      (vaultBtcPrice * 100_00 * 1e6);
    uint256 expectedFairness = ((1e8 - seizedBySpoke) * 100_00 * vaultBtcPrice) / bonus / wbtcPrice;
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
        applicationEntryPoint: AAVE_ADAPTER,
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
      abi.encodeWithSelector(IBTCVaultRegistry.redeemVaultForAVK.selector, vaultId),
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
    IERC20(USDC).approve(AAVE_ADAPTER, type(uint256).max);
    IERC20(WBTC).approve(AAVE_ADAPTER, type(uint256).max);
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
