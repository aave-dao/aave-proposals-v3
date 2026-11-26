// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {AggregatorInterface} from 'aave-v3-origin/contracts/dependencies/chainlink/AggregatorInterface.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IPool} from 'aave-v3-origin/contracts/interfaces/IPool.sol';
import {IAaveOracle} from 'aave-v3-origin/contracts/interfaces/IAaveOracle.sol';
import {IACLManager} from 'aave-v3-origin/contracts/interfaces/IACLManager.sol';
import {IPoolAddressesProvider} from 'aave-v3-origin/contracts/interfaces/IPoolAddressesProvider.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {IncentivizedERC20} from 'aave-v3-origin/contracts/protocol/tokenization/base/IncentivizedERC20.sol';
import {ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IRwaOracleParameterRegistry} from './IRwaOracleParameterRegistry.sol';
import {AaveV3EthereumHorizonCustom} from './AaveV3EthereumHorizonCustom.sol';
import {AaveV3EthereumHorizon, AaveV3EthereumHorizonAssets} from 'aave-address-book/AaveV3EthereumHorizon.sol';
import {Errors} from './Errors.sol';

/**
 * @dev Pool-wide validations for Horizon proposals (access control, oracle prices,
 *      aToken implementations, RWA oracle registrations, interest rate strategies,
 *      config sanity) that run automatically on every proposal test.
 */
abstract contract HorizonConfigAssertionHelper is Test {
  bytes32 internal constant EIP1967_IMPL_SLOT =
    bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);

  // ─── Pool-wide validations ────────────────────────────────────────

  function _runHorizonValidations(IPool pool, ReserveConfig[] memory configs) internal {
    _validateAccessControl(pool);
    _validateOracles(pool, configs);
    _validateATokenImplementations(configs);
    _validateRwaOracleRegistrations(configs);
    _validateInterestRateStrategies(configs);
    _validateConfigSanity(configs);
  }

  function _validateAccessControl(IPool pool) internal view {
    IACLManager aclManager = IACLManager(
      IPoolAddressesProvider(pool.ADDRESSES_PROVIDER()).getACLManager()
    );

    // HORIZON_EXECUTOR: AssetListingAdmin + RiskAdmin only (listing executor)
    assertFalse(
      aclManager.isPoolAdmin(AaveV3EthereumHorizonCustom.HORIZON_EXECUTOR),
      'VALIDATION: executor should not be pool admin'
    );
    assertFalse(
      aclManager.isEmergencyAdmin(AaveV3EthereumHorizonCustom.HORIZON_EXECUTOR),
      'VALIDATION: executor should not be emergency admin'
    );
    assertTrue(
      aclManager.isAssetListingAdmin(AaveV3EthereumHorizonCustom.HORIZON_EXECUTOR),
      'VALIDATION: executor should be asset listing admin'
    );
    assertTrue(
      aclManager.isRiskAdmin(AaveV3EthereumHorizonCustom.HORIZON_EXECUTOR),
      'VALIDATION: executor should be risk admin'
    );

    // HORIZON_EMERGENCY: PoolAdmin + EmergencyAdmin only
    assertTrue(
      aclManager.isPoolAdmin(AaveV3EthereumHorizonCustom.HORIZON_EMERGENCY),
      'VALIDATION: emergency should be pool admin'
    );
    assertTrue(
      aclManager.isEmergencyAdmin(AaveV3EthereumHorizonCustom.HORIZON_EMERGENCY),
      'VALIDATION: emergency should be emergency admin'
    );
    assertFalse(
      aclManager.isAssetListingAdmin(AaveV3EthereumHorizonCustom.HORIZON_EMERGENCY),
      'VALIDATION: emergency should not be asset listing admin'
    );
    assertFalse(
      aclManager.isRiskAdmin(AaveV3EthereumHorizonCustom.HORIZON_EMERGENCY),
      'VALIDATION: emergency should not be risk admin'
    );

    // HORIZON_OPS: RiskAdmin only (operational multisig)
    assertFalse(
      aclManager.isPoolAdmin(AaveV3EthereumHorizonCustom.HORIZON_OPS),
      'VALIDATION: ops should not be pool admin'
    );
    assertFalse(
      aclManager.isEmergencyAdmin(AaveV3EthereumHorizonCustom.HORIZON_OPS),
      'VALIDATION: ops should not be emergency admin'
    );
    assertFalse(
      aclManager.isAssetListingAdmin(AaveV3EthereumHorizonCustom.HORIZON_OPS),
      'VALIDATION: ops should not be asset listing admin'
    );
    assertTrue(
      aclManager.isRiskAdmin(AaveV3EthereumHorizonCustom.HORIZON_OPS),
      'VALIDATION: ops should be risk admin'
    );
  }

  function _validateOracles(IPool pool, ReserveConfig[] memory configs) internal view {
    IAaveOracle oracle = IAaveOracle(
      IPoolAddressesProvider(pool.ADDRESSES_PROVIDER()).getPriceOracle()
    );
    for (uint256 i; i < configs.length; i++) {
      uint256 price = oracle.getAssetPrice(configs[i].underlying);
      assertTrue(price > 0, string.concat('VALIDATION: zero oracle price for ', configs[i].symbol));
      address source = oracle.getSourceOfAsset(configs[i].underlying);
      assertEq(
        AggregatorInterface(source).decimals(),
        8,
        string.concat('VALIDATION: unexpected oracle decimals for ', configs[i].symbol)
      );
      address expectedFeed = _expectedPriceFeed(configs[i].underlying);
      assertEq(
        source,
        expectedFeed,
        string.concat('VALIDATION: oracle source mismatch for ', configs[i].symbol)
      );
    }
  }

  function _expectedPriceFeed(address underlying) internal pure virtual returns (address) {
    if (underlying == AaveV3EthereumHorizonAssets.USTB_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.USTB_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.USCC_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.USCC_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.USYC_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.USYC_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.JTRSY_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.JTRSY_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.JAAA_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.JAAA_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.VBILL_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.VBILL_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.GHO_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.GHO_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.USDC_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.USDC_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonAssets.RLUSD_UNDERLYING) {
      return AaveV3EthereumHorizonAssets.RLUSD_ORACLE;
    }
    if (underlying == AaveV3EthereumHorizonCustom.ACRED_UNDERLYING) {
      return AaveV3EthereumHorizonCustom.ACRED_PRICE_FEED;
    }
    if (underlying == AaveV3EthereumHorizonCustom.MGLOBAL_UNDERLYING) {
      return AaveV3EthereumHorizonCustom.MGLOBAL_PRICE_FEED;
    }
    revert('_expectedPriceFeed: unknown underlying');
  }

  function _validateATokenImplementations(ReserveConfig[] memory configs) internal {
    for (uint256 i; i < configs.length; i++) {
      address impl = _getProxyImplementation(configs[i].aToken);
      bool isRwa = _isRwaATokenImpl(impl);
      bool isStandard = _isStandardATokenImpl(impl);
      assertTrue(
        isRwa || isStandard,
        string.concat('VALIDATION: unknown aToken impl for ', configs[i].symbol)
      );
      if (isRwa) {
        // rwa aTokens do not support approve
        vm.expectRevert(bytes(Errors.OPERATION_NOT_SUPPORTED));
        IERC20(configs[i].aToken).approve(address(1), 0);
      }

      // verify incentives controller on aToken
      assertEq(
        address(IncentivizedERC20(configs[i].aToken).getIncentivesController()),
        AaveV3EthereumHorizon.DEFAULT_INCENTIVES_CONTROLLER,
        string.concat('VALIDATION: unexpected aToken incentivesController for ', configs[i].symbol)
      );

      // verify incentives controller on variable debt token
      assertEq(
        address(IncentivizedERC20(configs[i].variableDebtToken).getIncentivesController()),
        AaveV3EthereumHorizon.DEFAULT_INCENTIVES_CONTROLLER,
        string.concat(
          'VALIDATION: unexpected variableDebtToken incentivesController for ',
          configs[i].symbol
        )
      );
    }
  }

  function _validateRwaOracleRegistrations(ReserveConfig[] memory configs) internal view {
    for (uint256 i; i < configs.length; i++) {
      if (_isRwaAToken(configs[i].aToken)) {
        assertTrue(
          IRwaOracleParameterRegistry(AaveV3EthereumHorizonCustom.RWA_ORACLE_PARAMS_REGISTRY)
            .assetExists(configs[i].underlying),
          string.concat('VALIDATION: RWA not in oracle registry for ', configs[i].symbol)
        );
      }
    }
  }

  function _validateInterestRateStrategies(ReserveConfig[] memory configs) internal view {
    IDefaultInterestRateStrategyV2 strategy = IDefaultInterestRateStrategyV2(
      AaveV3EthereumHorizonCustom.DEFAULT_INTEREST_RATE_STRATEGY
    );
    for (uint256 i; i < configs.length; i++) {
      assertEq(
        configs[i].interestRateStrategy,
        address(strategy),
        string.concat('VALIDATION: unexpected IR strategy for ', configs[i].symbol)
      );
      IDefaultInterestRateStrategyV2.InterestRateData memory rateData = strategy
        .getInterestRateDataBps(configs[i].underlying);
      assertTrue(
        rateData.optimalUsageRatio > 0,
        string.concat('VALIDATION: zero optimalUsageRatio for ', configs[i].symbol)
      );
    }
  }

  function _validateConfigSanity(ReserveConfig[] memory configs) internal pure {
    for (uint256 i; i < configs.length; i++) {
      if (configs[i].usageAsCollateralEnabled) {
        assertTrue(
          configs[i].ltv <= configs[i].liquidationThreshold,
          string.concat('VALIDATION: ltv > liquidationThreshold for ', configs[i].symbol)
        );
      }
    }
  }

  function _getProxyImplementation(address proxy) internal view returns (address) {
    return address(uint160(uint256(vm.load(proxy, EIP1967_IMPL_SLOT))));
  }

  function _isRwaAToken(address aToken) internal view returns (bool) {
    return _isRwaATokenImpl(_getProxyImplementation(aToken));
  }

  function _isRwaATokenImpl(address impl) internal pure returns (bool) {
    return impl == AaveV3EthereumHorizonCustom.RWA_A_TOKEN_IMPL;
  }

  function _isStandardATokenImpl(address impl) internal pure returns (bool) {
    return impl == AaveV3EthereumHorizonCustom.DEFAULT_A_TOKEN_IMPL;
  }
}
