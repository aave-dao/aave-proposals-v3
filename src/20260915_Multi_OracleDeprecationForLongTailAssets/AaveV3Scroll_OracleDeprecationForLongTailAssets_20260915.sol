// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3ScrollAssets} from 'aave-address-book/AaveV3Scroll.sol';
import {AaveV3PayloadScroll} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadScroll.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Scroll_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadScroll {
  function _postExecute() internal override {}

  function rateStrategiesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.RateStrategyUpdate[] memory)
  {
    IAaveV3ConfigEngine.RateStrategyUpdate[]
      memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](1);
    rateStrategies[0] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3ScrollAssets.SCR_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 7_00,
        variableRateSlope2: 40_00
      })
    });

    return rateStrategies;
  }
  address public constant SCR_PRICE_FEED = 0xe90AA642db69c78959aFF4FC7d0E47866233BF43;
  function priceFeedsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory updates)
  {
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](1);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3ScrollAssets.SCR_UNDERLYING,
      SCR_PRICE_FEED
    );
  }
}
