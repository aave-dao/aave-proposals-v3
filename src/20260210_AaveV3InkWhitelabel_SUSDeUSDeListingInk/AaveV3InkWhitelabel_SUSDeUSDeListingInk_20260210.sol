// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {AaveV3PayloadInkWhitelabel} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadInkWhitelabel.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';

/**
 * @title sUSDe & USDe Listing Ink
 * @author Aavechan Initiative @aci
 */
contract AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210 is AaveV3PayloadInkWhitelabel {
  using SafeERC20 for IERC20;

  address public constant sUSDe = 0x211Cc4DD073734dA055fbF44a2b4667d5E5fE5d2;
  uint256 public constant sUSDe_SEED_AMOUNT = 100e18;
  address public constant sUSDe_LM_ADMIN = 0xac140648435d03f784879cd789130F22Ef588Fcd;

  address public constant USDe = 0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34;
  uint256 public constant USDe_SEED_AMOUNT = 99.99e18;
  address public constant USDe_LM_ADMIN = 0xac140648435d03f784879cd789130F22Ef588Fcd;

  function _postExecute() internal override {
    _supplyAndConfigureLMAdmin(sUSDe, sUSDe_SEED_AMOUNT, sUSDe_LM_ADMIN);

    _supplyAndConfigureLMAdmin(USDe, USDe_SEED_AMOUNT, USDe_LM_ADMIN);
  }

  function eModeCategoryCreations()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.EModeCategoryCreation[] memory)
  {
    IAaveV3ConfigEngine.EModeCategoryCreation[]
      memory eModeCreations = new IAaveV3ConfigEngine.EModeCategoryCreation[](2);

    address[] memory collateralAssets_SUSDe_USDe__USDT0_USDC_USDG = new address[](2);
    address[] memory borrowableAssets_SUSDe_USDe__USDT0_USDC_USDG = new address[](3);

    collateralAssets_SUSDe_USDe__USDT0_USDC_USDG[0] = sUSDe;
    collateralAssets_SUSDe_USDe__USDT0_USDC_USDG[1] = USDe;
    borrowableAssets_SUSDe_USDe__USDT0_USDC_USDG[0] = AaveV3InkWhitelabelAssets.USDT_UNDERLYING;
    borrowableAssets_SUSDe_USDe__USDT0_USDC_USDG[1] = AaveV3InkWhitelabelAssets.USDG_UNDERLYING;
    borrowableAssets_SUSDe_USDe__USDT0_USDC_USDG[2] = AaveV3InkWhitelabelAssets.USDC_UNDERLYING;

    eModeCreations[0] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 90_00,
      liqThreshold: 92_00,
      liqBonus: 4_00,
      label: 'sUSDe_USDe__USDT0_USDC_USDG',
      collaterals: collateralAssets_SUSDe_USDe__USDT0_USDC_USDG,
      borrowables: borrowableAssets_SUSDe_USDe__USDT0_USDC_USDG
    });

    address[] memory collateralAssets_USDe__USDT0_USDC_USDG = new address[](1);
    address[] memory borrowableAssets_USDe__USDT0_USDC_USDG = new address[](3);

    collateralAssets_USDe__USDT0_USDC_USDG[0] = USDe;
    borrowableAssets_USDe__USDT0_USDC_USDG[0] = AaveV3InkWhitelabelAssets.USDT_UNDERLYING;
    borrowableAssets_USDe__USDT0_USDC_USDG[1] = AaveV3InkWhitelabelAssets.USDG_UNDERLYING;
    borrowableAssets_USDe__USDT0_USDC_USDG[2] = AaveV3InkWhitelabelAssets.USDC_UNDERLYING;

    eModeCreations[1] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 90_00,
      liqThreshold: 93_00,
      liqBonus: 2_00,
      label: 'USDe__USDT0_USDC_USDG',
      collaterals: collateralAssets_USDe__USDT0_USDC_USDG,
      borrowables: borrowableAssets_USDe__USDT0_USDC_USDG
    });

    return eModeCreations;
  }
  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](2);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: sUSDe,
      assetSymbol: 'sUSDe',
      priceFeed: 0xC170637d22Ac02bAC99ED794038d2676d712e704, //lastAnswer: 20260223: 1.22130070 USD
      enabledToBorrow: EngineFlags.DISABLED,
      borrowableInIsolation: EngineFlags.DISABLED,
      withSiloedBorrowing: EngineFlags.DISABLED,
      flashloanable: EngineFlags.ENABLED,
      ltv: 0,
      liqThreshold: 0,
      liqBonus: 0,
      reserveFactor: 50_00,
      supplyCap: 50_000_000,
      borrowCap: 1,
      debtCeiling: 0,
      liqProtocolFee: 10_00,
      rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: 45_00,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 10_00,
        variableRateSlope2: 300_00
      })
    });
    listings[1] = IAaveV3ConfigEngine.Listing({
      asset: USDe,
      assetSymbol: 'USDe',
      priceFeed: AaveV3InkWhitelabelAssets.USDT_ORACLE, //lastAnswer: 20260223: 0.99990000 USD
      enabledToBorrow: EngineFlags.ENABLED,
      borrowableInIsolation: EngineFlags.DISABLED,
      withSiloedBorrowing: EngineFlags.DISABLED,
      flashloanable: EngineFlags.ENABLED,
      ltv: 0,
      liqThreshold: 0,
      liqBonus: 0,
      reserveFactor: 25_00,
      supplyCap: 50_000_000,
      borrowCap: 45_000_000,
      debtCeiling: 0,
      liqProtocolFee: 10_00,
      rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: 80_00,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 5_25,
        variableRateSlope2: 12_00
      })
    });

    return listings;
  }
  function _supplyAndConfigureLMAdmin(address asset, uint256 seedAmount, address lmAdmin) internal {
    IERC20(asset).forceApprove(address(AaveV3InkWhitelabel.POOL), seedAmount);
    AaveV3InkWhitelabel.POOL.supply(asset, seedAmount, address(AaveV3InkWhitelabel.DUST_BIN), 0);

    if (lmAdmin != address(0)) {
      address aToken = AaveV3InkWhitelabel.POOL.getReserveAToken(asset);
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).setEmissionAdmin(asset, lmAdmin);
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).setEmissionAdmin(aToken, lmAdmin);
    }
  }
}
