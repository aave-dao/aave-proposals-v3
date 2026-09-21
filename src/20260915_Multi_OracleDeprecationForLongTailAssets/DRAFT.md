# Implementation draft

**Not ready for submission.** Collector withdrawals are excluded by instruction. Nothing has been deployed or submitted.

## Specification status

The September 16 forum update supplies all four previously missing prices: BAL on V3 Ethereum Core ($0.1337), and BAL ($0.1316), GHST ($0.0828), miMATIC ($0.9530) on V3 Polygon. All 36 oracle targets now use the revised specification. The six V3 reserve-factor targets are 100%. Missing-price placeholders, guards and deliberately failing completeness tests have been removed.

## Implementation choices

- Ten market payloads, seven chain registrations. The generated script groups Ethereum's three market actions and Polygon's two market actions atomically per chain.
- 36 reserve entries with fixed prices from the September 16 specification. These are the published targets, not recomputed September 21 spot prices or averages.
- 32 IRM updates (21 V3, 11 V2); preserve omitted optimal utilization ratios and V2 stable slopes. Explicitly flatten variable slope1 for V2 AMPL/sUSD. Four V2 reserves have oracle-only changes and retain their complete rate strategies.
- Implement the 20 V3 cap rows as 11 actual reserve cap updates, preserving fields already at their target; also apply 12 explicitly requested freezes and six reserve-factor increases to 100%. Already-frozen rows remain frozen. SCR has no freeze/cap row and its configuration remains unchanged.
- A one-off adapter per specified reserve is deployed in the payload constructor, before governance execution; its address is immutable in the payload. V3 returns the fixed USD target with eight decimals. V2 divides that target by the canonical Chainlink ETH/USD feed on the same chain and returns 18-decimal ETH. ETH/USD stays live; the long-tail asset feed is removed. The conversion floors the quotient, rejects nonpositive ETH/USD, and verifies the feed uses eight decimals. No arbitrary staleness threshold was introduced.
- The payloads write no executor storage. The adapters have no update authority. Later repricing would require replacing the adapter.
- `config.ts` is the generator bootstrap input. Oracle adapters and explicit tests are custom additions; regenerating over this directory would discard them.

## Validation

Tests pin the September 15 blocks in each `setUp()`. The state-transition test checks all reserve configurations bit-for-bit after applying only specified edits, every before/after variable IRM field, unchanged V2 stable slopes, all oracle sources and denomination-correct output prices.

The workspace has uninitialized submodules. Validation uses temporary archives of the exact pinned helper revision `a213adb9223ba0bc92ed8150cb2c26f77211a09a` and its recursive dependency revisions, without changing repository dependency state.

- Updated suite: **32 tests passed, 0 failed, 0 skipped**, across 11 test contracts. This includes all 10 payload state transitions, generated execution/E2E tests, reserve-configuration checks and four adapter unit tests.
- Inspected all 10 before/after configuration reports; changes are confined to the specified reserves and parameters.
- All 36 published fixed prices are checked against the Solidity constants and expected oracle outputs; the AIP is mechanically compared with the updated forum post.
- Full cold-state Ethereum governance dispatch across all seven chains has not been validated. Per-chain fork execution does not establish aggregate dispatch gas or bridge delivery. Deployment and this final dispatch check remain before submission.

## Source reconciliation

Source: first post of [forum topic 25400](https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400), retrieved September 21, 2026, revision 2 (updated September 16). `forum-source.txt` preserves the raw Discourse post.

The AIP follows the generator front matter, References links on `main`, and Copyright section. Content changes are limited to Summary → Simple Summary, omission of the Treasury Holdings section as instructed, and removal of Disclaimer. Next Steps, the September 16 Changelog and all parameter tables are retained. The historical analysis still uses 99% RF; the updated specification and changelog explicitly supersede it with 100%. Formatting is normalized with the repository Prettier configuration. The prose still describes historical treasury holdings where relevant to reserve rationale, but there is no Collector action in any payload.

## Complete parameter inventory

Prices below are the forum's before → target values, **not live spot prices**. IRM values are the September 15 on-chain snapshot → specified draft result, in percent. `kink/base/slope1/slope2` uses that order. Freeze/caps/RF changes follow the published tables in `config.ts`; unchanged fields are checked by the fork tests.

| Market                   | Asset   | Forum USD price → target  | IRM before → after (%)      | Snapshot block |
| ------------------------ | ------- | ------------------------- | --------------------------- | -------------- |
| Aave V2 Ethereum         | AMPL    | $1.1955 → $1.2396         | 45/20/0/300 → 45/0/0/0      | 25982593       |
| Aave V2 Ethereum         | BAL     | $0.1100 → $0.1317         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | ENJ     | $0.0247 → $0.0461         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | FRAX    | $0.99 → $1.00             | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | KNC     | $0.1352 → $0.1401         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | LUSD    | $1.01 → $1.00             | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | RAI     | $2.9495 → $2.6587         | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | REN     | $0.0033 → $0.0033         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | TUSD    | $1.00 → $1.00             | 1/1/0/0 → 1/20/0/0          | 25982593       |
| Aave V2 Ethereum         | USDP    | $1.00 → $1.00             | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | YFI     | $2,015.8260 → $2,286.6368 | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | ZRX     | $0.1090 → $0.0981         | 1/1/0/0 → 1/20/0/40         | 25982593       |
| Aave V2 Ethereum         | sUSD    | $0.3780 → $0.3780         | 45/20/0/300 → 45/0/0/0      | 25982593       |
| Aave V2 Polygon          | BAL     | $0.1097 → $0.1284         | 45/20/0/300 → 45/20/0/40    | 93844683       |
| Aave V2 Polygon          | GHST    | $0.0641 → $0.0793         | 45/20/0/300 → 45/20/0/40    | 93844683       |
| Aave V3 Arbitrum         | FRAX    | $0.99 → $1.00             | 90/0/5.5/40 → 90/5/5.5/100  | 505404403      |
| Aave V3 Arbitrum         | LUSD    | $1.01 → $1.00             | 80/2/6.5/50 → 80/5/6.5/100  | 505404403      |
| Aave V3 Arbitrum         | MAI     | $0.9530 → $0.9530         | 45/0/9/300 → 45/20/9/40     | 505404403      |
| Aave V3 Avalanche        | FRAX    | $0.9911 → $1.0000         | 90/0/5.5/40 → 90/20/5.5/40  | 95341470       |
| Aave V3 Avalanche        | MAI     | $0.9530 → $0.9530         | 45/0/9/300 → 45/20/9/40     | 95341470       |
| Aave V3 Celo             | USDm    | $1.00 → $1.00             | 90/0/4/75 → 90/5/4/100      | 77571299       |
| Aave V3 Ethereum Core    | BAL     | $0.1092 → $0.1337         | 45/5/15/150 → 45/20/15/40   | 25982593       |
| Aave V3 Ethereum Core    | FRAX    | $0.99 → $1.00             | 90/0/5.5/40 → 90/5/5.5/100  | 25982593       |
| Aave V3 Ethereum Core    | FXS     | $0.2582 → $0.3562         | 45/0/9/300 → 45/20/9/40     | 25982593       |
| Aave V3 Ethereum Core    | KNC     | $0.1325 → $0.1400         | 45/0/9/300 → 45/20/9/40     | 25982593       |
| Aave V3 Ethereum Core    | LUSD    | $1.01 → $1.00             | 80/0/5/50 → 80/5/5/100      | 25982593       |
| Aave V3 Ethereum Core    | RPL     | $1.6172 → $1.7338         | 80/0/8.5/87 → 80/5/8.5/100  | 25982593       |
| Aave V3 Ethereum Core    | STG     | $0.1478 → $0.2734         | 45/0/7/300 → 45/20/7/40     | 25982593       |
| Aave V3 Ethereum EtherFi | FRAX    | $0.9910 → $1.0000         | 90/0/5.5/40 → 90/20/5.5/40  | 25982593       |
| Aave V3 Optimism         | LUSD    | $1.0096 → $1.0000         | 80/2/5.5/50 → 80/20/5.5/40  | 156936640      |
| Aave V3 Optimism         | MAI     | $0.9530 → $0.9530         | 45/0/5.5/300 → 45/20/5.5/40 | 156936640      |
| Aave V3 Optimism         | sUSD    | $0.3029 → $0.3029         | 80/0/5.5/50 → 80/0/0/0      | 156936640      |
| Aave V3 Polygon          | BAL     | $0.1095 → $0.1316         | 45/5/15/150 → 45/20/15/40   | 93844683       |
| Aave V3 Polygon          | GHST    | $0.0640 → $0.0828         | 45/0/7/300 → 45/20/7/40     | 93844683       |
| Aave V3 Polygon          | miMATIC | $0.9530 → $0.9530         | 45/0/9/300 → 45/20/9/40     | 93844683       |
| Aave V3 Scroll           | SCR     | $0.0209 → $0.0335         | 45/0/7/300 → 45/20/7/40     | 35039319       |
