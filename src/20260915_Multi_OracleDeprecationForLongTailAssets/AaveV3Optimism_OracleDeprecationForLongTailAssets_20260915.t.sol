// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Optimism, AaveV3OptimismAssets} from 'aave-address-book/AaveV3Optimism.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';
import {ReserveConfiguration} from 'aave-v3-origin/contracts/protocol/libraries/configuration/ReserveConfiguration.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915} from './AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';

/**
 * @dev Test for AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915_Test is ProtocolV3TestBase {
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 157_236_629);
    proposal = new AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    _assertRates(false);
    defaultTest(
      'AaveV3Optimism_OracleDeprecationForLongTailAssets_20260915',
      AaveV3Optimism.POOL,
      address(proposal)
    );
    _assertRates(true);
    _assertOracles();
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](3);
    updatedAssets[0] = AaveV3OptimismAssets.LUSD_UNDERLYING;
    updatedAssets[1] = AaveV3OptimismAssets.sUSD_UNDERLYING;
    updatedAssets[2] = AaveV3OptimismAssets.MAI_UNDERLYING;
    reserveConfigChangesTest(AaveV3Optimism.POOL, address(proposal), updatedAssets);
  }

  function _expectedFreezeChanges()
    internal
    pure
    override
    returns (address[] memory assets, bool[] memory frozen)
  {
    assets = new address[](2);
    frozen = new bool[](2);

    assets[0] = AaveV3OptimismAssets.LUSD_UNDERLYING;
    frozen[0] = true;
    assets[1] = AaveV3OptimismAssets.sUSD_UNDERLYING;
    frozen[1] = true;
  }

  function _expectedCapsChanges()
    internal
    pure
    override
    returns (IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate)
  {
    capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](1);
    capsUpdate[0] = IAaveV3ConfigEngine.CapsUpdate(AaveV3OptimismAssets.MAI_UNDERLYING, 1, 1);
  }
  function _assertRates(bool afterExecution) internal view {
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Optimism.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3OptimismAssets.LUSD_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        8_000, // unchanged; 80% (2 decimals)
        'LUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 200, // 2% -> 20% (2 decimals)
        'LUSD base'
      );
      assertEq(
        rate.variableRateSlope1,
        550, // unchanged; 5.5% (2 decimals)
        'LUSD s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 5_000, // 50% -> 40% (2 decimals)
        'LUSD s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Optimism.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3OptimismAssets.MAI_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        4_500, // unchanged; 45% (2 decimals)
        'MAI kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        afterExecution ? 2_000 : 0, // 0% -> 20% (2 decimals)
        'MAI base'
      );
      assertEq(
        rate.variableRateSlope1,
        550, // unchanged; 5.5% (2 decimals)
        'MAI s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 4_000 : 30_000, // 300% -> 40% (2 decimals)
        'MAI s2'
      );
    }
    {
      IDefaultInterestRateStrategyV2.InterestRateData memory rate = IDefaultInterestRateStrategyV2(
        AaveV3Optimism.POOL.RESERVE_INTEREST_RATE_STRATEGY()
      ).getInterestRateDataBps(AaveV3OptimismAssets.sUSD_UNDERLYING);
      assertEq(
        rate.optimalUsageRatio,
        8_000, // unchanged; 80% (2 decimals)
        'sUSD kink'
      );
      assertEq(
        rate.baseVariableBorrowRate,
        0, // unchanged; 0% (2 decimals)
        'sUSD base'
      );
      assertEq(
        rate.variableRateSlope1,
        afterExecution ? 0 : 550, // 5.5% -> 0% (2 decimals)
        'sUSD s1'
      );
      assertEq(
        rate.variableRateSlope2,
        afterExecution ? 0 : 5_000, // 50% -> 0% (2 decimals)
        'sUSD s2'
      );
    }
  }
  function _assertOracles() internal view {
    assertEq(
      AaveV3Optimism.ORACLE.getSourceOfAsset(AaveV3OptimismAssets.LUSD_UNDERLYING),
      proposal.LUSD_PRICE_FEED(),
      'LUSD source'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getAssetPrice(AaveV3OptimismAssets.LUSD_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'LUSD oracle output'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getSourceOfAsset(AaveV3OptimismAssets.MAI_UNDERLYING),
      proposal.MAI_PRICE_FEED(),
      'MAI source'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getAssetPrice(AaveV3OptimismAssets.MAI_UNDERLYING),
      // $0.953 (8 decimals)
      95_300_000,
      'MAI oracle output'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getSourceOfAsset(AaveV3OptimismAssets.sUSD_UNDERLYING),
      proposal.sUSD_PRICE_FEED(),
      'sUSD source'
    );
    assertEq(
      AaveV3Optimism.ORACLE.getAssetPrice(AaveV3OptimismAssets.sUSD_UNDERLYING),
      // $0.3029 (8 decimals)
      30_290_000,
      'sUSD oracle output'
    );
  }
  function test_payloadStateTransition() public {
    _assertRates(false);
    DataTypes.ReserveConfigurationMap memory expectedLUSD = AaveV3Optimism.POOL.getConfiguration(
      AaveV3OptimismAssets.LUSD_UNDERLYING
    );
    assertEq(expectedLUSD.getSupplyCap(), 1, 'LUSD pre supply cap'); // unchanged
    assertEq(expectedLUSD.getBorrowCap(), 1, 'LUSD pre borrow cap'); // unchanged
    assertEq(expectedLUSD.getFrozen(), false, 'LUSD pre freeze');
    expectedLUSD.setFrozen(true);
    DataTypes.ReserveConfigurationMap memory expectedMAI = AaveV3Optimism.POOL.getConfiguration(
      AaveV3OptimismAssets.MAI_UNDERLYING
    );
    assertEq(expectedMAI.getSupplyCap(), 650_000, 'MAI pre supply cap');
    expectedMAI.setSupplyCap(1);
    assertEq(expectedMAI.getBorrowCap(), 525_000, 'MAI pre borrow cap');
    expectedMAI.setBorrowCap(1);
    assertEq(expectedMAI.getFrozen(), true, 'MAI pre freeze'); // unchanged
    DataTypes.ReserveConfigurationMap memory expectedsUSD = AaveV3Optimism.POOL.getConfiguration(
      AaveV3OptimismAssets.sUSD_UNDERLYING
    );
    assertEq(expectedsUSD.getSupplyCap(), 1, 'sUSD pre supply cap'); // unchanged
    assertEq(expectedsUSD.getBorrowCap(), 1, 'sUSD pre borrow cap'); // unchanged
    assertEq(expectedsUSD.getFrozen(), false, 'sUSD pre freeze');
    expectedsUSD.setFrozen(true);
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
    _assertOracles();
    assertEq(
      AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.LUSD_UNDERLYING).data,
      expectedLUSD.data,
      'LUSD configuration and untouched fields'
    );
    assertEq(
      AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.MAI_UNDERLYING).data,
      expectedMAI.data,
      'MAI configuration and untouched fields'
    );
    assertEq(
      AaveV3Optimism.POOL.getConfiguration(AaveV3OptimismAssets.sUSD_UNDERLYING).data,
      expectedsUSD.data,
      'sUSD configuration and untouched fields'
    );
  }
}
