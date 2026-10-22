// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV4EthereumTokenizationSpokes} from 'aave-address-book/AaveV4Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IAaveCLRobotOperator} from 'src/interfaces/IAaveCLRobotOperator.sol';

/**
 * @title Mainnet GSM migration
 * @author TokenLogic
 * - Snapshot: TODO
 * - Discussion: TODO
 * @dev Must execute after AaveV4Ethereum_MainnetGSMMigration_20261022, which raises the add caps of the
 * Core USDC and USDT TokenizationSpokes.
 */
contract AaveV3Ethereum_MainnetGSMMigration_20261022 is IProposalGenericExecutor {
  using SafeERC20 for IERC20;

  // TODO: replace with the deployed Gsm4626 over AaveV4EthereumTokenizationSpokes.CORE_USDC_TOKENIZATION_SPOKE
  address public constant NEW_GSM_USDC = 0x40af54c6473EB9a539640edb4a8713E339dc0695;

  // TODO: replace with the deployed Gsm4626 over AaveV4EthereumTokenizationSpokes.CORE_USDT_TOKENIZATION_SPOKE
  address public constant NEW_GSM_USDT = 0xEBb7a5F5A27CbE02bbf09Dbace6014a1979c25d3;

  // TODO: replace with the deployed ChainlinkOracleSwapFreezer of NEW_GSM_USDC
  address public constant NEW_USDC_ORACLE_SWAP_FREEZER = 0x1c0F6AFC7F9249190732Fd07a44Ed28aF74E893A;

  // TODO: replace with the deployed ChainlinkOracleSwapFreezer of NEW_GSM_USDT
  address public constant NEW_USDT_ORACLE_SWAP_FREEZER = 0x1CB1588f0612E565BD3A65a83A9aBce106aCbB0b;

  // TODO: re-check caps and limits with the risk providers before going live
  uint128 public constant EXPOSURE_CAP_GSM_USDC = 90_000_000e6;
  uint128 public constant EXPOSURE_CAP_GSM_USDT = 85_000_000e6;
  uint128 public constant RESERVE_LIMIT_GSM_USDC = 100_000_000 ether;
  uint128 public constant RESERVE_LIMIT_GSM_USDT = 100_000_000 ether;

  // Keepers of the existing OracleSwapFreezers, already cancelled by the Chainlink Automation registry owner
  uint256 public constant EXISTING_ORACLE_SWAP_FREEZER_USDC =
    40831331354266106136802006200984629111720755373652730762609034360418296310552;
  uint256 public constant EXISTING_ORACLE_SWAP_FREEZER_USDT =
    14446266862268986374588159863529042189061116405334267310786859452241069238244;

  bytes32 public immutable LIQUIDATOR_ROLE = IGsm(GhoEthereum.GSM_USDC).LIQUIDATOR_ROLE();
  bytes32 public immutable SWAP_FREEZER_ROLE = IGsm(GhoEthereum.GSM_USDC).SWAP_FREEZER_ROLE();
  bytes32 public immutable CONFIGURATOR_ROLE = IGsm(GhoEthereum.GSM_USDC).CONFIGURATOR_ROLE();

  function execute() external {
    uint256 seizedStataUsdt = _seize();
    _grantAccess();
    _updateFeeStrategy();
    uint256 acquiredGho = _migrateUsdtBacking(seizedStataUsdt);
    _burnAfterSeize(acquiredGho);
    _revokeAccess();
  }

  function _seize() internal returns (uint256) {
    IGsm(GhoEthereum.GSM_USDC).distributeFeesToTreasury();
    IGsm(GhoEthereum.GSM_USDT).distributeFeesToTreasury();

    IGsm(GhoEthereum.GSM_USDC).grantRole(LIQUIDATOR_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(GhoEthereum.GSM_USDT).grantRole(LIQUIDATOR_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);

    // stataUSDC dust stays in the Collector
    IGsm(GhoEthereum.GSM_USDC).seize();
    return IGsm(GhoEthereum.GSM_USDT).seize();
  }

  function _grantAccess() internal {
    // Enroll GSMs as entities and set limit
    IGhoReserve(GhoEthereum.GHO_RESERVE).addEntity(NEW_GSM_USDC);
    IGhoReserve(GhoEthereum.GHO_RESERVE).addEntity(NEW_GSM_USDT);

    IGhoReserve(GhoEthereum.GHO_RESERVE).setLimit(NEW_GSM_USDC, RESERVE_LIMIT_GSM_USDC);
    IGhoReserve(GhoEthereum.GHO_RESERVE).setLimit(NEW_GSM_USDT, RESERVE_LIMIT_GSM_USDT);

    IGsm(NEW_GSM_USDC).updateExposureCap(EXPOSURE_CAP_GSM_USDC);
    IGsm(NEW_GSM_USDT).updateExposureCap(EXPOSURE_CAP_GSM_USDT);

    // Add GSM Swap Freezer role to OracleSwapFreezers
    IGsm(NEW_GSM_USDC).grantRole(SWAP_FREEZER_ROLE, NEW_USDC_ORACLE_SWAP_FREEZER);
    IGsm(NEW_GSM_USDT).grantRole(SWAP_FREEZER_ROLE, NEW_USDT_ORACLE_SWAP_FREEZER);
    IGsm(NEW_GSM_USDC).grantRole(SWAP_FREEZER_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(NEW_GSM_USDT).grantRole(SWAP_FREEZER_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);

    // Add GSMs to GSM Registry
    IGsmRegistry(GhoEthereum.GSM_REGISTRY).addGsm(NEW_GSM_USDC);
    IGsmRegistry(GhoEthereum.GSM_REGISTRY).addGsm(NEW_GSM_USDT);

    // GHO GSM Steward
    IGsm(NEW_GSM_USDC).grantRole(CONFIGURATOR_ROLE, GhoEthereum.GHO_GSM_STEWARD);
    IGsm(NEW_GSM_USDT).grantRole(CONFIGURATOR_ROLE, GhoEthereum.GHO_GSM_STEWARD);
  }

  function _updateFeeStrategy() internal {
    IGsm(NEW_GSM_USDC).updateFeeStrategy(IGsm(GhoEthereum.GSM_USDC).getFeeStrategy());
    IGsm(NEW_GSM_USDT).updateFeeStrategy(IGsm(GhoEthereum.GSM_USDT).getFeeStrategy());
  }

  /**
   * @dev Moves the seized stataUSDT backing into the new USDT GSM:
   * stataUSDT -> USDT (Aave V3) -> waCoreUSDT (Aave V4 Core TokenizationSpoke) -> GHO (new USDT GSM)
   * @return The amount of GHO acquired by selling the waCoreUSDT shares to the new USDT GSM
   */
  function _migrateUsdtBacking(uint256 stataAmount) internal returns (uint256) {
    address tokenizationSpoke = address(
      AaveV4EthereumTokenizationSpokes.CORE_USDT_TOKENIZATION_SPOKE
    );

    AaveV3Ethereum.COLLECTOR.transfer(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN),
      address(this),
      stataAmount
    );
    uint256 usdtAmount = IERC4626(AaveV3EthereumAssets.USDT_STATA_TOKEN).redeem(
      stataAmount,
      address(this),
      address(this)
    );

    IERC20(AaveV3EthereumAssets.USDT_UNDERLYING).forceApprove(tokenizationSpoke, usdtAmount);
    uint256 shares = IERC4626(tokenizationSpoke).deposit(usdtAmount, address(this));

    IERC20(tokenizationSpoke).forceApprove(NEW_GSM_USDT, shares);
    (uint256 soldShares, uint256 acquiredGho) = IGsm(NEW_GSM_USDT).sellAsset(shares, address(this));

    // Send to collector any share dust not taken by the GSM
    if (shares > soldShares) {
      IERC20(tokenizationSpoke).safeTransfer(
        address(AaveV3Ethereum.COLLECTOR),
        shares - soldShares
      );
    }

    return acquiredGho;
  }

  function _burnAfterSeize(uint256 acquiredGho) internal {
    uint256 ghoUsdcNeeded = IGhoReserve(GhoEthereum.GHO_RESERVE).getUsed(GhoEthereum.GSM_USDC);
    uint256 ghoUsdtNeeded = IGhoReserve(GhoEthereum.GHO_RESERVE).getUsed(GhoEthereum.GSM_USDT);
    uint256 neededGho = ghoUsdcNeeded + ghoUsdtNeeded;

    // Cover the USDC GSM used amount and any rounding shortfall of the USDT migration from the treasury
    if (neededGho > acquiredGho) {
      AaveV3Ethereum.COLLECTOR.transfer(
        IERC20(GhoEthereum.GHO_TOKEN),
        address(this),
        neededGho - acquiredGho
      );
    }

    if (ghoUsdcNeeded > 0) {
      IERC20(GhoEthereum.GHO_TOKEN).forceApprove(GhoEthereum.GSM_USDC, ghoUsdcNeeded);
      IGsm(GhoEthereum.GSM_USDC).burnAfterSeize(ghoUsdcNeeded);
    }
    if (ghoUsdtNeeded > 0) {
      IERC20(GhoEthereum.GHO_TOKEN).forceApprove(GhoEthereum.GSM_USDT, ghoUsdtNeeded);
      IGsm(GhoEthereum.GSM_USDT).burnAfterSeize(ghoUsdtNeeded);
    }

    // Send to collector any positive difference
    if (acquiredGho > neededGho) {
      IERC20(GhoEthereum.GHO_TOKEN).safeTransfer(
        address(AaveV3Ethereum.COLLECTOR),
        acquiredGho - neededGho
      );
    }
  }

  function _revokeAccess() internal {
    // Remove existing GSMs from Reserve and Registry
    IGhoReserve(GhoEthereum.GHO_RESERVE).setLimit(GhoEthereum.GSM_USDC, 0);
    IGhoReserve(GhoEthereum.GHO_RESERVE).setLimit(GhoEthereum.GSM_USDT, 0);
    IGhoReserve(GhoEthereum.GHO_RESERVE).removeEntity(GhoEthereum.GSM_USDC);
    IGhoReserve(GhoEthereum.GHO_RESERVE).removeEntity(GhoEthereum.GSM_USDT);

    IGsmRegistry(GhoEthereum.GSM_REGISTRY).removeGsm(GhoEthereum.GSM_USDC);
    IGsmRegistry(GhoEthereum.GSM_REGISTRY).removeGsm(GhoEthereum.GSM_USDT);

    // Revoke Roles
    IGsm(GhoEthereum.GSM_USDC).revokeRole(
      SWAP_FREEZER_ROLE,
      GhoEthereum.GSM_USDC_ORACLE_SWAP_FREEZER
    );
    IGsm(GhoEthereum.GSM_USDT).revokeRole(
      SWAP_FREEZER_ROLE,
      GhoEthereum.GSM_USDT_ORACLE_SWAP_FREEZER
    );
    IGsm(GhoEthereum.GSM_USDC).revokeRole(SWAP_FREEZER_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(GhoEthereum.GSM_USDT).revokeRole(SWAP_FREEZER_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);

    IGsm(GhoEthereum.GSM_USDC).revokeRole(LIQUIDATOR_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(GhoEthereum.GSM_USDT).revokeRole(LIQUIDATOR_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);

    // GHO GSM Steward
    IGsm(GhoEthereum.GSM_USDC).revokeRole(CONFIGURATOR_ROLE, GhoEthereum.GHO_GSM_STEWARD);
    IGsm(GhoEthereum.GSM_USDT).revokeRole(CONFIGURATOR_ROLE, GhoEthereum.GHO_GSM_STEWARD);

    // Withdraw the LINK left in the cancelled existing keepers to the Collector
    IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR).withdrawLink(
      EXISTING_ORACLE_SWAP_FREEZER_USDC
    );
    IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR).withdrawLink(
      EXISTING_ORACLE_SWAP_FREEZER_USDT
    );
  }
}
