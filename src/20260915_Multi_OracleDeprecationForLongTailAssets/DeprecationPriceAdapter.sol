// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IChainlinkAggregator} from 'aave-helpers/src/interfaces/IChainlinkAggregator.sol';

/// @notice Fixed USD target, optionally converted to the ETH base currency used by V2.
contract DeprecationPriceAdapter {
  uint256 public immutable PRICE_USD;
  IChainlinkAggregator public immutable ETH_USD;
  uint8 public immutable decimals;
  string public description;

  constructor(uint256 priceUsd, address ethUsd, string memory description_) {
    require(priceUsd > 0 && priceUsd <= uint256(type(int256).max) / 1e18, 'INVALID_FIXED_PRICE');
    PRICE_USD = priceUsd;
    ETH_USD = IChainlinkAggregator(ethUsd);
    decimals = ethUsd == address(0) ? 8 : 18;
    if (ethUsd != address(0)) require(ETH_USD.decimals() == 8, 'INVALID_ETH_USD_DECIMALS');
    description = description_;
  }

  function latestAnswer() external view returns (int256) {
    if (address(ETH_USD) == address(0)) return int256(PRICE_USD);
    int256 ethUsd = ETH_USD.latestAnswer();
    require(ethUsd > 0, 'INVALID_ETH_USD_PRICE');
    // Both USD inputs have 8 decimals. The quotient is returned in 18-decimal ETH.
    return int256((PRICE_USD * 1e18) / uint256(ethUsd));
  }
}

/// @dev Shared constructor helper for the proposal payloads.
function deployPriceAdapter(
  uint256 priceUsd,
  address ethUsd,
  string memory symbol
) returns (address) {
  return
    address(
      new DeprecationPriceAdapter(
        priceUsd,
        ethUsd,
        string.concat(symbol, ethUsd == address(0) ? ' / USD' : ' / ETH', ' fixed USD target')
      )
    );
}
