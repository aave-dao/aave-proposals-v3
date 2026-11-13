import {describe, expect, it, vi} from 'vitest';
import fs from 'fs';
import os from 'os';
import path from 'path';
import {forkResult, testStatusInLog} from './fork';

const SNAPSHOT = JSON.stringify({reserves: {}, strategies: {}, eModes: {}});

// as printed by `forge test -vv` in the CI test step
const log = (status: string) => `Compiling 1 files with Solc 0.8.27
Ran 2 tests for src/other/Other.t.sol:Other_Test
[PASS] test_defaultProposalExecution() (gas: 1)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 1.00s (1.00s CPU time)
Ran 2 tests for src/x/Test.t.sol:Test_Test
[PASS] test_isFlashBorrower() (gas: 1)
${status} test_defaultProposalExecution() (gas: 2)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 1.00s (1.00s CPU time)
`;

function setup() {
  const reports = fs.mkdtempSync(path.join(os.tmpdir(), 'reports-'));
  const write = () => {
    for (const s of ['before', 'after'])
      fs.writeFileSync(path.join(reports, `Test_${s}.json`), SNAPSHOT);
  };
  return {write, args: {folder: 'src/x', contractName: 'Test', reports}};
}

describe('risk params record: fork snapshots', () => {
  it('reads the status of a proposal test from the forge log', () => {
    expect(testStatusInLog(log('[PASS]'), 'src/x/Test.t.sol')).toBe('passed');
    expect(testStatusInLog(log('[FAIL: EvmError: Revert]'), 'src/x/Test.t.sol')).toBe('failed');
    expect(testStatusInLog(log('[PASS]'), 'src/y/Test.t.sol')).toBeUndefined();
  });

  it('uses snapshots from a run the forge log shows passing', () => {
    const {args, write} = setup();
    write();
    const run = vi.fn();
    expect(forkResult({...args, testLog: log('[PASS]'), runTest: true, run})).toMatchObject({
      passedIn: 'test log',
    });
    expect(run).not.toHaveBeenCalled();
  });

  it('rejects snapshots from a run the forge log shows failing', () => {
    const {args, write} = setup();
    write();
    const run = vi.fn();
    expect(
      forkResult({...args, testLog: log('[FAIL: EvmError: Revert]'), runTest: true, run}),
    ).toEqual({error: 'test_defaultProposalExecution failed in the forge test run'});
    expect(run).not.toHaveBeenCalled();
  });

  it('does not trust snapshots without a passing test', () => {
    const {args, write} = setup();
    write();
    expect(forkResult(args).error).toMatch(/snapshots found but no passing/);
  });

  it('runs the test when it is not in the log, and rejects a failing run', () => {
    const {args, write} = setup();
    write(); // left over from an earlier run
    const run = vi.fn(() => {
      write(); // defaultTest writes the snapshots before a later assertion fails
      return {status: 1};
    });
    expect(forkResult({...args, testLog: '', runTest: true, run})).toEqual({
      error: 'the fork test failed (exit code 1)',
    });
    expect(run).toHaveBeenCalledWith('src/x/Test.t.sol');
  });

  it('reports forge not starting', () => {
    const {args} = setup();
    const run = () => ({status: null, error: new Error('spawnSync forge ENOENT')});
    expect(forkResult({...args, runTest: true, run}).error).toBe(
      'the fork test failed (spawnSync forge ENOENT)',
    );
  });

  it('uses snapshots from a passing run of its own', () => {
    const {args, write} = setup();
    const run = () => {
      write();
      return {status: 0};
    };
    expect(forkResult({...args, runTest: true, run})).toMatchObject({passedIn: 'this check'});
  });

  it('asks for the test to run when snapshots are missing', () => {
    const {args} = setup();
    expect(forkResult(args).error).toMatch(/run the proposal test first/);
  });
});
