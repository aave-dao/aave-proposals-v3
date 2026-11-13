import Ajv from 'ajv/dist/2020';
import schema from './schema.json';
import * as addressBook from '@aave-dao/aave-address-book';
import type {Hex} from 'viem';
import {FEATURE} from '../types';
import type {ConfigFile, MarketConfig, MarketIdentifier} from '../types';
import type {BooleanSelectValues} from '../prompts/boolPrompt';
import type {
  Bps,
  EModeRef,
  RecordOps,
  RiskParamsRecord,
  V3Cap,
  V3Market,
  V3Rates,
  V3ReserveUpdate,
} from './types';

const ajv = new Ajv({allErrors: true, strict: false});
const validateRecord = ajv.compile(schema);

/// Throws with every schema error, so a bad record never reaches the generator.
export function assertValidRecord(record: unknown): asserts record is RiskParamsRecord {
  if (!validateRecord(record)) {
    const errors = (validateRecord.errors || [])
      .map((e) => `  ${e.instancePath || '/'} ${e.message}`)
      .join('\n');
    throw new Error(`risk params record is invalid:\n${errors}`);
  }
}

// generator inputs are strings: percentages as "72.5", caps as whole tokens, '' = keep current
const pct = (v?: Bps) => (v === undefined ? '' : String(v / 100));
const cap = (v?: V3Cap) => (v === undefined ? '' : v === 'unlimited' ? '0' : String(v));
const flag = (v?: boolean): BooleanSelectValues =>
  v === undefined ? 'KEEP_CURRENT' : v ? 'ENABLED' : 'DISABLED';
const rates = (r: V3Rates = {}) => ({
  optimalUtilizationRate: pct(r.optimal),
  baseVariableBorrowRate: pct(r.base),
  variableRateSlope1: pct(r.slope1),
  variableRateSlope2: pct(r.slope2),
});

function eModeCategory(market: string, ref: EModeRef) {
  if ('id' in ref) return String(ref.id);
  if ('label' in ref) return `${market}EModes.${ref.label}`;
  throw new Error(
    `${market}: assets of an eMode created in this AIP go in eModeCreates[].collateral / borrowable, not eModeAssets (ref "${ref.ref}")`,
  );
}

const isAddress = (v?: string): v is Hex => !!v && /^0x[0-9a-fA-F]{40}$/.test(v);

function hasAny(u: V3ReserveUpdate, keys: (keyof V3ReserveUpdate)[]) {
  return keys.some((k) => u[k] !== undefined);
}

function v3Configs(
  market: string,
  m: V3Market,
  ops: RecordOps['markets'][string],
): MarketConfig['configs'] {
  const configs: MarketConfig['configs'] = {};

  if (m.listings?.length) {
    configs[FEATURE.ASSET_LISTING] = m.listings.map((l) => {
      const o = ops.listings?.[l.asset.symbol];
      if (!o) throw new Error(`${market}: missing ops (decimals) for ${l.asset.symbol}`);
      const priceFeed = isAddress(l.priceFeed) ? l.priceFeed : o.priceFeed;
      if (!isAddress(priceFeed))
        throw new Error(
          `${market}: price feed "${l.priceFeed}" for ${l.asset.symbol} needs its address in ops`,
        );
      return {
        assetSymbol: l.asset.symbol,
        decimals: o.decimals,
        priceFeed,
        ltv: pct(l.ltv),
        liqThreshold: pct(l.liqThreshold),
        liqBonus: pct(l.liqBonus),
        liqProtocolFee: pct(l.liqProtocolFee),
        enabledToBorrow: flag(l.borrowable),
        flashloanable: flag(l.flashloanable),
        reserveFactor: pct(l.reserveFactor),
        supplyCap: cap(l.supplyCap),
        borrowCap: cap(l.borrowCap),
        rateStrategyParams: rates(l.rates),
        asset: l.asset.address,
        admin: o.admin ?? '',
        ...(o.seedAmount ? {seedAmount: o.seedAmount} : {}),
      };
    });
  }

  const updates = m.reserveUpdates || [];
  const pick = (keys: (keyof V3ReserveUpdate)[]) => updates.filter((u) => hasAny(u, keys));
  const collaterals = pick(['ltv', 'liqThreshold', 'liqBonus', 'liqProtocolFee']);
  if (collaterals.length)
    configs[FEATURE.COLLATERALS_UPDATE] = collaterals.map((u) => ({
      asset: u.asset.symbol,
      ltv: pct(u.ltv),
      liqThreshold: pct(u.liqThreshold),
      liqBonus: pct(u.liqBonus),
      liqProtocolFee: pct(u.liqProtocolFee),
    }));
  const borrows = pick(['borrowable', 'flashloanable', 'reserveFactor']);
  if (borrows.length)
    configs[FEATURE.BORROWS_UPDATE] = borrows.map((u) => ({
      asset: u.asset.symbol,
      enabledToBorrow: flag(u.borrowable),
      flashloanable: flag(u.flashloanable),
      reserveFactor: pct(u.reserveFactor),
    }));
  const caps = pick(['supplyCap', 'borrowCap']);
  if (caps.length)
    configs[FEATURE.CAPS_UPDATE] = caps.map((u) => ({
      asset: u.asset.symbol,
      supplyCap: cap(u.supplyCap),
      borrowCap: cap(u.borrowCap),
    }));
  const rateUpdates = pick(['rates']);
  if (rateUpdates.length)
    configs[FEATURE.RATE_UPDATE_V3] = rateUpdates.map((u) => ({
      asset: u.asset.symbol,
      params: rates(u.rates),
    }));
  const feeds = pick(['priceFeed']);
  if (feeds.length)
    configs[FEATURE.PRICE_FEEDS_UPDATE] = feeds.map((u) => {
      if (!isAddress(u.priceFeed))
        throw new Error(`${market}: price feed for ${u.asset.symbol} needs an address`);
      return {asset: u.asset.symbol, priceFeed: u.priceFeed};
    });
  const freezes = pick(['frozen']);
  if (freezes.length)
    configs[FEATURE.FREEZE] = freezes.map((u) => ({
      asset: u.asset.symbol,
      shouldBeFrozen: u.frozen!,
    }));

  if (m.eModeCreates?.length)
    configs[FEATURE.EMODES_CREATION] = m.eModeCreates.map((e) => ({
      ltv: pct(e.ltv),
      liqThreshold: pct(e.liqThreshold),
      liqBonus: pct(e.liqBonus),
      label: e.label,
      isolated: e.isolated ? 'ENABLED' : 'DISABLED',
      collateralAssets: e.collateral.map((a) => a.symbol),
      borrowableAssets: e.borrowable.map((a) => a.symbol),
    }));
  if (m.eModeUpdates?.length)
    configs[FEATURE.EMODES_UPDATES] = m.eModeUpdates.map((e) => ({
      eModeCategory: eModeCategory(market, e.eMode),
      ltv: pct(e.ltv),
      liqThreshold: pct(e.liqThreshold),
      liqBonus: pct(e.liqBonus),
      label: e.label ?? '',
      isolated: flag(e.isolated),
    }));
  if (m.eModeAssets?.length)
    configs[FEATURE.EMODES_ASSETS] = m.eModeAssets.map((e) => ({
      asset: e.asset.symbol,
      eModeCategory: eModeCategory(market, e.eMode),
      collateral: flag(e.collateral),
      borrowable: flag(e.borrowable),
      ltvzero: flag(e.ltvZero),
    }));
  return configs;
}

/// Record (risk values, from the provider) + ops (Aave Labs values) -> generator config.
export function configFromRecord(record: unknown, ops: RecordOps): ConfigFile {
  assertValidRecord(record);
  const marketOptions: ConfigFile['marketOptions'] = {};
  for (const [market, m] of Object.entries(record.markets)) {
    const o = ops.markets[market];
    if (!o) throw new Error(`${market}: missing ops (block number) for this market`);
    marketOptions[market as MarketIdentifier] = {
      configs: v3Configs(market, m as V3Market, o),
      cache: o.cache,
    };
  }
  return {
    rootOptions: {
      markets: Object.keys(record.markets) as MarketIdentifier[],
      discussion: record.forumPost,
      ...ops.rootOptions,
    } as ConfigFile['rootOptions'],
    marketOptions,
  };
}

/// Checks every asset against the market's address book: a symbol the book knows must come
/// with its address, and an address the book knows must come with its symbol. Assets listed in
/// the same record are the only ones allowed to be missing from the book.
export function assertKnownAssets(record: RiskParamsRecord) {
  const errors: string[] = [];
  for (const [market, raw] of Object.entries(record.markets)) {
    const book = (addressBook as Record<string, {ASSETS?: Record<string, {UNDERLYING: string}>}>)[
      market
    ];
    if (!book?.ASSETS) {
      errors.push(`${market}: not in the address book`);
      continue;
    }
    const m = raw as V3Market;
    const bySymbol = new Map(Object.entries(book.ASSETS).map(([s, a]) => [s, a.UNDERLYING]));
    const byAddress = new Map([...bySymbol].map(([s, a]) => [a.toLowerCase(), s]));
    const listed = new Set((m.listings ?? []).map((l) => l.asset.symbol));
    const check = (where: string, a: {symbol: string; address?: string}, isListing = false) => {
      const known = bySymbol.get(a.symbol);
      if (known && a.address && known.toLowerCase() !== a.address.toLowerCase())
        errors.push(
          `${market} ${where}: ${a.symbol} is ${known} in the address book, not ${a.address}`,
        );
      const owner = a.address && byAddress.get(a.address.toLowerCase());
      if (owner && owner !== a.symbol)
        errors.push(
          `${market} ${where}: ${a.address} is ${owner} in the address book, not ${a.symbol}`,
        );
      if (!known && !isListing && !listed.has(a.symbol))
        errors.push(`${market} ${where}: ${a.symbol} is not listed on this market`);
    };
    for (const l of m.listings ?? []) check('listings', l.asset, true);
    for (const u of m.reserveUpdates ?? []) check('reserveUpdates', u.asset);
    for (const e of m.eModeCreates ?? [])
      for (const a of [...e.collateral, ...e.borrowable]) check(`eModeCreates ${e.label}`, a);
    for (const e of m.eModeAssets ?? []) check('eModeAssets', e.asset);
  }
  if (errors.length)
    throw new Error(`risk params record has unknown assets:\n  ${errors.join('\n  ')}`);
}
