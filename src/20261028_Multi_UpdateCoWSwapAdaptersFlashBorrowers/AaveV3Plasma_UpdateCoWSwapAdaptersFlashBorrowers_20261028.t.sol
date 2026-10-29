// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Plasma, AaveV3PlasmaAssets} from 'aave-address-book/AaveV3Plasma.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';

import {AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028} from './AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol';
import {CoWFlashBorrowerBaseTest} from 'src/helpers/cow-adapters/CoWFlashBorrowerBaseTest.sol';

/**
 * @dev Test for AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol -vv
 */
contract AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028_Test is
  CoWFlashBorrowerBaseTest
{
  AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 36268094);
    proposal = new AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Plasma_UpdateCoWSwapAdaptersFlashBorrowers_20261028',
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

  function test_isFlashBorrower() external {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertTrue(AaveV3Plasma.ACL_MANAGER.isFlashBorrower(proposal.COW_V3_ADAPTER_FACTORY()));
    assertFalse(
      AaveV3Plasma.ACL_MANAGER.isFlashBorrower(proposal.DEPRECATED_COW_ADAPTER_FACTORY())
    );
  }

  function _pool() internal pure override returns (IPool) {
    return AaveV3Plasma.POOL;
  }

  function _cowV3Factory() internal view override returns (address) {
    return proposal.COW_V3_ADAPTER_FACTORY();
  }

  function _collateralSwapAdapter() internal pure override returns (address) {
    return COLLATERAL_SWAP_V3_ADAPTER;
  }

  function _factoryOwnerships()
    internal
    view
    override
    returns (FactoryOwnership[] memory ownerships)
  {
    ownerships = new FactoryOwnership[](1);
    ownerships[0] = FactoryOwnership(proposal.COW_V3_ADAPTER_FACTORY(), COW_V3_FACTORY_PROXY_ADMIN);
  }

  function _executePayload() internal override {
    GovV3Helpers.executePayload(vm, address(proposal));
  }

  function _collateralSwapConfig() internal pure override returns (CollateralSwapConfig memory) {
    // WETH is frozen on Plasma at this fork block and USDT0 is the only borrowable asset with
    // LTV > 0, so the trader holds USDe without debt and swaps it into USDT0 collateral.
    return
      CollateralSwapConfig({
        collateralAsset: AaveV3PlasmaAssets.USDe_UNDERLYING,
        debtAsset: AaveV3PlasmaAssets.USDT0_UNDERLYING,
        collateralSeed: 10_000 ether,
        debtSeed: 0,
        sellAmount: 10_000 ether,
        expectedBuyAmount: 10_000 * 1e6
      });
  }
}
