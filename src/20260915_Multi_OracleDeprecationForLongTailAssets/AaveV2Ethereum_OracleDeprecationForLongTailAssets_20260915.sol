// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveV2PayloadEthereum} from 'aave-helpers/src/v2-config-engine/AaveV2PayloadEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV2ConfigEngine} from 'aave-helpers/src/v2-config-engine/IAaveV2ConfigEngine.sol';
import {IV2RateStrategyFactory} from 'aave-helpers/src/v2-config-engine/IV2RateStrategyFactory.sol';

/**
 * @title Oracle Deprecation for Long-tail Assets
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xaa683250ff2e2835b9ac945d6219a35cdca1d4134f49e3bce6763ca8d8944c08
 * - Discussion: https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400
 */
contract AaveV2Ethereum_OracleDeprecationForLongTailAssets_20260915 is AaveV2PayloadEthereum {
  // https://etherscan.io/address/0x37C6089246750CEad02C0140999cefA063283D4c#code
  address public constant AMPL_PRICE_FEED = 0x37C6089246750CEad02C0140999cefA063283D4c;
  // https://etherscan.io/address/0x6215b7ee67f85B7DFe569F077a0D20dEd13a49c3#code
  address public constant BAL_PRICE_FEED = 0x6215b7ee67f85B7DFe569F077a0D20dEd13a49c3;
  // https://etherscan.io/address/0x67E0E09914089d7F50D0dCb55A85C9606A29008e#code
  address public constant ENJ_PRICE_FEED = 0x67E0E09914089d7F50D0dCb55A85C9606A29008e;
  // https://etherscan.io/address/0x4d8725f7e86475fa91BDFD17828dB6800A67f4d1#code
  address public constant FRAX_PRICE_FEED = 0x4d8725f7e86475fa91BDFD17828dB6800A67f4d1;
  // https://etherscan.io/address/0x2178B420243Fd8934a500f915112dbF07C4356FA#code
  address public constant KNC_PRICE_FEED = 0x2178B420243Fd8934a500f915112dbF07C4356FA;
  // https://etherscan.io/address/0x11F6f9b366C27819C3552009bcA9EEAd8d5D8FD7#code
  address public constant LUSD_PRICE_FEED = 0x11F6f9b366C27819C3552009bcA9EEAd8d5D8FD7;
  // https://etherscan.io/address/0xf8B9bD396f990780c5Fae80D97a83c31C799069D#code
  address public constant RAI_PRICE_FEED = 0xf8B9bD396f990780c5Fae80D97a83c31C799069D;
  // https://etherscan.io/address/0x054B1406B06A5FA6eCcfa04f2EFB9F621d454089#code
  address public constant REN_PRICE_FEED = 0x054B1406B06A5FA6eCcfa04f2EFB9F621d454089;
  // https://etherscan.io/address/0xA7572674a3f2fD8045A6A3F6ffd4Bab40FC693be#code
  address public constant TUSD_PRICE_FEED = 0xA7572674a3f2fD8045A6A3F6ffd4Bab40FC693be;
  // https://etherscan.io/address/0xa8FAE5a2f034c2EBDb06BFCc6CEE5CC61644A242#code
  address public constant USDP_PRICE_FEED = 0xa8FAE5a2f034c2EBDb06BFCc6CEE5CC61644A242;
  // https://etherscan.io/address/0x949E6a1C7c20409b20faa3eA20cEf8ceC16B41F5#code
  address public constant YFI_PRICE_FEED = 0x949E6a1C7c20409b20faa3eA20cEf8ceC16B41F5;
  // https://etherscan.io/address/0xb7C850e4AfCeCbf4532A44AE610156E346CFa209#code
  address public constant ZRX_PRICE_FEED = 0xb7C850e4AfCeCbf4532A44AE610156E346CFa209;
  // https://etherscan.io/address/0xf05d9e94AF7eB79cE6123aF8034b53a0751222d2#code
  address public constant sUSD_PRICE_FEED = 0xf05d9e94AF7eB79cE6123aF8034b53a0751222d2;

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
        baseVariableBorrowRate: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        variableRateSlope1: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        variableRateSlope2: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[1] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.TUSD_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[2] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.BAL_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00), // 40% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[3] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.ENJ_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00), // 40% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[4] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.sUSD_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        variableRateSlope1: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        variableRateSlope2: _bpsToRay(0), // 0% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[5] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.KNC_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00), // 40% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[6] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.LUSD_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00), // 40% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[7] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.REN_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00), // 40% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });
    rateStrategies[8] = IAaveV2ConfigEngine.RateStrategyUpdate({
      asset: AaveV2EthereumAssets.ZRX_UNDERLYING,
      params: IV2RateStrategyFactory.RateStrategyParams({
        optimalUtilizationRate: EngineFlags.KEEP_CURRENT,
        baseVariableBorrowRate: _bpsToRay(20_00), // 20% (2 decimals; converted to 27 decimals)
        variableRateSlope1: EngineFlags.KEEP_CURRENT,
        variableRateSlope2: _bpsToRay(40_00), // 40% (2 decimals; converted to 27 decimals)
        stableRateSlope1: EngineFlags.KEEP_CURRENT,
        stableRateSlope2: EngineFlags.KEEP_CURRENT
      })
    });

    return rateStrategies;
  }
}
