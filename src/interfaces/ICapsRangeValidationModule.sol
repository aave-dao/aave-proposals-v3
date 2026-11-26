// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ICapsRangeValidationModule
 * @author LlamaRisk
 * @notice Owner setters of the LlamaGuard Caps range validation module (`CapsRangeValidationModuleV3`) used by
 *         the activation payload. Source: llama-risk/llamaguard-contracts, src/caps-oracle.
 */
interface ICapsRangeValidationModule {
  enum CapKind {
    BORROW,
    SUPPLY
  }

  enum Direction {
    NONE,
    RAISE,
    CUT
  }

  struct RateLimitConfig {
    uint64 maxCap; // hard maximum cap, whole tokens, at most 2^36 - 1
    uint64 maxHeadroom; // ceiling of the buffer, whole tokens. Floor is ceil(maxHeadroom / 25)
    uint16 alphaBps; // buffer as a share of debt
    uint16 cutBandBps; // a cut needs headroom above (1 + band) * buffer
  }

  struct Bounds {
    uint16 alphaBpsLimit; // max alphaBps the Risk Council can set
    uint16 cutBandBpsLimit; // max cutBandBps the Risk Council can set
    uint16 maxIncreaseBps; // max Risk Council raise of maxCap or maxHeadroom per cooldown
    uint40 cooldown; // seconds between two Risk Council raises
  }

  function POOL() external view returns (address);

  function AGENT_HUB() external view returns (address);

  function riskCouncil() external view returns (address);

  function setAgent(uint256 agentId, Direction direction) external;

  function setBounds(CapKind kind, Bounds calldata bounds) external;

  function setRateLimitConfig(
    address asset,
    CapKind kind,
    RateLimitConfig calldata rateLimitConfig
  ) external;
}
