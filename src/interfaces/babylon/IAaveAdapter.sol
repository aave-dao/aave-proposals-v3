// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BTCVaultBasicInfo, TokenAmount, MarketPosition} from './BabylonTypes.sol';

/**
 * @dev Subset of Babylon's AaveAdapter, the liquidation manager of the Babylon Spoke.
 */
interface IAaveAdapter {
  error InvalidPositionSizes();

  error InvalidPostLiquidationState();

  error PositionNotHealthy();

  error ExcessiveExitBtcPayment();

  error TBV_Frozen();

  error TBV_Paused();

  error TBV_Unauthorized();

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

  function reorderVaults(bytes32[] memory permuted) external;

  function withdrawCollaterals(bytes32[] memory vaultIds) external returns (uint256);

  function pause() external;

  function unpause() external;

  function freeze() external;

  function unfreeze() external;

  function grantRole(bytes32 role, address account) external;

  function hasRole(bytes32 role, address account) external view returns (bool);

  function allowedToDeposit(
    address vaultReceiver,
    uint256 nVaultsToDeposit,
    uint256 amountToDeposit
  ) external view returns (bool);

  function getPosition(address borrower) external view returns (MarketPosition memory);

  function getVaultUsageStatus(bytes32 vaultId) external view returns (uint8);

  function vaultOwner(bytes32 vaultId) external view returns (address);

  function pauseState() external view returns (uint8);

  function liquidationFeeBps() external view returns (uint256);

  function interestFeeBps() external view returns (uint256);

  function applicationRecipient() external view returns (address);

  function interestFeeRecipient() external view returns (address);

  function setApplicationRecipient(address newRecipient) external;

  function setInterestFeeRecipient(address newRecipient) external;

  function BTC_VAULT_CORE_SPOKE() external view returns (address);

  function BTC_VAULT_HUB() external view returns (address);

  function BTC_VAULT_REGISTRY() external view returns (address);

  function APP_REGISTRY() external view returns (address);

  function EXIT_BTC_RESERVE_ID() external view returns (uint256);

  function VAULT_BTC_RESERVE_ID() external view returns (uint256);
}
