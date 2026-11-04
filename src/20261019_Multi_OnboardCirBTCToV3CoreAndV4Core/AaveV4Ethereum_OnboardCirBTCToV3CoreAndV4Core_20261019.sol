// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumIRStrategies, AaveV4EthereumSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {AaveV4PayloadEthereum} from 'aave-helpers/src/v4-config-engine/AaveV4PayloadEthereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';

/**
 * @title Onboard cirBTC on Aave V3 Core and Aave V4 Core
 * @author Aave Labs
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xe7ce2a6c2c3f8ea303351a12ea0e991815b3944bd44af4fd2890cadc2ff19881
 * - Discussion: https://governance.aave.com/t/arfc-onboard-cirbtc-on-aave-v3-core-and-aave-v4-core/25128
 */
contract AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019 is AaveV4PayloadEthereum {
  // https://etherscan.io/address/0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E
  address public constant cirBTC = 0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E;

  // https://etherscan.io/address/0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A
  address public constant MAIN_SPOKE_cirBTC_PRICE_FEED = ChainlinkEthereum.AAVE_SVR_BTC__USD;

  function hubAssetListings() public pure override returns (IConfigEngine.AssetListing[] memory) {
    IConfigEngine.AssetListing[] memory items = new IConfigEngine.AssetListing[](1);
    items[0] = IConfigEngine.AssetListing({
      hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: cirBTC,
      feeReceiver: address(AaveV4Ethereum.TREASURY_SPOKE),
      liquidityFee: 20_00,
      irStrategy: address(AaveV4EthereumIRStrategies.CORE_WBTC_IR_STRATEGY),
      irData: IAssetInterestRateStrategy.InterestRateData({
        optimalUsageRatio: uint16(80_00),
        baseDrawnRate: uint32(25),
        rateGrowthBeforeOptimal: uint32(4_00),
        rateGrowthAfterOptimal: uint32(60_00)
      }),
      tokenization: IConfigEngine.TokenizationSpokeConfig({
        addCap: 25,
        proxyAdminOwner: MiscEthereum.V4_SECURITY_COUNCIL,
        name: 'Wrapped Aave Core cirBTC',
        symbol: 'waCorecirBTC'
      })
    });
    return items;
  }

  function spokeReserveListings()
    public
    pure
    override
    returns (IConfigEngine.ReserveListing[] memory)
  {
    IConfigEngine.ReserveListing[] memory items = new IConfigEngine.ReserveListing[](1);
    items[0] = IConfigEngine.ReserveListing({
      spokeConfigurator: AaveV4Ethereum.SPOKE_CONFIGURATOR,
      spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
      hub: address(AaveV4EthereumHubs.CORE_HUB),
      underlying: cirBTC,
      priceSource: MAIN_SPOKE_cirBTC_PRICE_FEED,
      config: ISpoke.ReserveConfig({
        collateralRisk: uint24(0),
        paused: false,
        frozen: false,
        borrowable: true,
        receiveSharesEnabled: true
      }),
      dynamicConfig: ISpoke.DynamicReserveConfig({
        collateralFactor: uint16(78_00),
        maxLiquidationBonus: uint32(105_55),
        liquidationFee: uint16(10_00)
      })
    });
    return items;
  }

  function hubSpokeToAssetsAdditions()
    public
    pure
    override
    returns (IConfigEngine.SpokeToAssetsAddition[] memory)
  {
    IConfigEngine.SpokeToAssetsAddition[] memory items = new IConfigEngine.SpokeToAssetsAddition[](
      1
    );
    {
      IConfigEngine.SpokeAssetConfig[] memory subAssets = new IConfigEngine.SpokeAssetConfig[](1);
      subAssets[0] = IConfigEngine.SpokeAssetConfig({
        underlying: cirBTC,
        config: IHub.SpokeConfig({
          addCap: 250,
          drawCap: 25,
          riskPremiumThreshold: 0,
          active: true,
          halted: false
        })
      });
      items[0] = IConfigEngine.SpokeToAssetsAddition({
        hubConfigurator: AaveV4Ethereum.HUB_CONFIGURATOR,
        hub: address(AaveV4EthereumHubs.CORE_HUB),
        spoke: address(AaveV4EthereumSpokes.MAIN_SPOKE),
        assets: subAssets
      });
    }
    return items;
  }
}
