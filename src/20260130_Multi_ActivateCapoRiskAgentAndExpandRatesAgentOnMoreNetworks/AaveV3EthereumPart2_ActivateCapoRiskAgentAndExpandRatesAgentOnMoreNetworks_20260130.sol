// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {AgentConfigLib} from './AgentConfigLib.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title Activate Capo Risk Agent and expand Rates Agent on more networks
 * @author BGD Labs (@bgdlabs)
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601
 */
contract AaveV3EthereumPart2_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130 is
  IProposalGenericExecutor
{
  uint256 public constant CORE_RATES_AGENT_ID = 2;

  function execute() external {
    IRangeValidationModule(MiscEthereum.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscEthereum.AGENT_HUB,
      CORE_RATES_AGENT_ID,
      AaveV3EthereumAssets.WETH_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.wethSlope2RangeConfig()
    );
    IRangeValidationModule(MiscEthereum.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscEthereum.AGENT_HUB,
      CORE_RATES_AGENT_ID,
      AaveV3EthereumAssets.USDC_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
    IRangeValidationModule(MiscEthereum.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscEthereum.AGENT_HUB,
      CORE_RATES_AGENT_ID,
      AaveV3EthereumAssets.USDT_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
    IRangeValidationModule(MiscEthereum.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscEthereum.AGENT_HUB,
      CORE_RATES_AGENT_ID,
      AaveV3EthereumAssets.USDe_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
  }
}
