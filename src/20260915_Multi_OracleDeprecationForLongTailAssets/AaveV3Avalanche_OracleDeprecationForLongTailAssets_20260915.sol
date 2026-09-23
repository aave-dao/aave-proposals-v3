// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV3PayloadAvalanche} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadAvalanche.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Avalanche_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadAvalanche {
  // https://snowscan.xyz/address/0xC3B102d52dB93fE3B22B356085C5854c6Bcc2091#code
  address public constant FRAX_PRICE_FEED = 0xC3B102d52dB93fE3B22B356085C5854c6Bcc2091;
  // https://snowscan.xyz/address/0x80e8F4b3698A079d7f2397cd71ab4bb17a12924e#code
  address public constant MAI_PRICE_FEED = 0x80e8F4b3698A079d7f2397cd71ab4bb17a12924e;

  function _postExecute() internal override {
    AaveV3Avalanche.POOL_CONFIGURATOR.setReserveFreeze(AaveV3AvalancheAssets.FRAX_UNDERLYING, true);
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3AvalancheAssets.MAI_UNDERLYING, 1, 1);
  }

  function rateStrategiesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.RateStrategyUpdate[] memory)
  {
    IAaveV3ConfigEngine.RateStrategyUpdate[]
      memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](2);
    rateStrategies[0] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3AvalancheAssets.FRAX_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00, // 20% (2 decimals)
        variableRateSlope1: 5_50, // 5.5% (2 decimals)
        variableRateSlope2: 40_00 // 40% (2 decimals)
      })
    });
    rateStrategies[1] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3AvalancheAssets.MAI_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00, // 20% (2 decimals)
        variableRateSlope1: 9_00, // 9% (2 decimals)
        variableRateSlope2: 40_00 // 40% (2 decimals)
      })
    });

    return rateStrategies;
  }
  function priceFeedsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory updates)
  {
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](2);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3AvalancheAssets.FRAX_UNDERLYING,
      FRAX_PRICE_FEED
    );
    updates[1] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3AvalancheAssets.MAI_UNDERLYING,
      MAI_PRICE_FEED
    );
  }
}
