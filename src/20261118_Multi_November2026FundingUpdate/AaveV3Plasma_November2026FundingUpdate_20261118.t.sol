// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';
import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GhoPlasma} from 'aave-address-book/GhoPlasma.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
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
      'AFC should have no allowance before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3PlasmaAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Plasma.COLLECTOR),
        MiscPlasma.AFC_SAFE
      ),
      proposal.AFC_GHO_ALLOWANCE(),
      'unexpected AFC allowance'
    );
  }

  function test_rescueGsmRewards() public {
    IGsm gsm = IGsm(GhoPlasma.GSM_USDT);
    uint256 gsmBalance = IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(address(gsm));
    uint256 afcBalanceBefore = IERC20(AaveV3PlasmaAssets.WXPL_UNDERLYING).balanceOf(
      MiscPlasma.AFC_SAFE
    );
    assertGt(gsmBalance, 0, 'GSM should hold rewards to rescue');

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
}
