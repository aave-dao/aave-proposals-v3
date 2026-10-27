// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';
import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AggregatorInterface} from 'aave-v3-origin/contracts/dependencies/chainlink/AggregatorInterface.sol';
import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig, ExpectedListing} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019} from './AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.sol';

/**
 * @dev Test for AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261019_Multi_OnboardCirBTCToV3CoreAndV4Core/AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019.t.sol -vv
 */
contract AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019_Test is ProtocolV3TestBase {
  AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26282649);
    proposal = new AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_OnboardCirBTCToV3CoreAndV4Core_20261019',
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

  function test_preState() public view {
    assertEq(
      AaveV3Ethereum.POOL.getReserveAToken(proposal.cirBTC()),
      address(0),
      'cirBTC already listed'
    );
  }

  function test_dustBinHascirBTCFunds() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    address aTokenAddress = AaveV3Ethereum.POOL.getReserveAToken(proposal.cirBTC());
    assertGe(
      IERC20(aTokenAddress).balanceOf(address(AaveV3Ethereum.DUST_BIN)),
      proposal.cirBTC_SEED_AMOUNT()
    );
  }

  function test_cirBTCPriceFeed() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _validateAssetSourceOnOracle(
      AaveV3Ethereum.POOL_ADDRESSES_PROVIDER,
      proposal.cirBTC(),
      ChainlinkEthereum.AAVE_SVR_BTC__USD
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(proposal.cirBTC()),
      uint256(AggregatorInterface(ChainlinkEthereum.AAVE_SVR_BTC__USD).latestAnswer()),
      'cirBTC price differs from BTC/USD'
    );
    assertApproxEqRel(
      AaveV3Ethereum.ORACLE.getAssetPrice(proposal.cirBTC()),
      AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.cbBTC_UNDERLYING),
      0.005e18,
      'cirBTC price diverges from cbBTC'
    );
  }

  function test_cirBTCInterestRateStrategy() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    _validateInterestRateStrategy(
      proposal.cirBTC(),
      AaveV3Ethereum.POOL.getReserveData(proposal.cirBTC()).interestRateStrategyAddress,
      AaveV3EthereumAssets.cbBTC_INTEREST_RATE_STRATEGY,
      IDefaultInterestRateStrategyV2.InterestRateDataRay({
        optimalUsageRatio: 0.8e27,
        baseVariableBorrowRate: 0.0025e27,
        variableRateSlope1: 0.04e27,
        variableRateSlope2: 0.6e27
      })
    );
  }

  function test_e2e_cirBTCCollateralLiquidation() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    ReserveConfig[] memory configs = _getReservesConfigs(AaveV3Ethereum.POOL);
    ReserveConfig memory cirBTCConfig = _findReserveConfig(configs, proposal.cirBTC());
    ReserveConfig memory usdcConfig = _findReserveConfig(
      configs,
      AaveV3EthereumAssets.USDC_UNDERLYING
    );
    uint256 cirBTCPrice = AaveV3Ethereum.ORACLE.getAssetPrice(proposal.cirBTC());
    uint256 usdcPrice = AaveV3Ethereum.ORACLE.getAssetPrice(AaveV3EthereumAssets.USDC_UNDERLYING);
    address borrower = makeAddr('CIRBTC_BORROWER');

    _deposit(cirBTCConfig, AaveV3Ethereum.POOL, borrower, (100_000e8 * 1e8) / cirBTCPrice);
    _borrow(usdcConfig, AaveV3Ethereum.POOL, borrower, (70_000e8 * 1e6) / usdcPrice);
    (, , , , , uint256 healthFactor) = AaveV3Ethereum.POOL.getUserAccountData(borrower);
    assertGt(healthFactor, 1e18, 'position unhealthy after borrow');

    uint256 droppedPrice = (cirBTCPrice * 85) / 100;
    vm.mockCall(
      ChainlinkEthereum.AAVE_SVR_BTC__USD,
      abi.encodeWithSignature('latestAnswer()'),
      abi.encode(int256(droppedPrice))
    );
    assertEq(
      AaveV3Ethereum.ORACLE.getAssetPrice(proposal.cirBTC()),
      droppedPrice,
      'price not mocked'
    );
    (, , , , , healthFactor) = AaveV3Ethereum.POOL.getUserAccountData(borrower);
    assertLt(healthFactor, 1e18, 'position not liquidatable');

    address liquidator = makeAddr('LIQUIDATOR');
    address treasury = address(AaveV3Ethereum.COLLECTOR);
    uint256 collateralBefore = IERC20(cirBTCConfig.aToken).balanceOf(borrower);
    uint256 treasuryBefore = IERC20(cirBTCConfig.aToken).balanceOf(treasury);
    uint256 debtBefore = IERC20(usdcConfig.variableDebtToken).balanceOf(borrower);

    _liquidationCall(
      cirBTCConfig,
      usdcConfig,
      AaveV3Ethereum.POOL,
      liquidator,
      borrower,
      type(uint256).max,
      false
    );

    uint256 seized = collateralBefore - IERC20(cirBTCConfig.aToken).balanceOf(borrower);
    uint256 protocolFee = IERC20(cirBTCConfig.aToken).balanceOf(treasury) - treasuryBefore;
    uint256 repaidValue = ((debtBefore - IERC20(usdcConfig.variableDebtToken).balanceOf(borrower)) *
      usdcPrice) / 1e6;
    assertApproxEqRel(
      (seized * droppedPrice) / 1e8,
      (repaidValue * 105_00) / 100_00,
      0.001e18,
      'liquidation bonus is not 5%'
    );
    assertApproxEqRel(
      protocolFee,
      (seized * 5_00 * 20_00) / (105_00 * 100_00),
      0.001e18,
      'protocol fee is not 20% of the bonus'
    );
    assertApproxEqAbs(
      IERC20(proposal.cirBTC()).balanceOf(liquidator) + protocolFee,
      seized,
      2,
      'seized collateral not split between liquidator and treasury'
    );
  }

  function _expectedListings() internal pure override returns (ExpectedListing[] memory listings) {
    listings = new ExpectedListing[](1);

    listings[0] = ExpectedListing({
      listing: IAaveV3ConfigEngine.Listing({
        asset: 0x72DFB2E44f59C5AD2bAFE84314E5b99a7cd5075E,
        assetSymbol: 'cirBTC',
        priceFeed: 0xb41E773f507F7a7EA890b1afB7d2b660c30C8B0A,
        enabledToBorrow: EngineFlags.ENABLED,
        flashloanable: EngineFlags.ENABLED,
        ltv: 73_00,
        liqThreshold: 78_00,
        liqBonus: 5_00,
        reserveFactor: 50_00,
        supplyCap: 250,
        borrowCap: 20,
        liqProtocolFee: 20_00,
        rateStrategyParams: IAaveV3ConfigEngine.InterestRateInputData({
          optimalUsageRatio: 80_00,
          baseVariableBorrowRate: 25,
          variableRateSlope1: 4_00,
          variableRateSlope2: 60_00
        })
      }),
      decimals: 8
    });
  }
}
