# Proposal Generator Guide

## Quick Start

```bash
# Install dependencies
npm install

# Run the generator
pnpm generate
```

The generator will interactively prompt for:

1. Target markets (select from multiple networks)
2. Proposal metadata (title, author, forum/snapshot links)
3. Features to implement (caps, rates, listing, etc.)
4. Parameters for each feature

**Result**: Generates `.sol`, `.t.sol`, `.s.sol`, and `.md` files in `src/YYYYMMDD_*/`

## Command-Line Options

```bash
pnpm generate -- [options]

Options:
  -p, --markets <markets...>       Target markets (AaveV3Ethereum, AaveV3Arbitrum, etc.)
  -t, --title <string>             Short proposal title (used in contract names)
  -a, --author <string>            Proposal author
  -d, --discussion <string>        Governance forum link
  -s, --snapshot <string>          Snapshot vote link
  -v, --votingNetwork <network>    Network where voting takes place (default: Avalanche)
  -c, --configFile <string>        Path to config.ts file (for reproducibility)
  -u, --update                     Update block numbers when used with -c
  -r, --riskParams <string>        Path to a risk params record (JSON)
      --ops <string>               Path to an ops file, used with -r
  -f, --force                      Overwrite existing files
  -h, --help                       Display help
```

**Example**:

```bash
pnpm generate -- \
  --markets AaveV3Ethereum AaveV3Arbitrum \
  --title "Increase WETH Supply Cap" \
  --author "Risk DAO"
```

## Interactive Mode

After running `pnpm generate`, an interactive mode will be opened. Select required options from the list in 3 following steps: market selection, metadata entry, and feature selection.

## Feature Modules

After feature selection (step 3), the generator prompts for parameters specific to each selected feature.

**Example** (Caps Updates): Select assets → Enter new supply cap → Enter new borrow cap

**Available features**:

- Asset Listing
- Caps Updates
- Interest Rate Updates
- Collateral Updates
- Borrow Updates
- E-Mode Updates
- Price Feed Updates
- Emission Updates
- Flash Borrower
- Freeze Updates
- Custom Implementation

### 11. Custom Implementation

**Use Case**: Changes not supported by config engine.

**Generated**: Placeholder function with comment `// custom code goes here`

You must manually implement the logic.

## Generated File Structure

```
src/YYYYMMDD_<Market>_<Title>/
├── <Market>_<Title>_YYYYMMDD.sol       # Payload contract
├── <Market>_<Title>_YYYYMMDD.t.sol     # Tests
├── <Title>_YYYYMMDD.s.sol              # Deployment script
├── <Title>.md                          # AIP documentation
└── config.ts                           # Config file for reproducibility
```

**Naming**: Date (YYYYMMDD) + Market (AaveV3Arbitrum) + PascalCase title

## Config File Mode

The generator automatically creates a `config.ts` file in each proposal directory that captures all your inputs (chains, metadata, features, parameters). This enables reproducibility and iteration.

**Regenerate from existing config**:

```bash
# Use existing config to regenerate files
pnpm generate -- -c src/YYYYMMDD_Chain_Title/config.ts

# Update block numbers for fresh fork tests
pnpm generate -- -c src/YYYYMMDD_Chain_Title/config.ts --update
```

## Risk Params Record Mode

A V3 listing or parameter update can also be generated from a risk params record instead of the prompts. The record is one JSON file with only the risk values from the risk provider's post, in bps and whole tokens (schema: `generator/riskParams/schema.json`).

```bash
pnpm generate -- -r record.json -t "Onboard USDe to Aave V3 X Layer" -a "Aave Labs"
```

**Ops file** (optional, `--ops ops.json`): values that are not risk params, i.e. block number, token decimals, the price feed address when the record only names the feed, LM admin and seed amount. Missing block numbers and decimals are read onchain.

```json
{
  "markets": {
    "AaveV3XLayer": { "listings": { "USDe": { "seedAmount": "100e18" } } }
  }
}
```

The record is saved as `riskParams.json` next to `config.ts`, and only when `config.ts` is written.

**Revisions**: bump `version` whenever the parameters (`markets`) change. Formatting, notes and links don't need a bump.

**CI check**: for every proposal with a `riskParams.json`, the Test workflow checks that the record is valid, that its assets match the address book, that `version` was bumped if the parameters changed since the base branch or the previous push, and that the record, `config.ts` and the payload contract agree. It then reads the fork snapshots of `test_defaultProposalExecution` and posts a table per proposal: current value, proposed value from the record, and the value after execution. A value that differs from the record, or a change the record doesn't ask for, fails the check. Run it locally after the proposal test:

```bash
pnpm test:risk-params:check src/YYYYMMDD_Chain_Title
```

**Check the record against past proposals** (config -> record -> config must generate the same payload):

```bash
pnpm test:risk-params <dir containing <aip>/config.ts>
```

## Related Documentation

- [README.md](../README.md) - Repository overview and architecture
- [TESTING_GUIDE.md](../docs/TESTING_GUIDE.md) - Testing proposals
- [GLOSSARY.md](../docs/GLOSSARY.md) - Repository terminology
