// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Monad, AaveV3MonadAssets} from 'aave-address-book/AaveV3Monad.sol';
import {GovernanceV3Monad} from 'aave-address-book/GovernanceV3Monad.sol';
import {GhoMonad} from 'aave-address-book/GhoMonad.sol';
import {MiscMonad} from 'aave-address-book/MiscMonad.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Monad_November2026FundingUpdate_20261118} from './AaveV3Monad_November2026FundingUpdate_20261118.sol';

/**
 * @dev Test for AaveV3Monad_November2026FundingUpdate_20261118
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261118_Multi_November2026FundingUpdate/AaveV3Monad_November2026FundingUpdate_20261118.t.sol -vv
 * forge-config: default.networks.network = "monad"
 * forge-config: default.hardfork = "monad:MonadTen"
 */
contract AaveV3Monad_November2026FundingUpdate_20261118_Test is ProtocolV3TestBase {
  AaveV3Monad_November2026FundingUpdate_20261118 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('monad'), 125651484);
    proposal = new AaveV3Monad_November2026FundingUpdate_20261118();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Monad_November2026FundingUpdate_20261118',
      AaveV3Monad.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Monad.POOL, address(proposal), updatedAssets);
  }

  function test_afcAllowances() public {
    assertEq(
      IERC20(AaveV3MonadAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Monad.COLLECTOR),
        MiscMonad.AFC_SAFE
      ),
      0,
      'AFC should have no allowance before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3MonadAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Monad.COLLECTOR),
        MiscMonad.AFC_SAFE
      ),
      proposal.AFC_GHO_ALLOWANCE(),
      'unexpected AFC allowance'
    );
  }

  function test_rescueGsmRewards() public {
    IGsm gsm = IGsm(GhoMonad.GSM_USDC);
    uint256 gsmBalance = IERC20(proposal.WMON()).balanceOf(address(gsm));
    uint256 afcBalanceBefore = IERC20(proposal.WMON()).balanceOf(MiscMonad.AFC_SAFE);
    assertGt(gsmBalance, 0, 'GSM should hold rewards to rescue');
    assertFalse(
      IAccessControl(address(gsm)).hasRole(
        gsm.TOKEN_RESCUER_ROLE(),
        GovernanceV3Monad.EXECUTOR_LVL_1
      ),
      'executor should not hold the rescuer role before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(IERC20(proposal.WMON()).balanceOf(address(gsm)), 0, 'GSM should hold no rewards');
    assertEq(
      IERC20(proposal.WMON()).balanceOf(MiscMonad.AFC_SAFE),
      afcBalanceBefore + gsmBalance,
      'AFC should receive the rewards'
    );
    assertFalse(
      IAccessControl(address(gsm)).hasRole(
        gsm.TOKEN_RESCUER_ROLE(),
        GovernanceV3Monad.EXECUTOR_LVL_1
      ),
      'executor should not keep the rescuer role'
    );
  }

  function test_rescueRevertsWithoutRewards() public {
    address wmon = proposal.WMON();
    deal(wmon, GhoMonad.GSM_USDC, 0);
    uint40 payloadId = GovV3Helpers.readyPayload(vm, address(proposal));

    vm.expectRevert();
    GovernanceV3Monad.PAYLOADS_CONTROLLER.executePayload(payloadId);

    IGsm gsm = IGsm(GhoMonad.GSM_USDC);
    vm.startPrank(GovernanceV3Monad.EXECUTOR_LVL_1);
    IAccessControl(address(gsm)).grantRole(
      gsm.TOKEN_RESCUER_ROLE(),
      GovernanceV3Monad.EXECUTOR_LVL_1
    );
    vm.expectRevert(bytes('INVALID_AMOUNT'));
    gsm.rescueTokens(wmon, MiscMonad.AFC_SAFE, 0);
    vm.stopPrank();
  }
}
