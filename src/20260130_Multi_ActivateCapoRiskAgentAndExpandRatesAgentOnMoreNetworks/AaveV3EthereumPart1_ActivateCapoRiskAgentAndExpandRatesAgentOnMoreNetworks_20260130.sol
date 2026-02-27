// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLido} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';

import {AgentConfigLib} from './AgentConfigLib.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';
import {BaseActivateRiskAgentPayload, CollectorUtils, ICollector} from './BaseActivateRiskAgentPayload.sol';

/**
 * @title Activate Capo Risk Agent and expand Rates Agent on more networks
 * @author BGD Labs (@bgdlabs)
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0x66aa6904f140d56ada880f45c911994c5c6cc20109b55081f508ccdd6417066d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-calibration-of-capo-parameters-via-risk-oracles/22601
 */
contract AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130 is
  BaseActivateRiskAgentPayload
{
  using CollectorUtils for ICollector;

  address public constant CAPO_AGENT = 0xCc18Be380838956aad41FD22466085eD66aaBB46;
  uint96 public constant LINK_AMOUNT = 200 ether;

  address public constant BGD_RECEIVER = 0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF;
  uint96 public constant BGD_REIMBURSE_LINK_AMOUNT = 108 ether;

  function getAllowedMarkets() public pure override returns (address[] memory) {
    address[] memory markets = new address[](14);
    markets[0] = AaveV3EthereumAssets.wstETH_UNDERLYING;
    markets[1] = AaveV3EthereumAssets.weETH_UNDERLYING;
    markets[2] = AaveV3EthereumAssets.rsETH_UNDERLYING;
    markets[3] = AaveV3EthereumAssets.osETH_UNDERLYING;
    markets[4] = AaveV3EthereumAssets.ezETH_UNDERLYING;
    markets[5] = AaveV3EthereumAssets.cbETH_UNDERLYING;
    markets[6] = AaveV3EthereumAssets.rETH_UNDERLYING;
    markets[7] = AaveV3EthereumAssets.tETH_UNDERLYING;
    markets[8] = AaveV3EthereumAssets.ETHx_UNDERLYING;
    markets[9] = AaveV3EthereumAssets.LBTC_UNDERLYING;
    markets[10] = AaveV3EthereumAssets.eBTC_UNDERLYING;
    markets[11] = AaveV3EthereumAssets.sUSDe_UNDERLYING;
    markets[12] = AaveV3EthereumAssets.syrupUSDT_UNDERLYING;
    markets[13] = AaveV3EthereumAssets.sDAI_UNDERLYING;

    return markets;
  }

  function _getConfig() internal pure override returns (PayloadConfig memory) {
    return
      PayloadConfig({
        admin: GovernanceV3Ethereum.EXECUTOR_LVL_1,
        riskOracle: AaveV3Ethereum.EDGE_RISK_ORACLE,
        agentAddress: CAPO_AGENT,
        expirationPeriod: 3 days,
        minimumDelay: 3 days,
        updateType: 'CapoPriceCapUpdate_Core',
        agentContext: '',
        agentHub: MiscEthereum.AGENT_HUB,
        rangeValidationModule: MiscEthereum.RANGE_VALIDATION_MODULE,
        robotOperator: MiscEthereum.AAVE_CL_ROBOT_OPERATOR,
        agentHubAutomation: MiscEthereum.AGENT_HUB_AUTOMATION,
        linkToken: AaveV3EthereumAssets.LINK_UNDERLYING,
        linkAmount: LINK_AMOUNT,
        withdrawLinkFromCollector: true,
        pool: AaveV3Ethereum.POOL,
        collector: AaveV3Ethereum.COLLECTOR,
        automationName: 'Core Capo Agent'
      });
  }

  function _configureRangeValidation(
    address rangeValidationModule,
    address agentHub,
    uint256 agentId
  ) internal override {
    IRangeValidationModule(rangeValidationModule).setDefaultRangeConfig(
      agentHub,
      agentId,
      'CapoSnapshotRatio',
      AgentConfigLib.capoSnapshotRatioRangeConfig()
    );
    IRangeValidationModule(rangeValidationModule).setDefaultRangeConfig(
      agentHub,
      agentId,
      'CapoMaxYearlyGrowthRatePercent',
      AgentConfigLib.capoMaxYearlyRangeConfig()
    );
  }

  // Ethereum grants risk admin to both Core and Lido ACL managers as on ezETH we're using same capo on lido and core
  function _grantRiskAdminPermissions(address agentAddress) internal override {
    AaveV3Ethereum.ACL_MANAGER.addRiskAdmin(agentAddress);
    AaveV3EthereumLido.ACL_MANAGER.addRiskAdmin(agentAddress);
  }

  function _postExecute() internal override {
    AaveV3Ethereum.COLLECTOR.withdrawFromV3(
      CollectorUtils.IOInput({
        pool: address(AaveV3Ethereum.POOL),
        underlying: AaveV3EthereumAssets.LINK_UNDERLYING,
        amount: BGD_REIMBURSE_LINK_AMOUNT
      }),
      BGD_RECEIVER
    );
  }
}
