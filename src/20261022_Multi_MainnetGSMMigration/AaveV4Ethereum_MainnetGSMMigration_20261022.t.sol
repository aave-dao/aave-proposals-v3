// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {AaveV4EthereumAssets, AaveV4EthereumHubs, AaveV4EthereumTokenizationSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';

import 'forge-std/Test.sol';
import {ProtocolV4TestBaseEthereum} from 'aave-helpers/src/v4-protocol-test/ProtocolV4TestBaseEthereum.sol';
import {AaveV4Ethereum_MainnetGSMMigration_20261022} from './AaveV4Ethereum_MainnetGSMMigration_20261022.sol';

/**
 * @dev Test for AaveV4Ethereum_MainnetGSMMigration_20261022
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261022_Multi_MainnetGSMMigration/AaveV4Ethereum_MainnetGSMMigration_20261022.t.sol -vv
 */
contract AaveV4Ethereum_MainnetGSMMigration_20261022_Test is ProtocolV4TestBaseEthereum {
  using SafeERC20 for IERC20;

  AaveV4Ethereum_MainnetGSMMigration_20261022 internal proposal;

  IHub internal constant CORE_HUB = IHub(address(AaveV4EthereumHubs.CORE_HUB));
  address internal constant WA_CORE_USDC =
    address(AaveV4EthereumTokenizationSpokes.CORE_USDC_TOKENIZATION_SPOKE);
  address internal constant WA_CORE_USDT =
    address(AaveV4EthereumTokenizationSpokes.CORE_USDT_TOKENIZATION_SPOKE);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26248572);
    proposal = new AaveV4Ethereum_MainnetGSMMigration_20261022();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest('AaveV4Ethereum_MainnetGSMMigration_20261022', address(proposal));
  }

  /// --- Hub spoke config updates ---

  function test_coreUsdcTokenizationSpokeAddCap() public {
    _assertAddCapRaised(
      AaveV4EthereumAssets.USDC_UNDERLYING,
      WA_CORE_USDC,
      proposal.CORE_USDC_TOKENIZATION_SPOKE_ADD_CAP()
    );
  }

  function test_coreUsdtTokenizationSpokeAddCap() public {
    _assertAddCapRaised(
      AaveV4EthereumAssets.USDT_UNDERLYING,
      WA_CORE_USDT,
      proposal.CORE_USDT_TOKENIZATION_SPOKE_ADD_CAP()
    );
  }

  /// --- Post-execution behaviour ---

  function test_depositAboveOldAddCap_USDC() public {
    _assertDepositAboveOldAddCap(AaveV4EthereumAssets.USDC_UNDERLYING, WA_CORE_USDC);
  }

  function test_depositAboveOldAddCap_USDT() public {
    _assertDepositAboveOldAddCap(AaveV4EthereumAssets.USDT_UNDERLYING, WA_CORE_USDT);
  }

  /// --- Helpers ---

  function _assertAddCapRaised(address underlying, address spoke, uint256 newAddCap) internal {
    uint256 assetId = CORE_HUB.getAssetId(underlying);
    assertEq(IWaToken(spoke).assetId(), assetId, 'spoke not tokenizing the expected asset');
    IHub.SpokeConfig memory configBefore = CORE_HUB.getSpokeConfig(assetId, spoke);
    assertLt(uint256(configBefore.addCap), newAddCap, 'add cap not lower before');

    executePayload(vm, address(proposal));

    IHub.SpokeConfig memory configAfter = CORE_HUB.getSpokeConfig(assetId, spoke);
    assertEq(uint256(configAfter.addCap), newAddCap, 'wrong add cap');
    // Everything else is kept
    assertEq(configAfter.drawCap, configBefore.drawCap, 'draw cap changed');
    assertEq(
      configAfter.riskPremiumThreshold,
      configBefore.riskPremiumThreshold,
      'risk premium threshold changed'
    );
    assertEq(configAfter.active, configBefore.active, 'active flag changed');
    assertEq(configAfter.halted, configBefore.halted, 'halted flag changed');
  }

  function _assertDepositAboveOldAddCap(address underlying, address spoke) internal {
    uint256 assetId = CORE_HUB.getAssetId(underlying);
    uint256 oldAddCapAmount = uint256(CORE_HUB.getSpokeConfig(assetId, spoke).addCap) *
      10 ** IERC4626(spoke).decimals();
    // Deposit above the old add cap, regardless of what the spoke already holds
    uint256 amount = oldAddCapAmount + IERC4626(spoke).totalAssets();
    assertLt(IERC4626(spoke).maxDeposit(address(this)), amount, 'deposit fits before');

    executePayload(vm, address(proposal));

    assertGe(IERC4626(spoke).maxDeposit(address(this)), amount, 'deposit does not fit after');
    deal(underlying, address(this), amount);
    IERC20(underlying).forceApprove(spoke, amount);
    uint256 expectedShares = IERC4626(spoke).previewDeposit(amount);
    uint256 shares = IERC4626(spoke).deposit(amount, address(this));
    assertEq(shares, expectedShares, 'wrong shares minted');
    assertEq(IERC20(spoke).balanceOf(address(this)), shares, 'shares not received');
  }
}

interface IWaToken {
  function assetId() external view returns (uint256);
}
