// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {AaveV3PayloadArbitrum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadArbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Arbitrum_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadArbitrum {
  function _postExecute() internal override {
    AaveV3Arbitrum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3ArbitrumAssets.FRAX_UNDERLYING, true);
    AaveV3Arbitrum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3ArbitrumAssets.LUSD_UNDERLYING, true);
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3ArbitrumAssets.MAI_UNDERLYING, 1, 1);
  }

  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](2);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 100_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3ArbitrumAssets.FRAX_UNDERLYING,
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
      memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](3);
    rateStrategies[0] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 5_00,
        variableRateSlope1: 5_50,
        variableRateSlope2: 100_00
      })
    });
    rateStrategies[1] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 5_00,
        variableRateSlope1: 6_50,
        variableRateSlope2: 100_00
      })
    });
    rateStrategies[2] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3ArbitrumAssets.MAI_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 9_00,
        variableRateSlope2: 40_00
      })
    });

    return rateStrategies;
  }
  uint256 public constant FRAX_PRICE_USD = 100000000;
  address public immutable FRAX_PRICE_FEED =
    address(new DeprecationPriceAdapter(FRAX_PRICE_USD, address(0), 'FRAX / USD fixed USD target'));
  uint256 public constant LUSD_PRICE_USD = 100000000;
  address public immutable LUSD_PRICE_FEED =
    address(new DeprecationPriceAdapter(LUSD_PRICE_USD, address(0), 'LUSD / USD fixed USD target'));
  uint256 public constant MAI_PRICE_USD = 95300000;
  address public immutable MAI_PRICE_FEED =
    address(new DeprecationPriceAdapter(MAI_PRICE_USD, address(0), 'MAI / USD fixed USD target'));
  function priceFeedsUpdates()
    public
    view
    override
    returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory updates)
  {
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](3);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3ArbitrumAssets.FRAX_UNDERLYING,
      FRAX_PRICE_FEED
    );
    updates[1] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3ArbitrumAssets.LUSD_UNDERLYING,
      LUSD_PRICE_FEED
    );
    updates[2] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3ArbitrumAssets.MAI_UNDERLYING,
      MAI_PRICE_FEED
    );
  }
}
