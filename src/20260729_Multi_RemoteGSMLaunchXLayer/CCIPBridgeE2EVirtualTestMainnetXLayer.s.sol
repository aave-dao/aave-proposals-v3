// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TenderlyVirtualTestnetBase} from 'src/helpers/gsm-launch/TenderlyVirtualTestnetBase.sol';
import {GovNetworks} from 'src/helpers/gsm-launch/GovNetworks.sol';

import {AaveV3XLayer} from 'aave-address-book/AaveV3XLayer.sol';
import {GhoXLayer} from 'aave-address-book/GhoXLayer.sol';

import {AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1} from './AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1.sol';
import {AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2} from './AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2.sol';
import {AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1} from './AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1.sol';
import {AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2} from './AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2.sol';

import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

contract CCIPBridgeE2EVirtualTestMainnetXLayer is TenderlyVirtualTestnetBase {
  string private constant MAINNET = 'mainnet_virtual';
  string private constant XLAYER = 'xlayer_virtual';

  uint256 internal ghoBefore;

  function run() external {
    // Snapshot so Virtual Testnet does not drift
    string[] memory aliases = new string[](2);
    aliases[0] = MAINNET;
    aliases[1] = XLAYER;
    _snapshotLifecycle(aliases, './snapshot');

    GovNetworks.GovNetwork memory eth = GovNetworks.mainnet();
    GovNetworks.GovNetwork memory xlayer = GovNetworks.xlayer();

    // Deploy payloads on Virtual Testnet
    address ethPart1 = _deployPayloadOn(
      eth,
      type(AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part1).creationCode
    );
    address ethPart2 = _deployPayloadOn(
      eth,
      type(AaveV3Ethereum_RemoteGSMLaunchXLayer_20260729_Part2).creationCode
    );
    address xlayerPart1 = _deployPayloadOn(
      xlayer,
      type(AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part1).creationCode
    );
    address xlayerPart2 = _deployPayloadOn(
      xlayer,
      type(AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2).creationCode
    );

    // Execute XLayer Part 1
    // In practice, Eth Part 1 and Eth Part 2 could be executed prior to XLayer Part 1; this
    // script executes XLayer Part 1 first because the Virtual Testnets do not support
    // execution delays.
    _refork(xlayer.rpcAlias);
    (uint256 capBefore, ) = IGhoToken(GhoXLayer.GHO_TOKEN).getFacilitatorBucket(
      GhoXLayer.GHO_CCIP_TOKEN_POOL
    );

    _executePayloadOn(xlayer, xlayerPart1);
    _refork(xlayer.rpcAlias);

    (uint256 capAfter, ) = IGhoToken(GhoXLayer.GHO_TOKEN).getFacilitatorBucket(
      GhoXLayer.GHO_CCIP_TOKEN_POOL
    );
    require(
      capAfter == capBefore + RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
      'XLayer Part 1: bucket not increased'
    );

    ghoBefore = IGhoToken(GhoXLayer.GHO_TOKEN).balanceOf(address(AaveV3XLayer.COLLECTOR));

    _executePayloadOn(eth, ethPart1);
    _refork(eth.rpcAlias);
    _increaseTime(5 seconds);
    _executePayloadOn(eth, ethPart2);

    _pollUntilDelivered(xlayer.rpcAlias, 60, 3000);

    _executePayloadOn(xlayer, xlayerPart2);

    // Assert Part 2 landed the bridged GHO in the reserve and configured the USDG GSM.
    _refork(XLAYER);
    _assertXLayerPart2(AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2(xlayerPart2));
  }

  /// @dev End-state checks for XLayer Part 2, read from the payload's own constants so the
  /// expected addresses can't drift from what was executed.
  function _assertXLayerPart2(AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2 payload) internal {
    address gsm = payload.GSM_USDG();
    IGhoReserve reserve = payload.GHO_RESERVE();

    // Bridged GHO reached the reserve (Collector -> GhoReserve forward in Part 2).
    require(
      IGhoToken(GhoXLayer.GHO_TOKEN).balanceOf(address(reserve)) ==
        RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT,
      'XLayer Part2: reserve not funded with bridged GHO'
    );
    // GSM enrolled with its reserve draw limit.
    require(
      reserve.getLimit(gsm) == RemoteGSMLaunchXLayerSetup.GSM_USDG_RESERVE_LIMIT,
      'XLayer Part2: wrong GSM reserve limit'
    );
    // GSM wired to the reserve and configured with cap + fee strategy.
    require(IGsm(gsm).getGhoReserve() == address(reserve), 'XLayer Part2: GSM reserve not set');
    require(
      IGsm(gsm).getExposureCap() == RemoteGSMLaunchXLayerSetup.GSM_USDG_INITIAL_EXPOSURE_CAP,
      'XLayer Part2: wrong GSM exposure cap'
    );
    require(
      IGsm(gsm).getFeeStrategy() == payload.GSM_USDG_FEE_STRATEGY(),
      'XLayer Part2: fee strategy not set'
    );
    // GSM registered in the registry.
    IGsmRegistry registry = IGsmRegistry(payload.GSM_REGISTRY());
    require(registry.getGsmListLength() == 1, 'XLayer Part2: GSM not registered');
    require(registry.getGsmAtIndex(0) == gsm, 'XLayer Part2: wrong GSM registered');
  }

  function _isDelivered() internal view override returns (bool) {
    return
      IGhoToken(GhoXLayer.GHO_TOKEN).balanceOf(address(AaveV3XLayer.COLLECTOR)) >=
      ghoBefore + RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT;
  }
}
