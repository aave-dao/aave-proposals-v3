// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Monad} from 'aave-address-book/GovernanceV3Monad.sol';
import {GovernanceV3XLayer} from 'aave-address-book/GovernanceV3XLayer.sol';

library GovNetworks {
  struct GovNetwork {
    string rpcAlias;
    address payloadsController;
    address executor;
  }

  function arbitrum() internal pure returns (GovNetwork memory) {
    return
      GovNetwork(
        'arbitrum_virtual',
        address(GovernanceV3Arbitrum.PAYLOADS_CONTROLLER),
        GovernanceV3Arbitrum.EXECUTOR_LVL_1
      );
  }

  function mainnet() internal pure returns (GovNetwork memory) {
    return
      GovNetwork(
        'mainnet_virtual',
        address(GovernanceV3Ethereum.PAYLOADS_CONTROLLER),
        GovernanceV3Ethereum.EXECUTOR_LVL_1
      );
  }

  function monad() internal pure returns (GovNetwork memory) {
    return
      GovNetwork(
        'monad_virtual',
        address(GovernanceV3Monad.PAYLOADS_CONTROLLER),
        GovernanceV3Monad.EXECUTOR_LVL_1
      );
  }

  function xlayer() internal pure returns (GovNetwork memory) {
    return
      GovNetwork(
        'xlayer_virtual',
        address(GovernanceV3XLayer.PAYLOADS_CONTROLLER),
        GovernanceV3XLayer.EXECUTOR_LVL_1
      );
  }
}
