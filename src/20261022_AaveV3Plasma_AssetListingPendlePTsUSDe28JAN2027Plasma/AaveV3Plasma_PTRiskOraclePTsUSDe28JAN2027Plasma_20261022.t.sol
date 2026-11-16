// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Plasma, AaveV3PlasmaAssets, AaveV3PlasmaEModes} from 'aave-address-book/AaveV3Plasma.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';

import 'forge-std/Test.sol';
import {AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022} from './AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022.sol';
import {AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022} from './AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022.sol';
import {AgentHubConfigs} from '../helpers/agent-hub/Configs.sol';
import {IAgentHub} from '../interfaces/IAgentHub.sol';
import {IPendlePriceCapAdapter} from '../interfaces/IPendlePriceCapAdapter.sol';
import {IRiskOracle} from '../interfaces/IRiskOracle.sol';

/**
 * @dev Test for AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022, executed after the listing payload
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261022_AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma/AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022.t.sol -vv
 */
contract AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022_Test is Test {
  uint8 internal constant EXPECTED_EMODE_ID = 27;

  AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022 internal listing;
  AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022 internal proposal;
  IAgentHub internal hub = IAgentHub(MiscPlasma.AGENT_HUB);
  address internal pt;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 37634563);
    listing = new AaveV3Plasma_AssetListingPendlePTsUSDe28JAN2027Plasma_20261022();
    proposal = new AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022();
    pt = proposal.PT_sUSDE_28JAN2027();
  }

  function test_constantsMatchTheListing() public view {
    assertEq(proposal.PT_sUSDE_28JAN2027(), listing.PT_sUSDE_28JAN2027());
    assertEq(proposal.EMODE_LABEL(), listing.EMODE_LABEL());
  }

  /// @dev The eMode only exists once the listing payload has run, so the order of actions matters.
  function test_eModeNotFoundBeforeTheListing() public {
    vm.expectRevert(
      AaveV3Plasma_PTRiskOraclePTsUSDe28JAN2027Plasma_20261022.EModeNotFound.selector
    );
    proposal.eModeId();
  }

  function test_agentsAllowTheNewMarkets() public {
    address[] memory discountBefore = hub.getAllowedMarkets(proposal.DISCOUNT_RATE_AGENT_ID());
    address[] memory eModeBefore = hub.getAllowedMarkets(proposal.EMODE_AGENT_ID());

    _executeBoth();

    assertEq(proposal.eModeId(), EXPECTED_EMODE_ID, 'eMode id');

    address[] memory discountAfter = hub.getAllowedMarkets(proposal.DISCOUNT_RATE_AGENT_ID());
    assertEq(discountAfter.length, discountBefore.length + 1, 'discount markets');
    assertEq(discountAfter[discountAfter.length - 1], pt);
    assertEq(discountAfter[0], AaveV3PlasmaAssets.PT_sUSDE_22OCT2026_UNDERLYING);

    address[] memory eModeAfter = hub.getAllowedMarkets(proposal.EMODE_AGENT_ID());
    assertEq(eModeAfter.length, eModeBefore.length + 1, 'eMode markets');
    assertEq(eModeAfter[eModeAfter.length - 1], address(uint160(EXPECTED_EMODE_ID)));
    assertEq(
      eModeAfter[0],
      address(uint160(AaveV3PlasmaEModes.sUSDe_PT_sUSDE_22OCT2026__USDT0_USDe_GHO))
    );
  }

  function test_agentsStayWired() public {
    _executeBoth();

    assertEq(
      hub.getAgentAddress(proposal.DISCOUNT_RATE_AGENT_ID()),
      MiscPlasma.LLAMARISK_PT_DISCOUNT_RATE_AGENT
    );
    assertEq(hub.getAgentAddress(proposal.EMODE_AGENT_ID()), MiscPlasma.LLAMARISK_PT_EMODE_AGENT);
    assertTrue(hub.isAgentEnabled(proposal.DISCOUNT_RATE_AGENT_ID()));
    assertTrue(hub.isAgentEnabled(proposal.EMODE_AGENT_ID()));
    assertEq(
      hub.getRiskOracle(proposal.DISCOUNT_RATE_AGENT_ID()),
      MiscPlasma.LLAMARISK_RISK_ORACLE
    );
    assertEq(hub.getRiskOracle(proposal.EMODE_AGENT_ID()), MiscPlasma.LLAMARISK_RISK_ORACLE);
    assertTrue(AaveV3Plasma.ACL_MANAGER.isRiskAdmin(MiscPlasma.LLAMARISK_PT_DISCOUNT_RATE_AGENT));
    assertTrue(AaveV3Plasma.ACL_MANAGER.isRiskAdmin(MiscPlasma.LLAMARISK_PT_EMODE_AGENT));
  }

  function test_e2eAgentsInjectForTheNewMarkets() public {
    _executeBoth();

    IPendlePriceCapAdapter adapter = IPendlePriceCapAdapter(
      AaveV3Plasma.ORACLE.getSourceOfAsset(pt)
    );
    uint256 newDiscountRate = adapter.discountRatePerYear() +
      AgentHubConfigs.DISCOUNT_RANGE_ABS /
      2;

    address eModeMarket = address(uint160(EXPECTED_EMODE_ID));
    DataTypes.CollateralConfig memory before = AaveV3Plasma.POOL.getEModeCategoryCollateralConfig(
      EXPECTED_EMODE_ID
    );
    uint256 newLtv = before.ltv - 10;
    uint256 newLt = before.liquidationThreshold - 10;
    uint256 newLb = before.liquidationBonus - 100_00 - 10;

    _publish(AgentHubConfigs.DISCOUNT_UPDATE_TYPE, pt, abi.encodePacked(newDiscountRate));
    _publish(AgentHubConfigs.EMODE_UPDATE_TYPE, eModeMarket, abi.encode(newLtv, newLt, newLb));

    uint256[] memory agentIds = new uint256[](2);
    agentIds[0] = proposal.DISCOUNT_RATE_AGENT_ID();
    agentIds[1] = proposal.EMODE_AGENT_ID();
    (bool shouldExecute, IAgentHub.ActionData[] memory actions) = hub.check(agentIds);
    assertTrue(shouldExecute);
    assertEq(actions.length, 2);
    assertEq(actions[0].markets[0], pt);
    assertEq(actions[1].markets[0], eModeMarket);

    hub.execute(actions);

    assertEq(adapter.discountRatePerYear(), newDiscountRate, 'discount rate');
    DataTypes.CollateralConfig memory afterConfig = AaveV3Plasma
      .POOL
      .getEModeCategoryCollateralConfig(EXPECTED_EMODE_ID);
    assertEq(afterConfig.ltv, newLtv, 'ltv');
    assertEq(afterConfig.liquidationThreshold, newLt, 'lt');
    assertEq(afterConfig.liquidationBonus, newLb + 100_00, 'lb');
  }

  function test_outOfRangeDiscountUpdateIsNotInjected() public {
    _executeBoth();

    IPendlePriceCapAdapter adapter = IPendlePriceCapAdapter(
      AaveV3Plasma.ORACLE.getSourceOfAsset(pt)
    );
    _publish(
      AgentHubConfigs.DISCOUNT_UPDATE_TYPE,
      pt,
      abi.encodePacked(adapter.discountRatePerYear() + AgentHubConfigs.DISCOUNT_RANGE_ABS + 1)
    );

    uint256[] memory agentIds = new uint256[](1);
    agentIds[0] = proposal.DISCOUNT_RATE_AGENT_ID();
    (bool shouldExecute, ) = hub.check(agentIds);
    assertFalse(shouldExecute);
  }

  function _executeBoth() internal {
    GovV3Helpers.executePayload(vm, address(listing));
    GovV3Helpers.executePayload(vm, address(proposal));
  }

  function _publish(string memory updateType, address market, bytes memory newValue) internal {
    vm.prank(MiscPlasma.LLAMARISK_RISK_ORACLE_ROUTER);
    IRiskOracle(MiscPlasma.LLAMARISK_RISK_ORACLE).publishRiskParameterUpdate(
      'e2e-test',
      newValue,
      updateType,
      market,
      bytes('')
    );
  }
}
