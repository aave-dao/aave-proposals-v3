// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveSafetyModule} from 'aave-address-book/AaveSafetyModule.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {GhoEthereum} from 'aave-address-book/GhoEthereum.sol';
import {IStakeToken} from 'aave-address-book/common/IStakeToken.sol';
import {IStkGhoMigrator} from '../interfaces/IStkGhoMigrator.sol';

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {IERC4626} from 'openzeppelin-contracts/contracts/interfaces/IERC4626.sol';
import {Pausable} from 'openzeppelin-contracts/contracts/utils/Pausable.sol';
import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';

import 'forge-std/Test.sol';
import {ProtocolV3TestBase} from 'aave-helpers/src/ProtocolV3TestBase.sol';
import {AaveV3Ethereum_StkGhoMigratorUpdate_20261008} from './AaveV3Ethereum_StkGhoMigratorUpdate_20261008.sol';

/**
 * @dev Test for AaveV3Ethereum_StkGhoMigratorUpdate_20261008
 * command: FOUNDRY_PROFILE=test forge test --match-path=src/20261008_AaveV3Ethereum_StkGhoMigratorUpdate/AaveV3Ethereum_StkGhoMigratorUpdate_20261008.t.sol -vv
 */
contract AaveV3Ethereum_StkGhoMigratorUpdate_20261008_Test is ProtocolV3TestBase {
  struct MigrationState {
    uint256 accountStkGho;
    uint256 accountSGho;
    uint256 accountGho;
    uint256 migratorGho;
    uint256 migratorStkGho;
    uint256 migratorSGho;
    uint256 stkGhoTotalSupply;
    uint256 stkGhoGhoBalance;
    uint256 stkGhoExchangeRate;
    uint256 sGhoTotalSupply;
    uint256 sGhoGhoBalance;
  }

  struct StkGhoConfig {
    address slashAdmin;
    address slashPendingAdmin;
    address cooldownAdmin;
    address cooldownPendingAdmin;
    uint256 cooldownSeconds;
    uint256 exchangeRate;
    uint256 maxSlashablePercentage;
    uint256 totalSupply;
    bool inPostSlashingPeriod;
  }

  event PendingAdminChanged(address indexed newPendingAdmin, uint256 role);
  event RoleClaimed(address indexed newAdmin, uint256 role);
  event Paused(address account);

  AaveV3Ethereum_StkGhoMigratorUpdate_20261008 internal proposal;

  IStakeToken internal constant STK_GHO = IStakeToken(AaveSafetyModule.STK_GHO);
  IERC20 internal constant GHO = IERC20(GhoEthereum.GHO_TOKEN);
  IERC4626 internal constant SGHO = IERC4626(GhoEthereum.SGHO);

  address internal oldMigrator;
  address internal newMigrator;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 26149767);
    proposal = new AaveV3Ethereum_StkGhoMigratorUpdate_20261008();
    oldMigrator = proposal.STK_GHO_MIGRATOR();
    newMigrator = proposal.NEW_STK_GHO_MIGRATOR();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    defaultTest(
      'AaveV3Ethereum_StkGhoMigratorUpdate_20261008',
      AaveV3Ethereum.POOL,
      address(proposal)
    );
  }

  function test_stateBeforeExecution() public view {
    assertEq(STK_GHO.getAdmin(STK_GHO.CLAIM_HELPER_ROLE()), oldMigrator);
    assertEq(STK_GHO.getPendingAdmin(STK_GHO.CLAIM_HELPER_ROLE()), address(0));
    assertFalse(IStkGhoMigrator(oldMigrator).paused());
    assertEq(IStkGhoMigrator(oldMigrator).owner(), GovernanceV3Ethereum.EXECUTOR_LVL_1);
    assertEq(IStkGhoMigrator(oldMigrator).guardian(), MiscEthereum.PROTOCOL_GUARDIAN);

    _assertNewMigratorConfig();
    _assertHoldsNoStkGhoRole(newMigrator);
  }

  function test_newMigratorCannotMigrateBeforeExecution() public {
    address user = _stake('USER', 100e18);

    vm.prank(user);
    vm.expectRevert(bytes('CALLER_NOT_CLAIM_HELPER'));
    IStkGhoMigrator(newMigrator).migrate();
  }

  function test_executePayload() public {
    vm.recordLogs();
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);
    Vm.Log[] memory logs = _logsFrom(vm.getRecordedLogs());

    assertEq(logs.length, 3);
    _assertLog({
      log: logs[0],
      emitter: address(STK_GHO),
      topics: _topics(PendingAdminChanged.selector, newMigrator),
      data: abi.encode(STK_GHO.CLAIM_HELPER_ROLE())
    });
    _assertLog({
      log: logs[1],
      emitter: address(STK_GHO),
      topics: _topics(RoleClaimed.selector, newMigrator),
      data: abi.encode(STK_GHO.CLAIM_HELPER_ROLE())
    });
    _assertLog({
      log: logs[2],
      emitter: oldMigrator,
      topics: _topics(Paused.selector),
      data: abi.encode(GovernanceV3Ethereum.EXECUTOR_LVL_1)
    });

    assertEq(STK_GHO.getAdmin(STK_GHO.CLAIM_HELPER_ROLE()), newMigrator);
    assertEq(STK_GHO.getPendingAdmin(STK_GHO.CLAIM_HELPER_ROLE()), address(0));
  }

  function test_oldMigratorHoldsNoRoles() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    _assertHoldsNoStkGhoRole(oldMigrator);
  }

  function test_oldMigratorPausedWithUnchangedOwnership() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    assertTrue(IStkGhoMigrator(oldMigrator).paused());
    assertEq(IStkGhoMigrator(oldMigrator).owner(), GovernanceV3Ethereum.EXECUTOR_LVL_1);
    assertEq(IStkGhoMigrator(oldMigrator).pendingOwner(), address(0));
    assertEq(IStkGhoMigrator(oldMigrator).guardian(), MiscEthereum.PROTOCOL_GUARDIAN);
  }

  function test_newMigratorConfigUnchanged() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    _assertNewMigratorConfig();
  }

  function test_otherStkGhoConfigUnchanged() public {
    StkGhoConfig memory configBefore = _stkGhoConfig();

    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    assertEq(keccak256(abi.encode(_stkGhoConfig())), keccak256(abi.encode(configBefore)));
  }

  function test_oldMigratorMigrateReverts() public {
    address user = _stake('USER', 100e18);

    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(user);
    vm.expectRevert(Pausable.EnforcedPause.selector);
    IStkGhoMigrator(oldMigrator).migrate();
  }

  function test_oldMigratorMigrateRevertsWhenUnpaused() public {
    address user = _stake('USER', 100e18);

    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IStkGhoMigrator(oldMigrator).unpause();

    vm.prank(user);
    vm.expectRevert(bytes('CALLER_NOT_CLAIM_HELPER'));
    IStkGhoMigrator(oldMigrator).migrate();
  }

  function test_oldMigratorCannotReassignClaimHelperRole() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    vm.expectRevert(bytes('CALLER_NOT_ROLE_ADMIN'));
    IStkGhoMigrator(oldMigrator).setClaimHelperPendingAdmin(makeAddr('NEW_PENDING_ADMIN'));
  }

  function test_oldMigratorCannotReclaimClaimHelperRole() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IStkGhoMigrator(oldMigrator).unpause();

    vm.expectRevert(bytes('CALLER_NOT_PENDING_ROLE_ADMIN'));
    IStkGhoMigrator(oldMigrator).claimHelperRole();
  }

  function test_newMigratorCanHandClaimHelperRoleBackToExecutor() public {
    address user = _stake('USER', 100e18);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IStkGhoMigrator(newMigrator).setClaimHelperPendingAdmin(GovernanceV3Ethereum.EXECUTOR_LVL_1);

    assertEq(
      STK_GHO.getPendingAdmin(STK_GHO.CLAIM_HELPER_ROLE()),
      GovernanceV3Ethereum.EXECUTOR_LVL_1
    );
    assertEq(STK_GHO.getAdmin(STK_GHO.CLAIM_HELPER_ROLE()), newMigrator);

    uint256 claimHelperRole = STK_GHO.CLAIM_HELPER_ROLE();
    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    STK_GHO.claimRoleAdmin(claimHelperRole);

    assertEq(STK_GHO.getAdmin(STK_GHO.CLAIM_HELPER_ROLE()), GovernanceV3Ethereum.EXECUTOR_LVL_1);
    assertEq(STK_GHO.getPendingAdmin(STK_GHO.CLAIM_HELPER_ROLE()), address(0));
    _assertHoldsNoStkGhoRole(newMigrator);

    vm.prank(user);
    vm.expectRevert(bytes('CALLER_NOT_CLAIM_HELPER'));
    IStkGhoMigrator(newMigrator).migrate();
  }

  function test_newMigratorPausableByGuardian() public {
    address user = _stake('USER', 100e18);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(MiscEthereum.PROTOCOL_GUARDIAN);
    IStkGhoMigrator(newMigrator).pause();

    assertTrue(IStkGhoMigrator(newMigrator).paused());
    vm.prank(user);
    vm.expectRevert(Pausable.EnforcedPause.selector);
    IStkGhoMigrator(newMigrator).migrate();

    vm.prank(MiscEthereum.PROTOCOL_GUARDIAN);
    vm.expectRevert(
      abi.encodeWithSelector(
        Ownable.OwnableUnauthorizedAccount.selector,
        MiscEthereum.PROTOCOL_GUARDIAN
      )
    );
    IStkGhoMigrator(newMigrator).unpause();

    vm.prank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    IStkGhoMigrator(newMigrator).unpause();
    _migrateAndValidate(user, 100e18);
  }

  function test_e2e_migration() public {
    address user = _stake('USER', 100e18);

    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    assertEq(STK_GHO.getExchangeRate(), STK_GHO.EXCHANGE_RATE_UNIT());
    assertEq(STK_GHO.balanceOf(user), 100e18);
    _migrateAndValidate(user, 100e18);
  }

  function test_e2e_migrationStakedAfterExecution() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);
    address user = _stake('USER', 100e18);

    assertEq(STK_GHO.balanceOf(user), 100e18);
    _migrateAndValidate(user, 100e18);
  }

  function test_e2e_migrationMultipleUsers() public {
    address user = _stake('USER', 100e18);
    address otherUser = _stake('OTHER_USER', 2_500e18);

    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    _migrateAndValidate(user, 100e18);
    _migrateAndValidate(otherUser, 2_500e18);
  }

  function test_e2e_migrationStakeThenReturnFunds() public {
    address user = _stake('USER', 100e18);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    uint256 expectedRate = _expectedRateAfterReturnFunds(1e18);
    _returnFunds(1e18);

    assertEq(STK_GHO.getExchangeRate(), expectedRate);
    assertLt(expectedRate, STK_GHO.EXCHANGE_RATE_UNIT());
    assertEq(STK_GHO.balanceOf(user), 100e18);
    uint256 expectedGho = (100e18 * STK_GHO.EXCHANGE_RATE_UNIT()) / expectedRate;
    assertGt(expectedGho, 100e18);
    _migrateAndValidate(user, expectedGho);
  }

  function test_e2e_migrationReturnFundsThenStake() public {
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    uint256 expectedRate = _expectedRateAfterReturnFunds(1e18);
    _returnFunds(1e18);
    address user = _stake('USER', 100e18);

    uint256 expectedShares = (100e18 * expectedRate) / STK_GHO.EXCHANGE_RATE_UNIT();
    uint256 expectedGho = (expectedShares * STK_GHO.EXCHANGE_RATE_UNIT()) / expectedRate;
    assertEq(STK_GHO.getExchangeRate(), expectedRate);
    assertEq(STK_GHO.balanceOf(user), expectedShares);
    assertLt(expectedShares, 100e18);
    assertLe(expectedGho, 100e18);
    _migrateAndValidate(user, expectedGho);
  }

  function test_e2e_migrationAfterSlash() public {
    address user = _stake('USER', 100e18);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    uint256 totalShares = STK_GHO.totalSupply();
    uint256 totalAssets = STK_GHO.previewRedeem(totalShares);
    uint256 expectedRate = _ceilDiv(
      totalShares * STK_GHO.EXCHANGE_RATE_UNIT(),
      totalAssets - 1_000e18
    );

    vm.startPrank(GovernanceV3Ethereum.EXECUTOR_LVL_1);
    STK_GHO.setMaxSlashablePercentage(10_00);
    STK_GHO.slash(makeAddr('SLASH_RECEIVER'), 1_000e18);
    vm.stopPrank();

    assertEq(STK_GHO.getExchangeRate(), expectedRate);
    assertGt(expectedRate, STK_GHO.EXCHANGE_RATE_UNIT());
    uint256 expectedGho = (100e18 * STK_GHO.EXCHANGE_RATE_UNIT()) / expectedRate;
    assertLt(expectedGho, 100e18);
    _migrateAndValidate(user, expectedGho);
  }

  function test_e2e_migrationWithExistingBalances() public {
    address user = _stake('USER', 60e18);
    vm.prank(user);
    STK_GHO.cooldown();
    _stakeFor(user, 40e18);
    _depositSGho(user, 50e18);
    deal(address(GHO), user, 37e18);
    _seedMigrator({gho: 7e18, stkGho: 3e18, sGho: 2e18});
    uint256 migratorSGho = SGHO.balanceOf(newMigrator);
    assertGt(migratorSGho, 0);

    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    (, uint216 cooldownAmount) = STK_GHO.stakersCooldowns(user);
    assertEq(cooldownAmount, 60e18);
    assertEq(STK_GHO.balanceOf(user), 100e18);
    assertGt(SGHO.balanceOf(user), 0);
    assertEq(GHO.balanceOf(user), 37e18);
    _migrateAndValidate(user, 100e18);

    assertEq(GHO.balanceOf(newMigrator), 7e18);
    assertEq(STK_GHO.balanceOf(newMigrator), 3e18);
    assertEq(SGHO.balanceOf(newMigrator), migratorSGho);
  }

  function test_e2e_migrationWithExpiredCooldown() public {
    address user = _stake('USER', 100e18);
    vm.prank(user);
    STK_GHO.cooldown();
    vm.warp(block.timestamp + STK_GHO.UNSTAKE_WINDOW() + 1);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    vm.prank(user);
    vm.expectRevert(bytes('UNSTAKE_WINDOW_FINISHED'));
    STK_GHO.redeem(user, 100e18);

    _migrateAndValidate(user, 100e18);
  }

  function test_e2e_migrationStkGhoReceivedByTransfer() public {
    address staker = _stake('STAKER', 100e18);
    address user = makeAddr('USER');
    vm.prank(staker);
    assertTrue(STK_GHO.transfer(user, 100e18));
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    assertEq(STK_GHO.balanceOf(user), 100e18);
    _migrateAndValidate(user, 100e18);
  }

  /// forge-config: default.fuzz.runs = 64
  function testFuzz_e2e_migration(uint256 amount, uint256 donation) public {
    amount = bound(amount, 2, 1_000_000e18);
    donation = bound(donation, 0, 10_000_000e18);
    address user = _stake('USER', amount);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    uint256 expectedRate = STK_GHO.EXCHANGE_RATE_UNIT();
    if (donation >= STK_GHO.LOWER_BOUND()) {
      expectedRate = _expectedRateAfterReturnFunds(donation);
      _returnFunds(donation);
    }

    assertEq(STK_GHO.getExchangeRate(), expectedRate);
    assertEq(STK_GHO.balanceOf(user), amount);
    _migrateAndValidate(user, (amount * STK_GHO.EXCHANGE_RATE_UNIT()) / expectedRate);
  }

  /// forge-config: default.fuzz.runs = 64
  function testFuzz_e2e_migrationWithExistingBalances(
    uint256 amount,
    uint256 userGho,
    uint256 userSGhoDeposit,
    uint256 migratorGho,
    uint256 migratorStkGho,
    uint256 migratorSGho
  ) public {
    amount = bound(amount, 2, 1_000_000e18);
    userGho = bound(userGho, 0, 1_000_000e18);
    userSGhoDeposit = bound(userSGhoDeposit, 0, 1_000_000e18);
    migratorGho = bound(migratorGho, 0, 1_000_000e18);
    migratorStkGho = bound(migratorStkGho, 0, 1_000_000e18);
    migratorSGho = bound(migratorSGho, 0, 1_000_000e18);

    address user = _stake('USER', amount);
    if (userSGhoDeposit > 1) {
      _depositSGho(user, userSGhoDeposit);
    }
    deal(address(GHO), user, userGho);
    _seedMigrator({gho: migratorGho, stkGho: migratorStkGho, sGho: migratorSGho});
    uint256 migratorSGhoShares = SGHO.balanceOf(newMigrator);
    executePayload(vm, address(proposal), AaveV3Ethereum.POOL);

    _migrateAndValidate(user, amount);

    assertEq(GHO.balanceOf(newMigrator), migratorGho);
    assertEq(STK_GHO.balanceOf(newMigrator), migratorStkGho);
    assertEq(SGHO.balanceOf(newMigrator), migratorSGhoShares);
  }

  /// @dev Migrates `account` and asserts every balance and supply affected by the migration.
  function _migrateAndValidate(address account, uint256 expectedGho) internal {
    MigrationState memory stateBefore = _migrationState(account);
    assertEq(
      (stateBefore.accountStkGho * STK_GHO.EXCHANGE_RATE_UNIT()) / STK_GHO.getExchangeRate(),
      expectedGho,
      'expected GHO vs stkGHO rate'
    );
    assertEq(STK_GHO.previewRedeem(stateBefore.accountStkGho), expectedGho, 'stkGHO previewRedeem');
    uint256 expectedSGhoShares = SGHO.previewDeposit(expectedGho);

    vm.expectEmit(newMigrator);
    emit IStkGhoMigrator.StkGhoMigrated(account, expectedGho);
    vm.prank(account);
    (bool success, bytes memory returnData) = newMigrator.call(
      abi.encodeCall(IStkGhoMigrator.migrate, ())
    );
    assertTrue(success, 'migrate reverted');
    (uint256 ghoRedeemed, uint256 sGhoShares) = abi.decode(returnData, (uint256, uint256));

    assertEq(ghoRedeemed, expectedGho, 'returned GHO redeemed');
    assertEq(sGhoShares, expectedSGhoShares, 'returned sGHO shares');
    assertLe(SGHO.previewRedeem(sGhoShares), ghoRedeemed, 'sGHO value above GHO redeemed');

    MigrationState memory stateAfter = _migrationState(account);
    (uint40 cooldownTimestamp, uint216 cooldownAmount) = STK_GHO.stakersCooldowns(account);
    assertEq(stateAfter.accountStkGho, 0, 'account stkGHO');
    assertEq(stateAfter.accountSGho, stateBefore.accountSGho + expectedSGhoShares, 'account sGHO');
    assertEq(stateAfter.accountGho, stateBefore.accountGho, 'account GHO');
    assertEq(cooldownTimestamp, 0, 'account cooldown timestamp');
    assertEq(cooldownAmount, 0, 'account cooldown amount');
    assertEq(stateAfter.migratorGho, stateBefore.migratorGho, 'migrator GHO');
    assertEq(stateAfter.migratorStkGho, stateBefore.migratorStkGho, 'migrator stkGHO');
    assertEq(stateAfter.migratorSGho, stateBefore.migratorSGho, 'migrator sGHO');
    assertEq(
      stateAfter.stkGhoTotalSupply,
      stateBefore.stkGhoTotalSupply - stateBefore.accountStkGho,
      'stkGHO total supply'
    );
    assertEq(
      stateAfter.stkGhoGhoBalance,
      stateBefore.stkGhoGhoBalance - expectedGho,
      'stkGHO GHO balance'
    );
    assertEq(stateAfter.stkGhoExchangeRate, stateBefore.stkGhoExchangeRate, 'stkGHO rate');
    assertEq(
      stateAfter.sGhoTotalSupply,
      stateBefore.sGhoTotalSupply + expectedSGhoShares,
      'sGHO total supply'
    );
    assertEq(stateAfter.sGhoGhoBalance, stateBefore.sGhoGhoBalance + expectedGho, 'sGHO GHO');
  }

  function _migrationState(address account) internal view returns (MigrationState memory) {
    return
      MigrationState({
        accountStkGho: STK_GHO.balanceOf(account),
        accountSGho: SGHO.balanceOf(account),
        accountGho: GHO.balanceOf(account),
        migratorGho: GHO.balanceOf(newMigrator),
        migratorStkGho: STK_GHO.balanceOf(newMigrator),
        migratorSGho: SGHO.balanceOf(newMigrator),
        stkGhoTotalSupply: STK_GHO.totalSupply(),
        stkGhoGhoBalance: GHO.balanceOf(address(STK_GHO)),
        stkGhoExchangeRate: STK_GHO.getExchangeRate(),
        sGhoTotalSupply: SGHO.totalSupply(),
        sGhoGhoBalance: GHO.balanceOf(address(SGHO))
      });
  }

  function _stkGhoConfig() internal view returns (StkGhoConfig memory) {
    return
      StkGhoConfig({
        slashAdmin: STK_GHO.getAdmin(STK_GHO.SLASH_ADMIN_ROLE()),
        slashPendingAdmin: STK_GHO.getPendingAdmin(STK_GHO.SLASH_ADMIN_ROLE()),
        cooldownAdmin: STK_GHO.getAdmin(STK_GHO.COOLDOWN_ADMIN_ROLE()),
        cooldownPendingAdmin: STK_GHO.getPendingAdmin(STK_GHO.COOLDOWN_ADMIN_ROLE()),
        cooldownSeconds: STK_GHO.getCooldownSeconds(),
        exchangeRate: STK_GHO.getExchangeRate(),
        maxSlashablePercentage: STK_GHO.getMaxSlashablePercentage(),
        totalSupply: STK_GHO.totalSupply(),
        inPostSlashingPeriod: STK_GHO.inPostSlashingPeriod()
      });
  }

  function _assertNewMigratorConfig() internal view {
    IStkGhoMigrator migrator = IStkGhoMigrator(newMigrator);
    assertFalse(migrator.paused());
    assertEq(migrator.owner(), GovernanceV3Ethereum.EXECUTOR_LVL_1);
    assertEq(migrator.pendingOwner(), address(0));
    assertEq(migrator.guardian(), MiscEthereum.PROTOCOL_GUARDIAN);
    assertEq(migrator.STKGHO(), address(STK_GHO));
    assertEq(migrator.SGHO(), address(SGHO));
    assertEq(migrator.GHO(), address(GHO));
    assertEq(migrator.CLAIM_HELPER_ROLE(), STK_GHO.CLAIM_HELPER_ROLE());
    assertEq(GHO.allowance(newMigrator, address(SGHO)), type(uint256).max);
    assertEq(GHO.balanceOf(newMigrator), 0);
    assertEq(STK_GHO.balanceOf(newMigrator), 0);
    assertEq(SGHO.balanceOf(newMigrator), 0);
  }

  function _assertHoldsNoStkGhoRole(address account) internal view {
    uint256[3] memory roles = [
      STK_GHO.SLASH_ADMIN_ROLE(),
      STK_GHO.COOLDOWN_ADMIN_ROLE(),
      STK_GHO.CLAIM_HELPER_ROLE()
    ];
    for (uint256 i = 0; i < roles.length; i++) {
      assertNotEq(STK_GHO.getAdmin(roles[i]), account);
      assertNotEq(STK_GHO.getPendingAdmin(roles[i]), account);
    }
  }

  function _assertLog(
    Vm.Log memory log,
    address emitter,
    bytes32[] memory topics,
    bytes memory data
  ) internal pure {
    assertEq(log.emitter, emitter);
    assertEq(log.topics, topics);
    assertEq(log.data, data);
  }

  function _topics(bytes32 topic0) internal pure returns (bytes32[] memory topics) {
    topics = new bytes32[](1);
    topics[0] = topic0;
  }

  function _topics(bytes32 topic0, address topic1) internal pure returns (bytes32[] memory topics) {
    topics = new bytes32[](2);
    topics[0] = topic0;
    topics[1] = bytes32(uint256(uint160(topic1)));
  }

  /// @dev Keeps the logs emitted by stkGHO and either migrator, in emission order.
  function _logsFrom(Vm.Log[] memory logs) internal view returns (Vm.Log[] memory filtered) {
    filtered = new Vm.Log[](logs.length);
    uint256 count;
    for (uint256 i = 0; i < logs.length; i++) {
      address emitter = logs[i].emitter;
      if (emitter == address(STK_GHO) || emitter == oldMigrator || emitter == newMigrator) {
        filtered[count++] = logs[i];
      }
    }
    assembly {
      mstore(filtered, count)
    }
  }

  function _stake(string memory name, uint256 amount) internal returns (address staker) {
    staker = makeAddr(name);
    _stakeFor(staker, amount);
  }

  function _stakeFor(address staker, uint256 amount) internal {
    deal(address(GHO), staker, amount);
    vm.startPrank(staker);
    GHO.approve(address(STK_GHO), amount);
    STK_GHO.stake(staker, amount);
    vm.stopPrank();
  }

  function _depositSGho(address account, uint256 amount) internal {
    deal(address(GHO), account, amount);
    vm.startPrank(account);
    GHO.approve(address(SGHO), amount);
    SGHO.deposit(amount, account);
    vm.stopPrank();
  }

  /// @dev Sends GHO, stkGHO and the sGHO shares minted for `sGho` GHO to the new migrator, as if
  /// transferred to it by mistake.
  function _seedMigrator(uint256 gho, uint256 stkGho, uint256 sGho) internal {
    address sender = makeAddr('SEEDER');
    deal(address(GHO), newMigrator, gho);
    if (stkGho != 0) {
      _stakeFor(sender, stkGho);
      vm.prank(sender);
      assertTrue(STK_GHO.transfer(newMigrator, stkGho));
    }
    if (sGho != 0) {
      _depositSGho(sender, sGho);
      uint256 shares = SGHO.balanceOf(sender);
      vm.prank(sender);
      assertTrue(SGHO.transfer(newMigrator, shares));
    }
  }

  /// @dev stkGHO `returnFunds` sets the rate to `ceil(totalShares * UNIT / (totalAssets + amount))`.
  function _expectedRateAfterReturnFunds(uint256 amount) internal view returns (uint256) {
    uint256 totalShares = STK_GHO.totalSupply();
    uint256 totalAssets = STK_GHO.previewRedeem(totalShares);
    return _ceilDiv(totalShares * STK_GHO.EXCHANGE_RATE_UNIT(), totalAssets + amount);
  }

  function _ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a + b - 1) / b;
  }

  function _returnFunds(uint256 amount) internal {
    address donor = makeAddr('DONOR');
    deal(address(GHO), donor, amount);
    vm.startPrank(donor);
    GHO.approve(address(STK_GHO), amount);
    STK_GHO.returnFunds(amount);
    vm.stopPrank();
  }
}
