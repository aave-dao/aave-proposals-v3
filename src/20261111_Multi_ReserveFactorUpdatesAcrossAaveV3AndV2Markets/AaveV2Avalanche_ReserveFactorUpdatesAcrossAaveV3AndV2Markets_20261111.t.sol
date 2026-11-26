// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Avalanche, AaveV2AvalancheAssets} from 'aave-address-book/AaveV2Avalanche.sol';

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV2TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111} from './AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol';

/**
 * @dev Test for AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol -vv
 */
contract AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111_Test is
  ProtocolV2TestBase
{
  AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 100047514);
    proposal = new AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    (ReserveConfig[] memory allConfigsBefore, ReserveConfig[] memory allConfigsAfter) = defaultTest(
      'AaveV2Avalanche_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111',
      AaveV2Avalanche.POOL,
      address(proposal)
    );

    address[] memory assetsChanged = new address[](6);
    assetsChanged[0] = AaveV2AvalancheAssets.DAIe_UNDERLYING;
    assetsChanged[1] = AaveV2AvalancheAssets.USDCe_UNDERLYING;
    assetsChanged[2] = AaveV2AvalancheAssets.USDTe_UNDERLYING;
    assetsChanged[3] = AaveV2AvalancheAssets.WETHe_UNDERLYING;
    assetsChanged[4] = AaveV2AvalancheAssets.WAVAX_UNDERLYING;
    assetsChanged[5] = AaveV2AvalancheAssets.AAVEe_UNDERLYING;

    uint256[] memory reserveFactors = new uint256[](6);
    reserveFactors[0] = proposal.DAIe_RF();
    reserveFactors[1] = proposal.USDCe_RF();
    reserveFactors[2] = proposal.USDTe_RF();
    reserveFactors[3] = proposal.WETHe_RF();
    reserveFactors[4] = proposal.WAVAX_RF();
    reserveFactors[5] = proposal.AAVEe_RF();

    _noReservesConfigsChangesApartFrom(allConfigsBefore, allConfigsAfter, assetsChanged);

    for (uint256 i = 0; i < assetsChanged.length; i++) {
      ReserveConfig memory expected = _findReserveConfig(allConfigsBefore, assetsChanged[i]);
      expected.reserveFactor = reserveFactors[i];
      _requireNoChangeInConfigs(expected, _findReserveConfig(allConfigsAfter, assetsChanged[i]));
    }
  }

  function test_reserveFactorUpdates() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(_reserveFactor(AaveV2AvalancheAssets.DAIe_UNDERLYING), proposal.DAIe_RF());
    assertEq(_reserveFactor(AaveV2AvalancheAssets.USDCe_UNDERLYING), proposal.USDCe_RF());
    assertEq(_reserveFactor(AaveV2AvalancheAssets.USDTe_UNDERLYING), proposal.USDTe_RF());
    assertEq(_reserveFactor(AaveV2AvalancheAssets.WETHe_UNDERLYING), proposal.WETHe_RF());
    assertEq(_reserveFactor(AaveV2AvalancheAssets.WAVAX_UNDERLYING), proposal.WAVAX_RF());
    assertEq(_reserveFactor(AaveV2AvalancheAssets.AAVEe_UNDERLYING), proposal.AAVEe_RF());
  }

  function _reserveFactor(address asset) internal view returns (uint256 reserveFactor) {
    (, , , , reserveFactor, , , , , ) = AaveV2Avalanche
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(asset);
  }
}
