// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {IAaveOracle} from 'aave-address-book/AaveV2.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GhoArbitrum} from 'aave-address-book/GhoArbitrum.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmFeeStrategy} from 'src/interfaces/IGsmFeeStrategy.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IGsmSteward} from 'src/interfaces/IGsmSteward.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IOracleSwapFreezer} from 'src/interfaces/IOracleSwapFreezer.sol';
import {IFixedPriceStrategy4626} from 'src/interfaces/IFixedPriceStrategy4626.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

import {AaveV3Arbitrum_USDCGSMArbitrum_20260806} from './AaveV3Arbitrum_USDCGSMArbitrum_20260806.sol';

interface IGsm4626 {
  function getCurrentBacking() external view returns (uint256, uint256);
}

/**
 * @dev Test for AaveV3Arbitrum_USDCGSMArbitrum_20260806
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260806_AaveV3Arbitrum_USDCGSMArbitrum/AaveV3Arbitrum_USDCGSMArbitrum_20260806.t.sol -vv
 */
contract AaveV3Arbitrum_USDCGSMArbitrum_20260806_Test is ProtocolV3TestBase {
  AaveV3Arbitrum_USDCGSMArbitrum_20260806 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 491792569);
    proposal = new AaveV3Arbitrum_USDCGSMArbitrum_20260806();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV3Arbitrum_USDCGSMArbitrum_20260806', AaveV3Arbitrum.POOL, address(proposal));
  }

  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](0);

    reserveConfigChangesTest(AaveV3Arbitrum.POOL, address(proposal), updatedAssets);
  }

  function test_rolesAreTheSame() public view {
    assertTrue(
      IGsm(GhoArbitrum.GSM_USDC).LIQUIDATOR_ROLE() ==
        IGsm(proposal.NEW_GSM_USDC()).LIQUIDATOR_ROLE()
    );
    assertTrue(
      IGsm(GhoArbitrum.GSM_USDC).SWAP_FREEZER_ROLE() ==
        IGsm(proposal.NEW_GSM_USDC()).SWAP_FREEZER_ROLE()
    );
  }

  function test_checkConfig() public {
    assertEq(IGhoReserve(GhoArbitrum.GHO_RESERVE).totalEntities(), 1);

    executePayload(vm, address(proposal));

    // We replace one GSM with the new one so this remains the same
    assertEq(IGhoReserve(GhoArbitrum.GHO_RESERVE).totalEntities(), 1);

    uint256 limit = IGhoReserve(GhoArbitrum.GHO_RESERVE).getLimit(proposal.NEW_GSM_USDC());
    assertEq(limit, proposal.RESERVE_LIMIT_GSM());

    (uint256 excess, uint256 deficit) = IGsm4626(proposal.NEW_GSM_USDC()).getCurrentBacking();
    assertEq(excess, 0);
    assertEq(deficit, 0);

    // No usage from previous or new GSM yet
    assertEq(
      IGhoReserve(GhoArbitrum.GHO_RESERVE).getUsed(GhoArbitrum.GSM_USDC),
      0,
      'Used is not zero for old GSM'
    );
    assertEq(
      IGhoReserve(GhoArbitrum.GHO_RESERVE).getUsed(proposal.NEW_GSM_USDC()),
      0,
      'Used is not zero for new GSM'
    );

    GsmConfig memory gsmUsdcConfig = GsmConfig({
      sellFee: 0, // 0.00%
      buyFee: 0.001e4, // 0.1%
      exposureCap: 20_000_000e6,
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
      AaveV3ArbitrumAssets.USDCn_STATA_TOKEN,
      IOracleSwapFreezer(proposal.USDC_ORACLE_SWAP_FREEZER()),
      gsmUsdcConfig
    );
  }

  function test_checkOldGSMDisabled() public {
    executePayload(vm, address(proposal));

    assertTrue(IGsm(GhoArbitrum.GSM_USDC).getIsSeized());

    assertEq(IERC20(GhoArbitrum.GHO_TOKEN).balanceOf(GhoArbitrum.GSM_USDC), 0);
    assertEq(IERC20(AaveV3ArbitrumAssets.USDC_STATA_TOKEN).balanceOf(GhoArbitrum.GSM_USDC), 0);

    assertEq(IGsm(GhoArbitrum.GSM_USDC).getAvailableUnderlyingExposure(), 0, 'wrong exposure cap');

    assertFalse(
      IGsm(GhoArbitrum.GSM_USDC).hasRole(
        proposal.SWAP_FREEZER_ROLE(),
        GhoArbitrum.GSM_USDC_ORACLE_SWAP_FREEZER
      )
    );

    assertFalse(
      IGsm(GhoArbitrum.GSM_USDC).hasRole(
        proposal.SWAP_FREEZER_ROLE(),
        GovernanceV3Arbitrum.EXECUTOR_LVL_1
      )
    );

    assertFalse(
      IGsm(GhoArbitrum.GSM_USDC).hasRole(
        proposal.LIQUIDATOR_ROLE(),
        GovernanceV3Arbitrum.EXECUTOR_LVL_1
      )
    );

    assertFalse(
      IGsm(GhoArbitrum.GSM_USDC).hasRole(
        IGsm(GhoArbitrum.GSM_USDC).CONFIGURATOR_ROLE(),
        GhoArbitrum.GHO_GSM_STEWARD
      )
    );
  }

  function test_oracleSwapFreezer() public {
    // OracleSwapFreezer is not authorized
    assertEq(
      IGsm(proposal.NEW_GSM_USDC()).hasRole(
        IGsm(proposal.NEW_GSM_USDC()).SWAP_FREEZER_ROLE(),
        proposal.USDC_ORACLE_SWAP_FREEZER()
      ),
      false
    );

    IOracleSwapFreezer usdcFreezer = IOracleSwapFreezer(proposal.USDC_ORACLE_SWAP_FREEZER());
    (uint128 usdcFreezeLowerBound, ) = usdcFreezer.getFreezeBound();
    (uint128 usdcUnfreezeLowerBound, ) = usdcFreezer.getUnfreezeBound();

    // Price outside the price range
    // Freezers cannot execute freeze without authorization
    _mockAssetPrice(
      address(AaveV3Arbitrum.ORACLE),
      AaveV3ArbitrumAssets.USDCn_UNDERLYING,
      usdcFreezeLowerBound - 1
    );

    (bool canPerformUpkeep, ) = usdcFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, false);

    usdcFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getIsFrozen(), false);

    // Payload execution
    executePayload(vm, address(proposal));

    // Freezers is authorized now
    assertEq(
      IGsm(proposal.NEW_GSM_USDC()).hasRole(
        IGsm(proposal.NEW_GSM_USDC()).SWAP_FREEZER_ROLE(),
        proposal.USDC_ORACLE_SWAP_FREEZER()
      ),
      true
    );

    // Freezer freezes GSM contract
    (canPerformUpkeep, ) = usdcFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true);

    usdcFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getIsFrozen(), true);

    // Price back to normal
    _mockAssetPrice(
      address(AaveV3Arbitrum.ORACLE),
      AaveV3ArbitrumAssets.USDCn_UNDERLYING,
      usdcUnfreezeLowerBound + 1
    );

    (canPerformUpkeep, ) = usdcFreezer.checkUpkeep(bytes(''));
    assertEq(canPerformUpkeep, true);

    usdcFreezer.performUpkeep(bytes(''));
    assertEq(IGsm(proposal.NEW_GSM_USDC()).getIsFrozen(), false);
  }

  function test_checkRoles() public {
    executePayload(vm, address(proposal));
    _checkRolesConfig(IGsm(proposal.NEW_GSM_USDC()));
  }

  function test_oldGsmSeized() public {
    executePayload(vm, address(proposal));

    // Old GSM is seized
    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoArbitrum.GSM_USDC).buyAsset(1000e6, address(this));

    vm.expectRevert(bytes('GSM_SEIZED'));
    IGsm(GhoArbitrum.GSM_USDC).sellAsset(1000e6, address(this));
  }

  function test_gsmRegistryEntities() public {
    assertEq(IGsmRegistry(proposal.GSM_REGISTRY()).getGsmListLength(), 1);
    assertEq(IGsmRegistry(proposal.GSM_REGISTRY()).getGsmAtIndex(0), GhoArbitrum.GSM_USDC);

    executePayload(vm, address(proposal));

    assertEq(IGsmRegistry(proposal.GSM_REGISTRY()).getGsmListLength(), 1);
    assertEq(IGsmRegistry(proposal.GSM_REGISTRY()).getGsmAtIndex(0), proposal.NEW_GSM_USDC());
  }

  function test_ghoReserveEntities() public {
    assertTrue(
      IGhoReserve(address(GhoArbitrum.GHO_RESERVE)).isEntity(GhoArbitrum.GSM_USDC),
      'USDC.e GSM not registered as entity'
    );

    assertFalse(
      IGhoReserve(address(GhoArbitrum.GHO_RESERVE)).isEntity(proposal.NEW_GSM_USDC()),
      'USDC GSM not registered as entity'
    );

    executePayload(vm, address(proposal));

    assertFalse(
      IGhoReserve(address(GhoArbitrum.GHO_RESERVE)).isEntity(GhoArbitrum.GSM_USDC),
      'USDC.e still registered as entity'
    );

    assertTrue(
      IGhoReserve(address(GhoArbitrum.GHO_RESERVE)).isEntity(proposal.NEW_GSM_USDC()),
      'USDC GSM not registered as entity'
    );
  }

  function test_gsmIsOperational() public {
    executePayload(vm, address(proposal));

    deal(AaveV3ArbitrumAssets.USDCn_STATA_TOKEN, address(this), 1_000e6);

    IERC20(AaveV3ArbitrumAssets.USDCn_STATA_TOKEN).approve(proposal.NEW_GSM_USDC(), 1_000e6);
    IERC20(AaveV3ArbitrumAssets.GHO_UNDERLYING).approve(proposal.NEW_GSM_USDC(), 1_200 ether);

    uint256 amountUnderlying = 1_000e6;
    uint256 balanceBeforeUsdcGsm = IERC20(AaveV3ArbitrumAssets.USDCn_STATA_TOKEN).balanceOf(
      proposal.NEW_GSM_USDC()
    );

    uint256 balanceGhoBefore = IGhoToken(GhoArbitrum.GHO_TOKEN).balanceOf(address(this));
    (, uint256 ghoBought) = IGsm(proposal.NEW_GSM_USDC()).sellAsset(
      amountUnderlying,
      address(this)
    );

    assertEq(
      IERC20(AaveV3ArbitrumAssets.USDCn_STATA_TOKEN).balanceOf(proposal.NEW_GSM_USDC()),
      balanceBeforeUsdcGsm + amountUnderlying,
      'amounts USDC after sellAsset not equal'
    );

    assertEq(
      IGhoToken(GhoArbitrum.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + ghoBought,
      'GHO balance after sellAsset not equal'
    );

    (, uint256 ghoSold) = IGsm(proposal.NEW_GSM_USDC()).buyAsset(500e6, address(this));
    assertEq(
      IERC20(AaveV3ArbitrumAssets.USDCn_STATA_TOKEN).balanceOf(proposal.NEW_GSM_USDC()),
      balanceBeforeUsdcGsm + amountUnderlying - 500e6,
      'stataUSDC balance after buyAsset not equal'
    );

    assertEq(
      IGhoToken(GhoArbitrum.GHO_TOKEN).balanceOf(address(this)),
      balanceGhoBefore + ghoBought - ghoSold,
      'GHO balance after buyAsset not equal'
    );

    // The buy fee is retained by the GSM as accrued fees instead of being returned to the reserve,
    // so the outstanding usage is higher than the net GHO the user swapped by exactly that fee
    assertEq(
      IGhoReserve(GhoArbitrum.GHO_RESERVE).getUsed(proposal.NEW_GSM_USDC()),
      ghoBought - ghoSold + IGsm(proposal.NEW_GSM_USDC()).getAccruedFees()
    );
  }

  function test_oldGsmHasNoBalance() public {
    executePayload(vm, address(proposal));

    assertEq(IERC20(AaveV3ArbitrumAssets.USDC_STATA_TOKEN).balanceOf(GhoArbitrum.GSM_USDC), 0);
    assertEq(IERC20(AaveV3ArbitrumAssets.GHO_UNDERLYING).balanceOf(GhoArbitrum.GSM_USDC), 0);

    assertEq(IERC20(AaveV3ArbitrumAssets.USDC_STATA_TOKEN).balanceOf(address(proposal)), 0);
    assertEq(IERC20(AaveV3ArbitrumAssets.GHO_UNDERLYING).balanceOf(address(proposal)), 0);
  }

  function test_ghoGsmSteward_updateExposureCap() public {
    executePayload(vm, address(proposal));

    uint128 oldExposureCap = IGsm(proposal.NEW_GSM_USDC()).getExposureCap();
    uint128 newExposureCap = oldExposureCap + 1;

    vm.startPrank(GhoArbitrum.RISK_COUNCIL);
    IGsmSteward(GhoArbitrum.GHO_GSM_STEWARD).updateGsmExposureCap(
      proposal.NEW_GSM_USDC(),
      newExposureCap
    );

    uint128 currentExposureCap = IGsm(proposal.NEW_GSM_USDC()).getExposureCap();
    assertEq(currentExposureCap, newExposureCap);
  }

  function test_ghoGsmSteward_updateGsmBuySellFees() public {
    executePayload(vm, address(proposal));

    address feeStrategy = IGsm(proposal.NEW_GSM_USDC()).getFeeStrategy();
    uint256 buyFee = IGsmFeeStrategy(feeStrategy).getBuyFee(1e4);
    uint256 sellFee = IGsmFeeStrategy(feeStrategy).getSellFee(1e4);

    vm.startPrank(GhoArbitrum.RISK_COUNCIL);

    IGsmSteward(GhoArbitrum.GHO_GSM_STEWARD).updateGsmBuySellFees(
      proposal.NEW_GSM_USDC(),
      buyFee + 1,
      sellFee
    );

    address newStrategy = IGsm(proposal.NEW_GSM_USDC()).getFeeStrategy();
    uint256 newBuyFee = IGsmFeeStrategy(newStrategy).getBuyFee(1e4);

    assertEq(newBuyFee, buyFee + 1);
  }

  function _checkRolesConfig(IGsm gsm) internal view {
    // DAO permissions
    assertTrue(
      gsm.hasRole(bytes32(0), GovernanceV3Arbitrum.EXECUTOR_LVL_1),
      'Executor is not admin'
    );
    assertTrue(
      gsm.hasRole(gsm.SWAP_FREEZER_ROLE(), GovernanceV3Arbitrum.EXECUTOR_LVL_1),
      'Executor is not swap freezer'
    );
    assertTrue(
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GovernanceV3Arbitrum.EXECUTOR_LVL_1),
      'Executor is not configurator'
    );

    // No need to be liquidator or token rescuer at the beginning
    assertFalse(gsm.hasRole(gsm.LIQUIDATOR_ROLE(), GovernanceV3Arbitrum.EXECUTOR_LVL_1));
    assertFalse(gsm.hasRole(gsm.TOKEN_RESCUER_ROLE(), GovernanceV3Arbitrum.EXECUTOR_LVL_1));

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
      gsm.hasRole(gsm.CONFIGURATOR_ROLE(), GhoArbitrum.GHO_GSM_STEWARD),
      'Gho Steward not configured'
    );

    // Risk Council
    assertTrue(
      IGhoReserve(GhoArbitrum.GHO_RESERVE).hasRole(
        IGhoReserve(GhoArbitrum.GHO_RESERVE).LIMIT_MANAGER_ROLE(),
        GhoArbitrum.RISK_COUNCIL
      ),
      'Gho Reserve role not configured for risk council'
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
    assertEq(gsm.getGhoReserve(), GhoArbitrum.GHO_RESERVE, 'wrong gho reserve');
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
    assertEq(gsm.getGhoTreasury(), address(AaveV3Arbitrum.COLLECTOR));

    // Oracle freezer
    assertEq(freezer.getCanUnfreeze(), config.freezerCanUnfreeze, 'wrong freezer config');
    (uint256 lowerBound, uint256 upperBound) = freezer.getFreezeBound();

    assertEq(lowerBound, config.freezeLowerBound, 'wrong freeze lower bound');
    assertEq(upperBound, config.freezeUpperBound, 'wrong freeze upper bound');

    (lowerBound, upperBound) = freezer.getUnfreezeBound();

    assertEq(lowerBound, config.unfreezeLowerBound, 'wrong unfreeze lower bound');
    assertEq(upperBound, config.unfreezeUpperBound, 'wrong unfreeze upper bound');

    assertEq(freezer.ADDRESS_PROVIDER(), address(AaveV3Arbitrum.POOL_ADDRESSES_PROVIDER));
    assertEq(freezer.GSM(), address(gsm));
  }
}
