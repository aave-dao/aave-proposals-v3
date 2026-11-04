// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ISignatureGateway, ISpoke, ITakerPositionManager} from 'aave-address-book/AaveV4.sol';

/// @dev Data needed by the AdapterHook for the postHook execution.
struct HookOrderDataV3 {
  // Owner of the AdapterHook Instance (the user signing the Order)
  address owner;
  // Address of the Instance to be receiver of the Order (as specified in the GPv2Order.Data)
  address receiver;
  // The asset being sold (as specified in the GPv2Order.Data)
  address sellToken;
  // The asset being bought (as specified in the GPv2Order.Data)
  address buyToken;
  // The amount to sell (as specified in the GPv2Order.Data)
  uint256 sellAmount;
  // The amount to buy (as specified in the GPv2Order.Data)
  uint256 buyAmount;
  // The kind of swap (as specified in the GPv2Order.Data)
  bytes32 kind;
  // The expiry date of the Order (as specified in the GPv2Order.Data)
  uint256 validTo;
  // The amount taken as Flashloan
  uint256 flashLoanAmount;
  // The fee amount to be repaid on top of the flashLoanAmount
  uint256 flashLoanFeeAmount;
  // The amount of sell token given as parameter for the postHook
  uint256 hookSellTokenAmount;
  // The amount of buy token given as parameter for the postHook
  uint256 hookBuyTokenAmount;
}

interface IBaseAdapterFactory {
  /// @notice FlashLoanRouter contract.
  function ROUTER() external view returns (IFlashLoanRouter);

  /// @notice Returns the domain separator used in the EIP712 encoding of the AdapterOrderSig struct.
  /// @return The domain separator.
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  /// @notice Returns whether an Adapter implementation can be cloned by the Factory.
  function isAdapterImplementation(address adapterImplementation) external view returns (bool);
}

interface IBaseAdapterV3Factory is IBaseAdapterFactory {
  /// @notice Deploys an Adapter Instance and transfers the FlashLoaned assets to it (must have been initiated before).
  /// @param adapterImplementation The address of the Adapter Instance implementation to clone.
  /// @param hookData The HookOrderDataV3 struct containing the order details & postHook parameters.
  function deployAndTransferFlashLoan(
    address adapterImplementation,
    HookOrderDataV3 memory hookData
  ) external;

  /// @notice Returns the determined address of an Adapter Instance to clone based on a specific Order.
  /// @param adapterImplementation The address of the Adapter Implementation to clone.
  /// @param hookData The HookOrderDataV3 struct containing the order details & postHook parameters.
  /// @return The determined address of the Adapter Instance.
  function getInstanceDeterministicAddress(
    address adapterImplementation,
    HookOrderDataV3 memory hookData
  ) external view returns (address);
}

interface IOwnable {
  function owner() external view returns (address);
}

interface IFlashLoanRouter {
  /// @notice Request all flash loan specified in the input and, after that,
  /// executes the specified settlement.
  /// @dev It's the solver's responsibility to make sure the loan is specified
  /// correctly. The router contract offers no validation of the fact that
  /// the flash loan proceeds are available for spending.
  ///
  /// The repayment of a flash loan is different based on the protocol. For
  /// example, some expect to retrieve the funds from this borrower contract
  /// through `transferFrom`, while other check the lender balance is as
  /// expected after the flash loan has been processed. The executed
  /// settlement must be built to cater to the needs of the specified lender.
  ///
  /// A settlement can be executed at most once in a call. The settlement
  /// data cannot change during execution. Only the settle function can be
  /// called. All of this is also the case if the lender is untrusted.
  /// @param loans The list of flash loans to be requested before the
  /// settlement is executed. The loans will be requested in the specified
  /// order.
  /// @param settlement The ABI-encoded bytes for a call to `settle()` (as
  /// in `abi.encodeCall`).
  function flashLoanAndSettle(Loan.Data[] calldata loans, bytes calldata settlement) external;

  /// @notice The settlement contract supported by this router.
  function settlementContract() external view returns (IGPv2Settlement);
}

interface IGPv2Settlement {
  function authenticator() external view returns (IGPv2Authenticator);
  function settle(
    IERC20[] calldata tokens,
    uint256[] calldata clearingPrices,
    GPv2Trade.Data[] calldata trades,
    GPv2Interaction.Data[][3] calldata interactions
  ) external;
}

interface IGPv2Authenticator {
  function isSolver(address solver) external view returns (bool);
}

struct Permit {
  uint256 amount;
  uint256 deadline;
  uint8 v;
  bytes32 r;
  bytes32 s;
}

interface ICollateralSwapAaveV3Adapter {
  /// @notice PostHook to swap the collateral liquidity of an user.
  /// @dev Uses a flashloan & swap to supply the new collateral and withdraw the user's old collateral to repay the Flashloan.
  /// @param erc20Permit The permit data for the aToken to pull and withdraw.
  function collateralSwapWithFlashLoan(Permit calldata erc20Permit) external;
}

function _getEmptyPermitSig() pure returns (Permit memory permit) {
  permit = Permit({amount: 0, deadline: 0, v: 0, r: bytes32(0), s: bytes32(0)});
}

/// @dev Data needed by the Aave V4 AdapterHook for the postHook execution.
struct HookOrderDataV4 {
  address owner;
  address receiver;
  address sellToken;
  address buyToken;
  uint256 sellAmount;
  uint256 buyAmount;
  bytes32 kind;
  uint256 validTo;
  uint256 flashLoanAmount;
  uint256 flashLoanFeeAmount;
  address spoke;
  address sellAssetHub;
  address buyAssetHub;
  uint256 hookSellTokenAmount;
  uint256 hookBuyTokenAmount;
}

interface IBaseAdapterV4Factory is IBaseAdapterFactory {
  function deployAndTransferFlashLoan(
    address adapterImplementation,
    HookOrderDataV4 memory hookData
  ) external;

  function getInstanceDeterministicAddress(
    address adapterImplementation,
    HookOrderDataV4 memory hookData
  ) external view returns (address);
}

struct PositionManagersPermit {
  ISpoke.SetUserPositionManagers params;
  bytes signature;
}

struct WithdrawPermit {
  ITakerPositionManager.WithdrawPermit params;
  bytes signature;
}

struct SetUsingAsCollateralPermit {
  ISignatureGateway.SetUsingAsCollateral params;
  bytes signature;
}

interface ICollateralSwapAaveV4Adapter {
  function GIVER_POSITION_MANAGER() external view returns (address);

  function TAKER_POSITION_MANAGER() external view returns (address);

  /// @dev Permits with a zero deadline are skipped, so on-chain approvals can stand in for them.
  function collateralSwapWithFlashLoan(
    PositionManagersPermit calldata positionManagersPermit,
    WithdrawPermit calldata withdrawPermit,
    SetUsingAsCollateralPermit calldata setUsingAsCollateralPermit
  ) external;
}

/// @title Gnosis Protocol v2 Order Library
/// @author Gnosis Developers
library GPv2Order {
  /// @dev The complete data for a Gnosis Protocol order. This struct contains
  /// all order parameters that are signed for submitting to GP.
  struct Data {
    IERC20 sellToken;
    IERC20 buyToken;
    address receiver;
    uint256 sellAmount;
    uint256 buyAmount;
    uint32 validTo;
    bytes32 appData;
    uint256 feeAmount;
    bytes32 kind;
    bool partiallyFillable;
    bytes32 sellTokenBalance;
    bytes32 buyTokenBalance;
  }

  /// @dev The TokenBalance marker value for using direct ERC20 balances for computing the order struct hash.
  bytes32 internal constant BALANCE_ERC20 =
    hex'5a28e9363bb942b639270062aa6bb295f434bcdfc42c97267bf003f272060dc9';
}

/// @title Gnosis Protocol v2 Trade Library.
/// @author Gnosis Developers
library GPv2Trade {
  /// @dev A struct representing a trade to be executed as part a batch settlement.
  struct Data {
    uint256 sellTokenIndex;
    uint256 buyTokenIndex;
    address receiver;
    uint256 sellAmount;
    uint256 buyAmount;
    uint32 validTo;
    bytes32 appData;
    uint256 feeAmount;
    uint256 flags;
    uint256 executedAmount;
    bytes signature;
  }
}

/// @title Gnosis Protocol v2 Interaction Library
/// @author Gnosis Developers
library GPv2Interaction {
  /// @dev Interaction data for performing arbitrary contract interactions.
  struct Data {
    address target;
    uint256 value;
    bytes callData;
  }
}

struct SwapOrder {
  address trader;
  bytes32 kind;
  address sellToken;
  address buyToken;
  uint256 sellAmount;
  uint256 buyAmount;
  uint256 feeAmount;
  address receiver;
  uint32 validTo;
}

library SwapOrderToGPv2OrderLib {
  function convertToGPv2Order(
    SwapOrder memory order
  ) internal pure returns (GPv2Order.Data memory) {
    return
      GPv2Order.Data({
        kind: order.kind,
        partiallyFillable: false,
        sellToken: IERC20(order.sellToken),
        buyToken: IERC20(order.buyToken),
        sellAmount: order.sellAmount,
        buyAmount: order.buyAmount,
        feeAmount: order.feeAmount,
        validTo: order.validTo,
        appData: bytes32(uint256(1)), // mock here because we already encode the interactions
        sellTokenBalance: GPv2Order.BALANCE_ERC20,
        buyTokenBalance: GPv2Order.BALANCE_ERC20,
        receiver: order.receiver
      });
  }
}

library Loan {
  /// @notice The representation of a flash-loan request by the flash-loan router.
  struct Data {
    /// @notice The amount of funds requested from the lender.
    uint256 amount;
    /// @notice The contract that directly requests the flash loan from the
    /// lender and eventually calls back the router.
    address borrower;
    /// @notice The contract that loans out the funds to the borrower.
    address lender;
    /// @notice The token that is requested in the flash loan.
    IERC20 token;
  }
}

contract MockBasicPool {
  function swap(
    address sellToken,
    address buyToken,
    uint256 sellAmount,
    uint256 buyAmount,
    address caller,
    address receiver
  ) external {
    // Because Settlement contract only takes the exact amount to settle based on given prices,
    // so we don't want to pull more than the contract has.
    uint256 callerFullBalance = IERC20(sellToken).balanceOf(caller);
    uint256 takeAmount = sellAmount > callerFullBalance ? callerFullBalance : sellAmount;
    _safeCall(sellToken, abi.encodeCall(IERC20.transferFrom, (caller, address(this), takeAmount)));
    _safeCall(buyToken, abi.encodeCall(IERC20.transfer, (receiver, buyAmount)));
  }

  /// @dev Accepts tokens that return no data on transfer, such as USDT on Ethereum.
  function _safeCall(address token, bytes memory data) private {
    (bool success, bytes memory returnData) = token.call(data);
    require(
      success && (returnData.length == 0 || abi.decode(returnData, (bool))),
      'MockBasicPool: transfer failed'
    );
  }
}
