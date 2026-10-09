// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Monad, AaveV3MonadAssets, AaveV3MonadEModes} from 'aave-address-book/AaveV3Monad.sol';
import {MiscMonad} from 'aave-address-book/MiscMonad.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002} from './AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';
import {IAgentHub} from '../interfaces/IAgentHub.sol';
import {IBaseAaveAgent, IAaveDiscountRateAgent} from '../interfaces/IBaseAaveAgent.sol';
import {IPendlePriceCapAdapter} from '../interfaces/IPendlePriceCapAdapter.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';

/**
 * @dev Test for AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261002_AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle/AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002.t.sol -vv
 * forge-config: default.networks.network = "monad"
 * forge-config: default.hardfork = "monad:MonadTen"
 */
contract AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002_Test is ProtocolV3TestBase {
  AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002 internal proposal;

  uint256 internal discountAgentId;
  uint256 internal eModeAgentId;

  uint256 internal constant FORK_BLOCK = 111800000;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('monad'), FORK_BLOCK);
    proposal = new AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002();

    uint256 startCount = IAgentHub(MiscMonad.AGENT_HUB).getAgentCount();
    discountAgentId = startCount;
    eModeAgentId = startCount + 1;
  }

  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002',
      AaveV3Monad.POOL,
      address(proposal)
    );
  }

  /// @dev The payload touches no reserve configuration at all: it registers agents and grants a
  ///      role. Asserting the empty diff is what proves that.
  function test_reserveConfigChanges() public {
    ReserveConfig[] memory allConfigsBefore = createConfigurationSnapshot(
      'preAaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002',
      AaveV3Monad.POOL
    );

    executePayload(vm, address(proposal));

    ReserveConfig[] memory allConfigsAfter = createConfigurationSnapshot(
      'postAaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002',
      AaveV3Monad.POOL
    );

    diffReports(
      'preAaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002',
      'postAaveV3Monad_Onboard_PTAUSD17DEC2026_Oracle_20261002'
    );

    _noReservesConfigsChangesApartNewListings(allConfigsBefore, allConfigsAfter);
  }

  /// @dev Both agents are pre-deployed. Their immutable dependencies are checked before the payload
  ///      registers their addresses in the AgentHub.
  function test_agentsPredeployedAndWired() public {
    IAgentHub hub = IAgentHub(MiscMonad.AGENT_HUB);
    IAaveDiscountRateAgent discountAgent = IAaveDiscountRateAgent(
      MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT
    );
    IBaseAaveAgent eModeAgent = IBaseAaveAgent(MiscMonad.LLAMARISK_PT_EMODE_AGENT);

    assertGt(
      MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT.code.length,
      0,
      'discount agent has no code'
    );
    assertGt(MiscMonad.LLAMARISK_PT_EMODE_AGENT.code.length, 0, 'eMode agent has no code');

    assertEq(discountAgent.AGENT_HUB(), MiscMonad.AGENT_HUB);
    assertEq(discountAgent.RANGE_VALIDATION_MODULE(), MiscMonad.RANGE_VALIDATION_MODULE);
    assertEq(discountAgent.POOL(), address(AaveV3Monad.POOL));
    assertEq(discountAgent.AAVE_ORACLE(), address(AaveV3Monad.ORACLE));
    assertEq(discountAgent.getUpdateType(), AgentHubConfigs.DISCOUNT_UPDATE_TYPE);

    assertEq(eModeAgent.AGENT_HUB(), MiscMonad.AGENT_HUB);
    assertEq(eModeAgent.RANGE_VALIDATION_MODULE(), MiscMonad.RANGE_VALIDATION_MODULE);
    assertEq(eModeAgent.POOL(), address(AaveV3Monad.POOL));
    assertEq(eModeAgent.getUpdateType(), AgentHubConfigs.EMODE_UPDATE_TYPE);

    executePayload(vm, address(proposal));

    assertEq(hub.getAgentAddress(discountAgentId), MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT);
    assertEq(hub.getAgentAddress(eModeAgentId), MiscMonad.LLAMARISK_PT_EMODE_AGENT);
    assertEq(discountAgent.getUpdateType(), hub.getUpdateType(discountAgentId));
    assertEq(eModeAgent.getUpdateType(), hub.getUpdateType(eModeAgentId));
  }

  function test_agentsRegisteredAndRiskAdminGranted() public {
    IAgentHub hub = IAgentHub(MiscMonad.AGENT_HUB);
    uint256 countBefore = hub.getAgentCount();

    executePayload(vm, address(proposal));

    assertEq(hub.getAgentCount(), countBefore + 2, 'expected exactly two new agents');

    // Discount agent.
    assertTrue(hub.isAgentEnabled(discountAgentId), 'discount agent not enabled');
    assertEq(hub.getRiskOracle(discountAgentId), MiscMonad.LLAMARISK_RISK_ORACLE);
    assertEq(hub.getUpdateType(discountAgentId), AgentHubConfigs.DISCOUNT_UPDATE_TYPE);
    assertEq(hub.getAgentAdmin(discountAgentId), MiscMonad.PROTOCOL_GUARDIAN);
    assertEq(hub.getAgentAddress(discountAgentId), MiscMonad.LLAMARISK_PT_DISCOUNT_RATE_AGENT);
    assertEq(hub.getExpirationPeriod(discountAgentId), AgentHubConfigs.DISCOUNT_EXPIRATION_PERIOD);
    assertEq(hub.getMinimumDelay(discountAgentId), AgentHubConfigs.DISCOUNT_MINIMUM_DELAY);
    assertEq(hub.getAgentContext(discountAgentId), bytes(''));
    assertFalse(hub.isAgentPermissioned(discountAgentId));
    assertFalse(hub.isMarketsFromAgentEnabled(discountAgentId));
    assertEq(hub.getRestrictedMarkets(discountAgentId).length, 0);
    assertEq(hub.getPermissionedSenders(discountAgentId).length, 0);

    address[] memory discountMarkets = hub.getAllowedMarkets(discountAgentId);
    assertEq(discountMarkets.length, 1, 'discount agent should allow one market');
    assertEq(discountMarkets[0], AaveV3MonadAssets.PT_AUSD_17DEC2026_UNDERLYING);

    // eMode agent
    assertTrue(hub.isAgentEnabled(eModeAgentId), 'eMode agent not enabled');
    assertEq(hub.getRiskOracle(eModeAgentId), MiscMonad.LLAMARISK_RISK_ORACLE);
    assertEq(hub.getUpdateType(eModeAgentId), AgentHubConfigs.EMODE_UPDATE_TYPE);
    assertEq(hub.getAgentAdmin(eModeAgentId), MiscMonad.PROTOCOL_GUARDIAN);
    assertEq(hub.getAgentAddress(eModeAgentId), MiscMonad.LLAMARISK_PT_EMODE_AGENT);
    assertEq(hub.getExpirationPeriod(eModeAgentId), AgentHubConfigs.EMODE_EXPIRATION_PERIOD);
    assertEq(hub.getMinimumDelay(eModeAgentId), AgentHubConfigs.EMODE_MINIMUM_DELAY);
    assertFalse(hub.isAgentPermissioned(eModeAgentId));
    assertFalse(hub.isMarketsFromAgentEnabled(eModeAgentId));
    assertEq(hub.getRestrictedMarkets(eModeAgentId).length, 0);
    assertEq(hub.getPermissionedSenders(eModeAgentId).length, 0);

    // The delegatecall target the eMode agent decodes from its context. A wrong engine here is the
    // difference between an injection landing and reverting.
    assertEq(
      abi.decode(hub.getAgentContext(eModeAgentId), (address)),
      AaveV3Monad.CONFIG_ENGINE,
      'eMode agent context is not the current config engine'
    );

    address[] memory eModeMarkets = hub.getAllowedMarkets(eModeAgentId);
    assertEq(eModeMarkets.length, 1, 'eMode agent should allow one category');
    assertEq(
      eModeMarkets[0],
      address(uint160(AaveV3MonadEModes.PT_AUSD_17DEC2026__USDT0_USDC_USDe_mUSD_GHO))
    );

    // Without the role neither agent can write: the discount one is rejected by the
    // PendlePriceCapAdapter, the eMode one by the PoolConfigurator.
    assertTrue(
      AaveV3Monad.ACL_MANAGER.isRiskAdmin(hub.getAgentAddress(discountAgentId)),
      'discount agent is not a risk admin'
    );
    assertTrue(
      AaveV3Monad.ACL_MANAGER.isRiskAdmin(hub.getAgentAddress(eModeAgentId)),
      'eMode agent is not a risk admin'
    );
  }

  function test_e2eAgentsInjectRiskOracleUpdates() public {
    executePayload(vm, address(proposal));

    IAgentHub hub = IAgentHub(MiscMonad.AGENT_HUB);
    address pt = AaveV3MonadAssets.PT_AUSD_17DEC2026_UNDERLYING;
    IPendlePriceCapAdapter adapter = IPendlePriceCapAdapter(
      AaveV3Monad.ORACLE.getSourceOfAsset(pt)
    );
    uint256 newDiscountRate = adapter.discountRatePerYear() +
      AgentHubConfigs.DISCOUNT_RANGE_ABS /
      2;

    uint8 eModeCategory = AaveV3MonadEModes.PT_AUSD_17DEC2026__USDT0_USDC_USDe_mUSD_GHO;
    address eModeMarket = address(uint160(eModeCategory));
    DataTypes.CollateralConfig memory eModeBefore = AaveV3Monad
      .POOL
      .getEModeCategoryCollateralConfig(eModeCategory);
    bool isolatedBefore = AaveV3Monad.POOL.getIsEModeCategoryIsolated(eModeCategory);
    uint256 newLtv = eModeBefore.ltv - 10;
    uint256 newLiquidationThreshold = eModeBefore.liquidationThreshold - 10;
    uint256 newLiquidationBonus = eModeBefore.liquidationBonus - 100_00 - 10;

    _publishUpdate(AgentHubConfigs.DISCOUNT_UPDATE_TYPE, pt, abi.encodePacked(newDiscountRate));
    _publishUpdate(
      AgentHubConfigs.EMODE_UPDATE_TYPE,
      eModeMarket,
      abi.encode(newLtv, newLiquidationThreshold, newLiquidationBonus)
    );

    uint256[] memory agentIds = new uint256[](2);
    agentIds[0] = discountAgentId;
    agentIds[1] = eModeAgentId;

    (bool shouldExecute, IAgentHub.ActionData[] memory actions) = hub.check(agentIds);
    assertTrue(shouldExecute);
    assertEq(actions.length, 2);
    assertEq(actions[0].agentId, discountAgentId);
    assertEq(actions[0].markets.length, 1);
    assertEq(actions[0].markets[0], pt);
    assertEq(actions[1].agentId, eModeAgentId);
    assertEq(actions[1].markets.length, 1);
    assertEq(actions[1].markets[0], eModeMarket);

    hub.execute(actions);

    assertEq(adapter.discountRatePerYear(), newDiscountRate);
    DataTypes.CollateralConfig memory eModeAfter = AaveV3Monad
      .POOL
      .getEModeCategoryCollateralConfig(eModeCategory);
    assertEq(eModeAfter.ltv, newLtv);
    assertEq(eModeAfter.liquidationThreshold, newLiquidationThreshold);
    assertEq(eModeAfter.liquidationBonus, newLiquidationBonus + 100_00);
    assertEq(AaveV3Monad.POOL.getIsEModeCategoryIsolated(eModeCategory), isolatedBefore);

    vm.expectRevert(IAgentHub.NoActionCanBePerformed.selector);
    hub.execute(actions);
  }

  function test_revertOutOfRangeDiscountUpdate() public {
    executePayload(vm, address(proposal));

    IAgentHub hub = IAgentHub(MiscMonad.AGENT_HUB);
    address pt = AaveV3MonadAssets.PT_AUSD_17DEC2026_UNDERLYING;
    IPendlePriceCapAdapter adapter = IPendlePriceCapAdapter(
      AaveV3Monad.ORACLE.getSourceOfAsset(pt)
    );

    _publishUpdate(
      AgentHubConfigs.DISCOUNT_UPDATE_TYPE,
      pt,
      abi.encodePacked(adapter.discountRatePerYear() + AgentHubConfigs.DISCOUNT_RANGE_ABS + 1)
    );

    uint256[] memory agentIds = new uint256[](1);
    agentIds[0] = discountAgentId;
    (bool shouldExecute, ) = hub.check(agentIds);
    assertFalse(shouldExecute);

    address[] memory markets = new address[](1);
    markets[0] = pt;
    IAgentHub.ActionData[] memory actions = new IAgentHub.ActionData[](1);
    actions[0] = IAgentHub.ActionData({agentId: discountAgentId, markets: markets});

    vm.expectRevert(IAgentHub.NoActionCanBePerformed.selector);
    hub.execute(actions);
  }

  /// @dev A fresh agent id inherits no default range config, and the module reads a missing config
  ///      as a zero bound, which rejects every injection. So an unset range is not a loose stack,
  ///      it is a dead one, and this is the assertion that catches a forgotten call.
  function test_rangeConfiguration() public {
    executePayload(vm, address(proposal));

    _assertAbsoluteRange(
      discountAgentId,
      AgentHubConfigs.DISCOUNT_UPDATE_TYPE,
      AgentHubConfigs.DISCOUNT_RANGE_ABS
    );
    _assertAbsoluteRange(eModeAgentId, 'EModeLTV', AgentHubConfigs.EMODE_RANGE_ABS_BPS);
    _assertAbsoluteRange(
      eModeAgentId,
      'EModeLiquidationThreshold',
      AgentHubConfigs.EMODE_RANGE_ABS_BPS
    );
    _assertAbsoluteRange(
      eModeAgentId,
      'EModeLiquidationBonus',
      AgentHubConfigs.EMODE_RANGE_ABS_BPS
    );
  }

  function _assertAbsoluteRange(
    uint256 agentId,
    string memory updateType,
    uint120 expected
  ) internal view {
    IRangeValidationModule.RangeConfig memory config = IRangeValidationModule(
      MiscMonad.RANGE_VALIDATION_MODULE
    ).getDefaultRangeConfig(MiscMonad.AGENT_HUB, agentId, updateType);

    assertEq(config.maxIncrease, expected, 'unexpected maxIncrease');
    assertEq(config.maxDecrease, expected, 'unexpected maxDecrease');
    // Absolute, because a relative cap is measured against a previous injection that a fresh id
    // does not have, which would leave the first one unbounded.
    assertFalse(config.isIncreaseRelative, 'increase should be absolute');
    assertFalse(config.isDecreaseRelative, 'decrease should be absolute');
  }

  function _publishUpdate(
    string memory updateType,
    address market,
    bytes memory newValue
  ) internal {
    IRiskOracle riskOracle = IRiskOracle(MiscMonad.LLAMARISK_RISK_ORACLE);
    vm.prank(MiscMonad.LLAMARISK_RISK_ORACLE_ROUTER);
    riskOracle.publishRiskParameterUpdate('e2e-test', newValue, updateType, market, bytes(''));
  }
}
