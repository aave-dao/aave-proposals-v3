// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826} from './AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826.sol';

/**
 * @dev Test for AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260826_Multi_LowAdoptionAssetDeprecationOnAaveV3/AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826.t.sol -vv
 */
contract AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826_Test is ProtocolV3TestBase {
  AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25837412);
    proposal = new AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_LowAdoptionAssetDeprecationOnAaveV3_20260826',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev validates the current-state assumptions of the specification: reserves expected to
   * be (un)frozen are, and caps kept unchanged by the payload are already at their claimed
   * values
   */
  function test_preExecutionReserveState() public {
    ReserveConfig[] memory allConfigs = _getReservesConfigs(AaveV3Ethereum.POOL);
    ReserveConfig memory config;
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.FBTC_UNDERLYING);
    assertFalse(config.isFrozen, 'FBTC_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'FBTC_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.ezETH_UNDERLYING);
    assertFalse(config.isFrozen, 'ezETH_ALREADY_FROZEN');
    assertEq(config.borrowCap, 0, 'ezETH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.eUSDe_UNDERLYING);
    assertFalse(config.isFrozen, 'eUSDe_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'eUSDe_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'eUSDe_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.ETHx_UNDERLYING);
    assertFalse(config.isFrozen, 'ETHx_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'ETHx_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'ETHx_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.CRV_UNDERLYING);
    assertFalse(config.isFrozen, 'CRV_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'CRV_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.UNI_UNDERLYING);
    assertFalse(config.isFrozen, 'UNI_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'UNI_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.ONE_INCH_UNDERLYING);
    assertFalse(config.isFrozen, 'ONE_INCH_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'ONE_INCH_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.crvUSD_UNDERLYING);
    assertFalse(config.isFrozen, 'crvUSD_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'crvUSD_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'crvUSD_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.ENS_UNDERLYING);
    assertFalse(config.isFrozen, 'ENS_ALREADY_FROZEN');
    assertEq(config.borrowCap, 1, 'ENS_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.SNX_UNDERLYING);
    assertFalse(config.isFrozen, 'SNX_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'SNX_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'SNX_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.sDAI_UNDERLYING);
    assertFalse(config.isFrozen, 'sDAI_ALREADY_FROZEN');
    assertEq(config.supplyCap, 1, 'sDAI_SUPPLY_CAP');
    assertEq(config.borrowCap, 0, 'sDAI_BORROW_CAP');
    config = _findReserveConfig(allConfigs, AaveV3EthereumAssets.MKR_UNDERLYING);
    assertTrue(config.isFrozen, 'MKR_NOT_FROZEN');
    assertEq(config.supplyCap, 1, 'MKR_SUPPLY_CAP');
    assertEq(config.borrowCap, 1, 'MKR_BORROW_CAP');
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](12);
    updatedAssets[0] = AaveV3EthereumAssets.FBTC_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.ezETH_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.eUSDe_UNDERLYING;
    updatedAssets[3] = AaveV3EthereumAssets.ETHx_UNDERLYING;
    updatedAssets[4] = AaveV3EthereumAssets.CRV_UNDERLYING;
    updatedAssets[5] = AaveV3EthereumAssets.UNI_UNDERLYING;
    updatedAssets[6] = AaveV3EthereumAssets.ONE_INCH_UNDERLYING;
    updatedAssets[7] = AaveV3EthereumAssets.crvUSD_UNDERLYING;
    updatedAssets[8] = AaveV3EthereumAssets.ENS_UNDERLYING;
    updatedAssets[9] = AaveV3EthereumAssets.SNX_UNDERLYING;
    updatedAssets[10] = AaveV3EthereumAssets.sDAI_UNDERLYING;
    updatedAssets[11] = AaveV3EthereumAssets.MKR_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](11);
    frozen = new bool[](11);

    assets[0] = AaveV3EthereumAssets.FBTC_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3EthereumAssets.ezETH_UNDERLYING;
    frozen[1] = true;
    assets[2] = AaveV3EthereumAssets.eUSDe_UNDERLYING;
    frozen[2] = true;
    assets[3] = AaveV3EthereumAssets.ETHx_UNDERLYING;
    frozen[3] = true;
    assets[4] = AaveV3EthereumAssets.CRV_UNDERLYING;
    frozen[4] = true;
    assets[5] = AaveV3EthereumAssets.UNI_UNDERLYING;
    frozen[5] = true;
    assets[6] = AaveV3EthereumAssets.ONE_INCH_UNDERLYING;
    frozen[6] = true;
    assets[7] = AaveV3EthereumAssets.crvUSD_UNDERLYING;
    frozen[7] = true;
    assets[8] = AaveV3EthereumAssets.ENS_UNDERLYING;
    frozen[8] = true;
    assets[9] = AaveV3EthereumAssets.SNX_UNDERLYING;
    frozen[9] = true;
    assets[10] = AaveV3EthereumAssets.sDAI_UNDERLYING;
    frozen[10] = true;
  }

  /**
   * @dev on v3.7 freezing a reserve also sets its LTV to 0 (the previous LTV is parked in
   * pendingLtv), which the generic freeze modeling of the test base does not cover; FBTC is
   * the only reserve in this payload's scope with a non-zero LTV
   */
  function _expectedCollateralChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CollateralUpdate[] memory)
  {
    IAaveV3ConfigEngine.CollateralUpdate[]
      memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](1);

    collateralUpdate[0] = IAaveV3ConfigEngine.CollateralUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      ltv: 0,
      liqThreshold: EngineFlags.KEEP_CURRENT,
      liqBonus: EngineFlags.KEEP_CURRENT,
      liqProtocolFee: EngineFlags.KEEP_CURRENT
    });
    return collateralUpdate;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory)
  {
    IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate;
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](7);

    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[1] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.ezETH_UNDERLYING,
      supplyCap: 1,
      borrowCap: 1
    });
    capsUpdate[2] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.CRV_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[3] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.UNI_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[4] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.ONE_INCH_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[5] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.ENS_UNDERLYING,
      supplyCap: 1,
      borrowCap: EngineFlags.KEEP_CURRENT
    });
    capsUpdate[6] = IAaveV3ConfigEngine.CapsUpdate({
      asset: AaveV3EthereumAssets.sDAI_UNDERLYING,
      supplyCap: EngineFlags.KEEP_CURRENT,
      borrowCap: 1
    });
    return capsUpdate;
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](9);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 75_00
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.ETHx_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.CRV_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.UNI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.ONE_INCH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.crvUSD_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.MKR_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[7] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.ENS_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 50_00
    });
    borrowUpdates[8] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.SNX_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: 99_00
    });
    return borrowUpdates;
  }
}
