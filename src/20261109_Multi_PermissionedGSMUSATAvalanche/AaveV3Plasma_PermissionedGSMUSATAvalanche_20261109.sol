// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GhoPlasma} from 'aave-address-book/GhoPlasma.sol';

import {PermissionedGsmUsatAvalancheFacilitatorProposalBase} from './setup/PermissionedGsmUsatAvalancheFacilitatorProposalBase.sol';

/**
 * @title Permissioned GSM: USAT on Aave V4 Avalanche
 * @author TokenLogic
 * - Snapshot: https://snapshot.org/#/s:aavedao.eth/proposal/0x3a61c64d6f7d0546d76c8b7d93d29becf262a30240109c4ea9fa8d067ad6c2e2
 * - Discussion: https://governance.aave.com/t/arfc-permissioned-gsm-usat-aave-v4-avalanche/25852
 */
contract AaveV3Plasma_PermissionedGSMUSATAvalanche_20261109 is
  PermissionedGsmUsatAvalancheFacilitatorProposalBase
{
  function GHO_TOKEN() public pure override returns (address) {
    return GhoPlasma.GHO_TOKEN;
  }

  function GHO_CCIP_TOKEN_POOL() public pure override returns (address) {
    return GhoPlasma.GHO_CCIP_TOKEN_POOL;
  }
}
