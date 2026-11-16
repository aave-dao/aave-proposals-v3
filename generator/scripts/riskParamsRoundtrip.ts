/// Round trip on past AIPs: config.ts -> risk params record -> config.ts, then generate both with
/// the current generator and compare payload and test code. Any difference is a value the record
/// loses.
///
///   pnpm test:risk-params <dir containing <aip>/config.ts>
import fs from 'fs';
import path from 'path';
import {SUPPORTED_V3} from '../riskParams/toRecord';
import {firstDiff, generatePayloads, roundTrip} from '../riskParams/compare';
import type {PastConfigFile} from '../riskParams/compare';

const dir = process.argv[2];
if (!dir) throw new Error('usage: pnpm test:risk-params <dir containing <aip>/config.ts>');

const results: Record<string, string[]> = {same: [], diff: [], skipped: [], error: []};
const details: string[] = [];
for (const name of fs.readdirSync(dir).sort()) {
  const file = path.resolve(dir, name, 'config.ts');
  if (!fs.existsSync(file)) continue;
  const {config: cfg}: {config: PastConfigFile} = await import(file);
  const mo = cfg.marketOptions ?? cfg.poolOptions ?? {};
  const unsupported = Object.keys(mo).flatMap((m) =>
    m.startsWith('AaveV3')
      ? Object.keys(mo[m as keyof typeof mo]?.configs || {}).filter(
          (f) => !SUPPORTED_V3.includes(f),
        )
      : [m],
  );
  if (!Object.keys(mo).length || unsupported.length) {
    results.skipped.push(`${name} (${[...new Set(unsupported)].join(', ') || 'no markets'})`);
    continue;
  }
  try {
    const {original, rebuilt} = roundTrip(cfg);
    let a: string;
    try {
      a = await generatePayloads(original);
    } catch (e) {
      throw new Error(
        `original config does not generate on the current generator: ${(e as Error).message}`,
      );
    }
    const b = await generatePayloads(rebuilt);
    if (a === b) results.same.push(name);
    else {
      results.diff.push(name);
      details.push(`${name}: ${firstDiff(a, b)}`);
    }
  } catch (e) {
    results.error.push(name);
    details.push(
      `${name}: ERROR ${String((e as Error).message)
        .split('\n')
        .slice(0, 4)
        .join(' | ')}`,
    );
  }
}
for (const [k, v] of Object.entries(results)) console.log(`${k}: ${v.length}`);
if (details.length) console.log('\n' + details.join('\n\n'));
if (results.skipped.length) console.log('\nskipped:\n  ' + results.skipped.join('\n  '));
// fail automated checks when the record loses a value or a config can't be converted
if (results.diff.length || results.error.length) process.exitCode = 1;
