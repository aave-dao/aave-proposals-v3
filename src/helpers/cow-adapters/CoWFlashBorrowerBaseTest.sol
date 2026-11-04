// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

import {IPool} from 'aave-address-book/AaveV3.sol';
import {ISpoke, ITakerPositionManager} from 'aave-address-book/AaveV4.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

import {GPv2Interaction, GPv2Order, GPv2Trade, HookOrderDataV3, HookOrderDataV4, IBaseAdapterFactory, IBaseAdapterV3Factory, IBaseAdapterV4Factory, ICollateralSwapAaveV3Adapter, ICollateralSwapAaveV4Adapter, IFlashLoanRouter, IGPv2Settlement, IGPv2Authenticator, IOwnable, Loan, MockBasicPool, PositionManagersPermit, SetUsingAsCollateralPermit, SwapOrder, SwapOrderToGPv2OrderLib, WithdrawPermit, _getEmptyPermitSig} from 'src/helpers/cow-adapters/CoWFlashBorrowerTestUtils.sol';

/// @notice Shared collateral-swap-with-flash-loan and factory-ownership tests, parameterized
/// so they can run against any market in the proposal. Per-market test files inherit this
/// base, supply the market-specific values via virtual overrides, and keep their own
/// `test_defaultProposalExecution` / `test_isFlashBorrower` (which are typed against the
/// market's concrete `AaveV3<Market>` address-book module).
abstract contract CoWFlashBorrowerBaseTest is ProtocolV3TestBase {
  bytes32 internal constant KIND_SELL =
    hex'f3b277728b3fee749481eb3e0b3b48980dbbab78658fc419025cb16eee346775';

  /// @dev bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
  bytes32 internal constant ERC1967_ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  address internal constant COW_FACTORY_PROXY_ADMIN_V3 = 0x509Df56B5Aceb01674cC5506CA63bf41A4d68E8E;
  address internal constant COW_FACTORY_PROXY_ADMIN_V4 = 0xD7ef5094E88cE0f7f89bB6e5b3E3123aE3DF77Fa;
  address internal constant COW_FACTORY_PROXY_ADMIN_V3_PRIME =
    0xd4eDBfecd76c636a1313E057fF3f5cdFD6728649;
  address internal constant COW_FACTORY_PROXY_ADMIN_V3_LINEA =
    0xF6F22052Df7AE7c899178770075B6b2C3d700667;

  address internal constant COLLATERAL_SWAP_ADAPTER_V3 = 0xa1138627412212e53C208e220696f14b0185a82c;
  address internal constant COLLATERAL_SWAP_ADAPTER_V3_PRIME =
    0xdf36e299a5326dd284E3E7b5AD891b4262e32f0a;
  address internal constant COLLATERAL_SWAP_ADAPTER_V4 = 0xe8a2b6De869Ef989aA0F0f670A2Dd4064ED0A9a1;

  struct FactoryOwnership {
    address factory;
    address proxyAdmin;
  }

  struct FlashLoanParams {
    address borrower;
    address lender;
    address flashLoanAsset;
    uint256 flashLoanAmount;
    uint256 flashLoanFee;
  }

  /// @dev On V3, `userSupplied` / `adapterSupplied` are aToken balances and `userDebt` the
  /// variable debt token balance. On V4, they are read from the Spoke.
  struct PositionSnapshot {
    uint256 userBalance;
    uint256 userSupplied;
    uint256 userDebt;
    uint256 adapterBalance;
    uint256 adapterSupplied;
  }

  struct TestLocalVarsV3 {
    address trader;
    uint256 traderKey;
    address solver;
    IBaseAdapterV3Factory factory;
    address adapterImplementation;
    IGPv2Settlement settlement;
    uint256 sellAmount;
    address instance;
    IERC20[] tokens;
    uint256[] prices;
    PositionSnapshot sellInitial;
    PositionSnapshot buyInitial;
    PositionSnapshot sellFinal;
    PositionSnapshot buyFinal;
  }

  struct HookAmounts {
    uint256 flashLoanAmount;
    uint256 flashLoanFeeAmount;
    uint256 sellTokenAmount;
    uint256 buyTokenAmount;
  }

  struct EncodeSettlementParams {
    uint256 traderKey;
    IERC20[] tokens;
    uint256[] prices;
    GPv2Order.Data order;
    address preHookTarget;
    address postHookTarget;
    bytes preHookCallData;
    bytes postHookCallData;
    address settlement;
  }

  struct EncodeSettlementLocalVars {
    GPv2Trade.Data[] trades;
    GPv2Interaction.Data[] preInteractions;
    GPv2Interaction.Data[] intraInteractions;
    GPv2Interaction.Data[] postInteractions;
    GPv2Interaction.Data[][3] interactions;
  }

  struct CollateralSwapConfigV3 {
    address collateralAsset;
    address debtAsset;
    // Initial collateral amount supplied by the trader before the swap. On chains
    // where `debtAsset` has 0 LTV (so the swapped-in new collateral doesn't keep HF
    // healthy), set this larger than `sellAmount` so leftover original collateral
    // backstops the trader's remaining debt.
    uint256 collateralSeed;
    // Zero skips the borrow, for markets without a borrowable asset that has LTV > 0.
    uint256 debtSeed;
    // Amount of collateral being flash-loaned and sold. Must be ≤ `collateralSeed`.
    uint256 sellAmount;
    uint256 expectedBuyAmount;
  }

  struct CollateralSwapConfigV4 {
    address factory;
    ISpoke spoke;
    address hub;
    address collateralAsset;
    address debtAsset;
    uint256 collateralSeed;
    uint256 debtSeed;
    uint256 sellAmount;
    uint256 expectedBuyAmount;
  }

  struct TestLocalVarsV4 {
    address trader;
    uint256 traderKey;
    address solver;
    IGPv2Settlement settlement;
    uint256 collateralReserveId;
    uint256 debtReserveId;
    uint256 sellAmount;
    address instance;
    IERC20[] tokens;
    uint256[] prices;
    PositionSnapshot sellInitial;
    PositionSnapshot buyInitial;
    PositionSnapshot sellFinal;
    PositionSnapshot buyFinal;
  }

  /// @dev The V3 Pool used for seeding collateral / borrowing debt, reading aToken /
  /// variableDebtToken addresses, and as flash loan lender for both factories.
  function _poolV3() internal view virtual returns (IPool);

  /// @dev The V3 adapter factory whitelisted by the proposal on this market, i.e.
  /// `proposal.COW_V3_ADAPTER_FACTORY()`.
  function _cowFactoryV3() internal view virtual returns (address);

  /// @dev The CollateralSwap V3 adapter implementation registered on `_cowFactoryV3()`.
  function _collateralSwapAdapterV3() internal view virtual returns (address);

  /// @dev Expected owner of every factory and its ProxyAdmin, i.e. `Misc<Chain>.V4_SECURITY_COUNCIL`.
  function _cowAdaptersOwner() internal view virtual returns (address);

  /// @dev Every factory whitelisted by the proposal on this market, with its expected ProxyAdmin.
  function _factoryOwnerships() internal view virtual returns (FactoryOwnership[] memory);

  /// @dev Forwards to `GovV3Helpers.executePayload(vm, address(proposal))` from the
  /// per-market file. Untyped here so the base doesn't import any concrete proposal class.
  function _executePayload() internal virtual;

  /// @dev Per-market (collateral, debt) pair and amounts for the V3 swap test.
  function _collateralSwapConfigV3() internal view virtual returns (CollateralSwapConfigV3 memory);

  function test_factoryOwnership() public view {
    FactoryOwnership[] memory ownerships = _factoryOwnerships();
    for (uint256 i = 0; i < ownerships.length; i++) {
      address factory = ownerships[i].factory;
      address proxyAdmin = address(uint160(uint256(vm.load(factory, ERC1967_ADMIN_SLOT))));
      assertEq(IOwnable(factory).owner(), _cowAdaptersOwner(), 'factory owner');
      assertEq(proxyAdmin, ownerships[i].proxyAdmin, 'factory ProxyAdmin');
      assertEq(IOwnable(proxyAdmin).owner(), _cowAdaptersOwner(), 'ProxyAdmin owner');
    }
  }

  function test_collateralSwapWithFlashLoanV3_noFlashLoanFee() public {
    _testCollateralSwapWithFlashLoanNoFeeV3(true);
  }

  function test_collateralSwapWithFlashLoanV3_noFlashLoanFee_revertsWithoutPayload() public {
    _testCollateralSwapWithFlashLoanNoFeeV3(false);
  }

  /// @dev Without the payload the factory is not a flash borrower, so the Pool charges a premium
  /// the zero-fee order does not cover: the factory reverts with `InvalidFlashLoanAmount`, which
  /// the FlashLoanRouter rethrows as `Settlement reverted`.
  function _testCollateralSwapWithFlashLoanNoFeeV3(bool executePayload) internal {
    if (executePayload) _executePayload();

    CollateralSwapConfigV3 memory config = _collateralSwapConfigV3();
    IPool pool = _poolV3();

    TestLocalVarsV3 memory vars;
    (vars.trader, vars.traderKey) = makeAddrAndKey('Trader');
    vars.solver = makeAddr('solver');
    vars.factory = IBaseAdapterV3Factory(_cowFactoryV3());
    vars.adapterImplementation = _collateralSwapAdapterV3();
    assertTrue(vars.factory.isAdapterImplementation(vars.adapterImplementation));
    vars.settlement = _whitelistSolver(vars.factory, vars.solver);

    _seedPositionV3(config, vars.trader);

    address aToken = pool.getReserveAToken(config.collateralAsset);
    vars.sellAmount = IERC20(aToken).balanceOf(vars.trader);
    if (vars.sellAmount > config.sellAmount) vars.sellAmount = config.sellAmount;

    FlashLoanParams memory flashLoanParams = FlashLoanParams({
      borrower: address(vars.factory),
      lender: address(pool),
      flashLoanAsset: config.collateralAsset,
      flashLoanAmount: vars.sellAmount,
      flashLoanFee: 0
    });

    HookAmounts memory hookAmounts = HookAmounts({
      flashLoanAmount: flashLoanParams.flashLoanAmount,
      flashLoanFeeAmount: flashLoanParams.flashLoanFee,
      sellTokenAmount: vars.sellAmount,
      buyTokenAmount: config.expectedBuyAmount
    });

    SwapOrder memory order = SwapOrder({
      trader: vars.trader,
      kind: KIND_SELL,
      sellToken: config.collateralAsset,
      buyToken: config.debtAsset,
      sellAmount: vars.sellAmount - flashLoanParams.flashLoanFee,
      buyAmount: config.expectedBuyAmount,
      feeAmount: 0,
      validTo: 0xffffffff,
      receiver: address(0)
    });

    HookOrderDataV3 memory hookData = HookOrderDataV3({
      owner: vars.trader,
      receiver: address(0),
      sellToken: order.sellToken,
      buyToken: order.buyToken,
      sellAmount: order.sellAmount,
      buyAmount: order.buyAmount,
      kind: order.kind,
      validTo: order.validTo,
      hookSellTokenAmount: hookAmounts.sellTokenAmount,
      hookBuyTokenAmount: hookAmounts.buyTokenAmount,
      flashLoanAmount: hookAmounts.flashLoanAmount,
      flashLoanFeeAmount: hookAmounts.flashLoanFeeAmount
    });

    vars.instance = vars.factory.getInstanceDeterministicAddress(
      vars.adapterImplementation,
      hookData
    );
    vm.label(vars.instance, 'Adapter_Instance');
    order.receiver = vars.instance;
    hookData.receiver = vars.instance;

    vm.prank(vars.trader);
    IERC20(aToken).approve(vars.instance, type(uint256).max);

    vars.sellInitial = _getSnapshotV3(config.collateralAsset, vars.trader, vars.instance);
    vars.buyInitial = _getSnapshotV3(config.debtAsset, vars.trader, vars.instance);

    vars.tokens = new IERC20[](2);
    vars.tokens[0] = IERC20(config.collateralAsset);
    vars.tokens[1] = IERC20(config.debtAsset);
    vars.prices = new uint256[](2);
    vars.prices[0] = order.buyAmount;
    vars.prices[1] = order.sellAmount;

    bytes memory encodedSettlement = encodeSettlement(
      EncodeSettlementParams({
        traderKey: vars.traderKey,
        order: SwapOrderToGPv2OrderLib.convertToGPv2Order(order),
        tokens: vars.tokens,
        prices: vars.prices,
        preHookTarget: address(vars.factory),
        preHookCallData: abi.encodeCall(
          IBaseAdapterV3Factory.deployAndTransferFlashLoan,
          (vars.adapterImplementation, hookData)
        ),
        postHookTarget: vars.instance,
        postHookCallData: abi.encodeCall(
          ICollateralSwapAaveV3Adapter.collateralSwapWithFlashLoan,
          (_getEmptyPermitSig())
        ),
        settlement: address(vars.settlement)
      })
    );

    IFlashLoanRouter router = vars.factory.ROUTER();
    vm.startPrank(vars.solver);
    if (!executePayload) vm.expectRevert(bytes('Settlement reverted'));
    router.flashLoanAndSettle(
      _buildLoanData(
        flashLoanParams.borrower,
        flashLoanParams.lender,
        flashLoanParams.flashLoanAsset,
        flashLoanParams.flashLoanAmount
      ),
      encodedSettlement
    );
    vm.stopPrank();
    if (!executePayload) return;

    vars.sellFinal = _getSnapshotV3(config.collateralAsset, vars.trader, vars.instance);
    vars.buyFinal = _getSnapshotV3(config.debtAsset, vars.trader, vars.instance);

    // Trader's balances
    assertEq(
      vars.buyFinal.userBalance,
      vars.buyInitial.userBalance,
      'Trader buyToken Balance should stay the same'
    );
    assertEq(
      vars.sellFinal.userBalance,
      vars.sellInitial.userBalance,
      'Trader sellToken Balance should stay the same'
    );
    // Tolerance absorbs 1–2 wei of rounding on aToken mint/burn around supply/withdraw.
    assertApproxEqAbs(
      vars.buyFinal.userSupplied,
      vars.buyInitial.userSupplied + hookAmounts.buyTokenAmount,
      10,
      'aBuyToken Balance should increase'
    );
    assertApproxEqAbs(
      vars.sellFinal.userSupplied,
      vars.sellInitial.userSupplied - hookAmounts.sellTokenAmount,
      10,
      'aSellToken Balance should decrease'
    );
    assertEq(
      vars.buyFinal.userDebt,
      vars.buyInitial.userDebt,
      'Trader buyToken Variable Debt Balance should stay the same'
    );
    assertEq(
      vars.sellFinal.userDebt,
      vars.sellInitial.userDebt,
      'Trader sellToken Variable Debt Balance should stay the same'
    );

    // Instance final balances
    assertEq(vars.buyFinal.adapterBalance, 0, 'Adapter Instance buyToken Balance should be null');
    assertEq(vars.sellFinal.adapterBalance, 0, 'Adapter Instance sellToken Balance should be null');
    assertEq(vars.buyFinal.adapterSupplied, 0, 'Adapter Instance aBuyToken Balance should be null');
    assertEq(
      vars.sellFinal.adapterSupplied,
      0,
      'Adapter Instance aSellToken Balance should be null'
    );
  }

  /// @dev Collateral swap on an Aave V4 Spoke through the V4 factory, with the flash loan taken
  /// from this market's V3 Pool and signed with a zero fee. Opt-in per market, as only the
  /// networks with an Aave V4 deployment carry the V4 factory. Without the payload it must revert,
  /// as for `_testCollateralSwapWithFlashLoanNoFeeV3`.
  function _testCollateralSwapWithFlashLoanNoFeeV4(
    CollateralSwapConfigV4 memory config,
    bool executePayload
  ) internal {
    if (executePayload) _executePayload();

    TestLocalVarsV4 memory vars;
    (vars.trader, vars.traderKey) = makeAddrAndKey('Trader');
    vars.solver = makeAddr('solver');
    IBaseAdapterV4Factory factory = IBaseAdapterV4Factory(config.factory);
    assertTrue(factory.isAdapterImplementation(COLLATERAL_SWAP_ADAPTER_V4));
    vars.settlement = _whitelistSolver(factory, vars.solver);
    vars.collateralReserveId = _getReserveIdV4(config.spoke, config.hub, config.collateralAsset);
    vars.debtReserveId = _getReserveIdV4(config.spoke, config.hub, config.debtAsset);

    _seedPositionV4(config, vars);
    // The Hub rounds supply shares down, so the withdrawable amount can sit 1 wei below the seed.
    vars.sellAmount = config.spoke.getUserSuppliedAssets(vars.collateralReserveId, vars.trader);
    if (vars.sellAmount > config.sellAmount) vars.sellAmount = config.sellAmount;

    HookOrderDataV4 memory hookData = HookOrderDataV4({
      owner: vars.trader,
      receiver: address(0),
      sellToken: config.collateralAsset,
      buyToken: config.debtAsset,
      sellAmount: vars.sellAmount,
      buyAmount: config.expectedBuyAmount,
      kind: KIND_SELL,
      validTo: 0xffffffff,
      flashLoanAmount: vars.sellAmount,
      flashLoanFeeAmount: 0,
      spoke: address(config.spoke),
      sellAssetHub: config.hub,
      buyAssetHub: config.hub,
      hookSellTokenAmount: vars.sellAmount,
      hookBuyTokenAmount: config.expectedBuyAmount
    });
    vars.instance = factory.getInstanceDeterministicAddress(COLLATERAL_SWAP_ADAPTER_V4, hookData);
    vm.label(vars.instance, 'Adapter_Instance');
    hookData.receiver = vars.instance;

    _approveInstanceV4(config, vars);

    vars.sellInitial = _getSnapshotV4(config, vars.collateralReserveId, vars.trader, vars.instance);
    vars.buyInitial = _getSnapshotV4(config, vars.debtReserveId, vars.trader, vars.instance);

    SwapOrder memory order = SwapOrder({
      trader: vars.trader,
      kind: KIND_SELL,
      sellToken: config.collateralAsset,
      buyToken: config.debtAsset,
      sellAmount: vars.sellAmount,
      buyAmount: config.expectedBuyAmount,
      feeAmount: 0,
      validTo: 0xffffffff,
      receiver: vars.instance
    });

    // Zero-deadline permits: the trader granted the same approvals on-chain in `_approveInstanceV4`.
    PositionManagersPermit memory positionManagersPermit;
    WithdrawPermit memory withdrawPermit;
    SetUsingAsCollateralPermit memory setUsingAsCollateralPermit;

    vars.tokens = new IERC20[](2);
    vars.tokens[0] = IERC20(config.collateralAsset);
    vars.tokens[1] = IERC20(config.debtAsset);
    vars.prices = new uint256[](2);
    vars.prices[0] = order.buyAmount;
    vars.prices[1] = order.sellAmount;

    bytes memory encodedSettlement = encodeSettlement(
      EncodeSettlementParams({
        traderKey: vars.traderKey,
        order: SwapOrderToGPv2OrderLib.convertToGPv2Order(order),
        tokens: vars.tokens,
        prices: vars.prices,
        preHookTarget: config.factory,
        preHookCallData: abi.encodeCall(
          IBaseAdapterV4Factory.deployAndTransferFlashLoan,
          (COLLATERAL_SWAP_ADAPTER_V4, hookData)
        ),
        postHookTarget: vars.instance,
        postHookCallData: abi.encodeCall(
          ICollateralSwapAaveV4Adapter.collateralSwapWithFlashLoan,
          (positionManagersPermit, withdrawPermit, setUsingAsCollateralPermit)
        ),
        settlement: address(vars.settlement)
      })
    );

    IFlashLoanRouter router = factory.ROUTER();
    vm.startPrank(vars.solver);
    if (!executePayload) vm.expectRevert(bytes('Settlement reverted'));
    router.flashLoanAndSettle(
      _buildLoanData(config.factory, address(_poolV3()), config.collateralAsset, vars.sellAmount),
      encodedSettlement
    );
    vm.stopPrank();
    if (!executePayload) return;

    vars.sellFinal = _getSnapshotV4(config, vars.collateralReserveId, vars.trader, vars.instance);
    vars.buyFinal = _getSnapshotV4(config, vars.debtReserveId, vars.trader, vars.instance);

    assertEq(
      vars.buyFinal.userBalance,
      vars.buyInitial.userBalance,
      'Trader buyToken Balance should stay the same'
    );
    assertEq(
      vars.sellFinal.userBalance,
      vars.sellInitial.userBalance,
      'Trader sellToken Balance should stay the same'
    );
    // Tolerance absorbs share/asset rounding on the Hub around supply/withdraw.
    assertApproxEqAbs(
      vars.buyFinal.userSupplied,
      vars.buyInitial.userSupplied + config.expectedBuyAmount,
      10,
      'Trader supplied buyToken should increase'
    );
    assertApproxEqAbs(
      vars.sellFinal.userSupplied,
      vars.sellInitial.userSupplied - vars.sellAmount,
      10,
      'Trader supplied sellToken should decrease'
    );
    assertEq(vars.buyFinal.userDebt, vars.buyInitial.userDebt, 'Trader buyToken Debt unchanged');
    assertEq(vars.sellFinal.userDebt, vars.sellInitial.userDebt, 'Trader sellToken Debt unchanged');

    assertEq(vars.buyFinal.adapterBalance, 0, 'Adapter Instance buyToken Balance should be null');
    assertEq(vars.sellFinal.adapterBalance, 0, 'Adapter Instance sellToken Balance should be null');
    assertEq(vars.buyFinal.adapterSupplied, 0, 'Adapter Instance buyToken Supply should be null');
    assertEq(vars.sellFinal.adapterSupplied, 0, 'Adapter Instance sellToken Supply should be null');
  }

  function _whitelistSolver(
    IBaseAdapterFactory factory,
    address solver
  ) internal returns (IGPv2Settlement settlement) {
    settlement = factory.ROUTER().settlementContract();
    vm.mockCall(
      address(settlement.authenticator()),
      abi.encodeCall(IGPv2Authenticator.isSolver, (solver)),
      abi.encode(true)
    );
  }

  function _seedPositionV4(
    CollateralSwapConfigV4 memory config,
    TestLocalVarsV4 memory vars
  ) internal {
    deal2(config.collateralAsset, vars.trader, config.collateralSeed);

    vm.startPrank(vars.trader);
    IERC20(config.collateralAsset).approve(address(config.spoke), config.collateralSeed);
    config.spoke.supply(vars.collateralReserveId, config.collateralSeed, vars.trader);
    config.spoke.setUsingAsCollateral(vars.collateralReserveId, true, vars.trader);
    if (config.debtSeed != 0) {
      config.spoke.borrow(vars.debtReserveId, config.debtSeed, vars.trader);
    }
    vm.stopPrank();
  }

  /// @dev On-chain equivalents of the permits the postHook would otherwise carry.
  function _approveInstanceV4(
    CollateralSwapConfigV4 memory config,
    TestLocalVarsV4 memory vars
  ) internal {
    ICollateralSwapAaveV4Adapter adapter = ICollateralSwapAaveV4Adapter(COLLATERAL_SWAP_ADAPTER_V4);
    vm.startPrank(vars.trader);
    config.spoke.setUserPositionManager(adapter.GIVER_POSITION_MANAGER(), true);
    config.spoke.setUserPositionManager(adapter.TAKER_POSITION_MANAGER(), true);
    config.spoke.setUsingAsCollateral(vars.debtReserveId, true, vars.trader);
    ITakerPositionManager(adapter.TAKER_POSITION_MANAGER()).approveWithdraw(
      address(config.spoke),
      vars.collateralReserveId,
      vars.instance,
      vars.sellAmount
    );
    vm.stopPrank();
  }

  function _getReserveIdV4(
    ISpoke spoke,
    address hub,
    address underlying
  ) internal view returns (uint256) {
    uint256 count = spoke.getReserveCount();
    for (uint256 i = 0; i < count; i++) {
      ISpoke.Reserve memory reserve = spoke.getReserve(i);
      if (reserve.underlying == underlying && address(reserve.hub) == hub) return i;
    }
    revert('V4 reserve not listed');
  }

  function _getSnapshotV4(
    CollateralSwapConfigV4 memory config,
    uint256 reserveId,
    address account,
    address adapterInstance
  ) internal view returns (PositionSnapshot memory) {
    address underlying = config.spoke.getReserve(reserveId).underlying;
    return
      PositionSnapshot({
        userBalance: IERC20(underlying).balanceOf(account),
        userSupplied: config.spoke.getUserSuppliedAssets(reserveId, account),
        userDebt: config.spoke.getUserTotalDebt(reserveId, account),
        adapterBalance: IERC20(underlying).balanceOf(adapterInstance),
        adapterSupplied: config.spoke.getUserSuppliedAssets(reserveId, adapterInstance)
      });
  }

  function _seedPositionV3(CollateralSwapConfigV3 memory config, address trader) internal {
    IPool pool = _poolV3();
    deal2(config.collateralAsset, trader, config.collateralSeed);
    vm.startPrank(trader);
    IERC20(config.collateralAsset).approve(address(pool), config.collateralSeed);
    pool.supply(config.collateralAsset, config.collateralSeed, trader, 0);
    if (config.debtSeed != 0) pool.borrow(config.debtAsset, config.debtSeed, 2, 0, trader);
    vm.stopPrank();
  }

  function _getSnapshotV3(
    address underlying,
    address account,
    address adapterInstance
  ) internal view returns (PositionSnapshot memory) {
    IPool pool = _poolV3();
    address aToken = pool.getReserveAToken(underlying);
    address variableDebt = pool.getReserveVariableDebtToken(underlying);
    return
      PositionSnapshot({
        userBalance: IERC20(underlying).balanceOf(account),
        userSupplied: IERC20(aToken).balanceOf(account),
        userDebt: IERC20(variableDebt).balanceOf(account),
        adapterBalance: IERC20(underlying).balanceOf(adapterInstance),
        adapterSupplied: IERC20(aToken).balanceOf(adapterInstance)
      });
  }

  function encodeSettlement(EncodeSettlementParams memory params) internal returns (bytes memory) {
    EncodeSettlementLocalVars memory vars;

    // Deploy Mock Pool for swaps and pre-fund it with the buyAmount so the
    // intra-interaction `MockBasicPool.swap` can deliver buyToken to settlement.
    MockBasicPool basicSwapPool = new MockBasicPool();
    vm.label(address(basicSwapPool), 'BasicSwapPool');
    deal2(address(params.order.buyToken), address(basicSwapPool), params.order.buyAmount);

    // Pre Interactions
    vars.preInteractions = new GPv2Interaction.Data[](1);
    vars.preInteractions[0] = GPv2Interaction.Data({
      target: params.preHookTarget,
      value: 0,
      callData: params.preHookCallData
    });

    // Intra Interactions
    vars.intraInteractions = new GPv2Interaction.Data[](2);
    vars.intraInteractions[0] = GPv2Interaction.Data({
      target: address(params.order.sellToken),
      value: 0,
      callData: abi.encodeCall(IERC20.approve, (address(basicSwapPool), params.order.sellAmount))
    });
    vars.intraInteractions[1] = GPv2Interaction.Data({
      target: address(basicSwapPool),
      value: 0,
      callData: abi.encodeCall(
        MockBasicPool.swap,
        (
          address(params.order.sellToken),
          address(params.order.buyToken),
          params.order.sellAmount,
          params.order.buyAmount,
          params.settlement,
          params.settlement
        )
      )
    });

    // Post Interactions
    vars.postInteractions = new GPv2Interaction.Data[](1);
    vars.postInteractions[0] = GPv2Interaction.Data({
      target: params.postHookTarget,
      value: 0,
      callData: params.postHookCallData
    });

    // Encode and Sign
    vars.trades = new GPv2Trade.Data[](1);
    bytes memory signature = _signAndEncodeAdapterOrder(
      params.preHookTarget,
      params.order.receiver,
      params.order,
      params.traderKey
    );
    vars.trades[0] = deriveEip1271Trade(params.order, 0, 1, params.postHookTarget, signature);

    vars.interactions = [vars.preInteractions, vars.intraInteractions, vars.postInteractions];

    return
      abi.encodeCall(
        IGPv2Settlement.settle,
        (params.tokens, params.prices, vars.trades, vars.interactions)
      );
  }

  function _signAdapterOrder(
    address adapterFactory,
    address adapterInstance,
    GPv2Order.Data memory order,
    uint256 privateKey
  ) internal view returns (bytes memory signature) {
    bytes32 domainSeparator = IBaseAdapterFactory(adapterFactory).DOMAIN_SEPARATOR();
    // keccak256('AdapterOrderSig(address instance,address sellToken,address buyToken,uint256 sellAmount,uint256 buyAmount,bytes32 kind,uint32 validTo,bytes32 appData)')
    bytes32 ADAPTER_ORDER_TYPEHASH = 0x1ca15395c04ac473d5b42656e3782ae1fce1a113fdb5432b57f8fb0870fa3178;

    bytes32 structHash = keccak256(
      abi.encode(
        ADAPTER_ORDER_TYPEHASH,
        adapterInstance,
        address(order.sellToken),
        address(order.buyToken),
        order.sellAmount,
        order.buyAmount,
        order.kind,
        order.validTo,
        order.appData
      )
    );
    bytes32 digest = _toTypedDataHash(domainSeparator, structHash);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
    return abi.encodePacked(r, s, v);
  }

  function _signAndEncodeAdapterOrder(
    address adapterFactory,
    address adapterInstance,
    GPv2Order.Data memory order,
    uint256 privateKey
  ) internal view returns (bytes memory signature) {
    bytes memory userSignature = _signAdapterOrder(
      adapterFactory,
      adapterInstance,
      order,
      privateKey
    );
    signature = abi.encode(order, userSignature);
  }

  function deriveEip1271Trade(
    GPv2Order.Data memory order,
    uint256 sellTokenIndex,
    uint256 buyTokenIndex,
    address owner,
    bytes memory signature
  ) internal pure returns (GPv2Trade.Data memory) {
    return
      GPv2Trade.Data(
        sellTokenIndex,
        buyTokenIndex,
        order.receiver,
        order.sellAmount,
        order.buyAmount,
        order.validTo,
        order.appData,
        order.feeAmount,
        packFlags(order.kind),
        order.sellAmount,
        abi.encodePacked(owner, signature)
      );
  }

  function _buildLoanData(
    address borrower,
    address lender,
    address flashLoanAsset,
    uint256 flashLoanAmount
  ) internal pure returns (Loan.Data[] memory) {
    Loan.Data[] memory loans = new Loan.Data[](1);
    loans[0] = Loan.Data({
      amount: flashLoanAmount,
      borrower: borrower,
      lender: lender,
      token: IERC20(flashLoanAsset)
    });
    return loans;
  }

  function packFlags(bytes32 kind) internal pure returns (uint256) {
    // For information on flag encoding, see:
    // https://github.com/cowprotocol/contracts/blob/v1.0.0/src/contracts/libraries/GPv2Trade.sol#L70-L93
    uint256 sellOrderFlag = kind == KIND_SELL ? 0 : 1;
    uint256 fillOrKillFlag = 0 << 1;
    uint256 internalSellTokenBalanceFlag = 0 << 2;
    uint256 internalBuyTokenBalanceFlag = 0 << 4;
    uint256 eip1271Flag = 2 << 5;
    return
      sellOrderFlag |
      fillOrKillFlag |
      internalSellTokenBalanceFlag |
      internalBuyTokenBalanceFlag |
      eip1271Flag;
  }

  /// @dev Returns the keccak256 digest of an EIP-712 typed data (ERC-191 version `0x01`).
  function _toTypedDataHash(
    bytes32 domainSeparator,
    bytes32 structHash
  ) internal pure returns (bytes32 digest) {
    assembly ('memory-safe') {
      let ptr := mload(0x40)
      mstore(ptr, hex'19_01')
      mstore(add(ptr, 0x02), domainSeparator)
      mstore(add(ptr, 0x22), structHash)
      digest := keccak256(ptr, 0x42)
    }
  }
}
