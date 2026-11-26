// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum, AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV2TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV2TestBase.sol';
import {AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111} from './AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol';

/**
 * @dev Test for AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol -vv
 */
contract AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111_Test is
  ProtocolV2TestBase
{
  AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26393644);
    proposal = new AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    (ReserveConfig[] memory allConfigsBefore, ReserveConfig[] memory allConfigsAfter) = defaultTest(
      'AaveV2Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111',
      AaveV2Ethereum.POOL,
      address(proposal)
    );

    address[] memory assetsChanged = new address[](5);
    assetsChanged[0] = AaveV2EthereumAssets.USDC_UNDERLYING;
    assetsChanged[1] = AaveV2EthereumAssets.DAI_UNDERLYING;
    assetsChanged[2] = AaveV2EthereumAssets.WETH_UNDERLYING;
    assetsChanged[3] = AaveV2EthereumAssets.USDT_UNDERLYING;
    assetsChanged[4] = AaveV2EthereumAssets.WBTC_UNDERLYING;

    uint256[] memory reserveFactors = new uint256[](5);
    reserveFactors[0] = proposal.USDC_RF();
    reserveFactors[1] = proposal.DAI_RF();
    reserveFactors[2] = proposal.WETH_RF();
    reserveFactors[3] = proposal.USDT_RF();
    reserveFactors[4] = proposal.WBTC_RF();

    _noReservesConfigsChangesApartFrom(allConfigsBefore, allConfigsAfter, assetsChanged);

    for (uint256 i = 0; i < assetsChanged.length; i++) {
      ReserveConfig memory expected = _findReserveConfig(allConfigsBefore, assetsChanged[i]);
      expected.reserveFactor = reserveFactors[i];
      _requireNoChangeInConfigs(expected, _findReserveConfig(allConfigsAfter, assetsChanged[i]));
    }
  }

  function test_reserveFactorUpdates() public {
    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(_reserveFactor(AaveV2EthereumAssets.USDC_UNDERLYING), proposal.USDC_RF());
    assertEq(_reserveFactor(AaveV2EthereumAssets.DAI_UNDERLYING), proposal.DAI_RF());
    assertEq(_reserveFactor(AaveV2EthereumAssets.WETH_UNDERLYING), proposal.WETH_RF());
    assertEq(_reserveFactor(AaveV2EthereumAssets.USDT_UNDERLYING), proposal.USDT_RF());
    assertEq(_reserveFactor(AaveV2EthereumAssets.WBTC_UNDERLYING), proposal.WBTC_RF());
  }

  function _reserveFactor(address asset) internal view returns (uint256 reserveFactor) {
    (, , , , reserveFactor, , , , , ) = AaveV2Ethereum
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(asset);
  }
}
