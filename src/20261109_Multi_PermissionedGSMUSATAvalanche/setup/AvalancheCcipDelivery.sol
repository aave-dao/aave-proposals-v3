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
 * @title AvalancheCcipDelivery
 * @author TokenLogic
 * @notice Test helpers that stand in for the CCIP message from Ethereum on the Avalanche fork.
 */
abstract contract AvalancheCcipDelivery is Test {
  /// @dev Ethereum -> Avalanche OffRamp registered on the Avalanche router at the fork block
  /// https://snowscan.xyz/address/0x65D04D8dA1405b50d3508aaF94e1B6F5f1A3895C
  address internal constant CCIP_ETH_OFFRAMP = 0x65D04D8dA1405b50d3508aaF94e1B6F5f1A3895C;

  /**
   * @notice Asserts that the hard-coded OffRamp is live for the Avalanche GHO token pool.
   * @dev Checks that the pool uses the Avalanche router, and that this router lists CCIP_ETH_OFFRAMP as the
   * OffRamp for Ethereum, so the pool accepts CCIP_ETH_OFFRAMP as the caller of `releaseOrMint`.
   */
  function _assertOffRampRegistered() internal view {
    assertEq(
      IUpgradeableBurnMintTokenPool_1_5_1(GhoAvalanche.GHO_CCIP_TOKEN_POOL).getRouter(),
      CCIPChainRouters.AVALANCHE,
      'GHO token pool does not use the Avalanche router'
    );
    assertTrue(
      IRouter(CCIPChainRouters.AVALANCHE).isOffRamp(CCIPChainSelectors.ETHEREUM, CCIP_ETH_OFFRAMP),
      'CCIP_ETH_OFFRAMP is not a registered Ethereum -> Avalanche OffRamp'
    );
  }

  /**
   * @notice Simulates the Avalanche side of the CCIP message that bridges `amount` GHO from Ethereum to the Collector.
   * @dev The mint consumes the Ethereum lane's inbound rate limit, so the delivery reverts if `amount` exceeds
   * its current capacity, which Avalanche Part 1 raises.
   * @param amount The GHO amount to deliver, in base units (18 decimals).
   */
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
        // dummy id, the bridge uses it only in events and as the key of a failed message
        messageId: keccak256('usat-gsm-funding'),
        sourceChainSelector: CCIPChainSelectors.ETHEREUM,
        sender: abi.encode(GhoEthereum.GHO_CCIP_BRIDGE),
        data: new bytes(0),
        destTokenAmounts: tokenAmounts
      })
    );
  }
}
