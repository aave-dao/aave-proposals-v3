// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Arbitrum_November2026FundingUpdate_20261118} from './AaveV3Arbitrum_November2026FundingUpdate_20261118.sol';

/**
 * @dev Test for AaveV3Arbitrum_November2026FundingUpdate_20261118
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261118_Multi_November2026FundingUpdate/AaveV3Arbitrum_November2026FundingUpdate_20261118.t.sol -vv
 */
contract AaveV3Arbitrum_November2026FundingUpdate_20261118_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_November2026FundingUpdate_20261118 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 525369509);
    proposal = new AaveV3Arbitrum_November2026FundingUpdate_20261118();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Arbitrum_November2026FundingUpdate_20261118',
      AaveV3Arbitrum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function test_afcAllowances() public {
    assertEq(
      IERC20(AaveV3ArbitrumAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Arbitrum.COLLECTOR),
        MiscArbitrum.AFC_SAFE
      ),
      0,
      'AFC should have no allowance before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3ArbitrumAssets.GHO_UNDERLYING).allowance(
        address(AaveV3Arbitrum.COLLECTOR),
        MiscArbitrum.AFC_SAFE
      ),
      proposal.AFC_GHO_ALLOWANCE(),
      'unexpected AFC allowance'
    );
  }
}
