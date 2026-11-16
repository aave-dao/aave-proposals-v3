// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {AaveV3PayloadPlasma} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadPlasma.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title Asset Listing - Pendle PT-sUSDe-28JAN2027 Plasma
 * @author @TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902
 */
contract AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022 is AaveV3PayloadPlasma {
  using SafeERC20 for IERC20;

  // https://plasmascan.to/address/0x257561233419039BeC3a28be717d14B4f490883D
  address public constant PT_sUSDE_28JAN2027 = 0x257561233419039BeC3a28be717d14B4f490883D;
  uint256 public constant PT_sUSDE_28JAN2027_SEED_AMOUNT = 100e18;
  // https://plasmascan.to/address/0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f
  address public constant PT_sUSDE_28JAN2027_PRICE_FEED =
    0x94b31Cd097c4Ec98F9CaD1c82be2cdA3215b527f;
  string public constant EMODE_LABEL = 'sUSDe_PT_sUSDe_28JAN2027__Stablecoins';

  function _postExecute() internal override {
    IERC20(PT_sUSDE_28JAN2027).forceApprove(
      address(AaveV3Plasma.POOL),
      PT_sUSDE_28JAN2027_SEED_AMOUNT
    );
    AaveV3Plasma.POOL.supply({
      asset: PT_sUSDE_28JAN2027,
      amount: PT_sUSDE_28JAN2027_SEED_AMOUNT,
      onBehalfOf: AaveV3Plasma.DUST_BIN,
      referralCode: 0
    });
  }

  function newListings() public pure override returns (IAaveV3ConfigEngine.Listing[] memory) {
    IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](1);

    listings[0] = IAaveV3ConfigEngine.Listing({
      asset: PT_sUSDE_28JAN2027,
      assetSymbol: 'PT_sUSDE_28JAN2027',
      priceFeed: PT_sUSDE_28JAN2027_PRICE_FEED,
      enabledToBorrow: EngineFlags.DISABLED,
      flashloanable: EngineFlags.DISABLED,
      ltv: 0,
      liqThreshold: 0,
      liqBonus: 0,
      reserveFactor: 45_00,
      supplyCap: 25_000_000,
      borrowCap: 1,
      liqProtocolFee: 10_00,
      rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: 45_00,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 10_00,
        variableRateSlope2: 300_00
      })
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

    address[] memory collateralAssets = new address[](3);
    address[] memory borrowableAssets = new address[](3);

    collateralAssets[0] = AaveV3PlasmaAssets.sUSDe_UNDERLYING;
    collateralAssets[1] = PT_sUSDE_28JAN2027;
    collateralAssets[2] = AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING;
    borrowableAssets[0] = AaveV3PlasmaAssets.USDT0_UNDERLYING;
    borrowableAssets[1] = AaveV3PlasmaAssets.USDe_UNDERLYING;
    borrowableAssets[2] = AaveV3PlasmaAssets.GHO_UNDERLYING;

    eModeCreations[0] = IAaveV3ConfigEngine.EModeCategoryCreation({
      ltv: 90_00,
      liqThreshold: 92_00,
      liqBonus: 4_95,
      label: EMODE_LABEL,
      isolated: false,
      collaterals: collateralAssets,
      borrowables: borrowableAssets
    });

    return eModeCreations;
  }
}
