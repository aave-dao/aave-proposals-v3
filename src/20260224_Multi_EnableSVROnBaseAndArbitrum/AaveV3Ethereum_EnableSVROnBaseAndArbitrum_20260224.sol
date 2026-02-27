// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLido} from 'aave-address-book/AaveV3EthereumLido.sol';

/**
 * @title Enable SVR on Base and Arbitrum
 * @author BGD Labs @bgdlabs
 * - Snapshot: TODO
 * - Discussion: TODO
 */
contract AaveV3Ethereum_EnableSVROnBaseAndArbitrum_20260224 is IProposalGenericExecutor {
  function execute() external {
    AaveV3Ethereum.ACL_MANAGER.removeAssetListingAdmin(AaveV3Ethereum.SVR_STEWARD);
    AaveV3Ethereum.ACL_MANAGER.removeAssetListingAdmin(AaveV3EthereumLido.SVR_STEWARD);
  }
}
