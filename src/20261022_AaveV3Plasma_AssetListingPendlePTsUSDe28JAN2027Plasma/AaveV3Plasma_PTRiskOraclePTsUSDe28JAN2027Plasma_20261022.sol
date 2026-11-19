// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma} from 'aave-address-book/AaveV3Plasma.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IAgentHub} from '../interfaces/IAgentHub.sol';

/**
 * @title PT Risk Oracle - Pendle PT-sUSDe-28JAN2027 Plasma
 * @author LlamaRisk
 * @notice Adds PT-sUSDe-28JAN2027 and its eMode to the LlamaRisk PT agents already on the AgentHub.
 *         Runs after the listing payload, which creates the eMode.
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-onboard-pt-susde-28jan2027-to-aave-v3-plasma-instance/25902
 */
contract AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022 is IProposalGenericExecutor {
  error AgentMismatch(uint256 agentId);
  error EModeNotFound();

  // https://plasmascan.to/address/0x257561233419039BeC3a28be717d14B4f490883D
  address public constant PT_sUSDE_28JAN2027 = 0x257561233419039BeC3a28be717d14B4f490883D;
  string public constant EMODE_LABEL = 'sUSDe_PT_sUSDe_28JAN2027__Stablecoins';

  // Registered by the PT-sUSDe-22OCT2026 PT Risk Oracle AIP.
  uint256 public constant DISCOUNT_RATE_AGENT_ID = 2;
  uint256 public constant EMODE_AGENT_ID = 3;

  function execute() external {
    IAgentHub hub = IAgentHub(MiscPlasma.AGENT_HUB);
    if (hub.getAgentAddress(DISCOUNT_RATE_AGENT_ID) != MiscPlasma.LLAMARISK_PT_DISCOUNT_RATE_AGENT)
      revert AgentMismatch(DISCOUNT_RATE_AGENT_ID);
    if (hub.getAgentAddress(EMODE_AGENT_ID) != MiscPlasma.LLAMARISK_PT_EMODE_AGENT)
      revert AgentMismatch(EMODE_AGENT_ID);

    hub.addAllowedMarket(DISCOUNT_RATE_AGENT_ID, PT_sUSDE_28JAN2027);
    hub.addAllowedMarket(EMODE_AGENT_ID, address(uint160(eModeId())));
  }

  /// @notice The id the listing payload's config engine assigned to `EMODE_LABEL`.
  function eModeId() public view returns (uint8) {
    bytes32 label = keccak256(bytes(EMODE_LABEL));
    for (uint8 id = 1; id < type(uint8).max; id++) {
      if (keccak256(bytes(AaveV3Plasma.POOL.getEModeCategoryLabel(id))) == label) return id;
    }
    revert EModeNotFound();
  }
}
