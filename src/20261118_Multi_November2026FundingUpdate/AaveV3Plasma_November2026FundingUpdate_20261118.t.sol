// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GhoPlasma} from 'aave-address-book/GhoPlasma.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Plasma_November2026FundingUpdate_20261118} from './AaveV3Plasma_November2026FundingUpdate_20261118.sol';

/**
 * @dev Test for AaveV3Plasma_November2026FundingUpdate_20261118
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261118_Multi_November2026FundingUpdate/AaveV3Plasma_November2026FundingUpdate_20261118.t.sol -vv
 */
contract AaveV3Plasma_November2026FundingUpdate_20261118_Test is ProtocolV3TestBase {
  AaveV3Plasma_November2026FundingUpdate_20261118 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 38073370);
    proposal = new AaveV3Plasma_November2026FundingUpdate_20261118();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_November2026FundingUpdate_20261118',
      AaveV3Plasma.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Plasma.POOL, address(proposal), updatedAssets);
  }

  function test_afcAllowances() public {
    assertEq(
      IERC20(AaveV3PlasmaAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Plasma.COLLECTOR),
        MiscPlasma.AFC_SAFE
      ),
      0,
      'AFC should have no GHO allowance before execution'
    );
    assertEq(
      IERC20(AaveV3PlasmaAssets.GHO_A_TOKEN).allowance(
        address(AaveV3Plasma.COLLECTOR),
        MiscPlasma.AFC_SAFE
      ),
      0,
      'AFC should have no aGHO allowance before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3PlasmaAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Plasma.COLLECTOR),
        MiscPlasma.AFC_SAFE
      ),
      proposal.AFC_GHO_ALLOWANCE(),
      'unexpected AFC GHO allowance'
    );
    assertEq(
      IERC20(AaveV3PlasmaAssets.GHO_A_TOKEN).allowance(
        address(AaveV3Plasma.COLLECTOR),
        MiscPlasma.AFC_SAFE
      ),
      proposal.AFC_AGHO_ALLOWANCE(),
      'unexpected AFC aGHO allowance'
    );
  }

  function test_afcCanWithdrawAGho() public {
    executePayload(vm, address(proposal));

    uint256 amount = IERC20(AaveV3PlasmaAssets.GHO_A_TOKEN).balanceOf(
      address(AaveV3Plasma.COLLECTOR)
    );
    assertGt(amount, 0, 'Collector should hold aGHO');
    uint256 afcBalanceBefore = IERC20(AaveV3PlasmaAssets.GHO_UNDERLYING).balanceOf(
      MiscPlasma.AFC_SAFE
    );
    uint256 afcATokenBalanceBefore = IERC20(AaveV3PlasmaAssets.GHO_A_TOKEN).balanceOf(
      MiscPlasma.AFC_SAFE
    );

    vm.startPrank(MiscPlasma.AFC_SAFE);
    IERC20(AaveV3PlasmaAssets.GHO_A_TOKEN).transferFrom(
      address(AaveV3Plasma.COLLECTOR),
      MiscPlasma.AFC_SAFE,
      amount
    );
    AaveV3Plasma.POOL.withdraw(
      AaveV3PlasmaAssets.GHO_UNDERLYING,
      type(uint256).max,
      MiscPlasma.AFC_SAFE
    );
    vm.stopPrank();

    assertApproxEqAbs(
      IERC20(AaveV3PlasmaAssets.GHO_UNDERLYING).balanceOf(MiscPlasma.AFC_SAFE),
      afcBalanceBefore + afcATokenBalanceBefore + amount,
      10,
      'AFC should withdraw the aGHO as GHO'
    );
  }

  function test_rescueGsmRewards() public {
    IGsm gsm = IGsm(GhoPlasma.GSM_USDT);
    uint256 gsmBalance = IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(address(gsm));
    uint256 afcBalanceBefore = IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(
      MiscPlasma.AFC_SAFE
    );
    assertGt(gsmBalance, 0, 'GSM should hold rewards to rescue');
    assertFalse(
      IAccessControl(address(gsm)).hasRole(
        gsm.TOKEN_RESCUER_ROLE(),
        GovernanceV3Plasma.EXECUTOR_LVL_1
      ),
      'executor should not hold the rescuer role before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(address(gsm)),
      0,
      'GSM should hold no rewards'
    );
    assertEq(
      IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(MiscPlasma.AFC_SAFE),
      afcBalanceBefore + gsmBalance,
      'AFC should receive the rewards'
    );
    assertFalse(
      IAccessControl(address(gsm)).hasRole(
        gsm.TOKEN_RESCUER_ROLE(),
        GovernanceV3Plasma.EXECUTOR_LVL_1
      ),
      'executor should not keep the rescuer role'
    );
  }

  function test_rescueRevertsWithoutRewards() public {
    deal(AaveV3PlasmaAssets.WXPL_UNDERLYING, GhoPlasma.GSM_USDT, 0);
    uint40 payloadId = GovV3Helpers.readyPayload(vm, address(proposal));

    vm.expectRevert();
    GovernanceV3Plasma.PAYLOADS_CONTROLLER.executePayload(payloadId);
  }
}
