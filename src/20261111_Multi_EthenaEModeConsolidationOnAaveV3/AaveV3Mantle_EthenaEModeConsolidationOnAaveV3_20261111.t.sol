// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Mantle, AaveV3MantleEModes} from 'aave-address-book/AaveV3Mantle.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111} from './AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111.sol';

/**
 * @dev Test for AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_EthenaEModeConsolidationOnAaveV3/AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111.t.sol -vv
 */
contract AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111_Test is ProtocolV3TestBase {
  AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mantle'), 103149891);
    proposal = new AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Mantle_EthenaEModeConsolidationOnAaveV3_20261111',
      AaveV3Mantle.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Mantle.POOL, address(proposal), updatedAssets);
  }

  function test_eModeUpdatesConfiguration() public {
    DataTypes.CollateralConfig memory before_0 = AaveV3Mantle.POOL.getEModeCategoryCollateralConfig(
      AaveV3MantleEModes.USDe__USDT0_USDC_GHO
    );
    bool beforeIsolated_0 = AaveV3Mantle.POOL.getIsEModeCategoryIsolated(
      AaveV3MantleEModes.USDe__USDT0_USDC_GHO
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    DataTypes.CollateralConfig memory cfg_0 = AaveV3Mantle.POOL.getEModeCategoryCollateralConfig(
      AaveV3MantleEModes.USDe__USDT0_USDC_GHO
    );
    assertEq(cfg_0.ltv, 91_00);
    assertEq(cfg_0.liquidationThreshold, 93_00);
    assertEq(cfg_0.liquidationBonus, before_0.liquidationBonus);
    assertEq(
      AaveV3Mantle.POOL.getIsEModeCategoryIsolated(AaveV3MantleEModes.USDe__USDT0_USDC_GHO),
      beforeIsolated_0
    );
  }
}
