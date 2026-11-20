// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GhoAvalanche} from 'aave-address-book/GhoAvalanche.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {Client} from 'aave-helpers/src/dependencies/chainlink/libraries/Client.sol';
import {IAny2EVMMessageReceiver} from 'aave-helpers/src/dependencies/chainlink/interfaces/IAny2EVMMessageReceiver.sol';
import {IUpgradeableBurnMintTokenPool_1_5_1} from 'src/interfaces/ccip/tokenPool/IUpgradeableBurnMintTokenPool.sol';
import {IPool as IPool_CCIP} from 'src/interfaces/ccip/tokenPool/IPool.sol';
import {IRouter} from 'src/interfaces/ccip/IRouter.sol';
import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {CCIPChainRouters} from 'src/helpers/gho-launch/constants/CCIPChainRouters.sol';

/**
 * @dev Simulates the Ethereum -> Avalanche delivery of the bridged GHO: the OffRamp mints through the
 * GHO token pool into the Avalanche AaveGhoCcipBridge, then the Router calls `ccipReceive`, which forwards
 * the GHO to the Avalanche Collector.
 */
abstract contract AvalancheCcipDelivery is Test {
  // Ethereum -> Avalanche OffRamp registered on the Avalanche router at the fork block
  // https://snowscan.xyz/address/0x65D04D8dA1405b50d3508aaF94e1B6F5f1A3895C
  address internal constant CCIP_ETH_OFFRAMP = 0x65D04D8dA1405b50d3508aaF94e1B6F5f1A3895C;

  function _assertOffRampRegistered() internal view {
    assertTrue(
      IRouter(CCIPChainRouters.AVALANCHE).isOffRamp(CCIPChainSelectors.ETHEREUM, CCIP_ETH_OFFRAMP),
      'CCIP_ETH_OFFRAMP is not a registered Ethereum -> Avalanche OffRamp'
    );
  }

  function _deliverToAvalancheCollector(uint256 amount) internal {
    vm.prank(CCIP_ETH_OFFRAMP);
    IUpgradeableBurnMintTokenPool_1_5_1(GhoAvalanche.GHO_CCIP_TOKEN_POOL).releaseOrMint(
      IPool_CCIP.ReleaseOrMintInV1({
        originalSender: abi.encode(GhoEthereum.GHO_CCIP_BRIDGE),
        remoteChainSelector: CCIPChainSelectors.ETHEREUM,
        receiver: GhoAvalanche.GHO_CCIP_BRIDGE,
        amount: amount,
        localToken: GhoAvalanche.GHO_TOKEN,
        sourcePoolAddress: abi.encode(GhoEthereum.GHO_CCIP_TOKEN_POOL),
        sourcePoolData: new bytes(0),
        offchainTokenData: new bytes(0)
      })
    );

    Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
    tokenAmounts[0] = Client.EVMTokenAmount({token: GhoAvalanche.GHO_TOKEN, amount: amount});

    vm.prank(CCIPChainRouters.AVALANCHE);
    IAny2EVMMessageReceiver(GhoAvalanche.GHO_CCIP_BRIDGE).ccipReceive(
      Client.Any2EVMMessage({
        messageId: keccak256('usat-gsm-funding'),
        sourceChainSelector: CCIPChainSelectors.ETHEREUM,
        sender: abi.encode(GhoEthereum.GHO_CCIP_BRIDGE),
        data: new bytes(0),
        destTokenAmounts: tokenAmounts
      })
    );
  }
}
