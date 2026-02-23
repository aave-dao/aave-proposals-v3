// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210} from './AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210.sol';

/**
 * @dev Test for AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260210_AaveV3InkWhitelabel_SUSDeUSDeListingInk/AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210.t.sol -vv
 */
contract AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210_Test is ProtocolV3TestBase {
  AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 38352175);
    proposal = new AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3InkWhitelabel_SUSDeUSDeListingInk_20260210',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      true,
      true
    );
  }

  function test_dustBinHassUSDeFunds() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    address aTokenAddress = AaveV3InkWhitelabel.POOL.getReserveAToken(proposal.sUSDe());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3InkWhitelabel.DUST_BIN)),
      100 * 10 ** 18
    );
  }

  function test_sUSDeAdmin() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    address asUSDe = AaveV3InkWhitelabel.POOL.getReserveAToken(proposal.sUSDe());
    assertEq(
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).getEmissionAdmin(proposal.sUSDe()),
      proposal.sUSDe_LM_ADMIN()
    );
    assertEq(
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).getEmissionAdmin(asUSDe),
      proposal.sUSDe_LM_ADMIN()
    );
  }

  function test_dustBinHasUSDeFunds() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    address aTokenAddress = AaveV3InkWhitelabel.POOL.getReserveAToken(proposal.USDe());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3InkWhitelabel.DUST_BIN)),
      99.99 * 10 ** 18
    );
  }

  function test_USDeAdmin() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    address aUSDe = AaveV3InkWhitelabel.POOL.getReserveAToken(proposal.USDe());
    assertEq(
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).getEmissionAdmin(proposal.USDe()),
      proposal.USDe_LM_ADMIN()
    );
    assertEq(
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).getEmissionAdmin(aUSDe),
      proposal.USDe_LM_ADMIN()
    );
  }
}
