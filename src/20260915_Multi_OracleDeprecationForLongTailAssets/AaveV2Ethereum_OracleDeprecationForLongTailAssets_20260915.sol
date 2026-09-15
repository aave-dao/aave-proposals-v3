// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveV2PayloadEthereum} from 'aave-helpers/src/v2-config-engine/AaveV2PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV2ConfigEngine} from 'aave-helpers/src/v2-config-engine/IAaveV2ConfigEngine.sol';
import {IV2RateStrategyFactory} from 'aave-helpers/src/v2-config-engine/IV2RateStrategyFactory.sol';

import {DeprecationPriceAdapter} from './DeprecationPriceAdapter.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915 is AaveV2PayloadEthereum {
  function _postExecute() internal override {
    address[] memory assets = new address[](13);
    address[] memory feeds = new address[](13);
    assets[0] = AaveV2EthereumAssets.AMPL_UNDERLYING;
    feeds[0] = AMPL_PRICE_FEED;
    assets[1] = AaveV2EthereumAssets.BAL_UNDERLYING;
    feeds[1] = BAL_PRICE_FEED;
    assets[2] = AaveV2EthereumAssets.ENJ_UNDERLYING;
    feeds[2] = ENJ_PRICE_FEED;
    assets[3] = AaveV2EthereumAssets.FRAX_UNDERLYING;
    feeds[3] = FRAX_PRICE_FEED;
    assets[4] = AaveV2EthereumAssets.KNC_UNDERLYING;
    feeds[4] = KNC_PRICE_FEED;
    assets[5] = AaveV2EthereumAssets.LUSD_UNDERLYING;
    feeds[5] = LUSD_PRICE_FEED;
    assets[6] = AaveV2EthereumAssets.RAI_UNDERLYING;
    feeds[6] = RAI_PRICE_FEED;
    assets[7] = AaveV2EthereumAssets.REN_UNDERLYING;
    feeds[7] = REN_PRICE_FEED;
    assets[8] = AaveV2EthereumAssets.TUSD_UNDERLYING;
    feeds[8] = TUSD_PRICE_FEED;
    assets[9] = AaveV2EthereumAssets.USDP_UNDERLYING;
    feeds[9] = USDP_PRICE_FEED;
    assets[10] = AaveV2EthereumAssets.YFI_UNDERLYING;
    feeds[10] = YFI_PRICE_FEED;
    assets[11] = AaveV2EthereumAssets.ZRX_UNDERLYING;
    feeds[11] = ZRX_PRICE_FEED;
    assets[12] = AaveV2EthereumAssets.sUSD_UNDERLYING;
    feeds[12] = sUSD_PRICE_FEED;
    AaveV2Ethereum.ORACLE.setAssetSources(assets, feeds);
  }

  function rateStrategiesUpdates()
    public
    pure
    override
    returns (IAaveV2ConfigEngine.RateStrategyUpdate[] memory)
  {
    IAaveV2ConfigEngine.RateStrategyUpdate[]
      memory rateStrategies = new IAaveV2ConfigEngine.RateStrategyUpdate[](9);
    rateStrategies[0] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.AMPL_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(0),
        variableRateSlope1: _bpsToRay(0),
        variableRateSlope2: _bpsToRay(0),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[1] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.TUSD_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(0),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[2] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.BAL_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[3] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.ENJ_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[4] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.sUSD_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(0),
        variableRateSlope1: _bpsToRay(0),
        variableRateSlope2: _bpsToRay(0),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[5] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.KNC_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[6] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.LUSD_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[7] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.REN_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00),
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00),
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[8] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.ZRX_UNDERLYING,
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
  uint256 public constant AMPL_PRICE_USD = 117420000;
  address public immutable AMPL_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        AMPL_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'AMPL / ETH fixed USD target'
      )
    );
  uint256 public constant BAL_PRICE_USD = 14240000;
  address public immutable BAL_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        BAL_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'BAL / ETH fixed USD target'
      )
    );
  uint256 public constant ENJ_PRICE_USD = 3720000;
  address public immutable ENJ_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        ENJ_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'ENJ / ETH fixed USD target'
      )
    );
  uint256 public constant FRAX_PRICE_USD = 100000000;
  address public immutable FRAX_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        FRAX_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'FRAX / ETH fixed USD target'
      )
    );
  uint256 public constant KNC_PRICE_USD = 13560000;
  address public immutable KNC_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        KNC_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'KNC / ETH fixed USD target'
      )
    );
  uint256 public constant LUSD_PRICE_USD = 100000000;
  address public immutable LUSD_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        LUSD_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'LUSD / ETH fixed USD target'
      )
    );
  uint256 public constant RAI_PRICE_USD = 273390000;
  address public immutable RAI_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        RAI_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'RAI / ETH fixed USD target'
      )
    );
  uint256 public constant REN_PRICE_USD = 330000;
  address public immutable REN_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        REN_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'REN / ETH fixed USD target'
      )
    );
  uint256 public constant TUSD_PRICE_USD = 100000000;
  address public immutable TUSD_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        TUSD_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'TUSD / ETH fixed USD target'
      )
    );
  uint256 public constant USDP_PRICE_USD = 100000000;
  address public immutable USDP_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        USDP_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'USDP / ETH fixed USD target'
      )
    );
  uint256 public constant YFI_PRICE_USD = 239681630000;
  address public immutable YFI_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        YFI_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'YFI / ETH fixed USD target'
      )
    );
  uint256 public constant ZRX_PRICE_USD = 9660000;
  address public immutable ZRX_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        ZRX_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'ZRX / ETH fixed USD target'
      )
    );
  uint256 public constant sUSD_PRICE_USD = 29520000;
  address public immutable sUSD_PRICE_FEED =
    address(
      new DeprecationPriceAdapter(
        sUSD_PRICE_USD,
        ChainlinkEthereum.ETH__USD,
        'sUSD / ETH fixed USD target'
      )
    );
}
