// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Gnosis, AaveV3GnosisAssets} from 'aave-address-book/AaveV3Gnosis.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Gnosis_November2026FundingUpdate_20261118} from './AaveV3Gnosis_November2026FundingUpdate_20261118.sol';

/**
 * @dev Test for AaveV3Gnosis_November2026FundingUpdate_20261118
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261118_Multi_November2026FundingUpdate/AaveV3Gnosis_November2026FundingUpdate_20261118.t.sol -vv
 */
contract AaveV3Gnosis_November2026FundingUpdate_20261118_Test is ProtocolV3TestBase {
  AaveV3Gnosis_November2026FundingUpdate_20261118 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('gnosis'), 49345689);
    proposal = new AaveV3Gnosis_November2026FundingUpdate_20261118();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Gnosis_November2026FundingUpdate_20261118',
      AaveV3Gnosis.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Gnosis.POOL, address(proposal), updatedAssets);
  }

  function test_afcAllowances() public {
    assertEq(
      IERC20(AaveV3GnosisAssets.WXDAI_A_TOKEN).allowance(
        address(AaveV3Gnosis.COLLECTOR),
        MiscGnosis.AFC_SAFE
      ),
      0,
      'AFC should have no allowance before execution'
    );
    assertEq(
      IERC20(AaveV3GnosisAssets.USDC_A_TOKEN).allowance(
        address(AaveV3Gnosis.COLLECTOR),
        MiscGnosis.AFC_SAFE
      ),
      0,
      'AFC should have no allowance before execution'
    );
    assertEq(
      IERC20(AaveV3GnosisAssets.USDCe_A_TOKEN).allowance(
        address(AaveV3Gnosis.COLLECTOR),
        MiscGnosis.AFC_SAFE
      ),
      0,
      'AFC should have no allowance before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3GnosisAssets.WXDAI_A_TOKEN).allowance(
        address(AaveV3Gnosis.COLLECTOR),
        MiscGnosis.AFC_SAFE
      ),
      proposal.AFC_WXDAI_ALLOWANCE(),
      'unexpected AFC allowance'
    );
    assertEq(
      IERC20(AaveV3GnosisAssets.USDC_A_TOKEN).allowance(
        address(AaveV3Gnosis.COLLECTOR),
        MiscGnosis.AFC_SAFE
      ),
      proposal.AFC_USDC_ALLOWANCE(),
      'unexpected AFC allowance'
    );
    assertEq(
      IERC20(AaveV3GnosisAssets.USDCe_A_TOKEN).allowance(
        address(AaveV3Gnosis.COLLECTOR),
        MiscGnosis.AFC_SAFE
      ),
      proposal.AFC_USDCE_ALLOWANCE(),
      'unexpected AFC allowance'
    );
  }
}
