// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

import {IMainnetSwapSteward} from 'src/interfaces/IMainnetSwapSteward.sol';
import {AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907} from './AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907.sol';

/**
 * @dev Test for AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260907_Multi_AugustSeptember2026FundingUpdate/AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907.t.sol -vv
 */
contract AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907_Test is ProtocolV3TestBase {
  AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 25927734);
    proposal = new AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907',
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

  function test_cancelAhabWethAllowance() public {
    uint256 allowanceBefore = IERC20(AaveV3EthereumLidoAssets.WETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AHAB_SAFE
    );
    assertGt(allowanceBefore, 0, 'Ahab should have an aEthLidoWETH allowance before execution');

    executePayload(vm, address(proposal));

    uint256 allowanceAfter = IERC20(AaveV3EthereumLidoAssets.WETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AHAB_SAFE
    );
    assertEq(allowanceAfter, 0, 'Ahab aEthLidoWETH allowance should be cancelled');
  }

  function test_depositETH() public {
    uint256 collectorEthBalanceBefore = address(AaveV3Ethereum.COLLECTOR).balance;
    assertGt(collectorEthBalanceBefore, 0, 'collector should hold ETH to deposit');
    uint256 aWethBalanceBefore = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).balanceOf(
      address(AaveV3Ethereum.COLLECTOR)
    );

    executePayload(vm, address(proposal));

    // All of the collector's ETH has been wrapped and deposited.
    assertEq(address(AaveV3Ethereum.COLLECTOR).balance, 0, 'collector should hold no ETH');
    uint256 aWethBalanceAfter = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).balanceOf(
      address(AaveV3Ethereum.COLLECTOR)
    );

    // aTokens are minted ~1:1 with the deposited underlying.
    assertApproxEqAbs(
      aWethBalanceAfter,
      aWethBalanceBefore + collectorEthBalanceBefore,
      1,
      'aWETH not minted for the deposited ETH'
    );
  }

  function test_reimbursements() public {
    uint256 allowanceBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.TOKENLOGIC_FUNDING_RECEIVER
    );

    assertEq(
      allowanceBefore,
      50_000 ether,
      'TokenLogic allowance should equal the July reimbursement before execution'
    );

    executePayload(vm, address(proposal));

    uint256 allowanceAfter = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.TOKENLOGIC_FUNDING_RECEIVER
    );

    assertEq(
      allowanceAfter,
      allowanceBefore + proposal.REIMBURSEMENTS_GHO_AMOUNT(),
      'TokenLogic allowance should increase by the reimbursement amount'
    );
    assertEq(
      allowanceAfter,
      119_939.27 ether,
      'TokenLogic allowance should equal the standing allowance plus the two audit reimbursements'
    );
  }

  function test_aaveLiquidityCommitteeAllowance() public {
    uint256 allowanceBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.ALC_SAFE
    );
    assertEq(allowanceBefore, 0, 'ALC should have no aEthLidoGHO allowance before execution');

    executePayload(vm, address(proposal));

    uint256 allowanceAfter = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.ALC_SAFE
    );
    assertEq(
      allowanceAfter,
      proposal.ALC_GHO_ALLOWANCE(),
      'ALC aEthLidoGHO allowance should be set to the six month budget'
    );
    assertEq(allowanceAfter, 750_000 ether, 'ALC aEthLidoGHO allowance should be 750,000');
  }

  function test_growthAllowances() public {
    assertEq(
      _usdcAllowanceOf(MiscEthereum.AFC_SAFE),
      0,
      'AFC should have no aEthUSDC allowance before execution'
    );
    assertEq(
      _usdcAllowanceOf(MiscEthereum.BUDGET_INCENTIVE_SAFE),
      0,
      'Incentive Budget Safe should have no aEthUSDC allowance before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      _usdcAllowanceOf(MiscEthereum.AFC_SAFE),
      proposal.AFC_USDC_ALLOWANCE(),
      'AFC aEthUSDC allowance should be set to the growth allowance'
    );
    assertEq(
      _usdcAllowanceOf(MiscEthereum.AFC_SAFE),
      1_500_000e6,
      'AFC aEthUSDC allowance should be 1,500,000'
    );
    assertEq(
      _usdcAllowanceOf(MiscEthereum.BUDGET_INCENTIVE_SAFE),
      proposal.BUDGET_INCENTIVE_USDC_ALLOWANCE(),
      'Incentive Budget Safe aEthUSDC allowance should be set to the growth allowance'
    );
    assertEq(
      _usdcAllowanceOf(MiscEthereum.BUDGET_INCENTIVE_SAFE),
      850_000e6,
      'Incentive Budget Safe aEthUSDC allowance should be 850,000'
    );
  }

  function test_refreshSwapBudgets() public {
    assertGt(
      _budgetOf(AaveV3EthereumAssets.WETH_UNDERLYING),
      proposal.WETH_SWAP_BUDGET(),
      'WETH budget should be above the target before execution'
    );
    assertGt(
      _budgetOf(AaveV3EthereumAssets.USDC_UNDERLYING),
      proposal.USDC_SWAP_BUDGET(),
      'USDC budget should be above the target before execution'
    );
    assertGt(
      _budgetOf(AaveV3EthereumAssets.USDT_UNDERLYING),
      proposal.USDT_SWAP_BUDGET(),
      'USDT budget should be above the target before execution'
    );
    assertGt(
      _budgetOf(AaveV3EthereumAssets.USDe_UNDERLYING),
      proposal.USDE_SWAP_BUDGET(),
      'USDe budget should be above the target before execution'
    );
    assertGt(
      _budgetOf(AaveV3EthereumAssets.USDS_UNDERLYING),
      proposal.USDS_SWAP_BUDGET(),
      'USDS budget should be above the target before execution'
    );
    assertGt(
      _budgetOf(AaveV3EthereumAssets.DAI_UNDERLYING),
      proposal.DAI_SWAP_BUDGET(),
      'DAI budget should be above the target before execution'
    );
    assertLt(
      _budgetOf(AaveV3EthereumAssets.RLUSD_UNDERLYING),
      proposal.RLUSD_SWAP_BUDGET(),
      'rlUSD budget should be below the target before execution'
    );
    assertLt(
      _budgetOf(AaveV3EthereumAssets.PYUSD_UNDERLYING),
      proposal.PYUSD_SWAP_BUDGET(),
      'pyUSD budget should be below the target before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      _budgetOf(AaveV3EthereumAssets.WETH_UNDERLYING),
      proposal.WETH_SWAP_BUDGET(),
      'WETH budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.WETH_UNDERLYING),
      5_000 ether,
      'WETH budget should be 5k'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDC_UNDERLYING),
      proposal.USDC_SWAP_BUDGET(),
      'USDC budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDC_UNDERLYING),
      10_000_000e6,
      'USDC budget should be 10M'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDT_UNDERLYING),
      proposal.USDT_SWAP_BUDGET(),
      'USDT budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDT_UNDERLYING),
      10_000_000e6,
      'USDT budget should be 10M'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDe_UNDERLYING),
      proposal.USDE_SWAP_BUDGET(),
      'USDe budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDe_UNDERLYING),
      2_000_000 ether,
      'USDe budget should be 2M'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDS_UNDERLYING),
      proposal.USDS_SWAP_BUDGET(),
      'USDS budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.USDS_UNDERLYING),
      200_000 ether,
      'USDS budget should be 0.2M'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.DAI_UNDERLYING),
      proposal.DAI_SWAP_BUDGET(),
      'DAI budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.DAI_UNDERLYING),
      200_000 ether,
      'DAI budget should be 0.2M'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.RLUSD_UNDERLYING),
      proposal.RLUSD_SWAP_BUDGET(),
      'rlUSD budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.RLUSD_UNDERLYING),
      200_000 ether,
      'rlUSD budget should be 0.2M'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.PYUSD_UNDERLYING),
      proposal.PYUSD_SWAP_BUDGET(),
      'pyUSD budget should match the target'
    );
    assertEq(
      _budgetOf(AaveV3EthereumAssets.PYUSD_UNDERLYING),
      200_000e6,
      'pyUSD budget should be 0.2M'
    );
  }

  function _budgetOf(address token) internal view returns (uint256) {
    return IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).tokenBudget(token);
  }

  function _usdcAllowanceOf(address spender) internal view returns (uint256) {
    return
      IERC20(AaveV3EthereumAssets.USDC_A_TOKEN).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        spender
      );
  }
}
