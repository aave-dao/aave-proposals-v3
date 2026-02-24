// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {MiscInkWhitelabel} from 'aave-address-book/MiscInkWhitelabel.sol';
import {GovernanceV3InkWhitelabel} from 'aave-address-book/GovernanceV3InkWhitelabel.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';
import {IAaveV3ConfigEngine as IEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';

import {ProtocolV3TestBase, GovV3Helpers} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219} from './AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219.sol';
import {IAgentHub} from '../interfaces/IAgentHub.sol';
import {IBaseAaveAgent} from '../interfaces/IBaseAaveAgent.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';
import {IGelatoAutomationHub} from '../interfaces/chaos-agents/IGelatoAutomationHub.sol';

/**
 * @dev Test for AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260219_AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk/AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219.t.sol -vv
 */
contract AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219_Test is ProtocolV3TestBase {
  AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219 internal proposal;

  // Authorized sender for the risk oracle
  address public constant RISK_ORACLE_SENDER = address(55);

  // Agent IDs assigned at setUp based on current hub count
  uint256 internal supplyCapAgentId;
  uint256 internal borrowCapAgentId;
  uint256 internal ratesAgentId;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 38353224);
    proposal = new AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219();

    uint256 startCount = IAgentHub(MiscInkWhitelabel.AGENT_HUB).getAgentCount();
    supplyCapAgentId = startCount;
    borrowCapAgentId = startCount + 1;
    ratesAgentId = startCount + 2;

    // mock adding sender as it is not added yet on risk-oracle
    vm.startPrank(0xDe841Bf4B67970f5a19165443B0e9ec808E1cC85);
    IRiskOracle(proposal.RISK_ORACLE()).addAuthorizedSender(RISK_ORACLE_SENDER);
    vm.stopPrank();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3InkWhitelabel_ActivateRatesAndCapsAgentOnInk_20260219',
      AaveV3InkWhitelabel.POOL,
      address(proposal),
      true,
      true
    );
  }

  function test_riskAdminRole() public {
    assertFalse(AaveV3InkWhitelabel.ACL_MANAGER.isRiskAdmin(proposal.SUPPLY_CAP_AGENT()));
    assertFalse(AaveV3InkWhitelabel.ACL_MANAGER.isRiskAdmin(proposal.BORROW_CAP_AGENT()));
    assertFalse(AaveV3InkWhitelabel.ACL_MANAGER.isRiskAdmin(proposal.RATES_AGENT()));

    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    assertTrue(AaveV3InkWhitelabel.ACL_MANAGER.isRiskAdmin(proposal.SUPPLY_CAP_AGENT()));
    assertTrue(AaveV3InkWhitelabel.ACL_MANAGER.isRiskAdmin(proposal.BORROW_CAP_AGENT()));
    assertTrue(AaveV3InkWhitelabel.ACL_MANAGER.isRiskAdmin(proposal.RATES_AGENT()));
  }

  function test_agentsRegistered() public {
    uint256 agentCountBefore = IAgentHub(MiscInkWhitelabel.AGENT_HUB).getAgentCount();

    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    uint256 agentCountAfter = IAgentHub(MiscInkWhitelabel.AGENT_HUB).getAgentCount();
    assertEq(agentCountAfter, agentCountBefore + 3);

    assertEq(
      IAgentHub(MiscInkWhitelabel.AGENT_HUB).getUpdateType(supplyCapAgentId),
      'SupplyCapUpdate'
    );
    assertEq(
      IAgentHub(MiscInkWhitelabel.AGENT_HUB).getUpdateType(borrowCapAgentId),
      'BorrowCapUpdate'
    );
    assertEq(
      IAgentHub(MiscInkWhitelabel.AGENT_HUB).getUpdateType(ratesAgentId),
      'RateStrategyUpdate'
    );
  }

  function test_validateAgentContractImmutables() public {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    address supplyCapAgentContract = IAgentHub(MiscInkWhitelabel.AGENT_HUB).getAgentAddress(
      supplyCapAgentId
    );
    assertEq(
      address(IBaseAaveAgent(supplyCapAgentContract).RANGE_VALIDATION_MODULE()),
      MiscInkWhitelabel.RANGE_VALIDATION_MODULE
    );
    assertEq(
      address(IBaseAaveAgent(supplyCapAgentContract).POOL()),
      address(AaveV3InkWhitelabel.POOL)
    );
    assertEq(
      address(IBaseAaveAgent(supplyCapAgentContract).AGENT_HUB()),
      MiscInkWhitelabel.AGENT_HUB
    );

    address borrowCapAgentContract = IAgentHub(MiscInkWhitelabel.AGENT_HUB).getAgentAddress(
      borrowCapAgentId
    );
    assertEq(
      address(IBaseAaveAgent(borrowCapAgentContract).RANGE_VALIDATION_MODULE()),
      MiscInkWhitelabel.RANGE_VALIDATION_MODULE
    );
    assertEq(
      address(IBaseAaveAgent(borrowCapAgentContract).POOL()),
      address(AaveV3InkWhitelabel.POOL)
    );
    assertEq(
      address(IBaseAaveAgent(borrowCapAgentContract).AGENT_HUB()),
      MiscInkWhitelabel.AGENT_HUB
    );

    address ratesAgentContract = IAgentHub(MiscInkWhitelabel.AGENT_HUB).getAgentAddress(
      ratesAgentId
    );
    assertEq(
      address(IBaseAaveAgent(ratesAgentContract).RANGE_VALIDATION_MODULE()),
      MiscInkWhitelabel.RANGE_VALIDATION_MODULE
    );
    assertEq(address(IBaseAaveAgent(ratesAgentContract).POOL()), address(AaveV3InkWhitelabel.POOL));
    assertEq(address(IBaseAaveAgent(ratesAgentContract).AGENT_HUB()), MiscInkWhitelabel.AGENT_HUB);
  }

  function test_rangeValidationConfiguration() public {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    // Supply cap default range: 30% relative increase/decrease
    IRangeValidationModule.RangeConfig memory supplyCapConfig = IRangeValidationModule(
      MiscInkWhitelabel.RANGE_VALIDATION_MODULE
    ).getDefaultRangeConfig(MiscInkWhitelabel.AGENT_HUB, supplyCapAgentId, 'SupplyCapUpdate');
    assertEq(supplyCapConfig.maxIncrease, 30_00);
    assertEq(supplyCapConfig.maxDecrease, 30_00);
    assertEq(supplyCapConfig.isIncreaseRelative, true);
    assertEq(supplyCapConfig.isDecreaseRelative, true);

    // Borrow cap default range: 30% relative increase/decrease
    IRangeValidationModule.RangeConfig memory borrowCapConfig = IRangeValidationModule(
      MiscInkWhitelabel.RANGE_VALIDATION_MODULE
    ).getDefaultRangeConfig(MiscInkWhitelabel.AGENT_HUB, borrowCapAgentId, 'BorrowCapUpdate');
    assertEq(borrowCapConfig.maxIncrease, 30_00);
    assertEq(borrowCapConfig.maxDecrease, 30_00);
    assertEq(borrowCapConfig.isIncreaseRelative, true);
    assertEq(borrowCapConfig.isDecreaseRelative, true);

    // Rates per-market range configs
    address[] memory ratesMarkets = proposal.getAllowedMarketsForRates();
    for (uint256 i = 0; i < ratesMarkets.length; i++) {
      address market = ratesMarkets[i];

      // OptimalUsageRatio: 1% absolute for all markets
      IRangeValidationModule.RangeConfig memory optimalConfig = IRangeValidationModule(
        MiscInkWhitelabel.RANGE_VALIDATION_MODULE
      ).getRangeConfigByMarket(
          MiscInkWhitelabel.AGENT_HUB,
          ratesAgentId,
          market,
          'OptimalUsageRatio'
        );
      assertEq(optimalConfig.maxIncrease, 1_00);
      assertEq(optimalConfig.maxDecrease, 1_00);
      assertEq(optimalConfig.isIncreaseRelative, false);
      assertEq(optimalConfig.isDecreaseRelative, false);

      // BaseVariableBorrowRate: 0.5% absolute for all markets
      IRangeValidationModule.RangeConfig memory baseConfig = IRangeValidationModule(
        MiscInkWhitelabel.RANGE_VALIDATION_MODULE
      ).getRangeConfigByMarket(
          MiscInkWhitelabel.AGENT_HUB,
          ratesAgentId,
          market,
          'BaseVariableBorrowRate'
        );
      assertEq(baseConfig.maxIncrease, 10);
      assertEq(baseConfig.maxDecrease, 10);
      assertEq(baseConfig.isIncreaseRelative, false);
      assertEq(baseConfig.isDecreaseRelative, false);

      if (
        market == AaveV3InkWhitelabelAssets.kBTC_UNDERLYING ||
        market == AaveV3InkWhitelabelAssets.WETH_UNDERLYING
      ) {
        // VariableRateSlope1: 0.15% absolute for WETH/kBTC
        IRangeValidationModule.RangeConfig memory slope1Config = IRangeValidationModule(
          MiscInkWhitelabel.RANGE_VALIDATION_MODULE
        ).getRangeConfigByMarket(
            MiscInkWhitelabel.AGENT_HUB,
            ratesAgentId,
            market,
            'VariableRateSlope1'
          );
        assertEq(slope1Config.maxIncrease, 15);
        assertEq(slope1Config.maxDecrease, 15);
        assertEq(slope1Config.isIncreaseRelative, false);
        assertEq(slope1Config.isDecreaseRelative, false);

        // VariableRateSlope2: 1.5% absolute for WETH/kBTC
        IRangeValidationModule.RangeConfig memory slope2Config = IRangeValidationModule(
          MiscInkWhitelabel.RANGE_VALIDATION_MODULE
        ).getRangeConfigByMarket(
            MiscInkWhitelabel.AGENT_HUB,
            ratesAgentId,
            market,
            'VariableRateSlope2'
          );
        assertEq(slope2Config.maxIncrease, 1_50);
        assertEq(slope2Config.maxDecrease, 1_50);
        assertEq(slope2Config.isIncreaseRelative, false);
        assertEq(slope2Config.isDecreaseRelative, false);
      } else {
        // VariableRateSlope1: 0.2% absolute for other assets
        IRangeValidationModule.RangeConfig memory slope1Config = IRangeValidationModule(
          MiscInkWhitelabel.RANGE_VALIDATION_MODULE
        ).getRangeConfigByMarket(
            MiscInkWhitelabel.AGENT_HUB,
            ratesAgentId,
            market,
            'VariableRateSlope1'
          );
        assertEq(slope1Config.maxIncrease, 20);
        assertEq(slope1Config.maxDecrease, 20);
        assertEq(slope1Config.isIncreaseRelative, false);
        assertEq(slope1Config.isDecreaseRelative, false);

        // VariableRateSlope2: 2% absolute for other assets
        IRangeValidationModule.RangeConfig memory slope2Config = IRangeValidationModule(
          MiscInkWhitelabel.RANGE_VALIDATION_MODULE
        ).getRangeConfigByMarket(
            MiscInkWhitelabel.AGENT_HUB,
            ratesAgentId,
            market,
            'VariableRateSlope2'
          );
        assertEq(slope2Config.maxIncrease, 2_00);
        assertEq(slope2Config.maxDecrease, 2_00);
        assertEq(slope2Config.isIncreaseRelative, false);
        assertEq(slope2Config.isDecreaseRelative, false);
      }
    }
  }

  // Injects all rate params at the configured limits for each market.
  // slope1 and slope2 limits differ between WETH/kBTC and other assets.
  function test_injection_rates() public {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    address[] memory ratesMarkets = proposal.getAllowedMarketsForRates();
    for (uint256 i = 0; i < ratesMarkets.length; i++) {
      address market = ratesMarkets[i];
      address rateStrategyAddress = AaveV3InkWhitelabel
        .AAVE_PROTOCOL_DATA_PROVIDER
        .getInterestRateStrategyAddress(market);

      IDefaultInterestRateStrategyV2.InterestRateData
        memory currentRate = IDefaultInterestRateStrategyV2(rateStrategyAddress)
          .getInterestRateDataBps(market);

      // slope1 and slope2 limits differ for WETH/kBTC vs other assets
      uint256 slope1Change;
      uint256 slope2Change;
      if (
        market == AaveV3InkWhitelabelAssets.kBTC_UNDERLYING ||
        market == AaveV3InkWhitelabelAssets.WETH_UNDERLYING
      ) {
        slope1Change = 15; // 0.15% - at limit for WETH/kBTC
        slope2Change = 1_50; // 1.5% - at limit for WETH/kBTC
      } else {
        slope1Change = 20; // 0.2% - at limit for other assets
        slope2Change = 2_00; // 2% - at limit for other assets
      }

      IEngine.InterestRateInputData memory newRate = IEngine.InterestRateInputData({
        optimalUsageRatio: uint256(currentRate.optimalUsageRatio) + 1_00, // 1% - at uOptimal limit
        baseVariableBorrowRate: uint256(currentRate.baseVariableBorrowRate) + 10, // 0.1% - at baseRate limit
        variableRateSlope1: uint256(currentRate.variableRateSlope1) + slope1Change,
        variableRateSlope2: uint256(currentRate.variableRateSlope2) + slope2Change
      });

      vm.startPrank(RISK_ORACLE_SENDER);
      IRiskOracle(proposal.RISK_ORACLE()).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newRate),
        'RateStrategyUpdate',
        market,
        'additionalData'
      );
      vm.stopPrank();

      assertTrue(_checkAndPerformAutomation(ratesAgentId));
    }
  }

  // Publishes a slope2 update exceeding the configured limit for each market.
  // All other params are kept at current values to isolate the slope2 violation.
  function test_injection_rates_wrong_updates() public {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    address[] memory ratesMarkets = proposal.getAllowedMarketsForRates();
    for (uint256 i = 0; i < ratesMarkets.length; i++) {
      address market = ratesMarkets[i];
      address rateStrategyAddress = AaveV3InkWhitelabel
        .AAVE_PROTOCOL_DATA_PROVIDER
        .getInterestRateStrategyAddress(market);

      IDefaultInterestRateStrategyV2.InterestRateData
        memory currentRate = IDefaultInterestRateStrategyV2(rateStrategyAddress)
          .getInterestRateDataBps(market);

      // slope2 change exceeding the limit: 1.51% for WETH/kBTC, 2.01% for other assets
      uint256 slope2WrongChange;
      if (
        market == AaveV3InkWhitelabelAssets.kBTC_UNDERLYING ||
        market == AaveV3InkWhitelabelAssets.WETH_UNDERLYING
      ) {
        slope2WrongChange = 1_51; // 1.51% - exceeds 1.5% limit for WETH/kBTC
      } else {
        slope2WrongChange = 2_01; // 2.01% - exceeds 2% limit for other assets
      }

      IEngine.InterestRateInputData memory newRate = IEngine.InterestRateInputData({
        optimalUsageRatio: currentRate.optimalUsageRatio,
        baseVariableBorrowRate: currentRate.baseVariableBorrowRate,
        variableRateSlope1: currentRate.variableRateSlope1,
        variableRateSlope2: uint256(currentRate.variableRateSlope2) + slope2WrongChange
      });

      vm.startPrank(RISK_ORACLE_SENDER);
      IRiskOracle(proposal.RISK_ORACLE()).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newRate),
        'RateStrategyUpdate',
        market,
        'additionalData'
      );
      vm.stopPrank();

      assertFalse(_checkAndPerformAutomation(ratesAgentId));
    }
  }

  function test_injection_caps() public {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    address[] memory supplyCapMarkets = proposal.getAllowedMarketsForSupplyCap();
    for (uint256 i = 0; i < supplyCapMarkets.length; i++) {
      address market = supplyCapMarkets[i];
      (, uint256 supplyCap) = AaveV3InkWhitelabel.AAVE_PROTOCOL_DATA_PROVIDER.getReserveCaps(
        market
      );
      uint256 newSupplyCap = (supplyCap * 130) / 100; // 30% increase - within 30% limit

      vm.startPrank(RISK_ORACLE_SENDER);
      IRiskOracle(proposal.RISK_ORACLE()).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newSupplyCap),
        'SupplyCapUpdate',
        market,
        'additionalData'
      );
      vm.stopPrank();
      assertTrue(_checkAndPerformAutomation(supplyCapAgentId));
    }

    address[] memory borrowCapMarkets = proposal.getAllowedMarketsForBorrowCap();
    for (uint256 i = 0; i < borrowCapMarkets.length; i++) {
      address market = borrowCapMarkets[i];
      (uint256 borrowCap, ) = AaveV3InkWhitelabel.AAVE_PROTOCOL_DATA_PROVIDER.getReserveCaps(
        market
      );
      uint256 newBorrowCap = (borrowCap * 130) / 100; // 30% increase - within 30% limit

      vm.startPrank(RISK_ORACLE_SENDER);
      IRiskOracle(proposal.RISK_ORACLE()).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newBorrowCap),
        'BorrowCapUpdate',
        market,
        'additionalData'
      );
      vm.stopPrank();

      assertTrue(_checkAndPerformAutomation(borrowCapAgentId));
    }
  }

  function test_injection_caps_wrong_updates() public {
    GovV3Helpers.executePayload(
      vm,
      address(proposal),
      address(GovernanceV3InkWhitelabel.PERMISSIONED_PAYLOADS_CONTROLLER)
    );

    address[] memory supplyCapMarkets = proposal.getAllowedMarketsForSupplyCap();
    for (uint256 i = 0; i < supplyCapMarkets.length; i++) {
      address market = supplyCapMarkets[i];
      (, uint256 supplyCap) = AaveV3InkWhitelabel.AAVE_PROTOCOL_DATA_PROVIDER.getReserveCaps(
        market
      );
      uint256 newSupplyCap = (supplyCap * 131) / 100; // 31% increase - exceeds 30% limit

      vm.startPrank(RISK_ORACLE_SENDER);
      IRiskOracle(proposal.RISK_ORACLE()).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newSupplyCap),
        'SupplyCapUpdate',
        market,
        'additionalData'
      );
      vm.stopPrank();
      assertFalse(_checkAndPerformAutomation(supplyCapAgentId));
    }

    address[] memory borrowCapMarkets = proposal.getAllowedMarketsForBorrowCap();
    for (uint256 i = 0; i < borrowCapMarkets.length; i++) {
      address market = borrowCapMarkets[i];
      (uint256 borrowCap, ) = AaveV3InkWhitelabel.AAVE_PROTOCOL_DATA_PROVIDER.getReserveCaps(
        market
      );
      uint256 newBorrowCap = (borrowCap * 131) / 100; // 31% increase - exceeds 30% limit

      vm.startPrank(RISK_ORACLE_SENDER);
      IRiskOracle(proposal.RISK_ORACLE()).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(newBorrowCap),
        'BorrowCapUpdate',
        market,
        'additionalData'
      );
      vm.stopPrank();
      assertFalse(_checkAndPerformAutomation(borrowCapAgentId));
    }
  }

  function _checkAndPerformAutomation(uint256 agentId) internal returns (bool) {
    uint256[] memory agentIds = new uint256[](1);
    agentIds[0] = agentId;

    (bool upkeepNeeded, bytes memory encodedPerformData) = IGelatoAutomationHub(
      MiscInkWhitelabel.AGENT_HUB_AUTOMATION
    ).check(agentIds);

    if (upkeepNeeded) {
      (bool status, ) = address(MiscInkWhitelabel.AGENT_HUB_AUTOMATION).call(encodedPerformData);
      assertTrue(status);
    }
    return upkeepNeeded;
  }
}
