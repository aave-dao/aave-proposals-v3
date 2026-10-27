// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ExpectedListing} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008} from './AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008.sol';
import {IPriceCapAdapterStable} from '../interfaces/IPriceCapAdapterStable.sol';

/**
 * @dev Test for AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261008_AaveV3Arbitrum_AaveV3ArbitrumUSDGListing/AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008.t.sol -vv
 */
contract AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 518408593);
    proposal = new AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function test_dustBinHasUSDGFunds() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address aTokenAddress = AaveV3Arbitrum.POOL.getReserveAToken(proposal.USDG());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3Arbitrum.DUST_BIN)),
      proposal.USDG_SEED_AMOUNT(),
      'dust bin should hold at least the seeded aUSDG amount'
    );
  }

  function test_priceFeed() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address adapter = 0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D;
    _validateAssetSourceOnOracle(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER, proposal.USDG(), adapter);

    uint256 price = AaveV3Arbitrum.ORACLE.getAssetPrice(proposal.USDG());
    assertGt(price, 0.95e8, 'USDG price should trade near 1 USD');
    assertLt(price, 1.05e8, 'USDG price should trade near 1 USD');

    assertEq(IPriceCapAdapterStable(adapter).getPriceCap(), 1.04e8, 'price cap should be 1.04 USD');
    assertEq(
      IPriceCapAdapterStable(adapter).ASSET_TO_USD_AGGREGATOR(),
      0xE9Bd4Ca2CDacb56cd06c9C4C5231e69c33340B3c,
      'underlying aggregator should be the USDG / USD feed'
    );
  }

  function test_rates() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _validateInterestRateStrategy(
      proposal.USDG(),
      AaveV3Arbitrum.POOL.getReserveData(proposal.USDG()).interestRateStrategyAddress,
      AaveV3Arbitrum.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: 0.9e27,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 0.045e27,
        variableRateSlope2: 0.3e27
      })
    );
  }

  function test_liquidationProtocolFee() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      AaveV3Arbitrum.AAVE_PROTOCOL_DATA_PROVIDER.getLiquidationProtocolFee(proposal.USDG()),
      10_00
    );
  }

  function _expectedListings() internal pure override returns (ExpectedListing[] memory listings) {
    listings = new ExpectedListing[](1);

    listings[0] = ExpectedListing({
      listing: IAaveV3ConfigEngine.Listing({
        asset: 0x004B506865409877C9fA29bfb1ebA929984B9bbC,
        assetSymbol: 'USDG',
        priceFeed: 0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D,
        enabledToBorrow: EngineFlags.ENABLED,
        flashloanable: EngineFlags.ENABLED,
        ltv: 0,
        liqThreshold: 0,
        liqBonus: 0,
        reserveFactor: 10_00,
        supplyCap: 30_000_000,
        borrowCap: 27_000_000,
        liqProtocolFee: 10_00,
        rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
          optimalUsageRatio: 90_00,
          baseVariableBorrowRate: 0,
          variableRateSlope1: 4_50,
          variableRateSlope2: 30_00
        })
      }),
      decimals: 6
    });
  }
}
