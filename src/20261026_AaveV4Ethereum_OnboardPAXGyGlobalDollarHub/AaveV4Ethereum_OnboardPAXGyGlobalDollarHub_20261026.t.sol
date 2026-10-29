// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {ISpokeInstance} from 'aave-v4/deployments/utils/interfaces/ISpokeInstance.sol';
import {Initializable} from 'aave-v4/dependencies/openzeppelin-upgradeable/Initializable.sol';
import {IPriceCapAdapter} from 'src/interfaces/IPriceCapAdapter.sol';
import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV4EthereumSpokes, AaveV4EthereumHubs, AaveV4Ethereum, AaveV4EthereumIRStrategies, AaveV4EthereumSpokePriceFeeds, AaveV4EthereumAssets, AaveV4EthereumPositionManagers, AaveV4EthereumTokenizationSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';
import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';
import {AggregatorInterface} from 'aave-v3-origin/contracts/dependencies/chainlink/AggregatorInterface.sol';
import {IPositionManagerBase} from 'aave-v4/position-manager/interfaces/IPositionManagerBase.sol';
import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';
import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';
import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';
import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';

import 'forge-std/Test.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026} from './AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026.sol';

interface IPAXGyAccountant {
  error AccountantWithRateProviders__Paused();
  function owner() external view returns (address);
  function getRate() external view returns (uint256);
  function getRateSafe() external view returns (uint256);
  function pause() external;
}

/**
 * @dev Test for AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261026_AaveV4Ethereum_OnboardPAXGyGlobalDollarHub/AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026.t.sol -vv
 */
contract AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026_Test is ProtocolV4TestBaseEthereum {
  address internal constant PAXG_PAXOS_ESPOKE_IMPLEMENTATION =
    0x3E2A7AA92D5849D3FAd6Def1D11c379c7218223d;
  address internal constant PAXG_PAXOS_ESPOKE_ORACLE = 0x6b3800e96Bb4AA38a879b2c143B6E2f5f2687b77;
  address internal constant PAXGY_ACCOUNTANT = 0x397e38359f169748a02bc11f98D4f451FE88C1fd;

  AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26284253);
    proposal = new AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    ISpoke[] memory spokes = _getSpokes();
    address paxgPaxosESpoke = proposal.PAXG_PAXOS_ESPOKE();
    bool listed;
    for (uint256 i; i < spokes.length; ++i) {
      if (address(spokes[i]) == paxgPaxosESpoke) {
        listed = true;
        break;
      }
    }
    if (!listed) {
      ISpoke[] memory expanded = new ISpoke[](spokes.length + 1);
      for (uint256 i; i < spokes.length; ++i) {
        expanded[i] = spokes[i];
      }
      expanded[spokes.length] = ISpoke(paxgPaxosESpoke);
      spokes = expanded;
    }
    defaultTest(
      'AaveV4Ethereum_OnboardPAXGyGlobalDollarHub_20261026',
      spokes,
      _getTokenizationSpokes(),
      address(proposal)
    );
  }

  function test_preState() public view {
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    assertFalse(hub.isUnderlyingListed(proposal.PAXGY()), 'PAXGy listing pre-state mismatch');
    ISpoke spoke = ISpoke(proposal.PAXG_PAXOS_ESPOKE());
    assertEq(spoke.getReserveCount(), 0, 'reserve count mismatch');
    uint256 paxgAssetId = hub.getAssetId(AaveV4EthereumAssets.PAXG_UNDERLYING);
    assertFalse(
      hub.isSpokeListed(paxgAssetId, address(spoke)),
      'PAXG spoke registration pre-state mismatch'
    );
    IHub.SpokeConfig memory tokenizationCfg = hub.getSpokeConfig(
      paxgAssetId,
      address(AaveV4EthereumTokenizationSpokes.GLOBAL_DOLLAR_PAXG_TOKENIZATION_SPOKE)
    );
    assertEq(tokenizationCfg.addCap, 0, 'PAXG tokenization addCap pre-state mismatch');
    assertEq(tokenizationCfg.drawCap, 0, 'PAXG tokenization drawCap pre-state mismatch');
  }

  function test_paxgPaxosESpokeProxyAdminOwner() public view {
    assertEq(
      _proxyAdminOwner(proposal.PAXG_PAXOS_ESPOKE()),
      MiscEthereum.V4_SECURITY_COUNCIL,
      'proxy admin owner mismatch'
    );
  }

  function test_paxgPaxosESpokeImplementationAndOracle() public view {
    address spoke = proposal.PAXG_PAXOS_ESPOKE();
    bytes32 implementationSlot = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);
    address implementation = address(uint160(uint256(vm.load(spoke, implementationSlot))));
    assertEq(implementation, PAXG_PAXOS_ESPOKE_IMPLEMENTATION, 'spoke implementation mismatch');
    assertGt(implementation.code.length, 0, 'implementation code length mismatch');
    assertEq(ISpoke(spoke).ORACLE(), PAXG_PAXOS_ESPOKE_ORACLE, 'spoke oracle mismatch');
    assertEq(
      ISpoke(implementation).ORACLE(),
      ISpoke(spoke).ORACLE(),
      'implementation oracle mismatch'
    );
    assertEq(ISpoke(spoke).getReserveCount(), 0, 'reserve count mismatch');
    assertEq(
      ISpoke(spoke).MAX_USER_RESERVES_LIMIT(),
      type(uint16).max,
      'max user reserves limit mismatch'
    );
  }

  function test_existingGoldReserveConfigUnchanged() public {
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 paxgAssetId = hub.getAssetId(AaveV4EthereumAssets.PAXG_UNDERLYING);
    uint256 usdgAssetId = hub.getAssetId(AaveV4EthereumAssets.USDG_UNDERLYING);
    uint256 paxgReserveId = spoke.getReserveId(address(hub), paxgAssetId);
    uint256 usdgReserveId = spoke.getReserveId(address(hub), usdgAssetId);
    bytes32 liquidationBefore = keccak256(abi.encode(spoke.getLiquidationConfig()));
    bytes32 paxgBefore = _reserveConfigurationHash(spoke, paxgReserveId);
    bytes32 usdgBefore = _reserveConfigurationHash(spoke, usdgReserveId);
    bytes32 paxgCapsBefore = keccak256(abi.encode(hub.getSpokeConfig(paxgAssetId, address(spoke))));
    bytes32 usdgCapsBefore = keccak256(abi.encode(hub.getSpokeConfig(usdgAssetId, address(spoke))));

    GovV3Helpers.executePayload(vm, address(proposal));

    assertEq(
      keccak256(abi.encode(spoke.getLiquidationConfig())),
      liquidationBefore,
      'Gold Spoke liquidation configuration mismatch'
    );
    assertEq(
      _reserveConfigurationHash(spoke, paxgReserveId),
      paxgBefore,
      'PAXG reserve configuration mismatch'
    );
    assertEq(
      _reserveConfigurationHash(spoke, usdgReserveId),
      usdgBefore,
      'USDG reserve configuration mismatch'
    );
    assertEq(
      keccak256(abi.encode(hub.getSpokeConfig(paxgAssetId, address(spoke)))),
      paxgCapsBefore,
      'PAXG caps mismatch'
    );
    assertEq(
      keccak256(abi.encode(hub.getSpokeConfig(usdgAssetId, address(spoke)))),
      usdgCapsBefore,
      'USDG caps mismatch'
    );
  }

  function test_rolesWired_PAXG_PAXOS_ESPOKE() public {
    IConfigEngine.TargetFunctionRoleUpdate[] memory items = proposal
      .accessManagerTargetFunctionRoleUpdates();
    GovV3Helpers.executePayload(vm, address(proposal));
    uint256 matched;
    for (uint256 i; i < items.length; ++i) {
      if (items[i].target != proposal.PAXG_PAXOS_ESPOKE()) continue;
      _assertRolesWired(items[i], address(AaveV4EthereumSpokes.MAIN_SPOKE));
      ++matched;
    }
    assertGt(matched, 0, 'no wiring for target');
  }

  function test_spokeDeployment_PAXG_PAXOS_ESPOKE() public view {
    _assertSpokeDeployment(ISpoke(proposal.PAXG_PAXOS_ESPOKE()));
  }

  function test_hubAssetListing_GLOBAL_DOLLAR_HUB_PAXGY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    assertTrue(hub.isUnderlyingListed(proposal.PAXGY()), 'asset not listed');
    uint256 assetId = hub.getAssetId(proposal.PAXGY());
    IHub.Asset memory asset = hub.getAsset(assetId);
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    assertEq(asset.underlying, proposal.PAXGY(), 'underlying mismatch');
    assertEq(
      uint256(asset.decimals),
      IERC20Metadata(proposal.PAXGY()).decimals(),
      'decimals mismatch'
    );
    assertEq(cfg.feeReceiver, address(AaveV4Ethereum.TREASURY_SPOKE), 'feeReceiver mismatch');
    assertEq(
      cfg.irStrategy,
      address(AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_PAXG_IR_STRATEGY),
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
    assertEq(
      _findTokenizationSpoke(hub, proposal.PAXGY()),
      address(0),
      'unexpected tokenization spoke'
    );
  }

  function test_spokeReserveListing_PAXG_GOLD_SPOKE_PAXGY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(proposal.PAXGY());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(reserve.underlying, proposal.PAXGY(), 'underlying mismatch');
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(proposal.PAXGY()).decimals(),
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
    assertEq(uint256(dyn.collateralFactor), uint256(70_00), 'collateralFactor mismatch');
    assertEq(uint256(dyn.maxLiquidationBonus), uint256(107_50), 'maxLiquidationBonus mismatch');
    assertEq(uint256(dyn.liquidationFee), uint256(10_00), 'liquidationFee mismatch');
  }

  function test_spokeReserveListing_PAXG_PAXOS_ESPOKE_PAXGY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_PAXOS_ESPOKE());
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(proposal.PAXGY());
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(reserve.underlying, proposal.PAXGY(), 'underlying mismatch');
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(proposal.PAXGY()).decimals(),
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
    assertEq(uint256(dyn.collateralFactor), uint256(85_00), 'collateralFactor mismatch');
    assertEq(uint256(dyn.maxLiquidationBonus), uint256(104_00), 'maxLiquidationBonus mismatch');
    assertEq(uint256(dyn.liquidationFee), uint256(10_00), 'liquidationFee mismatch');
  }

  function test_spokeReserveListing_PAXG_PAXOS_ESPOKE_PAXG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_PAXOS_ESPOKE());
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.PAXG_UNDERLYING));
    uint256 reserveId = spoke.getReserveId(address(hub), assetId);
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    ISpoke.ReserveConfig memory cfg = spoke.getReserveConfig(reserveId);
    assertEq(
      reserve.underlying,
      address(AaveV4EthereumAssets.PAXG_UNDERLYING),
      'underlying mismatch'
    );
    assertEq(address(reserve.hub), address(hub), 'hub mismatch');
    assertEq(uint256(reserve.assetId), assetId, 'assetId mismatch');
    assertEq(
      uint256(reserve.decimals),
      IERC20Metadata(address(AaveV4EthereumAssets.PAXG_UNDERLYING)).decimals(),
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
    ISpoke spoke = ISpoke(address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE));
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
          IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)).getAssetId(proposal.PAXGY())
        )
      ),
      proposal.PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED(),
      'PAXGY price source mismatch'
    );
  }

  function test_reservePriceSources_PAXG_PAXOS_ESPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_PAXOS_ESPOKE());
    IAaveOracle oracle = IAaveOracle(spoke.ORACLE());
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
          IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)).getAssetId(proposal.PAXGY())
        )
      ),
      proposal.PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED(),
      'PAXGY price source mismatch'
    );
    assertEq(
      oracle.getReserveSource(
        spoke.getReserveId(
          address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB),
          IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB)).getAssetId(
            address(AaveV4EthereumAssets.PAXG_UNDERLYING)
          )
        )
      ),
      AaveV4EthereumSpokePriceFeeds.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED,
      'PAXG price source mismatch'
    );
  }

  function test_e2e_PAXG_PAXOS_ESPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestSpoke(ISpoke(proposal.PAXG_PAXOS_ESPOKE()));
  }

  function test_spokeLiquidationConfigUpdate_PAXG_PAXOS_ESPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke.LiquidationConfig memory cfg = ISpoke(proposal.PAXG_PAXOS_ESPOKE())
      .getLiquidationConfig();
    assertEq(uint256(cfg.targetHealthFactor), uint256(1.05e18), 'targetHealthFactor mismatch');
    assertEq(
      uint256(cfg.healthFactorForMaxBonus),
      uint256(0.99e18),
      'healthFactorForMaxBonus mismatch'
    );
    assertEq(
      uint256(cfg.liquidationBonusFactor),
      uint256(100_00),
      'liquidationBonusFactor mismatch'
    );
  }

  function test_hubSpokeToAssetsAddition_GLOBAL_DOLLAR_HUB_PAXG_GOLD_SPOKE_PAXGY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(proposal.PAXGY());
    assertTrue(
      hub.isSpokeListed(assetId, address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE)),
      'spoke not listed'
    );
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(
      assetId,
      address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE)
    );
    assertEq(uint256(cfg.addCap), uint256(480), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(0), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubSpokeToAssetsAddition_GLOBAL_DOLLAR_HUB_PAXG_PAXOS_ESPOKE_PAXGY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(proposal.PAXGY());
    assertTrue(hub.isSpokeListed(assetId, proposal.PAXG_PAXOS_ESPOKE()), 'spoke not listed');
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(assetId, proposal.PAXG_PAXOS_ESPOKE());
    assertEq(uint256(cfg.addCap), uint256(480), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(0), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_hubSpokeToAssetsAddition_GLOBAL_DOLLAR_HUB_PAXG_PAXOS_ESPOKE_PAXG() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(address(AaveV4EthereumAssets.PAXG_UNDERLYING));
    assertTrue(hub.isSpokeListed(assetId, proposal.PAXG_PAXOS_ESPOKE()), 'spoke not listed');
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(assetId, proposal.PAXG_PAXOS_ESPOKE());
    assertEq(uint256(cfg.addCap), uint256(0), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(400), 'drawCap mismatch');
    assertEq(uint256(cfg.riskPremiumThreshold), uint256(0), 'riskPremiumThreshold mismatch');
    assertEq(cfg.active, true, 'active mismatch');
    assertEq(cfg.halted, false, 'halted mismatch');
  }

  function test_spokePositionManagerUpdate_PAXG_PAXOS_ESPOKE_GIVER_POSITION_MANAGER() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_PAXOS_ESPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_spokePositionManagerUpdate_PAXG_PAXOS_ESPOKE_TAKER_POSITION_MANAGER() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_PAXOS_ESPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_spokePositionManagerUpdate_PAXG_PAXOS_ESPOKE_CONFIG_POSITION_MANAGER() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_PAXOS_ESPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_spokePositionManagerUpdate_PAXG_PAXOS_ESPOKE_SIGNATURE_GATEWAY() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    assertEq(
      ISpoke(proposal.PAXG_PAXOS_ESPOKE()).isPositionManagerActive(
        address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY)
      ),
      true,
      'positionManager active mismatch'
    );
  }

  function test_hubAssetConfigUpdate_GLOBAL_DOLLAR_HUB_PAXG() public {
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.PAXG_UNDERLYING);
    IHub.AssetConfig memory before = hub.getAssetConfig(assetId);
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub.AssetConfig memory cfg = hub.getAssetConfig(assetId);
    assertEq(uint256(cfg.liquidityFee), uint256(50_00), 'liquidityFee mismatch');
    assertEq(cfg.feeReceiver, before.feeReceiver, 'feeReceiver unchanged');
    assertEq(cfg.irStrategy, before.irStrategy, 'irStrategy unchanged');
    assertEq(
      cfg.reinvestmentController,
      before.reinvestmentController,
      'reinvestmentController unchanged'
    );
  }

  function test_hubSpokeConfigUpdate_GLOBAL_DOLLAR_HUB_GLOBAL_DOLLAR_PAXG_TOKENIZATION_SPOKE_PAXG()
    public
  {
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 assetId = hub.getAssetId(AaveV4EthereumAssets.PAXG_UNDERLYING);
    IHub.SpokeConfig memory before = hub.getSpokeConfig(
      assetId,
      address(AaveV4EthereumTokenizationSpokes.GLOBAL_DOLLAR_PAXG_TOKENIZATION_SPOKE)
    );
    GovV3Helpers.executePayload(vm, address(proposal));
    IHub.SpokeConfig memory cfg = hub.getSpokeConfig(
      assetId,
      address(AaveV4EthereumTokenizationSpokes.GLOBAL_DOLLAR_PAXG_TOKENIZATION_SPOKE)
    );
    assertEq(uint256(cfg.addCap), uint256(400), 'addCap mismatch');
    assertEq(uint256(cfg.drawCap), uint256(before.drawCap), 'drawCap unchanged');
    assertEq(
      uint256(cfg.riskPremiumThreshold),
      uint256(before.riskPremiumThreshold),
      'riskPremiumThreshold unchanged'
    );
    assertEq(cfg.active, before.active, 'active unchanged');
    assertEq(cfg.halted, before.halted, 'halted unchanged');
  }

  function test_reservePrices_PAXG_GOLD_SPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _assertPaxgyReservePrice(ISpoke(address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE)));
  }

  function test_reservePrices_PAXG_PAXOS_ESPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ISpoke spoke = ISpoke(proposal.PAXG_PAXOS_ESPOKE());
    _assertPaxgyReservePrice(spoke);
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256[] memory reserveIds = new uint256[](1);
    reserveIds[0] = spoke.getReserveId(
      address(hub),
      hub.getAssetId(AaveV4EthereumAssets.PAXG_UNDERLYING)
    );
    uint256[] memory prices = IAaveOracle(spoke.ORACLE()).getReservesPrices(reserveIds);
    assertEq(
      prices[0],
      uint256(
        AggregatorInterface(AaveV4EthereumSpokePriceFeeds.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED)
          .latestAnswer()
      ),
      'PAXG price mismatch'
    );
  }

  /// @dev The Security Council registers the spoke on the position managers outside this payload.
  function test_e2ePositionManagers_PAXG_PAXOS_ESPOKE() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address spoke = proposal.PAXG_PAXOS_ESPOKE();
    address[4] memory managers = [
      address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER),
      address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER),
      address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER),
      address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY)
    ];

    vm.startPrank(MiscEthereum.V4_SECURITY_COUNCIL);
    for (uint256 i; i < managers.length; ++i) {
      assertTrue(
        ISpoke(spoke).isPositionManagerActive(managers[i]),
        'position manager active status mismatch'
      );
      assertFalse(
        IPositionManagerBase(managers[i]).isSpokeRegistered(spoke),
        'position manager registration mismatch'
      );
      IPositionManagerBase(managers[i]).registerSpoke(spoke, true);
      assertTrue(
        IPositionManagerBase(managers[i]).isSpokeRegistered(spoke),
        'position manager registration mismatch'
      );
    }

    vm.stopPrank();

    e2eTestPositionManagers(ISpoke(spoke));
  }

  function test_paxgInterestRateModel() public {
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256 paxgAssetId = hub.getAssetId(AaveV4EthereumAssets.PAXG_UNDERLYING);
    IAssetInterestRateStrategy strategy = IAssetInterestRateStrategy(
      hub.getAssetConfig(paxgAssetId).irStrategy
    );
    assertEq(hub.getAssetConfig(paxgAssetId).liquidityFee, 0, 'liquidityFee pre-state mismatch');
    IAssetInterestRateStrategy.InterestRateData memory beforeIR = strategy.getInterestRateData(
      paxgAssetId
    );
    assertEq(beforeIR.optimalUsageRatio, 99_00, 'optimalUsageRatio pre-state mismatch');
    assertEq(beforeIR.baseDrawnRate, 0, 'baseDrawnRate pre-state mismatch');
    assertEq(beforeIR.rateGrowthBeforeOptimal, 0, 'rateGrowthBeforeOptimal pre-state mismatch');
    assertEq(beforeIR.rateGrowthAfterOptimal, 0, 'rateGrowthAfterOptimal pre-state mismatch');

    GovV3Helpers.executePayload(vm, address(proposal));

    uint256 paxgyAssetId = hub.getAssetId(proposal.PAXGY());
    IAssetInterestRateStrategy.InterestRateData memory ir = strategy.getInterestRateData(
      paxgAssetId
    );
    assertEq(hub.getAssetConfig(paxgAssetId).liquidityFee, 50_00, 'liquidityFee mismatch');
    assertEq(ir.optimalUsageRatio, 60_00, 'optimalUsageRatio mismatch');
    assertEq(ir.baseDrawnRate, 0, 'baseDrawnRate mismatch');
    assertEq(ir.rateGrowthBeforeOptimal, 3_00, 'rateGrowthBeforeOptimal mismatch');
    assertEq(ir.rateGrowthAfterOptimal, 20_00, 'rateGrowthAfterOptimal mismatch');
    assertEq(
      strategy.calculateInterestRate(paxgAssetId, 40e18, 60e18, 0, 0),
      3e25,
      'PAXG drawn rate mismatch'
    );
    assertEq(
      strategy.calculateInterestRate(paxgAssetId, 0, 100e18, 0, 0),
      23e25,
      'PAXG drawn rate mismatch'
    );
    assertEq(
      strategy.calculateInterestRate(paxgyAssetId, 0, 100e18, 0, 0),
      0,
      'PAXGy non-borrowable rate mismatch'
    );
  }

  /// @dev PAXGy is priced through the CAPO adapter over Chainlink XAU/USD.
  function test_priceFeedParameters() public view {
    IPriceCapAdapter adapter = IPriceCapAdapter(proposal.PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED());
    assertEq(
      address(adapter.BASE_TO_USD_AGGREGATOR()),
      AaveV4EthereumSpokePriceFeeds.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED,
      'base aggregator mismatch'
    );
    assertEq(adapter.RATIO_PROVIDER(), PAXGY_ACCOUNTANT, 'ratio provider mismatch');
    assertEq(
      address(adapter.ACL_MANAGER()),
      address(AaveV3Ethereum.ACL_MANAGER),
      'ACL manager mismatch'
    );
    assertEq(adapter.decimals(), 8, 'price decimals mismatch');
    assertEq(adapter.MINIMUM_SNAPSHOT_DELAY(), 7 days, 'minimum snapshot delay mismatch');
    assertEq(adapter.getSnapshotRatio(), 1.001317899581791979e18, 'snapshot ratio mismatch');
    assertEq(adapter.getSnapshotTimestamp(), 1791136619, 'snapshot timestamp mismatch');
    assertEq(adapter.getMaxYearlyGrowthRatePercent(), 6_00, 'max yearly growth mismatch');
    assertGt(adapter.latestAnswer(), 0, 'CAPO price mismatch');
  }

  function test_accountantPauseKeepsLastRate() public {
    IPriceCapAdapter adapter = IPriceCapAdapter(proposal.PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED());
    IPAXGyAccountant accountant = IPAXGyAccountant(PAXGY_ACCOUNTANT);
    uint256 rateBefore = accountant.getRate();
    int256 priceBefore = adapter.latestAnswer();
    vm.prank(accountant.owner());
    accountant.pause();
    assertEq(accountant.getRate(), rateBefore, 'stored accountant rate mismatch');
    vm.expectRevert(IPAXGyAccountant.AccountantWithRateProviders__Paused.selector);
    accountant.getRateSafe();
    assertEq(adapter.getRatio(), int256(rateBefore), 'CAPO ratio while paused mismatch');
    assertEq(adapter.latestAnswer(), priceBefore, 'CAPO price while paused mismatch');
  }

  function test_spokeCannotBeReinitialized() public {
    address spoke = proposal.PAXG_PAXOS_ESPOKE();
    bytes32 implementationSlot = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);
    address implementation = address(uint160(uint256(vm.load(spoke, implementationSlot))));
    vm.expectRevert(Initializable.InvalidInitialization.selector);
    ISpokeInstance(spoke).initialize(address(AaveV4Ethereum.ACCESS_MANAGER));
    vm.expectRevert(Initializable.InvalidInitialization.selector);
    ISpokeInstance(implementation).initialize(address(AaveV4Ethereum.ACCESS_MANAGER));
  }

  function test_hubAssetListingsInput() public view {
    IConfigEngine.AssetListing[] memory items = proposal.hubAssetListings();
    assertEq(items.length, 1, 'length');
    assertEq(items[0].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[0].underlying, proposal.PAXGY(), 'underlying');
    assertEq(items[0].feeReceiver, address(AaveV4Ethereum.TREASURY_SPOKE), 'feeReceiver');
    assertEq(items[0].liquidityFee, 0, 'liquidityFee');
    assertEq(
      items[0].irStrategy,
      address(AaveV4EthereumIRStrategies.GLOBAL_DOLLAR_PAXG_IR_STRATEGY),
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
  }

  function test_spokeReserveListingsInput() public view {
    IConfigEngine.ReserveListing[] memory items = proposal.spokeReserveListings();
    assertEq(items.length, 3, 'length');
    assertEq(items[0].spoke, address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE), 'spoke');
    assertEq(items[0].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[0].underlying, proposal.PAXGY(), 'underlying');
    assertEq(items[0].priceSource, proposal.PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED(), 'priceSource');
    assertEq(uint256(items[0].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[0].config.paused, false, 'paused');
    assertEq(items[0].config.frozen, false, 'frozen');
    assertEq(items[0].config.borrowable, false, 'borrowable');
    assertEq(items[0].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[0].dynamicConfig.collateralFactor), 70_00, 'collateralFactor');
    assertEq(uint256(items[0].dynamicConfig.maxLiquidationBonus), 107_50, 'maxLiquidationBonus');
    assertEq(uint256(items[0].dynamicConfig.liquidationFee), 10_00, 'liquidationFee');
    assertEq(items[1].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(items[1].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[1].underlying, proposal.PAXGY(), 'underlying');
    assertEq(items[1].priceSource, proposal.PAXG_GOLD_SPOKE_PAXGY_PRICE_FEED(), 'priceSource');
    assertEq(uint256(items[1].config.collateralRisk), 0, 'collateralRisk');
    assertEq(items[1].config.paused, false, 'paused');
    assertEq(items[1].config.frozen, false, 'frozen');
    assertEq(items[1].config.borrowable, false, 'borrowable');
    assertEq(items[1].config.receiveSharesEnabled, true, 'receiveSharesEnabled');
    assertEq(uint256(items[1].dynamicConfig.collateralFactor), 85_00, 'collateralFactor');
    assertEq(uint256(items[1].dynamicConfig.maxLiquidationBonus), 104_00, 'maxLiquidationBonus');
    assertEq(uint256(items[1].dynamicConfig.liquidationFee), 10_00, 'liquidationFee');
    assertEq(items[2].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(items[2].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(items[2].underlying, address(AaveV4EthereumAssets.PAXG_UNDERLYING), 'underlying');
    assertEq(
      items[2].priceSource,
      AaveV4EthereumSpokePriceFeeds.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED,
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
    assertEq(items[0].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(items[0].targetHealthFactor, 1.05e18, 'targetHealthFactor');
    assertEq(items[0].healthFactorForMaxBonus, 0.99e18, 'healthFactorForMaxBonus');
    assertEq(items[0].liquidationBonusFactor, 100_00, 'liquidationBonusFactor');
  }

  function test_hubSpokeToAssetsAdditionsInput() public view {
    IConfigEngine.SpokeToAssetsAddition[] memory items = proposal.hubSpokeToAssetsAdditions();
    assertEq(items.length, 2, 'length');
    assertEq(items[0].spoke, address(AaveV4EthereumSpokes.PAXG_GOLD_SPOKE), 'spoke');
    assertEq(items[0].assets.length, 1, 'assets length');
    assertEq(items[0].assets[0].underlying, proposal.PAXGY(), 'underlying');
    assertEq(uint256(items[0].assets[0].config.addCap), 480, 'addCap');
    assertEq(uint256(items[0].assets[0].config.drawCap), 0, 'drawCap');
    assertEq(uint256(items[0].assets[0].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[0].assets[0].config.active, true, 'active');
    assertEq(items[0].assets[0].config.halted, false, 'halted');
    assertEq(items[1].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(items[1].assets.length, 2, 'assets length');
    assertEq(items[1].assets[0].underlying, proposal.PAXGY(), 'underlying');
    assertEq(uint256(items[1].assets[0].config.addCap), 480, 'addCap');
    assertEq(uint256(items[1].assets[0].config.drawCap), 0, 'drawCap');
    assertEq(uint256(items[1].assets[0].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[1].assets[0].config.active, true, 'active');
    assertEq(items[1].assets[0].config.halted, false, 'halted');
    assertEq(
      items[1].assets[1].underlying,
      address(AaveV4EthereumAssets.PAXG_UNDERLYING),
      'underlying'
    );
    assertEq(uint256(items[1].assets[1].config.addCap), 0, 'addCap');
    assertEq(uint256(items[1].assets[1].config.drawCap), 400, 'drawCap');
    assertEq(uint256(items[1].assets[1].config.riskPremiumThreshold), 0, 'riskPremiumThreshold');
    assertEq(items[1].assets[1].config.active, true, 'active');
    assertEq(items[1].assets[1].config.halted, false, 'halted');
  }

  function test_spokePositionManagerUpdatesInput() public view {
    IConfigEngine.PositionManagerUpdate[] memory items = proposal.spokePositionManagerUpdates();
    assertEq(items.length, 4, 'length');
    assertEq(items[0].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(
      items[0].positionManager,
      address(AaveV4EthereumPositionManagers.GIVER_POSITION_MANAGER),
      'positionManager'
    );
    assertEq(items[0].active, true, 'active');
    assertEq(items[1].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(
      items[1].positionManager,
      address(AaveV4EthereumPositionManagers.TAKER_POSITION_MANAGER),
      'positionManager'
    );
    assertEq(items[1].active, true, 'active');
    assertEq(items[2].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(
      items[2].positionManager,
      address(AaveV4EthereumPositionManagers.CONFIG_POSITION_MANAGER),
      'positionManager'
    );
    assertEq(items[2].active, true, 'active');
    assertEq(items[3].spoke, proposal.PAXG_PAXOS_ESPOKE(), 'spoke');
    assertEq(
      items[3].positionManager,
      address(AaveV4EthereumPositionManagers.SIGNATURE_GATEWAY),
      'positionManager'
    );
    assertEq(items[3].active, true, 'active');
  }

  function test_hubSpokeConfigUpdatesInput() public view {
    IConfigEngine.SpokeConfigUpdate[] memory items = proposal.hubSpokeConfigUpdates();
    assertEq(items.length, 1, 'length');
    assertEq(
      address(items[0].hubConfigurator),
      address(AaveV4Ethereum.HUB_CONFIGURATOR),
      'hubConfigurator'
    );
    assertEq(items[0].hub, address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB), 'hub');
    assertEq(
      items[0].spoke,
      address(AaveV4EthereumTokenizationSpokes.GLOBAL_DOLLAR_PAXG_TOKENIZATION_SPOKE),
      'spoke'
    );
    assertEq(items[0].underlying, AaveV4EthereumAssets.PAXG_UNDERLYING, 'underlying');
    assertEq(items[0].addCap, 400, 'addCap');
    assertEq(items[0].drawCap, EngineFlags.KEEP_CURRENT, 'drawCap');
    assertEq(items[0].riskPremiumThreshold, EngineFlags.KEEP_CURRENT, 'riskPremiumThreshold');
    assertEq(items[0].active, EngineFlags.KEEP_CURRENT, 'active');
    assertEq(items[0].halted, EngineFlags.KEEP_CURRENT, 'halted');
  }

  function _assertPaxgyReservePrice(ISpoke spoke) internal view {
    IHub hub = IHub(address(AaveV4EthereumHubs.GLOBAL_DOLLAR_HUB));
    uint256[] memory reserveIds = new uint256[](1);
    reserveIds[0] = spoke.getReserveId(address(hub), hub.getAssetId(proposal.PAXGY()));
    uint256[] memory prices = IAaveOracle(spoke.ORACLE()).getReservesPrices(reserveIds);
    uint256 goldPrice = uint256(
      AggregatorInterface(AaveV4EthereumSpokePriceFeeds.PAXG_GOLD_SPOKE_PAXG_PRICE_FEED)
        .latestAnswer()
    );
    uint256 ratio = IPAXGyAccountant(PAXGY_ACCOUNTANT).getRate();
    assertEq(prices[0], (goldPrice * ratio) / 1e18, 'PAXGy price mismatch');
  }

  function _reserveConfigurationHash(
    ISpoke spoke,
    uint256 reserveId
  ) internal view returns (bytes32) {
    ISpoke.Reserve memory reserve = spoke.getReserve(reserveId);
    bytes32 result = keccak256(
      abi.encode(spoke.getReserveConfig(reserveId), reserve.dynamicConfigKey)
    );
    for (
      uint24 dynamicConfigKey;
      dynamicConfigKey <= reserve.dynamicConfigKey;
      ++dynamicConfigKey
    ) {
      result = keccak256(
        abi.encode(result, spoke.getDynamicReserveConfig(reserveId, dynamicConfigKey))
      );
    }
    return result;
  }
}
