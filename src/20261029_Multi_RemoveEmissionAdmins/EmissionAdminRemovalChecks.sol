// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IPool, DataTypes} from 'aave-address-book/AaveV3.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';
import {IRewardsController} from 'aave-v3-origin/contracts/rewards/interfaces/IRewardsController.sol';

interface IRemoveEmissionAdminsPayload {
  function getRewards() external pure returns (address[] memory);
}

abstract contract EmissionAdminRemovalChecks is Test {
  struct Claim {
    address user;
    address reward;
    address[] assets;
  }

  bytes32 internal constant EMISSION_ADMIN_UPDATED =
    keccak256('EmissionAdminUpdated(address,address,address)');

  function _checkAdminsRemoved(
    address payload,
    address emissionManager,
    IPool[] memory pools
  ) internal {
    IEmissionManager em = IEmissionManager(emissionManager);
    address[] memory rewards = IRemoveEmissionAdminsPayload(payload).getRewards();
    for (uint256 i = 0; i < rewards.length; i++) {
      assertNotEq(em.getEmissionAdmin(rewards[i]), address(0), 'payload reward has no admin');
      for (uint256 j = 0; j < i; j++) {
        assertNotEq(rewards[i], rewards[j], 'duplicate payload reward');
      }
    }

    vm.recordLogs();
    GovV3Helpers.executePayload(vm, payload);

    Vm.Log[] memory logs = vm.getRecordedLogs();
    uint256 updates;
    for (uint256 i = 0; i < logs.length; i++) {
      if (logs[i].emitter == emissionManager && logs[i].topics[0] == EMISSION_ADMIN_UPDATED) {
        assertEq(logs[i].topics[3], bytes32(0), 'admin set to non-zero');
        updates++;
      }
    }
    assertEq(updates, rewards.length, 'EmissionAdminUpdated count');

    for (uint256 i = 0; i < rewards.length; i++) {
      assertEq(em.getEmissionAdmin(rewards[i]), address(0), 'payload reward admin left');
    }

    // independent of the payload list: configured rewards and every reserve token
    address[] memory listed = em.getRewardsController().getRewardsList();
    for (uint256 i = 0; i < listed.length; i++) {
      assertEq(em.getEmissionAdmin(listed[i]), address(0), 'configured reward admin left');
    }
    for (uint256 p = 0; p < pools.length; p++) {
      address[] memory reserves = pools[p].getReservesList();
      for (uint256 i = 0; i < reserves.length; i++) {
        DataTypes.ReserveDataLegacy memory data = pools[p].getReserveData(reserves[i]);
        assertEq(em.getEmissionAdmin(reserves[i]), address(0), 'underlying admin left');
        assertEq(em.getEmissionAdmin(data.aTokenAddress), address(0), 'aToken admin left');
        assertEq(
          em.getEmissionAdmin(data.variableDebtTokenAddress),
          address(0),
          'vToken admin left'
        );
      }
    }
  }

  function _checkClaims(address payload, address controller, Claim[] memory claims) internal {
    IRewardsController rc = IRewardsController(controller);
    uint256[] memory accrued = new uint256[](claims.length);
    for (uint256 i = 0; i < claims.length; i++) {
      accrued[i] = rc.getUserRewards(claims[i].assets, claims[i].user, claims[i].reward);
      assertGt(accrued[i], 0, 'fixture has nothing to claim');
    }

    GovV3Helpers.executePayload(vm, payload);

    for (uint256 i = 0; i < claims.length; i++) {
      Claim memory c = claims[i];
      uint256 balanceBefore = IERC20(c.reward).balanceOf(c.user);
      vm.prank(c.user);
      uint256 claimed = rc.claimRewards(c.assets, type(uint256).max, c.user, c.reward);
      assertEq(claimed, accrued[i], 'claimed amount');
      assertEq(IERC20(c.reward).balanceOf(c.user) - balanceBefore, claimed, 'reward received');
      assertEq(rc.getUserRewards(c.assets, c.user, c.reward), 0, 'rewards left after claim');
    }
  }
}
