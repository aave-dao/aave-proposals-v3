// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {IMainnetSwapSteward} from 'src/interfaces/IMainnetSwapSteward.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase, ReserveConfig} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_November2026FundingUpdate_20261118} from './AaveV3Ethereum_November2026FundingUpdate_20261118.sol';

/**
 * @dev Test for AaveV3Ethereum_November2026FundingUpdate_20261118
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261118_Multi_November2026FundingUpdate/AaveV3Ethereum_November2026FundingUpdate_20261118.t.sol -vv
 */
contract AaveV3Ethereum_November2026FundingUpdate_20261118_Test is ProtocolV3TestBase {
  AaveV3Ethereum_November2026FundingUpdate_20261118 internal proposal;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26443067);
    proposal = new AaveV3Ethereum_November2026FundingUpdate_20261118();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_November2026FundingUpdate_20261118',
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

  function test_v4AuditGhoAllowance() public {
    uint256 allowanceBefore = IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
      address(AaveV3Ethereum.COLLECTOR),
      MiscEthereum.V4_AUDIT_DAO_WALLET_SECURITY
    );
    assertGt(
      allowanceBefore,
      proposal.V4_AUDIT_GHO_ALLOWANCE(),
      'V4 audit Safe allowance should be above the new amount before execution'
    );

    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3EthereumLidoAssets.GHO_A_TOKEN).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        MiscEthereum.V4_AUDIT_DAO_WALLET_SECURITY
      ),
      proposal.V4_AUDIT_GHO_ALLOWANCE(),
      'V4 audit Safe aEthLidoGHO allowance should be 250,000'
    );
  }

  function test_cancelAhabGhoAllowance() public {
    executePayload(vm, address(proposal));

    assertEq(
      IERC20(AaveV3EthereumAssets.GHO_A_TOKEN).allowance(
        address(AaveV3Ethereum.COLLECTOR),
        MiscEthereum.AHAB_SAFE
      ),
      0,
      'Ahab aEthGHO allowance should be cancelled'
    );
  }

  function test_depositETH() public {
    uint256 collectorEthBalanceBefore = address(AaveV3Ethereum.COLLECTOR).balance;
    assertGt(collectorEthBalanceBefore, 0, 'collector should hold ETH to deposit');
    uint256 aWethBalanceBefore = IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).balanceOf(
      address(AaveV3Ethereum.COLLECTOR)
    );

    executePayload(vm, address(proposal));

    assertEq(address(AaveV3Ethereum.COLLECTOR).balance, 0, 'collector should hold no ETH');
    assertApproxEqAbs(
      IERC20(AaveV3EthereumAssets.WETH_A_TOKEN).balanceOf(address(AaveV3Ethereum.COLLECTOR)),
      aWethBalanceBefore + collectorEthBalanceBefore,
      1,
      'aWETH not minted for the deposited ETH'
    );
  }

  function test_expandSwapSteward() public {
    address[4] memory tokens = [
      AaveV3EthereumAssets.USDtb_UNDERLYING,
      AaveV3EthereumAssets.USDG_UNDERLYING,
      AaveV3EthereumAssets.EURC_UNDERLYING,
      AaveV3EthereumAssets.sUSDe_UNDERLYING
    ];
    address[4] memory oracles = [
      AaveV3EthereumAssets.USDtb_ORACLE,
      AaveV3EthereumAssets.USDG_ORACLE,
      AaveV3EthereumAssets.EURC_ORACLE,
      AaveV3EthereumAssets.sUSDe_ORACLE
    ];
    uint256[4] memory budgets = [
      proposal.USDTB_SWAP_BUDGET(),
      proposal.USDG_SWAP_BUDGET(),
      proposal.EURC_SWAP_BUDGET(),
      proposal.SUSDE_SWAP_BUDGET()
    ];
    IMainnetSwapSteward steward = IMainnetSwapSteward(AaveV3Ethereum.COLLECTOR_SWAP_STEWARD);

    for (uint256 i = 0; i < tokens.length; i++) {
      assertEq(steward.priceOracle(tokens[i]), address(0), 'oracle should not be set before');
      assertFalse(
        steward.swapApprovedToken(tokens[i], AaveV3EthereumAssets.GHO_UNDERLYING),
        'token should not be swappable to GHO before'
      );
      assertEq(steward.tokenBudget(tokens[i]), 0, 'budget should be zero before');
    }

    executePayload(vm, address(proposal));

    for (uint256 i = 0; i < tokens.length; i++) {
      assertEq(steward.priceOracle(tokens[i]), oracles[i], 'unexpected oracle');
      assertTrue(
        steward.swapApprovedToken(tokens[i], AaveV3EthereumAssets.GHO_UNDERLYING),
        'token should be swappable to GHO'
      );
      assertEq(steward.tokenBudget(tokens[i]), budgets[i], 'unexpected budget');
    }
  }

  function test_bugBounty() public {
    IERC20 usdc = IERC20(AaveV3EthereumAssets.USDC_UNDERLYING);
    IERC20 aUsdc = IERC20(AaveV3EthereumAssets.USDC_A_TOKEN);
    uint256 aUsdcCollectorBefore = aUsdc.balanceOf(address(AaveV3Ethereum.COLLECTOR));
    assertGe(
      aUsdcCollectorBefore,
      proposal.BUGBOUNTY_AMOUNT() + proposal.BUGBOUNTY_FEE(),
      'collector should hold enough aUSDC'
    );
    uint256 balanceBeforeRecipient = usdc.balanceOf(proposal.BUGBOUNTY_RECEIVER());
    uint256 balanceBeforeImmunefi = usdc.balanceOf(proposal.IMMUNEFI());

    executePayload(vm, address(proposal));

    // aToken rounding can add a few wei to the withdrawn amount
    assertApproxEqAbs(
      usdc.balanceOf(proposal.BUGBOUNTY_RECEIVER()),
      balanceBeforeRecipient + proposal.BUGBOUNTY_AMOUNT(),
      10,
      'researcher should receive the bug bounty in USDC'
    );
    assertApproxEqAbs(
      usdc.balanceOf(proposal.IMMUNEFI()),
      balanceBeforeImmunefi + proposal.BUGBOUNTY_FEE(),
      10,
      'Immunefi should receive the fee in USDC'
    );
    assertApproxEqAbs(
      aUsdc.balanceOf(address(AaveV3Ethereum.COLLECTOR)),
      aUsdcCollectorBefore - proposal.BUGBOUNTY_AMOUNT() - proposal.BUGBOUNTY_FEE(),
      10,
      'collector aUSDC should decrease by the paid amount'
    );
  }
}
