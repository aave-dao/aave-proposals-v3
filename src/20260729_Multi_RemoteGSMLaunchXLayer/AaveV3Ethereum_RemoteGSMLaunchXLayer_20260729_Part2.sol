// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';
import {IAaveGhoCcipBridge} from 'aave-helpers/src/bridges/ccip/interfaces/IAaveGhoCcipBridge.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGhoDirectFacilitator} from 'src/interfaces/IGhoDirectFacilitator.sol';

import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

/**
 * @title Remote GSM Launch: XLayer
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178
 */
contract AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2 is IProposalGenericExecutor {
  using SafeERC20 for IERC20;

  // GhoDirectFacilitator Constants
  // https://etherscan.io/address/0x0aEeb8c6eE6c9616ab2834e3E0dCe967d8637006
  address public constant DIRECT_FACILITATOR = address(0x0aEeb8c6eE6c9616ab2834e3E0dCe967d8637006);
  string public constant DIRECT_FACILITATOR_NAME = 'GhoDirectFacilitator GSM XLayer';

  // Ethereum-side AaveGhoCcipBridge (target-agnostic; the destination lane is configured below).
  // Its ROUTER is the same one GhoEthereum.GHO_CCIP_TOKEN_POOL is registered under, so `send`
  // below provably drives the GHO token pool this proposal configures. See
  // `test_ccipBridgeIdentity`.
  // https://etherscan.io/address/0x7F2f96fcdC3A29Be75938d2aC3D92E7006919fe6
  address public constant CCIP_BRIDGE = 0x7F2f96fcdC3A29Be75938d2aC3D92E7006919fe6;

  // AaveGhoCcipBridge on XLayer (counterpart that will receive the CCIP message and forward GHO
  // to the XLayer Collector).
  // https://www.oklink.com/x-layer/evm/address/0x49a6105F195460140C22a1Be7A2b1A7Bd7C7faf8
  address public constant XLAYER_BRIDGE_DESTINATION =
    address(0x49a6105F195460140C22a1Be7A2b1A7Bd7C7faf8);

  // Typical bridge-receive gas limits sit in the 200k–500k range; pick a value that
  // covers the receive + Collector forwarding path with comfortable headroom.
  uint32 public constant XLAYER_BRIDGE_GAS_LIMIT = 450_000;

  function execute() external {
    IGhoToken(AaveV3EthereumAssets.GHO_UNDERLYING).addFacilitator(
      DIRECT_FACILITATOR,
      DIRECT_FACILITATOR_NAME,
      RemoteGSMLaunchXLayerSetup.DIRECT_FACILITATOR_CAPACITY
    );

    IGhoDirectFacilitator(DIRECT_FACILITATOR).mint(
      address(this),
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT
    );

    IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).forceApprove(
      CCIP_BRIDGE,
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT
    );

    // Configure the XLayer lane on the AaveGhoCcipBridge: maps the XLayer chain selector to the
    // counterpart bridge address on XLayer (which forwards the GHO to AaveV3XLayer.COLLECTOR on
    // receipt). `extraArgs` is left empty so the bridge uses its default CCIP extraArgs encoding
    // with the gas limit below.
    IAaveGhoCcipBridge(CCIP_BRIDGE).setDestinationChain(
      CCIPChainSelectors.XLAYER,
      abi.encode(XLAYER_BRIDGE_DESTINATION),
      bytes(''),
      XLAYER_BRIDGE_GAS_LIMIT
    );

    // Bridge already has LINK to bridge, no need to send for fee.
    // This step will fail if Part 1 is not executed first to set the augmented bridge limit (RateLimitExceeded error).
    IAaveGhoCcipBridge(CCIP_BRIDGE).send(
      CCIPChainSelectors.XLAYER,
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
      AaveV3EthereumAssets.LINK_UNDERLYING
    );

    // Restore ONLY the Ethereum <> XLayer lane rate-limit config to its standard values, undoing
    // the temporary bump from Part 1. Every other lane is intentionally left untouched so this
    // proposal does not change GHO lane capacities across the rest of the network.
    // NOTE: the global bridge limit raised in Part 1 is intentionally NOT reduced here: the 25M
    // just bridged out is now part of the locked supply, so the elevated limit reflects reality.
    RemoteGSMLaunchXLayerSetup.restoreLaneRateLimitConfig(
      GhoEthereum.GHO_CCIP_TOKEN_POOL,
      CCIPChainSelectors.XLAYER
    );
  }
}
