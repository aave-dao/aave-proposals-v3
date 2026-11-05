// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Linea, AaveV3LineaAssets} from 'aave-address-book/AaveV3Linea.sol';
import {IPool} from 'aave-address-book/AaveV3.sol';
import {MiscLinea} from 'aave-address-book/MiscLinea.sol';

import {AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028} from './AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028.sol';
import {CoWFlashBorrowerBaseTest} from 'src/helpers/cow-adapters/CoWFlashBorrowerBaseTest.sol';

/**
 * @dev Test for AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261028_Multi_UpdateCoWSwapAdaptersFlashBorrowers/AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028.t.sol -vv
 */
contract AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028_Test is CoWFlashBorrowerBaseTest {
  AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('linea'), 32509370);
    proposal = new AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Linea_UpdateCoWSwapAdaptersFlashBorrowers_20261028',
      AaveV3Linea.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Linea.POOL, address(proposal), updatedAssets);
  }

  function test_isFlashBorrower() external {
    assertFalse(AaveV3Linea.ACL_MANAGER.isFlashBorrower(proposal.COW_V3_ADAPTER_FACTORY()));
    assertTrue(AaveV3Linea.ACL_MANAGER.isFlashBorrower(proposal.DEPRECATED_COW_ADAPTER_FACTORY()));

    GovV3Helpers.executePayload(vm, address(proposal));

    assertTrue(AaveV3Linea.ACL_MANAGER.isFlashBorrower(proposal.COW_V3_ADAPTER_FACTORY()));
    assertFalse(AaveV3Linea.ACL_MANAGER.isFlashBorrower(proposal.DEPRECATED_COW_ADAPTER_FACTORY()));
  }

  function _poolV3() internal pure override returns (IPool) {
    return AaveV3Linea.POOL;
  }

  function _cowFactoryV3() internal view override returns (address) {
    return proposal.COW_V3_ADAPTER_FACTORY();
  }

  function _collateralSwapAdapterV3() internal pure override returns (address) {
    return COLLATERAL_SWAP_ADAPTER_V3;
  }

  function _cowAdaptersOwner() internal pure override returns (address) {
    return MiscLinea.V4_SECURITY_COUNCIL;
  }

  function _factoryOwnerships()
    internal
    view
    override
    returns (FactoryOwnership[] memory ownerships)
  {
    ownerships = new FactoryOwnership[](1);
    ownerships[0] = FactoryOwnership(
      proposal.COW_V3_ADAPTER_FACTORY(),
      COW_FACTORY_PROXY_ADMIN_V3_LINEA
    );
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
        collateralAsset: AaveV3LineaAssets.wstETH_UNDERLYING,
        buyAsset: AaveV3LineaAssets.WETH_UNDERLYING,
        collateralSeed: 10 ether,
        debtSeed: 2 ether,
        sellAmount: 10 ether,
        expectedBuyAmount: 12 ether
      });
  }
}
