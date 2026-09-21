// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon, AaveV3PolygonAssets} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3PayloadPolygon} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadPolygon.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {deployPriceAdapter} from './DeprecationPriceAdapter.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Polygon_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadPolygon {
  function _postExecute() internal override {
    AaveV3Polygon.POOL_CONFIGURATOR.setReserveFreeze(AaveV3PolygonAssets.GHST_UNDERLYING, true);
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](2);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3PolygonAssets.BAL_UNDERLYING, 1, 1);
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate(AaveV3PolygonAssets.miMATIC_UNDERLYING, 1, 1);
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
      asset: AaveV3PolygonAssets.BAL_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 15_00,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[1] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3PolygonAssets.GHST_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 7_00,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[2] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3PolygonAssets.miMATIC_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 9_00,
        variableRateSlope2: 40_00
      })
    });

    return rateStrategies;
  }
  uint256 public constant BAL_PRICE_USD = 13160000;
  address public immutable BAL_PRICE_FEED = deployPriceAdapter(BAL_PRICE_USD, address(0), 'BAL');
  uint256 public constant GHST_PRICE_USD = 8280000;
  address public immutable GHST_PRICE_FEED = deployPriceAdapter(GHST_PRICE_USD, address(0), 'GHST');
  uint256 public constant miMATIC_PRICE_USD = 95300000;
  address public immutable miMATIC_PRICE_FEED =
    deployPriceAdapter(miMATIC_PRICE_USD, address(0), 'miMATIC');
  function priceFeedsUpdates()
    public
    view
    override
    returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory updates)
  {
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](3);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3PolygonAssets.BAL_UNDERLYING,
      BAL_PRICE_FEED
    );
    updates[1] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3PolygonAssets.GHST_UNDERLYING,
      GHST_PRICE_FEED
    );
    updates[2] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3PolygonAssets.miMATIC_UNDERLYING,
      miMATIC_PRICE_FEED
    );
  }
}
