// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';

import {AaveV3Ethereum_February2026FundingUpdate_20260206} from './AaveV3Ethereum_February2026FundingUpdate_20260206.sol';

interface IMainnetSwapSteward {
  function tokenBudget(address token) external view returns (uint256);
}

/**
 * @dev Test for AaveV3Ethereum_February2026FundingUpdate_20260206
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20260206_AaveV3Ethereum_February2026FundingUpdate/AaveV3Ethereum_February2026FundingUpdate_20260206.t.sol -vv
 */
contract AaveV3Ethereum_February2026FundingUpdate_20260206_Test is ProtocolV3TestBase {
  AaveV3Ethereum_February2026FundingUpdate_20260206 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 24360000);
    proposal = new AaveV3Ethereum_February2026FundingUpdate_20260206();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_February2026FundingUpdate_20260206',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_aaveApprovals() public {
    uint256 allowanceBefore = IERC20(AaveV3EthereumAssets.AAVE_UNDERLYING).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AFC_SAFE
    );

    assertEq(allowanceBefore, 0);

    executePayload(vm, address(proposal));

    uint256 allowanceAfter = IERC20(AaveV3EthereumAssets.AAVE_UNDERLYING).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AFC_SAFE
    );

    assertEq(allowanceAfter, proposal.AFC_AAVE_AMOUNT());
  }

  function test_ahab() public {
    uint256 allowanceWethBefore = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AHAB_SAFE
    );
    uint256 allowanceWstethBefore = IERC20(AaveV3EthereumAssets.wstETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AHAB_SAFE
    );

    assertEq(allowanceWethBefore, 0);
    assertEq(allowanceWstethBefore, 0);

    executePayload(vm, address(proposal));

    uint256 allowanceWethAfter = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AHAB_SAFE
    );
    uint256 allowanceWstethAfter = IERC20(AaveV3EthereumAssets.wstETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.AHAB_SAFE
    );

    assertEq(allowanceWethAfter, proposal.AHAB_WETH_AMOUNT());
    assertEq(allowanceWstethAfter, proposal.AHAB_WSTETH_AMOUNT());
  }

  function test_liquidityApprovals() public {
    address liquiditySafe = proposal.AAVE_LIQUIDITY_SAFE();

    assertEq(
      IERC20(AaveV3EthereumAssets.AAVE_UNDERLYING).allowance(
        MiscEthereum.ECOSYSTEM_RESERVE,
        liquiditySafe
      ),
      0
    );
    assertEq(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        liquiditySafe
      ),
      0
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3EthereumAssets.AAVE_UNDERLYING).allowance(
        MiscEthereum.ECOSYSTEM_RESERVE,
        liquiditySafe
      ),
      proposal.LIQUIDITY_AAVE_AMOUNT()
    );
    assertEq(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        liquiditySafe
      ),
      proposal.LIQUIDITY_WETH_AMOUNT()
    );
  }

  function test_cexEarnApproval() public {
    assertEq(
      IERC20(AaveV3EthereumAssets.USDe_UNDERLYING).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        MiscEthereum.AFC_CEX_EARN_SAFE
      ),
      0
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3EthereumAssets.USDe_UNDERLYING).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        MiscEthereum.AFC_CEX_EARN_SAFE
      ),
      proposal.CEX_EARN_USDE_AMOUNT()
    );
  }

  function test_reimbursements() public {
    uint256 allowanceAciBefore = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      proposal.ACI_SAFE()
    );
    uint256 allowanceTokenLogicBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      proposal.TOKEN_LOGIC()
    );
    assertEq(allowanceAciBefore, 0);
    assertEq(allowanceTokenLogicBefore, 0);

    executePayload(vm, address(proposal));

    uint256 allowanceAciAfter = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      proposal.ACI_SAFE()
    );
    uint256 allowanceTokenLogicAfter = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      proposal.TOKEN_LOGIC()
    );
    assertEq(allowanceAciAfter, allowanceAciBefore + proposal.ACI_REIMBURSE_AWETH_AMOUNT());
    assertEq(
      allowanceTokenLogicAfter,
      allowanceTokenLogicBefore + proposal.TOKENLOGIC_REIMBURSE_GHO_AMOUNT()
    );
  }

  function test_ethDeposit() public {
    uint256 balanceEthBefore = address(AaveV3Ethereum.COLLECTOR).balance;
    address aWeth = AaveV3Ethereum.POOL.getReserveAToken(AaveV3EthereumAssets.WETH_UNDERLYING);
    uint256 balanceAWethBefore = IERC20(aWeth).balanceOf(address(AaveV3Ethereum.COLLECTOR));

    executePayload(vm, address(proposal));

    assertEq(address(AaveV3Ethereum.COLLECTOR).balance, 0);
    assertApproxEqAbs(
      IERC20(aWeth).balanceOf(address(AaveV3Ethereum.COLLECTOR)),
      balanceAWethBefore + balanceEthBefore,
      1,
      'aWETH balance after deposit'
    );
  }

  function test_replenishSwapTokenBudget() public {
    address swapSteward = AaveV3Ethereum.COLLECTOR_SWAP_STEWARD;
    address ethMock = AaveV3Ethereum.COLLECTOR.ETH_MOCK_ADDRESS();

    uint256 budgetEthBefore = IMainnetSwapSteward(swapSteward).tokenBudget(ethMock);
    uint256 budgetUsdcBefore = IMainnetSwapSteward(swapSteward).tokenBudget(
      AaveV3EthereumAssets.USDC_UNDERLYING
    );
    uint256 budgetUsdtBefore = IMainnetSwapSteward(swapSteward).tokenBudget(
      AaveV3EthereumAssets.USDT_UNDERLYING
    );
    uint256 budgetUsdeBefore = IMainnetSwapSteward(swapSteward).tokenBudget(
      AaveV3EthereumAssets.USDe_UNDERLYING
    );
    uint256 budgetUsdsBefore = IMainnetSwapSteward(swapSteward).tokenBudget(
      AaveV3EthereumAssets.USDS_UNDERLYING
    );
    uint256 budgetDaiBefore = IMainnetSwapSteward(swapSteward).tokenBudget(
      AaveV3EthereumAssets.DAI_UNDERLYING
    );

    executePayload(vm, address(proposal));

    assertEq(
      IMainnetSwapSteward(swapSteward).tokenBudget(ethMock),
      budgetEthBefore + proposal.ETH_SWAP_BUDGET_AMOUNT()
    );
    assertEq(
      IMainnetSwapSteward(swapSteward).tokenBudget(AaveV3EthereumAssets.USDC_UNDERLYING),
      budgetUsdcBefore + proposal.USDC_SWAP_BUDGET_AMOUNT()
    );
    assertEq(
      IMainnetSwapSteward(swapSteward).tokenBudget(AaveV3EthereumAssets.USDT_UNDERLYING),
      budgetUsdtBefore + proposal.USDT_SWAP_BUDGET_AMOUNT()
    );
    assertEq(
      IMainnetSwapSteward(swapSteward).tokenBudget(AaveV3EthereumAssets.USDe_UNDERLYING),
      budgetUsdeBefore + proposal.USDE_SWAP_BUDGET_AMOUNT()
    );
    assertEq(
      IMainnetSwapSteward(swapSteward).tokenBudget(AaveV3EthereumAssets.USDS_UNDERLYING),
      budgetUsdsBefore + proposal.USDS_SWAP_BUDGET_AMOUNT()
    );
    assertEq(
      IMainnetSwapSteward(swapSteward).tokenBudget(AaveV3EthereumAssets.DAI_UNDERLYING),
      budgetDaiBefore + proposal.DAI_SWAP_BUDGET_AMOUNT()
    );
  }
}
