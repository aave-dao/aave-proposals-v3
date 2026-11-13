// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {ITokenizationSpoke} from 'aave-v4/spoke/interfaces/ITokenizationSpoke.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {IAccessManaged} from 'aave-v4/dependencies/openzeppelin/IAccessManaged.sol';
import {IAccessManager} from 'aave-v4/dependencies/openzeppelin/IAccessManager.sol';
import {IAccessManagerEnumerable} from 'aave-v4/access/interfaces/IAccessManagerEnumerable.sol';
import {IHubConfigurator} from 'aave-v4/hub/interfaces/IHubConfigurator.sol';
import {ISpokeConfigurator} from 'aave-v4/spoke/interfaces/ISpokeConfigurator.sol';
import {IAaveV4ConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IBTCVaultSwap} from './IBTCVaultSwap.sol';
import {AaveV4EthereumGetters} from 'aave-address-book/AaveV4Ethereum.sol';
import {AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119} from './AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119.sol';
import {BabylonTestBase, IVaultBTC, IAaveAdapter, IBTCVaultSwapView, IBabylonSpoke, IOwnable, ISafe} from './BabylonTestBase.sol';

interface IV4RiskSteward {
  function updateHubSpokeCaps(IAaveV4ConfigEngine.SpokeConfigUpdate[] calldata updates) external;
}

/**
 * @dev Test for AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261119_AaveV4Ethereum_OnboardNativeBTCViaBabylon/AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119.t.sol -vv
 */
contract AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119_Test is BabylonTestBase {
  struct SpokeAddition {
    address hub;
    uint256 assetId;
    address spoke;
    uint40 addCap;
    uint40 drawCap;
  }

  struct ExpectedReserve {
    address hub;
    uint256 assetId;
    address underlying;
    address priceSource;
    bool borrowable;
    uint16 collateralFactor;
    uint32 maxLiquidationBonus;
  }

  // snapshots taken before the payload runs
  mapping(address hub => uint256) internal _assetCountBefore;
  mapping(address hub => mapping(uint256 assetId => uint256)) internal _spokeCountBefore;
  mapping(address hub => mapping(uint256 assetId => bytes32)) internal _spokesBefore;
  mapping(address hub => mapping(uint256 assetId => bytes32)) internal _assetConfigBefore;
  uint64[] internal _rolesBefore;
  mapping(uint64 role => bytes32) internal _roleBefore;
  mapping(uint64 role => address[]) internal _roleTargetsBefore;
  mapping(uint64 role => mapping(address target => bytes32)) internal _roleSelectorsBefore;
  mapping(address spoke => bytes32) internal _spokeStateBefore;

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest({
      reportName: 'AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119',
      spokes: _getSpokes(),
      tokenizationSpokes: _getTokenizationSpokes(),
      payload: address(proposal),
      runE2E: false,
      testPositionManagers: false
    });
    // the generic e2e supplies and liquidates directly, which the BabylonSpoke only allows through
    // the AaveAdapter, so it runs on every other spoke and BabylonLiquidationFlows covers this one
    vm.pauseGasMetering();
    e2eTestAllSpokes({spokes: AaveV4EthereumGetters.getAllSpokes(), testPositionManagers: false});
    e2eTestAllTokenizationSpokes(_getTokenizationSpokes());
    vm.resumeGasMetering();
  }

  // ─── state the payload relies on ───

  function test_preState_handover() public view {
    address[2] memory proxies = [BABYLON_HUB, BABYLON_SPOKE];
    address[2] memory proxyAdmins = [BABYLON_HUB_PROXY_ADMIN, BABYLON_SPOKE_PROXY_ADMIN];
    address[2] memory implementations = [BABYLON_HUB_IMPLEMENTATION, BABYLON_SPOKE_IMPLEMENTATION];
    for (uint256 i; i < proxies.length; ++i) {
      assertEq(IAccessManaged(proxies[i]).authority(), ACCESS_MANAGER, 'authority');
      assertEq(_proxyAdmin(proxies[i]), proxyAdmins[i], 'proxy admin');
      assertEq(IOwnable(proxyAdmins[i]).owner(), V4_SECURITY_COUNCIL, 'proxy admin owner');
      assertEq(_implementation(proxies[i]), implementations[i], 'implementation');
    }
    address[4] memory tokenizationSpokes = _babylonTokenizationSpokes();
    for (uint256 i; i < tokenizationSpokes.length; ++i) {
      assertEq(
        IOwnable(_proxyAdmin(tokenizationSpokes[i])).owner(),
        V4_SECURITY_COUNCIL,
        'tokenization spoke proxy admin owner'
      );
    }

    IAccessManagerEnumerable deployment = IAccessManagerEnumerable(DEPLOYMENT_ACCESS_MANAGER);
    uint256 roleCount = deployment.getRoleCount();
    for (uint256 i; i < roleCount; ++i) {
      assertEq(deployment.getRoleMemberCount(deployment.getRole(i)), 0, 'deployment role member');
    }
    address[3] memory accounts = [DEPLOYER, V4_SECURITY_COUNCIL, EXECUTOR_LVL_1];
    for (uint256 i; i < accounts.length; ++i) {
      (bool isAdmin, ) = deployment.hasRole(ADMIN_ROLE, accounts[i]);
      assertFalse(isAdmin, 'deployment access manager admin');
    }

    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);
    uint256 sharedRoleCount = accessManager.getRoleCount();
    for (uint256 i; i < sharedRoleCount; ++i) {
      (bool hasRole, ) = accessManager.hasRole(accessManager.getRole(i), DEPLOYER);
      assertFalse(hasRole, 'deployer role');
    }
    (bool deployerIsAdmin, ) = accessManager.hasRole(ADMIN_ROLE, DEPLOYER);
    assertFalse(deployerIsAdmin, 'deployer admin');
  }

  function test_preState_nothingConnected() public {
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);
    assertFalse(accessManager.isRole(BTC_VAULT_SWAP_FEE_ROLE), 'fee role exists');
    assertFalse(accessManager.isRole(BTC_VAULT_SWAP_GUARDIAN_ROLE), 'guardian role exists');
    assertFalse(accessManager.isRoleLabeled(BTC_VAULT_SWAP_FEE_ROLE), 'fee role labeled');
    assertFalse(accessManager.isRoleLabeled(BTC_VAULT_SWAP_GUARDIAN_ROLE), 'guardian role labeled');

    _assertSelectorRoles(BABYLON_HUB, _hubSelectors(), _repeat(ADMIN_ROLE, 7));
    _assertSelectorRoles(BABYLON_SPOKE, _spokeSelectors(), _repeat(ADMIN_ROLE, 9));
    _assertSelectorRoles(BTC_VAULT_SWAP, _btcVaultSwapSelectors(), _repeat(ADMIN_ROLE, 5));

    SpokeAddition[] memory additions = _expectedAdditions();
    for (uint256 i; i < additions.length; ++i) {
      assertFalse(
        IHub(additions[i].hub).isSpokeListed(additions[i].assetId, additions[i].spoke),
        'spoke listed before the proposal'
      );
    }
    // the fee receiver of each Babylon Hub asset is the only spoke listed
    for (uint256 assetId; assetId < 5; ++assetId) {
      assertEq(IHub(BABYLON_HUB).getSpokeCount(assetId), 1, 'babylon hub spoke count');
      assertEq(IHub(BABYLON_HUB).getSpokeAddress(assetId, 0), TREASURY_SPOKE, 'fee receiver');
    }

    _mintVaultBtc(user, 1e8);
    vm.startPrank(user);
    IERC20(VAULT_BTC).approve(BABYLON_SPOKE, 1e8);
    vm.expectRevert(IHub.SpokeNotActive.selector);
    ISpoke(BABYLON_SPOKE).supply(VAULT_BTC_RESERVE_ID, 1e8, user);
    vm.stopPrank();
  }

  /// @dev The market parameters the deployer set, which the proposal activates as they are.
  function test_preState_marketParameters() public view {
    ISpoke spoke = ISpoke(BABYLON_SPOKE);
    assertEq(spoke.ORACLE(), BABYLON_SPOKE_ORACLE, 'oracle');
    assertEq(IBabylonSpoke(BABYLON_SPOKE).LIQUIDATION_MANAGER(), AAVE_ADAPTER, 'manager');
    assertEq(IBabylonSpoke(BABYLON_SPOKE).MANAGED_COLLATERAL_RESERVE_ID(), 0, 'managed reserve');

    ISpoke.LiquidationConfig memory liquidationConfig = spoke.getLiquidationConfig();
    assertEq(liquidationConfig.targetHealthFactor, 1e18, 'target health factor');
    assertEq(liquidationConfig.healthFactorForMaxBonus, 0.9e18, 'health factor for max bonus');
    assertEq(liquidationConfig.liquidationBonusFactor, 90_00, 'liquidation bonus factor');

    ExpectedReserve[] memory expected = _expectedReserves();
    assertEq(spoke.getReserveCount(), RESERVE_COUNT, 'reserve count');
    for (uint256 i; i < expected.length; ++i) {
      _assertReserve(i, expected[i]);
    }

    // optimal usage, base rate, slope before and after optimal, liquidity fee, in BPS
    uint32[5][5] memory curves = [
      [uint32(99_00), 0, 0, 0, 0],
      [uint32(90_00), 0, 4_50, 20_00, 10_00],
      [uint32(90_00), 0, 4_50, 20_00, 10_00],
      [uint32(90_00), 0, 4_50, 20_00, 10_00],
      [uint32(80_00), 25, 4_00, 60_00, 20_00]
    ];
    address[5] memory underlyings = [VAULT_BTC, USDT, USDC, GHO, WBTC];
    IHub hub = IHub(BABYLON_HUB);
    assertEq(hub.getAssetCount(), 5, 'asset count');
    for (uint256 assetId; assetId < 5; ++assetId) {
      (address underlying, ) = hub.getAssetUnderlyingAndDecimals(assetId);
      assertEq(underlying, underlyings[assetId], 'underlying');
      IHub.AssetConfig memory assetConfig = hub.getAssetConfig(assetId);
      assertEq(assetConfig.feeReceiver, TREASURY_SPOKE, 'fee receiver');
      assertEq(assetConfig.liquidityFee, curves[assetId][4], 'liquidity fee');
      assertEq(assetConfig.irStrategy, BABYLON_HUB_IR_STRATEGY, 'ir strategy');
      assertEq(assetConfig.reinvestmentController, address(0), 'reinvestment controller');
      IAssetInterestRateStrategy.InterestRateData memory irData = IAssetInterestRateStrategy(
        BABYLON_HUB_IR_STRATEGY
      ).getInterestRateData(assetId);
      assertEq(irData.optimalUsageRatio, curves[assetId][0], 'optimal usage ratio');
      assertEq(irData.baseDrawnRate, curves[assetId][1], 'base drawn rate');
      assertEq(irData.rateGrowthBeforeOptimal, curves[assetId][2], 'rate growth before optimal');
      assertEq(irData.rateGrowthAfterOptimal, curves[assetId][3], 'rate growth after optimal');
    }
  }

  function test_preState_babylonContracts() public view {
    assertEq(IVaultBTC(VAULT_BTC).HUB(), BABYLON_HUB, 'vaultBTC hub');
    assertEq(IVaultBTC(VAULT_BTC).adapter(), AAVE_ADAPTER, 'vaultBTC adapter');
    assertEq(IERC20(VAULT_BTC).decimals(), 8, 'vaultBTC decimals');

    IAaveAdapter adapter = IAaveAdapter(AAVE_ADAPTER);
    assertEq(adapter.BTC_VAULT_CORE_SPOKE(), BABYLON_SPOKE, 'adapter spoke');
    assertEq(adapter.BTC_VAULT_HUB(), BABYLON_HUB, 'adapter hub');
    assertEq(adapter.VAULT_BTC_RESERVE_ID(), VAULT_BTC_RESERVE_ID, 'adapter collateral reserve');
    assertEq(adapter.EXIT_BTC_RESERVE_ID(), BABYLON_WBTC_RESERVE_ID, 'adapter exit reserve');
    // 10% of the liquidator's bonus profit, accepted by LlamaRisk
    assertEq(adapter.liquidationFeeBps(), 10_00, 'adapter liquidation fee');

    IBTCVaultSwapView btcVaultSwap = IBTCVaultSwapView(BTC_VAULT_SWAP);
    assertEq(btcVaultSwap.ADAPTER(), AAVE_ADAPTER, 'swap adapter');
    assertEq(btcVaultSwap.HUB(), CORE_HUB, 'swap hub');
    assertEq(btcVaultSwap.EXIT_BTC(), WBTC, 'swap exit token');
    assertEq(btcVaultSwap.EXIT_BTC_ASSET_ID(), CORE_WBTC_ASSET_ID, 'swap exit asset id');
    assertEq(btcVaultSwap.sellDiscountBps(), 2_00, 'sell discount');
    assertEq(btcVaultSwap.minimumProfitThresholdBps(), 50, 'minimum profit threshold');
    assertEq(IAccessManaged(BTC_VAULT_SWAP).authority(), ACCESS_MANAGER, 'swap authority');
    assertEq(_proxyAdmin(BTC_VAULT_SWAP), BTC_VAULT_SWAP_PROXY_ADMIN, 'swap proxy admin');
    assertEq(
      IOwnable(BTC_VAULT_SWAP_PROXY_ADMIN).owner(),
      V4_SECURITY_COUNCIL,
      'swap proxy admin owner'
    );
    // an upgrade of either Babylon contract before the fork block must be reviewed again
    assertEq(_implementation(AAVE_ADAPTER), AAVE_ADAPTER_IMPLEMENTATION, 'adapter implementation');
    assertEq(_implementation(BTC_VAULT_SWAP), BTC_VAULT_SWAP_IMPLEMENTATION, 'swap implementation');
  }

  /// @dev The Aave Labs, Babylon and LlamaRisk Safe that holds the fee role.
  function test_preState_btcVaultSwapMultisig() public view {
    ISafe safe = ISafe(BTC_VAULT_SWAP_MULTISIG);
    assertEq(safe.getThreshold(), 2, 'threshold');
    address[] memory owners = safe.getOwners();
    assertEq(owners.length, 3, 'owner count');
    assertEq(owners[0], 0x2B99790c35a401be873FA7Eb514D9220736BB1cA, 'owner');
    assertEq(owners[1], 0xb291232F480F41c75802C4a60F1D2AC03404Afef, 'owner');
    assertEq(owners[2], 0x4095d75b9eE5BF443d5680135C4106f9179b5B28, 'owner');
    (address[] memory modules, ) = safe.getModulesPaginated(address(1), 10);
    assertEq(modules.length, 0, 'modules');
    // keccak256("guard_manager.guard.address")
    assertEq(
      vm.load(
        BTC_VAULT_SWAP_MULTISIG,
        0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8
      ),
      bytes32(0),
      'guard'
    );
  }

  // ─── the payload refuses a half-finished handover ───

  function test_revertsWith_hubNotHandedOver() public {
    _partialHandover({hubAuthority: false, spokeAuthority: true, hubAdmin: true, spokeAdmin: true});
    vm.expectRevert('BABYLON_HUB_NOT_HANDED_OVER');
    proposal.execute();
    _expectGovernanceExecutionReverts();
  }

  function test_revertsWith_spokeNotHandedOver() public {
    _partialHandover({hubAuthority: true, spokeAuthority: false, hubAdmin: true, spokeAdmin: true});
    vm.expectRevert('BABYLON_SPOKE_NOT_HANDED_OVER');
    proposal.execute();
    _expectGovernanceExecutionReverts();
  }

  function test_revertsWith_hubProxyAdminNotHandedOver() public {
    _partialHandover({hubAuthority: true, spokeAuthority: true, hubAdmin: false, spokeAdmin: true});
    vm.expectRevert('BABYLON_HUB_PROXY_ADMIN_NOT_HANDED_OVER');
    proposal.execute();
    _expectGovernanceExecutionReverts();
  }

  function test_revertsWith_spokeProxyAdminNotHandedOver() public {
    _partialHandover({hubAuthority: true, spokeAuthority: true, hubAdmin: true, spokeAdmin: false});
    vm.expectRevert('BABYLON_SPOKE_PROXY_ADMIN_NOT_HANDED_OVER');
    proposal.execute();
    _expectGovernanceExecutionReverts();
  }

  function test_revertsWith_noHandover() public {
    _partialHandover({
      hubAuthority: false,
      spokeAuthority: false,
      hubAdmin: false,
      spokeAdmin: false
    });
    vm.expectRevert('BABYLON_HUB_NOT_HANDED_OVER');
    proposal.execute();
    _expectGovernanceExecutionReverts();
  }

  // ─── the payload changes exactly what is intended ───

  /// @dev Every AccessManager change emits an event, so the events are the full list of changes.
  function test_accessManagerEvents() public {
    vm.recordLogs();
    _executePayload();
    Vm.Log[] memory logs = vm.getRecordedLogs();

    uint256 granted;
    uint256 labeled;
    uint256 guardianChanged;
    uint256 functionRoleUpdated;
    uint256 total;
    for (uint256 i; i < logs.length; ++i) {
      assertTrue(logs[i].emitter != DEPLOYMENT_ACCESS_MANAGER, 'deployment access manager event');
      if (logs[i].emitter != ACCESS_MANAGER) continue;
      ++total;
      bytes32 topic = logs[i].topics[0];
      if (topic == IAccessManager.RoleGranted.selector) ++granted;
      if (topic == IAccessManager.RoleLabel.selector) ++labeled;
      if (topic == IAccessManager.RoleGuardianChanged.selector) ++guardianChanged;
      if (topic == IAccessManager.TargetFunctionRoleUpdated.selector) ++functionRoleUpdated;
    }
    assertEq(granted, 5, 'role grants');
    assertEq(labeled, 2, 'role labels');
    assertEq(guardianChanged, 1, 'role guardian changes');
    assertEq(functionRoleUpdated, 21, 'function role updates');
    // no revoke, admin change, grant delay change, target closing or target admin delay change
    assertEq(total, 29, 'access manager events');
  }

  function test_accessManagerChangesExactly() public {
    _snapshotAccessManager();
    _executePayload();
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);

    uint256 roleCountBefore = _rolesBefore.length;
    assertEq(accessManager.getRoleCount(), roleCountBefore + 2, 'role count');
    assertEq(accessManager.getRole(roleCountBefore), BTC_VAULT_SWAP_FEE_ROLE, 'fee role');
    assertEq(
      accessManager.getRole(roleCountBefore + 1),
      BTC_VAULT_SWAP_GUARDIAN_ROLE,
      'guardian role'
    );
    assertEq(_roleHash(ADMIN_ROLE), _roleBefore[ADMIN_ROLE], 'admin role changed');

    for (uint256 i; i < roleCountBefore; ++i) {
      uint64 role = _rolesBefore[i];
      assertEq(accessManager.getRole(i), role, 'role order');
      assertEq(_roleHash(role), _roleBefore[role], 'role members or settings changed');

      address newTarget = _newTargetOf(role);
      address[] storage targetsBefore = _roleTargetsBefore[role];
      uint256 targetCount = accessManager.getRoleTargetCount(role);
      assertEq(
        targetCount,
        targetsBefore.length + (newTarget == address(0) ? 0 : 1),
        'role target count'
      );
      for (uint256 j; j < targetsBefore.length; ++j) {
        assertEq(accessManager.getRoleTarget(role, j), targetsBefore[j], 'role target order');
        assertEq(
          _selectorsHash(role, targetsBefore[j]),
          _roleSelectorsBefore[role][targetsBefore[j]],
          'selectors of an existing target changed'
        );
      }
      if (newTarget != address(0)) {
        assertEq(accessManager.getRoleTarget(role, targetCount - 1), newTarget, 'new target');
      }
    }
  }

  function test_hubsChangeExactly() public {
    IHub[] memory hubs = _getHubs();
    for (uint256 i; i < hubs.length; ++i) {
      _snapshotHub(hubs[i]);
    }
    _executePayload();

    SpokeAddition[] memory additions = _expectedAdditions();
    uint256 matched;
    for (uint256 i; i < hubs.length; ++i) {
      address hub = address(hubs[i]);
      uint256 assetCount = hubs[i].getAssetCount();
      assertEq(assetCount, _assetCountBefore[hub], 'asset count');
      for (uint256 assetId; assetId < assetCount; ++assetId) {
        uint256 countBefore = _spokeCountBefore[hub][assetId];
        assertEq(
          keccak256(abi.encode(hubs[i].getAssetConfig(assetId))),
          _assetConfigBefore[hub][assetId],
          'asset config changed'
        );
        assertEq(
          _spokesHash(hubs[i], assetId, countBefore),
          _spokesBefore[hub][assetId],
          'existing spoke changed'
        );
        uint256 countAfter = hubs[i].getSpokeCount(assetId);
        for (uint256 j = countBefore; j < countAfter; ++j) {
          address spoke = hubs[i].getSpokeAddress(assetId, j);
          SpokeAddition memory addition = _findAddition(additions, hub, assetId, spoke);
          assertEq(
            abi.encode(hubs[i].getSpokeConfig(assetId, spoke)),
            abi.encode(_spokeConfig(addition.addCap, addition.drawCap)),
            'spoke config'
          );
          ++matched;
        }
      }
    }
    assertEq(matched, additions.length, 'spoke additions');
    assertEq(additions.length, 15, 'expected additions');
  }

  /// @dev The proposal sets no Spoke parameter and activates no position manager.
  function test_spokesUntouched() public {
    ISpoke[] memory spokes = _getSpokes();
    for (uint256 i; i < spokes.length; ++i) {
      _spokeStateBefore[address(spokes[i])] = _spokeStateHash(spokes[i]);
    }
    vm.recordLogs();
    _executePayload();
    Vm.Log[] memory logs = vm.getRecordedLogs();

    for (uint256 i; i < spokes.length; ++i) {
      assertEq(
        _spokeStateHash(spokes[i]),
        _spokeStateBefore[address(spokes[i])],
        'spoke state changed'
      );
    }
    for (uint256 i; i < logs.length; ++i) {
      for (uint256 j; j < spokes.length; ++j) {
        assertTrue(logs[i].emitter != address(spokes[j]), 'spoke event');
      }
    }
  }

  function test_noPositionManagers() public {
    _executePayload();
    address[] memory candidates = _positionManagerCandidates();
    assertEq(candidates.length, 5, 'position manager candidates');
    for (uint256 i; i < candidates.length; ++i) {
      assertFalse(
        ISpoke(BABYLON_SPOKE).isPositionManagerActive(candidates[i]),
        'position manager active'
      );
    }
    // covers position managers outside the known list
    bytes32[] memory topics = new bytes32[](1);
    topics[0] = ISpoke.UpdatePositionManager.selector;
    assertEq(
      vm.eth_getLogs(BABYLON_SPOKE_DEPLOY_BLOCK, FORK_BLOCK, BABYLON_SPOKE, topics).length,
      0,
      'position manager updates since deployment'
    );
  }

  /// @dev Only the shared AccessManager and the two Hubs are written, plus the governance contracts.
  function test_onlyExpectedContractsWritten() public {
    vm.startStateDiffRecording();
    _executePayload();
    Vm.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();

    uint256 writes;
    for (uint256 i; i < accesses.length; ++i) {
      for (uint256 j; j < accesses[i].storageAccesses.length; ++j) {
        Vm.StorageAccess memory access = accesses[i].storageAccesses[j];
        if (!access.isWrite || access.reverted || access.previousValue == access.newValue) {
          continue;
        }
        ++writes;
        assertTrue(
          access.account == ACCESS_MANAGER ||
            access.account == BABYLON_HUB ||
            access.account == CORE_HUB ||
            access.account == _payloadsController(),
          string.concat('unexpected storage write: ', vm.toString(access.account))
        );
      }
    }
    assertGt(writes, 0, 'no storage writes recorded');
  }

  // ─── end state, written out from the launch plan and the LlamaRisk parameters ───

  function test_hubAndSpokeRoleMapping() public {
    _executePayload();
    uint64[] memory hubRoles = new uint64[](7);
    for (uint256 i; i < 5; ++i) {
      hubRoles[i] = HUB_CONFIGURATOR_ROLE;
    }
    hubRoles[5] = HUB_FEE_MINTER_ROLE;
    hubRoles[6] = HUB_DEFICIT_ELIMINATOR_ROLE;
    _assertSelectorRoles(BABYLON_HUB, _hubSelectors(), hubRoles);
    // the mapping every other Ethereum V4 Hub has
    _assertSelectorRoles(CORE_HUB, _hubSelectors(), hubRoles);

    uint64[] memory spokeRoles = new uint64[](9);
    for (uint256 i; i < 7; ++i) {
      spokeRoles[i] = SPOKE_CONFIGURATOR_ROLE;
    }
    spokeRoles[7] = SPOKE_USER_POSITION_UPDATER_ROLE;
    spokeRoles[8] = SPOKE_USER_POSITION_UPDATER_ROLE;
    _assertSelectorRoles(BABYLON_SPOKE, _spokeSelectors(), spokeRoles);
    _assertSelectorRoles(MAIN_SPOKE, _spokeSelectors(), spokeRoles);

    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);
    assertEq(accessManager.getRoleTargetSelectorCount(HUB_CONFIGURATOR_ROLE, BABYLON_HUB), 5);
    assertEq(accessManager.getRoleTargetSelectorCount(HUB_FEE_MINTER_ROLE, BABYLON_HUB), 1);
    assertEq(accessManager.getRoleTargetSelectorCount(HUB_DEFICIT_ELIMINATOR_ROLE, BABYLON_HUB), 1);
    assertEq(accessManager.getRoleTargetSelectorCount(SPOKE_CONFIGURATOR_ROLE, BABYLON_SPOKE), 7);
    assertEq(
      accessManager.getRoleTargetSelectorCount(SPOKE_USER_POSITION_UPDATER_ROLE, BABYLON_SPOKE),
      2
    );
    address[3] memory targets = [BABYLON_HUB, BABYLON_SPOKE, BTC_VAULT_SWAP];
    for (uint256 i; i < targets.length; ++i) {
      assertFalse(accessManager.isTargetClosed(targets[i]), 'target closed');
      assertEq(accessManager.getTargetAdminDelay(targets[i]), 0, 'target admin delay');
    }
  }

  function test_btcVaultSwapRoles() public {
    _executePayload();
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);

    uint64[] memory roles = new uint64[](5);
    roles[0] = BTC_VAULT_SWAP_FEE_ROLE;
    for (uint256 i = 1; i < 5; ++i) {
      roles[i] = BTC_VAULT_SWAP_GUARDIAN_ROLE;
    }
    _assertSelectorRoles(BTC_VAULT_SWAP, _btcVaultSwapSelectors(), roles);
    assertEq(accessManager.getRoleTargetCount(BTC_VAULT_SWAP_FEE_ROLE), 1, 'fee role targets');
    assertEq(accessManager.getRoleTarget(BTC_VAULT_SWAP_FEE_ROLE, 0), BTC_VAULT_SWAP);
    assertEq(accessManager.getRoleTargetSelectorCount(BTC_VAULT_SWAP_FEE_ROLE, BTC_VAULT_SWAP), 1);
    assertEq(accessManager.getRoleTargetCount(BTC_VAULT_SWAP_GUARDIAN_ROLE), 1, 'guardian targets');
    assertEq(accessManager.getRoleTarget(BTC_VAULT_SWAP_GUARDIAN_ROLE, 0), BTC_VAULT_SWAP);
    assertEq(
      accessManager.getRoleTargetSelectorCount(BTC_VAULT_SWAP_GUARDIAN_ROLE, BTC_VAULT_SWAP),
      4
    );

    assertEq(accessManager.getLabelOfRole(BTC_VAULT_SWAP_FEE_ROLE), 'BTC_VAULT_SWAP_FEE_ROLE');
    assertEq(
      accessManager.getLabelOfRole(BTC_VAULT_SWAP_GUARDIAN_ROLE),
      'BTC_VAULT_SWAP_GUARDIAN_ROLE'
    );
    assertEq(accessManager.getRoleOfLabel('BTC_VAULT_SWAP_FEE_ROLE'), BTC_VAULT_SWAP_FEE_ROLE);
    assertEq(
      accessManager.getRoleOfLabel('BTC_VAULT_SWAP_GUARDIAN_ROLE'),
      BTC_VAULT_SWAP_GUARDIAN_ROLE
    );
    assertEq(
      accessManager.getRoleGuardian(BTC_VAULT_SWAP_FEE_ROLE),
      BTC_VAULT_SWAP_GUARDIAN_ROLE,
      'fee role guardian'
    );
    assertEq(accessManager.getRoleGuardian(BTC_VAULT_SWAP_GUARDIAN_ROLE), 0, 'guardian guardian');
    // 2000 stays reserved for a domain admin role
    assertEq(BTC_VAULT_SWAP_FEE_ROLE, 2001, 'fee role id');
    assertEq(BTC_VAULT_SWAP_GUARDIAN_ROLE, 2002, 'guardian role id');
    assertFalse(accessManager.isRole(BTC_VAULT_SWAP_DOMAIN_ADMIN_ROLE), 'domain admin role');
    assertEq(accessManager.getRoleMemberCount(BTC_VAULT_SWAP_DOMAIN_ADMIN_ROLE), 0);
    uint64[2] memory newRoles = [BTC_VAULT_SWAP_FEE_ROLE, BTC_VAULT_SWAP_GUARDIAN_ROLE];
    for (uint256 i; i < newRoles.length; ++i) {
      assertEq(accessManager.getRoleAdmin(newRoles[i]), ADMIN_ROLE, 'role admin');
      assertEq(accessManager.getRoleGrantDelay(newRoles[i]), 0, 'grant delay');
    }

    assertEq(accessManager.getRoleMemberCount(BTC_VAULT_SWAP_FEE_ROLE), 1, 'fee role members');
    assertEq(accessManager.getRoleMember(BTC_VAULT_SWAP_FEE_ROLE, 0), BTC_VAULT_SWAP_MULTISIG);
    _assertAccess({
      role: BTC_VAULT_SWAP_FEE_ROLE,
      account: BTC_VAULT_SWAP_MULTISIG,
      executionDelay: 432_000
    });

    address[4] memory guardians = _btcVaultSwapGuardians();
    assertEq(accessManager.getRoleMemberCount(BTC_VAULT_SWAP_GUARDIAN_ROLE), 4, 'guardians');
    for (uint256 i; i < guardians.length; ++i) {
      assertEq(accessManager.getRoleMember(BTC_VAULT_SWAP_GUARDIAN_ROLE, i), guardians[i]);
      _assertAccess({role: BTC_VAULT_SWAP_GUARDIAN_ROLE, account: guardians[i], executionDelay: 0});
    }
    // the fee role stays with the 2-of-3
    address[3] memory others = [V4_SECURITY_COUNCIL, V4_SECURITY_COUNCIL_EXECUTOR, EXECUTOR_LVL_1];
    for (uint256 i; i < others.length; ++i) {
      (bool isMember, ) = accessManager.hasRole(BTC_VAULT_SWAP_FEE_ROLE, others[i]);
      assertFalse(isMember, 'fee role member');
    }
    (bool stewardIsGuardian, ) = accessManager.hasRole(BTC_VAULT_SWAP_GUARDIAN_ROLE, RISK_STEWARD);
    assertFalse(stewardIsGuardian, 'risk steward guardian');

    // a grant delay set by the proposal would only show after its setback
    skip(30 days);
    for (uint256 i; i < newRoles.length; ++i) {
      assertEq(accessManager.getRoleGrantDelay(newRoles[i]), 0, 'grant delay after setback');
    }
  }

  function test_caps() public {
    _executePayload();
    SpokeAddition[] memory additions = _expectedAdditions();
    for (uint256 i; i < additions.length; ++i) {
      IHub.SpokeConfig memory config = IHub(additions[i].hub).getSpokeConfig(
        additions[i].assetId,
        additions[i].spoke
      );
      assertTrue(
        IHub(additions[i].hub).isSpokeListed(additions[i].assetId, additions[i].spoke),
        'spoke not listed'
      );
      assertEq(config.addCap, additions[i].addCap, 'add cap');
      assertEq(config.drawCap, additions[i].drawCap, 'draw cap');
      assertEq(config.riskPremiumThreshold, 0, 'risk premium threshold');
      assertTrue(config.active, 'active');
      assertFalse(config.halted, 'halted');
    }
    // vaultBTC can never be drawn
    uint256 spokeCount = IHub(BABYLON_HUB).getSpokeCount(BABYLON_VAULT_BTC_ASSET_ID);
    for (uint256 i; i < spokeCount; ++i) {
      address spoke = IHub(BABYLON_HUB).getSpokeAddress(BABYLON_VAULT_BTC_ASSET_ID, i);
      assertEq(
        IHub(BABYLON_HUB).getSpokeConfig(BABYLON_VAULT_BTC_ASSET_ID, spoke).drawCap,
        0,
        'vaultBTC draw cap'
      );
    }
    // the BabylonSpoke has no Core Hub WBTC line, only BTCVaultSwap does
    assertFalse(IHub(CORE_HUB).isSpokeListed(CORE_WBTC_ASSET_ID, BABYLON_SPOKE), 'core wbtc line');
  }

  // ─── BTCVaultSwap roles in use ───

  function test_feeChange() public {
    _executePayload();
    IAccessManager accessManager = IAccessManager(ACCESS_MANAGER);
    bytes memory data = abi.encodeCall(IBTCVaultSwap.setSwapFeeBps, (2_50, 60));
    bytes32 operationId = accessManager.hashOperation(
      BTC_VAULT_SWAP_MULTISIG,
      BTC_VAULT_SWAP,
      data
    );

    vm.expectRevert(
      abi.encodeWithSelector(IAccessManager.AccessManagerNotScheduled.selector, operationId)
    );
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).setSwapFeeBps(2_50, 60);

    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    accessManager.schedule(BTC_VAULT_SWAP, data, 0);
    assertEq(accessManager.getSchedule(operationId), block.timestamp + 5 days, 'schedule');

    skip(5 days - 1);
    vm.expectRevert(
      abi.encodeWithSelector(IAccessManager.AccessManagerNotReady.selector, operationId)
    );
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).setSwapFeeBps(2_50, 60);

    skip(1);
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).setSwapFeeBps(2_50, 60);
    assertEq(IBTCVaultSwapView(BTC_VAULT_SWAP).sellDiscountBps(), 2_50, 'sell discount');
    assertEq(IBTCVaultSwapView(BTC_VAULT_SWAP).minimumProfitThresholdBps(), 60, 'profit threshold');
  }

  function test_feeChange_cannotBeScheduledEarlier() public {
    _executePayload();
    bytes memory data = abi.encodeCall(IBTCVaultSwap.setSwapFeeBps, (2_50, 60));
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessManager.AccessManagerUnauthorizedCall.selector,
        BTC_VAULT_SWAP_MULTISIG,
        BTC_VAULT_SWAP,
        IBTCVaultSwap.setSwapFeeBps.selector
      )
    );
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IAccessManager(ACCESS_MANAGER).schedule(
      BTC_VAULT_SWAP,
      data,
      uint48(block.timestamp + 5 days - 1)
    );
  }

  function test_feeChange_expiresAfterOneWeek() public {
    _executePayload();
    IAccessManager accessManager = IAccessManager(ACCESS_MANAGER);
    bytes memory data = abi.encodeCall(IBTCVaultSwap.setSwapFeeBps, (2_50, 60));
    bytes32 operationId = accessManager.hashOperation(
      BTC_VAULT_SWAP_MULTISIG,
      BTC_VAULT_SWAP,
      data
    );
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    accessManager.schedule(BTC_VAULT_SWAP, data, 0);

    skip(5 days + 1 weeks);
    vm.expectRevert(
      abi.encodeWithSelector(IAccessManager.AccessManagerExpired.selector, operationId)
    );
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).setSwapFeeBps(2_50, 60);
  }

  function test_feeChange_cancelledByEachGuardian() public {
    _executePayload();
    IAccessManager accessManager = IAccessManager(ACCESS_MANAGER);
    bytes memory data = abi.encodeCall(IBTCVaultSwap.setSwapFeeBps, (2_50, 60));
    bytes32 operationId = accessManager.hashOperation(
      BTC_VAULT_SWAP_MULTISIG,
      BTC_VAULT_SWAP,
      data
    );
    address[4] memory guardians = _btcVaultSwapGuardians();
    for (uint256 i; i < guardians.length; ++i) {
      vm.prank(BTC_VAULT_SWAP_MULTISIG);
      accessManager.schedule(BTC_VAULT_SWAP, data, 0);

      vm.prank(guardians[i]);
      accessManager.cancel(BTC_VAULT_SWAP_MULTISIG, BTC_VAULT_SWAP, data);

      skip(5 days);
      vm.expectRevert(
        abi.encodeWithSelector(IAccessManager.AccessManagerNotScheduled.selector, operationId)
      );
      vm.prank(BTC_VAULT_SWAP_MULTISIG);
      IBTCVaultSwap(BTC_VAULT_SWAP).setSwapFeeBps(2_50, 60);
    }
    assertEq(IBTCVaultSwapView(BTC_VAULT_SWAP).sellDiscountBps(), 2_00, 'sell discount');
  }

  function test_feeChange_revertsWith_cancelNotFromGuardian() public {
    _executePayload();
    IAccessManager accessManager = IAccessManager(ACCESS_MANAGER);
    bytes memory data = abi.encodeCall(IBTCVaultSwap.setSwapFeeBps, (2_50, 60));
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    accessManager.schedule(BTC_VAULT_SWAP, data, 0);

    address[2] memory callers = [RISK_STEWARD, user];
    for (uint256 i; i < callers.length; ++i) {
      vm.expectRevert(
        abi.encodeWithSelector(
          IAccessManager.AccessManagerUnauthorizedCancel.selector,
          callers[i],
          BTC_VAULT_SWAP_MULTISIG,
          BTC_VAULT_SWAP,
          IBTCVaultSwap.setSwapFeeBps.selector
        )
      );
      vm.prank(callers[i]);
      accessManager.cancel(BTC_VAULT_SWAP_MULTISIG, BTC_VAULT_SWAP, data);
    }
  }

  function test_feeChange_revertsWith_notFromMultisig() public {
    _executePayload();
    bytes memory data = abi.encodeCall(IBTCVaultSwap.setSwapFeeBps, (2_50, 60));
    address[5] memory callers = [
      V4_SECURITY_COUNCIL,
      V4_SECURITY_COUNCIL_EXECUTOR,
      EXECUTOR_LVL_1,
      RISK_STEWARD,
      user
    ];
    for (uint256 i; i < callers.length; ++i) {
      vm.expectRevert(
        abi.encodeWithSelector(
          IAccessManager.AccessManagerUnauthorizedCall.selector,
          callers[i],
          BTC_VAULT_SWAP,
          IBTCVaultSwap.setSwapFeeBps.selector
        )
      );
      vm.prank(callers[i]);
      IAccessManager(ACCESS_MANAGER).schedule(BTC_VAULT_SWAP, data, 0);

      vm.expectRevert(
        abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, callers[i])
      );
      vm.prank(callers[i]);
      IBTCVaultSwap(BTC_VAULT_SWAP).setSwapFeeBps(2_50, 60);
    }
  }

  function test_guardiansPauseAndFreeze() public {
    _executePayload();
    IBTCVaultSwap btcVaultSwap = IBTCVaultSwap(BTC_VAULT_SWAP);
    IBTCVaultSwapView state = IBTCVaultSwapView(BTC_VAULT_SWAP);
    address[4] memory guardians = _btcVaultSwapGuardians();
    for (uint256 i; i < guardians.length; ++i) {
      vm.startPrank(guardians[i]);
      btcVaultSwap.pause();
      assertTrue(state.isPaused(), 'paused');
      btcVaultSwap.unpause();
      assertFalse(state.isPaused(), 'unpaused');
      btcVaultSwap.freeze();
      assertTrue(state.isFrozen(), 'frozen');
      btcVaultSwap.unfreeze();
      assertFalse(state.isFrozen(), 'unfrozen');
      vm.stopPrank();
    }
  }

  /// @dev A guardian other than the one that paused or froze can undo it.
  function test_guardiansUndoEachOther() public {
    _executePayload();
    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).pause();
    vm.prank(V4_SECURITY_COUNCIL);
    IBTCVaultSwap(BTC_VAULT_SWAP).unpause();
    assertFalse(IBTCVaultSwapView(BTC_VAULT_SWAP).isPaused(), 'unpaused');

    vm.prank(BTC_VAULT_SWAP_MULTISIG);
    IBTCVaultSwap(BTC_VAULT_SWAP).freeze();
    vm.prank(EXECUTOR_LVL_1);
    IBTCVaultSwap(BTC_VAULT_SWAP).unfreeze();
    assertFalse(IBTCVaultSwapView(BTC_VAULT_SWAP).isFrozen(), 'unfrozen');
  }

  function test_revertsWith_pauseOrFreezeNotFromGuardian() public {
    _executePayload();
    address[2] memory callers = [RISK_STEWARD, user];
    bytes4[4] memory selectors = [
      IBTCVaultSwap.pause.selector,
      IBTCVaultSwap.unpause.selector,
      IBTCVaultSwap.freeze.selector,
      IBTCVaultSwap.unfreeze.selector
    ];
    for (uint256 i; i < callers.length; ++i) {
      for (uint256 j; j < selectors.length; ++j) {
        vm.prank(callers[i]);
        (bool success, bytes memory returnData) = BTC_VAULT_SWAP.call(
          abi.encodeWithSelector(selectors[j])
        );
        assertFalse(success, 'unauthorized call succeeded');
        assertEq(
          returnData,
          abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, callers[i]),
          'revert reason'
        );
      }
    }
  }

  // ─── the market in use ───

  function test_btcVaultSwapCreditLine() public {
    _executePayload();
    uint256 balanceBefore = IERC20(WBTC).balanceOf(BTC_VAULT_SWAP);
    vm.prank(BTC_VAULT_SWAP);
    IHub(CORE_HUB).draw(CORE_WBTC_ASSET_ID, 20e8, BTC_VAULT_SWAP);
    assertEq(IERC20(WBTC).balanceOf(BTC_VAULT_SWAP), balanceBefore + 20e8, 'drawn');

    vm.expectRevert(abi.encodeWithSelector(IHub.DrawCapExceeded.selector, 20));
    vm.prank(BTC_VAULT_SWAP);
    IHub(CORE_HUB).draw(CORE_WBTC_ASSET_ID, 1, BTC_VAULT_SWAP);
  }

  function test_btcVaultSwapCannotSupplyToCoreHub() public {
    _executePayload();
    deal(WBTC, BTC_VAULT_SWAP, 1e8);
    vm.startPrank(BTC_VAULT_SWAP);
    IERC20(WBTC).transfer(CORE_HUB, 1e8);
    vm.expectRevert(abi.encodeWithSelector(IHub.AddCapExceeded.selector, 0));
    IHub(CORE_HUB).add(CORE_WBTC_ASSET_ID, 1e8);
    vm.stopPrank();
  }

  function test_borrowFromEachCoreHubCreditLine() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 20e8);
    uint256[5] memory reserveIds = [
      CORE_USDT_RESERVE_ID,
      CORE_USDC_RESERVE_ID,
      CORE_GHO_RESERVE_ID,
      CORE_USDG_RESERVE_ID,
      CORE_RLUSD_RESERVE_ID
    ];
    uint256[5] memory assetIds = [
      CORE_USDT_ASSET_ID,
      CORE_USDC_ASSET_ID,
      CORE_GHO_ASSET_ID,
      CORE_USDG_ASSET_ID,
      CORE_RLUSD_ASSET_ID
    ];
    address[5] memory tokens = [USDT, USDC, GHO, USDG, RLUSD];
    for (uint256 i; i < reserveIds.length; ++i) {
      uint256 snapshot = vm.snapshotState();
      // the Core Hub holds little RLUSD and GHO, so the amount follows what is available
      uint256 liquidity = IHub(CORE_HUB).getAssetLiquidity(assetIds[i]);
      uint256 amount = 1_000 * 10 ** IERC20(tokens[i]).decimals();
      if (amount > liquidity / 2) amount = liquidity / 2;
      assertGt(amount, 0, 'no core hub liquidity');
      uint256 drawnBefore = IHub(CORE_HUB).getSpokeDrawnShares(assetIds[i], BABYLON_SPOKE);
      vm.prank(user);
      ISpoke(BABYLON_SPOKE).borrow(reserveIds[i], amount, user);
      assertEq(IERC20(tokens[i]).balanceOf(user), amount, 'borrowed');
      assertGe(ISpoke(BABYLON_SPOKE).getUserTotalDebt(reserveIds[i], user), amount, 'debt');
      assertGt(
        IHub(CORE_HUB).getSpokeDrawnShares(assetIds[i], BABYLON_SPOKE),
        drawnBefore,
        'core hub drawn'
      );
      vm.revertToState(snapshot);
    }
  }

  function test_borrowFromEachBabylonHubReserve() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 20e8);
    uint256[4] memory reserveIds = [
      BABYLON_USDT_RESERVE_ID,
      BABYLON_USDC_RESERVE_ID,
      BABYLON_GHO_RESERVE_ID,
      BABYLON_WBTC_RESERVE_ID
    ];
    address[4] memory tokens = [USDT, USDC, GHO, WBTC];
    for (uint256 i; i < reserveIds.length; ++i) {
      uint256 snapshot = vm.snapshotState();
      uint256 unit = 10 ** IERC20(tokens[i]).decimals();
      _supplyToBabylonHub(tokens[i], reserveIds[i], 10 * unit);
      vm.prank(user);
      ISpoke(BABYLON_SPOKE).borrow(reserveIds[i], unit, user);
      assertEq(IERC20(tokens[i]).balanceOf(user), unit, 'borrowed');
      assertGt(IHub(BABYLON_HUB).getSpokeDrawnShares(i + 1, BABYLON_SPOKE), 0, 'drawn');
      vm.revertToState(snapshot);
    }
  }

  function test_repayAndWithdraw() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 2e8);
    vm.startPrank(user);
    ISpoke(BABYLON_SPOKE).borrow(CORE_USDC_RESERVE_ID, 10_000e6, user);
    skip(30 days);
    uint256 debt = ISpoke(BABYLON_SPOKE).getUserTotalDebt(CORE_USDC_RESERVE_ID, user);
    assertGt(debt, 10_000e6, 'interest accrued');
    deal(USDC, user, debt);
    IERC20(USDC).approve(BABYLON_SPOKE, debt);
    ISpoke(BABYLON_SPOKE).repay(CORE_USDC_RESERVE_ID, type(uint256).max, user);
    assertEq(ISpoke(BABYLON_SPOKE).getUserTotalDebt(CORE_USDC_RESERVE_ID, user), 0, 'debt');
    ISpoke(BABYLON_SPOKE).withdraw(VAULT_BTC_RESERVE_ID, 2e8, user);
    vm.stopPrank();
    assertEq(IERC20(VAULT_BTC).balanceOf(user), 2e8, 'vaultBTC returned');
  }

  function test_revertsWith_coreHubDrawCapExceeded() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 20e8);
    vm.expectRevert(abi.encodeWithSelector(IHub.DrawCapExceeded.selector, 500_000));
    vm.prank(user);
    ISpoke(BABYLON_SPOKE).borrow(CORE_USDC_RESERVE_ID, 500_001e6, user);
  }

  function test_revertsWith_babylonHubDrawCapExceeded() public {
    _executePayload();
    _supplyToBabylonHub(USDC, BABYLON_USDC_RESERVE_ID, 1_000_000e6);
    _supplyVaultBtcAsCollateral(user, 20e8);
    vm.expectRevert(abi.encodeWithSelector(IHub.DrawCapExceeded.selector, 250_000));
    vm.prank(user);
    ISpoke(BABYLON_SPOKE).borrow(BABYLON_USDC_RESERVE_ID, 250_001e6, user);
  }

  function test_vaultBtcAddCap() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 20e8);
    _mintVaultBtc(supplier, 1);
    vm.startPrank(supplier);
    IERC20(VAULT_BTC).approve(BABYLON_SPOKE, 1);
    vm.expectRevert(abi.encodeWithSelector(IHub.AddCapExceeded.selector, 20));
    ISpoke(BABYLON_SPOKE).supply(VAULT_BTC_RESERVE_ID, 1, supplier);
    vm.stopPrank();
  }

  function test_revertsWith_secondDebtReserve() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 10e8);
    vm.startPrank(user);
    ISpoke(BABYLON_SPOKE).borrow(CORE_USDC_RESERVE_ID, 1_000e6, user);
    vm.expectRevert(ISpoke.MaximumUserReservesExceeded.selector);
    ISpoke(BABYLON_SPOKE).borrow(CORE_USDT_RESERVE_ID, 1_000e6, user);
    vm.stopPrank();
  }

  function test_revertsWith_borrowVaultBtc() public {
    _executePayload();
    _supplyVaultBtcAsCollateral(user, 10e8);
    vm.expectRevert(ISpoke.ReserveNotBorrowable.selector);
    vm.prank(user);
    ISpoke(BABYLON_SPOKE).borrow(VAULT_BTC_RESERVE_ID, 1, user);
  }

  function test_revertsWith_liquidationNotFromAdapter() public {
    _executePayload();
    vm.expectRevert(ISpoke.Unauthorized.selector);
    IBabylonSpoke(BABYLON_SPOKE).liquidationCall(CORE_USDC_RESERVE_ID, 1, user, 1);
    vm.expectRevert(IBabylonSpoke.UnsupportedLiquidationCall.selector);
    ISpoke(BABYLON_SPOKE).liquidationCall(
      VAULT_BTC_RESERVE_ID,
      CORE_USDC_RESERVE_ID,
      user,
      1,
      false
    );
  }

  function test_tokenizationSpokeDeposits() public {
    _executePayload();
    address[4] memory tokenizationSpokes = _babylonTokenizationSpokes();
    address[4] memory tokens = [USDT, USDC, GHO, WBTC];
    uint40[4] memory addCaps = [uint40(1_000_000), 1_000_000, 1_000_000, 10];
    for (uint256 i; i < tokenizationSpokes.length; ++i) {
      ITokenizationSpoke tokenizationSpoke = ITokenizationSpoke(tokenizationSpokes[i]);
      assertEq(tokenizationSpoke.asset(), tokens[i], 'asset');
      uint256 amount = addCaps[i] * 10 ** IERC20(tokens[i]).decimals();
      deal(tokens[i], supplier, amount + 1);
      vm.startPrank(supplier);
      (bool ok, ) = tokens[i].call(
        abi.encodeCall(IERC20.approve, (tokenizationSpokes[i], amount + 1))
      );
      require(ok, 'approve');
      uint256 shares = tokenizationSpoke.deposit(amount, supplier);
      assertEq(tokenizationSpoke.balanceOf(supplier), shares, 'shares');
      assertEq(tokenizationSpoke.totalAssets(), amount, 'total assets');
      vm.expectRevert(abi.encodeWithSelector(IHub.AddCapExceeded.selector, addCaps[i]));
      tokenizationSpoke.deposit(1, supplier);
      vm.stopPrank();
    }
  }

  // ─── governance keeps control after the proposal ───

  function test_configuratorsGovernTheMarket() public {
    _executePayload();
    vm.startPrank(EXECUTOR_LVL_1);
    ISpokeConfigurator(SPOKE_CONFIGURATOR).updateFrozen(
      BABYLON_SPOKE,
      BABYLON_USDC_RESERVE_ID,
      true
    );
    IHubConfigurator(HUB_CONFIGURATOR).updateSpokeDrawCap({
      hub: BABYLON_HUB,
      assetId: BABYLON_USDC_ASSET_ID,
      spoke: BABYLON_SPOKE,
      drawCap: 1
    });
    vm.stopPrank();
    assertTrue(ISpoke(BABYLON_SPOKE).getReserveConfig(BABYLON_USDC_RESERVE_ID).frozen, 'frozen');
    assertEq(
      IHub(BABYLON_HUB).getSpokeConfig(BABYLON_USDC_ASSET_ID, BABYLON_SPOKE).drawCap,
      1,
      'draw cap'
    );
  }

  /// @dev Holders of role 200 can cut the BTCVaultSwap credit line, the fallback to role 2002.
  function test_securityCouncilCutsBtcVaultSwapCreditLine() public {
    _executePayload();
    vm.prank(V4_SECURITY_COUNCIL);
    IHubConfigurator(HUB_CONFIGURATOR).updateSpokeDrawCap({
      hub: CORE_HUB,
      assetId: CORE_WBTC_ASSET_ID,
      spoke: BTC_VAULT_SWAP,
      drawCap: 0
    });
    vm.expectRevert(abi.encodeWithSelector(IHub.DrawCapExceeded.selector, 0));
    vm.prank(BTC_VAULT_SWAP);
    IHub(CORE_HUB).draw(CORE_WBTC_ASSET_ID, 1, BTC_VAULT_SWAP);
  }

  function test_riskStewardUpdatesBabylonHubCaps() public {
    _executePayload();
    IHub.SpokeConfig memory config = IHub(BABYLON_HUB).getSpokeConfig(
      BABYLON_USDC_ASSET_ID,
      BABYLON_SPOKE
    );
    uint40 addCap = config.addCap + 1;
    uint40 drawCap = config.drawCap - 1;
    IAaveV4ConfigEngine.SpokeConfigUpdate[]
      memory updates = new IAaveV4ConfigEngine.SpokeConfigUpdate[](1);
    updates[0] = IAaveV4ConfigEngine.SpokeConfigUpdate({
      hubConfigurator: IHubConfigurator(HUB_CONFIGURATOR),
      hub: BABYLON_HUB,
      underlying: USDC,
      spoke: BABYLON_SPOKE,
      addCap: addCap,
      drawCap: drawCap,
      riskPremiumThreshold: EngineFlags.KEEP_CURRENT,
      active: EngineFlags.KEEP_CURRENT,
      halted: EngineFlags.KEEP_CURRENT
    });
    vm.prank(RISK_COUNCIL);
    IV4RiskSteward(RISK_STEWARD).updateHubSpokeCaps(updates);
    config = IHub(BABYLON_HUB).getSpokeConfig(BABYLON_USDC_ASSET_ID, BABYLON_SPOKE);
    assertEq(config.addCap, addCap, 'add cap');
    assertEq(config.drawCap, drawCap, 'draw cap');
  }

  function test_revertsWith_restrictedFunctionsFromAnyone() public {
    _executePayload();
    IHub.SpokeConfig memory config = _spokeConfig(1, 1);
    address[4] memory callers = [user, DEPLOYER, DEPLOYMENT_HUB_CONFIGURATOR, AAVE_ADAPTER];
    for (uint256 i; i < callers.length; ++i) {
      vm.startPrank(callers[i]);
      vm.expectRevert(
        abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, callers[i])
      );
      IHub(BABYLON_HUB).addSpoke(BABYLON_USDC_ASSET_ID, callers[i], config);
      vm.expectRevert(
        abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, callers[i])
      );
      IHub(BABYLON_HUB).mintFeeShares(BABYLON_USDC_ASSET_ID);
      vm.expectRevert(
        abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, callers[i])
      );
      ISpoke(BABYLON_SPOKE).updatePositionManager(callers[i], true);
      vm.stopPrank();
    }
  }

  // ─── expected values ───

  /// @dev Add and draw caps in whole tokens, from the LlamaRisk parameters of 13 Nov 2026.
  function _expectedAdditions() internal pure returns (SpokeAddition[] memory additions) {
    additions = new SpokeAddition[](15);
    additions[0] = SpokeAddition(BABYLON_HUB, BABYLON_VAULT_BTC_ASSET_ID, BABYLON_SPOKE, 20, 0);
    additions[1] = SpokeAddition(
      BABYLON_HUB,
      BABYLON_USDT_ASSET_ID,
      BABYLON_SPOKE,
      5_000_000,
      250_000
    );
    additions[2] = SpokeAddition(
      BABYLON_HUB,
      BABYLON_USDC_ASSET_ID,
      BABYLON_SPOKE,
      5_000_000,
      250_000
    );
    additions[3] = SpokeAddition(
      BABYLON_HUB,
      BABYLON_GHO_ASSET_ID,
      BABYLON_SPOKE,
      1_000_000,
      100_000
    );
    additions[4] = SpokeAddition(BABYLON_HUB, BABYLON_WBTC_ASSET_ID, BABYLON_SPOKE, 100, 20);
    additions[5] = SpokeAddition(BABYLON_HUB, BABYLON_USDT_ASSET_ID, WA_BABYLON_USDT, 1_000_000, 0);
    additions[6] = SpokeAddition(BABYLON_HUB, BABYLON_USDC_ASSET_ID, WA_BABYLON_USDC, 1_000_000, 0);
    additions[7] = SpokeAddition(BABYLON_HUB, BABYLON_GHO_ASSET_ID, WA_BABYLON_GHO, 1_000_000, 0);
    additions[8] = SpokeAddition(BABYLON_HUB, BABYLON_WBTC_ASSET_ID, WA_BABYLON_WBTC, 10, 0);
    additions[9] = SpokeAddition(CORE_HUB, CORE_USDT_ASSET_ID, BABYLON_SPOKE, 0, 500_000);
    additions[10] = SpokeAddition(CORE_HUB, CORE_USDC_ASSET_ID, BABYLON_SPOKE, 0, 500_000);
    additions[11] = SpokeAddition(CORE_HUB, CORE_USDG_ASSET_ID, BABYLON_SPOKE, 0, 250_000);
    additions[12] = SpokeAddition(CORE_HUB, CORE_GHO_ASSET_ID, BABYLON_SPOKE, 0, 100_000);
    additions[13] = SpokeAddition(CORE_HUB, CORE_RLUSD_ASSET_ID, BABYLON_SPOKE, 0, 100_000);
    additions[14] = SpokeAddition(CORE_HUB, CORE_WBTC_ASSET_ID, BTC_VAULT_SWAP, 0, 20);
  }

  function _expectedReserves() internal pure returns (ExpectedReserve[] memory expected) {
    expected = new ExpectedReserve[](10);
    expected[0] = ExpectedReserve({
      hub: BABYLON_HUB,
      assetId: BABYLON_VAULT_BTC_ASSET_ID,
      underlying: VAULT_BTC,
      priceSource: BTC_USD_SVR_FEED,
      borrowable: false,
      collateralFactor: 78_00,
      maxLiquidationBonus: 105_55
    });
    expected[1] = _borrowable(BABYLON_HUB, BABYLON_USDT_ASSET_ID, USDT, USDT_FEED);
    expected[2] = _borrowable(BABYLON_HUB, BABYLON_USDC_ASSET_ID, USDC, USDC_FEED);
    expected[3] = _borrowable(BABYLON_HUB, BABYLON_GHO_ASSET_ID, GHO, GHO_FEED);
    expected[4] = _borrowable(BABYLON_HUB, BABYLON_WBTC_ASSET_ID, WBTC, WBTC_FEED);
    expected[5] = _borrowable(CORE_HUB, CORE_USDT_ASSET_ID, USDT, USDT_FEED);
    expected[6] = _borrowable(CORE_HUB, CORE_USDC_ASSET_ID, USDC, USDC_FEED);
    expected[7] = _borrowable(CORE_HUB, CORE_GHO_ASSET_ID, GHO, GHO_FEED);
    expected[8] = _borrowable(CORE_HUB, CORE_USDG_ASSET_ID, USDG, USDG_FEED);
    expected[9] = _borrowable(CORE_HUB, CORE_RLUSD_ASSET_ID, RLUSD, RLUSD_FEED);
  }

  function _borrowable(
    address hub,
    uint256 assetId,
    address underlying,
    address priceSource
  ) internal pure returns (ExpectedReserve memory) {
    return
      ExpectedReserve({
        hub: hub,
        assetId: assetId,
        underlying: underlying,
        priceSource: priceSource,
        borrowable: true,
        collateralFactor: 0,
        maxLiquidationBonus: 100_00
      });
  }

  /// @dev addAsset, updateAssetConfig, addSpoke, updateSpokeConfig, setInterestRateData,
  /// mintFeeShares, eliminateDeficit
  function _hubSelectors() internal pure returns (bytes4[] memory selectors) {
    selectors = new bytes4[](7);
    selectors[0] = 0x1e83287e;
    selectors[1] = 0x24e4c1af;
    selectors[2] = 0xc25d82fe;
    selectors[3] = 0xa2763d29;
    selectors[4] = 0xa467cc59;
    selectors[5] = 0x033a0695;
    selectors[6] = 0xbe105280;
  }

  /// @dev updateLiquidationConfig, addReserve, updateReserveConfig, updateDynamicReserveConfig,
  /// addDynamicReserveConfig, updatePositionManager, updateReservePriceSource,
  /// updateUserDynamicConfig, updateUserRiskPremium
  function _spokeSelectors() internal pure returns (bytes4[] memory selectors) {
    selectors = new bytes4[](9);
    selectors[0] = 0x87107a6d;
    selectors[1] = 0x4de8d2ba;
    selectors[2] = 0xa0f5b9ab;
    selectors[3] = 0xe903e1bd;
    selectors[4] = 0x9290fa00;
    selectors[5] = 0x9ca9c134;
    selectors[6] = 0xb2380e93;
    selectors[7] = 0x826002e2;
    selectors[8] = 0x91c46d09;
  }

  /// @dev setSwapFeeBps(uint256,uint256), pause(), unpause(), freeze(), unfreeze()
  function _btcVaultSwapSelectors() internal pure returns (bytes4[] memory selectors) {
    selectors = new bytes4[](5);
    selectors[0] = 0x1891b442;
    selectors[1] = 0x8456cb59;
    selectors[2] = 0x3f4ba83a;
    selectors[3] = 0x62a5af3b;
    selectors[4] = 0x6a28f000;
  }

  /// @dev The target each existing role gains, zero for the roles the proposal does not map.
  function _newTargetOf(uint64 role) internal pure returns (address) {
    if (
      role == HUB_CONFIGURATOR_ROLE ||
      role == HUB_FEE_MINTER_ROLE ||
      role == HUB_DEFICIT_ELIMINATOR_ROLE
    ) {
      return BABYLON_HUB;
    }
    if (role == SPOKE_CONFIGURATOR_ROLE || role == SPOKE_USER_POSITION_UPDATER_ROLE) {
      return BABYLON_SPOKE;
    }
    return address(0);
  }

  // ─── helpers ───

  function _snapshotAccessManager() internal {
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);
    uint256 roleCount = accessManager.getRoleCount();
    _roleBefore[ADMIN_ROLE] = _roleHash(ADMIN_ROLE);
    for (uint256 i; i < roleCount; ++i) {
      uint64 role = accessManager.getRole(i);
      _rolesBefore.push(role);
      _roleBefore[role] = _roleHash(role);
      uint256 targetCount = accessManager.getRoleTargetCount(role);
      for (uint256 j; j < targetCount; ++j) {
        address target = accessManager.getRoleTarget(role, j);
        _roleTargetsBefore[role].push(target);
        _roleSelectorsBefore[role][target] = _selectorsHash(role, target);
      }
    }
  }

  /// @dev Members with their delays, admin, guardian, grant delay and label of a role.
  function _roleHash(uint64 role) internal view returns (bytes32) {
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);
    uint256 memberCount = accessManager.getRoleMemberCount(role);
    bytes memory members;
    for (uint256 i; i < memberCount; ++i) {
      address member = accessManager.getRoleMember(role, i);
      (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) = accessManager
        .getAccess(role, member);
      members = abi.encode(members, member, since, currentDelay, pendingDelay, effect);
    }
    return
      keccak256(
        abi.encode(
          members,
          accessManager.getRoleAdmin(role),
          accessManager.getRoleGuardian(role),
          accessManager.getRoleGrantDelay(role),
          accessManager.isRoleLabeled(role) ? accessManager.getLabelOfRole(role) : ''
        )
      );
  }

  function _selectorsHash(uint64 role, address target) internal view returns (bytes32) {
    IAccessManagerEnumerable accessManager = IAccessManagerEnumerable(ACCESS_MANAGER);
    return
      keccak256(
        abi.encode(
          accessManager.getRoleTargetSelectors(
            role,
            target,
            0,
            accessManager.getRoleTargetSelectorCount(role, target)
          ),
          accessManager.isTargetClosed(target),
          accessManager.getTargetAdminDelay(target)
        )
      );
  }

  function _snapshotHub(IHub hub) internal {
    uint256 assetCount = hub.getAssetCount();
    _assetCountBefore[address(hub)] = assetCount;
    for (uint256 assetId; assetId < assetCount; ++assetId) {
      uint256 spokeCount = hub.getSpokeCount(assetId);
      _spokeCountBefore[address(hub)][assetId] = spokeCount;
      _spokesBefore[address(hub)][assetId] = _spokesHash(hub, assetId, spokeCount);
      _assetConfigBefore[address(hub)][assetId] = keccak256(
        abi.encode(hub.getAssetConfig(assetId))
      );
    }
  }

  /// @dev The first `count` spokes of an asset with their caps and flags.
  function _spokesHash(IHub hub, uint256 assetId, uint256 count) internal view returns (bytes32) {
    bytes memory spokes;
    for (uint256 i; i < count; ++i) {
      address spoke = hub.getSpokeAddress(assetId, i);
      spokes = abi.encode(spokes, spoke, hub.getSpokeConfig(assetId, spoke));
    }
    return keccak256(spokes);
  }

  function _spokeStateHash(ISpoke spoke) internal view returns (bytes32) {
    uint256 reserveCount = spoke.getReserveCount();
    bytes memory state = abi.encode(spoke.getLiquidationConfig(), reserveCount);
    address oracle = spoke.ORACLE();
    for (uint256 i; i < reserveCount; ++i) {
      ISpoke.Reserve memory reserve = spoke.getReserve(i);
      state = abi.encode(
        state,
        reserve.underlying,
        address(reserve.hub),
        reserve.assetId,
        reserve.collateralRisk,
        reserve.dynamicConfigKey,
        spoke.getReserveConfig(i),
        spoke.getDynamicReserveConfig(i, reserve.dynamicConfigKey),
        IAaveOracle(oracle).getReserveSource(i)
      );
    }
    return keccak256(state);
  }

  function _findAddition(
    SpokeAddition[] memory additions,
    address hub,
    uint256 assetId,
    address spoke
  ) internal pure returns (SpokeAddition memory) {
    for (uint256 i; i < additions.length; ++i) {
      if (
        additions[i].hub == hub && additions[i].assetId == assetId && additions[i].spoke == spoke
      ) {
        return additions[i];
      }
    }
    revert(string.concat('unexpected spoke added: ', vm.toString(spoke)));
  }

  function _assertSelectorRoles(
    address target,
    bytes4[] memory selectors,
    uint64[] memory roles
  ) internal view {
    assertEq(selectors.length, roles.length, 'selector and role count');
    for (uint256 i; i < selectors.length; ++i) {
      assertEq(
        IAccessManager(ACCESS_MANAGER).getTargetFunctionRole(target, selectors[i]),
        roles[i],
        string.concat('role of selector ', vm.toString(bytes32(selectors[i])))
      );
    }
  }

  function _assertAccess(uint64 role, address account, uint32 executionDelay) internal view {
    (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) = IAccessManager(
      ACCESS_MANAGER
    ).getAccess(role, account);
    assertEq(since, block.timestamp, 'member since');
    assertEq(currentDelay, executionDelay, 'execution delay');
    assertEq(pendingDelay, 0, 'pending delay');
    assertEq(effect, 0, 'pending delay effect');
  }

  function _assertReserve(uint256 reserveId, ExpectedReserve memory expected) internal view {
    ISpoke spoke = ISpoke(BABYLON_SPOKE);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    assertEq(address(reserve.hub), expected.hub, 'reserve hub');
    assertEq(reserve.assetId, expected.assetId, 'reserve asset id');
    assertEq(reserve.underlying, expected.underlying, 'reserve underlying');
    assertEq(reserve.collateralRisk, 0, 'collateral risk');

    ISpoke.ReserveConfig memory config = spoke.getReserveConfig(reserveId);
    assertEq(config.borrowable, expected.borrowable, 'borrowable');
    assertFalse(config.paused, 'paused');
    assertFalse(config.frozen, 'frozen');
    assertFalse(config.receiveSharesEnabled, 'receive shares');

    ISpoke.DynamicReserveConfig memory dynamicConfig = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );
    assertEq(dynamicConfig.collateralFactor, expected.collateralFactor, 'collateral factor');
    assertEq(dynamicConfig.maxLiquidationBonus, expected.maxLiquidationBonus, 'max bonus');
    assertEq(dynamicConfig.liquidationFee, 0, 'liquidation fee');
    assertEq(
      IAaveOracle(BABYLON_SPOKE_ORACLE).getReserveSource(reserveId),
      expected.priceSource,
      'price source'
    );
  }

  function _repeat(uint64 role, uint256 count) internal pure returns (uint64[] memory roles) {
    roles = new uint64[](count);
    for (uint256 i; i < count; ++i) {
      roles[i] = role;
    }
  }

  /// @dev A fresh fork where only some of the handover transactions were sent.
  function _partialHandover(
    bool hubAuthority,
    bool spokeAuthority,
    bool hubAdmin,
    bool spokeAdmin
  ) internal {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);
    IAccessManagerEnumerable deployment = IAccessManagerEnumerable(DEPLOYMENT_ACCESS_MANAGER);
    vm.startPrank(DEPLOYER);
    if (hubAdmin) IOwnable(BABYLON_HUB_PROXY_ADMIN).transferOwnership(V4_SECURITY_COUNCIL);
    if (spokeAdmin) IOwnable(BABYLON_SPOKE_PROXY_ADMIN).transferOwnership(V4_SECURITY_COUNCIL);
    if (hubAuthority) deployment.updateAuthority(BABYLON_HUB, ACCESS_MANAGER);
    if (spokeAuthority) deployment.updateAuthority(BABYLON_SPOKE, ACCESS_MANAGER);
    vm.stopPrank();
    proposal = new AaveV4Ethereum_OnboardNativeBTCViaBabylon_20261119();
  }

  /// @dev The PayloadsController reverts when the payload does, and nothing is connected.
  function _expectGovernanceExecutionReverts() internal {
    try this.executePayloadThroughGovernance() {
      fail('payload executed');
    } catch {}
    assertFalse(
      IHub(BABYLON_HUB).isSpokeListed(BABYLON_VAULT_BTC_ASSET_ID, BABYLON_SPOKE),
      'spoke listed'
    );
    assertFalse(
      IAccessManagerEnumerable(ACCESS_MANAGER).isRole(BTC_VAULT_SWAP_FEE_ROLE),
      'fee role created'
    );
  }

  function executePayloadThroughGovernance() external {
    _executePayload();
  }

  function _payloadsController() internal view returns (address) {
    return address(GovV3Helpers.getPayloadsController(block.chainid));
  }
}
