// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {ProtocolV4TestBaseBase} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseBase.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {AaveV4Base, AaveV4BaseHubs, AaveV4BaseSpokes, AaveV4BaseSpokePriceFeeds, AaveV4BaseAssets} from 'aave-address-book/AaveV4Base.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IHub, IHubConfigurator, ISpoke} from 'aave-address-book/AaveV4.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from 'src/interfaces/IPriceCapAdapterStable.sol';
import {IRiskSteward} from 'src/interfaces/IRiskSteward.sol';
import {AaveV4RiskStewardsActivationTestBase} from './AaveV4RiskStewardsActivationTestBase.sol';
import {AaveV4Base_AaveV4RiskStewardsActivation_20260807} from './AaveV4Base_AaveV4RiskStewardsActivation_20260807.sol';

/**
 * @dev Test for AaveV4Base_AaveV4RiskStewardsActivation_20260807
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260807_Multi_AaveV4RiskStewardsActivation/AaveV4Base_AaveV4RiskStewardsActivation_20260807.t.sol -vv
 */
contract AaveV4Base_AaveV4RiskStewardsActivation_20260807_Test is
  ProtocolV4TestBaseBase,
  AaveV4RiskStewardsActivationTestBase
{
  function _createFork() internal override {
    vm.createSelectFork(vm.rpcUrl('base'), 51642134);
  }

  function _deployProposal() internal override returns (IProposalGenericExecutor) {
    return new AaveV4Base_AaveV4RiskStewardsActivation_20260807();
  }

  function _executor() internal pure override returns (address) {
    return GovernanceV3Base.EXECUTOR_LVL_1;
  }

  function _riskSteward() internal pure override returns (address) {
    return AaveV4Base.RISK_STEWARD;
  }

  function _v3RiskSteward() internal pure override returns (IRiskSteward) {
    return IRiskSteward(AaveV3Base.RISK_STEWARD);
  }

  function _aclManager() internal pure override returns (IACLManager) {
    return AaveV3Base.ACL_MANAGER;
  }

  function _hubConfigurator() internal pure override returns (IHubConfigurator) {
    return AaveV4Base.HUB_CONFIGURATOR;
  }

  function _hub() internal pure override returns (IHub) {
    return AaveV4BaseHubs.EQUITIES_HUB;
  }

  function _spoke() internal pure override returns (ISpoke) {
    return AaveV4BaseSpokes.MAG7_SPOKE;
  }

  function _asset() internal pure override returns (address) {
    return AaveV4BaseAssets.AAPLc_UNDERLYING;
  }

  /// @dev v4 Base lists no LST, so the lst bound is exercised on the v3 wstETH adapter, which the
  /// same risk admin role unlocks
  function _lstAdapter() internal pure override returns (IPriceCapAdapter) {
    return IPriceCapAdapter(AaveV3BaseAssets.wstETH_ORACLE);
  }

  function _stableAdapter() internal pure override returns (IPriceCapAdapterStable) {
    return IPriceCapAdapterStable(AaveV4BaseSpokePriceFeeds.MAG7_SPOKE_USDC_PRICE_FEED);
  }

  /**
   * @dev executes the payload with config snapshots and diff; the e2e runs in `test_e2e`
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4Base_AaveV4RiskStewardsActivation_20260807',
      payload: address(proposal),
      runE2E: false,
      testPositionManagers: false
    });
  }

  /// @dev The generic e2e suite over every spoke and tokenization spoke. The seven equities are B20
  /// tokens (node-native, code 0xef, balances outside EVM storage): stable forge cannot execute
  /// them, so this test only runs under a forge that selects the Base EVM (`--network base`) and is
  /// skipped, not passed, anywhere else. See `_requireB20Semantics`.
  function test_e2e() public {
    _requireB20Semantics();
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestAllSpokes({spokes: _getSpokes(), testPositionManagers: false});
    e2eTestAllTokenizationSpokes(_getTokenizationSpokes());
  }

  function _requireB20Semantics() internal {
    (bool ok, ) = _asset().staticcall(abi.encodeWithSignature('decimals()'));
    vm.skip(!ok, 'requires forge with --network base for the B20 equity precompiles');
  }
}
