// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016} from './AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016.sol';

/**
 * @dev Test for AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016.t.sol -vv
 */
contract AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 515357810);
    proposal = new AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_ETHAndBTCCollateralEfficiency_20261016',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations stay unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](2);
    updatedAssets[0] = AaveV3ArbitrumAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3ArbitrumAssets.WBTC_UNDERLYING;
    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function test_preProposalCollateralConfig() public view {
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Arbitrum.POOL);
    ReserveConfig memory WETHConfig = _findReserveConfig(
      configs,
      AaveV3ArbitrumAssets.WETH_UNDERLYING
    );
    assertEq(WETHConfig.ltv, 80_00);
    assertEq(WETHConfig.liquidationThreshold, 84_00);
    assertEq(WETHConfig.liquidationBonus, 105_00);
    assertEq(WETHConfig.liquidationProtocolFee, 10_00);
    ReserveConfig memory WBTCConfig = _findReserveConfig(
      configs,
      AaveV3ArbitrumAssets.WBTC_UNDERLYING
    );
    assertEq(WBTCConfig.ltv, 73_00);
    assertEq(WBTCConfig.liquidationThreshold, 78_00);
    assertEq(WBTCConfig.liquidationBonus, 107_00);
    assertEq(WBTCConfig.liquidationProtocolFee, 10_00);
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
      asset: AaveV3ArbitrumAssets.WETH_UNDERLYING,
      ltv: 81_00,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3ArbitrumAssets.WBTC_UNDERLYING,
      ltv: 78_00,
      liqThreshold: 82_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }
}
