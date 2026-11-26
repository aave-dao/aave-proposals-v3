// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {IAgentHub, IAgentConfigurator} from '../interfaces/IAgentHub.sol';
import {ICapsRangeValidationModule as IRvm} from '../interfaces/ICapsRangeValidationModule.sol';

/**
 * @dev LlamaGuard Caps contracts on Arbitrum, under the address book key names they move to once listed.
 *      Deployed from the LlamaRisk prod EOA and verified on Arbiscan.
 */
library ArbitrumLlamaGuardCaps {
  address internal constant LLAMARISK_RISK_ORACLE_ADMIN_SAFE =
    0x1a0267E9E5929a5914Ae9DbBf23Bc07B14365471;
  address internal constant LLAMARISK_CAPS_RISK_ORACLE = 0x556c75E6bbf0672bf3510b839Ad229450C474f23;
  address internal constant LLAMARISK_CAPS_RISK_ORACLE_ROUTER =
    0x74d8dd6CfCC3BeED9C4Db3fd6c4e471aD721d9F0;
  address internal constant LLAMARISK_CAPS_PARAMETER_REGISTRY =
    0x2662d3A9d07589DCAbAA10ea85F66572b51c260d;
  address internal constant LLAMARISK_CAPS_RANGE_VALIDATION_MODULE =
    0x039C0E59F728bA984dFAA96dFF977B977aA82Beb;
  address internal constant LLAMARISK_CAPS_REDUCER_ORACLE =
    0xC8D89bd6894C315Fb13bBD057357D1380771C181;
  address internal constant LLAMARISK_CAPS_RAISE_AGENT = 0x996126C29374EbBA1A3AC91c2564C29D0E634765;
  address internal constant LLAMARISK_CAPS_CUT_AGENT = 0x3Fe54E476007CB315B23284BC1064cCC01a1f666;
}

/**
 * @title Caps Rate Limiter Activation
 * @author LlamaRisk
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xd80bf15385e4f525108133bee1460b1907aabd1013b67821936fd52f3140793d
 * - Discussion: https://governance.aave.com/t/arfc-dynamic-caps-oracle-rate-limiter/26219
 */
contract AaveV3Arbitrum_CapsRateLimiterActivation_20261126 is IProposalGenericExecutor {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  error UnexpectedAgentId(uint256 expected, uint256 actual);
  error NoLiveBorrowCap(address asset);

  /// @dev The AgentHub holds agents 0 to 2. The workflow and keeper configs name these ids, so the payload
  ///      reverts rather than wire the RVM to other ids if a registration lands first.
  uint256 public constant RAISE_AGENT_ID = 3;
  uint256 public constant CUT_AGENT_ID = 4;

  string public constant UPDATE_TYPE = 'BorrowCapUpdate_Core';
  uint256 public constant EXPIRATION_PERIOD = 1 minutes;
  uint256 public constant RAISE_DELAY = 30 minutes;

  uint16 public constant ALPHA_BPS = 10_00;
  uint16 public constant CUT_BAND_BPS = 10_00;
  uint16 public constant ALPHA_BPS_LIMIT = 20_00;
  uint16 public constant CUT_BAND_BPS_LIMIT = 20_00;
  uint16 public constant MAX_INCREASE_BPS = 50_00;
  uint40 public constant COOLDOWN = 1 days;

  function execute() external {
    _grantRiskAdmin();
    _registerAgents();
    _configureRvm();
  }

  /// @dev Both agents write through the config engine by delegatecall, so the PoolConfigurator sees the agent.
  function _grantRiskAdmin() internal {
    AaveV3Arbitrum.ACL_MANAGER.addRiskAdmin(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RAISE_AGENT);
    AaveV3Arbitrum.ACL_MANAGER.addRiskAdmin(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_CUT_AGENT);
  }

  function _registerAgents() internal {
    _register(
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RAISE_AGENT,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE,
      RAISE_DELAY,
      RAISE_AGENT_ID
    );
    _register(
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_CUT_AGENT,
      ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_REDUCER_ORACLE,
      0,
      CUT_AGENT_ID
    );
  }

  /// @dev Permissioned to the Router: only a routed CRE report can execute either agent.
  function _register(
    address agent,
    address riskOracle,
    uint256 minimumDelay,
    uint256 expectedId
  ) internal {
    address[] memory senders = new address[](1);
    senders[0] = ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RISK_ORACLE_ROUTER;
    uint256 id = IAgentHub(MiscArbitrum.AGENT_HUB).registerAgent(
      IAgentConfigurator.AgentRegistrationInput({
        admin: MiscArbitrum.PROTOCOL_GUARDIAN,
        riskOracle: riskOracle,
        isAgentEnabled: true,
        isAgentPermissioned: true,
        isMarketsFromAgentEnabled: true,
        agentAddress: agent,
        expirationPeriod: EXPIRATION_PERIOD,
        minimumDelay: minimumDelay,
        updateType: UPDATE_TYPE,
        agentContext: abi.encode(AaveV3Arbitrum.CONFIG_ENGINE),
        allowedMarkets: new address[](0),
        restrictedMarkets: new address[](0),
        permissionedSenders: senders
      })
    );
    if (id != expectedId) revert UnexpectedAgentId(expectedId, id);
  }

  function _configureRvm() internal {
    IRvm rvm = IRvm(ArbitrumLlamaGuardCaps.LLAMARISK_CAPS_RANGE_VALIDATION_MODULE);
    rvm.setAgent(RAISE_AGENT_ID, IRvm.Direction.RAISE);
    rvm.setAgent(CUT_AGENT_ID, IRvm.Direction.CUT);
    rvm.setBounds(
      IRvm.CapKind.BORROW,
      IRvm.Bounds({
        alphaBpsLimit: ALPHA_BPS_LIMIT,
        cutBandBpsLimit: CUT_BAND_BPS_LIMIT,
        maxIncreaseBps: MAX_INCREASE_BPS,
        cooldown: COOLDOWN
      })
    );

    // Buffer ceiling: $15M in tokens at Aave oracle prices of 15 Nov 2026. GHO stays with the Risk
    // Stewards; every other reserve is frozen or has borrowing disabled.
    _list(rvm, AaveV3ArbitrumAssets.WBTC_UNDERLYING, 233);
    _list(rvm, AaveV3ArbitrumAssets.WETH_UNDERLYING, 8_282);
    _list(rvm, AaveV3ArbitrumAssets.USDT_UNDERLYING, 15_008_779);
    _list(rvm, AaveV3ArbitrumAssets.USDCn_UNDERLYING, 15_003_601);
  }

  /// @dev The hard maximum is the borrow cap at execution, so it stays the value the Risk Stewards set.
  function _list(IRvm rvm, address asset, uint64 maxHeadroom) internal {
    uint256 cap = AaveV3Arbitrum.POOL.getConfiguration(asset).getBorrowCap();
    if (cap == 0) revert NoLiveBorrowCap(asset); // maxCap 0 would retire the entry
    rvm.setRateLimitConfig(
      asset,
      IRvm.CapKind.BORROW,
      IRvm.RateLimitConfig({
        maxCap: uint64(cap),
        maxHeadroom: maxHeadroom,
        alphaBps: ALPHA_BPS,
        cutBandBps: CUT_BAND_BPS
      })
    );
  }
}
