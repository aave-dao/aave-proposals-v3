// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3PayloadInkWhitelabel} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadInkWhitelabel.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';
/**
 * @title Change Ink SolvBTC debt ceiling
 * @author ACI
 */
contract AaveV3InkWhitelabel_ChangeInkSolvBTCDebtCeiling_20260228 is AaveV3PayloadInkWhitelabel {
  function collateralsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[]
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](1);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3InkWhitelabelAssets.SolvBTC_UNDERLYING,
      ltv: EngineFlags.KEEP_CURRENT,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      debtCeiling: 0,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }
}
