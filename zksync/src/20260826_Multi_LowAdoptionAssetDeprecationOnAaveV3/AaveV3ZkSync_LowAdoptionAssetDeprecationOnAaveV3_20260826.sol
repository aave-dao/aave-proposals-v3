// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ZkSync, AaveV3ZkSyncAssets} from 'aave-address-book/AaveV3ZkSync.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @title Low Adoption Asset Deprecation on Aave V3
 * @author Llama Risk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7
 * - Discussion: https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401
 * @dev The config engine deployed on zkSync predates v3.7 and is ABI-incompatible with the
 * current payload base, so the changes are applied via direct POOL_CONFIGURATOR calls.
 * All reserves are already frozen with borrow caps at 1. Every reserve in scope gets its
 * supply cap reduced to 1; the reserves that carry a borrow additionally get the reserve
 * factor raised to 99% and the IRM base variable borrow rate set to 5% while keeping the
 * current optimal ratio and slopes.
 */
contract AaveV3ZkSync_LowAdoptionAssetDeprecationOnAaveV3_20260826 is IProposalGenericExecutor {
  function execute() external {
    address[] memory capAssets = new address[](7);
    capAssets[0] = AaveV3ZkSyncAssets.WETH_UNDERLYING;
    capAssets[1] = AaveV3ZkSyncAssets.weETH_UNDERLYING;
    capAssets[2] = AaveV3ZkSyncAssets.wstETH_UNDERLYING;
    capAssets[3] = AaveV3ZkSyncAssets.ZK_UNDERLYING;
    capAssets[4] = AaveV3ZkSyncAssets.USDC_UNDERLYING;
    capAssets[5] = AaveV3ZkSyncAssets.USDT_UNDERLYING;
    capAssets[6] = AaveV3ZkSyncAssets.sUSDe_UNDERLYING;

    for (uint256 i = 0; i < capAssets.length; i++) {
      AaveV3ZkSync.POOL_CONFIGURATOR.setSupplyCap(capAssets[i], 1);
    }

    address[] memory rateAssets = new address[](5);
    rateAssets[0] = AaveV3ZkSyncAssets.WETH_UNDERLYING;
    rateAssets[1] = AaveV3ZkSyncAssets.wstETH_UNDERLYING;
    rateAssets[2] = AaveV3ZkSyncAssets.ZK_UNDERLYING;
    rateAssets[3] = AaveV3ZkSyncAssets.USDC_UNDERLYING;
    rateAssets[4] = AaveV3ZkSyncAssets.USDT_UNDERLYING;

    for (uint256 i = 0; i < rateAssets.length; i++) {
      AaveV3ZkSync.POOL_CONFIGURATOR.setReserveFactor(rateAssets[i], 99_00);

      IDefaultInterestRateStrategyV2.InterestRateData
        memory rateData = IDefaultInterestRateStrategyV2(
          AaveV3ZkSync.AAVE_PROTOCOL_DATA_PROVIDER.getInterestRateStrategyAddress(rateAssets[i])
        ).getInterestRateDataBps(rateAssets[i]);
      rateData.baseVariableBorrowRate = 5_00;
      AaveV3ZkSync.POOL_CONFIGURATOR.setReserveInterestRateData(
        rateAssets[i],
        abi.encode(rateData)
      );
    }
  }
}
