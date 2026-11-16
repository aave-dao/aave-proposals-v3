import fs from 'fs';
import {getContract} from 'viem';
import {getBlockNumber} from 'viem/actions';
import {getClient, IERC20Metadata_ABI} from '@aave-dao/toolbox';
import {CHAIN_TO_CHAIN_ID, getDate, getMarketChain, pascalCase} from '../common';
import type {ConfigFile, MarketIdentifier, Options} from '../types';
import Ajv from 'ajv/dist/2020';
import opsSchema from './ops.schema.json';
import {assertKnownAssets, assertValidRecord, configFromRecord} from './fromRecord';
import type {ListingOps, OpsFile, RecordOps, RiskParamsRecord, V3Market} from './types';

const validateOps = new Ajv({allErrors: true, strict: false}).compile(opsSchema);

/// Value of a Solidity number literal like `100e18` or `0.001e8`, or undefined when it isn't a
/// whole number (Solidity rejects those for an integer constant).
export function literalValue(literal: string): bigint | undefined {
  const m = literal.replace(/_/g, '').match(/^(\d+)(?:\.(\d+))?(?:e(\d+))?$/);
  if (!m) return undefined;
  const [, int, frac = '', exp = '0'] = m;
  const scale = Number(exp) - frac.length;
  const digits = BigInt(int + frac);
  if (scale >= 0) return digits * 10n ** BigInt(scale);
  const divisor = 10n ** BigInt(-scale);
  return digits % divisor === 0n ? digits / divisor : undefined;
}

/// Throws on schema errors and on markets or listings the record doesn't have, so a typo in
/// the ops file can't silently fall back to onchain values.
export function assertValidOps(ops: unknown, record: RiskParamsRecord): asserts ops is OpsFile {
  if (!validateOps(ops)) {
    const errors = (validateOps.errors || [])
      .map((e) => `  ${e.instancePath || '/'} ${e.message}`)
      .join('\n');
    throw new Error(`ops file is invalid:\n${errors}`);
  }
  const errors: string[] = [];
  for (const [market, m] of Object.entries((ops as OpsFile).markets ?? {})) {
    for (const [symbol, l] of Object.entries(m.listings ?? {}))
      if (l.seedAmount !== undefined && !(literalValue(l.seedAmount)! > 0n))
        errors.push(
          `${market}: seedAmount ${l.seedAmount} for ${symbol} is not a positive whole amount`,
        );
    const r = record.markets[market] as V3Market | undefined;
    if (!r) {
      errors.push(`${market} is not in the record`);
      continue;
    }
    const listed = new Set((r.listings ?? []).map((l) => l.asset.symbol));
    for (const symbol of Object.keys(m.listings ?? {}))
      if (!listed.has(symbol)) errors.push(`${market}: ${symbol} is not a listing in the record`);
  }
  if (errors.length)
    throw new Error(`ops file doesn't match the record:\n  ${errors.join('\n  ')}`);
}

function client(market: string) {
  return getClient(CHAIN_TO_CHAIN_ID[getMarketChain(market as MarketIdentifier)], {
    providerConfig: {alchemyKey: process.env.ALCHEMY_API_KEY},
  });
}

/// Builds a generator config from a risk params record (+ optional ops file) and the CLI flags.
export async function configFileFromRecord(
  recordPath: string,
  opsPath: string | undefined,
  cli: Partial<Options>,
): Promise<ConfigFile> {
  const record = JSON.parse(fs.readFileSync(recordPath, 'utf8'));
  assertValidRecord(record);
  assertKnownAssets(record);
  const opsFile = opsPath ? JSON.parse(fs.readFileSync(opsPath, 'utf8')) : {};
  assertValidOps(opsFile, record);

  const root = {...opsFile.rootOptions, ...cli};
  if (!root.title) throw new Error('missing title: pass -t "<title>" or rootOptions.title in ops');
  if (!root.author)
    throw new Error('missing author: pass -a "<author>" or rootOptions.author in ops');
  const ops: RecordOps = {
    rootOptions: {
      votingNetwork: 'AVALANCHE',
      ...root,
      shortName: pascalCase(root.title),
      date: getDate(),
    },
    markets: {},
  };

  for (const [market, m] of Object.entries(record.markets)) {
    const o = opsFile.markets?.[market] ?? {};
    const cache = o.cache ?? {blockNumber: Number(await getBlockNumber(client(market)))};
    const listings: Record<string, ListingOps> = {};
    for (const l of (m as V3Market).listings ?? []) {
      const lo = o.listings?.[l.asset.symbol] ?? {};
      const decimals =
        lo.decimals ??
        (await getContract({
          abi: IERC20Metadata_ABI,
          client: client(market),
          address: l.asset.address,
        }).read.decimals());
      listings[l.asset.symbol] = {...lo, decimals: Number(decimals)};
    }
    ops.markets[market] = {cache, listings};
  }
  return configFromRecord(record, ops);
}
