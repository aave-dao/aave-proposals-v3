// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4EthereumSpokes, AaveV4EthereumHubs, AaveV4Ethereum, AaveV4EthereumIRStrategies, AaveV4EthereumAssets, AaveV4EthereumSpokePriceFeeds, AaveV4EthereumPositionManagers} from 'aave-address-book/AaveV4Ethereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {ITokenizationSpoke} from 'aave-v4/spoke/interfaces/ITokenizationSpoke.sol';
import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';

import 'forge-std/Test.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824} from './AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824.sol';

interface ITimelockController {
  function getMinDelay() external view returns (uint256);

  function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

  function PROPOSER_ROLE() external view returns (bytes32);

  function EXECUTOR_ROLE() external view returns (bytes32);

  function CANCELLER_ROLE() external view returns (bytes32);

  function hasRole(bytes32 role, address account) external view returns (bool);
}

/**
 * @dev Test for AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260824_AaveV4Ethereum_OnboardPAXGGlobalDollarHub/AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824.t.sol -vv
 */
contract AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824_Test is ProtocolV4TestBaseEthereum {
  bytes32 internal constant ZEPPELINOS_ADMIN_SLOT = keccak256('org.zeppelinos.proxy.admin');
  address internal constant PAXG_TIMELOCK = 0x4a515afE11581FD87BA90D6459DC93DB6591F5e3;
  address internal constant PAXG_TIMELOCK_CONTROLLER = 0x3Af3e85f4f97De7AD0f000B724Fb77fE5ffc024B;
  address internal constant SECURITY_COUNCIL = 0x187AAE17d4931310B3fc75743e7F16Bdc9eD77e9;

  AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25883490);
    proposal = new AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    ISpoke[] memory addressBookSpokes = _getSpokes();
    ISpoke[] memory spokes = new ISpoke[](addressBookSpokes.length + 1);
    for (uint256 i; i < addressBookSpokes.length; ++i) {
      spokes[i] = addressBookSpokes[i];
    }
    spokes[addressBookSpokes.length] = ISpoke(proposal.PAXG_GOLD_SPOKE());
    defaultTest(
      'AaveV4Ethereum_OnboardPAXGGlobalDollarHub_20260824',
      spokes,
      _getTokenizationSpokes(),
      address(proposal)
    );
  }

  function test_preState() public view {
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 usdgAssetId = hub.getAssetId(address(AaveV4EthereumAssets.USDG_UNDERLYING));
    ISpoke paxgGoldSpoke = ISpoke(proposal.PAXG_GOLD_SPOKE());

    assertFalse(hub.isUnderlyingListed(proposal.PAXG()), 'PAXG already listed');
    assertEq(paxgGoldSpoke.getReserveCount(), 0, 'PAXG Gold Spoke already configured');
    assertFalse(
      hub.isSpokeListed(usdgAssetId, proposal.PAXG_GOLD_SPOKE()),
      'Global Dollar USDG already registered on PAXG Gold Spoke'
    );
    assertFalse(
      hub.isSpokeListed(usdgAssetId, address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE)),
      'Global Dollar USDG already listed on Pendle Spoke'
    );

    ISpoke.LiquidationConfig memory cfg = paxgGoldSpoke.getLiquidationConfig();
    assertEq(uint256(cfg.targetHealthFactor), uint256(1e18), 'targetHealthFactor pre-state');
    assertEq(uint256(cfg.healthFactorForMaxBonus), uint256(0), 'hfForMaxBonus pre-state');
    assertEq(uint256(cfg.liquidationBonusFactor), uint256(0), 'bonusFactor pre-state');

    assertFalse(
      paxgGoldSpoke.isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER)
      ),
      'Giver Position Manager already active'
    );
    assertFalse(
      paxgGoldSpoke.isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER)
      ),
      'Taker Position Manager already active'
    );
    assertFalse(
      paxgGoldSpoke.isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER)
      ),
      'Config Position Manager already active'
    );
    assertFalse(
      paxgGoldSpoke.isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY)
      ),
      'Signature Gateway already active'
    );
  }

  function test_paxgProxyAdminTimelock() public view {
    address proxyAdmin = address(uint160(uint256(vm.load(proposal.PAXG(), ZEPPELINOS_ADMIN_SLOT))));
    assertEq(proxyAdmin, PAXG_TIMELOCK, 'PAXG proxy admin is not the timelock');

    ITimelockController timelock = ITimelockController(PAXG_TIMELOCK);
    assertEq(timelock.getMinDelay(), 1 days, 'unexpected PAXG timelock delay');
    assertTrue(
      timelock.hasRole(timelock.PROPOSER_ROLE(), PAXG_TIMELOCK_CONTROLLER),
      'unexpected PAXG timelock proposer'
    );
    assertTrue(
      timelock.hasRole(timelock.EXECUTOR_ROLE(), PAXG_TIMELOCK_CONTROLLER),
      'unexpected PAXG timelock executor'
    );
    assertTrue(
      timelock.hasRole(timelock.CANCELLER_ROLE(), PAXG_TIMELOCK_CONTROLLER),
      'unexpected PAXG timelock canceller'
    );
    assertTrue(
      timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), PAXG_TIMELOCK),
      'timelock is not self-administered'
    );
  }

  function test_paxgGoldSpokeProxyAdminOwner() public view {
    assertEq(
      _proxyAdminOwner(proposal.PAXG_GOLD_SPOKE()),
      SECURITY_COUNCIL,
      'PAXG Gold Spoke proxy admin owner mismatch'
    );
  }

  function test_existingGoldReserveConfigUnchanged() public {
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.GOLD_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.XAUt_UNDERLYING));
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.DynamicReserveConfig memory before = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );

    GovV3Helpers.executePayload(vm, address(proposal));

    ISpoke.DynamicReserveConfig memory afterConfig = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );
    assertEq(afterConfig.collateralFactor, before.collateralFactor, 'collateralFactor changed');
    assertEq(
      afterConfig.maxLiquidationBonus,
      before.maxLiquidationBonus,
      'maxLiquidationBonus changed'
    );
    assertEq(afterConfig.liquidationFee, before.liquidationFee, 'liquidationFee changed');
  }

  function test_rolesWired_PAXG_GOLD_SPOKE() public {
    IConfigEngine.TargetFunctionRoleUpdate[] memory items = proposal
      .accessManagerTargetFunctionRoleUpdates();
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 matched;
    for (uint256 i; i < items.length; ++i) {
      if (items[i].target != proposal.PAXG_GOLD_SPOKE()) continue;
      _assertRolesWired(items[i], address(AaveV4EthereumSpokes.MAIN_SPOKE));
      ++matched;
    }
    assertGt(matched, 0, 'no wiring for target');
  }

  function test_spokeDeployment_PAXG_GOLD_SPOKE() public view {
    _assertSpokeDeployment(ISpoke(proposal.PAXG_GOLD_SPOKE()));
  }

  function test_hubAssetListing_GLOBAL_DOLLAR_HUB_PAXG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    assertTrue(hub.isUnderlyingListed(proposal.PAXG()), 'asset not listed');
    uint256 assetId = hub.getAssetId(proposal.PAXG());
    IHub.Asset memory asset = hub.getAsset(assetId);
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    assertEq(asset.underlying, proposal.PAXG(), 'underlying mismatch');
    assertEq(
      uint256(asset.decimals),
      IERC20Metadata(proposal.PAXG()).decimals(),
      'decimals mismatch'
    );
    assertEq(cfg.feeReceiver, address(AaveV4Ethereum.TREASURY_SPOKE), 'feeReceiver mismatch');
    assertEq(
      cfg.irStrategy,
      address(AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_USDG_IR_STRATEGY),
      'irStrategy mismatch'
    );
    assertEq(uint256(cfg.liquidityFee), uint256(0), 'liquidityFee mismatch');
    IAssetInterestRateStrategy.InterestRateData memory irData = IAssetInterestRateStrategy(
      cfg.irStrategy
    ).getInterestRateData(assetId);
    assertEq(
      uint256(irData.optimalUsageRatio),
      uint256(V4EngineDefaults.MAX_OPTIMAL_USAGE_RATIO),
      'optimalUsageRatio mismatch'
    );
    assertEq(uint256(irData.baseDrawnRate), uint256(0), 'baseDrawnRate mismatch');
    assertEq(
      uint256(irData.rateGrowthBeforeOptimal),
      uint256(0),
      'rateGrowthBeforeOptimal mismatch'
    );
    assertEq(uint256(irData.rateGrowthAfterOptimal), uint256(0), 'rateGrowthAfterOptimal mismatch');
    address tokenizationSpoke = _getTokenizationSpoke(
      IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)),
      proposal.PAXG()
    );
    IHub.SpokeConfig memory tokenizationCfg = hub.getSpokeConfig(assetId, tokenizationSpoke);
    assertEq(uint256(tokenizationCfg.addCap), uint256(0), 'tokenization addCap mismatch');
    assertEq(
      IERC20Metadata(tokenizationSpoke).name(),
      'Wrapped Aave Global Dollar PAXG',
      'tokenization name mismatch'
    );
    assertEq(
      IERC20Metadata(tokenizationSpoke).symbol(),
      'waGlobalDollarPAXG',
      'tokenization symbol mismatch'
    );
  }

  function test_tokenizationSpoke_GLOBAL_DOLLAR_HUB_PAXG_proxyAdminOwner() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      _proxyAdminOwner(
        _getTokenizationSpoke(IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)), proposal.PAXG())
      ),
      SECURITY_COUNCIL,
      'proxyAdmin owner mismatch'
    );
  }

  function test_e2e_tokenizationSpoke_GLOBAL_DOLLAR_HUB_PAXG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestTokenizationSpoke(
      ITokenizationSpoke(
        _getTokenizationSpoke(IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)), proposal.PAXG())
      )
    );
  }

  function test_spokeReserveListing_PAXG_GOLD_SPOKE_PAXG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_GOLD_SPOKE());
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(proposal.PAXG());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(reserve.underlying, proposal.PAXG(), 'underlying mismatch');
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(proposal.PAXG()).decimals(),
      'decimals mismatch'
    );
    assertEq(uint256(cfg.collateralRisk), uint256(0), 'collateralRisk mismatch');
    assertEq(cfg.paused, false, 'paused mismatch');
    assertEq(cfg.frozen, false, 'frozen mismatch');
    assertEq(cfg.borrowable, false, 'borrowable mismatch');
    assertEq(cfg.receiveSharesEnabled, true, 'receiveSharesEnabled mismatch');
    ISpoke.DynamicReserveConfig memory dyn = spoke.getDynamicReserveConfig(
      reserveId,
      reserve.dynamicConfigKey
    );
    assertEq(uint256(dyn.collateralFactor), uint256(75_00), 'collateralFactor mismatch');
    assertEq(uint256(dyn.maxLiquidationBonus), uint256(106_50), 'maxLiquidationBonus mismatch');
    assertEq(uint256(dyn.liquidationFee), uint256(10_00), 'liquidationFee mismatch');
  }

  function test_spokeReserveListing_PAXG_GOLD_SPOKE_USDG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_GOLD_SPOKE());
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.USDG_UNDERLYING));
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(
      reserve.underlying,
      address(AaveV4EthereumAssets.USDG_UNDERLYING),
      'underlying mismatch'
    );
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(address(AaveV4EthereumAssets.USDG_UNDERLYING)).decimals(),
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

  function test_spokeReserveListing_USDG_PENDLE_SPOKE_USDG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.USDG_UNDERLYING));
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(
      reserve.underlying,
      address(AaveV4EthereumAssets.USDG_UNDERLYING),
      'underlying mismatch'
    );
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(address(AaveV4EthereumAssets.USDG_UNDERLYING)).decimals(),
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

  function test_reservePriceSources_PAXG_GOLD_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_GOLD_SPOKE());
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
          IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)).getAssetId(proposal.PAXG())
        )
      ),
      proposal.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED(),
      'PAXG price source mismatch'
    );
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
          IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)).getAssetId(
            address(AaveV4EthereumAssets.USDG_UNDERLYING)
          )
        )
      ),
      AaveV4EthereumSpokePriceFeeds.GOLD_SPOKE_USDG_PRICE_FEED,
      'USDG price source mismatch'
    );
  }

  function test_reservePriceSources_USDG_PENDLE_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE));
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
          IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)).getAssetId(
            address(AaveV4EthereumAssets.USDG_UNDERLYING)
          )
        )
      ),
      AaveV4EthereumSpokePriceFeeds.USDG_PENDLE_SPOKE_USDG_PRICE_FEED,
      'USDG price source mismatch'
    );
  }

  function test_e2e_PAXG_GOLD_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestSpoke(ISpoke(proposal.PAXG_GOLD_SPOKE()));
  }

  function test_spokeLiquidationConfigUpdate_PAXG_GOLD_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.LiquidationConfig memory cfg = ISpoke(proposal.PAXG_GOLD_SPOKE()).getLiquidationConfig();
    assertEq(uint256(cfg.targetHealthFactor), uint256(1.2e18), 'targetHealthFactor mismatch');
    assertEq(
      uint256(cfg.healthFactorForMaxBonus),
      uint256(0.9e18),
      'healthFactorForMaxBonus mismatch'
    );
    assertEq(
      uint256(cfg.liquidationBonusFactor),
      uint256(80_00),
      'liquidationBonusFactor mismatch'
    );
  }

  function test_hubSpokeToAssetsAddition_GLOBAL_DOLLAR_HUB_PAXG_GOLD_SPOKE_PAXG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(proposal.PAXG());
    assertTrue(hub.isSpokeListed(assetId, proposal.PAXG_GOLD_SPOKE()), 'spoke not listed');
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(assetId, proposal.PAXG_GOLD_SPOKE());
    assertEq(uint256(cfg.addCap), uint256(2_500), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(0), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubSpokeToAssetsAddition_GLOBAL_DOLLAR_HUB_PAXG_GOLD_SPOKE_USDG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.USDG_UNDERLYING));
    assertTrue(hub.isSpokeListed(assetId, proposal.PAXG_GOLD_SPOKE()), 'spoke not listed');
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(assetId, proposal.PAXG_GOLD_SPOKE());
    assertEq(uint256(cfg.addCap), uint256(5_000_000), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(9_500_000), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubSpokeToAssetsAddition_GLOBAL_DOLLAR_HUB_USDG_PENDLE_SPOKE_USDG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.USDG_UNDERLYING));
    assertTrue(
      hub.isSpokeListed(assetId, address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE)),
      'spoke not listed'
    );
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(
      assetId,
      address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE)
    );
    assertEq(uint256(cfg.addCap), uint256(0), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(4_000_000), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_spokePositionManagerUpdate_PAXG_GOLD_SPOKE_GIVER_POSITION_MANAGER() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_GOLD_SPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_spokePositionManagerUpdate_PAXG_GOLD_SPOKE_TAKER_POSITION_MANAGER() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_GOLD_SPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_spokePositionManagerUpdate_PAXG_GOLD_SPOKE_CONFIG_POSITION_MANAGER() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_GOLD_SPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_spokePositionManagerUpdate_PAXG_GOLD_SPOKE_SIGNATURE_GATEWAY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_GOLD_SPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_hubAssetListingsInput() public view {
    IConfigEngine.AssetListing[] memory items = proposal.hubAssetListings();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[0].underlying, proposal.PAXG(), 'underlying');
    assertEq(items[0].feeReceiver, address(AaveV4Ethereum.TREASURY_SPOKE), 'feeReceiver');
    assertEq(items[0].liquidityFee, 0, 'liquidityFee');
    assertEq(
      items[0].irStrategy,
      address(AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_USDG_IR_STRATEGY),
      'irStrategy'
    );
    assertEq(
      uint256(items[0].irData.optimalUsageRatio),
      V4EngineDefaults.MAX_OPTIMAL_USAGE_RATIO,
      'optimalUsageRatio'
    );
    assertEq(uint256(items[0].irData.baseDrawnRate), 0, 'baseDrawnRate');
    assertEq(uint256(items[0].irData.rateGrowthBeforeOptimal), 0, 'rateGrowthBeforeOptimal');
    assertEq(uint256(items[0].irData.rateGrowthAfterOptimal), 0, 'rateGrowthAfterOptimal');
    assertEq(items[0].tokenization.addCap, 0, 'tokenization addCap');
    assertEq(
      items[0].tokenization.proxyAdminOwner,
      SECURITY_COUNCIL,
      'tokenization proxyAdminOwner'
    );
    assertEq(items[0].tokenization.name, 'Wrapped Aave Global Dollar PAXG', 'tokenization name');
    assertEq(items[0].tokenization.symbol, 'waGlobalDollarPAXG', 'tokenization symbol');
  }

  function test_spokeReserveListingsInput() public view {
    IConfigEngine.ReserveListing[] memory items = proposal.spokeReserveListings();
    assertEq(items.length, 3, 'length');
    assertEq(items[0].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(items[0].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[0].underlying, proposal.PAXG(), 'underlying');
    assertEq(items[0].priceSource, proposal.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED(), 'priceSource');
    assertEq(uint256(items[0].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[0].config.paused, false, 'paused');
    assertEq(items[0].config.frozen, false, 'frozen');
    assertEq(items[0].config.borrowable, false, 'borrowable');
    assertEq(items[0].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[0].dynamicConfig.collateralFactor), 75_00, 'collateralFactor');
    assertEq(uint256(items[0].dynamicConfig.maxLiquidationBonus), 106_50, 'maxLiquidationBonus');
    assertEq(uint256(items[0].dynamicConfig.liquidationFee), 10_00, 'liquidationFee');
    assertEq(items[1].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(items[1].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[1].underlying, address(AaveV4EthereumAssets.USDG_UNDERLYING), 'underlying');
    assertEq(
      items[1].priceSource,
      AaveV4EthereumSpokePriceFeeds.GOLD_SPOKE_USDG_PRICE_FEED,
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
    assertEq(items[2].spoke, address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE), 'spoke');
    assertEq(items[2].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[2].underlying, address(AaveV4EthereumAssets.USDG_UNDERLYING), 'underlying');
    assertEq(
      items[2].priceSource,
      AaveV4EthereumSpokePriceFeeds.USDG_PENDLE_SPOKE_USDG_PRICE_FEED,
      'priceSource'
    );
    assertEq(uint256(items[2].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[2].config.paused, false, 'paused');
    assertEq(items[2].config.frozen, false, 'frozen');
    assertEq(items[2].config.borrowable, true, 'borrowable');
    assertEq(items[2].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[2].dynamicConfig.collateralFactor), 0, 'collateralFactor');
    assertEq(uint256(items[2].dynamicConfig.maxLiquidationBonus), 100_00, 'maxLiquidationBonus');
    assertEq(uint256(items[2].dynamicConfig.liquidationFee), 0, 'liquidationFee');
  }

  function test_spokeLiquidationConfigUpdatesInput() public view {
    IConfigEngine.LiquidationConfigUpdate[] memory items = proposal.spokeLiquidationConfigUpdates();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(items[0].targetHealthFactor, 1.2e18, 'targetHealthFactor');
    assertEq(items[0].healthFactorForMaxBonus, 0.9e18, 'healthFactorForMaxBonus');
    assertEq(items[0].liquidationBonusFactor, 80_00, 'liquidationBonusFactor');
  }

  function test_hubSpokeToAssetsAdditionsInput() public view {
    IConfigEngine.SpokeToAssetsAddition[] memory items = proposal.hubSpokeToAssetsAdditions();
    assertEq(items.length, 2, 'length');
    assertEq(items[0].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(items[0].assets.length, 2, 'assets length');
    assertEq(items[0].assets[0].underlying, proposal.PAXG(), 'underlying');
    assertEq(uint256(items[0].assets[0].config.addCap), 2_500, 'addCap');
    assertEq(uint256(items[0].assets[0].config.drawCap), 0, 'drawCap');
    assertEq(uint256(items[0].assets[0].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[0].assets[0].config.active, true, 'active');
    assertEq(items[0].assets[0].config.halted, false, 'halted');
    assertEq(
      items[0].assets[1].underlying,
      address(AaveV4EthereumAssets.USDG_UNDERLYING),
      'underlying'
    );
    assertEq(uint256(items[0].assets[1].config.addCap), 5_000_000, 'addCap');
    assertEq(uint256(items[0].assets[1].config.drawCap), 9_500_000, 'drawCap');
    assertEq(uint256(items[0].assets[1].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[0].assets[1].config.active, true, 'active');
    assertEq(items[0].assets[1].config.halted, false, 'halted');
    assertEq(items[1].spoke, address(AaveV4EthereumSpokes.USDG_PENDLE_SPOKE), 'spoke');
    assertEq(items[1].assets.length, 1, 'assets length');
    assertEq(
      items[1].assets[0].underlying,
      address(AaveV4EthereumAssets.USDG_UNDERLYING),
      'underlying'
    );
    assertEq(uint256(items[1].assets[0].config.addCap), 0, 'addCap');
    assertEq(uint256(items[1].assets[0].config.drawCap), 4_000_000, 'drawCap');
    assertEq(uint256(items[1].assets[0].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[1].assets[0].config.active, true, 'active');
    assertEq(items[1].assets[0].config.halted, false, 'halted');
  }

  function test_spokePositionManagerUpdatesInput() public view {
    IConfigEngine.PositionManagerUpdate[] memory items = proposal.spokePositionManagerUpdates();
    assertEq(items.length, 4, 'length');
    assertEq(items[0].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(
      items[0].positionManager,
      address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER),
      'positionManager'
    );
    assertEq(items[0].active, true, 'active');
    assertEq(items[1].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(
      items[1].positionManager,
      address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER),
      'positionManager'
    );
    assertEq(items[1].active, true, 'active');
    assertEq(items[2].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(
      items[2].positionManager,
      address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER),
      'positionManager'
    );
    assertEq(items[2].active, true, 'active');
    assertEq(items[3].spoke, proposal.PAXG_GOLD_SPOKE(), 'spoke');
    assertEq(
      items[3].positionManager,
      address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY),
      'positionManager'
    );
    assertEq(items[3].active, true, 'active');
  }
}
