// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111} from './AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.sol';

/**
 * @dev Test for AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261111_Multi_ReserveFactorUpdatesAcrossAaveV3AndV2Markets/AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111.t.sol -vv
 */
contract AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111_Test is
  ProtocolV3TestBase
{
  uint256 internal constant DAI_RF = 30_00;
  uint256 internal constant WBTC_RF = 100_00;
  uint256 internal constant cbBTC_RF = 100_00;
  uint256 internal constant wstETH_RF = 100_00;
  uint256 internal constant LINK_RF = 50_00;
  uint256 internal constant weETH_RF = 100_00;
  uint256 internal constant tBTC_RF = 100_00;
  uint256 internal constant FBTC_RF = 100_00;
  uint256 internal constant cbETH_RF = 100_00;
  uint256 internal constant rETH_RF = 100_00;

  AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26393644);
    proposal = new AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_ReserveFactorUpdatesAcrossAaveV3AndV2Markets_20261111',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](10);
    updatedAssets[0] = AaveV3EthereumAssets.DAI_UNDERLYING;
    updatedAssets[1] = AaveV3EthereumAssets.WBTC_UNDERLYING;
    updatedAssets[2] = AaveV3EthereumAssets.cbBTC_UNDERLYING;
    updatedAssets[3] = AaveV3EthereumAssets.wstETH_UNDERLYING;
    updatedAssets[4] = AaveV3EthereumAssets.LINK_UNDERLYING;
    updatedAssets[5] = AaveV3EthereumAssets.weETH_UNDERLYING;
    updatedAssets[6] = AaveV3EthereumAssets.tBTC_UNDERLYING;
    updatedAssets[7] = AaveV3EthereumAssets.FBTC_UNDERLYING;
    updatedAssets[8] = AaveV3EthereumAssets.cbETH_UNDERLYING;
    updatedAssets[9] = AaveV3EthereumAssets.rETH_UNDERLYING;
    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  function _expectedBorrowChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.BorrowUpdate[] memory)
  {
    IAaveV3ConfigEngine.BorrowUpdate[] memory borrowUpdates;
    borrowUpdates = new IAaveV3ConfigEngine.BorrowUpdate[](10);

    borrowUpdates[0] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.DAI_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: DAI_RF
    });
    borrowUpdates[1] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.WBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: WBTC_RF
    });
    borrowUpdates[2] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.cbBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: cbBTC_RF
    });
    borrowUpdates[3] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.wstETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: wstETH_RF
    });
    borrowUpdates[4] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.LINK_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: LINK_RF
    });
    borrowUpdates[5] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.weETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: weETH_RF
    });
    borrowUpdates[6] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.tBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: tBTC_RF
    });
    borrowUpdates[7] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.FBTC_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: FBTC_RF
    });
    borrowUpdates[8] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.cbETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: cbETH_RF
    });
    borrowUpdates[9] = IAaveV3ConfigEngine.BorrowUpdate({
      asset: AaveV3EthereumAssets.rETH_UNDERLYING,
      enabledToBorrow: EngineFlags.KEEP_CURRENT,
      flashloanable: EngineFlags.KEEP_CURRENT,
      reserveFactor: rETH_RF
    });
    return borrowUpdates;
  }
}
