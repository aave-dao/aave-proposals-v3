// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IWrappedTokenGatewayV3} from 'aave-v3-origin/contracts/helpers/interfaces/IWrappedTokenGatewayV3.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {IMainnetSwapSteward} from 'src/interfaces/IMainnetSwapSteward.sol';

/**
 * @title August/September 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-august-september-2026-funding-update/25597
 */
contract AaveV3Ethereum_AugustSeptember2026FundingUpdate_20260907 is IProposalGenericExecutor {
  uint256 public constant REIMBURSEMENTS_GHO_AMOUNT = 69_939.27 ether;

  uint256 public constant ALC_GHO_ALLOWANCE = 750_000 ether;

  uint256 public constant AFC_USDC_ALLOWANCE = 1_500_000e6;
  uint256 public constant BUDGET_INCENTIVE_USDC_ALLOWANCE = 850_000e6;

  uint256 public constant WETH_SWAP_BUDGET = 5_000 ether;
  uint256 public constant USDC_SWAP_BUDGET = 10_000_000e6;
  uint256 public constant USDT_SWAP_BUDGET = 10_000_000e6;
  uint256 public constant USDE_SWAP_BUDGET = 2_000_000 ether;
  uint256 public constant USDS_SWAP_BUDGET = 200_000 ether;
  uint256 public constant DAI_SWAP_BUDGET = 200_000 ether;
  uint256 public constant RLUSD_SWAP_BUDGET = 200_000 ether;
  uint256 public constant PYUSD_SWAP_BUDGET = 200_000e6;

  function execute() external {
    _cancelAllowances();
    _depositEth();
    _aaveLiquidityCommittee();
    _growthAllowances();
    _reimbursements();
    _refreshSwapBudgets();
  }

  function _cancelAllowances() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumLidoAssets.WETH_A_TOKEN),
      MiscEthereum.AHAB_SAFE,
      0
    );
  }

  function _depositEth() internal {
    uint256 collectorEthBalance = address(AaveV3Ethereum.COLLECTOR).balance;
    AaveV3Ethereum.COLLECTOR.transfer(
      IERC20(AaveV3Ethereum.COLLECTOR.ETH_MOCK_ADDRESS()),
      address(this),
      collectorEthBalance
    );
    IWrappedTokenGatewayV3(AaveV3Ethereum.WETH_GATEWAY).depositETH{value: collectorEthBalance}(
      address(AaveV3Ethereum.POOL),
      address(AaveV3Ethereum.COLLECTOR),
      0
    );
  }

  function _aaveLiquidityCommittee() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN),
      MiscEthereum.ALC_SAFE,
      ALC_GHO_ALLOWANCE
    );
  }

  function _growthAllowances() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDC_A_TOKEN),
      MiscEthereum.AFC_SAFE,
      AFC_USDC_ALLOWANCE
    );

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDC_A_TOKEN),
      MiscEthereum.BUDGET_INCENTIVE_SAFE,
      BUDGET_INCENTIVE_USDC_ALLOWANCE
    );
  }

  function _reimbursements() internal {
    uint256 currentAllowance = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.TOKENLOGIC_FUNDING_RECEIVER
    );
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN),
      MiscEthereum.TOKENLOGIC_FUNDING_RECEIVER,
      currentAllowance + REIMBURSEMENTS_GHO_AMOUNT
    );
  }

  function _refreshSwapBudgets() internal {
    _setSwapBudget(AaveV3EthereumAssets.WETH_UNDERLYING, WETH_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.USDC_UNDERLYING, USDC_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.USDT_UNDERLYING, USDT_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.USDe_UNDERLYING, USDE_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.USDS_UNDERLYING, USDS_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.DAI_UNDERLYING, DAI_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.RLUSD_UNDERLYING, RLUSD_SWAP_BUDGET);
    _setSwapBudget(AaveV3EthereumAssets.PYUSD_UNDERLYING, PYUSD_SWAP_BUDGET);
  }

  function _setSwapBudget(address token, uint256 budget) internal {
    uint256 currentBudget = IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).tokenBudget(
      token
    );
    if (currentBudget > budget) {
      IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).decreaseTokenBudget(
        token,
        currentBudget - budget
      );
    } else if (currentBudget < budget) {
      IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
        token,
        budget - currentBudget
      );
    }
  }
}
