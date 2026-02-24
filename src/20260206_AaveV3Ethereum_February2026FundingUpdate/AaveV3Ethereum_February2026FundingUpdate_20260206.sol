// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IWrappedTokenGatewayV3} from 'aave-v3-origin/contracts/helpers/interfaces/IWrappedTokenGatewayV3.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

interface IMainnetSwapSteward {
  function increaseTokenBudget(address token, uint256 budget) external;
}

/**
 * @title February 2026 - Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-february-2026-funding-update/24030
 */
contract AaveV3Ethereum_February2026FundingUpdate_20260206 is IProposalGenericExecutor {
  // Aave Liquidity SAFE
  // https://etherscan.io/address/0xAAA973Fe8A6202947e21D0a3a43d8E83ABE35C23
  address public constant AAVE_LIQUIDITY_SAFE = 0xAAA973Fe8A6202947e21D0a3a43d8E83ABE35C23;

  // Reimbursements
  // https://etherscan.io/address/0xac140648435d03f784879cd789130F22Ef588Fcd
  address public constant ACI_SAFE = 0xac140648435d03f784879cd789130F22Ef588Fcd;
  // https://etherscan.io/address/0xAA088dfF3dcF619664094945028d44E779F19894
  address public constant TOKEN_LOGIC = 0xAA088dfF3dcF619664094945028d44E779F19894;

  uint256 public constant ACI_REIMBURSE_AWETH_AMOUNT = 1.470836210916653291 ether;
  uint256 public constant TOKENLOGIC_REIMBURSE_GHO_AMOUNT = 26_000 ether;

  uint256 public constant AFC_AAVE_AMOUNT = 100_000 ether;
  uint256 public constant AHAB_WETH_AMOUNT = 4_000 ether;
  uint256 public constant AHAB_WSTETH_AMOUNT = 1_100 ether;
  uint256 public constant CEX_EARN_USDE_AMOUNT = 6_000_000 ether;

  uint256 public constant LIQUIDITY_AAVE_AMOUNT = 40_000 ether;
  uint256 public constant LIQUIDITY_WETH_AMOUNT = 1_500 ether;

  uint256 public constant ETH_SWAP_BUDGET_AMOUNT = 3_000 ether;
  uint256 public constant USDC_SWAP_BUDGET_AMOUNT = 5_000_000e6;
  uint256 public constant USDT_SWAP_BUDGET_AMOUNT = 5_000_000e6;
  uint256 public constant USDE_SWAP_BUDGET_AMOUNT = 5_000_000 ether;
  uint256 public constant USDS_SWAP_BUDGET_AMOUNT = 2_000_000 ether;
  uint256 public constant DAI_SWAP_BUDGET_AMOUNT = 2_000_000 ether;

  function execute() external {
    _aaveApprovals();
    _depositEth();
    _ahab();
    _liquidityApprovals();
    _cexEarnApproval();
    _reimbursements();
    _replenishAllowances();
  }

  function _aaveApprovals() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.AAVE_UNDERLYING),
      MiscEthereum.AFC_SAFE,
      AFC_AAVE_AMOUNT
    );
  }

  function _depositEth() internal {
    uint256 ethBalance = address(AaveV3Ethereum.COLLECTOR).balance;
    if (ethBalance > 0) {
      AaveV3Ethereum.COLLECTOR.transfer(
        IERC20(AaveV3Ethereum.COLLECTOR.ETH_MOCK_ADDRESS()),
        address(this),
        ethBalance
      );
      IWrappedTokenGatewayV3(AaveV3Ethereum.WETH_GATEWAY).depositETH{value: ethBalance}(
        address(AaveV3Ethereum.POOL),
        address(AaveV3Ethereum.COLLECTOR),
        0
      );
    }
  }

  function _ahab() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN),
      MiscEthereum.AHAB_SAFE,
      AHAB_WETH_AMOUNT
    );

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.wstETH_A_TOKEN),
      MiscEthereum.AHAB_SAFE,
      AHAB_WSTETH_AMOUNT
    );
  }

  function _liquidityApprovals() internal {
    MiscEthereum.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
      MiscEthereum.ECOSYSTEM_RESERVE,
      AaveV3EthereumAssets.AAVE_UNDERLYING,
      AAVE_LIQUIDITY_SAFE,
      LIQUIDITY_AAVE_AMOUNT
    );

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN),
      AAVE_LIQUIDITY_SAFE,
      LIQUIDITY_WETH_AMOUNT
    );
  }

  function _cexEarnApproval() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.USDe_UNDERLYING),
      MiscEthereum.AFC_CEX_EARN_SAFE,
      CEX_EARN_USDE_AMOUNT
    );
  }

  function _reimbursements() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN),
      ACI_SAFE,
      ACI_REIMBURSE_AWETH_AMOUNT
    );
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN),
      TOKEN_LOGIC,
      TOKENLOGIC_REIMBURSE_GHO_AMOUNT
    );
  }

  function _replenishAllowances() internal {
    IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
      AaveV3Ethereum.COLLECTOR.ETH_MOCK_ADDRESS(),
      ETH_SWAP_BUDGET_AMOUNT
    );
    IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
      AaveV3EthereumAssets.USDC_UNDERLYING,
      USDC_SWAP_BUDGET_AMOUNT
    );
    IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
      AaveV3EthereumAssets.USDT_UNDERLYING,
      USDT_SWAP_BUDGET_AMOUNT
    );
    IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
      AaveV3EthereumAssets.USDe_UNDERLYING,
      USDE_SWAP_BUDGET_AMOUNT
    );
    IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
      AaveV3EthereumAssets.USDS_UNDERLYING,
      USDS_SWAP_BUDGET_AMOUNT
    );
    IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD).increaseTokenBudget(
      AaveV3EthereumAssets.DAI_UNDERLYING,
      DAI_SWAP_BUDGET_AMOUNT
    );
  }
}
