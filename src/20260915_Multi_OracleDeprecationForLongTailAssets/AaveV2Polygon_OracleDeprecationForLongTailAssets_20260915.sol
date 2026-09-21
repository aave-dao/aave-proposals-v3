// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Polygon, AaveV2PolygonAssets} from 'aave-address-book/AaveV2Polygon.sol';
import {AaveV2PayloadPolygon} from 'aave-helpers/src/v2-config-engine/AaveV2PayloadPolygon.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV2ConfigEngine} from 'aave-helpers/src/v2-config-engine/IAaveV2ConfigEngine.sol';
import {IV2RateStrategyFactory} from 'aave-helpers/src/v2-config-engine/IV2RateStrategyFactory.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';
import {ChainlinkPolygon} from 'aave-address-book/ChainlinkPolygon.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV2Polygon_OracleDeprecationForLongTailAssets_20260915 is AaveV2PayloadPolygon {
  function _postExecute() internal override {
    address[] memory assets = new address[](2);
    address[] memory feeds = new address[](2);
    assets[0] = AaveV2PolygonAssets.BAL_UNDERLYING;
    feeds[0] = BAL_PRICE_FEED;
    assets[1] = AaveV2PolygonAssets.GHST_UNDERLYING;
    feeds[1] = GHST_PRICE_FEED;
    AaveV2Polygon.ORACLE.setAssetSources(assets, feeds);
  }

  function rateStrategiesUpdates()
    public
    pure
    override
    returns (IAaveV2ConfigEngine.RateStrategyUpdate[] memory)
  {
    IAaveV2ConfigEngine.RateStrategyUpdate[]
      memory rateStrategies = new IAaveV2ConfigEngine.RateStrategyUpdate[](2);
    rateStrategies[0] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2PolygonAssets.BAL_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[1] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2PolygonAssets.GHST_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });

    return rateStrategies;
  }
  uint256 public constant BAL_PRICE_USD = 12840000;
  address public immutable BAL_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        BAL_PRICE_USD,
        ChainlinkPolygon.ETH__USD,
        'BAL / ETH fixed USD target'
      )
    );
  uint256 public constant GHST_PRICE_USD = 7930000;
  address public immutable GHST_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        GHST_PRICE_USD,
        ChainlinkPolygon.ETH__USD,
        'GHST / ETH fixed USD target'
      )
    );
}
