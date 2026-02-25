// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {CollectorUtils, ICollector} from 'aave-helpers/src/CollectorUtils.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {IGhoBucketSteward} from 'src/interfaces/IGhoBucketSteward.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';
import {IAaveCLRobotOperator} from 'src/interfaces/IAaveCLRobotOperator.sol';
import {IGhoDirectFacilitator} from 'src/interfaces/IGhoDirectFacilitator.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';

/**
 * @title GSM Migration
 * @author @TokenLogic
 * - Snapshot: https://snapshot.box/#/s:aavedao.eth/proposal/0xeb3572580924976867073ad9c8012cb9e52093c76dafebd7d3aebf318f2576fb
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-plasma-set-aci-as-emissions-manager-for-rewards/22994/8
 */
contract AaveV3Ethereum_GSMMigration_20251113 is IProposalGenericExecutor {
  using SafeERC20 for IERC20;
  using CollectorUtils for ICollector;

  // GhoDirectFacilitator Constants
  address public constant DIRECT_FACILITATOR = 0xE9ac5231fAecb633dA0Fe85Fcb2785b8363427d2;
  string public constant DIRECT_FACILITATOR_NAME = 'GhoDirectFacilitator GSMs Mainnet';
  uint128 public constant DIRECT_FACILITATOR_CAPACITY = 180_000_000 ether;

  // GhoReserve
  // https://etherscan.io/address/0x54C58157DeF387A880AE62332D1445f03adbE7E9
  address public constant GHO_RESERVE = 0x54C58157DeF387A880AE62332D1445f03adbE7E9;

  // GSM Draw Limits
  uint128 public constant RESERVE_LIMIT_GSM_USDC = 110_000_000 ether;
  uint128 public constant RESERVE_LIMIT_GSM_USDT = 70_000_000 ether;

  // https://etherscan.io/address/0x3a3868898305f04bec7fea77becff04c13444112
  address public constant NEW_GSM_USDC = 0x3A3868898305f04beC7FEa77BecFf04C13444112;

  // https://etherscan.io/address/0x6e51936e0ED4256f9dA4794B536B619c88Ff0047
  address public constant USDC_ORACLE_SWAP_FREEZER = 0x6e51936e0ED4256f9dA4794B536B619c88Ff0047;

  // https://etherscan.io/address/0x882285e62656b9623af136ce3078c6bdcc33f5e3
  address public constant NEW_GSM_USDT = 0x882285E62656b9623AF136Ce3078c6BdCc33F5E3;

  // https://etherscan.io/address/0x733AB16005c39d07FD3D9d1A350AA6768D10125b
  address public constant USDT_ORACLE_SWAP_FREEZER = 0x733AB16005c39d07FD3D9d1A350AA6768D10125b;

  uint96 public constant LINK_AMOUNT_ORACLE_FREEZER_KEEPER = 80 ether;
  uint96 public constant TOTAL_LINK_AMOUNT_KEEPERS = LINK_AMOUNT_ORACLE_FREEZER_KEEPER * 2; // 2 GSMs
  uint32 public constant KEEPER_GAS_LIMIT = 150_000;

  uint256 public constant EXISTING_ORACLE_SWAP_FREEZER_USDC =
    85153843967789017760384794934034524869526055173666527804449435339462659418687;
  uint256 public constant EXISTING_ORACLE_SWAP_FREEZER_USDT =
    113117985912495124427864354142901529291134634735835568280477108198234580494999;

  bytes32 public immutable LIQUIDATOR_ROLE = IGsm(GhoEthereum.GSM_USDC).LIQUIDATOR_ROLE();
  bytes32 public immutable SWAP_FREEZER_ROLE = IGsm(GhoEthereum.GSM_USDC).SWAP_FREEZER_ROLE();

  function execute() external {
    uint256 balanceUsdc = IGsm(GhoEthereum.GSM_USDC).getAvailableLiquidity();
    uint256 balanceUsdt = IGsm(GhoEthereum.GSM_USDT).getAvailableLiquidity();

    IGhoToken(AaveV3EthereumAssets.GHO_UNDERLYING).addFacilitator(
      DIRECT_FACILITATOR,
      DIRECT_FACILITATOR_NAME,
      DIRECT_FACILITATOR_CAPACITY
    );

    _updateNewGsms();
    _seize();
    _grantAccess();
    _updateFeeStrategy();
    _registerOracles();
    _fund(balanceUsdc, balanceUsdt);
    _revokeAccess();
  }

  function _updateNewGsms() internal {
    IGsm(NEW_GSM_USDC).updateExposureCap(IGsm(GhoEthereum.GSM_USDC).getExposureCap());
    IGsm(NEW_GSM_USDT).updateExposureCap(IGsm(GhoEthereum.GSM_USDT).getExposureCap());

    IGsm(NEW_GSM_USDC).updateGhoReserve(GHO_RESERVE);
    IGsm(NEW_GSM_USDT).updateGhoReserve(GHO_RESERVE);
  }

  function _seize() internal {
    IGsm(GhoEthereum.GSM_USDC).distributeFeesToTreasury();
    IGsm(GhoEthereum.GSM_USDT).distributeFeesToTreasury();

    IGsm(GhoEthereum.GSM_USDC).grantRole(LIQUIDATOR_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(GhoEthereum.GSM_USDT).grantRole(LIQUIDATOR_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);

    IGsm(GhoEthereum.GSM_USDC).seize();
    IGsm(GhoEthereum.GSM_USDT).seize();
  }

  function _grantAccess() internal {
    address[] memory vaults = new address[](1);
    vaults[0] = DIRECT_FACILITATOR;
    IGhoBucketSteward(GhoEthereum.GHO_BUCKET_STEWARD).setControlledFacilitator(vaults, true);

    // Enroll GSMs as entities and set limit
    IGhoReserve(GHO_RESERVE).addEntity(NEW_GSM_USDC);
    IGhoReserve(GHO_RESERVE).addEntity(NEW_GSM_USDT);

    IGhoReserve(GHO_RESERVE).setLimit(NEW_GSM_USDC, RESERVE_LIMIT_GSM_USDC);
    IGhoReserve(GHO_RESERVE).setLimit(NEW_GSM_USDT, RESERVE_LIMIT_GSM_USDT);

    // Grant roles to control supply of GHO
    IGhoReserve(GHO_RESERVE).grantRole(
      IGhoReserve(GHO_RESERVE).LIMIT_MANAGER_ROLE(),
      GhoEthereum.RISK_COUNCIL
    );

    IGhoDirectFacilitator(DIRECT_FACILITATOR).grantRole(
      IGhoDirectFacilitator(DIRECT_FACILITATOR).MINTER_ROLE(),
      GhoEthereum.RISK_COUNCIL
    );

    // Add GSM Swap Freezer role to OracleSwapFreezers
    IGsm(NEW_GSM_USDC).grantRole(SWAP_FREEZER_ROLE, USDC_ORACLE_SWAP_FREEZER);
    IGsm(NEW_GSM_USDT).grantRole(SWAP_FREEZER_ROLE, USDT_ORACLE_SWAP_FREEZER);
    IGsm(NEW_GSM_USDC).grantRole(SWAP_FREEZER_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IGsm(NEW_GSM_USDT).grantRole(SWAP_FREEZER_ROLE, GovernanceV3Ethereum.EXECUTOR_LVL_1);

    // Add GSMs to GSM Registry
    IGsmRegistry(GhoEthereum.GSM_REGISTRY).addGsm(NEW_GSM_USDC);
    IGsmRegistry(GhoEthereum.GSM_REGISTRY).addGsm(NEW_GSM_USDT);

    // GHO GSM Steward
    IGsm(NEW_GSM_USDC).grantRole(
      IGsm(NEW_GSM_USDC).CONFIGURATOR_ROLE(),
      GhoEthereum.GHO_GSM_STEWARD
    );
    IGsm(NEW_GSM_USDT).grantRole(
      IGsm(NEW_GSM_USDT).CONFIGURATOR_ROLE(),
      GhoEthereum.GHO_GSM_STEWARD
    );
  }

  function _updateFeeStrategy() internal {
    IGsm(NEW_GSM_USDC).updateFeeStrategy(IGsm(GhoEthereum.GSM_USDC).getFeeStrategy());
    IGsm(NEW_GSM_USDT).updateFeeStrategy(IGsm(GhoEthereum.GSM_USDT).getFeeStrategy());
  }

  function _registerOracles() internal {
    uint256 withdrawnBalance = AaveV3Ethereum.COLLECTOR.withdrawFromV3(
      CollectorUtils.IOInput({
        pool: address(AaveV3Ethereum.POOL),
        underlying: AaveV3EthereumAssets.LINK_UNDERLYING,
        amount: TOTAL_LINK_AMOUNT_KEEPERS
      }),
      address(this)
    );
    IERC20(AaveV3EthereumAssets.LINK_UNDERLYING).forceApprove(
      MiscEthereum.AAVE_CL_ROBOT_OPERATOR,
      withdrawnBalance
    );

    IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR).register(
      'GHO GSM 4626 stataUSDC OracleSwapFreezer',
      USDC_ORACLE_SWAP_FREEZER,
      '',
      KEEPER_GAS_LIMIT,
      LINK_AMOUNT_ORACLE_FREEZER_KEEPER,
      0,
      ''
    );
    IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR).register(
      'GHO GSM 4626 stataUSDT OracleSwapFreezer',
      USDT_ORACLE_SWAP_FREEZER,
      '',
      KEEPER_GAS_LIMIT,
      uint96(withdrawnBalance) - LINK_AMOUNT_ORACLE_FREEZER_KEEPER,
      0,
      ''
    );
  }

  function _fund(uint256 balanceUsdc, uint256 balanceUsdt) internal {
    IGhoDirectFacilitator(DIRECT_FACILITATOR).mint(
      GHO_RESERVE,
      RESERVE_LIMIT_GSM_USDC + RESERVE_LIMIT_GSM_USDT
    );

    AaveV3Ethereum.COLLECTOR.transfer(
      IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN),
      address(this),
      balanceUsdc
    );
    AaveV3Ethereum.COLLECTOR.transfer(
      IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN),
      address(this),
      balanceUsdt
    );

    IERC20(AaveV3EthereumAssets.USDC_STATA_TOKEN).forceApprove(NEW_GSM_USDC, balanceUsdc);
    IERC20(AaveV3EthereumAssets.USDT_STATA_TOKEN).forceApprove(NEW_GSM_USDT, balanceUsdt);

    (, uint256 amountGhoUsdc) = IGsm(NEW_GSM_USDC).sellAsset(balanceUsdc, address(this));
    (, uint256 amountGhoUsdt) = IGsm(NEW_GSM_USDT).sellAsset(balanceUsdt, address(this));

    (, uint256 ghoUsdcNeeded) = IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitatorBucket(
      GhoEthereum.GSM_USDC
    );
    (, uint256 ghoUsdtNeeded) = IGhoToken(GhoEthereum.GHO_TOKEN).getFacilitatorBucket(
      GhoEthereum.GSM_USDT
    );

    uint256 acquiredGho = amountGhoUsdc + amountGhoUsdt;
    uint256 mintedGho = ghoUsdcNeeded + ghoUsdtNeeded;

    if (mintedGho > acquiredGho) {
      AaveV3Ethereum.COLLECTOR.transfer(
        IERC20(GhoEthereum.GHO_TOKEN),
        address(this),
        mintedGho - acquiredGho
      );
    }

    IERC20(GhoEthereum.GHO_TOKEN).forceApprove(GhoEthereum.GSM_USDC, ghoUsdcNeeded);
    IERC20(GhoEthereum.GHO_TOKEN).forceApprove(GhoEthereum.GSM_USDT, ghoUsdtNeeded);

    IGsm(GhoEthereum.GSM_USDC).burnAfterSeize(ghoUsdcNeeded);
    IGsm(GhoEthereum.GSM_USDT).burnAfterSeize(ghoUsdtNeeded);

    // Send to collector any positive difference
    IERC20(GhoEthereum.GHO_TOKEN).transfer(
      address(AaveV3Ethereum.COLLECTOR),
      IERC20(GhoEthereum.GHO_TOKEN).balanceOf(address(this))
    );
  }

  function _revokeAccess() internal {
    // Remove existing GSMs as GHO Facilitators
    IGhoToken(GhoEthereum.GHO_TOKEN).removeFacilitator(GhoEthereum.GSM_USDC);
    IGhoToken(GhoEthereum.GHO_TOKEN).removeFacilitator(GhoEthereum.GSM_USDT);

    // Revoke existing GSMs
    address[] memory revokedVaults = new address[](2);
    revokedVaults[0] = GhoEthereum.GSM_USDC;
    revokedVaults[1] = GhoEthereum.GSM_USDT;
    IGhoBucketSteward(GhoEthereum.GHO_BUCKET_STEWARD).setControlledFacilitator(
      revokedVaults,
      false
    );

    // Remove existing GSMs from Registry
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
    IGsm(GhoEthereum.GSM_USDC).revokeRole(
      IGsm(GhoEthereum.GSM_USDC).CONFIGURATOR_ROLE(),
      GhoEthereum.GHO_GSM_STEWARD
    );
    IGsm(GhoEthereum.GSM_USDT).revokeRole(
      IGsm(GhoEthereum.GSM_USDT).CONFIGURATOR_ROLE(),
      GhoEthereum.GHO_GSM_STEWARD
    );

    // Cancel existing keepers
    IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR).cancel(
      EXISTING_ORACLE_SWAP_FREEZER_USDC
    );
    IAaveCLRobotOperator(MiscEthereum.AAVE_CL_ROBOT_OPERATOR).cancel(
      EXISTING_ORACLE_SWAP_FREEZER_USDT
    );

    // Manually withdraw LINK from existing keepers permissionesly ~20 blocks after cancel
  }
}
