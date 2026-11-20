import {beforeEach, describe, expect, it, vi} from 'vitest';
import fs from 'fs';
import os from 'os';
import path from 'path';
import {getContract} from 'viem';
import {getBlockNumber} from 'viem/actions';
import {configFileFromRecord, literalValue} from './load';
import {recordFromConfig} from './toRecord';
import {normalizeConfig} from './compare';
import type {V3Market} from './types';
import {MULTI_LTV_AND_EMODE_UPDATE, USDE_XLAYER_LISTING} from './fixtures';

vi.mock('@aave-dao/toolbox', async (original) => ({
  ...(await original<typeof import('@aave-dao/toolbox')>()),
  getClient: vi.fn(() => ({})),
}));
vi.mock('viem/actions', async (original) => ({
  ...(await original<typeof import('viem/actions')>()),
  getBlockNumber: vi.fn(async () => 123n),
}));
vi.mock('viem', async (original) => ({
  ...(await original<typeof import('viem')>()),
  getContract: vi.fn(() => ({read: {decimals: async () => 6}})),
}));

const CLI = {title: 'USDe listing', author: 'Aave Labs'};

function write(record: unknown, ops?: unknown) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'risk-params-'));
  fs.writeFileSync(path.join(dir, 'record.json'), JSON.stringify(record));
  if (ops) fs.writeFileSync(path.join(dir, 'ops.json'), JSON.stringify(ops));
  return {
    recordPath: path.join(dir, 'record.json'),
    opsPath: ops ? path.join(dir, 'ops.json') : undefined,
  };
}

const listing = () => recordFromConfig(normalizeConfig(USDE_XLAYER_LISTING)).record;

describe('risk params record: load', () => {
  beforeEach(() => vi.clearAllMocks());

  it('builds a config from record and ops files, with title and author from the CLI', async () => {
    const r = listing();
    const {recordPath, opsPath} = write(r, {
      markets: {
        AaveV3XLayer: {
          cache: {blockNumber: 1},
          listings: {USDe: {decimals: 18, seedAmount: '100e18'}},
        },
      },
    });
    const cfg = await configFileFromRecord(recordPath, opsPath, CLI);
    expect(cfg.rootOptions).toMatchObject({
      title: 'USDe listing',
      shortName: 'USDeListing',
      author: 'Aave Labs',
      markets: ['AaveV3XLayer'],
      discussion: r.forumPost,
    });
    expect(cfg.marketOptions.AaveV3XLayer!.cache).toEqual({blockNumber: 1});
    expect(cfg.marketOptions.AaveV3XLayer!.configs.ASSET_LISTING![0]).toMatchObject({
      decimals: 18,
      seedAmount: '100e18',
    });
    expect(getBlockNumber).not.toHaveBeenCalled();
    expect(getContract).not.toHaveBeenCalled();
    await expect(configFileFromRecord(recordPath, opsPath, {author: 'x'})).rejects.toThrow(
      /missing title/,
    );
  });

  it('reads the block number and token decimals onchain when ops leave them out', async () => {
    const r = listing();
    const address = (r.markets.AaveV3XLayer as V3Market).listings![0].asset.address;
    const {recordPath} = write(r);
    const cfg = await configFileFromRecord(recordPath, undefined, CLI);
    expect(cfg.marketOptions.AaveV3XLayer!.cache).toEqual({blockNumber: 123});
    expect(cfg.marketOptions.AaveV3XLayer!.configs.ASSET_LISTING![0].decimals).toBe(6);
    expect(getBlockNumber).toHaveBeenCalledTimes(1);
    expect(getContract).toHaveBeenCalledWith(expect.objectContaining({address}));
  });

  it('reads one block number per market and no decimals without listings', async () => {
    const {recordPath} = write(recordFromConfig(MULTI_LTV_AND_EMODE_UPDATE).record);
    const cfg = await configFileFromRecord(recordPath, undefined, CLI);
    expect(Object.values(cfg.marketOptions).map((m) => m!.cache)).toEqual(
      Array(5).fill({blockNumber: 123}),
    );
    expect(getBlockNumber).toHaveBeenCalledTimes(5);
    expect(getContract).not.toHaveBeenCalled();
  });

  it('rejects an ops file with a typo in a listing symbol', async () => {
    const {recordPath, opsPath} = write(listing(), {
      markets: {AaveV3XLayer: {listings: {USDE: {decimals: 18}}}},
    });
    await expect(configFileFromRecord(recordPath, opsPath, CLI)).rejects.toThrow(
      /USDE is not a listing in the record/,
    );
  });

  it('rejects an ops file for a market the record does not touch', async () => {
    const {recordPath, opsPath} = write(listing(), {
      markets: {AaveV3Ethereum: {cache: {blockNumber: 1}}},
    });
    await expect(configFileFromRecord(recordPath, opsPath, CLI)).rejects.toThrow(
      /AaveV3Ethereum is not in the record/,
    );
  });

  it.each([
    ['a seed that is not a number literal', {seedAmount: '1e18 wei'}, /seedAmount must match/],
    [
      'a seed that is not a whole amount',
      {seedAmount: '1.5'},
      /1.5 for USDe is not a positive whole amount/,
    ],
    ['a zero seed', {seedAmount: '0e18'}, /0e18 for USDe is not a positive whole amount/],
    ['a price feed that is not an address', {priceFeed: 'USDe / USD'}, /priceFeed must match/],
    ['an unknown field', {decimal: 18}, /must NOT have additional properties/],
  ])('rejects %s in ops', async (_, values, error) => {
    const {recordPath, opsPath} = write(listing(), {
      markets: {AaveV3XLayer: {listings: {USDe: values}}},
    });
    await expect(configFileFromRecord(recordPath, opsPath, CLI)).rejects.toThrow(error);
  });

  it.each(['100e18', '1.5e18', '0.001e8', '1_000e6'])(
    'accepts the seed literal %s',
    async (seed) => {
      const {recordPath, opsPath} = write(listing(), {
        markets: {AaveV3XLayer: {listings: {USDe: {decimals: 18, seedAmount: seed}}}},
      });
      const cfg = await configFileFromRecord(recordPath, opsPath, CLI);
      expect(cfg.marketOptions.AaveV3XLayer!.configs.ASSET_LISTING![0].seedAmount).toBe(seed);
    },
  );

  it('values number literals like solc', () => {
    expect(literalValue('0.001e8')).toBe(100_000n);
    expect(literalValue('1.5e18')).toBe(1_500_000_000_000_000_000n);
    expect(literalValue('1_000')).toBe(1000n);
    expect(literalValue('0.0001e2')).toBeUndefined();
    expect(literalValue('1e')).toBeUndefined();
  });
});
