// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016} from './AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016.sol';

/**
 * @dev Test for AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016.t.sol -vv
 */
contract AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016_Test is ProtocolV3TestBase {
  AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26204733);
    proposal = new AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_ETHAndBTCCollateralEfficiency_20261016',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](5);
    updatedAssets[0] = AaveV3EthereumAssets.WETH_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.WBTC_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.cbBTC_UNDERLYING;
    updatedAssets[3] = AaveV3EthereumAssets.wstETH_UNDERLYING;
    updatedAssets[4] = AaveV3EthereumAssets.weETH_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[] memory collateralUpdate;
    collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](5);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.WETH_UNDERLYING,
      ltv: 81_00,
      liqThreshold: 84_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.WBTC_UNDERLYING,
      ltv: 81_00,
      liqThreshold: 85_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[2] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.cbBTC_UNDERLYING,
      ltv: 81_00,
      liqThreshold: 85_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[3] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.wstETH_UNDERLYING,
      ltv: 79_00,
      liqThreshold: 82_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    collateralUpdate[4] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.weETH_UNDERLYING,
      ltv: 78_00,
      liqThreshold: 81_00,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }

  function test_preProposalCollateralConfig() public view {
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Ethereum.POOL);
    ReserveConfig memory WETHConfig = _findReserveConfig(
      configs,
      AaveV3EthereumAssets.WETH_UNDERLYING
    );
    assertEq(WETHConfig.ltv, 8050);
    assertEq(WETHConfig.liquidationThreshold, 8300);
    assertEq(WETHConfig.liquidationBonus, 10500);
    assertEq(WETHConfig.liquidationProtocolFee, 1000);
    ReserveConfig memory WBTCConfig = _findReserveConfig(
      configs,
      AaveV3EthereumAssets.WBTC_UNDERLYING
    );
    assertEq(WBTCConfig.ltv, 7300);
    assertEq(WBTCConfig.liquidationThreshold, 7800);
    assertEq(WBTCConfig.liquidationBonus, 10500);
    assertEq(WBTCConfig.liquidationProtocolFee, 1000);
    ReserveConfig memory cbBTCConfig = _findReserveConfig(
      configs,
      AaveV3EthereumAssets.cbBTC_UNDERLYING
    );
    assertEq(cbBTCConfig.ltv, 7300);
    assertEq(cbBTCConfig.liquidationThreshold, 7800);
    assertEq(cbBTCConfig.liquidationBonus, 10750);
    assertEq(cbBTCConfig.liquidationProtocolFee, 1000);
    ReserveConfig memory wstETHConfig = _findReserveConfig(
      configs,
      AaveV3EthereumAssets.wstETH_UNDERLYING
    );
    assertEq(wstETHConfig.ltv, 7850);
    assertEq(wstETHConfig.liquidationThreshold, 8100);
    assertEq(wstETHConfig.liquidationBonus, 10600);
    assertEq(wstETHConfig.liquidationProtocolFee, 1000);
    ReserveConfig memory weETHConfig = _findReserveConfig(
      configs,
      AaveV3EthereumAssets.weETH_UNDERLYING
    );
    assertEq(weETHConfig.ltv, 7750);
    assertEq(weETHConfig.liquidationThreshold, 8000);
    assertEq(weETHConfig.liquidationBonus, 10700);
    assertEq(weETHConfig.liquidationProtocolFee, 1000);
  }
}
