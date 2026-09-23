// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {AaveV3PayloadOptimism} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadOptimism.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadOptimism {
  address public constant LUSD_PRICE_FEED = 0x0EB34b917D500a7736555f4508BFE77452cb261d;
  address public constant MAI_PRICE_FEED = 0x80e8F4b3698A079d7f2397cd71ab4bb17a12924e;
  address public constant sUSD_PRICE_FEED = 0x70371a0c40e8497Ce491f889D546AB760d644Eec;

  function _postExecute() internal override {
    AaveV3Optimism.POOL_CONFIGURATOR.setReserveFreeze(AaveV3OptimismAssets.LUSD_UNDERLYING, true);
    AaveV3Optimism.POOL_CONFIGURATOR.setReserveFreeze(AaveV3OptimismAssets.sUSD_UNDERLYING, true);
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3OptimismAssets.MAI_UNDERLYING, 1, 1);
  }

  function rateStrategiesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.RateStrategyUpdate[] memory)
  {
    IAaveV3ConfigEngine.RateStrategyUpdate[]
      memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](3);
    rateStrategies[0] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3OptimismAssets.LUSD_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 5_50,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[1] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3OptimismAssets.MAI_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 5_50,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[2] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3OptimismAssets.sUSD_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 0,
        variableRateSlope1: 0,
        variableRateSlope2: 0
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
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](3);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3OptimismAssets.LUSD_UNDERLYING,
      LUSD_PRICE_FEED
    );
    updates[1] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3OptimismAssets.MAI_UNDERLYING,
      MAI_PRICE_FEED
    );
    updates[2] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3OptimismAssets.sUSD_UNDERLYING,
      sUSD_PRICE_FEED
    );
  }
}
