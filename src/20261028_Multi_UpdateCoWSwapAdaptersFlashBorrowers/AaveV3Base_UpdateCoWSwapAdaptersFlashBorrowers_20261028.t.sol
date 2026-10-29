// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';
import {AaveV4BaseAssets, AaveV4BaseHubs, AaveV4BaseSpokes} from 'aave-address-book/AaveV4Base.sol';

import {AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028} from './AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol';
import {CoWFlashBorrowerBaseTest} from 'src/helpers/cow-adapters/CoWFlashBorrowerBaseTest.sol';

/**
 * @dev Test for AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol -vv
 */
contract AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028_Test is CoWFlashBorrowerBaseTest {
  AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 53210075);
    proposal = new AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Base_UpdateCoWSwapAdaptersFlashBorrowers_20261028',
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

  function test_isFlashBorrower() external {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertTrue(AaveV3Base.ACL_MANAGER.isFlashBorrower(proposal.COW_V3_ADAPTER_FACTORY()));
    assertTrue(AaveV3Base.ACL_MANAGER.isFlashBorrower(proposal.COW_V4_ADAPTER_FACTORY()));
    assertFalse(AaveV3Base.ACL_MANAGER.isFlashBorrower(proposal.DEPRECATED_COW_ADAPTER_FACTORY()));
  }

  /**
   * @dev Runs on forge's Base EVM so the native B20 equity tokens execute. Sells USDC, as the V3
   * Pool lists none of the MAG7 equities to flash-loan.
   * forge-config: default.networks.network = "base"
   * forge-config: default.hardfork = "base:cobalt"
   */
  function test_collateralSwapV4WithFlashLoan_noFlashLoanFee() public {
    _testCollateralSwapV4WithFlashLoanNoFee(
      CollateralSwapV4Config({
        factory: proposal.COW_V4_ADAPTER_FACTORY(),
        spoke: AaveV4BaseSpokes.MAG7_SPOKE,
        hub: address(AaveV4BaseHubs.EQUITIES_HUB),
        collateralAsset: AaveV4BaseAssets.USDC_UNDERLYING,
        debtAsset: AaveV4BaseAssets.AAPLc_UNDERLYING,
        collateralSeed: 10_000 * 1e6,
        debtSeed: 0,
        sellAmount: 10_000 * 1e6,
        expectedBuyAmount: 40 * 1e8
      })
    );
  }

  function _pool() internal pure override returns (IPool) {
    return AaveV3Base.POOL;
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
    ownerships = new FactoryOwnership[](2);
    ownerships[0] = FactoryOwnership(proposal.COW_V3_ADAPTER_FACTORY(), COW_V3_FACTORY_PROXY_ADMIN);
    ownerships[1] = FactoryOwnership(proposal.COW_V4_ADAPTER_FACTORY(), COW_V4_FACTORY_PROXY_ADMIN);
  }

  function _executePayload() internal override {
    GovV3Helpers.executePayload(vm, address(proposal));
  }

  function _collateralSwapConfig() internal pure override returns (CollateralSwapConfig memory) {
    return
      CollateralSwapConfig({
        collateralAsset: AaveV3BaseAssets.wstETH_UNDERLYING,
        debtAsset: AaveV3BaseAssets.USDC_UNDERLYING,
        collateralSeed: 10 ether,
        debtSeed: 10_000 * 1e6,
        sellAmount: 10 ether,
        expectedBuyAmount: 42_000 * 1e6
      });
  }
}
