// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

/// @dev Data needed by the AdapterHook for the postHook execution.
struct HookOrderData {
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
  /// @notice Deploys an Adapter Instance and transfers the FlashLoaned assets to it (must have been initiated before).
  /// @param adapterImplementation The address of the Adapter Instance implementation to clone.
  /// @param hookData The HookOrderData struct containing the order details & postHook parameters.
  function deployAndTransferFlashLoan(
    address adapterImplementation,
    HookOrderData memory hookData
  ) external;

  /// @notice Returns the determined address of an Adapter Instance to clone based on a specific Order.
  /// @param adapterImplementation The address of the Adapter Implementation to clone.
  /// @param hookData The HookOrderData struct containing the order details & postHook parameters.
  /// @return The determined address of the Adapter Instance.
  function getInstanceDeterministicAddress(
    address adapterImplementation,
    HookOrderData memory hookData
  ) external view returns (address);

  /// @notice FlashLoanRouter contract.
  function ROUTER() external view returns (IFlashLoanRouter);

  /// @notice Returns the domain separator used in the EIP712 encoding of the AdapterOrderSig struct.
  /// @return The domain separator.
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  /// @notice Returns whether an Adapter implementation can be cloned by the Factory.
  function isAdapterImplementation(address adapterImplementation) external view returns (bool);
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
  function addSolver(address solver) external;
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

  /// @dev The order EIP-712 type hash for the [`GPv2Order.Data`] struct.
  bytes32 internal constant TYPE_HASH =
    hex'd5a25ba2e97094ad7d83dc28a6572da797d6b3e7fc6663bd93efb789fc17e489';

  /// @dev The marker value for a sell order for computing the order struct hash.
  bytes32 internal constant KIND_SELL =
    hex'f3b277728b3fee749481eb3e0b3b48980dbbab78658fc419025cb16eee346775';

  /// @dev The OrderKind marker value for a buy order for computing the order struct hash.
  bytes32 internal constant KIND_BUY =
    hex'6ed88e868af0a1983e3886d5f3e95a2fafbd6c3450bc229e27342283dc429ccc';

  /// @dev The TokenBalance marker value for using direct ERC20 balances for computing the order struct hash.
  bytes32 internal constant BALANCE_ERC20 =
    hex'5a28e9363bb942b639270062aa6bb295f434bcdfc42c97267bf003f272060dc9';

  /// @dev The TokenBalance marker value for using Balancer Vault external balances.
  bytes32 internal constant BALANCE_EXTERNAL =
    hex'abee3b73373acd583a130924aad6dc38cfdc44ba0555ba94ce2ff63980ea0632';

  /// @dev The TokenBalance marker value for using Balancer Vault internal balances.
  bytes32 internal constant BALANCE_INTERNAL =
    hex'4ac99ace14ee0a5ef932dc609df0943ab7ac16b7583634612f8dc35a4289a6ce';

  /// @dev Marker address used to indicate that the receiver of the trade
  /// proceeds should the owner of the order.
  address internal constant RECEIVER_SAME_AS_OWNER = address(0);

  /// @dev The byte length of an order unique identifier.
  uint256 internal constant UID_LENGTH = 56;

  function actualReceiver(
    Data memory order,
    address owner
  ) internal pure returns (address receiver) {
    if (order.receiver == RECEIVER_SAME_AS_OWNER) {
      receiver = owner;
    } else {
      receiver = order.receiver;
    }
  }

  function hash(
    Data memory order,
    bytes32 domainSeparator
  ) internal pure returns (bytes32 orderDigest) {
    bytes32 structHash;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      let dataStart := sub(order, 32)
      let temp := mload(dataStart)
      mstore(dataStart, TYPE_HASH)
      structHash := keccak256(dataStart, 416)
      mstore(dataStart, temp)
    }

    // solhint-disable-next-line no-inline-assembly
    assembly {
      let freeMemoryPointer := mload(0x40)
      mstore(freeMemoryPointer, '\x19\x01')
      mstore(add(freeMemoryPointer, 2), domainSeparator)
      mstore(add(freeMemoryPointer, 34), structHash)
      orderDigest := keccak256(freeMemoryPointer, 66)
    }
  }

  function packOrderUidParams(
    bytes memory orderUid,
    bytes32 orderDigest,
    address owner,
    uint32 validTo
  ) internal pure {
    require(orderUid.length == UID_LENGTH, 'GPv2: uid buffer overflow');

    // solhint-disable-next-line no-inline-assembly
    assembly {
      mstore(add(orderUid, 56), validTo)
      mstore(add(orderUid, 52), owner)
      mstore(add(orderUid, 32), orderDigest)
    }
  }

  function extractOrderUidParams(
    bytes calldata orderUid
  ) internal pure returns (bytes32 orderDigest, address owner, uint32 validTo) {
    require(orderUid.length == UID_LENGTH, 'GPv2: invalid uid');

    // solhint-disable-next-line no-inline-assembly
    assembly {
      orderDigest := calldataload(orderUid.offset)
      owner := shr(96, calldataload(add(orderUid.offset, 32)))
      validTo := shr(224, calldataload(add(orderUid.offset, 52)))
    }
  }
}

/// @title Gnosis Protocol v2 Trade Library.
/// @author Gnosis Developers
library GPv2Trade {
  using GPv2Order for GPv2Order.Data;
  using GPv2Order for bytes;

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

  function execute(Data calldata interaction) internal {
    address target = interaction.target;
    uint256 value = interaction.value;
    bytes calldata callData = interaction.callData;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      let freeMemoryPointer := mload(0x40)
      calldatacopy(freeMemoryPointer, callData.offset, callData.length)
      if iszero(call(gas(), target, value, freeMemoryPointer, callData.length, 0, 0)) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }

  function selector(Data calldata interaction) internal pure returns (bytes4 result) {
    bytes calldata callData = interaction.callData;
    if (callData.length >= 4) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        result := calldataload(callData.offset)
      }
    }
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
  ) external pure returns (GPv2Order.Data memory) {
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

  /// @notice A type that wraps a pointer to raw data in memory.
  type EncodedData is uint256;

  uint256 private constant OFFSET_BORROWER = 32 - 12;
  uint256 private constant OFFSET_LENDER = 32 + 1 * 20 - 12;
  uint256 private constant OFFSET_TOKEN = 32 + 2 * 20 - 12;

  /// @notice The number of sequential bytes required to encode a loan in memory.
  uint256 internal constant ENCODED_LOAN_BYTE_SIZE = 32 + 3 * 20;

  function store(EncodedData encodedLoan, Data calldata loan) internal pure {
    uint256 amount = loan.amount;
    address borrower = loan.borrower;
    address lender = loan.lender;
    IERC20 token = loan.token;

    assembly ('memory-safe') {
      mstore(add(encodedLoan, OFFSET_TOKEN), token)
      mstore(add(encodedLoan, OFFSET_LENDER), lender)
      mstore(add(encodedLoan, OFFSET_BORROWER), borrower)
      mstore(encodedLoan, amount)
    }
  }

  function decode(
    EncodedData loan
  ) internal pure returns (uint256 amount, address borrower, address lender, IERC20 token) {
    assembly ('memory-safe') {
      amount := mload(loan)
      borrower := mload(add(loan, OFFSET_BORROWER))
      lender := mload(add(loan, OFFSET_LENDER))
      token := mload(add(loan, OFFSET_TOKEN))
    }
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
    IERC20(sellToken).transferFrom(caller, address(this), takeAmount);
    IERC20(buyToken).transfer(receiver, buyAmount);
  }
}
