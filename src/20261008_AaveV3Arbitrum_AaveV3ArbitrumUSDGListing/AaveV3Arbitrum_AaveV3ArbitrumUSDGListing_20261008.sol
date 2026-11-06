// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3PayloadArbitrum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadArbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title Onboard USDG to Aave V3 Arbitrum
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-asset-listing-usdg-arbitrum/25811
 */
contract AaveV3Arbitrum_AaveV3ArbitrumUSDGListing_20261008 is AaveV3PayloadArbitrum {
  using SafeERC20 for IERC20;

  // https://arbiscan.io/address/0x004B506865409877C9fA29bfb1ebA929984B9bbC
  address public constant USDG = 0x004B506865409877C9fA29bfb1ebA929984B9bbC;
  uint256 public constant USDG_SEED_AMOUNT = 150e6;
  // https://arbiscan.io/address/0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D
  address public constant USDG_PRICE_FEED = 0xf6bDD632625425cE368Bb19Af5A01C3C0344EB1D;

  function _postExecute() internal override {
    IERC20(USDG).forceApprove(address(AaveV3Arbitrum.POOL), USDG_SEED_AMOUNT);
    AaveV3Arbitrum.POOL.supply(USDG, USDG_SEED_AMOUNT, address(AaveV3Arbitrum.DUST_BIN), 0);
  }

  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](1);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: USDG,
      assetSymbol: 'USDG',
      priceFeed: USDG_PRICE_FEED,
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
    });

    return listings;
  }
}
