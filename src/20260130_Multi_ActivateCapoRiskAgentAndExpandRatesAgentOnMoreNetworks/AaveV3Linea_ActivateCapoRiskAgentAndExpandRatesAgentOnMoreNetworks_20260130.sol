// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Linea, AaveV3LineaAssets} from 'aave-address-book/AaveV3Linea.sol';
import {MiscLinea} from 'aave-address-book/MiscLinea.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {AgentConfigLib} from './AgentConfigLib.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title Activate Capo Risk Agent and expand Rates Agent on more networks
 * @author BGD Labs (@bgdlabs)
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601
 */
contract AaveV3Linea_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130 is
  IProposalGenericExecutor
{
  uint256 public constant RATES_AGENT_ID = 0;

  function execute() external {
    IRangeValidationModule(MiscLinea.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscLinea.AGENT_HUB,
      RATES_AGENT_ID,
      AaveV3LineaAssets.WETH_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.wethSlope2RangeConfig()
    );
    IRangeValidationModule(MiscLinea.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscLinea.AGENT_HUB,
      RATES_AGENT_ID,
      AaveV3LineaAssets.USDC_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
    IRangeValidationModule(MiscLinea.RANGE_VALIDATION_MODULE).setRangeConfigByMarket(
      MiscLinea.AGENT_HUB,
      RATES_AGENT_ID,
      AaveV3LineaAssets.USDT_UNDERLYING,
      'VariableRateSlope2',
      AgentConfigLib.stablecoinSlope2RangeConfig()
    );
  }
}
