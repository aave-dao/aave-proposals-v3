// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {UmbrellaEthereum, UmbrellaEthereumAssets} from 'aave-address-book/UmbrellaEthereum.sol';
import {IUmbrella} from 'aave-address-book/common/IUmbrella.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {IRewardsController} from 'aave-umbrella/rewards/interfaces/IRewardsController.sol';
import {IRewardsStructs} from 'aave-umbrella/rewards/interfaces/IRewardsStructs.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124} from './AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124.sol';

/**
 * @dev Test for AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261124_AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core/AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124.t.sol -vv
 */
contract AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124_Test is
  ProtocolV3TestBase
{
  IRewardsController internal constant REWARDS_CONTROLLER =
    IRewardsController(UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER);

  // staking 99x totalAssets keeps the stake far above 120% of target, so emission is the flat 80%
  uint256 internal constant STAKE_MULTIPLIER = 99;

  // totalAssets >= 120% of target emits 80% of maxEmissionPerSecond
  uint256 internal constant FLAT_EMISSION_BPS = 80_00;
  uint256 internal constant BPS = 100_00;
  uint256 internal constant CLAIM_TOLERANCE = 0.000001e18;

  uint256 internal constant NEW_DISTRIBUTION_END = 1806624000; // 2027-04-02 00:00:00 UTC

  uint256 internal constant USDC_CURRENT_TARGET_LIQUIDITY = 32_518_555e6;
  uint256 internal constant USDT_CURRENT_TARGET_LIQUIDITY = 34_114_525e6;
  uint256 internal constant WETH_TARGET_LIQUIDITY = 17_437.44e18;
  uint256 internal constant USDC_NEW_TARGET_LIQUIDITY = 38_345_557e6;
  uint256 internal constant USDT_NEW_TARGET_LIQUIDITY = 38_194_079e6;

  uint256 internal constant USDC_CURRENT_EMISSION = 38685;
  uint256 internal constant USDT_CURRENT_EMISSION = 40588;
  uint256 internal constant WETH_EMISSION = 14903602232369;
  uint256 internal constant USDC_NEW_EMISSION = 36307;
  uint256 internal constant USDT_NEW_EMISSION = 35832;

  uint256 internal constant USDC_CURRENT_DISTRIBUTION_END = 1796197007;
  uint256 internal constant USDT_CURRENT_DISTRIBUTION_END = 1796197223;
  uint256 internal constant WETH_CURRENT_DISTRIBUTION_END = 1796197283;

  uint256 internal constant USDC_ABSOLUTE_ALLOWANCE = 700_000e6;
  uint256 internal constant USDT_ABSOLUTE_ALLOWANCE = 655_000e6;
  uint256 internal constant WETH_ABSOLUTE_ALLOWANCE = 270e18;

  uint256 internal constant USDC_DEFICIT_OFFSET = 1_300_000e6;
  uint256 internal constant USDT_DEFICIT_OFFSET = 1_600_000e6;
  uint256 internal constant WETH_DEFICIT_OFFSET = 53_041.439525910725842244e18;
  uint256 internal constant GHO_DEFICIT_OFFSET = 3_000_000e18;

  // a staker in each module at block 26484891
  address internal constant USDC_STAKER = 0xeE0CfAaa640916c68CA865Fcbdc2cA0fcb670D0C;
  address internal constant USDT_STAKER = 0x40bD1a961eD45493b7A0B5d865ddC378c8C93019;
  address internal constant WETH_STAKER = 0xee27B8031b51575Ae9Aaaa7c21b93FEA242A82Ce;

  // sum of calculateCurrentUserReward at block 26484891 over every Transfer from/to address of each stake token since deployment (incl. exited holders)
  uint256 internal constant USDC_UNCLAIMED = 263_416.652094e6;
  uint256 internal constant USDT_UNCLAIMED = 202_042.977524e6;
  uint256 internal constant WETH_UNCLAIMED = 86.670484338133596782e18;

  AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26484891);
    proposal = new AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_UmbrellaRewardRenewalAndParameterUpdateOnAaveV3Core_20261124',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_targetLiquidityUpdated() public {
    assertEq(
      _targetLiquidity(address(UmbrellaEthereumAssets.STK_WA_USDC_V1)),
      USDC_CURRENT_TARGET_LIQUIDITY
    );
    assertEq(
      _targetLiquidity(address(UmbrellaEthereumAssets.STK_WA_USDT_V1)),
      USDT_CURRENT_TARGET_LIQUIDITY
    );
    assertEq(
      _targetLiquidity(address(UmbrellaEthereumAssets.STK_WA_WETH_V1)),
      WETH_TARGET_LIQUIDITY
    );

    executePayload(vm, address(proposal));

    assertEq(
      _targetLiquidity(address(UmbrellaEthereumAssets.STK_WA_USDC_V1)),
      USDC_NEW_TARGET_LIQUIDITY
    );
    assertEq(
      _targetLiquidity(address(UmbrellaEthereumAssets.STK_WA_USDT_V1)),
      USDT_NEW_TARGET_LIQUIDITY
    );
    assertEq(
      _targetLiquidity(address(UmbrellaEthereumAssets.STK_WA_WETH_V1)),
      WETH_TARGET_LIQUIDITY
    );
  }

  function test_maxEmissionPerSecondUpdated() public {
    assertEq(_usdcEmission(), USDC_CURRENT_EMISSION);
    assertEq(_usdtEmission(), USDT_CURRENT_EMISSION);
    assertEq(_wethEmission(), WETH_EMISSION);

    executePayload(vm, address(proposal));

    assertEq(_usdcEmission(), USDC_NEW_EMISSION);
    assertEq(_usdtEmission(), USDT_NEW_EMISSION);
    assertEq(_wethEmission(), WETH_EMISSION);
  }

  function test_distributionEndExtended() public {
    assertEq(_usdcEnd(), USDC_CURRENT_DISTRIBUTION_END);
    assertEq(_usdtEnd(), USDT_CURRENT_DISTRIBUTION_END);
    assertEq(_wethEnd(), WETH_CURRENT_DISTRIBUTION_END);

    executePayload(vm, address(proposal));

    assertEq(_usdcEnd(), NEW_DISTRIBUTION_END);
    assertEq(_usdtEnd(), NEW_DISTRIBUTION_END);
    assertEq(_wethEnd(), NEW_DISTRIBUTION_END);
  }

  function test_rewardPayerStaysCollector() public {
    vm.expectEmit(UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER);
    emit IRewardsController.RewardConfigUpdated(
      address(UmbrellaEthereumAssets.STK_WA_USDC_V1),
      AaveV3EthereumAssets.USDC_A_TOKEN,
      USDC_NEW_EMISSION,
      NEW_DISTRIBUTION_END,
      address(AaveV3Ethereum.COLLECTOR)
    );
    vm.expectEmit(UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER);
    emit IRewardsController.RewardConfigUpdated(
      address(UmbrellaEthereumAssets.STK_WA_USDT_V1),
      AaveV3EthereumAssets.USDT_A_TOKEN,
      USDT_NEW_EMISSION,
      NEW_DISTRIBUTION_END,
      address(AaveV3Ethereum.COLLECTOR)
    );
    vm.expectEmit(UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER);
    emit IRewardsController.RewardConfigUpdated(
      address(UmbrellaEthereumAssets.STK_WA_WETH_V1),
      AaveV3EthereumAssets.WETH_A_TOKEN,
      WETH_EMISSION,
      NEW_DISTRIBUTION_END,
      address(AaveV3Ethereum.COLLECTOR)
    );

    executePayload(vm, address(proposal));
  }

  function test_allowancesAbsolute() public {
    assertLt(_allowance(AaveV3EthereumAssets.USDC_A_TOKEN), USDC_ABSOLUTE_ALLOWANCE);
    assertLt(_allowance(AaveV3EthereumAssets.USDT_A_TOKEN), USDT_ABSOLUTE_ALLOWANCE);
    assertLt(_allowance(AaveV3EthereumAssets.WETH_A_TOKEN), WETH_ABSOLUTE_ALLOWANCE);

    executePayload(vm, address(proposal));

    assertEq(_allowance(AaveV3EthereumAssets.USDC_A_TOKEN), USDC_ABSOLUTE_ALLOWANCE);
    assertEq(_allowance(AaveV3EthereumAssets.USDT_A_TOKEN), USDT_ABSOLUTE_ALLOWANCE);
    assertEq(_allowance(AaveV3EthereumAssets.WETH_A_TOKEN), WETH_ABSOLUTE_ALLOWANCE);
  }

  function test_ghoAndDeficitOffsetsUnchanged() public {
    bytes32 ghoRewardBefore = _ghoRewardHash();
    uint256 ghoAllowanceBefore = _allowance(AaveV3EthereumAssets.GHO_UNDERLYING);
    _assertDeficitOffsets();

    executePayload(vm, address(proposal));

    assertEq(_ghoRewardHash(), ghoRewardBefore);
    assertEq(_allowance(AaveV3EthereumAssets.GHO_UNDERLYING), ghoAllowanceBefore);
    _assertDeficitOffsets();
  }

  function test_lateExecutionRestartsRewardsWithoutBackfill() public {
    vm.warp(WETH_CURRENT_DISTRIBUTION_END + 1 days);
    assertEq(_wethEmission(), 0);
    uint256 usdcAccruedAtOldEnd = _usdcAccrued(USDC_STAKER);
    uint256 usdtAccruedAtOldEnd = _usdtAccrued(USDT_STAKER);
    uint256 wethAccruedAtOldEnd = _wethAccrued(WETH_STAKER);

    executePayload(vm, address(proposal));

    // the gap between the old distributionEnd and execution is not backfilled
    assertEq(_usdcAccrued(USDC_STAKER), usdcAccruedAtOldEnd);
    assertEq(_usdtAccrued(USDT_STAKER), usdtAccruedAtOldEnd);
    assertEq(_wethAccrued(WETH_STAKER), wethAccruedAtOldEnd);
    vm.warp(block.timestamp + 1 hours);
    assertGt(_usdcAccrued(USDC_STAKER), usdcAccruedAtOldEnd);
    assertGt(_usdtAccrued(USDT_STAKER), usdtAccruedAtOldEnd);
    assertGt(_wethAccrued(WETH_STAKER), wethAccruedAtOldEnd);

    assertEq(_wethEmission(), WETH_EMISSION);
    assertEq(_usdcEmission(), USDC_NEW_EMISSION);
    assertEq(_usdtEmission(), USDT_NEW_EMISSION);
    assertEq(_usdcEnd(), NEW_DISTRIBUTION_END);
    assertEq(_usdtEnd(), NEW_DISTRIBUTION_END);
    assertEq(_wethEnd(), NEW_DISTRIBUTION_END);
  }

  function test_allowancesCoverUnclaimedAndRemainingEmission() public {
    executePayload(vm, address(proposal));

    assertGe(
      _allowance(AaveV3EthereumAssets.USDC_A_TOKEN),
      USDC_UNCLAIMED +
        _maxEmissions(USDC_CURRENT_EMISSION, USDC_NEW_EMISSION, USDC_CURRENT_DISTRIBUTION_END)
    );
    assertGe(
      _allowance(AaveV3EthereumAssets.USDT_A_TOKEN),
      USDT_UNCLAIMED +
        _maxEmissions(USDT_CURRENT_EMISSION, USDT_NEW_EMISSION, USDT_CURRENT_DISTRIBUTION_END)
    );
    assertGe(
      _allowance(AaveV3EthereumAssets.WETH_A_TOKEN),
      WETH_UNCLAIMED + _maxEmissions(WETH_EMISSION, WETH_EMISSION, WETH_CURRENT_DISTRIBUTION_END)
    );
  }

  // max emissions from now until 2027-04-02: the current rate until the 2026-12-02 end, then the proposed rate
  // (an upper bound: before 2026-12-02, execution starts the lower USDC and USDT rate early; after 2026-12-02, nothing accrues between 2026-12-02 and execution)
  function _maxEmissions(
    uint256 oldEmission,
    uint256 newEmission,
    uint256 oldEnd
  ) internal view returns (uint256) {
    return oldEmission * (oldEnd - block.timestamp) + newEmission * (NEW_DISTRIBUTION_END - oldEnd);
  }

  function test_stakersCanClaimUsdcRewards() public {
    address largeStaker = makeAddr('largeStaker');
    _testStakersCanClaim(
      address(UmbrellaEthereumAssets.STK_WA_USDC_V1),
      AaveV3EthereumAssets.USDC_A_TOKEN,
      largeStaker,
      _usdcStakers(largeStaker),
      USDC_CURRENT_EMISSION,
      USDC_NEW_EMISSION,
      USDC_CURRENT_DISTRIBUTION_END
    );
  }

  function test_stakersCanClaimUsdtRewards() public {
    address largeStaker = makeAddr('largeStaker');
    _testStakersCanClaim(
      address(UmbrellaEthereumAssets.STK_WA_USDT_V1),
      AaveV3EthereumAssets.USDT_A_TOKEN,
      largeStaker,
      _usdtStakers(largeStaker),
      USDT_CURRENT_EMISSION,
      USDT_NEW_EMISSION,
      USDT_CURRENT_DISTRIBUTION_END
    );
  }

  function test_stakersCanClaimWethRewards() public {
    address largeStaker = makeAddr('largeStaker');
    _testStakersCanClaim(
      address(UmbrellaEthereumAssets.STK_WA_WETH_V1),
      AaveV3EthereumAssets.WETH_A_TOKEN,
      largeStaker,
      _wethStakers(largeStaker),
      WETH_EMISSION,
      WETH_EMISSION,
      WETH_CURRENT_DISTRIBUTION_END
    );
  }

  function _claimAllUsers(address stakeVault, address[] memory users) internal {
    for (uint256 i; i < users.length; ++i) {
      vm.prank(users[i]);
      REWARDS_CONTROLLER.claimAllRewards(stakeVault, users[i]);
    }
  }

  function _testStakersCanClaim(
    address stakeVault,
    address reward,
    address largeStaker,
    address[] memory stakers,
    uint256 oldEmission,
    uint256 newEmission,
    uint256 oldEnd
  ) internal {
    _stake(stakeVault, largeStaker);
    uint256 allowanceBefore = _allowance(reward);
    uint256 expectedExtra = _expectedExtraClaim(
      stakeVault,
      largeStaker,
      oldEmission,
      newEmission,
      oldEnd
    );

    // without the payload rewards stop accruing at the old distributionEnd
    uint256 snapshotId = vm.snapshotState();
    vm.warp(NEW_DISTRIBUTION_END);
    _claimAllUsers(stakeVault, stakers);
    uint256 claimedWithoutPayload = IERC20Metadata(reward).balanceOf(largeStaker);
    vm.revertToState(snapshotId);

    executePayload(vm, address(proposal));
    uint256 allowanceSet = _allowance(reward);
    vm.warp(NEW_DISTRIBUTION_END);

    _claimAllUsers(stakeVault, stakers);
    assertApproxEqRel(
      IERC20Metadata(reward).balanceOf(largeStaker) - claimedWithoutPayload,
      expectedExtra,
      CLAIM_TOLERANCE
    );
    assertGt(
      allowanceSet - _allowance(reward),
      allowanceBefore,
      'claims must exceed the pre-payload allowance'
    );
  }

  function _expectedExtraClaim(
    address stakeVault,
    address largeStaker,
    uint256 oldEmission,
    uint256 newEmission,
    uint256 oldEnd
  ) internal view returns (uint256) {
    uint256 flatEmissions = (newEmission * (NEW_DISTRIBUTION_END - block.timestamp)) -
      (oldEmission * (oldEnd - block.timestamp));
    return
      (flatEmissions * FLAT_EMISSION_BPS * IERC20Metadata(stakeVault).balanceOf(largeStaker)) /
      (BPS * IERC20Metadata(stakeVault).totalSupply());
  }

  function _stake(address stakeVault, address largeStaker) internal {
    IERC20Metadata asset = IERC20Metadata(IERC4626(stakeVault).asset());
    uint256 amount = IERC4626(stakeVault).totalAssets() * STAKE_MULTIPLIER;

    deal(address(asset), largeStaker, amount);
    vm.startPrank(largeStaker);
    asset.approve(stakeVault, amount);
    IERC4626(stakeVault).deposit(amount, largeStaker);
    vm.stopPrank();
  }

  function _targetLiquidity(address stakeToken) internal view returns (uint256) {
    return REWARDS_CONTROLLER.getAssetData(stakeToken).targetLiquidity;
  }

  function _rewardData(
    address stakeToken,
    address reward
  ) internal view returns (IRewardsStructs.RewardDataExternal memory) {
    return REWARDS_CONTROLLER.getRewardData(stakeToken, reward);
  }

  function _usdcEmission() internal view returns (uint256) {
    return
      _rewardData(address(UmbrellaEthereumAssets.STK_WA_USDC_V1), AaveV3EthereumAssets.USDC_A_TOKEN)
        .maxEmissionPerSecond;
  }

  function _usdtEmission() internal view returns (uint256) {
    return
      _rewardData(address(UmbrellaEthereumAssets.STK_WA_USDT_V1), AaveV3EthereumAssets.USDT_A_TOKEN)
        .maxEmissionPerSecond;
  }

  function _wethEmission() internal view returns (uint256) {
    return
      _rewardData(address(UmbrellaEthereumAssets.STK_WA_WETH_V1), AaveV3EthereumAssets.WETH_A_TOKEN)
        .maxEmissionPerSecond;
  }

  function _usdcEnd() internal view returns (uint256) {
    return
      _rewardData(address(UmbrellaEthereumAssets.STK_WA_USDC_V1), AaveV3EthereumAssets.USDC_A_TOKEN)
        .distributionEnd;
  }

  function _usdtEnd() internal view returns (uint256) {
    return
      _rewardData(address(UmbrellaEthereumAssets.STK_WA_USDT_V1), AaveV3EthereumAssets.USDT_A_TOKEN)
        .distributionEnd;
  }

  function _wethEnd() internal view returns (uint256) {
    return
      _rewardData(address(UmbrellaEthereumAssets.STK_WA_WETH_V1), AaveV3EthereumAssets.WETH_A_TOKEN)
        .distributionEnd;
  }

  function _ghoRewardHash() internal view returns (bytes32) {
    return
      keccak256(
        abi.encode(
          _rewardData(
            address(UmbrellaEthereumAssets.STK_GHO_V1),
            AaveV3EthereumAssets.GHO_UNDERLYING
          )
        )
      );
  }

  function _allowance(address token) internal view returns (uint256) {
    return
      IERC20Metadata(token).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        UmbrellaEthereum.UMBRELLA_REWARDS_CONTROLLER
      );
  }

  function _assertDeficitOffsets() internal view {
    IUmbrella umbrella = IUmbrella(UmbrellaEthereum.UMBRELLA);
    assertEq(umbrella.getDeficitOffset(AaveV3EthereumAssets.USDC_UNDERLYING), USDC_DEFICIT_OFFSET);
    assertEq(umbrella.getDeficitOffset(AaveV3EthereumAssets.USDT_UNDERLYING), USDT_DEFICIT_OFFSET);
    assertEq(umbrella.getDeficitOffset(AaveV3EthereumAssets.WETH_UNDERLYING), WETH_DEFICIT_OFFSET);
    assertEq(umbrella.getDeficitOffset(AaveV3EthereumAssets.GHO_UNDERLYING), GHO_DEFICIT_OFFSET);
  }

  function _usdcAccrued(address user) internal view returns (uint256) {
    return
      REWARDS_CONTROLLER.calculateCurrentUserReward(
        address(UmbrellaEthereumAssets.STK_WA_USDC_V1),
        AaveV3EthereumAssets.USDC_A_TOKEN,
        user
      );
  }

  function _usdtAccrued(address user) internal view returns (uint256) {
    return
      REWARDS_CONTROLLER.calculateCurrentUserReward(
        address(UmbrellaEthereumAssets.STK_WA_USDT_V1),
        AaveV3EthereumAssets.USDT_A_TOKEN,
        user
      );
  }

  function _wethAccrued(address user) internal view returns (uint256) {
    return
      REWARDS_CONTROLLER.calculateCurrentUserReward(
        address(UmbrellaEthereumAssets.STK_WA_WETH_V1),
        AaveV3EthereumAssets.WETH_A_TOKEN,
        user
      );
  }

  // accounts with unclaimed rewards at block 26484891 (some no longer staked) and a new large staker
  function _usdtStakers(address largeStaker) internal pure returns (address[] memory users) {
    users = new address[](18);
    users[0] = USDT_STAKER;
    users[1] = 0xeC819b5E1d3B4549cAb841D894A09DF965b240e0;
    users[2] = 0x05279914272C6b352c2afd50f20a892cA8938092;
    users[3] = 0x942c34c92BDF7bb86ce206A186A8139a0B94DefB;
    users[4] = 0x504bb8F14E467CA71c47984725125aDcCaA2Ce99;
    users[5] = 0x5A2a98d3C9720734C2Fca8d5ec808B073c047Ccd;
    users[6] = 0xa9FA0F4F573a62A19fb6a3FFeCe9f9a285cbac8F;
    users[7] = 0x7dAA01bcf397D164eA3ebd6f75bfBcCe11F76f2E;
    users[8] = 0x9f4F18AC9cc9dE7C1441AC39Ab2DbD7174Fa1561;
    users[9] = 0x6c69a7AC85dE35DA20C908bcb9209726176d5Ba8;
    users[10] = 0x3D9cEFa0d77Bf9E6E367883F1B741fb44CAF0504;
    users[11] = 0x9b6AD928912bF1b4842630A9Ab0531c7ecaEb3f0;
    users[12] = 0x52D222BEAac5b1ce93f94778A672D143F150052F;
    users[13] = 0x1Efb9f8b00b4a5dBF0F779aa032febD4b8F38a94;
    users[14] = 0x1cA23C38584E371Dcd656ba88c29cEdbec794F07;
    users[15] = 0x90c05aaA614B6657F94097333B0a46007bCf55c0;
    users[16] = 0xc7a300d91dcAF3CaC0bCc171C543d8E51f0e75Ef;
    users[17] = largeStaker;
  }

  // accounts with unclaimed rewards at block 26484891 (some no longer staked) and a new large staker
  function _usdcStakers(address largeStaker) internal pure returns (address[] memory users) {
    users = new address[](20);
    users[0] = USDC_STAKER;
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

  // accounts with unclaimed rewards at block 26484891 (some no longer staked) and a new large staker
  function _wethStakers(address largeStaker) internal pure returns (address[] memory users) {
    users = new address[](15);
    users[0] = WETH_STAKER;
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
