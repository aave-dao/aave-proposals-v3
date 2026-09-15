// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3PayloadEthereum} from 'aave-helpers/src/v3-config-engine/AaveV3PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV3Ethereum_OracleDeprecationForLongTailAssets_20260915 is AaveV3PayloadEthereum {
  function _postExecute() internal override {
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.BAL_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.FRAX_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.LUSD_UNDERLYING, true);
    AaveV3Ethereum.POOL_CONFIGURATOR.setReserveFreeze(AaveV3EthereumAssets.RPL_UNDERLYING, true);
  }

  function capsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](5);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3EthereumAssets.FXS_UNDERLYING, 1, 1);
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate(AaveV3EthereumAssets.KNC_UNDERLYING, 1, 1);
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate(
      AaveV3EthereumAssets.LUSD_UNDERLYING,
      1,
      EngineFlags.KEEP_CURRENT
    );
    capsUpdate[3] = IAaveV3ConfigEngine.CapsUpdate(
      AaveV3EthereumAssets.RPL_UNDERLYING,
      1,
      EngineFlags.KEEP_CURRENT
    );
    capsUpdate[4] = IAaveV3ConfigEngine.CapsUpdate(AaveV3EthereumAssets.STG_UNDERLYING, 1, 1);
  }

  function borrowsUpdates()
    public
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[]
      memory borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](3);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.LUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FRAX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.RPL_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
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
      memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](7);
    rateStrategies[0] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.FRAX_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 5_00,
        variableRateSlope1: 5_50,
        variableRateSlope2: 100_00
      })
    });
    rateStrategies[1] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.LUSD_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 5_00,
        variableRateSlope1: 5_00,
        variableRateSlope2: 100_00
      })
    });
    rateStrategies[2] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.RPL_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 5_00,
        variableRateSlope1: 8_50,
        variableRateSlope2: 100_00
      })
    });
    rateStrategies[3] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.BAL_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 15_00,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[4] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.FXS_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 9_00,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[5] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.KNC_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 9_00,
        variableRateSlope2: 40_00
      })
    });
    rateStrategies[6] = IAaveV3ConfigEngine.RateStrategyUpdate({
      asset: AaveV3EthereumAssets.STG_UNDERLYING,
      params: IAaveV3ConfigEngine.InterestRateInputData({
        optimalUsageRatio: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: 20_00,
        variableRateSlope1: 7_00,
        variableRateSlope2: 40_00
      })
    });

    return rateStrategies;
  }
  // TODO: LLR must specify the Aave V3 Ethereum Core BAL fixed USD price.
  uint256 public constant BAL_PRICE_USD = 0;
  // Keep the draft deployable until this price is specified; _preExecute blocks execution.
  address public immutable BAL_PRICE_FEED =
    BAL_PRICE_USD == 0
      ? address(0)
      : address(
        new DeprecationPriceAdapter(BAL_PRICE_USD, address(0), 'BAL / USD fixed USD target')
      );
  uint256 public constant FRAX_PRICE_USD = 100000000;
  address public immutable FRAX_PRICE_FEED =
    address(new DeprecationPriceAdapter(FRAX_PRICE_USD, address(0), 'FRAX / USD fixed USD target'));
  uint256 public constant FXS_PRICE_USD = 54150000;
  address public immutable FXS_PRICE_FEED =
    address(new DeprecationPriceAdapter(FXS_PRICE_USD, address(0), 'FXS / USD fixed USD target'));
  uint256 public constant KNC_PRICE_USD = 14720000;
  address public immutable KNC_PRICE_FEED =
    address(new DeprecationPriceAdapter(KNC_PRICE_USD, address(0), 'KNC / USD fixed USD target'));
  uint256 public constant LUSD_PRICE_USD = 100000000;
  address public immutable LUSD_PRICE_FEED =
    address(new DeprecationPriceAdapter(LUSD_PRICE_USD, address(0), 'LUSD / USD fixed USD target'));
  uint256 public constant RPL_PRICE_USD = 195430000;
  address public immutable RPL_PRICE_FEED =
    address(new DeprecationPriceAdapter(RPL_PRICE_USD, address(0), 'RPL / USD fixed USD target'));
  uint256 public constant STG_PRICE_USD = 26660000;
  address public immutable STG_PRICE_FEED =
    address(new DeprecationPriceAdapter(STG_PRICE_USD, address(0), 'STG / USD fixed USD target'));
  function _preExecute() internal pure override {
    // Circuit breaker: do not execute until LLR supplies the missing fixed prices.
    require(BAL_PRICE_USD > 0, 'UNSPECIFIED_AaveV3Ethereum_BAL_PRICE');
  }
  function priceFeedsUpdates()
    public
    view
    override
    returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory updates)
  {
    updates = new IAaveV3ConfigEngine.PriceFeedUpdate[](7);
    updates[0] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.BAL_UNDERLYING,
      BAL_PRICE_FEED
    );
    updates[1] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.FRAX_UNDERLYING,
      FRAX_PRICE_FEED
    );
    updates[2] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.FXS_UNDERLYING,
      FXS_PRICE_FEED
    );
    updates[3] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.KNC_UNDERLYING,
      KNC_PRICE_FEED
    );
    updates[4] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.LUSD_UNDERLYING,
      LUSD_PRICE_FEED
    );
    updates[5] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.RPL_UNDERLYING,
      RPL_PRICE_FEED
    );
    updates[6] = IAaveV3ConfigEngine.PriceFeedUpdate(
      AaveV3EthereumAssets.STG_UNDERLYING,
      STG_PRICE_FEED
    );
  }
}
