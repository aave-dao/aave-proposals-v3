// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';

import {PermissionedGsmUsatAvalancheFacilitatorProposalBase} from './PermissionedGsmUsatAvalancheFacilitatorProposalBase.sol';
import {PermissionedGSMUSATAvalancheSetup as Setup} from './PermissionedGSMUSATAvalancheSetup.sol';
import {SupportedChainsCheck} from 'src/helpers/gho-launch/tests/utils/SupportedChainsCheck.sol';

// ARFC bridge bucket capacity: the Ethereum bridge limit and every remote token pool bucket after execution
uint256 constant EXPECTED_BUCKET_CAPACITY = 265_000_000 ether;

/**
 * @dev Shared tests for the remote GHO networks other than Avalanche.
 */
abstract contract PermissionedGsmUsatAvalancheFacilitatorProposalBaseTest is
  ProtocolV3TestBase,
  SupportedChainsCheck
{
  PermissionedGsmUsatAvalancheFacilitatorProposalBase internal proposal;
  uint64 internal chainSelector;

  function test_bucketCapacity() public {
    IGhoToken gho = IGhoToken(proposal.GHO_TOKEN());
    IGhoToken.Facilitator memory before = gho.getFacilitator(proposal.GHO_CCIP_TOKEN_POOL());

    executePayload(vm, address(proposal));

    IGhoToken.Facilitator memory post = gho.getFacilitator(proposal.GHO_CCIP_TOKEN_POOL());
    assertEq(post.bucketCapacity, before.bucketCapacity + Setup.GHO_BRIDGE_AMOUNT);
    assertEq(post.bucketCapacity, EXPECTED_BUCKET_CAPACITY);
    assertEq(post.bucketLevel, before.bucketLevel);
  }

  /// @dev The payload only raises the bucket; no lane config changes
  function test_lanesUntouched() public {
    bytes32 before = _laneConfigHash(proposal.GHO_CCIP_TOKEN_POOL(), chainSelector, 0);

    executePayload(vm, address(proposal));

    assertEq(_laneConfigHash(proposal.GHO_CCIP_TOKEN_POOL(), chainSelector, 0), before);
  }

  function test_supportedChainsMatchLibrary() public view {
    _assertSupportedChainsMatchLibrary(proposal.GHO_CCIP_TOKEN_POOL(), chainSelector);
  }
}
