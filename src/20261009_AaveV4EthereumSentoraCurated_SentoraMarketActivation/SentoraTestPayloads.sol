// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {ISpoke} from 'aave-address-book/AaveV4.sol';
import {AaveV4EthereumSentoraCurated, AaveV4EthereumSentoraCuratedHubs, AaveV4EthereumSentoraCuratedSpokes, AaveV4EthereumSentoraCuratedAssets} from 'aave-address-book/AaveV4EthereumSentoraCurated.sol';

/// @dev Risk-increasing Sentora payload: raises the RLUSD Yield RLUSD caps and adds a higher USDe
/// collateral factor on RLUSD Yield, through roles 1000 the Executor holds.
contract SentoraRiskIncreasePayload is IProposalGenericExecutor {
  uint256 public constant RLUSD_ADD_CAP = 120_000_000;
  uint256 public constant RLUSD_DRAW_CAP = 100_000_000;
  uint16 public constant USDe_COLLATERAL_FACTOR = 92_00;

  function execute() external {
    address hub = address(AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB);
    ISpoke spoke = AaveV4EthereumSentoraCuratedSpokes.RLUSD_YIELD_SPOKE;
    AaveV4EthereumSentoraCurated.HUB_CONFIGURATOR.updateSpokeCaps({
      hub: hub,
      assetId: AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB.getAssetId(
        AaveV4EthereumSentoraCuratedAssets.RLUSD_UNDERLYING
      ),
      spoke: address(spoke),
      addCap: RLUSD_ADD_CAP,
      drawCap: RLUSD_DRAW_CAP
    });
    AaveV4EthereumSentoraCurated.SPOKE_CONFIGURATOR.addCollateralFactor({
      spoke: address(spoke),
      reserveId: spoke.getReserveId(
        hub,
        AaveV4EthereumSentoraCuratedHubs.SENTORA_HUB.getAssetId(
          AaveV4EthereumSentoraCuratedAssets.USDe_UNDERLYING
        )
      ),
      collateralFactor: USDe_COLLATERAL_FACTOR
    });
  }
}

/// @dev Sentora payload replaying a fixed list of calls. The Executor delegatecalls `execute`, so the
/// list is read back from this contract's own deployment rather than from storage.
contract SentoraCallsPayload is IProposalGenericExecutor {
  struct Call {
    address target;
    bytes data;
  }

  SentoraCallsPayload internal immutable SELF;
  Call[] internal _calls;

  constructor(Call[] memory calls_) {
    SELF = this;
    for (uint256 i; i < calls_.length; ++i) {
      _calls.push(calls_[i]);
    }
  }

  function calls() external view returns (Call[] memory) {
    return _calls;
  }

  function execute() external {
    Call[] memory list = SELF.calls();
    for (uint256 i; i < list.length; ++i) {
      (bool success, bytes memory result) = list[i].target.call(list[i].data);
      if (!success) {
        assembly {
          revert(add(result, 32), mload(result))
        }
      }
    }
  }
}
