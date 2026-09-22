// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumEtherFi, AaveV3EthereumEtherFiAssets} from 'aave-address-book/AaveV3EthereumEtherFi.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915} from './AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915_Test is
  ProtocolV3TestBase
{
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26_032_357);
    proposal = new AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915',
      AaveV3EthereumEtherFi.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](1);
    updatedAssets[0] = AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING;
    reserveConfigChangesTest(AaveV3EthereumEtherFi.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](1);
    frozen = new bool[](1);

    assets[0] = AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING;
    frozen[0] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](0);
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3EthereumEtherFi.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        9_000, // unchanged; 90% (2 decimals)
        'FRAX kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'FRAX base'
      );
      assertEq(
        rate.variableRateSlope1,
        550, // unchanged; 5.5% (2 decimals)
        'FRAX s1'
      );
      assertEq(
        rate.variableRateSlope2,
        4_000, // unchanged; 40% (2 decimals)
        'FRAX s2'
      );
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3EthereumEtherFi.ORACLE.getSourceOfAsset(AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING),
      proposal.FRAX_PRICE_FEED(),
      'FRAX source'
    );
    assertEq(
      AaveV3EthereumEtherFi.ORACLE.getAssetPrice(AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    DataTypes.ReserveConfigurationMap memory expectedFRAX = AaveV3EthereumEtherFi
      .POOL
      .getConfiguration(AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING);
    assertEq(expectedFRAX.getSupplyCap(), 1, 'FRAX pre supply cap'); // unchanged
    assertEq(expectedFRAX.getBorrowCap(), 1, 'FRAX pre borrow cap'); // unchanged
    assertEq(expectedFRAX.getFrozen(), false, 'FRAX pre freeze');
    expectedFRAX.setFrozen(true);
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3EthereumEtherFi.POOL.getConfiguration(AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING).data,
      expectedFRAX.data,
      'FRAX configuration and untouched fields'
    );
  }
}
