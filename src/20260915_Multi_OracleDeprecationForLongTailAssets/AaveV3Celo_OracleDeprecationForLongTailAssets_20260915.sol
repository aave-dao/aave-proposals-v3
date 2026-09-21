// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Celo, AaveV3CeloAssets} from 'aave-address-book/AaveV3Celo.sol';
import {AaveV3PayloadCelo} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadCelo.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Celo_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadCelo {
  function _postExecute() internal override {
    AaveV3Celo.POOL_CONFIGURATOR.setReserveFreeze(AaveV3CeloAssets.USDm_UNDERLYING, true);
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3CeloAssets.USDm_UNDERLYING, 1, 1);
  }

  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](1);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3CeloAssets.USDm_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });

    return borrowUpdates;
  }

  function rateStrategiesUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.RateStrategyUpdate[] memory)
  {
    IAaveV3ConfigEngine.RateStrategyUpdate[]
      memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](1);
    rateStrategies[0] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3CeloAssets.USDm_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 5_00,
        variableRateSlope1: 4_00,
        variableRateSlope2: 100_00
      })
    });

    return rateStrategies;
  }
  uint256 public constant USDm_PRICE_USD = 100000000;
  address public immutable USDm_PRICE_FEED =
    address(new DeprecationPriceAdapter(USDm_PRICE_USD, address(0), 'USDm / USD fixed USD target'));
  function priceFeedsUpdates()
    public
    view
    override
    returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory updates)
  {
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](1);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3CeloAssets.USDm_UNDERLYING,
      USDm_PRICE_FEED
    );
  }
}
