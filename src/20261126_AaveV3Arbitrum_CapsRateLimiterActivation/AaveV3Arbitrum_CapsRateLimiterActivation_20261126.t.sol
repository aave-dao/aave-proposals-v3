// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {GovV3Helpers, IPayloadsControllerCore} from 'aave-helpers/src/GovV3Helpers.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {AaveV3Arbitrum_CapsRateLimiterActivation_20261126, ArbitrumLlamaGuardCaps} from './AaveV3Arbitrum_CapsRateLimiterActivation_20261126.sol';
import {IOwnable} from 'aave-address-book/common/IOwnable.sol';
import {IAgentHub, IAgentConfigurator} from '../interfaces/chaos-agents/IAgentHub.sol';
import {IBaseAaveAgent} from '../interfaces/IBaseAaveAgent.sol';
import {ICapsRangeValidationModule as IRvm} from '../interfaces/ICapsRangeValidationModule.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';
import {IOwnable2Step} from '../interfaces/IOwnable2Step.sol';

/**
 * @dev Test for AaveV3Arbitrum_CapsRateLimiterActivation_20261126
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261126_AaveV3Arbitrum_CapsRateLimiterActivation/AaveV3Arbitrum_CapsRateLimiterActivation_20261126.t.sol -vv
 */
contract AaveV3Arbitrum_CapsRateLimiterActivation_20261126_Test is ProtocolV3TestBase {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Arbitrum_CapsRateLimiterActivation_20261126 internal proposal;

  address internal constant RISK_COUNCIL = 0x3Be327F22eB4BD8042e6944073b8826dCf357Aa2;

  IAgentHub internal constant HUB = IAgentHub(MiscArbitrum.AGENT_HUB);
  address internal constant ROUTER = ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE_ROUTER;

  struct Entry {
    address asset;
    uint64 maxCap; // 0: the borrow cap at execution
    uint64 maxHeadroom;
  }

  uint256 internal raiseAgentId;
  uint256 internal cutAgentId;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 527792680);
    proposal = new AaveV3Arbitrum_CapsRateLimiterActivation_20261126();

    uint256 startCount = HUB.getAgentCount();
    raiseAgentId = startCount;
    cutAgentId = startCount + 1;
  }

  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_CapsRateLimiterActivation_20261126',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /// @dev The payload registers agents and lists reserves in the module; no reserve configuration moves.
  function test_reserveConfigChanges() public {
    ReserveConfig[] memory allConfigsBefore = createConfigurationSnapshot(
      'preAaveV3Arbitrum_CapsRateLimiterActivation_20261126',
      AaveV3Arbitrum.POOL
    );

    executePayload(vm, address(proposal));

    ReserveConfig[] memory allConfigsAfter = createConfigurationSnapshot(
      'postAaveV3Arbitrum_CapsRateLimiterActivation_20261126',
      AaveV3Arbitrum.POOL
    );

    diffReports(
      'preAaveV3Arbitrum_CapsRateLimiterActivation_20261126',
      'postAaveV3Arbitrum_CapsRateLimiterActivation_20261126'
    );

    _noReservesConfigsChangesApartNewListings(allConfigsBefore, allConfigsAfter);
  }

  /// @dev The agent ids the workflow configs name.
  function test_agentIdsAreTheExpectedOnes() public view {
    assertEq(raiseAgentId, proposal.RAISE_AGENT_ID(), 'raise agent id');
    assertEq(cutAgentId, proposal.CUT_AGENT_ID(), 'cut agent id');
  }

  /// @dev Bytecode and immutable wiring of the predeployed contracts, and their owners.
  function test_contractsPredeployedAndWired() public view {
    address rvm = ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RANGE_VALIDATION_MODULE;
    address[2] memory agents = [
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RAISE_AGENT,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_CUT_AGENT
    ];
    for (uint256 i; i < agents.length; ++i) {
      IBaseAaveAgent agent = IBaseAaveAgent(agents[i]);
      assertGt(agents[i].code.length, 0, 'agent has no code');
      assertEq(agent.AGENT_HUB(), MiscArbitrum.AGENT_HUB);
      assertEq(agent.RANGE_VALIDATION_MODULE(), rvm);
      assertEq(agent.POOL(), address(AaveV3Arbitrum.POOL));
      assertEq(agent.getUpdateType(), proposal.UPDATE_TYPE());
    }

    assertGt(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_REDUCER_ORACLE.code.length, 0, 'no reducer');
    assertEq(IRvm(rvm).AGENT_HUB(), MiscArbitrum.AGENT_HUB);
    assertEq(IRvm(rvm).POOL(), address(AaveV3Arbitrum.POOL));
    assertEq(IRvm(rvm).riskCouncil(), RISK_COUNCIL);
    assertEq(IOwnable(rvm).owner(), GovernanceV3Arbitrum.EXECUTOR_LVL_1);
    assertGt(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_BORROW_FORWARDER.code.length, 0, 'no forwarder');
    assertEq(
      IOwnable(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_BORROW_FORWARDER).owner(),
      GovernanceV3Arbitrum.EXECUTOR_LVL_1
    );

    address admin = ArbitrumLlamaGuardCaps.LLAMARISK_RISK_ORACLE_ADMIN_SAFE;
    // Two-step: the admin Safe accepts before the AIP executes; until then it is the pending owner.
    assertTrue(
      IOwnable2Step(ROUTER).owner() == admin || IOwnable2Step(ROUTER).pendingOwner() == admin,
      'Router owner'
    );
    assertEq(IOwnable(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE).owner(), admin);
    assertEq(
      IOwnable(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_PARAMETER_REGISTRY).owner(),
      GovernanceV3Arbitrum.EXECUTOR_LVL_1
    );
  }

  function test_agentsRegisteredAndRiskAdminGranted() public {
    uint256 countBefore = HUB.getAgentCount();

    executePayload(vm, address(proposal));

    assertEq(HUB.getAgentCount(), countBefore + 2, 'expected exactly two new agents');
    // The forwarder raises caps through the config engine too.
    assertTrue(
      AaveV3Arbitrum.ACL_MANAGER.isRiskAdmin(
        ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_BORROW_FORWARDER
      ),
      'forwarder is not a risk admin'
    );
    _assertAgent(
      raiseAgentId,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RAISE_AGENT,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE,
      proposal.RAISE_DELAY()
    );
    _assertAgent(
      cutAgentId,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_CUT_AGENT,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_REDUCER_ORACLE,
      0
    );
  }

  /// @dev The module's agents, borrow bounds and every listed entry after execution.
  function test_rangeValidationModuleConfigured() public {
    AaveV3Arbitrum_CapsRateLimiterActivation_20261126 p = proposal;
    Entry[19] memory entries = [
      Entry(AaveV3ArbitrumAssets.WBTC_UNDERLYING, 0, p.WBTC_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.WETH_UNDERLYING, 0, p.WETH_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.USDT_UNDERLYING, 0, p.USDT_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.USDCn_UNDERLYING, 0, p.USDCN_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.wstETH_UNDERLYING, 0, p.WSTETH_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.DAI_UNDERLYING, 0, p.DAI_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.LINK_UNDERLYING, 0, p.LINK_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.USDCe_UNDERLYING, 0, p.USDCE_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.EURS_UNDERLYING, 0, p.EURS_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.MAI_UNDERLYING, 0, p.MAI_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.rETH_UNDERLYING, 0, p.RETH_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.LUSD_UNDERLYING, 0, p.LUSD_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.FRAX_UNDERLYING, 0, p.FRAX_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.ARB_UNDERLYING, 0, p.ARB_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.weETH_UNDERLYING, 0, p.WEETH_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.ezETH_UNDERLYING, 0, p.EZETH_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.rsETH_UNDERLYING, 0, p.RSETH_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.tBTC_UNDERLYING, 0, p.TBTC_MAX_HEADROOM()),
      Entry(AaveV3ArbitrumAssets.AAVE_UNDERLYING, p.AAVE_MAX_CAP(), p.AAVE_MAX_HEADROOM())
    ];
    // The hard maximum of a listed reserve is its borrow cap at execution.
    for (uint256 i; i < entries.length; ++i) {
      if (entries[i].maxCap == 0) entries[i].maxCap = uint64(_borrowCap(entries[i].asset));
    }

    executePayload(vm, address(proposal));

    IRvm rvm = IRvm(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RANGE_VALIDATION_MODULE);

    IRvm.AgentConfig memory agent = rvm.getAgent(raiseAgentId);
    assertEq(uint8(agent.direction), uint8(IRvm.Direction.RAISE), 'raise agent direction');
    assertEq(uint8(agent.kind), uint8(IRvm.CapKind.BORROW), 'raise agent kind');
    agent = rvm.getAgent(cutAgentId);
    assertEq(uint8(agent.direction), uint8(IRvm.Direction.CUT), 'cut agent direction');
    assertEq(uint8(agent.kind), uint8(IRvm.CapKind.BORROW), 'cut agent kind');

    IRvm.Bounds memory bounds = rvm.getBounds(IRvm.CapKind.BORROW);
    assertEq(bounds.alphaBpsLimit, p.ALPHA_BPS_LIMIT(), 'alphaBpsLimit');
    assertEq(bounds.cutBandBpsLimit, p.CUT_BAND_BPS_LIMIT(), 'cutBandBpsLimit');
    assertEq(bounds.maxIncreaseBps, p.MAX_INCREASE_BPS(), 'maxIncreaseBps');
    assertEq(bounds.cooldown, p.COOLDOWN(), 'cooldown');

    for (uint256 i; i < entries.length; ++i) {
      IRvm.KeyState memory key = rvm.getKeyState(entries[i].asset, IRvm.CapKind.BORROW);
      string memory symbol = IERC20Metadata(entries[i].asset).symbol();
      assertGt(entries[i].maxCap, 0, symbol);
      assertEq(key.maxCap, entries[i].maxCap, string.concat(symbol, ' maxCap'));
      assertEq(key.maxHeadroom, entries[i].maxHeadroom, string.concat(symbol, ' maxHeadroom'));
      assertEq(key.alphaBps, p.ALPHA_BPS(), string.concat(symbol, ' buffer share'));
      assertEq(key.cutBandBps, p.CUT_BAND_BPS(), string.concat(symbol, ' cut band'));
      assertEq(key.holdUntil, 0, string.concat(symbol, ' hold'));
      assertEq(key.lastIncreaseAt, 0, string.concat(symbol, ' lastIncreaseAt'));
      assertEq(key.onboardingUntil, 0, string.concat(symbol, ' onboarding'));
    }

    // Every reserve but GHO is listed; GHO stays with the Risk Stewards.
    assertEq(AaveV3Arbitrum.POOL.getReservesList().length, entries.length + 1, 'reserve count');
    IRvm.KeyState memory gho = rvm.getKeyState(
      AaveV3ArbitrumAssets.GHO_UNDERLYING,
      IRvm.CapKind.BORROW
    );
    assertEq(gho.maxCap, 0, 'GHO listed');
  }

  /// @dev If another registration takes id 3 first, the payload must fail rather than wire the
  ///      module to the wrong agents.
  function test_revertIfAgentIdTaken() public {
    address[] memory none = new address[](0);
    string memory updateType = proposal.UPDATE_TYPE();
    vm.prank(GovernanceV3Arbitrum.EXECUTOR_LVL_1);
    HUB.registerAgent(
      IAgentConfigurator.AgentRegistrationInput({
        admin: MiscArbitrum.PROTOCOL_GUARDIAN,
        riskOracle: ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE,
        isAgentEnabled: false,
        isAgentPermissioned: false,
        isMarketsFromAgentEnabled: false,
        agentAddress: ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RAISE_AGENT,
        expirationPeriod: 1,
        minimumDelay: 0,
        updateType: updateType,
        agentContext: bytes(''),
        allowedMarkets: none,
        restrictedMarkets: none,
        permissionedSenders: none
      })
    );

    address controller = address(GovV3Helpers.getPayloadsController(block.chainid));
    uint40 payloadId = GovV3Helpers.readyPayload(vm, address(proposal), controller);
    vm.expectRevert();
    IPayloadsControllerCore(controller).executePayload(payloadId);
  }

  /// @dev Current caps sit above debt plus one buffer, so cuts are due right after execution. The
  ///      Router can apply them; any other caller is skipped.
  function test_e2eCutThroughRouter() public {
    executePayload(vm, address(proposal));

    uint256[] memory ids = new uint256[](1);
    ids[0] = cutAgentId;
    (bool shouldExecute, IAgentHub.ActionData[] memory actions) = HUB.check(ids);
    assertTrue(shouldExecute, 'no cut due after execution');
    assertEq(actions.length, 1);
    assertGt(actions[0].markets.length, 0);

    vm.expectRevert(IAgentHub.NoActionCanBePerformed.selector);
    HUB.execute(actions);

    address[] memory markets = actions[0].markets;
    uint256[] memory capsBefore = new uint256[](markets.length);
    for (uint256 i; i < markets.length; ++i) capsBefore[i] = _borrowCap(markets[i]);

    vm.prank(ROUTER);
    HUB.execute(actions);

    for (uint256 i; i < markets.length; ++i) {
      uint256 cap = _borrowCap(markets[i]);
      assertLt(cap, capsBefore[i], 'cap not cut');
      assertGe(cap, _debtTokens(markets[i]), 'cap cut below debt');
    }
  }

  /// @dev A raise above debt plus one buffer is refused by the module, so the hub has nothing to run.
  function test_raiseAboveTheRuleIsRefused() public {
    executePayload(vm, address(proposal));

    address weth = AaveV3ArbitrumAssets.WETH_UNDERLYING;
    bytes memory newCap = abi.encode(_borrowCap(weth) + 1);
    string memory updateType = proposal.UPDATE_TYPE();
    vm.prank(ROUTER);
    IRiskOracle(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE).publishRiskParameterUpdate(
      'e2e-test',
      newCap,
      updateType,
      weth,
      bytes('')
    );

    uint256[] memory ids = new uint256[](1);
    ids[0] = raiseAgentId;
    (bool shouldExecute, ) = HUB.check(ids);
    assertFalse(shouldExecute, 'raise above the rule accepted');
  }

  function _assertAgent(
    uint256 agentId,
    address agent,
    address riskOracle,
    uint256 minimumDelay
  ) internal view {
    assertEq(HUB.getAgentAddress(agentId), agent);
    assertTrue(HUB.isAgentEnabled(agentId), 'agent not enabled');
    assertEq(HUB.getRiskOracle(agentId), riskOracle);
    assertEq(HUB.getUpdateType(agentId), proposal.UPDATE_TYPE());
    assertEq(HUB.getAgentAdmin(agentId), MiscArbitrum.PROTOCOL_GUARDIAN);
    assertEq(HUB.getExpirationPeriod(agentId), proposal.EXPIRATION_PERIOD());
    assertEq(HUB.getMinimumDelay(agentId), minimumDelay);
    assertTrue(HUB.isMarketsFromAgentEnabled(agentId), 'markets not read from the agent');
    assertEq(abi.decode(HUB.getAgentContext(agentId), (address)), AaveV3Arbitrum.CONFIG_ENGINE);

    assertTrue(HUB.isAgentPermissioned(agentId), 'agent not permissioned');
    address[] memory senders = HUB.getPermissionedSenders(agentId);
    assertEq(senders.length, 1, 'one permissioned sender');
    assertEq(senders[0], ROUTER);

    // Both agents delegatecall the config engine, so the PoolConfigurator checks the role on the agent.
    assertTrue(AaveV3Arbitrum.ACL_MANAGER.isRiskAdmin(agent), 'agent is not a risk admin');
  }

  function _borrowCap(address asset) internal view returns (uint256) {
    return AaveV3Arbitrum.POOL.getConfiguration(asset).getBorrowCap();
  }

  function _debtTokens(address asset) internal view returns (uint256) {
    IERC20Metadata debt = IERC20Metadata(AaveV3Arbitrum.POOL.getReserveVariableDebtToken(asset));
    return debt.totalSupply() / 10 ** debt.decimals();
  }
}
