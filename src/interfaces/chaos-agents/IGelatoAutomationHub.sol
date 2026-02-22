// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAgentHub} from './IAgentHub.sol';

/**
 * @title IGelatoAutomationHub
 * @author BGD Labs
 */
interface IGelatoAutomationHub {
  /**
   * @notice method that is simulated by the gelato keepers off-chain to see if `execute()` actually needs to be called
   * @param agentIds contains the list of agentIds for which updates should be checked
   * @return upkeepNeeded boolean to indicate whether the keeper should call `execute()` or not.
   * @return encodedData contains the encoded actions which should be executed along with the `execute()` function selector
   *         as required by the gelato infrastructure
   */
  function check(
    uint256[] memory agentIds
  ) external view returns (bool upkeepNeeded, bytes memory encodedData);

  /**
   * @notice method called by gelato keepers when check returns true, to inject updates for agents
   * @param actions contains the list of ActionData for which updates can be injected
   */
  function execute(IAgentHub.ActionData[] memory actions) external;

  /**
   * @notice method to get the agent hub contract on which automation would run
   * @return agent hub contract address
   */
  function AGENT_HUB() external view returns (IAgentHub);
}
