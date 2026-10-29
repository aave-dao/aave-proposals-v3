// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {IGhoBucketSteward} from 'src/interfaces/IGhoBucketSteward.sol';
import {IGhoDirectFacilitator} from 'src/interfaces/IGhoDirectFacilitator.sol';
import {IGhoToken} from 'src/interfaces/IGhoToken.sol';
import {AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027} from './AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027.sol';

/**
 * @dev Test for AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261027_AaveV3Ethereum_AaveInstitutionalOTCFacilitator/AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027.t.sol -vv
 */
contract AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027_Test is ProtocolV3TestBase {
  address internal constant DEPLOYER = 0x3765A685a401622C060E5D700D9ad89413363a91;

  AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027 internal proposal;

  IGhoToken internal gho = IGhoToken(GhoEthereum.GHO_TOKEN);
  IGhoBucketSteward internal bucketSteward = IGhoBucketSteward(GhoEthereum.GHO_BUCKET_STEWARD);
  IGhoDirectFacilitator internal facilitator;
  address internal recipient;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26287087);
    proposal = new AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027();
    facilitator = IGhoDirectFacilitator(proposal.AAVE_INSTITUTIONAL_FACILITATOR());
    recipient = makeAddr('recipient');
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_AaveInstitutionalOTCFacilitator_20261027',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_facilitatorDeployment() public view {
    assertEq(facilitator.GHO_TOKEN(), GhoEthereum.GHO_TOKEN);
    assertTrue(
      facilitator.hasRole(facilitator.DEFAULT_ADMIN_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1)
    );
    assertTrue(facilitator.hasRole(facilitator.MINTER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertTrue(facilitator.hasRole(facilitator.BURNER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertFalse(facilitator.hasRole(facilitator.DEFAULT_ADMIN_ROLE(), DEPLOYER));
    assertFalse(facilitator.hasRole(facilitator.MINTER_ROLE(), DEPLOYER));
    assertFalse(facilitator.hasRole(facilitator.BURNER_ROLE(), DEPLOYER));
  }

  function test_addFacilitator() public {
    address[] memory facilitatorsBefore = gho.getFacilitatorsList();
    for (uint256 i; i < facilitatorsBefore.length; i++) {
      assertNotEq(facilitatorsBefore[i], address(facilitator));
    }
    assertEq(gho.getFacilitator(address(facilitator)).bucketCapacity, 0);

    executePayload(vm, address(proposal));

    address[] memory facilitatorsAfter = gho.getFacilitatorsList();
    assertEq(facilitatorsAfter.length, facilitatorsBefore.length + 1);
    assertEq(facilitatorsAfter[facilitatorsAfter.length - 1], address(facilitator));

    IGhoToken.Facilitator memory registered = gho.getFacilitator(address(facilitator));
    assertEq(registered.bucketCapacity, proposal.AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY());
    assertEq(registered.bucketLevel, 0);
    assertEq(registered.label, proposal.AAVE_INSTITUTIONAL_FACILITATOR_NAME());
  }

  function test_setControlledFacilitator() public {
    uint256 controlledBefore = bucketSteward.getControlledFacilitators().length;
    assertFalse(bucketSteward.isControlledFacilitator(address(facilitator)));

    executePayload(vm, address(proposal));

    address[] memory controlled = bucketSteward.getControlledFacilitators();
    assertEq(controlled.length, controlledBefore + 1);
    assertEq(controlled[controlled.length - 1], address(facilitator));
    assertTrue(bucketSteward.isControlledFacilitator(address(facilitator)));
  }

  function test_roles() public {
    assertFalse(facilitator.hasRole(facilitator.MINTER_ROLE(), GhoEthereum.RISK_COUNCIL));
    assertFalse(facilitator.hasRole(facilitator.BURNER_ROLE(), GhoEthereum.RISK_COUNCIL));

    executePayload(vm, address(proposal));

    assertTrue(facilitator.hasRole(facilitator.MINTER_ROLE(), GhoEthereum.RISK_COUNCIL));
    assertTrue(facilitator.hasRole(facilitator.BURNER_ROLE(), GhoEthereum.RISK_COUNCIL));
    assertFalse(facilitator.hasRole(facilitator.DEFAULT_ADMIN_ROLE(), GhoEthereum.RISK_COUNCIL));
    assertTrue(
      facilitator.hasRole(facilitator.DEFAULT_ADMIN_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1)
    );
    assertTrue(facilitator.hasRole(facilitator.MINTER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
    assertTrue(facilitator.hasRole(facilitator.BURNER_ROLE(), GovernanceV3Ethereum.EXECUTOR_LVL_1));
  }

  function test_mint() public {
    uint256 amount = proposal.AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY();
    assertEq(amount, 25_000_000 ether);

    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        GhoEthereum.RISK_COUNCIL,
        facilitator.MINTER_ROLE()
      )
    );
    vm.prank(GhoEthereum.RISK_COUNCIL);
    facilitator.mint(recipient, amount);

    executePayload(vm, address(proposal));
    uint256 supplyBefore = gho.totalSupply();

    vm.prank(GhoEthereum.RISK_COUNCIL);
    facilitator.mint(recipient, amount);

    (, uint256 bucketLevel) = gho.getFacilitatorBucket(address(facilitator));
    assertEq(bucketLevel, amount);
    assertEq(gho.balanceOf(recipient), amount);
    assertEq(gho.totalSupply(), supplyBefore + amount);
  }

  function test_mint_revertsWith_FACILITATOR_BUCKET_CAPACITY_EXCEEDED() public {
    executePayload(vm, address(proposal));

    uint256 amount = proposal.AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY() + 1;

    vm.prank(GhoEthereum.RISK_COUNCIL);
    vm.expectRevert(bytes('FACILITATOR_BUCKET_CAPACITY_EXCEEDED'));
    facilitator.mint(recipient, amount);
  }

  function test_mint_revertsWith_AccessControlUnauthorizedAccount() public {
    executePayload(vm, address(proposal));
    address caller = makeAddr('caller');

    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        facilitator.MINTER_ROLE()
      )
    );
    vm.prank(caller);
    facilitator.mint(caller, 1);
  }

  function test_burn() public {
    uint256 amount = 1_000_000e18;

    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        GhoEthereum.RISK_COUNCIL,
        facilitator.BURNER_ROLE()
      )
    );
    vm.prank(GhoEthereum.RISK_COUNCIL);
    facilitator.burn(amount);

    executePayload(vm, address(proposal));

    vm.prank(GhoEthereum.RISK_COUNCIL);
    facilitator.mint(recipient, amount);
    vm.prank(recipient);
    gho.transfer(address(facilitator), amount);
    uint256 supplyBefore = gho.totalSupply();

    vm.prank(GhoEthereum.RISK_COUNCIL);
    facilitator.burn(amount);

    (, uint256 bucketLevel) = gho.getFacilitatorBucket(address(facilitator));
    assertEq(bucketLevel, 0);
    assertEq(gho.balanceOf(address(facilitator)), 0);
    assertEq(gho.totalSupply(), supplyBefore - amount);
  }

  function test_burn_revertsWith_AccessControlUnauthorizedAccount() public {
    executePayload(vm, address(proposal));
    address caller = makeAddr('caller');

    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        facilitator.BURNER_ROLE()
      )
    );
    vm.prank(caller);
    facilitator.burn(1);
  }

  function test_bucketSteward_updateFacilitatorBucketCapacity() public {
    executePayload(vm, address(proposal));

    uint128 newCapacity = 2 * proposal.AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY();

    vm.prank(GhoEthereum.RISK_COUNCIL);
    bucketSteward.updateFacilitatorBucketCapacity(address(facilitator), newCapacity);

    (uint256 bucketCapacity, ) = gho.getFacilitatorBucket(address(facilitator));
    assertEq(bucketCapacity, newCapacity);
  }

  function test_bucketSteward_updateFacilitatorBucketCapacity_revertsWith_INVALID_BUCKET_CAPACITY_UPDATE()
    public
  {
    executePayload(vm, address(proposal));
    uint128 currentCapacity = proposal.AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY();

    vm.startPrank(GhoEthereum.RISK_COUNCIL);
    vm.expectRevert(bytes('INVALID_BUCKET_CAPACITY_UPDATE'));
    bucketSteward.updateFacilitatorBucketCapacity(address(facilitator), 2 * currentCapacity + 1);
    vm.expectRevert(bytes('INVALID_BUCKET_CAPACITY_UPDATE'));
    bucketSteward.updateFacilitatorBucketCapacity(address(facilitator), currentCapacity - 1);
    vm.stopPrank();
  }

  function test_bucketSteward_updateFacilitatorBucketCapacity_revertsWith_DEBOUNCE_NOT_RESPECTED()
    public
  {
    executePayload(vm, address(proposal));
    uint128 currentCapacity = proposal.AAVE_INSTITUTIONAL_FACILITATOR_CAPACITY();

    vm.startPrank(GhoEthereum.RISK_COUNCIL);
    bucketSteward.updateFacilitatorBucketCapacity(address(facilitator), 2 * currentCapacity);
    skip(1 days);
    vm.expectRevert(bytes('DEBOUNCE_NOT_RESPECTED'));
    bucketSteward.updateFacilitatorBucketCapacity(address(facilitator), 3 * currentCapacity);
    vm.stopPrank();
  }
}
