// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FixedPriceAdapter} from './dependencies/aave-price-feeds/src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {CLSynchronicityPriceAdapterBaseToPeg} from './dependencies/aave-price-feeds/src/contracts/CLSynchronicityPriceAdapterBaseToPeg.sol';

/// @dev Deploy in the payload constructor. V2 keeps the fixed USD target using the ETH/USD feed.
function deployPriceAdapter(
  uint256 priceUsd,
  address aclManager,
  address ethUsd,
  string memory symbol
) returns (address) {
  address fixedFeed = address(
    new FixedPriceAdapter(
      aclManager,
      8,
      int256(priceUsd),
      string.concat(symbol, ' / USD fixed USD target')
    )
  );
  if (ethUsd == address(0)) return fixedFeed;
  return
    address(
      new CLSynchronicityPriceAdapterBaseToPeg(
        ethUsd,
        fixedFeed,
        18,
        string.concat(symbol, ' / ETH fixed USD target')
      )
    );
}
