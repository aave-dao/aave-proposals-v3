// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_RiskParamsRecordCISample_20261113} from './AaveV3Arbitrum_RiskParamsRecordCISample_20261113.sol';

/**
 * @dev Test for AaveV3Arbitrum_RiskParamsRecordCISample_20261113
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261113_Multi_RiskParamsRecordCISample/AaveV3Arbitrum_RiskParamsRecordCISample_20261113.t.sol -vv
 */
contract AaveV3Arbitrum_RiskParamsRecordCISample_20261113_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_RiskParamsRecordCISample_20261113 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 523807251);
    proposal = new AaveV3Arbitrum_RiskParamsRecordCISample_20261113();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_RiskParamsRecordCISample_20261113',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](1);
    updatedAssets[0] = AaveV3ArbitrumAssets.WBTC_UNDERLYING;
    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[] memory collateralUpdate;
    collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](1);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3ArbitrumAssets.WBTC_UNDERLYING,
      ltv: 79_00,
      liqThreshold: 83_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }
}
