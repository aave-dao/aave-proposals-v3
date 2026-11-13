import {FEATURE} from '../types';
import type {ConfigFile} from '../types';
import type {RateStrategyParams} from '../features/types';
import type {
  EModeRef,
  RecordOps,
  RiskParamsRecord,
  V3Market,
  V3Rates,
  V3ReserveUpdate,
} from './types';

/// Builds a record + ops from an existing config.ts. Used to fill pilot records and to test the
/// converter on past AIPs: config -> record -> config must generate the same payload.

// past AIPs without a forum link: the record needs a URL, the generator keeps "TODO" via ops
const NO_FORUM_POST = 'https://governance.aave.com/t/none';

const unset = (v: unknown) => v === '' || v === undefined || v === null || v === 'KEEP_CURRENT';
const num = (v: unknown) => parseFloat(String(v).replace(/_/g, ''));
const bps = (v: unknown) => (unset(v) ? undefined : Math.round(num(v) * 100));
const cap = (v: unknown) =>
  unset(v) ? undefined : num(v) === 0 ? ('unlimited' as const) : Math.round(num(v));
const bool = (v: unknown) =>
  v === 'ENABLED' || v === true ? true : v === 'DISABLED' || v === false ? false : undefined;
const clean = <T extends object>(o: T): T =>
  Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined)) as T;
const eref = (c: unknown): EModeRef =>
  /^\d+$/.test(String(c)) ? {id: Number(c)} : {label: String(c).replace(/^.*EModes\./, '')};
const rates = (p?: Partial<RateStrategyParams>): V3Rates =>
  clean({
    optimal: bps(p?.optimalUtilizationRate),
    base: bps(p?.baseVariableBorrowRate),
    slope1: bps(p?.variableRateSlope1),
    slope2: bps(p?.variableRateSlope2),
  });

export const SUPPORTED_V3 = [
  FEATURE.ASSET_LISTING,
  FEATURE.COLLATERALS_UPDATE,
  FEATURE.BORROWS_UPDATE,
  FEATURE.CAPS_UPDATE,
  FEATURE.RATE_UPDATE_V3,
  FEATURE.PRICE_FEEDS_UPDATE,
  FEATURE.FREEZE,
  FEATURE.EMODES_CREATION,
  FEATURE.EMODES_UPDATES,
  FEATURE.EMODES_ASSETS,
] as string[];

export function recordFromConfig(cfg: ConfigFile): {record: RiskParamsRecord; ops: RecordOps} {
  const ro = cfg.rootOptions;
  const date = String(ro.date);
  const record: RiskParamsRecord = {
    schemaVersion: '1.0',
    aip: ro.shortName,
    version: 1,
    updatedAt: `${date.slice(0, 4)}-${date.slice(4, 6)}-${date.slice(6, 8)}`,
    provider: ro.author || 'unknown',
    forumPost: ro.discussion || NO_FORUM_POST,
    markets: {},
  };
  const {markets: _m, discussion: _d, ...rest} = ro;
  const rootOptions: RecordOps['rootOptions'] = rest;
  if (!ro.discussion) rootOptions.discussion = undefined;
  const ops: RecordOps = {rootOptions, markets: {}};

  for (const [market, mo] of Object.entries(cfg.marketOptions)) {
    if (!market.startsWith('AaveV3')) throw new Error(`${market}: only V3 is supported`);
    const c = mo.configs || {};
    for (const f of Object.keys(c))
      if (!SUPPORTED_V3.includes(f))
        throw new Error(`${market}: feature ${f} is not in the record`);
    const out: V3Market = {};
    const mops: RecordOps['markets'][string] = {cache: mo.cache, listings: {}};

    for (const l of c[FEATURE.ASSET_LISTING] || []) {
      out.listings = out.listings || [];
      out.listings.push({
        asset: {symbol: l.assetSymbol, address: l.asset},
        priceFeed: l.priceFeed,
        ltv: bps(l.ltv)!,
        liqThreshold: bps(l.liqThreshold)!,
        liqBonus: bps(l.liqBonus)!,
        liqProtocolFee: bps(l.liqProtocolFee)!,
        reserveFactor: bps(l.reserveFactor)!,
        supplyCap: cap(l.supplyCap)!,
        borrowCap: cap(l.borrowCap)!,
        borrowable: bool(l.enabledToBorrow)!,
        flashloanable: bool(l.flashloanable)!,
        rates: rates(l.rateStrategyParams) as Required<V3Rates>,
      });
      mops.listings![l.assetSymbol] = clean({
        decimals: l.decimals,
        admin: l.admin,
        seedAmount: l.seedAmount,
      });
    }

    const upd = new Map<string, V3ReserveUpdate>();
    const U = (a: string) => upd.get(a) ?? upd.set(a, {asset: {symbol: a}}).get(a)!;
    for (const u of c[FEATURE.COLLATERALS_UPDATE] || [])
      Object.assign(
        U(u.asset),
        clean({
          ltv: bps(u.ltv),
          liqThreshold: bps(u.liqThreshold),
          liqBonus: bps(u.liqBonus),
          liqProtocolFee: bps(u.liqProtocolFee),
        }),
      );
    for (const u of c[FEATURE.BORROWS_UPDATE] || [])
      Object.assign(
        U(u.asset),
        clean({
          borrowable: bool(u.enabledToBorrow),
          flashloanable: bool(u.flashloanable),
          reserveFactor: bps(u.reserveFactor),
        }),
      );
    for (const u of c[FEATURE.CAPS_UPDATE] || [])
      Object.assign(U(u.asset), clean({supplyCap: cap(u.supplyCap), borrowCap: cap(u.borrowCap)}));
    for (const u of c[FEATURE.RATE_UPDATE_V3] || []) {
      const r = rates(u.params);
      if (Object.keys(r).length) U(u.asset).rates = r;
    }
    for (const u of c[FEATURE.PRICE_FEEDS_UPDATE] || []) U(u.asset).priceFeed = u.priceFeed;
    for (const u of c[FEATURE.FREEZE] || []) U(u.asset).frozen = !!u.shouldBeFrozen;
    const ups = [...upd.values()].filter((u) => Object.keys(u).length > 1);
    if (ups.length) out.reserveUpdates = ups;

    for (const [i, e] of (c[FEATURE.EMODES_CREATION] || []).entries()) {
      out.eModeCreates = out.eModeCreates || [];
      out.eModeCreates.push({
        ref: `new${i + 1}`,
        label: e.label,
        ltv: bps(e.ltv)!,
        liqThreshold: bps(e.liqThreshold)!,
        liqBonus: bps(e.liqBonus)!,
        isolated: bool(e.isolated) ?? false,
        collateral: (e.collateralAssets || []).map((s: string) => ({symbol: s})),
        borrowable: (e.borrowableAssets || []).map((s: string) => ({symbol: s})),
      });
    }
    for (const e of c[FEATURE.EMODES_UPDATES] || []) {
      const x = clean({
        eMode: eref(e.eModeCategory),
        label: unset(e.label) ? undefined : e.label,
        ltv: bps(e.ltv),
        liqThreshold: bps(e.liqThreshold),
        liqBonus: bps(e.liqBonus),
        isolated: bool(e.isolated),
      });
      if (Object.keys(x).length > 1) (out.eModeUpdates = out.eModeUpdates || []).push(x);
    }
    for (const e of c[FEATURE.EMODES_ASSETS] || []) {
      const x = clean({
        asset: {symbol: e.asset},
        eMode: eref(e.eModeCategory),
        collateral: bool(e.collateral),
        borrowable: bool(e.borrowable),
        ltvZero: bool(e.ltvzero),
      });
      if (Object.keys(x).length > 2) (out.eModeAssets = out.eModeAssets || []).push(x);
    }
    record.markets[market] = out;
    ops.markets[market] = mops;
  }
  return {record, ops};
}
