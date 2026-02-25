// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {IAaveOracle} from 'aave-address-book/AaveV2.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmFeeStrategy} from 'src/interfaces/IGsmFeeStrategy.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IGsmSteward} from 'src/interfaces/IGsmSteward.sol';
import {IGhoBucketSteward} from 'src/interfaces/IGhoBucketSteward.sol';
import {IAaveCLRobotOperator} from 'src/interfaces/IAaveCLRobotOperator.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IGhoDirectFacilitator} from 'src/interfaces/IGhoDirectFacilitator.sol';

import {AaveV3Ethereum_GSMMigration_20251113} from './AaveV3Ethereum_GSMMigration_20251113.sol';

/**
 * @dev Test for AaveV3Ethereum_GSMMigration_20251113
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20251113_AaveV3Ethereum_GSMMigration/AaveV3Ethereum_GSMMigration_20251113.t.sol -vv
 */
contract AaveV3Ethereum_GSMMigration_20251113_Test is ProtocolV3TestBase {
  AaveV3Ethereum_GSMMigration_20251113 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 24347697);
    proposal = new AaveV3Ethereum_GSMMigration_20251113();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV3Ethereum_GSMMigration_20251113', AaveV3Ethereum.POOL, address(proposal));
  }

  function test_checkConfig() public {
    assertFalse(
      IGhoBucketSteward(GhoEthereum.GHO_BUCKET_STEWARD).isControlledFacilitator(
        proposal.DIRECT_FACILITATOR()
      )
    );

    uint256 facilitatorListLengthBefore = IGhoToken(GhoEthereum.GHO_TOKEN)
      .getFacilitatorsList()
      .length;

    IGhoToken.Facilitator memory oldGsmUsdc = IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitator(
      GhoEthereum.GSM_USDC
    );

    IGhoToken.Facilitator memory oldGsmUsdt = IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitator(
      GhoEthereum.GSM_USDT
    );

    assertEq(IGhoReserve(proposal.GHO_RESERVE()).totalEntities(), 0);

    executePayload(vm, address(proposal));

    assertTrue(
      IGhoBucketSteward(GhoEthereum.GHO_BUCKET_STEWARD).isControlledFacilitator(
        proposal.DIRECT_FACILITATOR()
      )
    );

    // We replace 2 GSMs as facilitators with only the GhoDirectFacilitator
    assertTrue(
      IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitatorsList().length ==
        facilitatorListLengthBefore - 1
    );

    assertEq(IGhoReserve(proposal.GHO_RESERVE()).totalEntities(), 2);

    // USDC
    uint256 limit = IGhoReserve(proposal.GHO_RESERVE()).getLimit(proposal.NEW_GSM_USDC());
    assertEq(limit, proposal.RESERVE_LIMIT_GSM_USDC());

    (uint256 excess, uint256 deficit) = IGsm4626(proposal.NEW_GSM_USDC()).getCurrentBacking();
    assertEq(excess, 0);
    assertEq(deficit, 0);

    // Asset price in GHO has changed from previous migration
    assertApproxEqAbs(
      IGhoReserve(proposal.GHO_RESERVE()).getUsed(proposal.NEW_GSM_USDC()),
      oldGsmUsdc.bucketLevel,
      50_000 ether,
      'Delta for GHO needed on stataUSDC is too wide'
    );

    // USDT
    limit = IGhoReserve(proposal.GHO_RESERVE()).getLimit(proposal.NEW_GSM_USDT());
    assertEq(limit, proposal.RESERVE_LIMIT_GSM_USDT());
    (excess, deficit) = IGsm4626(proposal.NEW_GSM_USDT()).getCurrentBacking();
    assertEq(excess, 0);
    assertEq(deficit, 0);

    // Asset price in GHO has changed from previous migration
    assertApproxEqAbs(
      IGhoReserve(proposal.GHO_RESERVE()).getUsed(proposal.NEW_GSM_USDT()),
      oldGsmUsdt.bucketLevel,
      50_000 ether,
      'Delta for GHO needed on stataUSDT is too wide'
    );

    // GSM USDC
    GsmConfig memory gsmUsdcConfig = GsmConfig({
      sellFee: 0, // 0.00%
      buyFee: 0.0008e4, // 0.08%
      exposureCap: 87_000_000e6,
      isFrozen: false,
      isSeized: false,
      freezerCanUnfreeze: true,
      freezeLowerBound: 0.99e8,
      freezeUpperBound: 1.01e8,
      unfreezeLowerBound: 0.995e8,
      unfreezeUpperBound: 1.005e8
    });
    _checkGsmConfig(
      IGsm(proposal.NEW_GSM_USDC()),
      AaveV3EthereumAssets.USDC_STATA_TOKEN,
      IOracleSwapFreezer(proposal.USDC_ORACLE_SWAP_FREEZER()),
      gsmUsdcConfig
    );

    // GSM USDT
    GsmConfig memory gsmUsdtConfig = GsmConfig({
      sellFee: 0, // 0.00%
      buyFee: 0.0010e4, // 0.10%
      exposureCap: 55_000_000e6,
      isFrozen: false,
      isSeized: false,
      freezerCanUnfreeze: true,
      freezeLowerBound: 0.99e8,
      freezeUpperBound: 1.01e8,
      unfreezeLowerBound: 0.995e8,
      unfreezeUpperBound: 1.005e8
    });
    _checkGsmConfig(
      IGsm(proposal.NEW_GSM_USDT()),
      AaveV3EthereumAssets.USDT_STATA_TOKEN,
      IOracleSwapFreezer(proposal.USDT_ORACLE_SWAP_FREEZER()),
      gsmUsdtConfig
    );
  }

  function test_checkOldGSMsDisabled() public {
    executePayload(vm, address(proposal));

    assertTrue(IGsm(GhoEthereum.GSM_USDC).getIsSeized());
    assertTrue(IGsm(GhoEthereum.GSM_USDT).getIsSeized());

    assertEq(IERC20(GhoEthereum.GHO_TOKEN).balanceOf(GhoEthereum.GSM_USDC), 0);
    assertEq(IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDC), 0);

    assertEq(IERC20(GhoEthereum.GHO_TOKEN).balanceOf(GhoEthereum.GSM_USDT), 0);
    assertEq(IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDT), 0);

    IGhoToken.Facilitator memory oldGsmUsdc = IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitator(
      GhoEthereum.GSM_USDC
    );

    assertEq(oldGsmUsdc.bucketCapacity, 0);
    assertEq(oldGsmUsdc.bucketLevel, 0);

    IGhoToken.Facilitator memory oldGsmUsdt = IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitator(
      GhoEthereum.GSM_USDT
    );

    assertEq(oldGsmUsdt.bucketCapacity, 0);
    assertEq(oldGsmUsdt.bucketLevel, 0);

    assertEq(IGsm(GhoEthereum.GSM_USDC).getAvailableUnderlyingExposure(), 0, 'wrong exposure cap');
    assertEq(IGsm(GhoEthereum.GSM_USDT).getAvailableUnderlyingExposure(), 0, 'wrong exposure cap');

    assertFalse(
      IGsm(GhoEthereum.GSM_USDC).hasRole(
        proposal.SWAP_FREEZER_ROLE(),
        GhoEthereum.GSM_USDC_ORACLE_SWAP_FREEZER
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDT).hasRole(
        proposal.SWAP_FREEZER_ROLE(),
        GhoEthereum.GSM_USDT_ORACLE_SWAP_FREEZER
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDC).hasRole(
        proposal.SWAP_FREEZER_ROLE(),
        GovernanceV3Ethereum.EXECUTOR_LVL_1
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDT).hasRole(
        proposal.SWAP_FREEZER_ROLE(),
        GovernanceV3Ethereum.EXECUTOR_LVL_1
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDC).hasRole(
        proposal.LIQUIDATOR_ROLE(),
        GovernanceV3Ethereum.EXECUTOR_LVL_1
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDT).hasRole(
        proposal.LIQUIDATOR_ROLE(),
        GovernanceV3Ethereum.EXECUTOR_LVL_1
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDC).hasRole(
        IGsm(GhoEthereum.GSM_USDC).CONFIGURATOR_ROLE(),
        GhoEthereum.GHO_GSM_STEWARD
      )
    );
    assertFalse(
      IGsm(GhoEthereum.GSM_USDT).hasRole(
        IGsm(GhoEthereum.GSM_USDT).CONFIGURATOR_ROLE(),
        GhoEthereum.GHO_GSM_STEWARD
      )
    );
  }

  function test_oracleSwapFreezers() public {
    // OracleSwapFreezers are not authorized
    assertEq(
      IGsm(proposal.NEW_GSM_USDC()).hasRole(
        IGsm(proposal.NEW_GSM_USDC()).SWAP_FREEZER_ROLE(),
        proposal.USDC_ORACLE_SWAP_FREEZER()
      ),
      false
    );
    assertEq(
      IGsm(proposal.NEW_GSM_USDT()).hasRole(
        IGsm(proposal.NEW_GSM_USDT()).SWAP_FREEZER_ROLE(),
        proposal.USDT_ORACLE_SWAP_FREEZER()
      ),
      false
    );

    IOracleSwapFreezer usdcFreezer = IOracleSwapFreezer(proposal.USDC_ORACLE_SWAP_FREEZER());
    IOracleSwapFreezer usdtFreezer = IOracleSwapFreezer(proposal.USDT_ORACLE_SWAP_FREEZER());
    (uint128 usdcFreezeLowerBound, ) = usdcFreezer.getFreezeBound();
    (uint128 usdcUnfreezeLowerBound, ) = usdcFreezer.getUnfreezeBound();
    (uint128 usdtFreezeLowerBound, ) = usdtFreezer.getFreezeBound();
    (uint128 usdtUnfreezeLowerBound, ) = usdtFreezer.getUnfreezeBound();

    // Price outside the price range
    // Freezers cannot execute freeze without authorization
    _mockAssetPrice(
      address(AaveV3Ethereum.ORACLE),
      AaveV3EthereumAssets.USDC_UNDERLYING,
      usdcFreezeLowerBound - 1
    );
    _mockAssetPrice(
      address(AaveV3Ethereum.ORACLE),
      AaveV3EthereumAssets.USDT_UNDERLYING,
      usdtFreezeLowerBound - 1
    );

    (bool canPerformUpkeep, ) = usdcFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, false);
    usdcFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getIsFrozen(), false);

    (canPerformUpkeep, ) = usdtFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, false);
    usdtFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDT()).getIsFrozen(), false);

    // Payload execution
    executePayload(vm, address(proposal));

    // Freezers are authorized now
    assertEq(
      IGsm(proposal.NEW_GSM_USDC()).hasRole(
        IGsm(proposal.NEW_GSM_USDC()).SWAP_FREEZER_ROLE(),
        proposal.USDC_ORACLE_SWAP_FREEZER()
      ),
      true
    );
    assertEq(
      IGsm(proposal.NEW_GSM_USDT()).hasRole(
        IGsm(proposal.NEW_GSM_USDT()).SWAP_FREEZER_ROLE(),
        proposal.USDT_ORACLE_SWAP_FREEZER()
      ),
      true
    );

    // Freezers freeze GSM contracts
    (canPerformUpkeep, ) = usdcFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true);
    usdcFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getIsFrozen(), true);

    (canPerformUpkeep, ) = usdtFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true);
    usdtFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDT()).getIsFrozen(), true);

    // Price back to normal
    _mockAssetPrice(
      address(AaveV3Ethereum.ORACLE),
      AaveV3EthereumAssets.USDC_UNDERLYING,
      usdcUnfreezeLowerBound + 1
    );
    _mockAssetPrice(
      address(AaveV3Ethereum.ORACLE),
      AaveV3EthereumAssets.USDT_UNDERLYING,
      usdtUnfreezeLowerBound + 1
    );

    (canPerformUpkeep, ) = usdcFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true);
    usdcFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getIsFrozen(), false);

    (canPerformUpkeep, ) = usdtFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true);
    usdtFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDT()).getIsFrozen(), false);
  }

  function test_checkRoles() public {
    executePayload(vm, address(proposal));

    _checkRolesConfig(IGsm(proposal.NEW_GSM_USDC()));
    _checkRolesConfig(IGsm(proposal.NEW_GSM_USDT()));
  }

  function test_oldGsmsAreSeized() public {
    executePayload(vm, address(proposal));

    // Old GSMs are seized
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDC).buyAsset(1000e6, address(this));
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDT).buyAsset(1000e6, address(this));
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDC).sellAsset(1000e6, address(this));
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoEthereum.GSM_USDT).sellAsset(1000e6, address(this));
  }

  function test_gsmUsdcIsOperational() public {
    executePayload(vm, address(proposal));

    deal(AaveV3EthereumAssets.USDC_STATA_TOKEN, address(this), 1_000e6);

    // New GSMs are operational
    IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).approve(proposal.NEW_GSM_USDC(), 1_000e6);
    IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).approve(proposal.NEW_GSM_USDC(), 1_200 ether);

    uint256 amountUnderlying = 1_000e6;
    uint256 balanceBeforeUsdcGsm = IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(
      proposal.NEW_GSM_USDC()
    );
    uint256 balanceGhoBefore = IGhoToken(GhoEthereum.GHO_TOKEN).balanceOf(address(this));

    (, uint256 ghoBought) = IGsm(proposal.NEW_GSM_USDC()).sellAsset(
      amountUnderlying,
      address(this)
    );

    assertEq(
      IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(proposal.NEW_GSM_USDC()),
      balanceBeforeUsdcGsm + amountUnderlying,
      'amounts USDC after sellAsset not equal'
    );
    assertEq(
      IGhoToken(GhoEthereum.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + ghoBought,
      'GHO balance after sellAsset not equal'
    );

    (, uint256 ghoSold) = IGsm(proposal.NEW_GSM_USDC()).buyAsset(500e6, address(this));

    assertEq(
      IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(proposal.NEW_GSM_USDC()),
      balanceBeforeUsdcGsm + amountUnderlying - 500e6,
      'stataUSDC balance after buyAsset not equal'
    );
    assertEq(
      IGhoToken(GhoEthereum.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + ghoBought - ghoSold,
      'GHO balance after buyAsset not equal'
    );
  }

  function test_oldGsmsHaveNoBalance() public {
    executePayload(vm, address(proposal));

    assertEq(IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDC), 0);
    assertEq(IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(GhoEthereum.GSM_USDT), 0);

    assertEq(IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).balanceOf(GhoEthereum.GSM_USDC), 0);
    assertEq(IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).balanceOf(GhoEthereum.GSM_USDT), 0);

    assertEq(IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).balanceOf(address(proposal)), 0);
    assertEq(IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(address(proposal)), 0);
    assertEq(IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).balanceOf(address(proposal)), 0);
  }

  function test_gsmUsdtIsOperational() public {
    executePayload(vm, address(proposal));

    // Update exposure cap because it's currently full
    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(proposal.NEW_GSM_USDT()).updateExposureCap(
      (proposal.RESERVE_LIMIT_GSM_USDT() * 1e6) / 1e18
    );
    vm.stopPrank();

    deal(AaveV3EthereumAssets.USDT_STATA_TOKEN, address(this), 10_000e6);

    // New GSMs are operational
    IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).approve(proposal.NEW_GSM_USDT(), 10_000e6);
    IERC20(AaveV3EthereumAssets.GHO_UNDERLYING).approve(proposal.NEW_GSM_USDT(), 1_200 ether);

    uint256 amountUnderlying = 500e6;
    uint256 balanceBeforeUsdtGsm = IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(
      proposal.NEW_GSM_USDT()
    );
    uint256 balanceGhoBefore = IGhoToken(GhoEthereum.GHO_TOKEN).balanceOf(address(this));

    (, uint256 ghoBought) = IGsm(proposal.NEW_GSM_USDT()).sellAsset(
      amountUnderlying,
      address(this)
    );

    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(proposal.NEW_GSM_USDT()),
      balanceBeforeUsdtGsm + amountUnderlying,
      'amounts USDT after sellAsset not equal'
    );
    assertEq(
      IGhoToken(GhoEthereum.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + ghoBought,
      'GHO balance after sellAsset not equal'
    );

    (, uint256 ghoSold) = IGsm(proposal.NEW_GSM_USDT()).buyAsset(100e6, address(this));

    assertEq(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).balanceOf(proposal.NEW_GSM_USDT()),
      balanceBeforeUsdtGsm + amountUnderlying - 100e6,
      'stataUSDT balance after buyAsset not equal'
    );
    assertEq(
      IGhoToken(GhoEthereum.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + ghoBought - ghoSold,
      'GHO balance after buyAsset not equal'
    );
  }

  function test_ghoGsmSteward_updateExposureCapUSDC() public {
    executePayload(vm, address(proposal));

    uint128 oldExposureCap = IGsm(proposal.NEW_GSM_USDC()).getExposureCap();
    uint128 newExposureCap = oldExposureCap + 1;

    vm.startPrank(GhoEthereum.RISK_COUNCIL);
    IGsmSteward(GhoEthereum.GHO_GSM_STEWARD).updateGsmExposureCap(
      proposal.NEW_GSM_USDC(),
      newExposureCap
    );
    uint128 currentExposureCap = IGsm(proposal.NEW_GSM_USDC()).getExposureCap();
    assertEq(currentExposureCap, newExposureCap);
  }

  function test_ghoGsmSteward_updateExposureCapUSDT() public {
    executePayload(vm, address(proposal));

    uint128 oldExposureCap = IGsm(proposal.NEW_GSM_USDT()).getExposureCap();
    uint128 newExposureCap = oldExposureCap + 1;

    vm.startPrank(GhoEthereum.RISK_COUNCIL);
    IGsmSteward(GhoEthereum.GHO_GSM_STEWARD).updateGsmExposureCap(
      proposal.NEW_GSM_USDT(),
      newExposureCap
    );
    uint128 currentExposureCap = IGsm(proposal.NEW_GSM_USDT()).getExposureCap();
    assertEq(currentExposureCap, newExposureCap);
  }

  function test_ghoGsmSteward_updateGsmBuySellFeesUSDC() public {
    executePayload(vm, address(proposal));

    address feeStrategy = IGsm(proposal.NEW_GSM_USDC()).getFeeStrategy();
    uint256 buyFee = IGsmFeeStrategy(feeStrategy).getBuyFee(1e4);
    uint256 sellFee = IGsmFeeStrategy(feeStrategy).getSellFee(1e4);

    vm.startPrank(GhoEthereum.RISK_COUNCIL);
    IGsmSteward(GhoEthereum.GHO_GSM_STEWARD).updateGsmBuySellFees(
      proposal.NEW_GSM_USDC(),
      buyFee + 1,
      sellFee
    );
    address newStrategy = IGsm(proposal.NEW_GSM_USDC()).getFeeStrategy();
    uint256 newBuyFee = IGsmFeeStrategy(newStrategy).getBuyFee(1e4);
    assertEq(newBuyFee, buyFee + 1);
  }

  function test_ghoGsmSteward_updateGsmBuySellFeesUSDT() public {
    executePayload(vm, address(proposal));

    address feeStrategy = IGsm(proposal.NEW_GSM_USDT()).getFeeStrategy();
    uint256 buyFee = IGsmFeeStrategy(feeStrategy).getBuyFee(1e4);
    uint256 sellFee = IGsmFeeStrategy(feeStrategy).getSellFee(1e4);

    vm.startPrank(GhoEthereum.RISK_COUNCIL);
    IGsmSteward(GhoEthereum.GHO_GSM_STEWARD).updateGsmBuySellFees(
      proposal.NEW_GSM_USDT(),
      buyFee + 1,
      sellFee
    );
    address newStrategy = IGsm(proposal.NEW_GSM_USDT()).getFeeStrategy();
    uint256 newBuyFee = IGsmFeeStrategy(newStrategy).getBuyFee(1e4);
    assertEq(newBuyFee, buyFee + 1);
  }

  function _checkRolesConfig(IGsm gsm) internal view {
    // DAO permissions
    assertTrue(
      gsm.hasRole(bytes32(0), GovernanceV3Ethereum.EXECUTOR_LVL_1),
      'Executor is not admin'
    );
    assertTrue(
      gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1),
      'Executor is not swap freezer'
    );
    assertTrue(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1),
      'Executor is not configurator'
    );
    // No need to be liquidator or token rescuer at the beginning
    assertFalse(gsm.hasRole(gsm.LIQUIDATOR_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertFalse(gsm.hasRole(gsm.TOKEN_RESCUER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));

    // Deployer does not have permissions
    address deployer = 0x3765A685a401622C060E5D700D9ad89413363a91;
    assertFalse(gsm.hasRole(bytes32(0), deployer), 'Deployer cannot be admin');
    assertFalse(gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), deployer), 'Deployer cannot be swap freezer');
    assertFalse(gsm.hasRole(gsm.CONFIGURATOR_ROLE(), deployer), 'Deployer cannot be configurator');
    assertFalse(gsm.hasRole(gsm.LIQUIDATOR_ROLE(), deployer), 'Deployer cannot be liquidator');
    assertFalse(
      gsm.hasRole(gsm.TOKEN_RESCUER_ROLE(), deployer),
      'Deployer cannot be token rescuer'
    );

    // GHO Steward
    assertTrue(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GhoEthereum.GHO_GSM_STEWARD),
      'Gho Steward not configured'
    );

    // Risk Council
    assertTrue(
      IGhoReserve(proposal.GHO_RESERVE()).hasRole(
        IGhoReserve(proposal.GHO_RESERVE()).LIMIT_MANAGER_ROLE(),
        GhoEthereum.RISK_COUNCIL
      ),
      'Gho Reserve role not configured for risk council'
    );

    assertTrue(
      IGhoDirectFacilitator(proposal.DIRECT_FACILITATOR()).hasRole(
        IGhoDirectFacilitator(proposal.DIRECT_FACILITATOR()).MINTER_ROLE(),
        GhoEthereum.RISK_COUNCIL
      ),
      'Gho Direct Facilitator role not configured for risk council'
    );
  }

  function _mockAssetPrice(address priceOracle, address asset, uint256 price) internal {
    vm.mockCall(
      priceOracle,
      abi.encodeWithSelector(IAaveOracle.getAssetPrice.selector, asset),
      abi.encode(price)
    );
  }

  struct GsmConfig {
    uint256 sellFee;
    uint256 buyFee;
    uint256 exposureCap;
    bool isFrozen;
    bool isSeized;
    bool freezerCanUnfreeze;
    uint256 freezeLowerBound;
    uint256 freezeUpperBound;
    uint256 unfreezeLowerBound;
    uint256 unfreezeUpperBound;
  }

  function _checkGsmConfig(
    IGsm gsm,
    address underlying,
    IOracleSwapFreezer freezer,
    GsmConfig memory config
  ) internal view {
    assertEq(gsm.UNDERLYING_ASSET(), underlying, 'wrong underlying asset');
    assertEq(gsm.getExposureCap(), config.exposureCap, 'wrong exposure cap');
    assertEq(gsm.getIsFrozen(), config.isFrozen, 'wrong freeze state');
    assertEq(gsm.getIsSeized(), config.isSeized, 'wrong seized state');

    // Fee Strategy
    IGsmFeeStrategy feeStrategy = IGsmFeeStrategy(gsm.getFeeStrategy());
    assertEq(feeStrategy.getSellFee(10000), config.sellFee, 'wrong sell fee');
    assertEq(feeStrategy.getBuyFee(10000), config.buyFee, 'wrong buy fee');

    // Price Strategy
    IFixedPriceStrategy4626 priceStrategy = IFixedPriceStrategy4626(gsm.PRICE_STRATEGY());
    assertEq(
      IERC4626(underlying).previewMint(1e6) * 10 ** 12,
      priceStrategy.getAssetPriceInGho(1e6, true)
    );
    assertEq(
      IERC4626(underlying).previewWithdraw(1 ether) / 10 ** 12,
      priceStrategy.getGhoPriceInAsset(1 ether, false)
    );

    assertEq(gsm.getGhoTreasury(), address(AaveV3Ethereum.COLLECTOR));

    // Oracle freezer
    assertEq(freezer.getCanUnfreeze(), config.freezerCanUnfreeze, 'wrong freezer config');
    (uint256 lowerBound, uint256 upperBound) = freezer.getFreezeBound();
    assertEq(lowerBound, config.freezeLowerBound, 'wrong freeze lower bound');
    assertEq(upperBound, config.freezeUpperBound, 'wrong freeze upper bound');
    (lowerBound, upperBound) = freezer.getUnfreezeBound();
    assertEq(lowerBound, config.unfreezeLowerBound, 'wrong unfreeze lower bound');
    assertEq(upperBound, config.unfreezeUpperBound, 'wrong unfreeze upper bound');

    assertEq(freezer.ADDRESS_PROVIDER(), address(AaveV3Ethereum.POOL_ADDRESSES_PROVIDER));
    assertEq(freezer.GSM(), address(gsm));
  }
}

interface IOracleSwapFreezer {
  function ADDRESS_PROVIDER() external view returns (address);
  function GSM() external view returns (address);
  function getCanUnfreeze() external view returns (bool);
  function getFreezeBound() external view returns (uint128, uint128);
  function getUnfreezeBound() external view returns (uint128, uint128);
  function checkUpkeep(bytes calldata) external view returns (bool, bytes memory);
  function performUpkeep(bytes calldata) external;
}

interface IFixedPriceStrategy4626 {
  function getAssetPriceInGho(uint256 assetAmount, bool roundUp) external view returns (uint256);
  function getGhoPriceInAsset(uint256 ghoAmount, bool roundUp) external view returns (uint256);
}

interface IGsm4626 {
  function getCurrentBacking() external view returns (uint256, uint256);
}
