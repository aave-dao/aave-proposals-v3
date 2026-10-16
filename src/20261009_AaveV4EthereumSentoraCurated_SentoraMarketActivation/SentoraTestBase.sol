// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IPayloadsControllerCore} from 'aave-address-book/GovernanceV3.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {IHub, ISpoke, IAaveOracle, IHubConfigurator, ISpokeConfigurator, ITreasurySpoke, IAccessManagerEnumerable} from 'aave-address-book/AaveV4.sol';
import {IPriceFeed} from 'aave-v4/spoke/interfaces/IPriceFeed.sol';
import {AaveV4EthereumSentoraCurated, AaveV4EthereumSentoraCuratedHubs, AaveV4EthereumSentoraCuratedSpokes, AaveV4EthereumSentoraCuratedPositionManagers, AaveV4EthereumSentoraCuratedAssets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';
import {ProtocolV4TestBaseEthereumSentoraCurated} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereumSentoraCurated.sol';
import {IOwnable2Step} from 'src/interfaces/IOwnable2Step.sol';
import {IRiskStewardV4} from 'src/interfaces/IRiskStewardV4.sol';
import {AaveV4EthereumSentoraCurated_SentoraMarketActivation_20261009} from './AaveV4EthereumSentoraCurated_SentoraMarketActivation_20261009.sol';
import {AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016} from './AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016.sol';
import {SentoraPreLaunchCouncilCalls} from './SentoraPreLaunchCouncilCalls.sol';
import {SentoraCallsPayload} from './SentoraTestPayloads.sol';
import {IReduceRiskStewardWrapper} from './SentoraInterfaces.sol';

/**
 * @dev Shared fork setup for the Sentora market activation tests. Forks after the on-chain relinquish
 *      and the activation payload deploy, then runs the pre-launch config payload the way the V4
 *      Security Council will (role grants, then its Executor), so every test starts from the state
 *      the activation payload will find.
 */
abstract contract SentoraTestBase is ProtocolV4TestBaseEthereumSentoraCurated {
  uint256 internal constant FORK_BLOCK = 26203500;

  IHub internal constant HUB = AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB;
  ISpoke internal constant RLUSD_YIELD = AaveV4EthereumSentoraCuratedSpokes.RLUSD_YIELD_SPOKE;
  ISpoke internal constant OUSD_YIELD = AaveV4EthereumSentoraCuratedSpokes.OUSD_YIELD_SPOKE;
  ISpoke internal constant BLUECHIP = AaveV4EthereumSentoraCuratedSpokes.BLUECHIP_SPOKE;
  ITreasurySpoke internal constant TREASURY_SPOKE = AaveV4EthereumSentoraCurated.TREASURY_SPOKE;
  IAccessManagerEnumerable internal constant ACCESS_MANAGER =
    AaveV4EthereumSentoraCurated.ACCESS_MANAGER;
  IHubConfigurator internal constant HUB_CONFIGURATOR =
    AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR;
  ISpokeConfigurator internal constant SPOKE_CONFIGURATOR =
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR;
  IRiskStewardV4 internal constant RISK_STEWARD =
    IRiskStewardV4(AaveV4EthereumSentoraCurated.RISK_STEWARD);
  IReduceRiskStewardWrapper internal constant WRAPPER =
    IReduceRiskStewardWrapper(AaveV4EthereumSentoraCurated.REDUCE_RISK_STEWARD_WRAPPER);

  address internal constant PPC = AaveV4EthereumSentoraCurated.PERMISSIONED_PAYLOADS_CONTROLLER;
  address internal constant EXECUTOR =
    AaveV4EthereumSentoraCurated.PERMISSIONED_PAYLOADS_CONTROLLER_EXECUTOR;
  address internal constant SECURITY_COUNCIL = MiscEthereum.V4_SECURITY_COUNCIL;
  address internal constant COUNCIL_EXECUTOR = MiscEthereum.V4_SECURITY_COUNCIL_EXECUTOR;
  address internal constant EXECUTOR_LVL_1 = GovernanceV3Ethereum.EXECUTOR_LVL_1;
  address internal constant EMERGENCY_ADMIN = AaveV4EthereumSentoraCurated.SENTORA_EMERGENCY_ADMIN;
  address internal constant OPERATOR = AaveV4EthereumSentoraCurated.SENTORA_OPERATOR;
  address internal constant FEE_ADMIN = AaveV4EthereumSentoraCurated.SENTORA_FEE_ADMIN;
  /// @dev Deployed and configured the market (aave-v4 Sentora deploy report); holds nothing after the
  /// relinquish but the pending Ownable2Step transfers.
  address internal constant DEPLOYER = 0x043a48d1Bd61c59f67C09215D5Eae6b743Fe533d;

  uint64 internal constant ADMIN_ROLE = 0;
  uint64 internal constant HUB_CONFIGURATOR_ROLE = 101;
  uint64 internal constant HUB_FEE_MINTER_ROLE = 102;
  uint64 internal constant HUB_CONFIGURATOR_DOMAIN_ADMIN_ROLE = 200;
  uint64 internal constant SPOKE_CONFIGURATOR_ROLE = 301;
  uint64 internal constant SPOKE_CONFIGURATOR_DOMAIN_ADMIN_ROLE = 400;
  uint64 internal constant SENTORA_RISK_ROLE = 1000;
  uint64 internal constant SENTORA_EMERGENCY_ROLE = 1001;

  uint40 internal constant PPC_DELAY = 2 days;
  uint40 internal constant PPC_GRACE_PERIOD = 7 days;
  uint40 internal constant PPC_EXPIRATION_DELAY = 35 days;

  /// @dev The activation payload deployed on mainnet (CREATE2 salt v1); its runtime code equals
  /// this folder's source.
  address internal constant DEPLOYED_PAYLOAD = 0x888dAbE1Bc1Eb6DFaBc4BB398c4886CdA5D84bD0;

  uint256 internal constant ASSET_COUNT = 8;
  /// @dev 14 reserves plus the TreasurySpoke of each of the 8 assets.
  uint256 internal constant SPOKE_PAIR_COUNT = 22;

  AaveV4EthereumSentoraCurated_SentoraMarketActivation_20261009 internal proposal;
  address internal preLaunchConfig;

  function setUp() public virtual {
    _fork();
    _applyPreLaunchConfig();
  }

  function _fork() internal {
    vm.createSelectFork(vm.rpcUrl('mainnet'), FORK_BLOCK);
    assertGt(address(HUB).code.length, 0, 'hub code');
    assertGt(PPC.code.length, 0, 'payloads controller code');
    assertGt(address(RISK_STEWARD).code.length, 0, 'risk steward code');
    assertGt(address(WRAPPER).code.length, 0, 'wrapper code');
    assertGt(DEPLOYED_PAYLOAD.code.length, 0, 'payload code');
    proposal = AaveV4EthereumSentoraCurated_SentoraMarketActivation_20261009(DEPLOYED_PAYLOAD);
    preLaunchConfig = GovV3Helpers.deployDeterministic(
      type(AaveV4EthereumSentoraCurated_SentoraPreLaunchConfig_20261016).creationCode
    );
  }

  /// @dev Sends the Council Safe transactions the deploy script prints, one by one.
  function _applyPreLaunchConfig() internal {
    SentoraPreLaunchCouncilCalls.Call[] memory calls = SentoraPreLaunchCouncilCalls.calls(
      preLaunchConfig
    );
    for (uint256 i; i < calls.length; ++i) {
      vm.prank(SECURITY_COUNCIL);
      (bool success, ) = calls[i].to.call(calls[i].data);
      assertTrue(success, string.concat('council call ', vm.toString(i)));
    }
  }

  /// @dev Raises the PST and PRIME caps back to the ARFC values through a Sentora Executor payload
  /// on the PPC, so flows that need those reserves can still use them after the pre-launch config.
  function _raisePstPrimeCapsThroughSentora() internal {
    SentoraCallsPayload.Call[] memory calls = new SentoraCallsPayload.Call[](4);
    calls[0] = _capsCall(
      AaveV4EthereumSentoraCuratedAssets.PRIME_UNDERLYING,
      RLUSD_YIELD,
      15_000_000
    );
    calls[1] = _capsCall(
      AaveV4EthereumSentoraCuratedAssets.PRIME_UNDERLYING,
      OUSD_YIELD,
      1_500_000
    );
    calls[2] = _capsCall(
      AaveV4EthereumSentoraCuratedAssets.PST_UNDERLYING,
      RLUSD_YIELD,
      20_000_000
    );
    calls[3] = _capsCall(AaveV4EthereumSentoraCuratedAssets.PST_UNDERLYING, OUSD_YIELD, 2_000_000);
    _executeAfterDelay(_createPayload(address(new SentoraCallsPayload(calls))));
  }

  function _capsCall(
    address underlying,
    ISpoke spoke,
    uint256 addCap
  ) internal view returns (SentoraCallsPayload.Call memory) {
    return
      SentoraCallsPayload.Call({
        target: address(HUB_CONFIGURATOR),
        data: abi.encodeCall(
          IHubConfigurator.updateSpokeCaps,
          (address(HUB), HUB.getAssetId(underlying), address(spoke), addCap, 0)
        )
      });
  }

  modifier activated() {
    _activate();
    _;
  }

  /// @dev The Fee Admin's TreasurySpoke `acceptOwnership` is its own step outside the activation
  /// payload; flows that need the Fee Admin as owner run it first.
  function _acceptTreasurySpokeOwnership() internal {
    vm.prank(FEE_ADMIN);
    IOwnable2Step(address(TREASURY_SPOKE)).acceptOwnership();
  }

  /// @dev Runs the activation payload the way it goes live: created by the Sentora Operator,
  /// executed once the PPC delay has passed.
  function _activate() internal {
    _executeAfterDelay(_createPayload(address(proposal)));
  }

  function _createPayload(address payload) internal returns (uint40) {
    IPayloadsControllerCore.ExecutionAction[]
      memory actions = new IPayloadsControllerCore.ExecutionAction[](1);
    actions[0] = GovV3Helpers.buildAction(payload);
    vm.prank(OPERATOR);
    return IPayloadsControllerCore(PPC).createPayload(actions);
  }

  function _executeAfterDelay(uint40 payloadId) internal {
    IPayloadsControllerCore.Payload memory payload = IPayloadsControllerCore(PPC).getPayloadById(
      payloadId
    );
    vm.warp(payload.queuedAt + payload.delay + 1);
    IPayloadsControllerCore(PPC).executePayload(payloadId);
  }

  function _ownedByExecutor() internal pure returns (address[] memory owned) {
    owned = new address[](5);
    owned[0] = address(AaveV4EthereumSentoraCuratedPositionManagers.GIVER_POSITION_MANAGER);
    owned[1] = address(AaveV4EthereumSentoraCuratedPositionManagers.TAKER_POSITION_MANAGER);
    owned[2] = address(AaveV4EthereumSentoraCuratedPositionManagers.CONFIG_POSITION_MANAGER);
    owned[3] = address(AaveV4EthereumSentoraCuratedPositionManagers.NATIVE_TOKEN_GATEWAY);
    owned[4] = address(AaveV4EthereumSentoraCuratedPositionManagers.SIGNATURE_GATEWAY);
  }

  function _marketProxies() internal pure returns (address[] memory proxies) {
    proxies = new address[](5);
    proxies[0] = address(HUB);
    proxies[1] = address(RLUSD_YIELD);
    proxies[2] = address(OUSD_YIELD);
    proxies[3] = address(BLUECHIP);
    proxies[4] = address(TREASURY_SPOKE);
  }

  function _spokes() internal pure returns (ISpoke[] memory spokes) {
    spokes = new ISpoke[](3);
    spokes[0] = RLUSD_YIELD;
    spokes[1] = OUSD_YIELD;
    spokes[2] = BLUECHIP;
  }

  function _proxyAdmin(address proxy) internal view returns (address) {
    return
      address(
        uint160(
          uint256(
            vm.load(proxy, 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
          )
        )
      );
  }

  function _reserveId(ISpoke spoke, address underlying) internal view returns (uint256) {
    return spoke.getReserveId(address(HUB), HUB.getAssetId(underlying));
  }

  function _underlying(ISpoke spoke, uint256 reserveId) internal view returns (address) {
    return spoke.getReserve(reserveId).underlying;
  }

  function _units(ISpoke spoke, uint256 reserveId, uint256 tokens) internal view returns (uint256) {
    return tokens * 10 ** spoke.getReserve(reserveId).decimals;
  }

  function _supplyAs(ISpoke spoke, uint256 reserveId, address user, uint256 amount) internal {
    address underlying = _underlying(spoke, reserveId);
    deal2(underlying, user, amount);
    vm.startPrank(user);
    IERC20(underlying).approve(address(spoke), amount);
    spoke.supply(reserveId, amount, user);
    vm.stopPrank();
  }

  function _supplyCollateralAs(
    ISpoke spoke,
    uint256 reserveId,
    address user,
    uint256 amount
  ) internal {
    _supplyAs(spoke, reserveId, user, amount);
    vm.prank(user);
    spoke.setUsingAsCollateral(reserveId, true, user);
  }

  function _borrowAs(ISpoke spoke, uint256 reserveId, address user, uint256 amount) internal {
    vm.prank(user);
    spoke.borrow(reserveId, amount, user);
  }

  function _mockSourcePrice(ISpoke spoke, uint256 reserveId, int256 price) internal {
    vm.mockCall(
      _source(spoke, reserveId),
      abi.encodeWithSelector(IPriceFeed.latestAnswer.selector),
      abi.encode(price)
    );
  }

  function _source(ISpoke spoke, uint256 reserveId) internal view returns (address) {
    return IAaveOracle(spoke.ORACLE()).getReserveSource(reserveId);
  }

  function _expectUnauthorized(address caller) internal {
    vm.expectRevert(abi.encodeWithSignature('AccessManagedUnauthorized(address)', caller));
  }
}
