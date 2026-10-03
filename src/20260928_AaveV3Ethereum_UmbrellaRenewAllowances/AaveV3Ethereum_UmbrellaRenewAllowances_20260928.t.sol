// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {UmbrellaEthereum, UmbrellaEthereumAssets} from 'aave-address-book/UmbrellaEthereum.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {IncentivizedERC20} from 'aave-v3-origin/contracts/protocol/tokenization/base/IncentivizedERC20.sol';
import {IRewardsController} from 'aave-umbrella/rewards/interfaces/IRewardsController.sol';
import {IRewardsStructs} from 'aave-umbrella/rewards/interfaces/IRewardsStructs.sol';
import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_UmbrellaRenewAllowances_20260928} from './AaveV3Ethereum_UmbrellaRenewAllowances_20260928.sol';

/**
 * @dev Test for AaveV3Ethereum_UmbrellaRenewAllowances_20260928
 * command:
 *  FOUNDRY_PROFILE=test forge test \
 *    --match-path=src/20260928_AaveV3Ethereum_UmbrellaRenewAllowances/AaveV3Ethereum_UmbrellaRenewAllowances_20260928.t.sol \
 *    -vv
 */
contract AaveV3Ethereum_UmbrellaRenewAllowances_20260928_Test is ProtocolV3TestBase {
  uint256 internal constant STAKE_MULTIPLIER = 99;

  // sum of calculateCurrentUserReward across all stake token holders at block 26075443
  uint256 internal constant USDT_UNCLAIMED = 264_923.009008e6;
  uint256 internal constant USDC_UNCLAIMED = 248_101.3744e6;
  uint256 internal constant WETH_UNCLAIMED = 69.347e18;

  IRewardsController internal constant REWARDS_CONTROLLER =
    IRewardsController(UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER);

  AaveV3Ethereum_UmbrellaRenewAllowances_20260928 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26075443);
    proposal = new AaveV3Ethereum_UmbrellaRenewAllowances_20260928();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_UmbrellaRenewAllowances_20260928',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_allowancesAfter() public {
    address collector = address(AaveV3Ethereum.COLLECTOR);
    address rewardsController = UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER;

    executePayload(vm, address(proposal));

    uint256 aUsdtAfter = IERC20Metadata(AaveV3EthereumAssets.USDT_A_TOKEN).allowance(
      collector,
      rewardsController
    );
    uint256 aUsdcAfter = IERC20Metadata(AaveV3EthereumAssets.USDC_A_TOKEN).allowance(
      collector,
      rewardsController
    );
    uint256 aWethAfter = IERC20Metadata(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
      collector,
      rewardsController
    );

    assertEq(
      aUsdtAfter,
      proposal.USDT_ABSOLUTE_ALLOWANCE(),
      'post-proposal USDT allowance should equal the absolute target'
    );
    assertEq(
      aUsdcAfter,
      proposal.USDC_ABSOLUTE_ALLOWANCE(),
      'post-proposal USDC allowance should equal the absolute target'
    );
    assertEq(
      aWethAfter,
      proposal.WETH_ABSOLUTE_ALLOWANCE(),
      'post-proposal WETH allowance should equal the absolute target'
    );
  }

  function test_allowancesCoverUnclaimedAndRemainingEmission() public view {
    assertGe(
      proposal.USDT_ABSOLUTE_ALLOWANCE(),
      _requiredUntilDistributionEnd(
        address(UmbrellaEthereumAssets.STK_WA_USDT_V1),
        AaveV3EthereumAssets.USDT_A_TOKEN,
        USDT_UNCLAIMED
      ),
      'USDT allowance should cover unclaimed rewards plus remaining emission'
    );
    assertGe(
      proposal.USDC_ABSOLUTE_ALLOWANCE(),
      _requiredUntilDistributionEnd(
        address(UmbrellaEthereumAssets.STK_WA_USDC_V1),
        AaveV3EthereumAssets.USDC_A_TOKEN,
        USDC_UNCLAIMED
      ),
      'USDC allowance should cover unclaimed rewards plus remaining emission'
    );
    assertGe(
      proposal.WETH_ABSOLUTE_ALLOWANCE(),
      _requiredUntilDistributionEnd(
        address(UmbrellaEthereumAssets.STK_WA_WETH_V1),
        AaveV3EthereumAssets.WETH_A_TOKEN,
        WETH_UNCLAIMED
      ),
      'WETH allowance should cover unclaimed rewards plus remaining emission'
    );
  }

  function test_stakersCanClaimUsdtRewards() public {
    address largeStaker = makeAddr('largeStaker');
    _testStakersCanClaim(
      address(UmbrellaEthereumAssets.STK_WA_USDT_V1),
      AaveV3EthereumAssets.USDT_A_TOKEN,
      largeStaker,
      _usdtStakers(largeStaker)
    );
  }

  function test_stakersCanClaimUsdcRewards() public {
    address largeStaker = makeAddr('largeStaker');
    _testStakersCanClaim(
      address(UmbrellaEthereumAssets.STK_WA_USDC_V1),
      AaveV3EthereumAssets.USDC_A_TOKEN,
      largeStaker,
      _usdcStakers(largeStaker)
    );
  }

  function test_stakersCanClaimWethRewards() public {
    address largeStaker = makeAddr('largeStaker');
    _testStakersCanClaim(
      address(UmbrellaEthereumAssets.STK_WA_WETH_V1),
      AaveV3EthereumAssets.WETH_A_TOKEN,
      largeStaker,
      _wethStakers(largeStaker)
    );
  }

  function claimAllUsers(address stakeVault, address reward, address[] memory users) external {
    for (uint256 i; i < users.length; ++i) {
      uint256 balanceBefore = IERC20Metadata(reward).balanceOf(users[i]);
      vm.prank(users[i]);
      REWARDS_CONTROLLER.claimAllRewards(stakeVault, users[i]);
      assertGt(
        IERC20Metadata(reward).balanceOf(users[i]),
        balanceBefore,
        'staker should receive rewards'
      );
    }
  }

  function _testStakersCanClaim(
    address stakeVault,
    address reward,
    address largeStaker,
    address[] memory stakers
  ) internal {
    _stake(stakeVault, largeStaker);
    vm.warp(REWARDS_CONTROLLER.getRewardData(stakeVault, reward).distributionEnd);

    try this.claimAllUsers(stakeVault, reward, stakers) {
      revert('pre-proposal claims should revert');
    } catch (bytes memory reason) {
      assertEq(
        bytes4(reason),
        IncentivizedERC20.ERC20InsufficientAllowance.selector,
        'pre-proposal claims should revert on insufficient allowance'
      );
    }

    executePayload(vm, address(proposal));

    try this.claimAllUsers(stakeVault, reward, stakers) {} catch {
      revert('post-proposal claims should succeed');
    }
  }

  /// @dev Upper bound of what the rewards controller can pull from the Collector until distributionEnd.
  function _requiredUntilDistributionEnd(
    address stakeVault,
    address reward,
    uint256 unclaimed
  ) internal view returns (uint256) {
    IRewardsStructs.RewardDataExternal memory data = REWARDS_CONTROLLER.getRewardData(
      stakeVault,
      reward
    );
    return unclaimed + data.maxEmissionPerSecond * (data.distributionEnd - block.timestamp);
  }

  /// @dev Stakes STAKE_MULTIPLIER times the vault's assets, so it accrues almost all emission left until distributionEnd.
  function _stake(address stakeVault, address largeStaker) internal {
    IERC20Metadata asset = IERC20Metadata(IERC4626(stakeVault).asset());
    uint256 amount = IERC4626(stakeVault).totalAssets() * STAKE_MULTIPLIER;

    deal(address(asset), largeStaker, amount);
    vm.startPrank(largeStaker);
    asset.approve(stakeVault, amount);
    IERC4626(stakeVault).deposit(amount, largeStaker);
    vm.stopPrank();
  }

  /// @dev Top usdt stakers with unclaimed rewards and current top staker
  function _usdtStakers(address largeStaker) internal pure returns (address[] memory users) {
    users = new address[](14);
    users[0] = 0xbBd0D0406f5106bfC36b0b40263764D834fbBdEf;
    users[1] = 0xf07766108Cdb54082F7B06CAd20d6ADAb1342d46;
    users[2] = 0xe71b445ff9c375cB3B224304E3B0c11577E8227b;
    users[3] = 0x40bD1a961eD45493b7A0B5d865ddC378c8C93019;
    users[4] = 0xeC819b5E1d3B4549cAb841D894A09DF965b240e0;
    users[5] = 0xF8F06bA7Ad82e4c3Ea59a3F066dFC7390ED4bD8A;
    users[6] = 0x05279914272C6b352c2afd50f20a892cA8938092;
    users[7] = 0x674cE5965471f867F9649BBe69802b24FFEd7f04;
    users[8] = 0xDa8820bb10Fd38fbD2bed72d13A33E7E5D15D185;
    users[9] = 0x942c34c92BDF7bb86ce206A186A8139a0B94DefB;
    users[10] = 0x504bb8F14E467CA71c47984725125aDcCaA2Ce99;
    users[11] = 0x5A2a98d3C9720734C2Fca8d5ec808B073c047Ccd;
    users[12] = 0xa9FA0F4F573a62A19fb6a3FFeCe9f9a285cbac8F;
    users[13] = largeStaker;
  }

  /// @dev Top usdc stakers with unclaimed rewards and current top staker
  function _usdcStakers(address largeStaker) internal pure returns (address[] memory users) {
    users = new address[](20);
    users[0] = 0xeE0CfAaa640916c68CA865Fcbdc2cA0fcb670D0C;
    users[1] = 0xfbeb5B79Ad0C3643Dc3c904eA28981CbcA709B3a;
    users[2] = 0xf9587365a5Ab255CFE8947Bb6B8F5E967A31191f;
    users[3] = 0xd98c48E20eEfa06788d305BB8C56b6c901389E48;
    users[4] = 0xb440a60a5972320b3A168a7d3ECaB513BF78a63E;
    users[5] = 0x7824f9796Dea77aE4F41E79190878c8aDA8ff23e;
    users[6] = 0xDD62115f601dAeBCCfDd2aEED834513D8DC2F4E2;
    users[7] = 0x2D023900f5b8E011aF48F8047368CDae513609e4;
    users[8] = 0x28a4cd868e9a6932B4FC49a401962156A9d18725;
    users[9] = 0xcBC463BeAe0DA08a439DC9d10a5690c084eF6B25;
    users[10] = 0x0E12d87Fa6B79ac834963BB0Ae65701a50d1556B;
    users[11] = 0x5b2e99156f553d7A364DB873AfC81ba06c4d696c;
    users[12] = 0xb0758D59a2206602Fe7e5A984b436D45C581FEEd;
    users[13] = 0x5A2a98d3C9720734C2Fca8d5ec808B073c047Ccd;
    users[14] = 0x3E2B9020fB2e18767e2017e1DE7A43b1F23A2815;
    users[15] = 0xe6E5CC36B249B477f923047288C8918954879183;
    users[16] = 0xe103ABFa0F867E53ceF1AD2Cb0dCbC193b385A93;
    users[17] = 0xc7a300d91dcAF3CaC0bCc171C543d8E51f0e75Ef;
    users[18] = 0x40bD1a961eD45493b7A0B5d865ddC378c8C93019;
    users[19] = largeStaker;
  }

  /// @dev Top weth stakers with unclaimed rewards and current top staker
  function _wethStakers(address largeStaker) internal pure returns (address[] memory users) {
    users = new address[](15);
    users[0] = 0xee27B8031b51575Ae9Aaaa7c21b93FEA242A82Ce;
    users[1] = 0xE7B009F26aae94C3d5919c327E0c4DafE5137aa9;
    users[2] = 0x49D29b200A9F8929D1E368A00097372E41794399;
    users[3] = 0x1367D4854424847A240ce666C576bE2294daE099;
    users[4] = 0xdBbc8499614fcafB958829BD3143384cEb59779E;
    users[5] = 0x20a270f243C228e549C9353504dcF2c0977D69D7;
    users[6] = 0x619BEfCFbdE157ab8a27775BED7fc532c34280E6;
    users[7] = 0x752092f89Ff72c008Aa7ad016ED6c6AC54EF9558;
    users[8] = 0x78A83110C440A6bE66132894a0920976d061B26f;
    users[9] = 0xB6647caE065c321e75775B50a25fd54e9ac5C436;
    users[10] = 0xC025C03E10f656D3ee76685d53d236824d8eF3da;
    users[11] = 0x24CD35F90F0907BEDe762A0d35f1978c5758C562;
    users[12] = 0x0199b45426a2CbCFEDD8d346f7756243A22BFcf5;
    users[13] = 0x58a48b6cfA8B813757aD8627265741C679bb4445;
    users[14] = largeStaker;
  }
}
