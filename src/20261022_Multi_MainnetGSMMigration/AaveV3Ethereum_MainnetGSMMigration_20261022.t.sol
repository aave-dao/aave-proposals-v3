// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {IPriceOracleGetter} from 'aave-v3-origin/contracts/interfaces/IPriceOracleGetter.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4EthereumHubs, AaveV4EthereumTokenizationSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IAaveCLRobotOperator} from 'src/interfaces/IAaveCLRobotOperator.sol';
import {IFixedPriceStrategy4626} from 'src/interfaces/IFixedPriceStrategy4626.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmFeeStrategy} from 'src/interfaces/IGsmFeeStrategy.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IGsmSteward} from 'src/interfaces/IGsmSteward.sol';
import {IOracleSwapFreezer} from 'src/interfaces/IOracleSwapFreezer.sol';

import {AaveV3Ethereum_MainnetGSMMigration_20261022} from './AaveV3Ethereum_MainnetGSMMigration_20261022.sol';
import {AaveV4Ethereum_MainnetGSMMigration_20261022} from './AaveV4Ethereum_MainnetGSMMigration_20261022.sol';

/**
 * @dev Test for AaveV3Ethereum_MainnetGSMMigration_20261022
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261022_Multi_MainnetGSMMigration/AaveV3Ethereum_MainnetGSMMigration_20261022.t.sol -vv
 */
contract AaveV3Ethereum_MainnetGSMMigration_20261022_Test is ProtocolV3TestBase {
  using SafeERC20 for IERC20;

  struct GsmConfig {
    uint256 sellFee;
    uint256 buyFee;
    uint256 exposureCap;
    uint256 reserveLimit;
    bool freezerCanUnfreeze;
    uint256 freezeLowerBound;
    uint256 freezeUpperBound;
    uint256 unfreezeLowerBound;
    uint256 unfreezeUpperBound;
  }

  // ERC1967 implementation slot, used to read the live Gsm4626 implementation bytecode
  bytes32 internal constant IMPLEMENTATION_SLOT =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  // LINK left in the two cancelled keepers (80 LINK each, funded at registration and never spent)
  uint256 internal constant KEEPERS_REMAINING_LINK = 160 ether;

  // Max GHO lost to rounding in the stataUSDT -> USDT -> waCoreUSDT -> GHO conversion path
  uint256 internal constant MIGRATION_ROUNDING_TOLERANCE = 10e12; // 10 units of 6-decimal USDT

  AaveV4Ethereum_MainnetGSMMigration_20261022 internal v4Proposal;
  AaveV3Ethereum_MainnetGSMMigration_20261022 internal proposal;
  uint256 internal beforeV4PayloadSnapshot;

  IGhoReserve internal constant GHO_RESERVE = IGhoReserve(GhoEthereum.GHO_RESERVE);
  IERC20 internal constant GHO = IERC20(GhoEthereum.GHO_TOKEN);
  address internal constant COLLECTOR = address(AaveV3Ethereum.COLLECTOR);
  address internal constant EXECUTOR = GovernanceV3Ethereum.EXECUTOR_LVL_1;
  address internal constant WA_CORE_USDC =
    address(AaveV4EthereumTokenizationSpokes.CORE_USDC_TOKENIZATION_SPOKE);
  address internal constant WA_CORE_USDT =
    address(AaveV4EthereumTokenizationSpokes.CORE_USDT_TOKENIZATION_SPOKE);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26248572);
    v4Proposal = new AaveV4Ethereum_MainnetGSMMigration_20261022();
    proposal = new AaveV3Ethereum_MainnetGSMMigration_20261022();

    // TODO: remove once the new GSMs and freezers are deployed and the placeholders replaced
    _deployNewGsmIfNeeded({
      oldGsm: GhoEthereum.GSM_USDC,
      oldFreezer: GhoEthereum.GSM_USDC_ORACLE_SWAP_FREEZER,
      newGsm: proposal.NEW_GSM_USDC(),
      newFreezer: proposal.NEW_USDC_ORACLE_SWAP_FREEZER(),
      newUnderlying: WA_CORE_USDC,
      newPriceStrategy: makeAddr('NEW_USDC_PRICE_STRATEGY')
    });
    _deployNewGsmIfNeeded({
      oldGsm: GhoEthereum.GSM_USDT,
      oldFreezer: GhoEthereum.GSM_USDT_ORACLE_SWAP_FREEZER,
      newGsm: proposal.NEW_GSM_USDT(),
      newFreezer: proposal.NEW_USDT_ORACLE_SWAP_FREEZER(),
      newUnderlying: WA_CORE_USDT,
      newPriceStrategy: makeAddr('NEW_USDT_PRICE_STRATEGY')
    });

    // The V4 payload executes first in the same proposal, raising the TokenizationSpoke add caps
    beforeV4PayloadSnapshot = vm.snapshotState();
    executePayload(vm, address(v4Proposal));
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_MainnetGSMMigration_20261022',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Ethereum.POOL, address(proposal), updatedAssets);
  }

  /**
   * @dev the USDT backing migration only fits in the Core USDT TokenizationSpoke after the V4 payload
   */
  function test_v4AddCapRaiseCoversUsdtMigration() public {
    uint256 usdtBacking = IERC4626(AaveV3EthereumAssets.USDT_STATA_TOKEN).previewRedeem(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDT)
    );
    assertGe(
      IERC4626(WA_CORE_USDT).maxDeposit(EXECUTOR),
      usdtBacking,
      'add cap too low for the migration'
    );

    vm.revertToState(beforeV4PayloadSnapshot);
    assertLt(
      IERC4626(WA_CORE_USDT).maxDeposit(EXECUTOR),
      usdtBacking,
      'migration fits without the V4 payload'
    );
  }

  /// --- Seize old GSMs ---

  function test_oldGsmFeesDistributedToTreasury() public {
    uint256 feesUsdc = IGsm(GhoEthereum.GSM_USDC).getAccruedFees();
    uint256 feesUsdt = IGsm(GhoEthereum.GSM_USDT).getAccruedFees();
    (uint256 excessUsdt, ) = IGsm4626(GhoEthereum.GSM_USDT).getCurrentBacking();
    assertGt(feesUsdc, 0, 'no USDC GSM fees to distribute');
    assertGt(feesUsdt, 0, 'no USDT GSM fees to distribute');
    assertEq(GHO.balanceOf(GhoEthereum.GSM_USDC), feesUsdc, 'USDC GSM GHO balance != fees');
    assertEq(GHO.balanceOf(GhoEthereum.GSM_USDT), feesUsdt, 'USDT GSM GHO balance != fees');

    uint256 collectorGhoBefore = GHO.balanceOf(COLLECTOR);
    uint256 usedUsdcBefore = GHO_RESERVE.getUsed(GhoEthereum.GSM_USDC);

    executePayload(vm, address(proposal));

    assertEq(IGsm(GhoEthereum.GSM_USDC).getAccruedFees(), 0, 'USDC GSM fees not distributed');
    assertEq(IGsm(GhoEthereum.GSM_USDT).getAccruedFees(), 0, 'USDT GSM fees not distributed');
    assertEq(GHO.balanceOf(GhoEthereum.GSM_USDC), 0, 'USDC GSM still holds GHO');
    assertEq(GHO.balanceOf(GhoEthereum.GSM_USDT), 0, 'USDT GSM still holds GHO');

    // Collector receives both GSMs' fees (+ USDT unbooked yield) and pays the USDC GSM used GHO
    // and the rounding shortfall of the USDT backing migration
    assertApproxEqAbs(
      GHO.balanceOf(COLLECTOR),
      collectorGhoBefore + feesUsdc + feesUsdt + excessUsdt - usedUsdcBefore,
      MIGRATION_ROUNDING_TOLERANCE,
      'unexpected collector GHO balance'
    );
  }

  function test_oldGsmsSeized() public {
    assertFalse(IGsm(GhoEthereum.GSM_USDC).getIsSeized(), 'USDC GSM seized before');
    assertFalse(IGsm(GhoEthereum.GSM_USDT).getIsSeized(), 'USDT GSM seized before');

    executePayload(vm, address(proposal));

    _assertSeized(GhoEthereum.GSM_USDC);
    _assertSeized(GhoEthereum.GSM_USDT);
  }

  function test_oldUsdcGsmUnderlyingSentToTreasury() public {
    uint256 gsmStata = IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(
      GhoEthereum.GSM_USDC
    );
    assertGt(gsmStata, 0, 'USDC GSM holds no stataUSDC');
    uint256 collectorStataBefore = IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(
      COLLECTOR
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDC),
      0,
      'USDC GSM still holds stataUSDC'
    );
    assertEq(
      IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(COLLECTOR),
      collectorStataBefore + gsmStata,
      'collector did not receive stataUSDC'
    );
  }

  /// --- Grant access to new GSMs ---

  function test_newGsmsRegisteredInGhoReserve() public {
    assertFalse(GHO_RESERVE.isEntity(proposal.NEW_GSM_USDC()), 'USDC GSM entity before');
    assertFalse(GHO_RESERVE.isEntity(proposal.NEW_GSM_USDT()), 'USDT GSM entity before');

    executePayload(vm, address(proposal));

    assertTrue(GHO_RESERVE.isEntity(proposal.NEW_GSM_USDC()), 'USDC GSM not an entity');
    assertTrue(GHO_RESERVE.isEntity(proposal.NEW_GSM_USDT()), 'USDT GSM not an entity');
    assertEq(
      GHO_RESERVE.getLimit(proposal.NEW_GSM_USDC()),
      proposal.RESERVE_LIMIT_GSM_USDC(),
      'wrong USDC GSM limit'
    );
    assertEq(
      GHO_RESERVE.getLimit(proposal.NEW_GSM_USDT()),
      proposal.RESERVE_LIMIT_GSM_USDT(),
      'wrong USDT GSM limit'
    );
  }

  function test_newGsmsInRegistry() public {
    assertFalse(_isInRegistry(proposal.NEW_GSM_USDC()), 'USDC GSM in registry before');
    assertFalse(_isInRegistry(proposal.NEW_GSM_USDT()), 'USDT GSM in registry before');

    executePayload(vm, address(proposal));

    assertTrue(_isInRegistry(proposal.NEW_GSM_USDC()), 'USDC GSM not in registry');
    assertTrue(_isInRegistry(proposal.NEW_GSM_USDT()), 'USDT GSM not in registry');
  }

  function test_newGsmRoles_USDC() public {
    _assertNewGsmRoles(IGsm(proposal.NEW_GSM_USDC()), proposal.NEW_USDC_ORACLE_SWAP_FREEZER());
  }

  function test_newGsmRoles_USDT() public {
    _assertNewGsmRoles(IGsm(proposal.NEW_GSM_USDT()), proposal.NEW_USDT_ORACLE_SWAP_FREEZER());
  }

  function test_newGsmConfig_USDC() public {
    executePayload(vm, address(proposal));

    _checkGsmConfig(
      IGsm(proposal.NEW_GSM_USDC()),
      WA_CORE_USDC,
      IOracleSwapFreezer(proposal.NEW_USDC_ORACLE_SWAP_FREEZER()),
      GsmConfig({
        sellFee: 0, // 0.00%
        buyFee: 0.0015e4, // 0.15%
        exposureCap: proposal.EXPOSURE_CAP_GSM_USDC(),
        reserveLimit: proposal.RESERVE_LIMIT_GSM_USDC(),
        freezerCanUnfreeze: true,
        freezeLowerBound: 0.99e8,
        freezeUpperBound: 1.01e8,
        unfreezeLowerBound: 0.995e8,
        unfreezeUpperBound: 1.005e8
      })
    );
  }

  function test_newGsmConfig_USDT() public {
    executePayload(vm, address(proposal));

    _checkGsmConfig(
      IGsm(proposal.NEW_GSM_USDT()),
      WA_CORE_USDT,
      IOracleSwapFreezer(proposal.NEW_USDT_ORACLE_SWAP_FREEZER()),
      GsmConfig({
        sellFee: 0, // 0.00%
        buyFee: 0.0010e4, // 0.10%
        exposureCap: proposal.EXPOSURE_CAP_GSM_USDT(),
        reserveLimit: proposal.RESERVE_LIMIT_GSM_USDT(),
        freezerCanUnfreeze: true,
        freezeLowerBound: 0.99e8,
        freezeUpperBound: 1.01e8,
        unfreezeLowerBound: 0.995e8,
        unfreezeUpperBound: 1.005e8
      })
    );
  }

  /// --- Update fee strategies ---

  function test_newGsmsReuseOldFeeStrategies() public {
    address usdcFeeStrategy = IGsm(GhoEthereum.GSM_USDC).getFeeStrategy();
    address usdtFeeStrategy = IGsm(GhoEthereum.GSM_USDT).getFeeStrategy();
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getFeeStrategy(), address(0), 'USDC fee set before');
    assertEq(IGsm(proposal.NEW_GSM_USDT()).getFeeStrategy(), address(0), 'USDT fee set before');

    executePayload(vm, address(proposal));

    assertEq(
      IGsm(proposal.NEW_GSM_USDC()).getFeeStrategy(),
      usdcFeeStrategy,
      'wrong USDC fee strategy'
    );
    assertEq(
      IGsm(proposal.NEW_GSM_USDT()).getFeeStrategy(),
      usdtFeeStrategy,
      'wrong USDT fee strategy'
    );
  }

  /// --- Migrate USDT backing ---

  function test_usdtBackingMigratedToNewGsm() public {
    uint256 seizedStata = IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(
      GhoEthereum.GSM_USDT
    );
    uint256 usdtBacking = IERC4626(AaveV3EthereumAssets.USDT_STATA_TOKEN).previewRedeem(
      seizedStata
    );
    uint256 expectedShares = IERC4626(WA_CORE_USDT).previewDeposit(usdtBacking);
    uint256 collectorStataBefore = IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(
      COLLECTOR
    );
    assertEq(IGsm(proposal.NEW_GSM_USDT()).getAvailableLiquidity(), 0, 'USDT GSM not empty');

    executePayload(vm, address(proposal));

    // The seized stataUSDT is fully redeemed, so the Collector balance is unchanged
    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDT),
      0,
      'old USDT GSM still holds stataUSDT'
    );
    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(COLLECTOR),
      collectorStataBefore,
      'stataUSDT left in the collector'
    );

    // All shares minted for the redeemed USDT end up in the new GSM
    assertEq(
      IGsm(proposal.NEW_GSM_USDT()).getAvailableLiquidity(),
      expectedShares,
      'wrong new USDT GSM exposure'
    );
    assertEq(
      IERC20(WA_CORE_USDT).balanceOf(proposal.NEW_GSM_USDT()),
      expectedShares,
      'wrong new USDT GSM share balance'
    );
  }

  function test_usdtBackingMovedFromV3ToV4() public {
    uint256 usdtBacking = IERC4626(AaveV3EthereumAssets.USDT_STATA_TOKEN).previewRedeem(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDT)
    );
    IHub hub = IHub(address(AaveV4EthereumHubs.CORE_HUB));
    uint256 assetId = IWaToken(WA_CORE_USDT).assetId();
    uint256 hubAddedBefore = hub.getAddedAssets(assetId);
    uint256 spokeAddedBefore = hub.getSpokeAddedAssets(assetId, WA_CORE_USDT);
    uint256 v3UsdtCashBefore = IERC20(AaveV3EthereumAssets.USDT_UNDERLYING).balanceOf(
      AaveV3EthereumAssets.USDT_A_TOKEN
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_UNDERLYING).balanceOf(AaveV3EthereumAssets.USDT_A_TOKEN),
      v3UsdtCashBefore - usdtBacking,
      'USDT not withdrawn from V3'
    );
    // Hub accounting rounds down on deposit
    assertApproxEqAbs(
      hub.getAddedAssets(assetId),
      hubAddedBefore + usdtBacking,
      1,
      'USDT not added to the V4 Core Hub'
    );
    assertApproxEqAbs(
      hub.getSpokeAddedAssets(assetId, WA_CORE_USDT),
      spokeAddedBefore + usdtBacking,
      1,
      'USDT not added through the Core USDT TokenizationSpoke'
    );
  }

  function test_usdtGhoUsageMovedToNewGsm() public {
    uint256 oldUsed = GHO_RESERVE.getUsed(GhoEthereum.GSM_USDT);
    (uint256 excess, ) = IGsm4626(GhoEthereum.GSM_USDT).getCurrentBacking();
    assertEq(GHO_RESERVE.getUsed(proposal.NEW_GSM_USDT()), 0, 'new USDT GSM used before');

    executePayload(vm, address(proposal));

    // The new GSM draws the GHO backed by the migrated USDT, which includes the yield booked as fees
    assertApproxEqAbs(
      GHO_RESERVE.getUsed(proposal.NEW_GSM_USDT()),
      oldUsed + excess,
      MIGRATION_ROUNDING_TOLERANCE,
      'wrong new USDT GSM used'
    );
    (uint256 newExcess, uint256 newDeficit) = IGsm4626(proposal.NEW_GSM_USDT()).getCurrentBacking();
    assertEq(newExcess, 0, 'new USDT GSM has excess backing');
    assertEq(newDeficit, 0, 'new USDT GSM has deficit backing');
  }

  function test_ghoSupplyUnchangedAndReserveRestored() public {
    uint256 ghoSupplyBefore = GHO.totalSupply();
    uint256 reserveBalanceBefore = GHO.balanceOf(address(GHO_RESERVE));
    uint256 usedUsdc = GHO_RESERVE.getUsed(GhoEthereum.GSM_USDC);
    (uint256 excessUsdt, ) = IGsm4626(GhoEthereum.GSM_USDT).getCurrentBacking();
    assertGt(excessUsdt, 0, 'no unbooked USDT GSM yield');

    executePayload(vm, address(proposal));

    assertEq(GHO.totalSupply(), ghoSupplyBefore, 'GHO supply changed');
    // The USDT backing moves between GSMs (use + restore) and the USDC GSM used GHO is restored.
    // The unbooked USDT GSM yield is drawn from the reserve and distributed as fees.
    assertApproxEqAbs(
      GHO.balanceOf(address(GHO_RESERVE)),
      reserveBalanceBefore + usedUsdc - excessUsdt,
      MIGRATION_ROUNDING_TOLERANCE,
      'unexpected GhoReserve GHO balance'
    );
  }

  function test_executorHoldsNoTokensAfterExecution() public {
    executePayload(vm, address(proposal));

    assertEq(GHO.balanceOf(EXECUTOR), 0, 'executor holds GHO');
    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(EXECUTOR),
      0,
      'executor holds stataUSDT'
    );
    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_UNDERLYING).balanceOf(EXECUTOR),
      0,
      'executor holds USDT'
    );
    assertEq(IERC20(WA_CORE_USDT).balanceOf(EXECUTOR), 0, 'executor holds waCoreUSDT');
    assertEq(
      IERC20(AaveV3EthereumAssets.LINK_UNDERLYING).balanceOf(EXECUTOR),
      0,
      'executor holds LINK'
    );
  }

  /// --- Burn after seize ---

  function test_oldGsmsUsedGhoRestored() public {
    assertGt(GHO_RESERVE.getUsed(GhoEthereum.GSM_USDC), 0, 'USDC GSM used is zero before');
    assertGt(GHO_RESERVE.getUsed(GhoEthereum.GSM_USDT), 0, 'USDT GSM used is zero before');

    executePayload(vm, address(proposal));

    assertEq(GHO_RESERVE.getUsed(GhoEthereum.GSM_USDC), 0, 'USDC GSM used not restored');
    assertEq(GHO_RESERVE.getUsed(GhoEthereum.GSM_USDT), 0, 'USDT GSM used not restored');
  }

  /// --- New OracleSwapFreezers ---

  function test_oracleSwapFreezers_USDC() public {
    _assertOracleSwapFreezer(
      IGsm(proposal.NEW_GSM_USDC()),
      IOracleSwapFreezer(proposal.NEW_USDC_ORACLE_SWAP_FREEZER()),
      AaveV3EthereumAssets.USDC_UNDERLYING
    );
  }

  function test_oracleSwapFreezers_USDT() public {
    _assertOracleSwapFreezer(
      IGsm(proposal.NEW_GSM_USDT()),
      IOracleSwapFreezer(proposal.NEW_USDT_ORACLE_SWAP_FREEZER()),
      AaveV3EthereumAssets.USDT_UNDERLYING
    );
  }

  /// --- Revoke access of old GSMs ---

  function test_oldGsmsRemovedFromGhoReserve() public {
    assertTrue(GHO_RESERVE.isEntity(GhoEthereum.GSM_USDC), 'USDC GSM not an entity before');
    assertTrue(GHO_RESERVE.isEntity(GhoEthereum.GSM_USDT), 'USDT GSM not an entity before');
    uint256 totalEntitiesBefore = GHO_RESERVE.totalEntities();

    executePayload(vm, address(proposal));

    assertFalse(GHO_RESERVE.isEntity(GhoEthereum.GSM_USDC), 'USDC GSM still an entity');
    assertFalse(GHO_RESERVE.isEntity(GhoEthereum.GSM_USDT), 'USDT GSM still an entity');
    assertEq(GHO_RESERVE.getLimit(GhoEthereum.GSM_USDC), 0, 'USDC GSM limit not zero');
    assertEq(GHO_RESERVE.getLimit(GhoEthereum.GSM_USDT), 0, 'USDT GSM limit not zero');
    // 2 old GSMs replaced by 2 new GSMs
    assertEq(GHO_RESERVE.totalEntities(), totalEntitiesBefore, 'wrong total entities');
  }

  function test_oldGsmsRemovedFromRegistry() public {
    assertTrue(_isInRegistry(GhoEthereum.GSM_USDC), 'USDC GSM not in registry before');
    assertTrue(_isInRegistry(GhoEthereum.GSM_USDT), 'USDT GSM not in registry before');
    uint256 lengthBefore = IGsmRegistry(GhoEthereum.GSM_REGISTRY).getGsmListLength();

    executePayload(vm, address(proposal));

    assertFalse(_isInRegistry(GhoEthereum.GSM_USDC), 'USDC GSM still in registry');
    assertFalse(_isInRegistry(GhoEthereum.GSM_USDT), 'USDT GSM still in registry');
    assertEq(
      IGsmRegistry(GhoEthereum.GSM_REGISTRY).getGsmListLength(),
      lengthBefore,
      'wrong registry length'
    );
  }

  function test_oldGsmRolesRevoked_USDC() public {
    _assertOldGsmRolesRevoked(GhoEthereum.GSM_USDC, GhoEthereum.GSM_USDC_ORACLE_SWAP_FREEZER);
  }

  function test_oldGsmRolesRevoked_USDT() public {
    _assertOldGsmRolesRevoked(GhoEthereum.GSM_USDT, GhoEthereum.GSM_USDT_ORACLE_SWAP_FREEZER);
  }

  /**
   * @dev the existing keepers were cancelled by the Chainlink Automation registry owner and still hold
   * the LINK funded at registration
   */
  function test_oldOracleSwapFreezerKeepersLinkWithdrawn() public {
    IAaveCLRobotOperator operator = IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR);
    IERC20 link = IERC20(AaveV3EthereumAssets.LINK_UNDERLYING);
    assertEq(
      _keeperIdOf(GhoEthereum.GSM_USDC_ORACLE_SWAP_FREEZER),
      proposal.EXISTING_ORACLE_SWAP_FREEZER_USDC(),
      'wrong existing USDC keeper id'
    );
    assertEq(
      _keeperIdOf(GhoEthereum.GSM_USDT_ORACLE_SWAP_FREEZER),
      proposal.EXISTING_ORACLE_SWAP_FREEZER_USDT(),
      'wrong existing USDT keeper id'
    );
    uint256 collectorLinkBefore = link.balanceOf(COLLECTOR);

    executePayload(vm, address(proposal));

    assertEq(
      link.balanceOf(COLLECTOR),
      collectorLinkBefore + KEEPERS_REMAINING_LINK,
      'keepers LINK not withdrawn to the collector'
    );

    // Keepers are drained: withdrawing again sends nothing
    operator.withdrawLink(proposal.EXISTING_ORACLE_SWAP_FREEZER_USDC());
    operator.withdrawLink(proposal.EXISTING_ORACLE_SWAP_FREEZER_USDT());
    assertEq(
      link.balanceOf(COLLECTOR),
      collectorLinkBefore + KEEPERS_REMAINING_LINK,
      'keepers still hold LINK'
    );
  }

  /// --- Post-execution behaviour ---

  function test_oldGsmsUnusable() public {
    executePayload(vm, address(proposal));

    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDC).buyAsset(1e6, address(this));
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDT).buyAsset(1e6, address(this));
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDC).sellAsset(1e6, address(this));
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDT).sellAsset(1e6, address(this));
  }

  function test_newGsmOperational_USDC() public {
    _assertNewGsmOperational(
      IGsm(proposal.NEW_GSM_USDC()),
      AaveV3EthereumAssets.USDC_UNDERLYING,
      100_000e6
    );
  }

  function test_newGsmOperational_USDT() public {
    _assertNewGsmOperational(
      IGsm(proposal.NEW_GSM_USDT()),
      AaveV3EthereumAssets.USDT_UNDERLYING,
      100_000e6
    );
  }

  /**
   * @dev a buyer of the migrated backing can redeem the V4 shares for USDT while the Hub has liquidity
   */
  function test_migratedUsdtBackingRedeemable() public {
    executePayload(vm, address(proposal));

    IGsm gsm = IGsm(proposal.NEW_GSM_USDT());
    uint256 sharesToBuy = 1_000_000e6;
    (, uint256 ghoNeeded, , ) = gsm.getGhoAmountForBuyAsset(sharesToBuy);
    deal(address(GHO), address(this), ghoNeeded);
    GHO.approve(address(gsm), ghoNeeded);
    (uint256 sharesBought, ) = gsm.buyAsset(sharesToBuy, address(this));

    uint256 expectedUsdt = IERC4626(WA_CORE_USDT).previewRedeem(sharesBought);
    uint256 usdtBefore = IERC20(AaveV3EthereumAssets.USDT_UNDERLYING).balanceOf(address(this));
    IERC4626(WA_CORE_USDT).redeem(sharesBought, address(this), address(this));

    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_UNDERLYING).balanceOf(address(this)),
      usdtBefore + expectedUsdt,
      'USDT not redeemed from the V4 Core Hub'
    );
  }

  function test_ghoGsmStewardCanUpdateExposureCap_USDC() public {
    _assertStewardCanUpdateExposureCap(IGsm(proposal.NEW_GSM_USDC()));
  }

  function test_ghoGsmStewardCanUpdateExposureCap_USDT() public {
    _assertStewardCanUpdateExposureCap(IGsm(proposal.NEW_GSM_USDT()));
  }

  function test_ghoGsmStewardCanUpdateFees_USDC() public {
    _assertStewardCanUpdateFees(IGsm(proposal.NEW_GSM_USDC()));
  }

  function test_ghoGsmStewardCanUpdateFees_USDT() public {
    _assertStewardCanUpdateFees(IGsm(proposal.NEW_GSM_USDT()));
  }

  /// --- Helpers ---

  function _assertSeized(address gsm) internal view {
    assertTrue(IGsm(gsm).getIsSeized(), 'GSM not seized');
    assertEq(IGsm(gsm).getExposureCap(), 0, 'seized GSM exposure cap not zero');
    assertEq(IGsm(gsm).getAvailableLiquidity(), 0, 'seized GSM exposure not zero');
    assertEq(
      IERC20(IGsm(gsm).UNDERLYING_ASSET()).balanceOf(gsm),
      0,
      'seized GSM still holds underlying'
    );
  }

  function _assertNewGsmRoles(IGsm gsm, address freezer) internal {
    assertFalse(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), freezer), 'freezer role before');
    assertFalse(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), EXECUTOR), 'executor freezer role before');
    assertFalse(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GhoEthereum.GHO_GSM_STEWARD),
      'steward role before'
    );

    executePayload(vm, address(proposal));

    assertTrue(gsm.hasRole(bytes32(0), EXECUTOR), 'executor is not admin');
    assertTrue(gsm.hasRole(gsm.CONFIGURATOR_ROLE(), EXECUTOR), 'executor is not configurator');
    assertTrue(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), EXECUTOR), 'executor is not swap freezer');
    assertTrue(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), freezer), 'freezer is not swap freezer');
    assertTrue(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GhoEthereum.GHO_GSM_STEWARD),
      'steward is not configurator'
    );
    // No need to be liquidator or token rescuer at the beginning
    assertFalse(gsm.hasRole(gsm.LIQUIDATOR_ROLE(), EXECUTOR), 'executor is liquidator');
    assertFalse(gsm.hasRole(gsm.TOKEN_RESCUER_ROLE(), EXECUTOR), 'executor is token rescuer');
  }

  function _checkGsmConfig(
    IGsm gsm,
    address underlying,
    IOracleSwapFreezer freezer,
    GsmConfig memory config
  ) internal view {
    assertEq(gsm.UNDERLYING_ASSET(), underlying, 'wrong underlying asset');
    assertEq(gsm.GHO_TOKEN(), address(GHO), 'wrong GHO token');
    assertEq(gsm.getGhoReserve(), address(GHO_RESERVE), 'wrong GHO reserve');
    assertEq(gsm.getGhoTreasury(), COLLECTOR, 'wrong GHO treasury');
    assertEq(gsm.getExposureCap(), config.exposureCap, 'wrong exposure cap');
    assertEq(GHO_RESERVE.getLimit(address(gsm)), config.reserveLimit, 'wrong reserve limit');
    assertFalse(gsm.getIsFrozen(), 'GSM frozen');
    assertFalse(gsm.getIsSeized(), 'GSM seized');

    // Fee Strategy
    IGsmFeeStrategy feeStrategy = IGsmFeeStrategy(gsm.getFeeStrategy());
    assertEq(feeStrategy.getSellFee(1e4), config.sellFee, 'wrong sell fee');
    assertEq(feeStrategy.getBuyFee(1e4), config.buyFee, 'wrong buy fee');

    // Price Strategy: 1:1 against the ERC-4626 share value
    IFixedPriceStrategy4626 priceStrategy = IFixedPriceStrategy4626(gsm.PRICE_STRATEGY());
    assertEq(
      priceStrategy.getAssetPriceInGho(1e6, true),
      IERC4626(underlying).previewMint(1e6) * 1e12,
      'wrong asset price in GHO (round up)'
    );
    assertEq(
      priceStrategy.getAssetPriceInGho(1e6, false),
      IERC4626(underlying).convertToAssets(1e6) * 1e12,
      'wrong asset price in GHO (round down)'
    );
    assertEq(
      priceStrategy.getGhoPriceInAsset(1 ether, true),
      IERC4626(underlying).previewWithdraw(1e6),
      'wrong GHO price in asset (round up)'
    );
    assertEq(
      priceStrategy.getGhoPriceInAsset(1 ether, false),
      IERC4626(underlying).convertToShares(1e6),
      'wrong GHO price in asset (round down)'
    );

    // Oracle freezer
    assertEq(freezer.GSM(), address(gsm), 'wrong freezer GSM');
    assertEq(
      freezer.ADDRESS_PROVIDER(),
      address(AaveV3Ethereum.POOL_ADDRESSES_PROVIDER),
      'wrong freezer address provider'
    );
    assertEq(freezer.getCanUnfreeze(), config.freezerCanUnfreeze, 'wrong freezer unfreeze flag');
    (uint256 lowerBound, uint256 upperBound) = freezer.getFreezeBound();
    assertEq(lowerBound, config.freezeLowerBound, 'wrong freeze lower bound');
    assertEq(upperBound, config.freezeUpperBound, 'wrong freeze upper bound');
    (lowerBound, upperBound) = freezer.getUnfreezeBound();
    assertEq(lowerBound, config.unfreezeLowerBound, 'wrong unfreeze lower bound');
    assertEq(upperBound, config.unfreezeUpperBound, 'wrong unfreeze upper bound');
  }

  function _assertOracleSwapFreezer(
    IGsm gsm,
    IOracleSwapFreezer freezer,
    address oracleAsset
  ) internal {
    (uint128 freezeLowerBound, ) = freezer.getFreezeBound();
    (uint128 unfreezeLowerBound, ) = freezer.getUnfreezeBound();
    _mockAssetPrice(oracleAsset, freezeLowerBound - 1);

    // Freezer cannot freeze without authorization
    (bool canPerformUpkeep, ) = freezer.checkUpkeep('');
    assertFalse(canPerformUpkeep, 'freezer can act before execution');

    executePayload(vm, address(proposal));

    // Depeg freezes the GSM
    (canPerformUpkeep, ) = freezer.checkUpkeep('');
    assertTrue(canPerformUpkeep, 'freezer cannot freeze on depeg');
    freezer.performUpkeep('');
    assertTrue(gsm.getIsFrozen(), 'GSM not frozen on depeg');

    // Price back inside the unfreeze bounds unfreezes the GSM
    _mockAssetPrice(oracleAsset, unfreezeLowerBound + 1);
    (canPerformUpkeep, ) = freezer.checkUpkeep('');
    assertTrue(canPerformUpkeep, 'freezer cannot unfreeze on repeg');
    freezer.performUpkeep('');
    assertFalse(gsm.getIsFrozen(), 'GSM not unfrozen on repeg');
  }

  function _assertOldGsmRolesRevoked(address gsm, address oldFreezer) internal {
    bytes32 swapFreezerRole = proposal.SWAP_FREEZER_ROLE();
    bytes32 configuratorRole = proposal.CONFIGURATOR_ROLE();
    assertTrue(IGsm(gsm).hasRole(swapFreezerRole, oldFreezer), 'freezer role missing before');
    assertTrue(IGsm(gsm).hasRole(swapFreezerRole, EXECUTOR), 'executor freezer missing before');
    assertTrue(
      IGsm(gsm).hasRole(configuratorRole, GhoEthereum.GHO_GSM_STEWARD),
      'steward role missing before'
    );

    executePayload(vm, address(proposal));

    assertFalse(IGsm(gsm).hasRole(swapFreezerRole, oldFreezer), 'freezer role not revoked');
    assertFalse(IGsm(gsm).hasRole(swapFreezerRole, EXECUTOR), 'executor freezer not revoked');
    assertFalse(
      IGsm(gsm).hasRole(proposal.LIQUIDATOR_ROLE(), EXECUTOR),
      'executor liquidator not revoked'
    );
    assertFalse(
      IGsm(gsm).hasRole(configuratorRole, GhoEthereum.GHO_GSM_STEWARD),
      'steward role not revoked'
    );
  }

  function _assertNewGsmOperational(IGsm gsm, address asset, uint256 assetAmount) internal {
    executePayload(vm, address(proposal));

    address share = gsm.UNDERLYING_ASSET();
    deal(asset, address(this), assetAmount);
    IERC20(asset).forceApprove(share, assetAmount);
    uint256 shares = IERC4626(share).deposit(assetAmount, address(this));

    uint256 gsmSharesBefore = IERC20(share).balanceOf(address(gsm));
    uint256 usedBefore = GHO_RESERVE.getUsed(address(gsm));

    // Sell: shares in, GHO out at the share value (no sell fee)
    IERC20(share).forceApprove(address(gsm), shares);
    (uint256 sharesSold, uint256 ghoBought) = gsm.sellAsset(shares, address(this));
    assertEq(sharesSold, shares, 'not all shares sold');
    assertEq(ghoBought, IERC4626(share).previewRedeem(shares) * 1e12, 'wrong GHO bought');
    assertEq(GHO.balanceOf(address(this)), ghoBought, 'GHO not received');
    assertEq(IERC20(share).balanceOf(address(gsm)), gsmSharesBefore + shares, 'shares not in GSM');
    assertEq(GHO_RESERVE.getUsed(address(gsm)), usedBefore + ghoBought, 'GSM used not increased');

    // Buy: GHO in (with buy fee), shares out
    uint256 sharesToBuy = shares / 2;
    (, uint256 ghoNeeded, , uint256 fee) = gsm.getGhoAmountForBuyAsset(sharesToBuy);
    assertGt(fee, 0, 'no buy fee charged');
    GHO.approve(address(gsm), ghoNeeded);
    (uint256 sharesBought, uint256 ghoSold) = gsm.buyAsset(sharesToBuy, address(this));
    assertEq(sharesBought, sharesToBuy, 'wrong shares bought');
    assertEq(ghoSold, ghoNeeded, 'wrong GHO sold');
    assertEq(IERC20(share).balanceOf(address(this)), sharesToBuy, 'shares not received');
    assertEq(GHO.balanceOf(address(this)), ghoBought - ghoSold, 'GHO not paid');
  }

  function _assertStewardCanUpdateExposureCap(IGsm gsm) internal {
    executePayload(vm, address(proposal));

    uint128 newExposureCap = gsm.getExposureCap() + 1;
    vm.prank(GhoEthereum.RISK_COUNCIL);
    IGsmSteward(GhoEthereum.GHO_GSM_STEWARD).updateGsmExposureCap(address(gsm), newExposureCap);
    assertEq(gsm.getExposureCap(), newExposureCap, 'steward could not update exposure cap');
  }

  function _assertStewardCanUpdateFees(IGsm gsm) internal {
    executePayload(vm, address(proposal));

    IGsmFeeStrategy feeStrategy = IGsmFeeStrategy(gsm.getFeeStrategy());
    uint256 buyFee = feeStrategy.getBuyFee(1e4);
    uint256 sellFee = feeStrategy.getSellFee(1e4);

    vm.prank(GhoEthereum.RISK_COUNCIL);
    IGsmSteward(GhoEthereum.GHO_GSM_STEWARD).updateGsmBuySellFees(
      address(gsm),
      buyFee + 1,
      sellFee
    );
    assertEq(
      IGsmFeeStrategy(gsm.getFeeStrategy()).getBuyFee(1e4),
      buyFee + 1,
      'steward could not update fees'
    );
  }

  function _isInRegistry(address gsm) internal returns (bool) {
    IGsmRegistry registry = IGsmRegistry(GhoEthereum.GSM_REGISTRY);
    uint256 length = registry.getGsmListLength();
    for (uint256 i; i < length; ++i) {
      if (registry.getGsmAtIndex(i) == gsm) return true;
    }
    return false;
  }

  /// @dev returns the active robot operator keeper id of an upkeep contract, 0 if none
  function _keeperIdOf(address upkeep) internal view returns (uint256) {
    IAaveCLRobotOperator operator = IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR);
    uint256[] memory ids = operator.getKeepersList();
    for (uint256 i; i < ids.length; ++i) {
      if (operator.getKeeperInfo(ids[i]).upkeep == upkeep) return ids[i];
    }
    return 0;
  }

  function _mockAssetPrice(address asset, uint256 price) internal {
    vm.mockCall(
      address(AaveV3Ethereum.ORACLE),
      abi.encodeWithSelector(IPriceOracleGetter.getAssetPrice.selector, asset),
      abi.encode(price)
    );
  }

  /**
   * @dev Stand-in for the not-yet-deployed contracts: places the live mainnet bytecode of the current
   * Gsm4626 implementation, its FixedPriceStrategy4626 and its ChainlinkOracleSwapFreezer at the
   * payload placeholders, with the immutables pointing at the new underlying, price strategy and GSM.
   * The GSM is initialized as the deployment script does (Executor admin, Collector treasury,
   * zero exposure cap, current GhoReserve). Skipped once real code exists at the placeholder.
   * TODO: remove once the placeholders are replaced with deployed addresses
   */
  function _deployNewGsmIfNeeded(
    address oldGsm,
    address oldFreezer,
    address newGsm,
    address newFreezer,
    address newUnderlying,
    address newPriceStrategy
  ) internal {
    if (newGsm.code.length != 0) return;

    address oldUnderlying = IGsm(oldGsm).UNDERLYING_ASSET();
    address oldPriceStrategy = IGsm(oldGsm).PRICE_STRATEGY();
    address oldImplementation = address(uint160(uint256(vm.load(oldGsm, IMPLEMENTATION_SLOT))));

    vm.etch(newPriceStrategy, _replaceWord(oldPriceStrategy.code, oldUnderlying, newUnderlying));

    bytes memory gsmCode = _replaceWord(oldImplementation.code, oldUnderlying, newUnderlying);
    vm.etch(newGsm, _replaceWord(gsmCode, oldPriceStrategy, newPriceStrategy));
    IGsmInitializable(newGsm).initialize(EXECUTOR, COLLECTOR, 0, address(GHO_RESERVE));

    vm.etch(newFreezer, _replaceWord(oldFreezer.code, oldGsm, newGsm));
  }

  /// @dev replaces every 32-byte occurrence of `from` with `to` in `code`; reverts if there is none
  function _replaceWord(
    bytes memory code,
    address from,
    address to
  ) internal pure returns (bytes memory) {
    bytes32 fromWord = bytes32(uint256(uint160(from)));
    bytes32 toWord = bytes32(uint256(uint160(to)));
    uint256 replaced;
    for (uint256 i = 32; i <= code.length; ++i) {
      bytes32 word;
      assembly {
        word := mload(add(code, i))
      }
      if (word == fromWord) {
        assembly {
          mstore(add(code, i), toWord)
        }
        ++replaced;
      }
    }
    require(replaced > 0, 'immutable not found in bytecode');
    return code;
  }
}

interface IGsm4626 {
  function getCurrentBacking() external view returns (uint256, uint256);
}

interface IGsmInitializable {
  function initialize(
    address admin,
    address ghoTreasury,
    uint128 exposureCap,
    address ghoReserve
  ) external;
}

interface IWaToken {
  function assetId() external view returns (uint256);
}
