# Implementation draft

**Not ready for submission.** Collector withdrawals are excluded by instruction. Nothing has been deployed or submitted.

## Open specification inputs

| Deployment       | Asset   | Blocker                               |
| ---------------- | ------- | ------------------------------------- |
| V3 Ethereum Core | BAL     | Fixed USD price absent from the forum |
| V3 Polygon       | BAL     | Fixed USD price absent from the forum |
| V3 Polygon       | GHST    | Fixed USD price absent from the forum |
| V3 Polygon       | miMATIC | Fixed USD price absent from the forum |

Each missing value is a named `*_PRICE_USD = 0` constant. `_preExecute()` rejects it with an asset-specific reason; the corresponding feed remains the zero address and cannot be installed. `test_specificationComplete_*` deliberately fails for every missing value. Fill the authoritative constants and redeploy the payloads before submission; filling the constants automatically creates their adapters.

## Implementation choices

- Ten market payloads, seven chain registrations. The generated script groups Ethereum's three market actions and Polygon's two market actions atomically per chain. Consequently the missing V3 prices block the entire Ethereum and Polygon registrations, including their complete V2 actions.
- 36 reserve entries: 32 fixed prices from the published tables and four blocked placeholders. The published prices are retained; the earlier September 15 price review is not treated as approval to substitute fresh values. LLR should confirm the stale six-month averages, depegged MAI targets and sUSD spot targets before finalization.
- 32 IRM updates (21 V3, 11 V2); preserve omitted optimal utilization ratios and V2 stable slopes. Explicitly flatten variable slope1 for V2 AMPL/sUSD. Four V2 reserves have oracle-only changes and retain their complete rate strategies.
- Implement the 20 V3 cap rows as 11 actual reserve cap updates, preserving fields already at their target; also apply 12 explicitly requested freezes and six reserve-factor increases. Already-frozen rows remain frozen. SCR has no freeze/cap row and its configuration remains unchanged.
- A one-off adapter per specified reserve is deployed in the payload constructor, before governance execution; its address is immutable in the payload. V3 returns the fixed USD target with eight decimals. V2 divides that target by the canonical Chainlink ETH/USD feed on the same chain and returns 18-decimal ETH. ETH/USD stays live; the long-tail asset feed is removed. The conversion floors the quotient, rejects nonpositive ETH/USD, and verifies the feed uses eight decimals. No arbitrary staleness threshold was introduced.
- The payloads write no executor storage. The adapters have no update authority. Later repricing would require replacing the adapter.
- `config.ts` is the generator bootstrap input. Oracle adapters, guards and explicit tests are custom additions; regenerating over this directory would discard them.

## Validation

Tests pin the September 15 blocks in each `setUp()`. The state-transition test checks all reserve configurations bit-for-bit after applying only specified edits, every before/after variable IRM field, unchanged V2 stable slopes, all oracle sources and denomination-correct output prices.

The workspace has uninitialized submodules. Validation uses temporary archives of the exact pinned helper revision `a213adb9223ba0bc92ed8150cb2c26f77211a09a` and its recursive dependency revisions, without changing repository dependency state.

- Compilation with Solidity 0.8.28: passed.
- Adapter unit tests: 4 passed.
- Payload state-transition tests: 8 passed; Ethereum Core and Polygon V3 fail intentionally because of missing prices.
- Completeness assertions: all 4 fail intentionally.
- Full generated and custom suite: **26 passed, 10 deliberately failed** (36 tests). All eight complete payloads pass the generated execution/E2E tests; generated reserve-configuration checks pass wherever execution is not blocked. The 10 failures are four missing-price assertions plus three execution/configuration tests for each of the two incomplete payloads.
- All eight generated configuration diffs were inspected: changes are confined to the specified reserves, sources, IRMs, cap reductions, freezes and reserve factors. Explicit tests cover unchanged configuration bits and V2 stable slopes.
- All 32 published fixed prices were mechanically checked against the Solidity constants. AIP/forum normalized content comparison and Prettier checks pass.
- Full cold-state Ethereum governance dispatch across all seven chains has not been validated. It requires finalized payloads; per-chain fork execution does not establish aggregate dispatch gas or bridge delivery.

## Source reconciliation

Source: first post of [forum topic 25400](https://governance.aave.com/t/arfc-oracle-deprecation-for-long-tail-assets-across-aave-v2-and-v3/25400), retrieved September 15, 2026. The cooked post was checked unchanged against the earlier review snapshot. `forum-source.txt` preserves the raw Discourse post.

The AIP follows the generator front matter, References links on `main`, and Copyright section. Content changes are limited to Summary → Simple Summary, omission of the Treasury Holdings section as instructed, and removal of Disclaimer. Next Steps and all parameter tables are retained. Formatting is normalized with the repository Prettier configuration. The prose still describes historical treasury holdings where relevant to reserve rationale, but there is no Collector action in any payload.

## Complete parameter inventory

Prices below are the forum's before → target values, **not live spot prices**. IRM values are the September 15 on-chain snapshot → specified draft result, in percent. `kink/base/slope1/slope2` uses that order. Freeze/caps/RF changes follow the published tables in `config.ts`; unchanged fields are checked by the fork tests.

| Market                   | Asset   | Forum USD price → target  | IRM before → after (%)      | Snapshot block |
| ------------------------ | ------- | ------------------------- | --------------------------- | -------------- |
| Aave V2 Ethereum         | AMPL    | $1.2792 → $1.1742         | 45/20/0/300 → 45/0/0/0      | 25982593       |
| Aave V2 Ethereum         | BAL     | $0.1153 → $0.1424         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | ENJ     | $0.0254 → $0.0372         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | FRAX    | $0.99 → $1.00             | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | KNC     | $0.1074 → $0.1356         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | LUSD    | $1.01 → $1.00             | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | RAI     | $2.1692 → $2.7339         | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | REN     | $0.0033 → $0.0033         | 45/20/0/300 → 45/20/0/40    | 25982593       |
| Aave V2 Ethereum         | TUSD    | $1.00 → $1.00             | 1/1/0/0 → 1/20/0/0          | 25982593       |
| Aave V2 Ethereum         | USDP    | $1.00 → $1.00             | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | YFI     | $1,998.9956 → $2,396.8163 | 45/20/0/300 → 45/20/0/300   | 25982593       |
| Aave V2 Ethereum         | ZRX     | $0.0801 → $0.0966         | 1/1/0/0 → 1/20/0/40         | 25982593       |
| Aave V2 Ethereum         | sUSD    | $0.2952 → $0.2952         | 45/20/0/300 → 45/0/0/0      | 25982593       |
| Aave V2 Polygon          | BAL     | $0.1151 → $0.1405         | 45/20/0/300 → 45/20/0/40    | 93844683       |
| Aave V2 Polygon          | GHST    | $0.0441 → $0.0867         | 45/20/0/300 → 45/20/0/40    | 93844683       |
| Aave V3 Arbitrum         | FRAX    | $0.99 → $1.00             | 90/0/5.5/40 → 90/5/5.5/100  | 505404403      |
| Aave V3 Arbitrum         | LUSD    | $1.01 → $1.00             | 80/2/6.5/50 → 80/5/6.5/100  | 505404403      |
| Aave V3 Arbitrum         | MAI     | $0.9731 → $1.0000         | 45/0/9/300 → 45/20/9/40     | 505404403      |
| Aave V3 Avalanche        | FRAX    | $0.9926 → $1.0000         | 90/0/5.5/40 → 90/20/5.5/40  | 95341470       |
| Aave V3 Avalanche        | MAI     | $0.9730 → $1.0000         | 45/0/9/300 → 45/20/9/40     | 95341470       |
| Aave V3 Celo             | USDm    | $1.00 → $1.00             | 90/0/4/75 → 90/5/4/100      | 77571299       |
| Aave V3 Ethereum Core    | BAL     | **MISSING**               | 45/5/15/150 → 45/20/15/40   | 25982593       |
| Aave V3 Ethereum Core    | FRAX    | $0.99 → $1.00             | 90/0/5.5/40 → 90/5/5.5/100  | 25982593       |
| Aave V3 Ethereum Core    | FXS     | $0.2545 → $0.5415         | 45/0/9/300 → 45/20/9/40     | 25982593       |
| Aave V3 Ethereum Core    | KNC     | $0.1064 → $0.1472         | 45/0/9/300 → 45/20/9/40     | 25982593       |
| Aave V3 Ethereum Core    | LUSD    | $1.00 → $1.00             | 80/0/5/50 → 80/5/5/100      | 25982593       |
| Aave V3 Ethereum Core    | RPL     | $1.6104 → $1.9543         | 80/0/8.5/87 → 80/5/8.5/100  | 25982593       |
| Aave V3 Ethereum Core    | STG     | $0.1256 → $0.2666         | 45/0/7/300 → 45/20/7/40     | 25982593       |
| Aave V3 Ethereum EtherFi | FRAX    | $0.9923 → $1.0000         | 90/0/5.5/40 → 90/20/5.5/40  | 25982593       |
| Aave V3 Optimism         | LUSD    | $1.0048 → $1.0000         | 80/2/5.5/50 → 80/20/5.5/40  | 156936640      |
| Aave V3 Optimism         | MAI     | $0.9733 → $1.0000         | 45/0/5.5/300 → 45/20/5.5/40 | 156936640      |
| Aave V3 Optimism         | sUSD    | $0.2763 → $0.2763         | 80/0/5.5/50 → 80/0/0/0      | 156936640      |
| Aave V3 Polygon          | BAL     | **MISSING**               | 45/5/15/150 → 45/20/15/40   | 93844683       |
| Aave V3 Polygon          | GHST    | **MISSING**               | 45/0/7/300 → 45/20/7/40     | 93844683       |
| Aave V3 Polygon          | miMATIC | **MISSING**               | 45/0/9/300 → 45/20/9/40     | 93844683       |
| Aave V3 Scroll           | SCR     | $0.0198 → $0.0418         | 45/0/7/300 → 45/20/7/40     | 35039319       |
