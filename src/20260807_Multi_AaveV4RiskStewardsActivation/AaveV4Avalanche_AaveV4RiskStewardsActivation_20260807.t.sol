// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {ProtocolV4TestBaseAvalanche} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseAvalanche.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {AaveV3Avalanche} from 'aave-address-book/AaveV3Avalanche.sol';
import {AaveV4Avalanche, AaveV4AvalancheHubs, AaveV4AvalancheSpokes, AaveV4AvalancheSpokePriceFeeds, AaveV4AvalancheAssets} from 'aave-address-book/AaveV4Avalanche.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IHub, IHubConfigurator, ISpoke} from 'aave-address-book/AaveV4.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskSteward} from 'src/interfaces/IRiskSteward.sol';
import {AaveV4RiskStewardsActivationTestBase} from 'src/helpers/risk-stewards/AaveV4RiskStewardsActivationTestBase.sol';
import {AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807} from './AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807_Test is
  ProtocolV4TestBaseAvalanche,
  AaveV4RiskStewardsActivationTestBase
{
  // capped sAVAX / AVAX / USD, the price source of sAVAX on the AVAX correlated spoke
  IPriceCapAdapter internal constant sAVAX_CAPO_ADAPTER =
    IPriceCapAdapter(0xB2B332f27e4B7305649a228C31Ed9858c5a6bAD9);

  function _createFork() internal override {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 92229650);
  }

  function _deployProposal() internal override returns (IProposalGenericExecutor) {
    return new AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807();
  }

  function _executor() internal pure override returns (address) {
    return GovernanceV3Avalanche.EXECUTOR_LVL_1;
  }

  function _riskSteward() internal pure override returns (address) {
    return AaveV4Avalanche.RISK_STEWARD;
  }

  function _v3RiskSteward() internal pure override returns (IRiskSteward) {
    return IRiskSteward(AaveV3Avalanche.RISK_STEWARD);
  }

  function _aclManager() internal pure override returns (IACLManager) {
    return AaveV3Avalanche.ACL_MANAGER;
  }

  function _hubConfigurator() internal pure override returns (IHubConfigurator) {
    return AaveV4Avalanche.HUB_CONFIGURATOR;
  }

  function _hub() internal pure override returns (IHub) {
    return AaveV4AvalancheHubs.CORE_HUB;
  }

  function _spoke() internal pure override returns (ISpoke) {
    return AaveV4AvalancheSpokes.MAIN_SPOKE;
  }

  function _asset() internal pure override returns (address) {
    return AaveV4AvalancheAssets.WAVAX_UNDERLYING;
  }

  function _lstAdapter() internal pure override returns (IPriceCapAdapter) {
    return sAVAX_CAPO_ADAPTER;
  }

  function _stableAdapter() internal pure override returns (IPriceCapAdapterStable) {
    return IPriceCapAdapterStable(AaveV4AvalancheSpokePriceFeeds.MAIN_SPOKE_USDC_PRICE_FEED);
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Avalanche_AaveV4RiskStewardsActivation_20260807', address(proposal));
  }
}
