// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ISpoke, IAaveOracle} from 'aave-address-book/AaveV4.sol';
import {IPriceFeed} from 'aave-v4/spoke/interfaces/IPriceFeed.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';

interface ICapoAdapter {
  function getRatio() external view returns (int256);

  function getSnapshotRatio() external view returns (uint256);

  function getSnapshotTimestamp() external view returns (uint256);

  function getMaxRatioGrowthPerSecondScaled() external view returns (uint256);

  function isCapped() external view returns (bool);

  function latestAnswer() external view returns (int256);

  function RATIO_PROVIDER() external view returns (address);

  function RATIO_DECIMALS() external view returns (uint8);

  function BASE_TO_USD_AGGREGATOR() external view returns (address);
}

/// @dev Price sources pinned to the STATE.md oracle audit (2026-10-14), not to the address book.
contract SentoraOracles_Test is SentoraTestBase {
  struct SourceSpec {
    ISpoke spoke;
    address underlying;
    address source;
  }

  address internal constant RLUSD_SOURCE = 0x5120deb18Ca5545B056D9eb2fB368811162F737a;
  address internal constant PYUSD_SOURCE = 0xA592516A46203fd4Ece5b81f651d12A9d0cA92F1;
  address internal constant OUSD_SOURCE = 0x6f7bd8F596E66317D6323A6D61460f00d325823E;
  address internal constant USDe_SOURCE = 0x8004d13AF906d85997106D92Cec947880191e7Cc;
  address internal constant PRIME_SOURCE = 0x0abD10103b878d8D6Ac9708a0B8798459199174B;
  address internal constant PST_SOURCE = 0x5a3a7705484c5aD672237edE966b0a4564eeD763;
  address internal constant mWIN_SOURCE = 0x3EC0233530c548Ab984eb06BEE8a2E404aeA7557;
  address internal constant kBTC_SOURCE = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;

  uint256 internal constant SCALING_FACTOR = 1e6;

  function setUp() public override {
    super.setUp();
    _activate();
  }

  function test_reserveSources() public view {
    SourceSpec[] memory specs = _specs();
    uint256 reserveCount;
    for (uint256 i; i < specs.length; ++i) {
      IAaveOracle oracle = IAaveOracle(specs[i].spoke.ORACLE());
      uint256 reserveId = _reserveId(specs[i].spoke, specs[i].underlying);
      assertEq(oracle.getReserveSource(reserveId), specs[i].source, 'source');
      assertGt(oracle.getReservePrice(reserveId), 0, 'price');
      assertEq(
        oracle.getReservePrice(reserveId),
        uint256(IPriceFeed(specs[i].source).latestAnswer()),
        'price from source'
      );
      assertEq(IPriceFeed(specs[i].source).decimals(), 8, 'source decimals');
    }
    ISpoke[] memory spokes = _spokes();
    for (uint256 i; i < spokes.length; ++i) {
      reserveCount += spokes[i].getReserveCount();
    }
    assertEq(reserveCount, specs.length, 'every reserve covered');
  }

  function test_oraclesBoundToSpokes() public view {
    ISpoke[] memory spokes = _spokes();
    for (uint256 i; i < spokes.length; ++i) {
      IAaveOracle oracle = IAaveOracle(spokes[i].ORACLE());
      assertEq(oracle.spoke(), address(spokes[i]), 'oracle spoke');
      assertEq(oracle.decimals(), 8, 'oracle decimals');
    }
  }

  function test_stableAdaptersCapAt104() public {
    address[4] memory adapters = [RLUSD_SOURCE, PYUSD_SOURCE, OUSD_SOURCE, USDe_SOURCE];
    for (uint256 i; i < adapters.length; ++i) {
      _assertStableCap(adapters[i], 1.04e8);
    }
  }

  /// @dev The PST base is a capped USDC adapter; the STATE.md audit names it but not its cap, so
  /// the cap asserted is the on-chain one.
  function test_pstBaseAdapterCaps() public {
    address base = ICapoAdapter(PST_SOURCE).BASE_TO_USD_AGGREGATOR();
    assertEq(base, 0x42B1aEaE8D589102cEBB05107068Ec47B71202Ff, 'pst base');
    _assertStableCap(base, IPriceCapAdapterStable(base).getPriceCap());
  }

  /// @dev At FORK_BLOCK the live ratios sit about 0.25% (PRIME) and 0.18% (PST) under the cap.
  function test_capoAdaptersCapRatioGrowth() public {
    address[2] memory adapters = [PRIME_SOURCE, PST_SOURCE];
    for (uint256 i; i < adapters.length; ++i) {
      ICapoAdapter adapter = ICapoAdapter(adapters[i]);
      int256 maxRatio = int256(
        adapter.getSnapshotRatio() +
          (adapter.getMaxRatioGrowthPerSecondScaled() *
            (block.timestamp - adapter.getSnapshotTimestamp())) /
          SCALING_FACTOR
      );
      assertFalse(adapter.isCapped(), 'not capped at fork');
      assertLt(adapter.getRatio(), maxRatio, 'ratio under cap');

      int256 basePrice = IPriceFeed(adapter.BASE_TO_USD_AGGREGATOR()).latestAnswer();
      int256 cappedPrice = (basePrice * maxRatio) / int256(10 ** adapter.RATIO_DECIMALS());

      _mockRatio(adapter, maxRatio);
      assertFalse(adapter.isCapped(), 'ratio at cap');
      assertEq(adapter.latestAnswer(), cappedPrice, 'price at cap');

      _mockRatio(adapter, maxRatio + 1);
      assertTrue(adapter.isCapped(), 'capped');
      assertEq(adapter.latestAnswer(), cappedPrice, 'price capped');

      _mockRatio(adapter, maxRatio * 2);
      assertEq(adapter.latestAnswer(), cappedPrice, 'price capped at double ratio');
      vm.clearMockedCalls();
    }
  }

  function _assertStableCap(address adapter, int256 cap) internal {
    IPriceCapAdapterStable stable = IPriceCapAdapterStable(adapter);
    assertEq(stable.getPriceCap(), cap, 'price cap');
    assertFalse(stable.isCapped(), 'not capped at fork');

    address feed = stable.ASSET_TO_USD_AGGREGATOR();
    vm.mockCall(feed, abi.encodeWithSelector(IPriceFeed.latestAnswer.selector), abi.encode(cap));
    assertEq(IPriceFeed(adapter).latestAnswer(), cap, 'at cap');
    assertFalse(stable.isCapped(), 'at cap not capped');

    vm.mockCall(
      feed,
      abi.encodeWithSelector(IPriceFeed.latestAnswer.selector),
      abi.encode(cap + 1)
    );
    assertTrue(stable.isCapped(), 'capped');
    assertEq(IPriceFeed(adapter).latestAnswer(), cap, 'clamped');

    vm.mockCall(
      feed,
      abi.encodeWithSelector(IPriceFeed.latestAnswer.selector),
      abi.encode(int256(1.5e8))
    );
    assertEq(IPriceFeed(adapter).latestAnswer(), cap, 'clamped at 1.50');
    vm.clearMockedCalls();
  }

  function _mockRatio(ICapoAdapter adapter, int256 ratio) internal {
    vm.mockCall(
      adapter.RATIO_PROVIDER(),
      abi.encodeWithSelector(IPriceFeed.latestAnswer.selector),
      abi.encode(ratio)
    );
  }

  function _specs() internal pure returns (SourceSpec[] memory s) {
    s = new SourceSpec[](14);
    s[0] = SourceSpec(RLUSD_YIELD, Assets.RLUSD_UNDERLYING, RLUSD_SOURCE);
    s[1] = SourceSpec(RLUSD_YIELD, Assets.USDe_UNDERLYING, USDe_SOURCE);
    s[2] = SourceSpec(RLUSD_YIELD, Assets.PRIME_UNDERLYING, PRIME_SOURCE);
    s[3] = SourceSpec(RLUSD_YIELD, Assets.mWIN_UNDERLYING, mWIN_SOURCE);
    s[4] = SourceSpec(RLUSD_YIELD, Assets.PST_UNDERLYING, PST_SOURCE);
    s[5] = SourceSpec(OUSD_YIELD, Assets.OUSD_UNDERLYING, OUSD_SOURCE);
    s[6] = SourceSpec(OUSD_YIELD, Assets.USDe_UNDERLYING, USDe_SOURCE);
    s[7] = SourceSpec(OUSD_YIELD, Assets.PRIME_UNDERLYING, PRIME_SOURCE);
    s[8] = SourceSpec(OUSD_YIELD, Assets.mWIN_UNDERLYING, mWIN_SOURCE);
    s[9] = SourceSpec(OUSD_YIELD, Assets.PST_UNDERLYING, PST_SOURCE);
    s[10] = SourceSpec(BLUECHIP, Assets.RLUSD_UNDERLYING, RLUSD_SOURCE);
    s[11] = SourceSpec(BLUECHIP, Assets.PYUSD_UNDERLYING, PYUSD_SOURCE);
    s[12] = SourceSpec(BLUECHIP, Assets.OUSD_UNDERLYING, OUSD_SOURCE);
    s[13] = SourceSpec(BLUECHIP, Assets.kBTC_UNDERLYING, kBTC_SOURCE);
  }
}
