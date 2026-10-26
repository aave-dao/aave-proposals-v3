// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4EthereumSpokes, AaveV4EthereumHubs, AaveV4EthereumAssets} from 'aave-address-book/AaveV4Ethereum.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';

import 'forge-std/Test.sol';
import {stdStorage, StdStorage} from 'forge-std/StdStorage.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016} from './AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016.sol';

/**
 * @dev Test for AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261016_Multi_ETHAndBTCCollateralEfficiency/AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016.t.sol -vv
 */
contract AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016_Test is ProtocolV4TestBaseEthereum {
  using stdStorage for StdStorage;

  uint32 internal constant LEGACY_CONFIG_KEY = 0;
  uint32 internal constant DISABLED_CONFIG_KEY = 1;
  uint32 internal constant LATEST_CONFIG_KEY = 2;

  AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016 internal proposal;
  StdStorage private legacyPositionStorage;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26204733);
    proposal = new AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Ethereum_ETHAndBTCCollateralEfficiency_20261016', address(proposal));
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_WETH_0() public {
    uint32 dynamicConfigKey = 0;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.WETH_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(84_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_WBTC_0() public {
    uint32 dynamicConfigKey = 0;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.WBTC_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(85_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_cbBTC_0() public {
    uint32 dynamicConfigKey = 0;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.cbBTC_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(85_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_wstETH_0() public {
    uint32 dynamicConfigKey = 0;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.wstETH_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(82_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_weETH_0() public {
    uint32 dynamicConfigKey = 0;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.weETH_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(81_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_wstETH_2() public {
    uint32 dynamicConfigKey = 2;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.wstETH_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(82_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_spokeDynamicReserveConfigUpdate_MAIN_SPOKE_weETH_2() public {
    uint32 dynamicConfigKey = 2;
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.weETH_UNDERLYING);
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.DynamicReserveConfig memory beforeDyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(81_00), 'collateralFactor mismatch');
    assertEq(
      uint256(dyn.maxLiquidationBonus),
      uint256(beforeDyn.maxLiquidationBonus),
      'maxLiquidationBonus unchanged'
    );
    assertEq(
      uint256(dyn.liquidationFee),
      uint256(beforeDyn.liquidationFee),
      'liquidationFee unchanged'
    );
  }

  function test_preProposalDynamicConfigs() public view {
    ISpoke spoke = AaveV4EthereumSpokes.MAIN_SPOKE;
    IHub hub = AaveV4EthereumHubs.CORE_HUB;
    address[5] memory assets = [
      AaveV4EthereumAssets.WETH_UNDERLYING,
      AaveV4EthereumAssets.wstETH_UNDERLYING,
      AaveV4EthereumAssets.weETH_UNDERLYING,
      AaveV4EthereumAssets.WBTC_UNDERLYING,
      AaveV4EthereumAssets.cbBTC_UNDERLYING
    ];
    uint16[5] memory factors = [uint16(83_00), 80_00, 80_00, 78_00, 78_00];
    uint32[5] memory keys = [
      LEGACY_CONFIG_KEY,
      LATEST_CONFIG_KEY,
      LATEST_CONFIG_KEY,
      LEGACY_CONFIG_KEY,
      LEGACY_CONFIG_KEY
    ];
    uint32[5] memory bonuses = [uint32(105_55), 106_66, 107_77, 105_55, 105_55];
    for (uint256 i; i < assets.length; ++i) {
      uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(assets[i]));
      assertEq(spoke.getReserve(reserveId).dynamicConfigKey, keys[i]);
      ISpoke.DynamicReserveConfig memory config = spoke.getDynamicReserveConfig(reserveId, keys[i]);
      assertEq(config.collateralFactor, factors[i]);
      assertEq(config.maxLiquidationBonus, bonuses[i]);
      assertEq(config.liquidationFee, 10_00);
      if (keys[i] == 2) {
        assertEq(
          abi.encode(spoke.getDynamicReserveConfig(reserveId, LEGACY_CONFIG_KEY)),
          abi.encode(config)
        );
        assertEq(spoke.getDynamicReserveConfig(reserveId, DISABLED_CONFIG_KEY).collateralFactor, 0);
      }
    }
  }

  function test_dynamicConfigsUpdatedInPlace() public {
    ISpoke spoke = AaveV4EthereumSpokes.MAIN_SPOKE;
    uint256 count = spoke.getReserveCount();
    bytes32[] memory reservesBefore = new bytes32[](count);
    bytes32[][] memory expectedConfigs = new bytes32[][](count);
    bytes32 liquidationBefore = keccak256(abi.encode(spoke.getLiquidationConfig()));
    for (uint256 i; i < count; ++i) {
      ISpoke.Reserve memory reserve = spoke.getReserve(i);
      reservesBefore[i] = keccak256(abi.encode(reserve, spoke.getReserveConfig(i)));
      expectedConfigs[i] = new bytes32[](uint256(reserve.dynamicConfigKey) + 1);
      for (uint32 key; key <= reserve.dynamicConfigKey; ++key) {
        ISpoke.DynamicReserveConfig memory config = spoke.getDynamicReserveConfig(i, key);
        uint16 factor = _expectedCollateralFactor(reserve.underlying);
        if ((key == LEGACY_CONFIG_KEY || key == reserve.dynamicConfigKey) && factor != 0) {
          config.collateralFactor = factor;
        }
        expectedConfigs[i][key] = keccak256(abi.encode(config));
      }
    }
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(spoke.getReserveCount(), count);
    assertEq(keccak256(abi.encode(spoke.getLiquidationConfig())), liquidationBefore);
    for (uint256 i; i < count; ++i) {
      ISpoke.Reserve memory reserve = spoke.getReserve(i);
      assertEq(keccak256(abi.encode(reserve, spoke.getReserveConfig(i))), reservesBefore[i]);
      for (uint32 key; key <= reserve.dynamicConfigKey; ++key) {
        assertEq(
          keccak256(abi.encode(spoke.getDynamicReserveConfig(i, key))),
          expectedConfigs[i][key]
        );
      }
    }
  }

  function test_existingPositionUsesUpdatedLegacyConfig_wstETH() public {
    _testExistingPositionUsesUpdatedLegacyConfig(AaveV4EthereumAssets.wstETH_UNDERLYING, 82_00);
  }

  function test_existingPositionUsesUpdatedLegacyConfig_weETH() public {
    _testExistingPositionUsesUpdatedLegacyConfig(AaveV4EthereumAssets.weETH_UNDERLYING, 81_00);
  }

  function _testExistingPositionUsesUpdatedLegacyConfig(
    address underlying,
    uint16 expectedFactor
  ) internal {
    ISpoke spoke = AaveV4EthereumSpokes.MAIN_SPOKE;
    IHub hub = AaveV4EthereumHubs.CORE_HUB;
    uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(underlying));
    uint256 debtReserveId = spoke.getReserveId(
      address(hub),
      hub.getAssetId(AaveV4EthereumAssets.WETH_UNDERLYING)
    );
    address user = makeAddr('legacy borrower');
    uint256 supplied = 10e18;
    uint256 collateralValueInWeth = (supplied *
      AaveV4EthereumSpokes.MAIN_SPOKE_ORACLE.getReservePrice(reserveId)) /
      AaveV4EthereumSpokes.MAIN_SPOKE_ORACLE.getReservePrice(debtReserveId);
    uint256 initialBorrow = (collateralValueInWeth * 79_00) / 100_00;
    uint256 additionalBorrow = (collateralValueInWeth * (expectedFactor - 50)) /
      100_00 -
      initialBorrow;
    deal2(underlying, user, supplied);
    vm.startPrank(user);
    IERC20Metadata(underlying).approve(address(spoke), supplied);
    spoke.supply(reserveId, supplied, user);
    spoke.setUsingAsCollateral(reserveId, true, user);
    spoke.borrow(debtReserveId, initialBorrow, user);
    vm.stopPrank();

    assertEq(spoke.getReserve(reserveId).dynamicConfigKey, LATEST_CONFIG_KEY);
    assertEq(
      abi.encode(spoke.getDynamicReserveConfig(reserveId, LEGACY_CONFIG_KEY)),
      abi.encode(spoke.getDynamicReserveConfig(reserveId, LATEST_CONFIG_KEY))
    );
    ISpoke.UserPosition memory beforePosition = spoke.getUserPosition(reserveId, user);
    _restoreLegacyConfigKey(spoke, reserveId, user);
    beforePosition.dynamicConfigKey = LEGACY_CONFIG_KEY;
    assertEq(abi.encode(spoke.getUserPosition(reserveId, user)), abi.encode(beforePosition));
    uint256 healthFactorBefore = spoke.getUserAccountData(user).healthFactor;
    vm.prank(user);
    vm.expectRevert(ISpoke.HealthFactorBelowThreshold.selector);
    spoke.borrow(debtReserveId, additionalBorrow, user);

    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(spoke.getUserPosition(reserveId, user).dynamicConfigKey, LEGACY_CONFIG_KEY);
    assertGt(spoke.getUserAccountData(user).healthFactor, healthFactorBefore);
    assertEq(abi.encode(spoke.getUserPosition(reserveId, user)), abi.encode(beforePosition));
    assertEq(spoke.getUserAccountData(user).avgCollateralFactor, uint256(expectedFactor) * 1e14);
    assertEq(
      spoke.getDynamicReserveConfig(reserveId, LEGACY_CONFIG_KEY).collateralFactor,
      expectedFactor
    );
    assertEq(spoke.getDynamicReserveConfig(reserveId, DISABLED_CONFIG_KEY).collateralFactor, 0);
    assertEq(
      spoke.getDynamicReserveConfig(reserveId, LATEST_CONFIG_KEY).collateralFactor,
      expectedFactor
    );

    vm.prank(user);
    spoke.borrow(debtReserveId, additionalBorrow, user);
    assertEq(spoke.getUserPosition(reserveId, user).dynamicConfigKey, LATEST_CONFIG_KEY);
    assertEq(spoke.getUserPosition(reserveId, user).suppliedShares, beforePosition.suppliedShares);
    assertEq(spoke.getUserAccountData(user).avgCollateralFactor, uint256(expectedFactor) * 1e14);
    assertGe(spoke.getUserAccountData(user).healthFactor, 1e18);
    assertEq(
      IERC20Metadata(AaveV4EthereumAssets.WETH_UNDERLYING).balanceOf(user),
      initialBorrow + additionalBorrow
    );
  }

  function _restoreLegacyConfigKey(ISpoke spoke, uint256 reserveId, address user) internal {
    // Recreate the legacy snapshot without changing balances or debt.
    legacyPositionStorage
      .target(address(spoke))
      .sig(ISpoke.getUserPosition.selector)
      .with_key(reserveId)
      .with_key(user)
      .depth(4)
      .enable_packed_slots()
      .checked_write(uint256(LEGACY_CONFIG_KEY));
  }

  function _expectedCollateralFactor(address underlying) internal pure returns (uint16) {
    if (underlying == AaveV4EthereumAssets.WETH_UNDERLYING) return 84_00;
    if (underlying == AaveV4EthereumAssets.wstETH_UNDERLYING) return 82_00;
    if (underlying == AaveV4EthereumAssets.weETH_UNDERLYING) return 81_00;
    if (
      underlying == AaveV4EthereumAssets.WBTC_UNDERLYING ||
      underlying == AaveV4EthereumAssets.cbBTC_UNDERLYING
    ) return 85_00;
    return 0;
  }
}
