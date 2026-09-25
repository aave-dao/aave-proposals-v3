// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumEtherFi, AaveV3EthereumEtherFiAssets} from 'aave-address-book/AaveV3EthereumEtherFi.sol';
import {AaveV3PayloadEthereumEtherFi} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereumEtherFi.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915 is
  AaveV3PayloadEthereumEtherFi
{
  // https://etherscan.io/address/0x4501b17229a27eE82F364172928e30526D2215E8#code
  address public constant FRAX_PRICE_FEED = 0x4501b17229a27eE82F364172928e30526D2215E8;

  function _postExecute() internal override {
    AaveV3EthereumEtherFi.POOL_CONFIGURATOR.setReserveFreeze(
      AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING,
      true
    );
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](0);
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
      asset: AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00, // 20% (2 decimals)
        variableRateSlope1: 5_50, // 5.5% (2 decimals)
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
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](1);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING,
      FRAX_PRICE_FEED
    );
  }
}
