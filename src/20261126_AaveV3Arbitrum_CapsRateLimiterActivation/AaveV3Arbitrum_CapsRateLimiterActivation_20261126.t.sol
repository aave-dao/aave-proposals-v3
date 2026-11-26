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
import {IAgentHub, IAgentConfigurator} from '../interfaces/IAgentHub.sol';
import {IBaseAaveAgent} from '../interfaces/IBaseAaveAgent.sol';
import {ICapsRangeValidationModule as IRvm} from '../interfaces/ICapsRangeValidationModule.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';

interface IOwnable {
  function owner() external view returns (address);
}

/**
 * @dev Test for AaveV3Arbitrum_CapsRateLimiterActivation_20261126
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261126_AaveV3Arbitrum_CapsRateLimiterActivation/AaveV3Arbitrum_CapsRateLimiterActivation_20261126.t.sol -vv
 *
 * Every test is skipped until the LlamaRisk addresses in `ArbitrumLlamaGuardCaps` are filled in.
 */
contract AaveV3Arbitrum_CapsRateLimiterActivation_20261126_Test is ProtocolV3TestBase {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Arbitrum_CapsRateLimiterActivation_20261126 internal proposal;

  // TODO(PXE-238): pin to a block after the production deployment.
  uint256 internal constant FORK_BLOCK = 0;

  address internal constant RISK_COUNCIL = 0x3Be327F22eB4BD8042e6944073b8826dCf357Aa2;

  IAgentHub internal constant HUB = IAgentHub(MiscArbitrum.AGENT_HUB);
  address internal constant ROUTER = ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE_ROUTER;

  uint256 internal raiseAgentId;
  uint256 internal cutAgentId;

  function setUp() public {
    if (FORK_BLOCK == 0) vm.createSelectFork(vm.rpcUrl('arbitrum'));
    else vm.createSelectFork(vm.rpcUrl('arbitrum'), FORK_BLOCK);
    proposal = new AaveV3Arbitrum_CapsRateLimiterActivation_20261126();

    uint256 startCount = HUB.getAgentCount();
    raiseAgentId = startCount;
    cutAgentId = startCount + 1;
  }

  modifier deployed() {
    vm.skip(
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RANGE_VALIDATION_MODULE == address(0),
      'LlamaRisk caps contracts not deployed yet'
    );
    _;
  }

  /// forge-config: default.isolate = true
  function test_defaultProposalExecution() public deployed {
    defaultTest(
      'AaveV3Arbitrum_CapsRateLimiterActivation_20261126',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /// @dev The payload registers agents and lists reserves in the module; no reserve configuration moves.
  function test_reserveConfigChanges() public deployed {
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
  function test_contractsPredeployedAndWired() public deployed {
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

    address admin = ArbitrumLlamaGuardCaps.LLAMARISK_RISK_ORACLE_ADMIN_SAFE;
    assertEq(IOwnable(ROUTER).owner(), admin, 'Router owner');
    assertEq(IOwnable(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE).owner(), admin);
    assertEq(
      IOwnable(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_PARAMETER_REGISTRY).owner(),
      GovernanceV3Arbitrum.EXECUTOR_LVL_1
    );
  }

  function test_agentsRegisteredAndRiskAdminGranted() public deployed {
    uint256 countBefore = HUB.getAgentCount();

    executePayload(vm, address(proposal));

    assertEq(HUB.getAgentCount(), countBefore + 2, 'expected exactly two new agents');
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

  /// @dev If another registration takes id 3 first, the payload must fail rather than wire the
  ///      module to the wrong agents.
  function test_revertIfAgentIdTaken() public deployed {
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
  function test_e2eCutThroughRouter() public deployed {
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
  function test_raiseAboveTheRuleIsRefused() public deployed {
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
