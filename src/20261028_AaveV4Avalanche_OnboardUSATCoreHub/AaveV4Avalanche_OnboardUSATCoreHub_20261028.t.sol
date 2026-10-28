// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4AvalancheHubs, AaveV4Avalanche, AaveV4AvalancheIRStrategies, AaveV4AvalancheSpokes} from 'aave-address-book/AaveV4Avalanche.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {ITokenizationSpoke} from 'aave-v4/spoke/interfaces/ITokenizationSpoke.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';

import 'forge-std/Test.sol';
import {ProtocolV4TestBaseAvalanche} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseAvalanche.sol';
import {AaveV4Avalanche_OnboardUSATCoreHub_20261028} from './AaveV4Avalanche_OnboardUSATCoreHub_20261028.sol';

/**
 * @dev Test for AaveV4Avalanche_OnboardUSATCoreHub_20261028
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261028_AaveV4Avalanche_OnboardUSATCoreHub/AaveV4Avalanche_OnboardUSATCoreHub_20261028.t.sol -vv
 */
contract AaveV4Avalanche_OnboardUSATCoreHub_20261028_Test is ProtocolV4TestBaseAvalanche {
  AaveV4Avalanche_OnboardUSATCoreHub_20261028 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 98782788);
    proposal = new AaveV4Avalanche_OnboardUSATCoreHub_20261028();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Avalanche_OnboardUSATCoreHub_20261028', address(proposal));
  }

  function test_preState() public view {
    assertFalse(
      IHub(address(AaveV4AvalancheHubs.CORE_HUB)).isUnderlyingListed(proposal.USAT()),
      'asset already listed'
    );
    ISpoke[2] memory spokes = [
      ISpoke(address(AaveV4AvalancheSpokes.MAIN_SPOKE)),
      ISpoke(address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE))
    ];
    for (uint256 i; i < spokes.length; ++i) {
      for (uint256 reserveId; reserveId < spokes[i].getReserveCount(); ++reserveId) {
        assertNotEq(
          spokes[i].getReserve(reserveId).underlying,
          proposal.USAT(),
          'reserve already listed'
        );
      }
    }
  }

  function test_hubAssetListing_CORE_HUB_USAT() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4AvalancheHubs.CORE_HUB));
    assertTrue(hub.isUnderlyingListed(proposal.USAT()), 'asset not listed');
    uint256 assetId = hub.getAssetId(proposal.USAT());
    IHub.Asset memory asset = hub.getAsset(assetId);
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    assertEq(asset.underlying, proposal.USAT(), 'underlying mismatch');
    assertEq(
      uint256(asset.decimals),
      IERC20Metadata(proposal.USAT()).decimals(),
      'decimals mismatch'
    );
    assertEq(cfg.feeReceiver, address(AaveV4Avalanche.TREASURY_SPOKE), 'feeReceiver mismatch');
    assertEq(
      cfg.irStrategy,
      address(AaveV4AvalancheIRStrategies.CORE_USDt_IR_STRATEGY),
      'irStrategy mismatch'
    );
    assertEq(uint256(cfg.liquidityFee), uint256(10_00), 'liquidityFee mismatch');
    IAssetInterestRateStrategy.InterestRateData memory irData = IAssetInterestRateStrategy(
      cfg.irStrategy
    ).getInterestRateData(assetId);
    assertEq(uint256(irData.optimalUsageRatio), uint256(94_00), 'optimalUsageRatio mismatch');
    assertEq(uint256(irData.baseDrawnRate), uint256(0), 'baseDrawnRate mismatch');
    assertEq(
      uint256(irData.rateGrowthBeforeOptimal),
      uint256(4_90),
      'rateGrowthBeforeOptimal mismatch'
    );
    assertEq(
      uint256(irData.rateGrowthAfterOptimal),
      uint256(20_00),
      'rateGrowthAfterOptimal mismatch'
    );
    address tokenizationSpoke = _getTokenizationSpoke(
      IHub(address(AaveV4AvalancheHubs.CORE_HUB)),
      proposal.USAT()
    );
    IHub.SpokeConfig memory tokenizationCfg = hub.getSpokeConfig(assetId, tokenizationSpoke);
    assertEq(uint256(tokenizationCfg.addCap), uint256(1_500_000), 'tokenization addCap mismatch');
    assertEq(
      IERC20Metadata(tokenizationSpoke).name(),
      'Wrapped Aave Core USAT',
      'tokenization name mismatch'
    );
    assertEq(
      IERC20Metadata(tokenizationSpoke).symbol(),
      'waCoreUSAT',
      'tokenization symbol mismatch'
    );
  }

  function test_tokenizationSpoke_CORE_HUB_USAT_proxyAdminOwner() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      _proxyAdminOwner(
        _getTokenizationSpoke(IHub(address(AaveV4AvalancheHubs.CORE_HUB)), proposal.USAT())
      ),
      address(MiscAvalanche.V4_SECURITY_COUNCIL),
      'proxyAdmin owner mismatch'
    );
    assertEq(
      _proxyAdminOwner(
        _getTokenizationSpoke(IHub(address(AaveV4AvalancheHubs.CORE_HUB)), proposal.USAT())
      ),
      _proxyAdminOwner(address(AaveV4AvalancheSpokes.MAIN_SPOKE)),
      'main spoke proxyAdmin owner mismatch'
    );
  }

  function test_e2e_tokenizationSpoke_CORE_HUB_USAT() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestTokenizationSpoke(
      ITokenizationSpoke(
        _getTokenizationSpoke(IHub(address(AaveV4AvalancheHubs.CORE_HUB)), proposal.USAT())
      )
    );
  }

  function test_spokeReserveListing_MAIN_SPOKE_USAT() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4AvalancheSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4AvalancheHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.USAT());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(reserve.underlying, proposal.USAT(), 'underlying mismatch');
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(proposal.USAT()).decimals(),
      'decimals mismatch'
    );
    assertEq(uint256(cfg.collateralRisk), uint256(0), 'collateralRisk mismatch');
    assertEq(cfg.paused, false, 'paused mismatch');
    assertEq(cfg.frozen, false, 'frozen mismatch');
    assertEq(cfg.borrowable, true, 'borrowable mismatch');
    assertEq(cfg.receiveSharesEnabled, true, 'receiveSharesEnabled mismatch');
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(0), 'collateralFactor mismatch');
    assertEq(uint256(dyn.maxLiquidationBonus), uint256(100_00), 'maxLiquidationBonus mismatch');
    assertEq(uint256(dyn.liquidationFee), uint256(0), 'liquidationFee mismatch');
  }

  function test_spokeReserveListing_ETHENA_ECOSYSTEM_SPOKE_USAT() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE));
    IHub hub = IHub(address(AaveV4AvalancheHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.USAT());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(reserve.underlying, proposal.USAT(), 'underlying mismatch');
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(proposal.USAT()).decimals(),
      'decimals mismatch'
    );
    assertEq(uint256(cfg.collateralRisk), uint256(0), 'collateralRisk mismatch');
    assertEq(cfg.paused, false, 'paused mismatch');
    assertEq(cfg.frozen, false, 'frozen mismatch');
    assertEq(cfg.borrowable, true, 'borrowable mismatch');
    assertEq(cfg.receiveSharesEnabled, true, 'receiveSharesEnabled mismatch');
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(0), 'collateralFactor mismatch');
    assertEq(uint256(dyn.maxLiquidationBonus), uint256(100_00), 'maxLiquidationBonus mismatch');
    assertEq(uint256(dyn.liquidationFee), uint256(0), 'liquidationFee mismatch');
  }

  function test_reservePriceSources_MAIN_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4AvalancheSpokes.MAIN_SPOKE));
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4AvalancheHubs.CORE_HUB),
          IHub(address(AaveV4AvalancheHubs.CORE_HUB)).getAssetId(proposal.USAT())
        )
      ),
      proposal.MAIN_SPOKE_USAT_PRICE_FEED(),
      'USAT price source mismatch'
    );
  }

  function test_reservePriceSources_ETHENA_ECOSYSTEM_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE));
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4AvalancheHubs.CORE_HUB),
          IHub(address(AaveV4AvalancheHubs.CORE_HUB)).getAssetId(proposal.USAT())
        )
      ),
      proposal.ETHENA_ECOSYSTEM_SPOKE_USAT_PRICE_FEED(),
      'USAT price source mismatch'
    );
  }

  function test_reservePrices_MAIN_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4AvalancheSpokes.MAIN_SPOKE));
    uint256[] memory reserveIds = new uint256[](1);
    reserveIds[0] = spoke.getReserveId(
      address(AaveV4AvalancheHubs.CORE_HUB),
      IHub(address(AaveV4AvalancheHubs.CORE_HUB)).getAssetId(proposal.USAT())
    );
    uint256[] memory prices = IAaveOracle(spoke.ORACLE()).getReservesPrices(reserveIds);
    assertApproxEqAbs(prices[0], 1e8, 0.02e8, 'USAT price mismatch');
  }

  function test_reservePrices_ETHENA_ECOSYSTEM_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE));
    uint256[] memory reserveIds = new uint256[](1);
    reserveIds[0] = spoke.getReserveId(
      address(AaveV4AvalancheHubs.CORE_HUB),
      IHub(address(AaveV4AvalancheHubs.CORE_HUB)).getAssetId(proposal.USAT())
    );
    uint256[] memory prices = IAaveOracle(spoke.ORACLE()).getReservesPrices(reserveIds);
    assertApproxEqAbs(prices[0], 1e8, 0.02e8, 'USAT price mismatch');
  }

  function test_hubSpokeToAssetsAddition_CORE_HUB_MAIN_SPOKE_USAT() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4AvalancheHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.USAT());
    assertTrue(
      hub.isSpokeListed(assetId, address(AaveV4AvalancheSpokes.MAIN_SPOKE)),
      'spoke not listed'
    );
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(
      assetId,
      address(AaveV4AvalancheSpokes.MAIN_SPOKE)
    );
    assertEq(uint256(cfg.addCap), uint256(60_000_000), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(5_000_000), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(1_100_00), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubSpokeToAssetsAddition_CORE_HUB_ETHENA_ECOSYSTEM_SPOKE_USAT() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4AvalancheHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.USAT());
    assertTrue(
      hub.isSpokeListed(assetId, address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE)),
      'spoke not listed'
    );
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(
      assetId,
      address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE)
    );
    assertEq(uint256(cfg.addCap), uint256(0), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(50_000_000), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(1_100_00), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubAssetListingsInput() public view {
    IConfigEngine.AssetListing[] memory items = proposal.hubAssetListings();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].hub, address(AaveV4AvalancheHubs.CORE_HUB), 'hub');
    assertEq(items[0].underlying, proposal.USAT(), 'underlying');
    assertEq(items[0].feeReceiver, address(AaveV4Avalanche.TREASURY_SPOKE), 'feeReceiver');
    assertEq(items[0].liquidityFee, 10_00, 'liquidityFee');
    assertEq(
      items[0].irStrategy,
      address(AaveV4AvalancheIRStrategies.CORE_USDt_IR_STRATEGY),
      'irStrategy'
    );
    assertEq(uint256(items[0].irData.optimalUsageRatio), 94_00, 'optimalUsageRatio');
    assertEq(uint256(items[0].irData.baseDrawnRate), 0, 'baseDrawnRate');
    assertEq(uint256(items[0].irData.rateGrowthBeforeOptimal), 4_90, 'rateGrowthBeforeOptimal');
    assertEq(uint256(items[0].irData.rateGrowthAfterOptimal), 20_00, 'rateGrowthAfterOptimal');
    assertEq(items[0].tokenization.addCap, 1_500_000, 'tokenization addCap');
    assertEq(
      items[0].tokenization.proxyAdminOwner,
      address(MiscAvalanche.V4_SECURITY_COUNCIL),
      'tokenization proxyAdminOwner'
    );
    assertEq(items[0].tokenization.name, 'Wrapped Aave Core USAT', 'tokenization name');
    assertEq(items[0].tokenization.symbol, 'waCoreUSAT', 'tokenization symbol');
  }

  function test_spokeReserveListingsInput() public view {
    IConfigEngine.ReserveListing[] memory items = proposal.spokeReserveListings();
    assertEq(items.length, 2, 'length');
    assertEq(items[0].spoke, address(AaveV4AvalancheSpokes.MAIN_SPOKE), 'spoke');
    assertEq(items[0].hub, address(AaveV4AvalancheHubs.CORE_HUB), 'hub');
    assertEq(items[0].underlying, proposal.USAT(), 'underlying');
    assertEq(items[0].priceSource, proposal.MAIN_SPOKE_USAT_PRICE_FEED(), 'priceSource');
    assertEq(uint256(items[0].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[0].config.paused, false, 'paused');
    assertEq(items[0].config.frozen, false, 'frozen');
    assertEq(items[0].config.borrowable, true, 'borrowable');
    assertEq(items[0].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[0].dynamicConfig.collateralFactor), 0, 'collateralFactor');
    assertEq(uint256(items[0].dynamicConfig.maxLiquidationBonus), 100_00, 'maxLiquidationBonus');
    assertEq(uint256(items[0].dynamicConfig.liquidationFee), 0, 'liquidationFee');
    assertEq(items[1].spoke, address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE), 'spoke');
    assertEq(items[1].hub, address(AaveV4AvalancheHubs.CORE_HUB), 'hub');
    assertEq(items[1].underlying, proposal.USAT(), 'underlying');
    assertEq(
      items[1].priceSource,
      proposal.ETHENA_ECOSYSTEM_SPOKE_USAT_PRICE_FEED(),
      'priceSource'
    );
    assertEq(uint256(items[1].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[1].config.paused, false, 'paused');
    assertEq(items[1].config.frozen, false, 'frozen');
    assertEq(items[1].config.borrowable, true, 'borrowable');
    assertEq(items[1].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[1].dynamicConfig.collateralFactor), 0, 'collateralFactor');
    assertEq(uint256(items[1].dynamicConfig.maxLiquidationBonus), 100_00, 'maxLiquidationBonus');
    assertEq(uint256(items[1].dynamicConfig.liquidationFee), 0, 'liquidationFee');
  }

  function test_hubSpokeToAssetsAdditionsInput() public view {
    IConfigEngine.SpokeToAssetsAddition[] memory items = proposal.hubSpokeToAssetsAdditions();
    assertEq(items.length, 2, 'length');
    assertEq(items[0].spoke, address(AaveV4AvalancheSpokes.MAIN_SPOKE), 'spoke');
    assertEq(items[0].assets.length, 1, 'assets length');
    assertEq(items[0].assets[0].underlying, proposal.USAT(), 'underlying');
    assertEq(uint256(items[0].assets[0].config.addCap), 60_000_000, 'addCap');
    assertEq(uint256(items[0].assets[0].config.drawCap), 5_000_000, 'drawCap');
    assertEq(
      uint256(items[0].assets[0].config.riskPremiumThreshold),
      1_100_00,
      'riskPremiumThreshold'
    );
    assertEq(items[0].assets[0].config.active, true, 'active');
    assertEq(items[0].assets[0].config.halted, false, 'halted');
    assertEq(items[1].spoke, address(AaveV4AvalancheSpokes.ETHENA_ECOSYSTEM_SPOKE), 'spoke');
    assertEq(items[1].assets.length, 1, 'assets length');
    assertEq(items[1].assets[0].underlying, proposal.USAT(), 'underlying');
    assertEq(uint256(items[1].assets[0].config.addCap), 0, 'addCap');
    assertEq(uint256(items[1].assets[0].config.drawCap), 50_000_000, 'drawCap');
    assertEq(
      uint256(items[1].assets[0].config.riskPremiumThreshold),
      1_100_00,
      'riskPremiumThreshold'
    );
    assertEq(items[1].assets[0].config.active, true, 'active');
    assertEq(items[1].assets[0].config.halted, false, 'halted');
  }
}
