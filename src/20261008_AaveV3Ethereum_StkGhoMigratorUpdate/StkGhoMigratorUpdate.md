---
title: "Move stkGHO Claim Helper Role to Updated StkGhoMigrator"
author: "Aave Labs"
discussions: "https://governance.aave.com/t/technical-maintenance-proposals/15274/138"
---

## Simple Summary

This proposal moves the stkGHO `CLAIM_HELPER_ROLE` from the current StkGhoMigrator to an updated StkGhoMigrator, and pauses the current StkGhoMigrator.

## Motivation

The StkGhoMigrator lets stkGHO holders move their position into sGHO in a single transaction, supporting the [stkGHO deprecation strategy outlined by TokenLogic](https://governance.aave.com/t/arfc-sgho-launch-configuration/24346). It was enabled by granting it the stkGHO `CLAIM_HELPER_ROLE`.

An updated StkGhoMigrator has been deployed. It deposits into sGHO the full amount of GHO received from stkGHO, instead of requiring that amount to equal the number of stkGHO shares redeemed. It also returns the amount of GHO redeemed and the amount of sGHO received. The user flow is unchanged.

The `CLAIM_HELPER_ROLE` on stkGHO is held by a single address, so the role has to move from the current StkGhoMigrator to the updated one.

## How the migration works

A stkGHO holder calls `migrate()` on the StkGhoMigrator. In one transaction, the StkGhoMigrator:

1. Starts the stkGHO cooldown on behalf of the holder. The stkGHO cooldown is 0 seconds, so the position can be redeemed immediately.
2. Redeems the holder's full stkGHO balance to GHO, at the stkGHO exchange rate at execution.
3. Deposits all of that GHO into sGHO, with the holder as receiver.

The holder ends up with sGHO and no stkGHO. Holders can still exit stkGHO and deposit into sGHO themselves, in separate transactions.

## Specification

Upon execution, the proposal:

1. Calls `setClaimHelperPendingAdmin(0x4C728397b9d5C8071d46229DF8823Ea2782124fb)` on the current [StkGhoMigrator](https://etherscan.io/address/0xC836143e39201698e7d543bCf21AfF3415aE4697) (`0xC836143e39201698e7d543bCf21AfF3415aE4697`), which sets the updated StkGhoMigrator as pending `CLAIM_HELPER_ROLE` admin on [stkGHO](https://etherscan.io/address/0x1a88Df1cFe15Af22B3c4c783D4e6F7F9e0C1885d) (`0x1a88Df1cFe15Af22B3c4c783D4e6F7F9e0C1885d`).
2. Calls `claimHelperRole()` on the updated [StkGhoMigrator](https://etherscan.io/address/0x4C728397b9d5C8071d46229DF8823Ea2782124fb) (`0x4C728397b9d5C8071d46229DF8823Ea2782124fb`), which claims the `CLAIM_HELPER_ROLE` on stkGHO.
3. Calls `pause()` on the current StkGhoMigrator.

The ownership of the current StkGhoMigrator is unchanged. The updated StkGhoMigrator is owned by the Governance Executor Lvl 1, with the Protocol Guardian as pause guardian.

The migration flow in the Aave UI will be switched to the updated StkGhoMigrator.

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/11d2f73d5ceecaecf729b7c40c28e39c8250a5b2/src/20261008_AaveV3Ethereum_StkGhoMigratorUpdate/AaveV3Ethereum_StkGhoMigratorUpdate_20261008.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/11d2f73d5ceecaecf729b7c40c28e39c8250a5b2/src/20261008_AaveV3Ethereum_StkGhoMigratorUpdate/AaveV3Ethereum_StkGhoMigratorUpdate_20261008.t.sol)
- [Discussion](https://governance.aave.com/t/technical-maintenance-proposals/15274/138)

## Disclaimer

This proposal was prepared by Aave Labs in its capacity as a contributor to the Aave ecosystem.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
