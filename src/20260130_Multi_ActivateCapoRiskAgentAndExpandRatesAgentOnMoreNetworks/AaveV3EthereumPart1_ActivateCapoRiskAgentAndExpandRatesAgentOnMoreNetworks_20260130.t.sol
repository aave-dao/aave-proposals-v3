// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLido} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GovV3Helpers} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

import {AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130} from './AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.sol';
import {IRangeValidationModule} from '../interfaces/IRangeValidationModule.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';
import {IPriceCapAdapter} from '../interfaces/IPriceCapAdapter.sol';
import {BaseActivateRiskAgentTest} from './BaseActivateRiskAgentTest.t.sol';

/**
 * @dev Test for AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260130_Multi_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks/AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130.t.sol -vv
 */
contract AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130_Test is
  BaseActivateRiskAgentTest
{
  using SafeCast for uint256;

  AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130
    internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 24390711);
    proposal = new AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130();
  }

  function _getConfig() internal view override returns (TestConfig memory) {
    return
      TestConfig({
        pool: AaveV3Ethereum.POOL,
        aclManager: AaveV3Ethereum.ACL_MANAGER,
        protocolDataProvider: AaveV3Ethereum.AAVE_PROTOCOL_DATA_PROVIDER,
        agentHub: MiscEthereum.AGENT_HUB,
        rangeValidationModule: MiscEthereum.RANGE_VALIDATION_MODULE,
        agentHubAutomation: MiscEthereum.AGENT_HUB_AUTOMATION,
        robotOperator: MiscEthereum.AAVE_CL_ROBOT_OPERATOR,
        edgeRiskOracle: address(AaveV3Ethereum.EDGE_RISK_ORACLE),
        proposal: address(proposal),
        riskAgent: proposal.CAPO_AGENT(),
        linkAmount: proposal.LINK_AMOUNT(),
        assetsToEnable: proposal.getAllowedMarkets(),
        testName: 'AaveV3EthereumPart1_ActivateCapoRiskAgentAndExpandRatesAgentOnMoreNetworks_20260130',
        agentId: 4,
        updateType: 'CapoPriceCapUpdate_Core'
      });
  }

  // Ethereum checks both Core and Lido ACL managers
  function test_riskAdminRole() public override {
    TestConfig memory config = _getConfig();
    address agentContract = config.riskAgent;

    assertFalse(AaveV3Ethereum.ACL_MANAGER.isRiskAdmin(agentContract));
    assertFalse(AaveV3EthereumLido.ACL_MANAGER.isRiskAdmin(agentContract));

    GovV3Helpers.executePayload(vm, config.proposal);

    assertTrue(AaveV3Ethereum.ACL_MANAGER.isRiskAdmin(agentContract));
    assertTrue(AaveV3EthereumLido.ACL_MANAGER.isRiskAdmin(agentContract));
  }

  function test_rangeValidationConfiguration() public {
    TestConfig memory config = _getConfig();
    GovV3Helpers.executePayload(vm, config.proposal);

    IRangeValidationModule.RangeConfig memory snapshotConfig = IRangeValidationModule(
      config.rangeValidationModule
    ).getDefaultRangeConfig(config.agentHub, config.agentId, 'CapoSnapshotRatio');
    assertEq(snapshotConfig.maxIncrease, 3_00);
    assertEq(snapshotConfig.maxDecrease, 3_00);
    assertEq(snapshotConfig.isIncreaseRelative, true);
    assertEq(snapshotConfig.isDecreaseRelative, true);

    IRangeValidationModule.RangeConfig memory maxGrowthConfig = IRangeValidationModule(
      config.rangeValidationModule
    ).getDefaultRangeConfig(config.agentHub, config.agentId, 'CapoMaxYearlyGrowthRatePercent');
    assertEq(maxGrowthConfig.maxIncrease, 10_00);
    assertEq(maxGrowthConfig.maxDecrease, 10_00);
    assertEq(maxGrowthConfig.isIncreaseRelative, true);
    assertEq(maxGrowthConfig.isDecreaseRelative, true);
  }

  function test_injection_capo() public {
    TestConfig memory config = _getConfig();
    GovV3Helpers.executePayload(vm, config.proposal);

    for (
      uint256 i = 0;
      i < config.assetsToEnable.length && config.assetsToEnable[i] != address(0);
      i++
    ) {
      vm.startPrank(0x42939e82DF15afc586bb95f7dD69Afb6Dc24A6f9);
      IPriceCapAdapter capo = IPriceCapAdapter(
        AaveV3Ethereum.ORACLE.getSourceOfAsset(config.assetsToEnable[i])
      );

      IRiskOracle(config.edgeRiskOracle).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(
          IPriceCapAdapter.PriceCapUpdateParams({
            snapshotRatio: ((capo.getSnapshotRatio() * 103) / 100).toUint104(), // 3% increase
            snapshotTimestamp: (capo.getSnapshotTimestamp() + 1).toUint48(),
            maxYearlyRatioGrowthPercent: ((capo.getMaxYearlyGrowthRatePercent() * 110) / 100)
              .toUint16() // 10% increase
          })
        ),
        'CapoPriceCapUpdate_Core',
        config.assetsToEnable[i],
        'additionalData'
      );
      vm.stopPrank();

      // check injection
      assertTrue(_checkAndPerformAutomation(config.agentHubAutomation, config.agentId));
    }
  }

  function test_injection_capo_wrong_update() public {
    TestConfig memory config = _getConfig();
    GovV3Helpers.executePayload(vm, config.proposal);

    for (
      uint256 i = 0;
      i < config.assetsToEnable.length && config.assetsToEnable[i] != address(0);
      i++
    ) {
      vm.startPrank(0x42939e82DF15afc586bb95f7dD69Afb6Dc24A6f9);
      IPriceCapAdapter capo = IPriceCapAdapter(
        AaveV3Ethereum.ORACLE.getSourceOfAsset(config.assetsToEnable[i])
      );

      IRiskOracle(config.edgeRiskOracle).publishRiskParameterUpdate(
        'referenceId',
        abi.encode(
          IPriceCapAdapter.PriceCapUpdateParams({
            snapshotRatio: ((capo.getSnapshotRatio() * 104) / 100).toUint104(), // 4% increase
            snapshotTimestamp: (capo.getSnapshotTimestamp() + 1).toUint48(),
            maxYearlyRatioGrowthPercent: ((capo.getMaxYearlyGrowthRatePercent() * 111) / 100)
              .toUint16() // 11% increase
          })
        ),
        'CapoPriceCapUpdate_Core',
        config.assetsToEnable[i],
        'additionalData'
      );
      vm.stopPrank();

      // check injection
      assertFalse(_checkAndPerformAutomation(config.agentHubAutomation, config.agentId));
    }
  }

  function test_BgdReceivedLinkToken() public {
    uint256 balanceBefore = IERC20(AaveV3EthereumAssets.LINK_UNDERLYING).balanceOf(
      proposal.BGD_RECEIVER()
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 balanceAfter = IERC20(AaveV3EthereumAssets.LINK_UNDERLYING).balanceOf(
      proposal.BGD_RECEIVER()
    );

    assertEq(balanceAfter - balanceBefore, 108 ether);
  }
}
