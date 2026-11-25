// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ARFC bridge bucket capacity: the Ethereum bridge limit and every remote token pool bucket after execution
uint256 constant EXPECTED_BUCKET_CAPACITY = 265_000_000 ether;
// ARFC temporary rate limit of the Ethereum -> Avalanche lane, set on both sides by the Part 1 payloads
uint128 constant EXPECTED_TEMP_BRIDGE_CAPACITY = 71_500_000 ether;
uint128 constant EXPECTED_TEMP_BRIDGE_RATE = 64_999_999 ether;
