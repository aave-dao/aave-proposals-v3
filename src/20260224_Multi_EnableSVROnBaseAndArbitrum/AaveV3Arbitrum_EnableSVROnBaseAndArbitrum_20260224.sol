// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {ISvrOracleSteward} from '../interfaces/ISvrOracleSteward.sol';

/**
 * @title Enable SVR on Base and Arbitrum
 * @author BGD Labs @bgdlabs
 * - Snapshot: TODO
 * - Discussion: TODO
 */
contract AaveV3Arbitrum_EnableSVROnBaseAndArbitrum_20260224 is IProposalGenericExecutor {
  address public constant STEWARD = 0x94E54D858e9293964b4ACd6f8938c831827a31F4;

  function execute() external {
    AaveV3Arbitrum.ACL_MANAGER.addAssetListingAdmin(STEWARD);
    ISvrOracleSteward.AssetOracle[] memory configInput = new ISvrOracleSteward.AssetOracle[](4);
    // configInput[0] = ISvrOracleSteward.AssetOracle({
    //   asset: AaveV3EthereumAssets.LBTC_UNDERLYING,
    //   svrOracle: SVR_BTC_USD
    // });
    ISvrOracleSteward(STEWARD).enableSvrOracles(configInput);
  }
}
