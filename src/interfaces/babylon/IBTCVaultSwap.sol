// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Subset of Babylon's BTCVaultSwap, the spoke that settles liquidated vaults against WBTC.
 */
interface IBTCVaultSwap {
  error EnforcedPause();

  error EnforcedFreeze();

  function setSwapFeeBps(uint256 sellDiscountBps, uint256 minimumProfitThresholdBps) external;

  function pause() external;

  function unpause() external;

  function freeze() external;

  function unfreeze() external;

  function swapExitBtcForVault(bytes32 vaultId, uint256 maxExitBtc) external returns (uint256);

  function vaultsInfo(bytes32 vaultId) external view returns (uint128, uint128, uint128, uint8);

  function sellDiscountBps() external view returns (uint256);

  function minimumProfitThresholdBps() external view returns (uint256);

  function isPaused() external view returns (bool);

  function isFrozen() external view returns (bool);

  function ADAPTER() external view returns (address);

  function HUB() external view returns (address);

  function EXIT_BTC() external view returns (address);

  function EXIT_BTC_ASSET_ID() external view returns (uint256);
}
