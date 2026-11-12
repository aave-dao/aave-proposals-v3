// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {AaveV4AvalancheAssets, AaveV4AvalancheHubs, AaveV4AvalancheSpokes} from 'aave-address-book/AaveV4Avalanche.sol';

import {AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028} from './AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol';
import {CoWFlashBorrowerBaseTest} from 'src/helpers/cow-adapters/CoWFlashBorrowerBaseTest.sol';

/**
 * @dev Test for AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol -vv
 */
contract AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028_Test is
  CoWFlashBorrowerBaseTest
{
  AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 99329879);
    proposal = new AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Avalanche_UpdateCoWSwapAdaptersFlashBorrowers_20261028',
      AaveV3Avalanche.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Avalanche.POOL, address(proposal), updatedAssets);
  }

  function test_isFlashBorrower() external {
    assertFalse(AaveV3Avalanche.ACL_MANAGER.isFlashBorrower(proposal.COW_V3_ADAPTER_FACTORY()));
    assertFalse(AaveV3Avalanche.ACL_MANAGER.isFlashBorrower(proposal.COW_V4_ADAPTER_FACTORY()));
    assertTrue(
      AaveV3Avalanche.ACL_MANAGER.isFlashBorrower(proposal.DEPRECATED_COW_ADAPTER_FACTORY())
    );

    GovV3Helpers.executePayload(vm, address(proposal));

    assertTrue(AaveV3Avalanche.ACL_MANAGER.isFlashBorrower(proposal.COW_V3_ADAPTER_FACTORY()));
    assertTrue(AaveV3Avalanche.ACL_MANAGER.isFlashBorrower(proposal.COW_V4_ADAPTER_FACTORY()));
    assertFalse(
      AaveV3Avalanche.ACL_MANAGER.isFlashBorrower(proposal.DEPRECATED_COW_ADAPTER_FACTORY())
    );
  }

  function test_collateralSwapWithFlashLoanV4_noFlashLoanFee() public {
    _testCollateralSwapWithFlashLoanNoFeeV4(_collateralSwapConfigV4(), true);
  }

  function test_collateralSwapWithFlashLoanV4_noFlashLoanFee_revertsWithoutPayload() public {
    _testCollateralSwapWithFlashLoanNoFeeV4(_collateralSwapConfigV4(), false);
  }

  function _poolV3() internal pure override returns (IPool) {
    return AaveV3Avalanche.POOL;
  }

  function _cowFactoryV3() internal view override returns (address) {
    return proposal.COW_V3_ADAPTER_FACTORY();
  }

  function _collateralSwapAdapterV3() internal pure override returns (address) {
    return COLLATERAL_SWAP_ADAPTER_V3;
  }

  function _cowAdaptersOwner() internal pure override returns (address) {
    return MiscAvalanche.V4_SECURITY_COUNCIL;
  }

  function _factoryOwnerships()
    internal
    view
    override
    returns (FactoryOwnership[] memory ownerships)
  {
    ownerships = new FactoryOwnership[](2);
    ownerships[0] = FactoryOwnership(proposal.COW_V3_ADAPTER_FACTORY(), COW_FACTORY_PROXY_ADMIN_V3);
    ownerships[1] = FactoryOwnership(proposal.COW_V4_ADAPTER_FACTORY(), COW_FACTORY_PROXY_ADMIN_V4);
  }

  function _executePayload() internal override {
    GovV3Helpers.executePayload(vm, address(proposal));
  }

  function _collateralSwapConfigV3()
    internal
    pure
    override
    returns (CollateralSwapConfigV3 memory)
  {
    return
      CollateralSwapConfigV3({
        collateralAsset: AaveV3AvalancheAssets.WETHe_UNDERLYING,
        buyAsset: AaveV3AvalancheAssets.BTCb_UNDERLYING,
        collateralSeed: 10 ether,
        debtSeed: 0.05 * 1e8,
        sellAmount: 10 ether,
        expectedBuyAmount: 0.3 * 1e8
      });
  }

  function _collateralSwapConfigV4() internal view returns (CollateralSwapConfigV4 memory) {
    return
      CollateralSwapConfigV4({
        factory: proposal.COW_V4_ADAPTER_FACTORY(),
        spoke: AaveV4AvalancheSpokes.MAIN_SPOKE,
        hub: address(AaveV4AvalancheHubs.CORE_HUB),
        collateralAsset: AaveV4AvalancheAssets.WETHe_UNDERLYING,
        buyAsset: AaveV4AvalancheAssets.WAVAX_UNDERLYING,
        collateralSeed: 10 ether,
        debtSeed: 100 ether,
        sellAmount: 10 ether,
        expectedBuyAmount: 1_500 ether
      });
  }
}
