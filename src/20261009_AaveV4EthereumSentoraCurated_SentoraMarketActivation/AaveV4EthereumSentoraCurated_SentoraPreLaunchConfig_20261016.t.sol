// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IHub, ISpoke} from 'aave-address-book/AaveV4.sol';
import {IExecutor} from 'aave-address-book/governance-v3/IExecutor.sol';
import {IAccessManager} from 'aave-v4/dependencies/openzeppelin/IAccessManager.sol';
import {IOwnable} from 'aave-address-book/common/IOwnable.sol';
import {AaveV4EthereumSentoraCuratedAssets as Assets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {SentoraTestBase} from './SentoraTestBase.sol';
import {SentoraPreLaunchCouncilCalls} from './SentoraPreLaunchCouncilCalls.sol';

/// @dev Stand-in for the Council Safe's own DELEGATECALL into MultiSendCallOnly.
contract DelegateCaller {
  function delegate(address target, bytes calldata data) external {
    (bool success, bytes memory result) = target.delegatecall(data);
    if (!success) {
      assembly {
        revert(add(result, 32), mload(result))
      }
    }
  }
}

/**
 * @dev Test for AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016, run the way the V4
 *      Security Council will: role grants from the Council Safe, then its Executor delegatecalls the
 *      payload. Expected values come from STATE.md "Pre-launch config update".
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261009_AaveV4EthereumSentoraCurated_SentoraMarketActivation/AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016.t.sol -vv
 */
contract AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016_Test is SentoraTestBase {
  struct Pair {
    uint256 assetId;
    address spoke;
    IHub.SpokeConfig config;
  }

  struct ReserveState {
    ISpoke spoke;
    uint256 reserveId;
    ISpoke.Reserve reserve;
    ISpoke.ReserveConfig config;
    ISpoke.DynamicReserveConfig dynamicConfig;
  }

  struct State {
    Pair[] pairs;
    ReserveState[] reserves;
    IHub.AssetConfig[] assets;
    uint64[] roles;
    uint256[] memberCounts;
  }

  function setUp() public override {
    _fork();
  }

  function test_councilExecutorBeforeConfig() public view {
    assertEq(IOwnable(COUNCIL_EXECUTOR).owner(), SECURITY_COUNCIL, 'executor owner');
    uint64[4] memory roles = SentoraPreLaunchCouncilCalls.roles();
    for (uint256 i; i < roles.length; ++i) {
      (bool isMember, ) = ACCESS_MANAGER.hasRole(roles[i], COUNCIL_EXECUTOR);
      assertFalse(isMember, 'role before grant');
    }
    (bool isAdmin, ) = ACCESS_MANAGER.hasRole(ADMIN_ROLE, EXECUTOR_LVL_1);
    assertFalse(isAdmin, 'lvl1 admin before grant');
  }

  function test_revertsBeforeRolesGranted() public {
    vm.prank(SECURITY_COUNCIL);
    vm.expectRevert(bytes('29'));
    IExecutor(COUNCIL_EXECUTOR).executeTransaction(preLaunchConfig, 0, 'execute()', '', true);
  }

  function test_councilCalls() public view {
    SentoraPreLaunchCouncilCalls.Call[] memory calls = SentoraPreLaunchCouncilCalls.calls(
      preLaunchConfig
    );
    uint64[4] memory roles = SentoraPreLaunchCouncilCalls.roles();
    assertEq(calls.length, 6, 'calls');
    for (uint256 i; i < roles.length; ++i) {
      assertEq(calls[i].to, address(ACCESS_MANAGER), 'grant target');
      assertEq(
        calls[i].data,
        abi.encodeWithSignature('grantRole(uint64,address,uint32)', roles[i], COUNCIL_EXECUTOR, 0),
        'grant calldata'
      );
    }
    assertEq(calls[4].to, COUNCIL_EXECUTOR, 'execute target');
    assertEq(
      calls[4].data,
      abi.encodeWithSignature(
        'executeTransaction(address,uint256,string,bytes,bool)',
        preLaunchConfig,
        0,
        'execute()',
        '',
        true
      ),
      'execute calldata'
    );
    assertEq(calls[5].to, address(ACCESS_MANAGER), 'admin grant target');
    assertEq(bytes4(calls[5].data), IAccessManager.grantRole.selector, 'admin grant selector');
    assertEq(
      calls[5].data,
      abi.encodeWithSignature('grantRole(uint64,address,uint32)', 0, EXECUTOR_LVL_1, 0),
      'admin grant calldata'
    );
  }

  /// @dev Unpacks the MultiSendCallOnly batch: each entry is a CALL with value 0 carrying the
  /// Council call at the same index.
  function test_multiSendBatch() public view {
    SentoraPreLaunchCouncilCalls.Call[] memory calls = SentoraPreLaunchCouncilCalls.calls(
      preLaunchConfig
    );
    bytes memory batch = SentoraPreLaunchCouncilCalls.multiSend(preLaunchConfig);
    assertEq(bytes4(batch), bytes4(keccak256('multiSend(bytes)')), 'multiSend selector');
    bytes memory transactions = abi.decode(_slice(batch, 4, batch.length - 4), (bytes));

    uint256 offset;
    uint256 n;
    while (offset < transactions.length) {
      assertEq(uint8(transactions[offset]), 0, 'operation');
      assertEq(address(bytes20(_slice(transactions, offset + 1, 20))), calls[n].to, 'to');
      assertEq(uint256(bytes32(_slice(transactions, offset + 21, 32))), 0, 'value');
      uint256 dataLength = uint256(bytes32(_slice(transactions, offset + 53, 32)));
      assertEq(_slice(transactions, offset + 85, dataLength), calls[n].data, 'data');
      offset += 85 + dataLength;
      ++n;
    }
    assertEq(offset, transactions.length, 'batch length');
    assertEq(n, 6, 'batch calls');
  }

  function test_preLaunchConfig() public {
    State memory before = _state();
    _applyPreLaunchConfig();
    _assertConfigApplied(before);
  }

  /// @dev Same six calls as one Safe batch through MultiSendCallOnly v1.4.1, which runs each as a
  /// CALL from the Safe.
  function test_preLaunchConfigThroughMultiSendCallOnly() public {
    assertGt(SentoraPreLaunchCouncilCalls.MULTI_SEND_CALL_ONLY.code.length, 0, 'multisend code');
    State memory before = _state();
    vm.etch(SECURITY_COUNCIL, address(new DelegateCaller()).code);
    DelegateCaller(SECURITY_COUNCIL).delegate(
      SentoraPreLaunchCouncilCalls.MULTI_SEND_CALL_ONLY,
      SentoraPreLaunchCouncilCalls.multiSend(preLaunchConfig)
    );
    _assertConfigApplied(before);
  }

  function test_activationAfterConfig() public {
    _applyPreLaunchConfig();
    _activate();
    uint256 assetCount = HUB.getAssetCount();
    for (uint256 assetId; assetId < assetCount; ++assetId) {
      uint256 spokeCount = HUB.getSpokeCount(assetId);
      for (uint256 i; i < spokeCount; ++i) {
        assertFalse(
          HUB.getSpokeConfig(assetId, HUB.getSpokeAddress(assetId, i)).halted,
          'unhalted'
        );
      }
    }
    uint256 mWinId = HUB.getAssetId(Assets.mWIN_UNDERLYING);
    for (uint256 i; i < HUB.getSpokeCount(mWinId); ++i) {
      IHub.SpokeConfig memory config = HUB.getSpokeConfig(mWinId, HUB.getSpokeAddress(mWinId, i));
      assertFalse(config.active, 'mWIN inactive');
      assertEq(config.addCap, 0, 'mWIN add cap');
    }
    assertEq(_pairConfig(Assets.PST_UNDERLYING, address(RLUSD_YIELD)).addCap, 0, 'PST cap');
    assertEq(_pairConfig(Assets.PRIME_UNDERLYING, address(OUSD_YIELD)).addCap, 0, 'PRIME cap');
  }

  function _assertConfigApplied(State memory before) internal view {
    State memory current = _state();
    uint256 mWinId = HUB.getAssetId(Assets.mWIN_UNDERLYING);
    uint256 pstId = HUB.getAssetId(Assets.PST_UNDERLYING);
    uint256 primeId = HUB.getAssetId(Assets.PRIME_UNDERLYING);

    assertEq(current.pairs.length, before.pairs.length, 'pairs');
    for (uint256 i; i < current.pairs.length; ++i) {
      Pair memory pair = current.pairs[i];
      IHub.SpokeConfig memory expected = before.pairs[i].config;
      assertEq(pair.spoke, before.pairs[i].spoke, 'pair spoke');
      bool reservePair = pair.spoke == address(RLUSD_YIELD) || pair.spoke == address(OUSD_YIELD);
      if (pair.assetId == mWinId) {
        expected.active = false;
        expected.addCap = 0;
        expected.drawCap = 0;
      } else if ((pair.assetId == pstId || pair.assetId == primeId) && reservePair) {
        expected.addCap = 0;
        expected.drawCap = 0;
      }
      _assertSpokeConfig(pair.config, expected);
    }

    for (uint256 i; i < current.reserves.length; ++i) {
      ReserveState memory reserve = current.reserves[i];
      ISpoke.ReserveConfig memory expected = before.reserves[i].config;
      ISpoke.Reserve memory reserveData = reserve.reserve;
      if (reserveData.assetId == mWinId) {
        expected.paused = true;
        // the packed flags carry the paused bit, already checked through the reserve config
        reserveData.flags = before.reserves[i].reserve.flags;
      }
      assertEq(abi.encode(reserve.config), abi.encode(expected), 'reserve config');
      assertEq(abi.encode(reserveData), abi.encode(before.reserves[i].reserve), 'reserve');
      assertEq(
        abi.encode(reserve.dynamicConfig),
        abi.encode(before.reserves[i].dynamicConfig),
        'dynamic config'
      );
    }

    assertEq(abi.encode(current.assets), abi.encode(before.assets), 'asset configs');

    _assertLiquidationConfig(RLUSD_YIELD, 1.047e18);
    _assertLiquidationConfig(OUSD_YIELD, 1.047e18);
    _assertLiquidationConfig(BLUECHIP, 1.143e18);

    uint64[4] memory granted = SentoraPreLaunchCouncilCalls.roles();
    for (uint256 i; i < granted.length; ++i) {
      (bool isMember, uint32 executionDelay) = ACCESS_MANAGER.hasRole(granted[i], COUNCIL_EXECUTOR);
      assertTrue(isMember, 'executor role');
      assertEq(executionDelay, 0, 'execution delay');
    }
    (bool isAdmin, uint32 adminDelay) = ACCESS_MANAGER.hasRole(ADMIN_ROLE, EXECUTOR_LVL_1);
    assertTrue(isAdmin, 'lvl1 admin');
    assertEq(adminDelay, 0, 'lvl1 admin execution delay');
    (bool councilIsAdmin, ) = ACCESS_MANAGER.hasRole(ADMIN_ROLE, SECURITY_COUNCIL);
    assertTrue(councilIsAdmin, 'council admin');
    for (uint256 i; i < granted.length; ++i) {
      (bool isMember, ) = ACCESS_MANAGER.hasRole(granted[i], EXECUTOR_LVL_1);
      assertFalse(isMember, 'lvl1 role');
    }
    for (uint256 i; i < current.roles.length; ++i) {
      bool isGranted = current.roles[i] == ADMIN_ROLE ||
        current.roles[i] == granted[0] ||
        current.roles[i] == granted[1] ||
        current.roles[i] == granted[2] ||
        current.roles[i] == granted[3];
      assertEq(
        current.memberCounts[i],
        before.memberCounts[i] + (isGranted ? 1 : 0),
        'role member count'
      );
    }
  }

  function _slice(
    bytes memory data,
    uint256 start,
    uint256 length
  ) internal pure returns (bytes memory slice) {
    slice = new bytes(length);
    for (uint256 i; i < length; ++i) slice[i] = data[start + i];
  }

  function _assertSpokeConfig(
    IHub.SpokeConfig memory actual,
    IHub.SpokeConfig memory expected
  ) internal pure {
    assertEq(actual.addCap, expected.addCap, 'add cap');
    assertEq(actual.drawCap, expected.drawCap, 'draw cap');
    assertEq(actual.riskPremiumThreshold, expected.riskPremiumThreshold, 'threshold');
    assertEq(actual.active, expected.active, 'active');
    assertEq(actual.halted, expected.halted, 'halted');
  }

  function _assertLiquidationConfig(ISpoke spoke, uint256 targetHealthFactor) internal view {
    ISpoke.LiquidationConfig memory config = spoke.getLiquidationConfig();
    assertEq(config.targetHealthFactor, targetHealthFactor, 'target health factor');
    assertEq(config.healthFactorForMaxBonus, 0.99e18, 'health factor for max bonus');
    assertEq(config.liquidationBonusFactor, 100_00, 'liquidation bonus factor');
  }

  function _pairConfig(
    address underlying,
    address spoke
  ) internal view returns (IHub.SpokeConfig memory) {
    return HUB.getSpokeConfig(HUB.getAssetId(underlying), spoke);
  }

  /// @dev Every Hub pair, reserve, asset config and role count, in a fixed order.
  function _state() internal view returns (State memory s) {
    uint256 assetCount = HUB.getAssetCount();
    assertEq(assetCount, ASSET_COUNT, 'asset count');
    s.pairs = new Pair[](SPOKE_PAIR_COUNT);
    s.assets = new IHub.AssetConfig[](assetCount);
    uint256 n;
    for (uint256 assetId; assetId < assetCount; ++assetId) {
      s.assets[assetId] = HUB.getAssetConfig(assetId);
      uint256 spokeCount = HUB.getSpokeCount(assetId);
      for (uint256 i; i < spokeCount; ++i) {
        address spoke = HUB.getSpokeAddress(assetId, i);
        // the TreasurySpoke and the three Spokes are the only Hub spokes: no tokenization spoke
        assertTrue(
          spoke == address(TREASURY_SPOKE) ||
            spoke == address(RLUSD_YIELD) ||
            spoke == address(OUSD_YIELD) ||
            spoke == address(BLUECHIP),
          'unknown hub spoke'
        );
        s.pairs[n++] = Pair(assetId, spoke, HUB.getSpokeConfig(assetId, spoke));
      }
    }
    assertEq(n, SPOKE_PAIR_COUNT, 'pair count');

    ISpoke[] memory spokes = _spokes();
    s.reserves = new ReserveState[](14);
    n = 0;
    for (uint256 i; i < spokes.length; ++i) {
      uint256 reserveCount = spokes[i].getReserveCount();
      for (uint256 reserveId; reserveId < reserveCount; ++reserveId) {
        ISpoke.Reserve memory reserve = spokes[i].getReserve(reserveId);
        s.reserves[n++] = ReserveState({
          spoke: spokes[i],
          reserveId: reserveId,
          reserve: reserve,
          config: spokes[i].getReserveConfig(reserveId),
          dynamicConfig: spokes[i].getDynamicReserveConfig(reserveId, reserve.dynamicConfigKey)
        });
      }
    }
    assertEq(n, 14, 'reserve count');

    uint256 roleCount = ACCESS_MANAGER.getRoleCount();
    s.roles = new uint64[](roleCount + 1);
    s.memberCounts = new uint256[](roleCount + 1);
    s.memberCounts[0] = ACCESS_MANAGER.getRoleMemberCount(ADMIN_ROLE);
    for (uint256 i; i < roleCount; ++i) {
      s.roles[i + 1] = ACCESS_MANAGER.getRole(i);
      s.memberCounts[i + 1] = ACCESS_MANAGER.getRoleMemberCount(s.roles[i + 1]);
    }
  }
}
