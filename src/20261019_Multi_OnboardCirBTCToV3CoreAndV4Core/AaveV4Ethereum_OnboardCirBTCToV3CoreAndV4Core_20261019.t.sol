// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4EthereumHubs, AaveV4Ethereum, AaveV4EthereumIRStrategies, AaveV4EthereumSpokes, AaveV4EthereumAssets} from 'aave-address-book/AaveV4Ethereum.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {ITokenizationSpoke} from 'aave-v4/spoke/interfaces/ITokenizationSpoke.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {AggregatorInterface} from 'aave-v3-origin/contracts/dependencies/chainlink/AggregatorInterface.sol';

import 'forge-std/Test.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {Types} from 'aave-helpers/src/dependencies/v4/Types.sol';
import {AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019} from './AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.sol';

/**
 * @dev Test for AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.t.sol -vv
 */
contract AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019_Test is ProtocolV4TestBaseEthereum {
  AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26282649);
    proposal = new AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019', address(proposal));
  }

  function test_preState() public view {
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    assertFalse(hub.isUnderlyingListed(proposal.cirBTC()), 'cirBTC already listed on Core Hub');

    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    uint256 reserveCount = spoke.getReserveCount();
    assertEq(reserveCount, 14, 'unexpected Main Spoke reserve count');
    for (uint256 i; i < reserveCount; ++i) {
      assertNotEq(
        spoke.getReserve(i).underlying,
        proposal.cirBTC(),
        'cirBTC already a Main Spoke reserve'
      );
    }
  }

  function test_existingBtcAssetsUnchanged_CORE_HUB() public {
    bytes memory wbtcBefore = _coreHubAssetState(AaveV4EthereumAssets.WBTC_UNDERLYING);
    bytes memory cbBtcBefore = _coreHubAssetState(AaveV4EthereumAssets.cbBTC_UNDERLYING);

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(
      _coreHubAssetState(AaveV4EthereumAssets.WBTC_UNDERLYING),
      wbtcBefore,
      'WBTC Core Hub asset changed'
    );
    assertEq(
      _coreHubAssetState(AaveV4EthereumAssets.cbBTC_UNDERLYING),
      cbBtcBefore,
      'cbBTC Core Hub asset changed'
    );
  }

  function test_hubSpokeToAssetsAddition_CORE_HUB_TREASURY_SPOKE_cirBTC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.cirBTC());
    address treasurySpoke = address(AaveV4Ethereum.TREASURY_SPOKE);
    assertTrue(hub.isSpokeListed(assetId, treasurySpoke), 'treasury spoke not listed');
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(assetId, treasurySpoke);
    assertEq(uint256(cfg.addCap), uint256(hub.MAX_ALLOWED_SPOKE_CAP()), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(0), 'drawCap mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubAssetListing_CORE_HUB_cirBTC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    assertTrue(hub.isUnderlyingListed(proposal.cirBTC()), 'asset not listed');
    uint256 assetId = hub.getAssetId(proposal.cirBTC());
    IHub.Asset memory asset = hub.getAsset(assetId);
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    assertEq(asset.underlying, proposal.cirBTC(), 'underlying mismatch');
    assertEq(
      uint256(asset.decimals),
      IERC20Metadata(proposal.cirBTC()).decimals(),
      'decimals mismatch'
    );
    assertEq(cfg.feeReceiver, address(AaveV4Ethereum.TREASURY_SPOKE), 'feeReceiver mismatch');
    assertEq(
      cfg.irStrategy,
      address(AaveV4EthereumIRStrategies.CORE_WBTC_IR_STRATEGY),
      'irStrategy mismatch'
    );
    assertEq(uint256(cfg.liquidityFee), uint256(20_00), 'liquidityFee mismatch');
    IAssetInterestRateStrategy.InterestRateData memory irData = IAssetInterestRateStrategy(
      cfg.irStrategy
    ).getInterestRateData(assetId);
    assertEq(uint256(irData.optimalUsageRatio), uint256(80_00), 'optimalUsageRatio mismatch');
    assertEq(uint256(irData.baseDrawnRate), uint256(25), 'baseDrawnRate mismatch');
    assertEq(
      uint256(irData.rateGrowthBeforeOptimal),
      uint256(4_00),
      'rateGrowthBeforeOptimal mismatch'
    );
    assertEq(
      uint256(irData.rateGrowthAfterOptimal),
      uint256(60_00),
      'rateGrowthAfterOptimal mismatch'
    );
    address tokenizationSpoke = _getTokenizationSpoke(hub, proposal.cirBTC());
    IHub.SpokeConfig memory tokenizationCfg = hub.getSpokeConfig(assetId, tokenizationSpoke);
    assertEq(uint256(tokenizationCfg.addCap), uint256(25), 'tokenization addCap mismatch');
    assertEq(uint256(tokenizationCfg.drawCap), uint256(0), 'tokenization drawCap mismatch');
    assertEq(tokenizationCfg.active, true, 'tokenization active mismatch');
    assertEq(tokenizationCfg.halted, false, 'tokenization halted mismatch');
    assertEq(
      IERC20Metadata(tokenizationSpoke).name(),
      'Wrapped Aave Core cirBTC',
      'tokenization name mismatch'
    );
    assertEq(
      IERC20Metadata(tokenizationSpoke).symbol(),
      'waCorecirBTC',
      'tokenization symbol mismatch'
    );
  }

  function test_tokenizationSpoke_CORE_HUB_cirBTC_proxyAdminOwner() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      _proxyAdminOwner(
        _getTokenizationSpoke(IHub(address(AaveV4EthereumHubs.CORE_HUB)), proposal.cirBTC())
      ),
      MiscEthereum.V4_SECURITY_COUNCIL,
      'proxyAdmin owner mismatch'
    );
  }

  function test_e2e_tokenizationSpoke_CORE_HUB_cirBTC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestTokenizationSpoke(
      ITokenizationSpoke(
        _getTokenizationSpoke(IHub(address(AaveV4EthereumHubs.CORE_HUB)), proposal.cirBTC())
      )
    );
  }

  function test_spokeReserveListing_MAIN_SPOKE_cirBTC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.cirBTC());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(reserve.underlying, proposal.cirBTC(), 'underlying mismatch');
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(proposal.cirBTC()).decimals(),
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
    assertEq(uint256(dyn.collateralFactor), uint256(78_00), 'collateralFactor mismatch');
    assertEq(uint256(dyn.maxLiquidationBonus), uint256(105_55), 'maxLiquidationBonus mismatch');
    assertEq(uint256(dyn.liquidationFee), uint256(10_00), 'liquidationFee mismatch');
  }

  function test_reservePriceSources_MAIN_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 reserveId = spoke.getReserveId(address(hub), hub.getAssetId(proposal.cirBTC()));
    assertEq(
      oracle.getReserveSource(reserveId),
      ChainlinkEthereum.AAVE_SVR_BTC__USD,
      'cirBTC price source mismatch'
    );
    assertEq(
      oracle.getReservePrice(reserveId),
      uint256(AggregatorInterface(ChainlinkEthereum.AAVE_SVR_BTC__USD).latestAnswer()),
      'cirBTC price differs from BTC/USD'
    );
    assertApproxEqRel(
      oracle.getReservePrice(reserveId),
      oracle.getReservePrice(
        spoke.getReserveId(address(hub), hub.getAssetId(AaveV4EthereumAssets.cbBTC_UNDERLYING))
      ),
      0.005e18,
      'cirBTC price diverges from cbBTC'
    );
  }

  function test_hubSpokeToAssetsAddition_CORE_HUB_MAIN_SPOKE_cirBTC() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(proposal.cirBTC());
    assertTrue(
      hub.isSpokeListed(assetId, address(AaveV4EthereumSpokes.MAIN_SPOKE)),
      'spoke not listed'
    );
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(
      assetId,
      address(AaveV4EthereumSpokes.MAIN_SPOKE)
    );
    assertEq(uint256(cfg.addCap), uint256(250), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(25), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  /// @dev the generic e2e suite never picks cirBTC as collateral, so the collateral path is exercised here
  function test_e2e_cirBTCCollateralLiquidation_MAIN_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    _setCapsToMax(spoke);

    Types.ReserveInfo memory cirBTCInfo = _findReserveInfo(spoke, proposal.cirBTC());
    Types.ReserveInfo memory usdcInfo = _findReserveInfo(
      spoke,
      AaveV4EthereumAssets.USDC_UNDERLYING
    );
    address borrower = makeAddr('CIRBTC_BORROWER');

    _supply({
      spoke: spoke,
      reserveInfo: cirBTCInfo,
      user: borrower,
      amount: _getTokenAmountByDollarValue(address(oracle), cirBTCInfo, 100_000)
    });
    vm.prank(borrower);
    spoke.setUsingAsCollateral(cirBTCInfo.reserveId, true, borrower);
    _borrow({
      spoke: spoke,
      reserveInfo: usdcInfo,
      user: borrower,
      amount: _getTokenAmountByDollarValue(address(oracle), usdcInfo, 70_000)
    });
    assertGt(
      spoke.getUserAccountData(borrower).healthFactor,
      HEALTH_FACTOR_LIQUIDATION_THRESHOLD,
      'position unhealthy after borrow'
    );

    // BTC drops 15%: 78% CF on $85k collateral no longer covers $70k debt
    uint256 btcPrice = oracle.getReservePrice(cirBTCInfo.reserveId);
    vm.mockCall(
      ChainlinkEthereum.AAVE_SVR_BTC__USD,
      abi.encodeWithSignature('latestAnswer()'),
      abi.encode(int256((btcPrice * 85) / 100))
    );
    assertEq(
      oracle.getReservePrice(cirBTCInfo.reserveId),
      (btcPrice * 85) / 100,
      'price not mocked'
    );
    uint256 healthFactorBefore = spoke.getUserAccountData(borrower).healthFactor;
    assertLt(healthFactorBefore, HEALTH_FACTOR_LIQUIDATION_THRESHOLD, 'position not liquidatable');

    uint256 collateralBefore = spoke.getUserSuppliedAssets(cirBTCInfo.reserveId, borrower);
    uint256 debtBefore = spoke.getUserTotalDebt(usdcInfo.reserveId, borrower);

    _liquidationCall({
      spoke: spoke,
      collateralInfo: cirBTCInfo,
      debtInfo: usdcInfo,
      liquidator: makeAddr('LIQUIDATOR'),
      borrower: borrower,
      debtToCover: type(uint256).max,
      receiveShares: false
    });

    uint256 seizedValue = ((collateralBefore -
      spoke.getUserSuppliedAssets(cirBTCInfo.reserveId, borrower)) *
      oracle.getReservePrice(cirBTCInfo.reserveId)) / 10 ** cirBTCInfo.decimals;
    uint256 repaidValue = ((debtBefore - spoke.getUserTotalDebt(usdcInfo.reserveId, borrower)) *
      oracle.getReservePrice(usdcInfo.reserveId)) / 10 ** usdcInfo.decimals;
    assertGt(seizedValue, repaidValue, 'no liquidation bonus paid');
    // seized collateral includes the liquidation fee, so it is capped by the 5.55% max bonus (1bp rounding tolerance)
    assertLe(seizedValue * 100_00, repaidValue * 105_56, 'bonus above 5.55% max');
    assertGt(
      spoke.getUserAccountData(borrower).healthFactor,
      healthFactorBefore,
      'health factor did not improve'
    );
  }

  function test_borrowAtCollateralFactorBoundary_MAIN_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    address oracle = spoke.ORACLE();
    _setCapsToMax(spoke);

    Types.ReserveInfo memory cirBTCInfo = _findReserveInfo(spoke, proposal.cirBTC());
    Types.ReserveInfo memory usdcInfo = _findReserveInfo(
      spoke,
      AaveV4EthereumAssets.USDC_UNDERLYING
    );
    address borrower = makeAddr('CIRBTC_BOUNDARY_BORROWER');

    _supply({
      spoke: spoke,
      reserveInfo: cirBTCInfo,
      user: borrower,
      amount: _getTokenAmountByDollarValue(oracle, cirBTCInfo, 100_000)
    });
    vm.prank(borrower);
    spoke.setUsingAsCollateral(cirBTCInfo.reserveId, true, borrower);

    uint256 aboveCollateralFactor = _getTokenAmountByDollarValue(oracle, usdcInfo, 78_500);
    vm.prank(borrower);
    vm.expectRevert(ISpoke.HealthFactorBelowThreshold.selector);
    spoke.borrow({
      reserveId: usdcInfo.reserveId,
      amount: aboveCollateralFactor,
      onBehalfOf: borrower
    });

    _borrow({
      spoke: spoke,
      reserveInfo: usdcInfo,
      user: borrower,
      amount: _getTokenAmountByDollarValue(oracle, usdcInfo, 77_500)
    });
    uint256 healthFactor = spoke.getUserAccountData(borrower).healthFactor;
    assertGt(healthFactor, HEALTH_FACTOR_LIQUIDATION_THRESHOLD, 'unhealthy below 78% CF');
    assertLt(healthFactor, 1.01e18, 'effective CF above 78%');
  }

  function test_e2e_positionManagers_cirBTC_MAIN_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.MAIN_SPOKE));
    _setCapsToMax(spoke);

    Types.ReserveInfo memory cirBTCInfo = _findReserveInfo(spoke, proposal.cirBTC());
    Types.ReserveInfo memory usdcInfo = _findReserveInfo(
      spoke,
      AaveV4EthereumAssets.USDC_UNDERLYING
    );
    Types.ReserveInfo memory wethInfo = _findReserveInfo(
      spoke,
      AaveV4EthereumAssets.WETH_UNDERLYING
    );

    _testGiverPositionManager(spoke, usdcInfo, cirBTCInfo);
    _testGiverPositionManager(spoke, cirBTCInfo, wethInfo);
    _testTakerPositionManager(spoke, usdcInfo, cirBTCInfo);
    _testTakerPositionManager(spoke, cirBTCInfo, wethInfo);
    _testConfigPositionManager(spoke, cirBTCInfo);

    uint256 snapshot = vm.snapshotState();
    _testSignatureGateway({
      gateway: _getPositionManagers().signatureGateway,
      spoke: spoke,
      reserveInfo: usdcInfo,
      collateralInfo: cirBTCInfo
    });
    vm.revertToState(snapshot);
    _testSignatureGateway({
      gateway: _getPositionManagers().signatureGateway,
      spoke: spoke,
      reserveInfo: cirBTCInfo,
      collateralInfo: wethInfo
    });
  }

  function test_hubAssetListingsInput() public view {
    IConfigEngine.AssetListing[] memory items = proposal.hubAssetListings();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].hub, address(AaveV4EthereumHubs.CORE_HUB), 'hub');
    assertEq(items[0].underlying, proposal.cirBTC(), 'underlying');
    assertEq(items[0].feeReceiver, address(AaveV4Ethereum.TREASURY_SPOKE), 'feeReceiver');
    assertEq(items[0].liquidityFee, 20_00, 'liquidityFee');
    assertEq(
      items[0].irStrategy,
      address(AaveV4EthereumIRStrategies.CORE_WBTC_IR_STRATEGY),
      'irStrategy'
    );
    assertEq(uint256(items[0].irData.optimalUsageRatio), 80_00, 'optimalUsageRatio');
    assertEq(uint256(items[0].irData.baseDrawnRate), 25, 'baseDrawnRate');
    assertEq(uint256(items[0].irData.rateGrowthBeforeOptimal), 4_00, 'rateGrowthBeforeOptimal');
    assertEq(uint256(items[0].irData.rateGrowthAfterOptimal), 60_00, 'rateGrowthAfterOptimal');
    assertEq(items[0].tokenization.addCap, 25, 'tokenization addCap');
    assertEq(
      items[0].tokenization.proxyAdminOwner,
      MiscEthereum.V4_SECURITY_COUNCIL,
      'tokenization proxyAdminOwner'
    );
    assertEq(items[0].tokenization.name, 'Wrapped Aave Core cirBTC', 'tokenization name');
    assertEq(items[0].tokenization.symbol, 'waCorecirBTC', 'tokenization symbol');
  }

  function test_spokeReserveListingsInput() public view {
    IConfigEngine.ReserveListing[] memory items = proposal.spokeReserveListings();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].spoke, address(AaveV4EthereumSpokes.MAIN_SPOKE), 'spoke');
    assertEq(items[0].hub, address(AaveV4EthereumHubs.CORE_HUB), 'hub');
    assertEq(items[0].underlying, proposal.cirBTC(), 'underlying');
    assertEq(items[0].priceSource, proposal.MAIN_SPOKE_cirBTC_PRICE_FEED(), 'priceSource');
    assertEq(uint256(items[0].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[0].config.paused, false, 'paused');
    assertEq(items[0].config.frozen, false, 'frozen');
    assertEq(items[0].config.borrowable, true, 'borrowable');
    assertEq(items[0].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[0].dynamicConfig.collateralFactor), 78_00, 'collateralFactor');
    assertEq(uint256(items[0].dynamicConfig.maxLiquidationBonus), 105_55, 'maxLiquidationBonus');
    assertEq(uint256(items[0].dynamicConfig.liquidationFee), 10_00, 'liquidationFee');
  }

  function test_hubSpokeToAssetsAdditionsInput() public view {
    IConfigEngine.SpokeToAssetsAddition[] memory items = proposal.hubSpokeToAssetsAdditions();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].spoke, address(AaveV4EthereumSpokes.MAIN_SPOKE), 'spoke');
    assertEq(items[0].assets.length, 1, 'assets length');
    assertEq(items[0].assets[0].underlying, proposal.cirBTC(), 'underlying');
    assertEq(uint256(items[0].assets[0].config.addCap), 250, 'addCap');
    assertEq(uint256(items[0].assets[0].config.drawCap), 25, 'drawCap');
    assertEq(uint256(items[0].assets[0].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[0].assets[0].config.active, true, 'active');
    assertEq(items[0].assets[0].config.halted, false, 'halted');
  }

  function _findReserveInfo(
    ISpoke spoke,
    address underlying
  ) internal view returns (Types.ReserveInfo memory) {
    Types.ReserveInfo[] memory reserves = _getReserveInfo(spoke);
    for (uint256 i; i < reserves.length; ++i) {
      if (reserves[i].underlying == underlying) return reserves[i];
    }
    revert('reserve not found');
  }

  function _coreHubAssetState(address underlying) internal view returns (bytes memory) {
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(underlying);
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    return
      abi.encode(
        cfg,
        IAssetInterestRateStrategy(cfg.irStrategy).getInterestRateData(assetId),
        hub.getSpokeConfig(assetId, address(AaveV4EthereumSpokes.MAIN_SPOKE))
      );
  }
}
