// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Base, AaveV3BaseAssets, AaveV3BaseEModes} from 'aave-address-book/AaveV3Base.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Base_RiskParamsRecordCISample_20261113} from './AaveV3Base_RiskParamsRecordCISample_20261113.sol';

/**
 * @dev Test for AaveV3Base_RiskParamsRecordCISample_20261113
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261113_Multi_RiskParamsRecordCISample/AaveV3Base_RiskParamsRecordCISample_20261113.t.sol -vv
 */
contract AaveV3Base_RiskParamsRecordCISample_20261113_Test is ProtocolV3TestBase {
  AaveV3Base_RiskParamsRecordCISample_20261113 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 56833184);
    proposal = new AaveV3Base_RiskParamsRecordCISample_20261113();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV3Base_RiskParamsRecordCISample_20261113', AaveV3Base.POOL, address(proposal));
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](2);
    updatedAssets[0] = AaveV3BaseAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3BaseAssets.cbBTC_UNDERLYING;
    reserveConfigChangesTest(AaveV3Base.POOL, address(proposal), updatedAssets);
  }

  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[] memory collateralUpdate;
    collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](2);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.WETH_UNDERLYING,
      ltv: 82_00,
      liqThreshold: 85_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3BaseAssets.cbBTC_UNDERLYING,
      ltv: 82_00,
      liqThreshold: 85_00,
      liqBonus: 6_50,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }

  function test_eModeUpdatesConfiguration() public {
    DataTypes.CollateralConfig memory before_0 = AaveV3Base.POOL.getEModeCategoryCollateralConfig(
      AaveV3BaseEModes.cbBTC__USDC_GHO
    );
    bool beforeIsolated_0 = AaveV3Base.POOL.getIsEModeCategoryIsolated(
      AaveV3BaseEModes.cbBTC__USDC_GHO
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    DataTypes.CollateralConfig memory cfg_0 = AaveV3Base.POOL.getEModeCategoryCollateralConfig(
      AaveV3BaseEModes.cbBTC__USDC_GHO
    );
    assertEq(cfg_0.ltv, 83_00);
    assertEq(cfg_0.liquidationThreshold, 86_00);
    assertEq(cfg_0.liquidationBonus, before_0.liquidationBonus);
    assertEq(
      AaveV3Base.POOL.getIsEModeCategoryIsolated(AaveV3BaseEModes.cbBTC__USDC_GHO),
      beforeIsolated_0
    );
  }
}
