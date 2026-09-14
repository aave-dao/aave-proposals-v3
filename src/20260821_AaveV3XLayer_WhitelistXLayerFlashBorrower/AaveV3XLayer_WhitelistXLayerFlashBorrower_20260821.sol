// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3XLayer} from 'aave-address-book/AaveV3XLayer.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

/**
 * @title Add X Layer Loop Tool & Margin Trading to FlashBorrowers
 * @author @TokenLogic
 * - Snapshot: direct-to-aip
 * - Discussion: https://governance.aave.com/t/direct-to-aip-add-x-layer-loop-tool-margin-trading-to-flashborrowers/25551
 */
contract AaveV3XLayer_WhitelistXLayerFlashBorrower_20260821 is IProposalGenericExecutor {
  // https://www.oklink.com/xlayer/address/0x714A871d3B471FF7Ee6A1896B16c5f55884fd910
  address public constant LOOP_TOOL = 0x714A871d3B471FF7Ee6A1896B16c5f55884fd910;
  // https://www.oklink.com/xlayer/address/0x18a6704775570afA8dB0D3FC0242515D90d120C0
  address public constant MARGIN_TRADING = 0x18a6704775570afA8dB0D3FC0242515D90d120C0;

  function execute() external {
    AaveV3XLayer.ACL_MANAGER.addFlashBorrower(LOOP_TOOL);
    AaveV3XLayer.ACL_MANAGER.addFlashBorrower(MARGIN_TRADING);
  }
}
