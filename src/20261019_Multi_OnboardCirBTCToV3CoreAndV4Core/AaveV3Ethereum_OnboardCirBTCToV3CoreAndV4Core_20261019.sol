// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {AaveV3PayloadEthereum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title Onboard cirBTC on Aave V3 Core and Aave V4 Core
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xe7ce2a6c2c3f8ea303351a12ea0e991815b3944bd44af4fd2890cadc2ff19881
 * - Discussion: https://governance.aave.com/t/arfc-onboard-cirbtc-on-aave-v3-core-and-aave-v4-core/25128
 */
contract AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019 is AaveV3PayloadEthereum {
  using SafeERC20 for IERC20;

  // https://etherscan.io/address/0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E
  address public constant cirBTC = 0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E;
  uint256 public constant cirBTC_SEED_AMOUNT = 1e5;
  // https://etherscan.io/address/0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A
  address public constant cirBTC_PRICE_FEED = ChainlinkEthereum.AAVE_SVR_BTC__USD;

  function _postExecute() internal override {
    IERC20(cirBTC).forceApprove(address(AaveV3Ethereum.POOL), cirBTC_SEED_AMOUNT);
    AaveV3Ethereum.POOL.supply(cirBTC, cirBTC_SEED_AMOUNT, address(AaveV3Ethereum.DUST_BIN), 0);
  }

  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](1);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: cirBTC,
      assetSymbol: 'cirBTC',
      priceFeed: cirBTC_PRICE_FEED,
      enabledToBorrow: EngineFlags.ENABLED,
      flashloanable: EngineFlags.ENABLED,
      ltv: 73_00,
      liqThreshold: 78_00,
      liqBonus: 5_00,
      reserveFactor: 50_00,
      supplyCap: 250,
      borrowCap: 20,
      liqProtocolFee: 20_00,
      rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: 80_00,
        baseVariableBorrowRate: 25,
        variableRateSlope1: 4_00,
        variableRateSlope2: 60_00
      })
    });

    return listings;
  }
}
