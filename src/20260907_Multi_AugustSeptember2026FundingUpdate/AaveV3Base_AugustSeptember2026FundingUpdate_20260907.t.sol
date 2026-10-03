// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

import {AaveV3Base_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Base_AugustSeptember2026FundingUpdate_20260907.sol';

/**
 * @dev Test for AaveV3Base_AugustSeptember2026FundingUpdate_20260907
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Base_AugustSeptember2026FundingUpdate_20260907.t.sol -vv
 */
contract AaveV3Base_AugustSeptember2026FundingUpdate_20260907_Test is ProtocolV3TestBase {
  AaveV3Base_AugustSeptember2026FundingUpdate_20260907 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 51612000);
    proposal = new AaveV3Base_AugustSeptember2026FundingUpdate_20260907();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Base_AugustSeptember2026FundingUpdate_20260907',
      AaveV3Base.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Base.POOL, address(proposal), updatedAssets);
  }

  function test_growthAllowance() public {
    assertEq(_afcAllowance(), 0, 'AFC should have no aBasUSDC allowance before execution');

    executePayload(vm, address(proposal));

    assertEq(
      _afcAllowance(),
      proposal.AFC_USDC_ALLOWANCE(),
      'AFC aBasUSDC allowance should be set to the growth allowance'
    );
    assertEq(_afcAllowance(), 443_000e6, 'AFC aBasUSDC allowance should be 443,000');
  }

  function _afcAllowance() internal view returns (uint256) {
    return
      IERC20(AaveV3BaseAssets.USDC_A_TOKEN).allowance(
        address(AaveV3Base.COLLECTOR),
        MiscBase.AFC_SAFE
      );
  }
}
