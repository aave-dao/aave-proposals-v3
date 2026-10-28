// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import 'forge-std/Test.sol';

import {IPool} from 'aave-address-book/AaveV3.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

import {GPv2Interaction, GPv2Order, GPv2Trade, HookOrderData, IBaseAdapterFactory, ICollateralSwapAaveV3Adapter, IFlashLoanRouter, IGPv2Settlement, IGPv2Authenticator, IOwnable, Loan, MockBasicPool, Permit, SwapOrder, SwapOrderToGPv2OrderLib, _getEmptyPermitSig} from './CoWFlashBorrowerTestUtils.sol';

/// @notice Shared collateral-swap-with-flash-loan and factory-ownership tests, parameterized
/// so they can run against any market in the proposal. Per-market test files inherit this
/// base, supply the market-specific values via virtual overrides, and keep their own
/// `test_defaultProposalExecution` / `test_isFlashBorrower` (which are typed against the
/// market's concrete `AaveV3<Market>` address-book module).
abstract contract CoWFlashBorrowerBaseTest is ProtocolV3TestBase {
  bytes32 internal constant KIND_SELL =
    hex'f3b277728b3fee749481eb3e0b3b48980dbbab78658fc419025cb16eee346775';

  bytes32 internal constant KIND_BUY =
    hex'6ed88e868af0a1983e3886d5f3e95a2fafbd6c3450bc229e27342283dc429ccc';

  /// @dev bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
  bytes32 internal constant ERC1967_ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  address internal constant COW_ADAPTERS_OWNER = 0xA043B0EaD753d15fe6830d7be57f24432Dd773d1;

  address internal constant COW_V3_FACTORY_PROXY_ADMIN = 0x509Df56B5Aceb01674cC5506CA63bf41A4d68E8E;
  address internal constant COW_V4_FACTORY_PROXY_ADMIN = 0xD7ef5094E88cE0f7f89bB6e5b3E3123aE3DF77Fa;
  address internal constant COW_V3_PRIME_FACTORY_PROXY_ADMIN =
    0xd4eDBfecd76c636a1313E057fF3f5cdFD6728649;
  address internal constant COW_V3_LINEA_FACTORY_PROXY_ADMIN =
    0xF6F22052Df7AE7c899178770075B6b2C3d700667;

  address internal constant COLLATERAL_SWAP_V3_ADAPTER = 0xa1138627412212e53C208e220696f14b0185a82c;
  address internal constant COLLATERAL_SWAP_V3_PRIME_ADAPTER =
    0xdf36e299a5326dd284E3E7b5AD891b4262e32f0a;

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

  struct AssetBalances {
    uint256 poolBalance;
    uint256 userBalance;
    uint256 aTokenUserBalance;
    uint256 variableDebtUserBalance;
    uint256 adapterBalance;
    uint256 aTokenAdapterBalance;
  }

  struct TestLocalVars {
    Vm.Wallet traderWallet;
    address trader;
    address solver;
    IBaseAdapterFactory factory;
    address adapterImplementation;
    uint256 buyAmount;
    uint256 sellAmount;
    IERC20[] tokens;
    uint256[] prices;
    AssetBalances buyTokenInitialBalances;
    AssetBalances sellTokenInitialBalances;
    AssetBalances buyTokenFinalBalances;
    AssetBalances sellTokenFinalBalances;
  }

  struct HookAmounts {
    uint256 flashLoanAmount;
    uint256 flashLoanFeeAmount;
    uint256 sellTokenAmount;
    uint256 buyTokenAmount;
  }

  struct EncodeSettlementParams {
    Vm.Wallet user;
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

  struct CollateralSwapConfig {
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

  /// @dev The pool used for seeding collateral / borrowing debt and reading aToken /
  /// variableDebtToken addresses.
  function _pool() internal view virtual returns (IPool);

  /// @dev The V3 adapter factory whitelisted by the proposal on this market, i.e.
  /// `proposal.COW_V3_ADAPTER_FACTORY()`.
  function _cowV3Factory() internal view virtual returns (address);

  /// @dev The CollateralSwap V3 adapter implementation registered on `_cowV3Factory()`.
  function _collateralSwapAdapter() internal view virtual returns (address);

  /// @dev Every factory whitelisted by the proposal on this market, with its expected ProxyAdmin.
  function _factoryOwnerships() internal view virtual returns (FactoryOwnership[] memory);

  /// @dev Forwards to `GovV3Helpers.executePayload(vm, address(proposal))` from the
  /// per-market file. Untyped here so the base doesn't import any concrete proposal class.
  function _executePayload() internal virtual;

  /// @dev Per-market (collateral, debt) pair and amounts for the swap test.
  function _collateralSwapConfig() internal view virtual returns (CollateralSwapConfig memory);

  function test_factoryOwnership() public view {
    FactoryOwnership[] memory ownerships = _factoryOwnerships();
    for (uint256 i = 0; i < ownerships.length; i++) {
      address factory = ownerships[i].factory;
      address proxyAdmin = address(uint160(uint256(vm.load(factory, ERC1967_ADMIN_SLOT))));
      assertEq(IOwnable(factory).owner(), COW_ADAPTERS_OWNER, 'factory owner');
      assertEq(proxyAdmin, ownerships[i].proxyAdmin, 'factory ProxyAdmin');
      assertEq(IOwnable(proxyAdmin).owner(), COW_ADAPTERS_OWNER, 'ProxyAdmin owner');
    }
  }

  function test_collateralSwapWithFlashLoan_noFlashLoanFee() public {
    _executePayload();

    CollateralSwapConfig memory config = _collateralSwapConfig();
    IPool pool = _pool();

    TestLocalVars memory vars;
    vars.traderWallet = vm.createWallet('Trader');
    vars.trader = vars.traderWallet.addr;
    vars.solver = makeAddr('solver');
    vars.factory = IBaseAdapterFactory(_cowV3Factory());
    vars.adapterImplementation = _collateralSwapAdapter();
    assertTrue(vars.factory.isAdapterImplementation(vars.adapterImplementation));
    IGPv2Settlement settlement = vars.factory.ROUTER().settlementContract();
    address authenticator = address(settlement.authenticator());
    // Whitelist the test's solver and the FlashLoanRouter (which becomes msg.sender of
    // `Settlement.settle` once `flashLoanAndSettle` enters the settlement). Routers are
    // whitelisted on most chains' real CoW deployments but not all (e.g. Plasma).
    vm.mockCall(
      authenticator,
      abi.encodeCall(IGPv2Authenticator.isSolver, (vars.solver)),
      abi.encode(true)
    );
    vm.mockCall(
      authenticator,
      abi.encodeCall(IGPv2Authenticator.isSolver, (address(vars.factory.ROUTER()))),
      abi.encode(true)
    );

    _seedDebt(
      config.collateralAsset,
      config.debtAsset,
      vars.trader,
      config.collateralSeed,
      config.debtSeed
    );

    uint256 sellTokenAmount = config.sellAmount;

    vars.buyTokenInitialBalances = _getBalances(config.debtAsset, vars.trader);
    vars.sellTokenInitialBalances = _getBalances(config.collateralAsset, vars.trader);

    if (vars.sellTokenInitialBalances.aTokenUserBalance < sellTokenAmount) {
      sellTokenAmount = vars.sellTokenInitialBalances.aTokenUserBalance;
    }

    FlashLoanParams memory flashLoanParams = FlashLoanParams({
      borrower: address(vars.factory),
      lender: address(pool),
      flashLoanAsset: config.collateralAsset,
      flashLoanAmount: sellTokenAmount,
      flashLoanFee: 0
    });

    HookAmounts memory hookAmounts = HookAmounts({
      flashLoanAmount: flashLoanParams.flashLoanAmount,
      flashLoanFeeAmount: flashLoanParams.flashLoanFee,
      sellTokenAmount: sellTokenAmount,
      buyTokenAmount: config.expectedBuyAmount
    });

    SwapOrder memory order = SwapOrder({
      trader: vars.trader,
      kind: KIND_SELL,
      sellToken: config.collateralAsset,
      buyToken: config.debtAsset,
      sellAmount: sellTokenAmount - flashLoanParams.flashLoanFee,
      buyAmount: config.expectedBuyAmount,
      feeAmount: 0,
      validTo: 0xffffffff,
      receiver: address(0)
    });

    HookOrderData memory hookData = HookOrderData({
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

    address expectedInstanceAddress = vars.factory.getInstanceDeterministicAddress(
      vars.adapterImplementation,
      hookData
    );
    vm.label(expectedInstanceAddress, 'Adapter_Instance');
    order.receiver = expectedInstanceAddress;
    hookData.receiver = expectedInstanceAddress;

    vm.startPrank(vars.trader);
    address aToken = pool.getReserveAToken(order.sellToken);
    IERC20(aToken).approve(expectedInstanceAddress, type(uint256).max);
    vm.stopPrank();

    bytes memory preHookCalldata = abi.encodeCall(
      IBaseAdapterFactory.deployAndTransferFlashLoan,
      (vars.adapterImplementation, hookData)
    );

    bytes memory postHookCalldata = abi.encodeCall(
      ICollateralSwapAaveV3Adapter.collateralSwapWithFlashLoan,
      (_getEmptyPermitSig())
    );

    vars.tokens = new IERC20[](2);
    vars.tokens[0] = IERC20(config.collateralAsset);
    vars.tokens[1] = IERC20(config.debtAsset);
    vars.prices = new uint256[](2);
    vars.prices[0] = order.buyAmount;
    vars.prices[1] = order.sellAmount;

    bytes memory encodedSettlement = encodeSettlement(
      EncodeSettlementParams({
        user: vars.traderWallet,
        order: SwapOrderToGPv2OrderLib.convertToGPv2Order(order),
        tokens: vars.tokens,
        prices: vars.prices,
        preHookTarget: address(vars.factory),
        preHookCallData: preHookCalldata,
        postHookTarget: expectedInstanceAddress,
        postHookCallData: postHookCalldata,
        settlement: address(settlement)
      })
    );

    vm.startPrank(vars.solver);
    vars.factory.ROUTER().flashLoanAndSettle(
      _buildLoanData(
        flashLoanParams.borrower,
        flashLoanParams.lender,
        flashLoanParams.flashLoanAsset,
        flashLoanParams.flashLoanAmount
      ),
      encodedSettlement
    );
    vm.stopPrank();

    vars.buyTokenFinalBalances = _getBalances(
      config.debtAsset,
      vars.trader,
      expectedInstanceAddress
    );
    vars.sellTokenFinalBalances = _getBalances(
      config.collateralAsset,
      vars.trader,
      expectedInstanceAddress
    );

    // Trader's balances
    assertEq(
      vars.buyTokenFinalBalances.userBalance,
      vars.buyTokenInitialBalances.userBalance,
      'Trader buyToken Balance should stay the same'
    );
    assertEq(
      vars.sellTokenFinalBalances.userBalance,
      vars.sellTokenInitialBalances.userBalance,
      'Trader sellToken Balance should stay the same'
    );
    // Tolerance absorbs 1–2 wei of rounding on aToken mint/burn around supply/withdraw.
    assertApproxEqAbs(
      vars.buyTokenFinalBalances.aTokenUserBalance,
      vars.buyTokenInitialBalances.aTokenUserBalance + hookAmounts.buyTokenAmount,
      10,
      'aBuyToken Balance should increase'
    );
    assertApproxEqAbs(
      vars.sellTokenFinalBalances.aTokenUserBalance,
      vars.sellTokenInitialBalances.aTokenUserBalance - hookAmounts.sellTokenAmount,
      10,
      'aSellToken Balance should decrease'
    );
    assertEq(
      vars.buyTokenFinalBalances.variableDebtUserBalance,
      vars.buyTokenInitialBalances.variableDebtUserBalance,
      'Trader buyToken Variable Debt Balance should stay the same'
    );
    assertEq(
      vars.sellTokenFinalBalances.variableDebtUserBalance,
      vars.sellTokenInitialBalances.variableDebtUserBalance,
      'Trader sellToken Variable Debt Balance should stay the same'
    );

    // Instance final balances
    assertEq(
      vars.buyTokenFinalBalances.adapterBalance,
      0,
      'Adapter Instance buyToken Balance should be null'
    );
    assertEq(
      vars.sellTokenFinalBalances.adapterBalance,
      0,
      'Adapter Instance sellToken Balance should be null'
    );
    assertEq(
      vars.buyTokenFinalBalances.aTokenAdapterBalance,
      0,
      'Adapter Instance aBuyToken Balance should be null'
    );
    assertEq(
      vars.sellTokenFinalBalances.aTokenAdapterBalance,
      0,
      'Adapter Instance aSellToken Balance should be null'
    );
  }

  function _seedDebt(
    address collateralAsset,
    address debtAsset,
    address account,
    uint256 collateralAmount,
    uint256 debtAmount
  ) internal {
    _seedDeposit(collateralAsset, account, collateralAmount);
    if (debtAmount == 0) return;
    vm.startPrank(account);
    _pool().borrow(debtAsset, debtAmount, 2, 0, account);
    vm.stopPrank();
  }

  function _seedDeposit(address collateralAsset, address account, uint256 amount) internal {
    IPool pool = _pool();
    deal(collateralAsset, account, amount);
    vm.startPrank(account);
    IERC20(collateralAsset).approve(address(pool), amount);
    pool.supply(collateralAsset, amount, account, 0);
    vm.stopPrank();
  }

  function _getBalances(
    address underlying,
    address account
  ) internal view returns (AssetBalances memory) {
    IPool pool = _pool();
    address aToken = pool.getReserveAToken(underlying);
    address variableDebt = pool.getReserveVariableDebtToken(underlying);
    return
      AssetBalances({
        poolBalance: IERC20(underlying).balanceOf(aToken),
        userBalance: IERC20(underlying).balanceOf(account),
        aTokenUserBalance: IERC20(aToken).balanceOf(account),
        variableDebtUserBalance: IERC20(variableDebt).balanceOf(account),
        adapterBalance: 0,
        aTokenAdapterBalance: 0
      });
  }

  function _getBalances(
    address underlying,
    address account,
    address adapterInstance
  ) internal view returns (AssetBalances memory) {
    IPool pool = _pool();
    address aToken = pool.getReserveAToken(underlying);
    address variableDebt = pool.getReserveVariableDebtToken(underlying);
    return
      AssetBalances({
        poolBalance: IERC20(underlying).balanceOf(aToken),
        userBalance: IERC20(underlying).balanceOf(account),
        aTokenUserBalance: IERC20(aToken).balanceOf(account),
        variableDebtUserBalance: IERC20(variableDebt).balanceOf(account),
        adapterBalance: IERC20(underlying).balanceOf(adapterInstance),
        aTokenAdapterBalance: IERC20(aToken).balanceOf(adapterInstance)
      });
  }

  function encodeSettlement(EncodeSettlementParams memory params) internal returns (bytes memory) {
    EncodeSettlementLocalVars memory vars;

    // Deploy Mock Pool for swaps and pre-fund it with the buyAmount so the
    // intra-interaction `MockBasicPool.swap` can deliver buyToken to settlement.
    MockBasicPool basicSwapPool = new MockBasicPool();
    vm.label(address(basicSwapPool), 'BasicSwapPool');
    deal(address(params.order.buyToken), address(basicSwapPool), params.order.buyAmount);

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
      params.user.privateKey
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
