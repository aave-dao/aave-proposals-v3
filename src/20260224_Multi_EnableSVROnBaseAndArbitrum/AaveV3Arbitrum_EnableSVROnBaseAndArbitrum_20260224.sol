// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {ChainlinkArbitrum} from 'aave-address-book/ChainlinkArbitrum.sol';
import {ISvrOracleSteward} from '../interfaces/ISvrOracleSteward.sol';

/**
 * @title Enable SVR on Base and Arbitrum
 * @author BGD Labs @bgdlabs
 * - Snapshot: TODO
 * - Discussion: TODO
 */
contract AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224 is IProposalGenericExecutor {
  address public constant STEWARD = 0x94E54D858e9293964b4ACd6f8938c831827a31F4;

  // https://arbiscan.io/address/0xF44a2B5605b07a1CBA7CF3907A9D0bB4A515C3F1
  address public constant SVR_DAI_USD = 0xF44a2B5605b07a1CBA7CF3907A9D0bB4A515C3F1;

  // https://arbiscan.io/address/0xB0C9A7122aaB68F75CffD9851E867144DBFF113b
  address public constant SVR_USDC_USD = 0xB0C9A7122aaB68F75CffD9851E867144DBFF113b;

  // https://arbiscan.io/address/0x03f1203a32DF3a941D41dE07F5fD2E71D2a70172
  address public constant SVR_USDT_USD = 0x03f1203a32DF3a941D41dE07F5fD2E71D2a70172;

  // https://arbiscan.io/address/0xb4a28DF1b926646f94e6fE6f15828c491b4def5F
  address public constant SVR_wstETH_USD = 0xb4a28DF1b926646f94e6fE6f15828c491b4def5F;

  // https://arbiscan.io/address/0x0E82D4e66B8C41c532184BCd0d89781c0040d07A
  address public constant SVR_rETH_USD = 0x0E82D4e66B8C41c532184BCd0d89781c0040d07A;

  // https://arbiscan.io/address/0x8659250B67C7BdA853EbEBCF56dD22d6d4aE7617
  address public constant SVR_LUSD_USD = 0x8659250B67C7BdA853EbEBCF56dD22d6d4aE7617;

  // https://arbiscan.io/address/0x8aa156740411030Cf9a6381baa51FA4f1Af2c47C
  address public constant SVR_FRAX_USD = 0x8aa156740411030Cf9a6381baa51FA4f1Af2c47C;

  // https://arbiscan.io/address/0x258a576895DC50c990500775d6591ff2D52059f2
  address public constant SVR_weETH_USD = 0x258a576895DC50c990500775d6591ff2D52059f2;

  // https://arbiscan.io/address/0x3c4B37b69E7e1FFD1669fe085C74a89c6C79D908
  address public constant SVR_ezETH_USD = 0x3c4B37b69E7e1FFD1669fe085C74a89c6C79D908;

  // https://arbiscan.io/address/0x9F54122B14dAf2211989446868B9aa1CF207292B
  address public constant SVR_rsETH_USD = 0x9F54122B14dAf2211989446868B9aa1CF207292B;

  function execute() external {
    AaveV3Arbitrum.ACL_MANAGER.addAssetListingAdmin(STEWARD);
    ISvrOracleSteward.AssetOracle[] memory configInput = getSvrOracles();

    ISvrOracleSteward(STEWARD).enableSvrOracles(configInput);
  }

  function getSvrOracles() public pure returns (ISvrOracleSteward.AssetOracle[] memory) {
    ISvrOracleSteward.AssetOracle[] memory configInput = new ISvrOracleSteward.AssetOracle[](17);
    configInput[0] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.DAI_UNDERLYING,
      svrOracle: SVR_DAI_USD
    });
    configInput[1] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.LINK_UNDERLYING,
      svrOracle: ChainlinkArbitrum.AAVE_SVR_LINK__USD
    });
    configInput[2] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.USDC_UNDERLYING,
      svrOracle: SVR_USDC_USD
    });
    configInput[3] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.WBTC_UNDERLYING,
      svrOracle: ChainlinkArbitrum.AAVE_SVR_BTC__USD
    });
    configInput[4] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.WETH_UNDERLYING,
      svrOracle: ChainlinkArbitrum.AAVE_SVR_ETH__USD
    });
    configInput[5] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.USDT_UNDERLYING,
      svrOracle: SVR_USDT_USD
    });
    configInput[6] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.AAVE_UNDERLYING,
      svrOracle: ChainlinkArbitrum.AAVE_SVR_AAVE__USD
    });
    configInput[7] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.wstETH_UNDERLYING,
      svrOracle: SVR_wstETH_USD
    });
    configInput[8] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.rETH_UNDERLYING,
      svrOracle: SVR_rETH_USD
    });
    configInput[9] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      svrOracle: SVR_LUSD_USD
    });
    configInput[10] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.USDCn_UNDERLYING,
      svrOracle: SVR_USDC_USD
    });
    configInput[11] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      svrOracle: SVR_FRAX_USD
    });
    configInput[12] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.ARB_UNDERLYING,
      svrOracle: ChainlinkArbitrum.AAVE_SVR_ARB__USD
    });
    configInput[13] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.weETH_UNDERLYING,
      svrOracle: SVR_weETH_USD
    });
    configInput[14] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.ezETH_UNDERLYING,
      svrOracle: SVR_ezETH_USD
    });
    configInput[15] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.rsETH_UNDERLYING,
      svrOracle: SVR_rsETH_USD
    });
    configInput[16] = ISvrOracleSteward.AssetOracle({
      asset: AaveV3ArbitrumAssets.tBTC_UNDERLYING,
      svrOracle: ChainlinkArbitrum.AAVE_SVR_BTC__USD
    });

    return configInput;
  }
}
