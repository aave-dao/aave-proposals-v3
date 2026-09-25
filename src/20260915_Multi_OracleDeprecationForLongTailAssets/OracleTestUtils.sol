// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IChainlinkAggregator} from 'aave-helpers/src/interfaces/IChainlinkAggregator.sol';

library OracleTestUtils {
  // Both USD prices use 8 decimals; the returned ETH price uses 18 decimals.
  function usdToEth(uint256 usdPrice, address ethUsdFeed) internal view returns (uint256) {
    return (usdPrice * 1e18) / uint256(IChainlinkAggregator(ethUsdFeed).latestAnswer());
  }
}
