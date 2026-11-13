---
title: "Mainnet GSM migration"
author: "TokenLogic"
discussions: "TODO"
snapshot: "TODO"
---

## Simple Summary

This publication replaces the Ethereum USDC and USDT GSMs, whose underlyings are the Aave V3 stataUSDC and stataUSDT, with new GSMs whose underlyings are the Aave V4 Core USDC and USDT TokenizationSpokes (waCoreUSDC and waCoreUSDT). The current GSMs are seized, their backing is migrated, and they are removed from the GhoReserve and the GsmRegistry.

## Motivation

A TokenizationSpoke is an ERC-4626 vault over one asset of an Aave V4 Hub. The GSM holds the vault shares as a plain ERC-20 balance and prices them through `FixedPriceStrategy4626`, the same as it does for stataTokens. The existing `Gsm4626` and `FixedPriceStrategy4626` contracts are therefore reused without changes.

The USDC GSM is almost empty, so its GHO usage is repaid from the treasury. The USDT GSM backs about 48.3M GHO with about 40.9M stataUSDT (block 26248572). That backing is moved to the new USDT GSM within the proposal, so the circulating GHO stays backed during and after the migration:

1. The current USDT GSM is seized, and its stataUSDT goes to the Collector.
2. The stataUSDT is redeemed for USDT on Aave V3.
3. The USDT is deposited into the Aave V4 Core USDT TokenizationSpoke.
4. The waCoreUSDT shares are sold to the new USDT GSM for GHO.
5. That GHO repays the GHO used by the seized USDT GSM in the GhoReserve.

The GHO total supply does not change. The new USDT GSM draws from the GhoReserve the same GHO that the old one returns.

## Specification

The proposal executes two payloads on Ethereum, in this order.

### 1. Aave V4 payload

Raise the add caps of the Core Hub TokenizationSpokes so that the new GSMs can hold their shares and the USDT backing can be migrated:

| TokenizationSpoke                                                                                                                 | Current add cap | New add cap |
| --------------------------------------------------------------------------------------------------------------------------------- | :-------------: | :---------: |
| Core USDC [`0x531E90a2376902DE8915789Fcc1075e3B0c153E7`](https://etherscan.io/address/0x531E90a2376902DE8915789Fcc1075e3B0c153E7) |       1M        |    100M     |
| Core USDT [`0x5eC44a70F309854fe04d495cFE1B5dA63DD1cc73`](https://etherscan.io/address/0x5eC44a70F309854fe04d495cFE1B5dA63DD1cc73) |       1M        |    100M     |

TODO: re-check the add caps with the risk providers before going live.

### 2. Aave V3 payload

- On both current GSMs:
  - Distribute the accrued fees to the treasury. For the USDT GSM, this includes the unbooked stataUSDT yield.
  - Grant the Executor `LIQUIDATOR_ROLE`, then `seize()`. The stataUSDC dust and the stataUSDT go to the Collector.
- On the GhoReserve, add the new GSMs as entities and set their limits.
- On the new GSMs:
  - Set the exposure caps.
  - Grant `SWAP_FREEZER_ROLE` to their OracleSwapFreezers and to the Executor.
  - Grant `CONFIGURATOR_ROLE` to the GhoGsmSteward.
- Add the new GSMs to the GsmRegistry.
- Reuse the fee strategies of the current GSMs on the new GSMs.
- Migrate the USDT backing: stataUSDT → USDT (Aave V3) → waCoreUSDT (Aave V4) → GHO (new USDT GSM).
- Call `burnAfterSeize()` on both current GSMs to bring their GHO used to zero. The treasury covers the USDC GSM usage and any rounding shortfall of the USDT migration.
- Set the current GSMs' GhoReserve limits to zero and remove them as entities. Remove them from the GsmRegistry.
- Revoke the roles of the current GSMs' OracleSwapFreezers, the Executor (swap freezer and liquidator) and the GhoGsmSteward on the current GSMs.
- Withdraw to the Collector the LINK left in the current OracleSwapFreezer keepers. The Chainlink Automation registry owner already cancelled these keepers.

The new GSMs and OracleSwapFreezers are deployed with the Executor as `DEFAULT_ADMIN` and ProxyAdmin owner, so there is no deployer role to revoke.

| Parameter            |           waCoreUSDC GSM            |           waCoreUSDT GSM            |
| -------------------- | :---------------------------------: | :---------------------------------: |
| Address              |                TODO                 |                TODO                 |
| Underlying           | Aave V4 Core USDC TokenizationSpoke | Aave V4 Core USDT TokenizationSpoke |
| Draw Limit (GHO)     |               100.00M               |               100.00M               |
| Exposure Capacity    |               90.00M                |               85.00M                |
| Price Strategy       |           1:1 (ERC-4626)            |           1:1 (ERC-4626)            |
| Freeze Lower Bound   |               $0.990                |               $0.990                |
| Freeze Upper Bound   |               $1.010                |               $1.010                |
| Unfreeze Lower Bound |               $0.995                |               $0.995                |
| Unfreeze Upper Bound |               $1.005                |               $1.005                |
| Mint GHO Fee         |                0.00%                |                0.00%                |
| Burn GHO Fee         |                0.15%                |                0.10%                |

TODO: re-check exposure caps and draw limits with the risk providers before going live.

### Known limitations

- **Keepers:** Chainlink disabled automatic approval on the Automation registrar used by the Aave robot operator, so the payload does not register keepers for the new OracleSwapFreezers. The freezers hold `SWAP_FREEZER_ROLE` and their `performUpkeep` is permissionless. A keeper must be set up outside this proposal. The current GSMs' keepers have been cancelled since 2026-05-01.
- **Unfreezing:** the freezers are allowed to unfreeze. A keeper therefore reverses a manual freeze (for example after an Aave V4 Hub halt or bad debt) whenever the stablecoin price is within the unfreeze bounds.
- **V4 bad debt:** a TokenizationSpoke share keeps its quoted value when the Hub records bad debt (deficit), so the GSM does not see the loss. A bad-debt policy is needed.
- **Hub liquidity:** a user who buys waCoreUSDC or waCoreUSDT from a GSM can redeem it only while the V4 Core Hub has free liquidity.
- **Concentration:** the USDT migration increases the V4 Core Hub USDT supply from about 27.7M to about 76.0M. Utilisation drops from about 83% to about 30%, and about 64% of the Hub USDT supply becomes GSM backing (block 26248572).

## References

- Implementation: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261022_Multi_MainnetGSMMigration/AaveV3Ethereum_MainnetGSMMigration_20261022.sol), [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261022_Multi_MainnetGSMMigration/AaveV4Ethereum_MainnetGSMMigration_20261022.sol)
- Tests: [AaveV3Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261022_Multi_MainnetGSMMigration/AaveV3Ethereum_MainnetGSMMigration_20261022.t.sol), [AaveV4Ethereum](https://github.com/aave-dao/aave-proposals-v3/blob/main/src/20261022_Multi_MainnetGSMMigration/AaveV4Ethereum_MainnetGSMMigration_20261022.t.sol)
- [Snapshot](TODO)
- [Discussion](TODO)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
