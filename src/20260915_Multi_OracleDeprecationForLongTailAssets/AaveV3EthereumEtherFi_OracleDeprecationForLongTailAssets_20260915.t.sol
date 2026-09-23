// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3EthereumEtherFi, AaveV3EthereumEtherFiAssets} from 'aave-address-book/AaveV3EthereumEtherFi.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import 'forge-std/Test.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915} from './AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915.sol';

import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

/**
 * @dev Test for AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260915_Multi_OracleDeprecationForLongTailAssets/AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915.t.sol -vv
 */
contract AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915_Test is
  ProtocolV3TestBase
{
  AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915 internal proposal;

  mapping(address => IDefaultInterestRateStrategyV2.InterestRateDataRay) internal _ratesBefore;

  address internal _strategyBefore;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26_032_357);
    proposal = new AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915();
    _strategyBefore = AaveV3EthereumEtherFi.POOL.RESERVE_INTEREST_RATE_STRATEGY();
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(_strategyBefore);
    _ratesBefore[AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING] = strategy.getInterestRateData(
      AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING
    );
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3EthereumEtherFi_OracleDeprecationForLongTailAssets_20260915',
      AaveV3EthereumEtherFi.POOL,
      address(proposal)
    );
  }

  function test_rateStrategies() public {
    _assertRates(false);
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertRates(true);
  }

  function test_oracles() public {
    GovV3Helpers.executePayload(vm, address(proposal));
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
    _validateInterestRateStrategy(
      AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING,
      AaveV3EthereumEtherFi.POOL.RESERVE_INTEREST_RATE_STRATEGY(),
      _strategyBefore,
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: _ratesBefore[AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING]
          .optimalUsageRatio,
        baseVariableBorrowRate: afterExecution ? 200_000_000_000_000_000_000_000_000 : 0, // 0% -> 20% (27 decimals)
        variableRateSlope1: _ratesBefore[AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING]
          .variableRateSlope1,
        variableRateSlope2: _ratesBefore[AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING]
          .variableRateSlope2
      })
    );
  }
  function _assertOracles() internal view {
    _validateAssetSourceOnOracle(
      AaveV3EthereumEtherFi.POOL_ADDRESSES_PROVIDER,
      AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING,
      proposal.FRAX_PRICE_FEED()
    );
    assertEq(
      AaveV3EthereumEtherFi.ORACLE.getAssetPrice(AaveV3EthereumEtherFiAssets.FRAX_UNDERLYING),
      // $1 (8 decimals)
      100_000_000,
      'FRAX oracle output'
    );
  }
}
