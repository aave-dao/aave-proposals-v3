// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';

/**
 * @title AgentConfigLib
 * @author BGD Labs
 * @notice Stores range configurations of the agent
 */
library AgentConfigLib {
  function stablecoinSlope2RangeConfig()
    internal
    pure
    returns (IRangeValidationModule.RangeConfig memory)
  {
    return
      IRangeValidationModule.RangeConfig({
        maxIncrease: 2_00, // 2% increase
        maxDecrease: 2_00, // 2% decrease
        isIncreaseRelative: false,
        isDecreaseRelative: false
      });
  }

  function wethSlope2RangeConfig()
    internal
    pure
    returns (IRangeValidationModule.RangeConfig memory)
  {
    return
      IRangeValidationModule.RangeConfig({
        maxIncrease: 1_50, // 1.5% increase
        maxDecrease: 1_50, // 1.5% decrease
        isIncreaseRelative: false,
        isDecreaseRelative: false
      });
  }

  function capoSnapshotRatioRangeConfig()
    internal
    pure
    returns (IRangeValidationModule.RangeConfig memory)
  {
    return
      IRangeValidationModule.RangeConfig({
        maxIncrease: 3_00, // 3%
        maxDecrease: 3_00, // 3%
        isIncreaseRelative: true,
        isDecreaseRelative: true
      });
  }

  function capoMaxYearlyRangeConfig()
    internal
    pure
    returns (IRangeValidationModule.RangeConfig memory)
  {
    return
      IRangeValidationModule.RangeConfig({
        maxIncrease: 10_00, // 10%
        maxDecrease: 10_00, // 10%
        isIncreaseRelative: true,
        isDecreaseRelative: true
      });
  }
}
