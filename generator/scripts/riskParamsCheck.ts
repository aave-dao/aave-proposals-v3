/// Checks proposals generated from a risk params record and writes the PR table:
///   - the record is valid, its assets match the address book, and its version was bumped if
///     its parameters changed since the base branch or the previous push;
///   - riskParams.json, config.ts and the payload contracts agree;
///   - the fork snapshots from `defaultTest` (reports/) show every value the record asks for,
///     and nothing it doesn't.
///
///   pnpm test:risk-params:check [src/<proposal> ...] [--base origin/main] [--previous <sha>]
///     [--reports reports] [--testLog <file>] [--out <file>] [--fork]
///
/// Without folders it checks every proposal with a riskParams.json touched since --base.
import fs from 'fs';
import path from 'path';
import {execFileSync} from 'child_process';
import {Command} from 'commander';
import {generateContractName} from '../common';
import type {MarketIdentifier} from '../types';
import {assertKnownAssets, assertValidRecord} from '../riskParams/fromRecord';
import {checkCommitted} from '../riskParams/committed';
import {checkRevision} from '../riskParams/revision';
import type {Revision} from '../riskParams/revision';
import {buildRows, readEModeIds, recordMarkets, renderReport} from '../riskParams/report';
import {forkResult} from '../riskParams/fork';
import type {ForkStatus, Row} from '../riskParams/report';
import type {RiskParamsRecord} from '../riskParams/types';

const opts = new Command()
  .argument('[folders...]')
  .option('--base <ref>', 'branch the PR merges into', 'origin/main')
  .option('--previous <sha>', 'head of the previous push, to check revisions between pushes')
  .option('--reports <dir>', 'where defaultTest writes its snapshots', 'reports')
  .option('--testLog <file>', 'output of the forge test run that wrote the snapshots')
  .option('--out <file>', 'also write the markdown report to this file')
  .option('--fork', 'run the proposal test when its snapshots are missing')
  .parse(process.argv);
const {base, previous, reports, testLog, out, fork} = opts.opts<{
  base: string;
  previous?: string;
  reports: string;
  testLog?: string;
  out?: string;
  fork?: boolean;
}>();

// the address book the payloads compile against (remappings.txt)
const ADDRESS_BOOK_SRC = 'lib/aave-helpers/lib/aave-address-book/src';

const git = (...args: string[]) =>
  execFileSync('git', args, {encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore']});

function changedFolders(): string[] {
  const files = git('diff', '--name-only', `${base}...HEAD`).split('\n');
  const folders = new Set(
    files.filter((f) => /^src\/[^/]+\//.test(f)).map((f) => f.split('/').slice(0, 2).join('/')),
  );
  return [...folders].filter((f) => fs.existsSync(path.join(f, 'riskParams.json'))).sort();
}

function recordAt(ref: string, file: string): RiskParamsRecord | undefined {
  try {
    return JSON.parse(git('show', `${ref}:${file}`));
  } catch {
    return undefined; // not in that commit, or the commit isn't fetched
  }
}

const log = testLog && fs.existsSync(testLog) ? fs.readFileSync(testLog, 'utf8') : undefined;

async function check(folder: string): Promise<{markdown: string; failed: boolean}> {
  const file = path.join(folder, 'riskParams.json');
  const record: unknown = JSON.parse(fs.readFileSync(file, 'utf8'));
  assertValidRecord(record);
  assertKnownAssets(record);

  // the previous push is the last version reviewers saw; the base branch the last merged one
  const revisions = [
    ...(previous ? [checkRevision(record, recordAt(previous, file), 'previous push')] : []),
    checkRevision(record, recordAt(base, file), 'base branch'),
  ];
  const revision: Revision = {
    ...(revisions.find((r) => r.previous) ?? revisions[0]),
    error:
      revisions
        .map((r) => r.error)
        .filter(Boolean)
        .join('; ') || undefined,
  };

  const {config, errors} = await checkCommitted(folder, record);
  const rows: Row[] = [];
  const forks: ForkStatus[] = [];
  for (const [market, m] of recordMarkets(record)) {
    const {result, passedIn, error} = config
      ? forkResult({
          folder,
          contractName: generateContractName(config.rootOptions, market as MarketIdentifier),
          reports,
          testLog: log,
          runTest: fork,
        })
      : {error: 'no config.ts to find the proposal test'};
    forks.push({market, passedIn});
    if (error) errors.push(`${market}: ${error}`);
    const built = buildRows(market, m, config, result, readEModeIds(ADDRESS_BOOK_SRC, market));
    rows.push(...built.rows);
    errors.push(...built.errors);
  }
  const failed = !!revision.error || errors.length > 0 || rows.some((r) => r.ok === false);
  return {markdown: renderReport(record, revision, rows, errors, forks), failed};
}

const folders = opts.args.length ? opts.args : changedFolders();
if (!folders.length) {
  console.log('no proposal with a riskParams.json changed');
} else {
  const results = [];
  // one broken proposal (bad JSON, config.ts that doesn't import) still reports the others
  for (const folder of folders)
    results.push(
      await check(folder).catch((e: Error) => ({
        markdown: `### ${folder}\n\n\`\`\`\n${e.message}\n\`\`\``,
        failed: true,
      })),
    );
  const markdown = [
    `<details open><summary>${results.some((r) => r.failed) ? '❌' : '✅'} <strong>Risk params</strong></summary>\n`,
    ...results.map((r) => r.markdown),
    '</details>',
  ].join('\n\n');
  console.log(markdown);
  if (out) {
    fs.mkdirSync(path.dirname(out), {recursive: true});
    fs.writeFileSync(out, markdown);
  }
  if (results.some((r) => r.failed)) process.exitCode = 1;
}
