// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016} from './AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016.sol';

/**
 * @dev Test for AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261016_AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH/AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016.t.sol -vv
 */
contract AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016_Test is
  ProtocolV3TestBase
{
  AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26204670);
    proposal = new AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_LiquidationProtocolFeeIncreaseWBTCWETHWstETH_20261016',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumption of the specification: the liquidation
   * protocol fee of WBTC, WETH and wstETH is 10% before execution
   */
  function test_preExecutionReserveState() public view {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Ethereum.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.WBTC_UNDERLYING);
    assertEq(config.liquidationProtocolFee, 10_00, 'WBTC_LIQ_PROTOCOL_FEE');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.WETH_UNDERLYING);
    assertEq(config.liquidationProtocolFee, 10_00, 'WETH_LIQ_PROTOCOL_FEE');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.wstETH_UNDERLYING);
    assertEq(config.liquidationProtocolFee, 10_00, 'wstETH_LIQ_PROTOCOL_FEE');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](3);
    updatedAssets[0] = AaveV3EthereumAssets.WBTC_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.WETH_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.wstETH_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[] memory collateralUpdate;
    collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](3);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.WBTC_UNDERLYING,
      ltv: EngineFlags.KEEP_CURRENT,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: 20_00
    });
    collateralUpdate[1] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.WETH_UNDERLYING,
      ltv: EngineFlags.KEEP_CURRENT,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: 20_00
    });
    collateralUpdate[2] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.wstETH_UNDERLYING,
      ltv: EngineFlags.KEEP_CURRENT,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: 20_00
    });
    return collateralUpdate;
  }
}
