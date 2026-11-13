import {describe, expect, it} from 'vitest';
import {canonical, checkRevision} from './revision';
import {recordFromConfig} from './toRecord';
import {normalizeConfig} from './compare';
import type {V3Market} from './types';
import {USDE_XLAYER_LISTING} from './fixtures';

const record = () => recordFromConfig(normalizeConfig(USDE_XLAYER_LISTING)).record;
const listing = (r: ReturnType<typeof record>) => (r.markets.AaveV3XLayer as V3Market).listings![0];

describe('risk params record: revisions', () => {
  it('needs no previous version for a new record', () => {
    expect(checkRevision(record(), undefined, 'main')).toEqual({version: 1});
  });

  it('accepts formatting-only edits without a bump', () => {
    const before = record();
    // same content, keys in another order, as an edit in another editor would leave it
    const after = Object.fromEntries(
      Object.entries(structuredClone(before)).reverse(),
    ) as typeof before;
    after.notes = ['typo fixed'];
    listing(after).fromPreset = {preset: 'v3Default', fields: ['rates']};
    const rev = checkRevision(after, before, 'previous push');
    expect(rev.error).toBeUndefined();
    expect(rev.previous).toEqual({version: 1, label: 'previous push', paramsChanged: false});
  });

  it('rejects changed parameters without a higher version', () => {
    const before = record();
    const after = record();
    listing(after).supplyCap = 120_000_000;
    expect(checkRevision(after, before, 'previous push').error).toBe(
      'parameters changed since previous push but version is still 1: bump it to 2',
    );
    after.version = 2;
    expect(checkRevision(after, before, 'previous push')).toEqual({
      version: 2,
      previous: {version: 1, label: 'previous push', paramsChanged: true},
    });
  });

  it('rejects a version that goes down', () => {
    const before = {...record(), version: 3};
    expect(checkRevision(record(), before, 'main').error).toBe(
      'version went down from 3 (main) to 1',
    );
  });

  it('treats reordered listings as a change, since order decides reserve ids', () => {
    const a = {x: [{a: 1}, {b: 2}]};
    expect(canonical(a)).not.toBe(canonical({x: [{b: 2}, {a: 1}]}));
    expect(canonical({b: 1, a: 2})).toBe(canonical({a: 2, b: 1}));
  });
});
