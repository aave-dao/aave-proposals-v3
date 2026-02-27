// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {ChainlinkBase} from 'aave-address-book/ChainlinkBase.sol';
import {ISvrOracleSteward} from '../interfaces/ISvrOracleSteward.sol';

/**
 * @title Enable SVR on Base and Arbitrum
 * @author BGD Labs @bgdlabs
 * - Snapshot: TODO
 * - Discussion: TODO
 */
contract AaveV3Base_EnableSVROnBaseAndArbitrum_20260224 is IProposalGenericExecutor {
  address public constant STEWARD = 0x4B09DAEAe857b93c9103392028294F0602C5fD5b;

  // https://basescan.org/address/0xB6E9fbba669763BD811B10A761110C449824b5BB
  address public constant SVR_cbETH_USD = 0xB6E9fbba669763BD811B10A761110C449824b5BB;

  // https://basescan.org/address/0xf52D010c7d4ecBfda92c2509900593CE34535D86
  address public constant SVR_USDC_USD = 0xf52D010c7d4ecBfda92c2509900593CE34535D86;

  // https://basescan.org/address/0x1AFC5010Fb182B6e62D6a3B522F09F644Fb62EfD
  address public constant SVR_wstETH_USD = 0x1AFC5010Fb182B6e62D6a3B522F09F644Fb62EfD;

  // https://basescan.org/address/0x0A0fFc2952B682eb36cde5Bdb03169C2c5F5305c
  address public constant SVR_weETH_USD = 0x0A0fFc2952B682eb36cde5Bdb03169C2c5F5305c;

  // https://basescan.org/address/0x0B472c80cAf27B3238Ae6cF0f13a362D2522bf6d
  address public constant SVR_ezETH_USD = 0x0B472c80cAf27B3238Ae6cF0f13a362D2522bf6d;

  // https://basescan.org/address/0x87445df51b4A2E5BbD2F0F8564C5bfe65cC3dB61
  address public constant SVR_wrsETH_USD = 0x87445df51b4A2E5BbD2F0F8564C5bfe65cC3dB61;

  // https://basescan.org/address/0x7a52aEb0461Ff4De29D5849A9E9885ca4E0d62D0
  address public constant SVR_LBTC_USD = 0x7a52aEb0461Ff4De29D5849A9E9885ca4E0d62D0;

  // https://basescan.org/address/0x8438ee84b847FA4e462d906bbdf4B11341434d13
  address public constant SVR_EURC_USD = 0x8438ee84b847FA4e462d906bbdf4B11341434d13;

  // https://basescan.org/address/0x5e9eCce4aCBBc8172A40f7b8A7c086A4bb5CDeac
  address public constant SVR_syrupUSDC_USD = 0x5e9eCce4aCBBc8172A40f7b8A7c086A4bb5CDeac;

  function execute() external {
    AaveV3Base.ACL_MANAGER.addAssetListingAdmin(STEWARD);
    ISvrOracleSteward.AssetOracle[] memory configInput = new ISvrOracleSteward.AssetOracle[](13);
    configInput[0] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.WETH_UNDERLYING,
      svrOracle: ChainlinkBase.AAVE_SVR_ETH__USD
    });
    configInput[1] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.cbETH_UNDERLYING,
      svrOracle: SVR_cbETH_USD
    });
    configInput[2] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.USDbC_UNDERLYING,
      svrOracle: SVR_USDC_USD
    });
    configInput[3] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.wstETH_UNDERLYING,
      svrOracle: SVR_wstETH_USD
    });
    configInput[4] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.USDC_UNDERLYING,
      svrOracle: SVR_USDC_USD
    });
    configInput[5] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.weETH_UNDERLYING,
      svrOracle: SVR_weETH_USD
    });
    configInput[6] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.cbBTC_UNDERLYING,
      svrOracle: ChainlinkBase.AAVE_SVR_BTC__USD
    });
    configInput[7] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.ezETH_UNDERLYING,
      svrOracle: SVR_ezETH_USD
    });
    configInput[8] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.wrsETH_UNDERLYING,
      svrOracle: SVR_wrsETH_USD
    });
    configInput[9] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.LBTC_UNDERLYING,
      svrOracle: SVR_LBTC_USD
    });
    configInput[10] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.EURC_UNDERLYING,
      svrOracle: SVR_EURC_USD
    });
    configInput[11] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.AAVE_UNDERLYING,
      svrOracle: ChainlinkBase.AAVE_SVR_AAVE__USD
    });
    configInput[12] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3BaseAssets.tBTC_UNDERLYING,
      svrOracle: ChainlinkBase.AAVE_SVR_BTC__USD
    });

    ISvrOracleSteward(STEWARD).enableSvrOracles(configInput);
  }
}
