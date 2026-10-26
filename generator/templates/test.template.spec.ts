import {expect, describe, it} from 'vitest';
import {testTemplate} from './test.template';
import {MarketConfig, Options} from '../types';

const OPTS: Options = {
  markets: ['AaveV4Ethereum'],
  title: 'test',
  shortName: 'Test',
  date: '20260521',
  author: 'test',
  discussion: 'test',
  snapshot: 'test',
};

const withTestFns = (fns: string[][]): MarketConfig => ({
  configs: {},
  artifacts: fns.map((fn) => ({test: {fn}})),
  cache: {blockNumber: 0},
});

describe('testTemplate', () => {
  it('emits a test requested by two features once', () => {
    const fn = "function test_a() public {\n  assertEq(1, 1, 'x');\n}";
    const out = testTemplate(OPTS, withTestFns([[fn], [fn]]), 'AaveV4Ethereum');
    expect(out.match(/function test_a\(\)/g)).toHaveLength(1);
  });

  it('rejects two features defining the same test differently', () => {
    expect(() =>
      testTemplate(
        OPTS,
        withTestFns([
          ['function test_a() public {\n  assertEq(1, 1);\n}'],
          ['function test_a() public {\n  assertEq(1, 2);\n}'],
        ]),
        'AaveV4Ethereum',
      ),
    ).toThrow('conflicting definitions of test_a');
  });

  it('separates isolated V4 Base execution from non-isolated e2e', () => {
    const out = testTemplate({...OPTS, markets: ['AaveV4Base']}, withTestFns([]), 'AaveV4Base');
    expect(out).toContain('ProtocolV4TestBaseBase');
    expect(out).toContain('forge-config: default.networks.network = "base"');
    expect(out).toContain('forge-config: default.hardfork = "base:cobalt"');
    expect(out).toContain('forge-config: default.isolate = false');
    expect(out).toContain("import {GovV3Helpers} from 'aave-helpers/src/GovV3Helpers.sol'");
    const execution = out.slice(
      out.indexOf('function test_defaultProposalExecution()'),
      out.indexOf('function test_e2e()'),
    );
    expect(execution).toContain('runE2E: false');
    expect(execution).toContain('testPositionManagers: false');
    expect(out).toContain('forge-config: default.isolate = true');
    const e2e = out.slice(out.indexOf('function test_e2e()'));
    expect(e2e).toContain('GovV3Helpers.executePayload(vm, address(proposal))');
    expect(e2e).toContain('e2eTestAllSpokes({spokes: _getSpokes(), testPositionManagers: false})');
    expect(e2e).toContain('e2eTestAllTokenizationSpokes(_getTokenizationSpokes())');
    expect(e2e).not.toContain('forge-config: default.isolate = true');
  });

  it.each(['AaveV4Ethereum', 'AaveV4Avalanche', 'AaveV3Base'] as const)(
    'preserves the existing execution setup on %s',
    (market) => {
      const out = testTemplate({...OPTS, markets: [market]}, withTestFns([]), market);
      expect(out).not.toContain('default.networks.network');
      expect(out).not.toContain('base:cobalt');
      expect(out).not.toContain('function test_e2e()');
      expect(out).not.toContain('runE2E: false');
      expect(out).toContain('forge-config: default.isolate = true');
    },
  );
});
