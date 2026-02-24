// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3InkWhitelabel_INKSolvBTCListing_20260211} from './AaveV3InkWhitelabel_INKSolvBTCListing_20260211.sol';

/**
 * @dev Test for AaveV3InkWhitelabel_INKSolvBTCListing_20260211
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260211_AaveV3InkWhitelabel_INKSolvBTCListing/AaveV3InkWhitelabel_INKSolvBTCListing_20260211.t.sol -vv
 */
contract AaveV3InkWhitelabel_INKSolvBTCListing_20260211_Test is ProtocolV3TestBase {
  AaveV3InkWhitelabel_INKSolvBTCListing_20260211 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 37491400);
    proposal = new AaveV3InkWhitelabel_INKSolvBTCListing_20260211();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3InkWhitelabel_INKSolvBTCListing_20260211',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      true,
      true
    );
  }

  function test_dustBinHasSolvBTCFunds() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    address aTokenAddress = AaveV3InkWhitelabel.POOL.getReserveAToken(proposal.SolvBTC());
    assertGe(IERC20(aTokenAddress).balanceOf(address(AaveV3InkWhitelabel.DUST_BIN)), 0.0016e18);
  }

  function test_SolvBTCAdmin() public {
    executePayload(vm, address(proposal), AaveV3InkWhitelabel.POOL);
    address aSolvBTC = AaveV3InkWhitelabel.POOL.getReserveAToken(proposal.SolvBTC());
    assertEq(
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).getEmissionAdmin(proposal.SolvBTC()),
      proposal.SolvBTC_LM_ADMIN()
    );
    assertEq(
      IEmissionManager(AaveV3InkWhitelabel.EMISSION_MANAGER).getEmissionAdmin(aSolvBTC),
      proposal.SolvBTC_LM_ADMIN()
    );
  }
}
