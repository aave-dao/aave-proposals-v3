// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {ISvrOracleSteward} from '../interfaces/ISvrOracleSteward.sol';

/**
 * @title Enable SVR on Base and Arbitrum
 * @author BGD Labs @bgdlabs
 * - Snapshot: TODO
 * - Discussion: TODO
 */
contract AaveV3Base_EnableSVROnBaseAndArbitrum_20260224 is IProposalGenericExecutor {
  address public constant STEWARD = 0x4B09DAEAe857b93c9103392028294F0602C5fD5b;

  function execute() external {
    AaveV3Base.ACL_MANAGER.addAssetListingAdmin(STEWARD);
    ISvrOracleSteward.AssetOracle[] memory configInput = new ISvrOracleSteward.AssetOracle[](4);
    // configInput[0] = ISvrOracleSteward.AssetOracle({
    //   asset: AaveV3EthereumAssets.LBTC_UNDERLYING,
    //   svrOracle: SVR_BTC_USD
    // });
    ISvrOracleSteward(STEWARD).enableSvrOracles(configInput);
  }
}
