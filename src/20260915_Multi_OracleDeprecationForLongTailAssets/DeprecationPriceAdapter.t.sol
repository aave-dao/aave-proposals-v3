// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test} from 'forge-std/Test.sol';
import {IChainlinkAggregator} from 'aave-helpers/src/interfaces/IChainlinkAggregator.sol';
import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';
contract DeprecationPriceAdapterTest is Test {
  address constant FEED = address(0x1234);
  function test_fixedUsd() public {
    DeprecationPriceAdapter adapter = new DeprecationPriceAdapter(
      195430000,
      address(0),
      'RPL / USD'
    );
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.latestAnswer(), 195430000);
  }
  function test_v2ConvertsUsingLiveEthPrice() public {
    vm.mockCall(FEED, abi.encodeCall(IChainlinkAggregator.decimals, ()), abi.encode(uint8(8)));
    vm.mockCall(
      FEED,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(2000e8))
    );
    DeprecationPriceAdapter adapter = new DeprecationPriceAdapter(1e8, FEED, 'USD / ETH');
    assertEq(adapter.decimals(), 18);
    assertEq(adapter.latestAnswer(), 5e14);
    vm.mockCall(
      FEED,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(4000e8))
    );
    assertEq(adapter.latestAnswer(), 25e13);
    vm.mockCall(FEED, abi.encodeCall(IChainlinkAggregator.latestAnswer, ()), abi.encode(int256(0)));
    vm.expectRevert('INVALID_ETH_USD_PRICE');
    adapter.latestAnswer();
    vm.mockCall(
      FEED,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(-1))
    );
    vm.expectRevert('INVALID_ETH_USD_PRICE');
    adapter.latestAnswer();
  }
  function test_rejectsMissingPrice() public {
    vm.expectRevert('INVALID_FIXED_PRICE');
    new DeprecationPriceAdapter(0, address(0), 'missing');
  }
  function test_rejectsWrongEthFeedScale() public {
    vm.mockCall(FEED, abi.encodeCall(IChainlinkAggregator.decimals, ()), abi.encode(uint8(18)));
    vm.expectRevert('INVALID_ETH_USD_DECIMALS');
    new DeprecationPriceAdapter(1e8, FEED, 'USD / ETH');
  }
}
