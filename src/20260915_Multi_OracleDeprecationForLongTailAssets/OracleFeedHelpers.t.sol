// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {deployPriceAdapter, FixedPriceAdapter, CLSynchronicityPriceAdapterBaseToPeg} from './OracleFeedHelpers.sol';
import {IFixedPriceAdapter} from './dependencies/aave-price-feeds/src/interfaces/IFixedPriceAdapter.sol';
import {IChainlinkAggregator} from 'aave-helpers/src/interfaces/IChainlinkAggregator.sol';

contract OracleFeedHelpersTest is Test {
  address constant ACL = address(0xAC1);
  address constant ETH_USD = address(0xFEE);

  function setUp() public {
    vm.mockCall(ETH_USD, abi.encodeCall(IChainlinkAggregator.decimals, ()), abi.encode(uint8(8)));
    vm.mockCall(
      ETH_USD,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(2000e8))
    );
    vm.mockCall(
      ACL,
      abi.encodeWithSignature('isPoolAdmin(address)', address(this)),
      abi.encode(false)
    );
  }

  function test_fixedUsd() public {
    FixedPriceAdapter feed = FixedPriceAdapter(
      deployPriceAdapter(265870000, ACL, address(0), 'RAI')
    );
    assertEq(feed.latestAnswer(), 265870000);
    assertEq(feed.decimals(), 8);
    assertEq(address(feed.ACL_MANAGER()), ACL);
    assertEq(feed.description(), 'RAI / USD fixed USD target');
  }

  function test_v2ConvertsUsingLiveEthPrice() public {
    CLSynchronicityPriceAdapterBaseToPeg feed = CLSynchronicityPriceAdapterBaseToPeg(
      deployPriceAdapter(1e8, ACL, ETH_USD, 'USD')
    );
    assertEq(address(feed.BASE_TO_PEG()), ETH_USD);
    assertEq(feed.decimals(), 18);
    assertEq(feed.latestAnswer(), 1e18 / 2000);
    vm.mockCall(
      ETH_USD,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(4000e8))
    );
    assertEq(feed.latestAnswer(), 1e18 / 4000);
  }

  function test_v2InvalidEthPriceReturnsZero() public {
    CLSynchronicityPriceAdapterBaseToPeg feed = CLSynchronicityPriceAdapterBaseToPeg(
      deployPriceAdapter(1e8, ACL, ETH_USD, 'USD')
    );
    vm.mockCall(
      ETH_USD,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(0))
    );
    assertEq(feed.latestAnswer(), 0);
    vm.mockCall(
      ETH_USD,
      abi.encodeCall(IChainlinkAggregator.latestAnswer, ()),
      abi.encode(int256(-1))
    );
    assertEq(feed.latestAnswer(), 0);
  }

  function test_onlyPoolAdminCanUpdateFixedPrice() public {
    CLSynchronicityPriceAdapterBaseToPeg feed = CLSynchronicityPriceAdapterBaseToPeg(
      deployPriceAdapter(1e8, ACL, ETH_USD, 'USD')
    );
    FixedPriceAdapter fixedFeed = FixedPriceAdapter(address(feed.ASSET_TO_PEG()));
    vm.expectRevert(IFixedPriceAdapter.CallerIsNotPoolAdmin.selector);
    fixedFeed.setPrice(2e8);
    assertEq(feed.latestAnswer(), 1e18 / 2000);
    vm.mockCall(
      ACL,
      abi.encodeWithSignature('isPoolAdmin(address)', address(this)),
      abi.encode(true)
    );
    fixedFeed.setPrice(2e8);
    assertEq(feed.latestAnswer(), 2e18 / 2000);
  }
}
