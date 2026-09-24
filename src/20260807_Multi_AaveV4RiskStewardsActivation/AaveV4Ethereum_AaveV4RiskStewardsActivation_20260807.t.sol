// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {ProtocolV4TestBase} from 'aave-helpers/src/ProtocolV4TestBase.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4Ethereum, AaveV4EthereumHubs, AaveV4EthereumSpokes, AaveV4EthereumSpokePriceFeeds, AaveV4EthereumAssets} from 'aave-address-book/AaveV4Ethereum.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IHub, IHubConfigurator, ISpoke, ITokenizationSpoke} from 'aave-address-book/AaveV4.sol';
import {IPendlePriceCapAdapter} from 'src/interfaces/IPendlePriceCapAdapter.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskSteward} from 'src/interfaces/IRiskSteward.sol';
import {AaveV4RiskStewardsActivationTestBase} from 'src/helpers/risk-stewards/AaveV4RiskStewardsActivationTestBase.sol';
import {AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807} from './AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807_Test is
  ProtocolV4TestBaseEthereum,
  AaveV4RiskStewardsActivationTestBase
{
  // capped wstETH / stETH(ETH) / USD, the price source of wstETH on the main spoke
  IPriceCapAdapter internal constant wstETH_CAPO_ADAPTER =
    IPriceCapAdapter(0xe1D97bF61901B075E9626c8A2340a7De385861Ef);

  function _createFork() internal override {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26032000);
  }

  function _deployProposal() internal override returns (IProposalGenericExecutor) {
    return new AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807();
  }

  function _executor() internal pure override returns (address) {
    return GovernanceV3Ethereum.EXECUTOR_LVL_1;
  }

  function _riskSteward() internal pure override returns (address) {
    return AaveV4Ethereum.RISK_STEWARD;
  }

  function _v3RiskSteward() internal pure override returns (IRiskSteward) {
    return IRiskSteward(AaveV3Ethereum.RISK_STEWARD);
  }

  function _aclManager() internal pure override returns (IACLManager) {
    return AaveV3Ethereum.ACL_MANAGER;
  }

  function _hubConfigurator() internal pure override returns (IHubConfigurator) {
    return AaveV4Ethereum.HUB_CONFIGURATOR;
  }

  function _hub() internal pure override returns (IHub) {
    return AaveV4EthereumHubs.CORE_HUB;
  }

  function _spoke() internal pure override returns (ISpoke) {
    return AaveV4EthereumSpokes.MAIN_SPOKE;
  }

  function _asset() internal pure override returns (address) {
    return AaveV4EthereumAssets.WETH_UNDERLYING;
  }

  function _lstAdapter() internal pure override returns (IPriceCapAdapter) {
    return wstETH_CAPO_ADAPTER;
  }

  function _stableAdapter() internal pure override returns (IPriceCapAdapterStable) {
    return IPriceCapAdapterStable(AaveV4EthereumSpokePriceFeeds.MAIN_SPOKE_USDC_PRICE_FEED);
  }

  /// @dev the only Pendle price source not yet past maturity at the fork block; a matured adapter
  /// reverts on any `setDiscountRatePerYear` call
  function _pendleAdapter() internal pure override returns (IPendlePriceCapAdapter) {
    return
      IPendlePriceCapAdapter(
        AaveV4EthereumSpokePriceFeeds.USDG_PENDLE_SPOKE_PT_USDG_24SEP2026_PRICE_FEED
      );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Ethereum_AaveV4RiskStewardsActivation_20260807', address(proposal));
  }

  function _getTokenizationSpokes()
    internal
    view
    override(ProtocolV4TestBase, ProtocolV4TestBaseEthereum)
    returns (ITokenizationSpoke[] memory)
  {
    ITokenizationSpoke[] memory all = super._getTokenizationSpokes();
    uint256 activeCount;
    for (uint256 i; i < all.length; ++i) {
      if (_isTokenizationSpokeActive(all[i])) ++activeCount;
    }
    ITokenizationSpoke[] memory active = new ITokenizationSpoke[](activeCount);
    uint256 index;
    for (uint256 i; i < all.length; ++i) {
      if (_isTokenizationSpokeActive(all[i])) active[index++] = all[i];
    }
    return active;
  }

  function _isTokenizationSpokeActive(
    ITokenizationSpoke tokenizationSpoke
  ) internal view returns (bool) {
    return
      IHub(tokenizationSpoke.hub())
        .getSpokeConfig(tokenizationSpoke.assetId(), address(tokenizationSpoke))
        .active;
  }
}
