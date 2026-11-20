// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Mantle, AaveV3MantleAssets} from 'aave-address-book/AaveV3Mantle.sol';
import {AaveV3PayloadMantle} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadMantle.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title Aave V3 Mantle – XAUt Listing
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-aave-v3-mantle-collateral-enablement-emode-expansion-and-isolation-updates-usdt0-usde-eth-xaut/24153
 */
contract AaveV3Mantle_XAUtListing_20260805 is AaveV3PayloadMantle {
  using SafeERC20 for IERC20;

  // https://mantlescan.xyz/address/0x6199CCd9273A1E0e41e2cC18d9dAcd1E9382F58E
  address public constant XAUt = 0x6199CCd9273A1E0e41e2cC18d9dAcd1E9382F58E;
  // https://mantlescan.xyz/address/0x23A1105fd2C26BCc9EA691725Bbda3f5F1bC0b78
  address public constant XAUt_PRICE_FEED = 0x23A1105fd2C26BCc9EA691725Bbda3f5F1bC0b78;
  uint256 public constant XAUt_SEED_AMOUNT = 0.025e6; // 0.025 XAUt (~100 USD)

  function _postExecute() internal override {
    IERC20(XAUt).forceApprove(address(AaveV3Mantle.POOL), XAUt_SEED_AMOUNT);
    AaveV3Mantle.POOL.supply(XAUt, XAUt_SEED_AMOUNT, AaveV3Mantle.DUST_BIN, 0);
  }

  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](1);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: XAUt,
      assetSymbol: 'XAUt',
      priceFeed: XAUt_PRICE_FEED,
      rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: 45_00,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 10_00,
        variableRateSlope2: 300_00
      }),
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.ENABLED,
      ltv: 0,
      liqThreshold: 0,
      liqBonus: 0,
      reserveFactor: 20_00,
      supplyCap: 4_000,
      borrowCap: 1,
      liqProtocolFee: 10_00
    });

    return listings;
  }

  function eModeCategoryCreations()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryCreation[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryCreation[]
      memory eModeCreations = new IAaveV3ConfigEngine.EModeCategoryCreation[](1);

    address[] memory borrowableAssets_Stablecoins = new address[](3);
    borrowableAssets_Stablecoins[0] = AaveV3MantleAssets.USDT0_UNDERLYING;
    borrowableAssets_Stablecoins[1] = AaveV3MantleAssets.USDC_UNDERLYING;
    borrowableAssets_Stablecoins[2] = AaveV3MantleAssets.GHO_UNDERLYING;

    address[] memory collateralAssets_XAUtStablecoins = new address[](1);
    collateralAssets_XAUtStablecoins[0] = XAUt;

    eModeCreations[0] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 70_00,
      liqThreshold: 75_00,
      liqBonus: 6_00,
      label: 'XAUt Stablecoins',
      collaterals: collateralAssets_XAUtStablecoins,
      borrowables: borrowableAssets_Stablecoins,
      isolated: false
    });

    return eModeCreations;
  }
}
