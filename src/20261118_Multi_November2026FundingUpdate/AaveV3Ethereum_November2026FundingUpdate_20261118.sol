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
 * @title November 2026 Funding Update
 * @author TokenLogic
 * - Snapshot: Direct-to-AIP
 * - Discussion: https://governance.aave.com/t/direct-to-aip-november-2026-funding-update/26312
 */
contract AaveV3Ethereum_November2026FundingUpdate_20261118 is IProposalGenericExecutor {
  // https://etherscan.io/address/0x0DDE46b923eB74F1860727914f179e82b9eE47B9
  address public constant BUGBOUNTY_RECEIVER = 0x0DDE46b923eB74F1860727914f179e82b9eE47B9;

  // https://etherscan.io/address/0x7119f398b6C06095c6E8964C1f58e7C1BAa79E18
  address public constant IMMUNEFI = 0x7119f398b6C06095c6E8964C1f58e7C1BAa79E18;
  uint256 public constant BUGBOUNTY_AMOUNT = 1_000e6;
  uint256 public constant BUGBOUNTY_FEE = 100e6;

  uint256 public constant V4_AUDIT_GHO_ALLOWANCE = 250_000 ether;

  uint256 public constant USDTB_SWAP_BUDGET = 625_000 ether;
  uint256 public constant USDG_SWAP_BUDGET = 385_000e6;
  uint256 public constant EURC_SWAP_BUDGET = 175_000e6;
  uint256 public constant SUSDE_SWAP_BUDGET = 125_000 ether;

  function execute() external {
    _allowances();
    _depositEth();
    _expandSwapSteward();
    _bugBounty();
  }

  function _allowances() internal {
    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN),
      MiscEthereum.V4_AUDIT_DAO_WALLET_SECURITY,
      V4_AUDIT_GHO_ALLOWANCE
    );

    AaveV3Ethereum.COLLECTOR.approve(
      IERC20(AaveV3EthereumAssets.GHO_A_TOKEN),
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

  function _expandSwapSteward() internal {
    _addSwapToken(
      AaveV3EthereumAssets.USDtb_UNDERLYING,
      AaveV3EthereumAssets.USDtb_ORACLE,
      USDTB_SWAP_BUDGET
    );
    _addSwapToken(
      AaveV3EthereumAssets.USDG_UNDERLYING,
      AaveV3EthereumAssets.USDG_ORACLE,
      USDG_SWAP_BUDGET
    );
    _addSwapToken(
      AaveV3EthereumAssets.EURC_UNDERLYING,
      AaveV3EthereumAssets.EURC_ORACLE,
      EURC_SWAP_BUDGET
    );
    _addSwapToken(
      AaveV3EthereumAssets.sUSDe_UNDERLYING,
      AaveV3EthereumAssets.sUSDe_ORACLE,
      SUSDE_SWAP_BUDGET
    );
  }

  function _addSwapToken(address token, address oracle, uint256 budget) internal {
    IMainnetSwapSteward steward = IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD);
    steward.setTokenOracle(token, oracle);
    steward.setSwappablePair(token, AaveV3EthereumAssets.GHO_UNDERLYING, true);
    steward.increaseTokenBudget(token, budget);
  }

  function _bugBounty() internal {
    _payUsdc(BUGBOUNTY_RECEIVER, BUGBOUNTY_AMOUNT);
    _payUsdc(IMMUNEFI, BUGBOUNTY_FEE);
  }

  function _payUsdc(address receiver, uint256 amount) internal {
    AaveV3Ethereum.COLLECTOR.transfer(
      IERC20(AaveV3EthereumAssets.USDC_A_TOKEN),
      address(this),
      amount
    );
    AaveV3Ethereum.POOL.withdraw(AaveV3EthereumAssets.USDC_UNDERLYING, type(uint256).max, receiver);
  }
}
