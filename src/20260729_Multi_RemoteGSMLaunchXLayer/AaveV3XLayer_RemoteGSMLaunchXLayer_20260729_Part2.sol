// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {GhoXLayer} from 'aave-address-book/GhoXLayer.sol';
import {AaveV3XLayer} from 'aave-address-book/AaveV3XLayer.sol';
import {GovernanceV3XLayer} from 'aave-address-book/GovernanceV3XLayer.sol';
import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';

import {CCIPChainSelectors} from 'src/helpers/gho-launch/constants/CCIPChainSelectors.sol';
import {IGhoReserve} from 'src/interfaces/IGhoReserve.sol';
import {IGsm} from 'src/interfaces/IGsm.sol';
import {IGsmRegistry} from 'src/interfaces/IGsmRegistry.sol';

import {RemoteGSMLaunchXLayerSetup} from './setup/RemoteGSMLaunchXLayerSetup.sol';

/**
 * @title Remote GSM Launch: XLayer
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0xed5edc3f33a3b5d845452df717c18a3eb105a2eae8ab8be34cbf0832dfe8a20a
 * - Discussion: https://governance.aave.com/t/arfc-launch-gho-on-x-layer/23178
 *
 * NOTE: granting RISK_ADMIN_ROLE on AaveV3XLayer.ACL_MANAGER to a GhoAaveSteward
 * is intentionally OUT OF SCOPE for this proposal. If a steward is not already
 * empowered on XLayer, that grant must be made in a separate proposal before
 * the steward can call updateGhoBorrowCap / updateGhoBorrowRate / updateGhoSupplyCap.
 *
 * NOTE (CCIP receiver assumption): this proposal assumes the CCIP token-pool on
 * the XLayer lane delivers bridged GHO to `AaveV3XLayer.COLLECTOR`. The
 * Collector -> GhoReserve transfer below depends on that. If the CCIP receiver
 * for this lane is anything other than the Collector, this payload will revert.
 * Verify on-chain before deploy.
 */
contract AaveV3XLayer_RemoteGSMLaunchXLayer_20260729_Part2 is IProposalGenericExecutor {
  // https://www.oklink.com/x-layer/evm/address/0xE25F86A114Aabcb774d6E7d8826F743A1b8cD12A
  IGhoReserve public constant GHO_RESERVE =
    IGhoReserve(address(0xE25F86A114Aabcb774d6E7d8826F743A1b8cD12A));

  // https://www.oklink.com/x-layer/evm/address/0x2CF06F6116DE4da4f6d5541dF09981825820CE20
  address public constant GHO_GSM_STEWARD = address(0x2CF06F6116DE4da4f6d5541dF09981825820CE20);

  // https://www.oklink.com/x-layer/evm/address/0x1ECD8281BB799Ef055A379c27846B683cbeB6752
  address public constant GSM_REGISTRY = address(0x1ECD8281BB799Ef055A379c27846B683cbeB6752);

  // GSM USDG (stataUSDG)
  // https://www.oklink.com/x-layer/evm/address/0xAcB3d2f60CAA4966dE003E22936033FFBE7f6787
  address public constant GSM_USDG = address(0xAcB3d2f60CAA4966dE003E22936033FFBE7f6787);

  // https://www.oklink.com/x-layer/evm/address/0xD70BE7e6111EA563226cb8e53B1F195Da4E566E2
  address public constant USDG_ORACLE_SWAP_FREEZER =
    address(0xD70BE7e6111EA563226cb8e53B1F195Da4E566E2);

  // https://www.oklink.com/x-layer/evm/address/0xab1c66208266bbF5b2809ce1deDd3e5149eb4C94
  address public constant GSM_USDG_FEE_STRATEGY =
    address(0xab1c66208266bbF5b2809ce1deDd3e5149eb4C94);

  function execute() external {
    GHO_RESERVE.grantRole(GHO_RESERVE.LIMIT_MANAGER_ROLE(), GhoXLayer.RISK_COUNCIL);

    _wireGsm(
      IGsm(GSM_USDG),
      RemoteGSMLaunchXLayerSetup.GSM_USDG_RESERVE_LIMIT,
      USDG_ORACLE_SWAP_FREEZER,
      RemoteGSMLaunchXLayerSetup.GSM_USDG_INITIAL_EXPOSURE_CAP,
      GSM_USDG_FEE_STRATEGY
    );

    AaveV3XLayer.COLLECTOR.transfer(
      IERC20(GhoXLayer.GHO_TOKEN),
      address(GHO_RESERVE),
      RemoteGSMLaunchXLayerSetup.GHO_BRIDGE_AMOUNT
    );

    // Restore ONLY the XLayer <> Ethereum lane rate-limit config to its standard values, undoing
    // the temporary inbound bump from Part 1. Every other lane is intentionally left untouched.
    // Facilitator Bucket Capacity does not need to change.
    RemoteGSMLaunchXLayerSetup.restoreLaneRateLimitConfig(
      GhoXLayer.GHO_CCIP_TOKEN_POOL,
      CCIPChainSelectors.ETHEREUM
    );
  }

  function _wireGsm(
    IGsm gsm,
    uint128 reserveLimit,
    address oracleSwapFreezer,
    uint128 initialExposureCap,
    address feeStrategy
  ) internal {
    gsm.updateGhoReserve(address(GHO_RESERVE));

    // Enroll GSM as entity and set limit
    GHO_RESERVE.addEntity(address(gsm));
    GHO_RESERVE.setLimit(address(gsm), reserveLimit);

    // Add GSM Swap Freezer role to OracleSwapFreezers
    bytes32 swapFreezerRole = gsm.SWAP_FREEZER_ROLE();
    gsm.grantRole(swapFreezerRole, oracleSwapFreezer);
    gsm.grantRole(swapFreezerRole, GovernanceV3XLayer.EXECUTOR_LVL_1);

    // Add GSM to GSM Registry
    IGsmRegistry(GSM_REGISTRY).addGsm(address(gsm));

    // GHO GSM Steward
    gsm.grantRole(gsm.CONFIGURATOR_ROLE(), GHO_GSM_STEWARD);

    // Update deployed exposure cap to initial value
    gsm.updateExposureCap(initialExposureCap);

    gsm.updateFeeStrategy(feeStrategy);
  }
}
