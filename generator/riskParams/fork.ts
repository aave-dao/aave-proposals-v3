import fs from 'fs';
import path from 'path';
import {spawnSync} from 'child_process';
import type {ForkResult, Snapshot} from './report';

const TEST = 'test_defaultProposalExecution';

/// Runs `test_defaultProposalExecution` of one proposal test; returns forge's exit status.
export function runForgeTest(testFile: string): {status: number | null; error?: Error} {
  return spawnSync('forge', ['test', '--match-path', testFile, '--match-test', TEST], {
    stdio: 'inherit',
  });
}

/// Result of `test_defaultProposalExecution` for a test file in a `forge test` log (as the CI
/// test step writes it), or undefined when the file didn't run.
export function testStatusInLog(log: string, testFile: string): 'passed' | 'failed' | undefined {
  // forge prints one "Ran N test(s) for <file>:<contract>" block per suite
  const blocks = log.split(/^(?=Ran \d+ tests? for )/m);
  const block = blocks.find((b) => b.startsWith('Ran ') && b.includes(` for ${testFile}:`));
  const line = block?.split('\n').find((l) => new RegExp(`\\] ${TEST}\\(\\)`).test(l));
  if (!line) return undefined;
  return line.startsWith('[PASS]') ? 'passed' : 'failed';
}

export type TestSource = 'test log' | 'this check';

/// Before/after snapshots of a proposal, written by `defaultTest` to `reports/`, and how we
/// know the test that wrote them passed. Snapshots are only used with that evidence: from the
/// forge log of an earlier step (`testLog`), or from running the test here (`runTest`). A
/// failing test can still have written them.
export function forkResult({
  folder,
  contractName,
  reports,
  testLog,
  runTest,
  run = runForgeTest,
}: {
  folder: string;
  contractName: string;
  reports: string;
  testLog?: string;
  runTest?: boolean;
  run?: typeof runForgeTest;
}): {result?: ForkResult; passedIn?: TestSource; error?: string} {
  const testFile = path.join(folder, `${contractName}.t.sol`);
  const files = ['before', 'after'].map((s) => path.join(reports, `${contractName}_${s}.json`));
  const read = () =>
    files.map((f) =>
      fs.existsSync(f) ? (JSON.parse(fs.readFileSync(f, 'utf8')) as Snapshot) : undefined,
    );

  let [before, after] = read();
  const logged = testLog === undefined ? undefined : testStatusInLog(testLog, testFile);
  if (logged === 'failed') return {error: `${TEST} failed in the forge test run`};
  if (before && after && logged === 'passed')
    return {result: {before, after}, passedIn: 'test log'};
  if (!runTest)
    return {
      error:
        before && after
          ? `snapshots found but no passing ${TEST} to back them: run with --fork or pass --testLog`
          : `no fork snapshots in ${reports}/, run the proposal test first`,
    };

  console.log(`running the fork test of ${contractName}`);
  for (const f of files) fs.rmSync(f, {force: true});
  const {status, error} = run(testFile);
  if (status !== 0)
    return {error: `the fork test failed (${error?.message ?? `exit code ${status}`})`};
  [before, after] = read();
  return before && after
    ? {result: {before, after}, passedIn: 'this check'}
    : {error: `the fork test passed but wrote no snapshots to ${reports}/`};
}
