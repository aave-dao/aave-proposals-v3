// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Metis, AaveV3MetisAssets} from 'aave-address-book/AaveV3Metis.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @title Low Adoption Asset Deprecation on Aave V3
 * @author Llama Risk (implemented by Aave Labs)
 * - Snapshot: https://snapshot.org/#/aavedao.eth/proposal/0x4ec0c13baf55472ecd538a2fae4bbdb60f30c96621a97ecf4db073b3e65597c7
 * - Discussion: https://governance.aave.com/t/arfc-low-adoption-asset-deprecation-on-aave-v3/25401
 * @dev The config engine deployed on Metis predates v3.7 and is ABI-incompatible with the
 * current payload base, so the changes are applied via direct POOL_CONFIGURATOR calls.
 * All reserves are already frozen. Each reserve gets its supply cap reduced to 1 (borrow
 * caps are already 1), the reserve factor raised to 99% and the IRM base variable borrow
 * rate set to 5% while keeping the current optimal ratio and slopes.
 */
contract AaveV3Metis_LowAdoptionAssetDeprecationOnAaveV3_20260826 is IProposalGenericExecutor {
  function execute() external {
    address[] memory assets = new address[](5);
    assets[0] = AaveV3MetisAssets.Metis_UNDERLYING;
    assets[1] = AaveV3MetisAssets.mUSDT_UNDERLYING;
    assets[2] = AaveV3MetisAssets.mUSDC_UNDERLYING;
    assets[3] = AaveV3MetisAssets.WETH_UNDERLYING;
    assets[4] = AaveV3MetisAssets.mDAI_UNDERLYING;

    for (uint256 i = 0; i < assets.length; i++) {
      AaveV3Metis.POOL_CONFIGURATOR.setSupplyCap(assets[i], 1);
      AaveV3Metis.POOL_CONFIGURATOR.setReserveFactor(assets[i], 99_00);

      IDefaultInterestRateStrategyV2.InterestRateData
        memory rateData = IDefaultInterestRateStrategyV2(
          AaveV3Metis.AAVE_PROTOCOL_DATA_PROVIDER.getInterestRateStrategyAddress(assets[i])
        ).getInterestRateDataBps(assets[i]);
      rateData.baseVariableBorrowRate = 5_00;
      AaveV3Metis.POOL_CONFIGURATOR.setReserveInterestRateData(assets[i], abi.encode(rateData));
    }
  }
}
