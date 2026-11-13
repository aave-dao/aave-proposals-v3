import fs from 'fs';
import * as addressBook from '@aave-dao/aave-address-book';
import type {ConfigFile, MarketIdentifier} from '../types';
import type {Revision} from './revision';
import type {Bps, EModeRef, RiskParamsRecord, V3Cap, V3Market, V3Rates} from './types';

/// Builds the PR table from a record and the fork snapshots written by `defaultTest`
/// (reports/<contract>_before.json and _after.json). "Proposed" comes from the record and
/// "After execution" from the fork, so a payload that doesn't do what the record says shows up
/// as a mismatch instead of being repeated in the table.

export interface SnapshotReserve {
  symbol: string;
  id: number;
  underlying: string;
  ltv: number;
  liquidationThreshold: number;
  liquidationBonus: number;
  liquidationProtocolFee: number;
  reserveFactor: number;
  supplyCap: number;
  borrowCap: number;
  borrowingEnabled: boolean;
  isFlashloanable: boolean;
  isFrozen: boolean;
  isPaused: boolean;
  isActive: boolean;
  oracle: string;
}

export interface SnapshotStrategy {
  optimalUsageRatio: string;
  baseVariableBorrowRate: string;
  variableRateSlope1: string;
  variableRateSlope2: string;
}

export interface SnapshotEMode {
  eModeCategory: number;
  label: string;
  ltv: number;
  liquidationThreshold: number;
  liquidationBonus: number;
  isolated?: boolean;
  collateralBitmap: string;
  borrowableBitmap: string;
  ltvzeroBitmap?: string;
}

export interface Snapshot {
  reserves: Record<string, SnapshotReserve>;
  strategies: Record<string, SnapshotStrategy>;
  eModes?: Record<string, SnapshotEMode>;
}

/// Whether the snapshots of a market come from a passing test, and how we know.
export interface ForkStatus {
  market: string;
  passedIn?: 'test log' | 'this check';
}

export interface ForkResult {
  before: Snapshot;
  after: Snapshot;
}

type Kind = 'pct' | 'cap' | 'bool' | 'address' | 'rate' | 'assets' | 'text';
type Value = number | bigint | boolean | string | string[];

export interface Row {
  market: string;
  subject: string;
  parameter: string;
  kind: Kind;
  current?: Value;
  proposed?: Value;
  actual?: Value;
  /// Changed by the payload although the record leaves it as is.
  unplanned?: boolean;
  /// The fork snapshot doesn't hold this value, so it can't be checked.
  unverified?: boolean;
  /// true: fork matches the record, false: it doesn't, undefined: no fork result.
  ok?: boolean;
}

const RAY_PER_BPS = 10n ** 23n;
const EMPTY = '—';

// ---------- formatting

function pct(bps: number | bigint) {
  // rates come in ray; keep their full precision
  const s =
    typeof bps === 'bigint'
      ? trimDecimals((Number(bps / 10n ** 21n) / 1e4).toFixed(4))
      : trimDecimals((bps / 100).toFixed(2));
  return `${s}%`;
}
const trimDecimals = (s: string) => s.replace(/\.?0+$/, '');

export function formatValue(kind: Kind, v?: Value): string {
  if (v === undefined) return EMPTY;
  switch (kind) {
    case 'pct':
      return pct(v as number);
    case 'rate':
      return pct(v as bigint);
    case 'cap':
      return v === 0 ? 'unlimited' : (v as number).toLocaleString('en-US');
    case 'bool':
      return v ? 'yes' : 'no';
    case 'address':
      return `\`${(v as string).slice(0, 6)}…${(v as string).slice(-4)}\``;
    case 'text':
      return String(v);
    case 'assets':
      return (v as string[]).length ? (v as string[]).join(', ') : 'none';
  }
}

const same = (kind: Kind, a?: Value, b?: Value) =>
  Array.isArray(a) && Array.isArray(b)
    ? a.length === b.length && a.every((x, i) => x === b[i])
    : kind === 'address' && typeof a === 'string' && typeof b === 'string'
      ? a.toLowerCase() === b.toLowerCase()
      : a === b;

// ---------- snapshot reading

const bonus = (v: number) => (v === 0 ? 0 : v - 10_000);
const ray = (v: string) => BigInt(v);
const rayFromBps = (bps: Bps) => BigInt(bps) * RAY_PER_BPS;
const capValue = (c: V3Cap) => (c === 'unlimited' ? 0 : c);

const RESERVE_PARAMS = [
  ['ltv', 'LTV', 'pct', (r: SnapshotReserve) => r.ltv],
  ['liqThreshold', 'Liquidation threshold', 'pct', (r: SnapshotReserve) => r.liquidationThreshold],
  ['liqBonus', 'Liquidation bonus', 'pct', (r: SnapshotReserve) => bonus(r.liquidationBonus)],
  [
    'liqProtocolFee',
    'Liquidation protocol fee',
    'pct',
    (r: SnapshotReserve) => r.liquidationProtocolFee,
  ],
  ['reserveFactor', 'Reserve factor', 'pct', (r: SnapshotReserve) => r.reserveFactor],
  ['supplyCap', 'Supply cap', 'cap', (r: SnapshotReserve) => r.supplyCap],
  ['borrowCap', 'Borrow cap', 'cap', (r: SnapshotReserve) => r.borrowCap],
  ['borrowable', 'Borrowable', 'bool', (r: SnapshotReserve) => r.borrowingEnabled],
  ['flashloanable', 'Flashloanable', 'bool', (r: SnapshotReserve) => r.isFlashloanable],
  ['frozen', 'Frozen', 'bool', (r: SnapshotReserve) => r.isFrozen],
  ['paused', 'Paused', 'bool', (r: SnapshotReserve) => r.isPaused],
  ['active', 'Active', 'bool', (r: SnapshotReserve) => r.isActive],
  ['priceFeed', 'Price feed', 'address', (r: SnapshotReserve) => r.oracle],
] as const;

const RATE_PARAMS = [
  ['optimal', 'Optimal usage', (s: SnapshotStrategy) => ray(s.optimalUsageRatio)],
  ['base', 'Base rate', (s: SnapshotStrategy) => ray(s.baseVariableBorrowRate)],
  ['slope1', 'Slope 1', (s: SnapshotStrategy) => ray(s.variableRateSlope1)],
  ['slope2', 'Slope 2', (s: SnapshotStrategy) => ray(s.variableRateSlope2)],
] as const;

type ReserveIntent = Partial<Record<(typeof RESERVE_PARAMS)[number][0], Value>> & {
  rates?: V3Rates;
};

const find = <T>(map: Record<string, T> | undefined, address: string) =>
  Object.entries(map ?? {}).find(([k]) => k.toLowerCase() === address.toLowerCase())?.[1];

/// Same naming as the address book's eMode constants (generator/common.ts getEModes).
const eModeName = (label: string) =>
  label
    .replace(/\s*\/\s*/g, '__')
    .replace(/[^\w ]/gi, ' ')
    .replace(/ +/gi, '_');

const bit = (bitmap: string | undefined, id: number) =>
  bitmap === undefined ? undefined : ((BigInt(bitmap) >> BigInt(id)) & 1n) === 1n;

// ---------- the table

/// Resolves record symbols to addresses: the record, then the listing in config.ts, then the
/// address book. Lowercase, so they compare with snapshot keys.
function assetResolver(market: string, m: V3Market, config: ConfigFile | undefined) {
  const book =
    (addressBook as Record<string, {ASSETS?: Record<string, {UNDERLYING: string}>}>)[market]
      ?.ASSETS ?? {};
  const listings = config?.marketOptions[market as MarketIdentifier]?.configs.ASSET_LISTING ?? [];
  const toAddress = (symbol: string, address?: string) =>
    (
      address ??
      m.listings?.find((l) => l.asset.symbol === symbol)?.asset.address ??
      listings.find((l) => l.assetSymbol === symbol)?.asset ??
      book[symbol]?.UNDERLYING
    )?.toLowerCase();
  const names = new Map<string, string>();
  for (const [s, a] of Object.entries(book)) names.set(a.UNDERLYING.toLowerCase(), s);
  for (const l of listings) names.set(l.asset.toLowerCase(), l.assetSymbol);
  for (const l of m.listings ?? []) names.set(l.asset.address.toLowerCase(), l.asset.symbol);
  return {toAddress, symbolOf: (address: string) => names.get(address.toLowerCase())};
}

/// eMode ids by constant name, as in the address book the payload compiles against
/// (`<Market>EModes` in Solidity). Record labels are those names, onchain labels can differ.
export type EModeIds = Record<string, number>;

export function buildRows(
  market: string,
  m: V3Market,
  config: ConfigFile | undefined,
  fork: ForkResult | undefined,
  eModeIds: EModeIds = {},
): {rows: Row[]; errors: string[]} {
  const rows: Row[] = [];
  const errors: string[] = [];
  const {toAddress, symbolOf} = assetResolver(market, m, config);
  const reserveSymbol = (snap: Snapshot | undefined, address: string) =>
    symbolOf(address) ?? find(snap?.reserves, address)?.symbol ?? address;
  const push = (row: Omit<Row, 'ok'>) =>
    rows.push({
      ...row,
      ok: fork && !row.unverified ? same(row.kind, row.actual, row.proposed) : undefined,
    });

  // reserves: listings and updates
  const intents = new Map<string, {symbol: string; isNew: boolean; intent: ReserveIntent}>();
  const configListings = config?.marketOptions[market as MarketIdentifier]?.configs.ASSET_LISTING;
  for (const l of m.listings ?? []) {
    const feed =
      configListings?.find((c) => c.assetSymbol === l.asset.symbol)?.priceFeed ?? l.priceFeed;
    intents.set(l.asset.address.toLowerCase(), {
      symbol: l.asset.symbol,
      isNew: true,
      intent: {
        ltv: l.ltv,
        liqThreshold: l.liqThreshold,
        liqBonus: l.liqBonus,
        liqProtocolFee: l.liqProtocolFee,
        reserveFactor: l.reserveFactor,
        supplyCap: capValue(l.supplyCap),
        borrowCap: capValue(l.borrowCap),
        borrowable: l.borrowable,
        flashloanable: l.flashloanable,
        frozen: false,
        paused: false,
        active: true,
        priceFeed: feed,
        rates: l.rates,
      },
    });
  }
  for (const u of m.reserveUpdates ?? []) {
    const address = toAddress(u.asset.symbol, u.asset.address);
    if (!address) {
      errors.push(`${market}: can't resolve the address of ${u.asset.symbol}`);
      continue;
    }
    const intent: ReserveIntent = {
      ltv: u.ltv,
      liqThreshold: u.liqThreshold,
      liqBonus: u.liqBonus,
      liqProtocolFee: u.liqProtocolFee,
      reserveFactor: u.reserveFactor,
      supplyCap: u.supplyCap === undefined ? undefined : capValue(u.supplyCap),
      borrowCap: u.borrowCap === undefined ? undefined : capValue(u.borrowCap),
      borrowable: u.borrowable,
      flashloanable: u.flashloanable,
      frozen: u.frozen,
      priceFeed: u.priceFeed,
      rates: u.rates,
    };
    intents.set(address, {symbol: u.asset.symbol, isNew: false, intent});
  }

  for (const [address, {symbol, isNew, intent}] of intents) {
    const before = isNew ? undefined : find(fork?.before.reserves, address);
    const after = find(fork?.after.reserves, address);
    if (fork && !after) errors.push(`${market}: ${symbol} is not a reserve after execution`);
    if (fork && !isNew && !before)
      errors.push(`${market}: ${symbol} is not a reserve before execution`);
    const subject = isNew ? `${symbol} (new listing)` : symbol;
    for (const [key, label, kind, read] of RESERVE_PARAMS) {
      if (intent[key] === undefined) continue;
      push({
        market,
        subject,
        parameter: label,
        kind,
        current: before && read(before),
        proposed: intent[key],
        actual: after && read(after),
      });
    }
    const sBefore = isNew ? undefined : find(fork?.before.strategies, address);
    const sAfter = find(fork?.after.strategies, address);
    for (const [key, label, read] of RATE_PARAMS) {
      const bps = intent.rates?.[key];
      if (bps === undefined) continue;
      push({
        market,
        subject,
        parameter: label,
        kind: 'rate',
        current: sBefore && read(sBefore),
        proposed: rayFromBps(bps),
        actual: sAfter && read(sAfter),
      });
    }
  }

  if (fork) {
    // changes the record doesn't ask for: a payload doing more than reviewed
    for (const [address, after] of Object.entries(fork.after.reserves)) {
      const before = fork.before.reserves[address];
      const planned = intents.get(address.toLowerCase());
      if (!before) {
        if (!planned)
          errors.push(`${market}: ${after.symbol} is listed by the payload but not in the record`);
        continue;
      }
      for (const [key, label, kind, read] of RESERVE_PARAMS) {
        if (planned?.intent[key] !== undefined || same(kind, read(before), read(after))) continue;
        push({
          market,
          subject: reserveSymbol(fork.after, address),
          parameter: label,
          kind,
          current: read(before),
          proposed: read(before),
          unplanned: true,
          actual: read(after),
        });
      }
      const sBefore = fork.before.strategies[address];
      const sAfter = fork.after.strategies[address];
      if (sBefore && sAfter)
        for (const [key, label, read] of RATE_PARAMS) {
          if (planned?.intent.rates?.[key] !== undefined || read(sBefore) === read(sAfter))
            continue;
          push({
            market,
            subject: reserveSymbol(fork.after, address),
            parameter: label,
            kind: 'rate',
            current: read(sBefore),
            proposed: read(sBefore),
            unplanned: true,
            actual: read(sAfter),
          });
        }
    }
  }

  eModeRows(
    market,
    m,
    fork,
    eModeIds,
    toAddress,
    (a) => reserveSymbol(fork?.after, a),
    push,
    errors,
  );
  return {rows, errors};
}

function eModeRows(
  market: string,
  m: V3Market,
  fork: ForkResult | undefined,
  eModeIds: EModeIds,
  toAddress: (symbol: string) => string | undefined,
  symbolOf: (address: string) => string,
  push: (row: Omit<Row, 'ok'>) => void,
  errors: string[],
) {
  const before = fork?.before.eModes ?? {};
  const after = fork?.after.eModes ?? {};
  const byRef = (eModes: Record<string, SnapshotEMode>, ref: EModeRef) => {
    const id = 'id' in ref ? ref.id : 'label' in ref ? eModeIds[ref.label] : undefined;
    return Object.values(eModes).find((e) =>
      id !== undefined
        ? e.eModeCategory === id
        : 'label' in ref && eModeName(e.label) === ref.label,
    );
  };
  const refName = (ref: EModeRef) =>
    'id' in ref ? `id ${ref.id}` : 'label' in ref ? ref.label : ref.ref;
  const name = (b: SnapshotEMode | undefined, ref: EModeRef) =>
    b ? `${eModeName(b.label)} (id ${b.eModeCategory})` : refName(ref);
  const idOf = (address: string, snap?: Snapshot) => find(snap?.reserves, address)?.id;
  const members = (e: SnapshotEMode | undefined, bitmap: 'collateralBitmap' | 'borrowableBitmap') =>
    e &&
    Object.values(fork!.after.reserves)
      .filter((r) => bit(e[bitmap], r.id))
      .map((r) => symbolOf(r.underlying))
      .sort();
  // fields the record changes, per eMode id: anything else that moves is unplanned
  const planned = new Map<number, Set<string>>();
  const plan = (id: number, field: string) =>
    planned.set(id, (planned.get(id) ?? new Set()).add(field));
  const expectedBits = new Map<string, boolean>(); // `${id}:${bitmap}:${address}`

  for (const e of m.eModeCreates ?? []) {
    const created = Object.values(after).find(
      (x) => eModeName(x.label) === e.label && !before[x.eModeCategory],
    );
    if (fork && !created) errors.push(`${market}: eMode ${e.label} was not created`);
    const subject = `eMode ${e.label}${created ? ` (id ${created.eModeCategory}, new)` : ' (new)'}`;
    const symbols = (assets: {symbol: string}[]) => assets.map((a) => a.symbol).sort();
    for (const [label, kind, proposed, actual] of [
      ['LTV', 'pct', e.ltv, created?.ltv],
      ['Liquidation threshold', 'pct', e.liqThreshold, created?.liquidationThreshold],
      ['Liquidation bonus', 'pct', e.liqBonus, created && bonus(created.liquidationBonus)],
      ['Isolated', 'bool', e.isolated, created?.isolated],
      ['Collateral', 'assets', symbols(e.collateral), members(created, 'collateralBitmap')],
      ['Borrowable', 'assets', symbols(e.borrowable), members(created, 'borrowableBitmap')],
    ] as const)
      push({market, subject, parameter: label, kind, proposed, actual});
  }

  for (const e of m.eModeUpdates ?? []) {
    const b = byRef(before, e.eMode);
    const a = b && after[b.eModeCategory];
    if (fork && !b) errors.push(`${market}: eMode ${refName(e.eMode)} not found`);
    const subject = `eMode ${name(b, e.eMode)}`;
    for (const [label, kind, proposed, cur, actual] of [
      ['Label', 'text', e.label, b?.label, a?.label],
      ['LTV', 'pct', e.ltv, b?.ltv, a?.ltv],
      [
        'Liquidation threshold',
        'pct',
        e.liqThreshold,
        b?.liquidationThreshold,
        a?.liquidationThreshold,
      ],
      [
        'Liquidation bonus',
        'pct',
        e.liqBonus,
        b && bonus(b.liquidationBonus),
        a && bonus(a.liquidationBonus),
      ],
      ['Isolated', 'bool', e.isolated, b?.isolated, a?.isolated],
    ] as const)
      if (proposed !== undefined) {
        if (b) plan(b.eModeCategory, label);
        push({market, subject, parameter: label, kind, current: cur, proposed, actual});
      }
  }

  for (const e of m.eModeAssets ?? []) {
    const b = byRef(before, e.eMode);
    const a = b && after[b.eModeCategory];
    if (fork && !b) errors.push(`${market}: eMode ${refName(e.eMode)} not found`);
    const address = toAddress(e.asset.symbol);
    const id = address === undefined ? undefined : idOf(address, fork?.after);
    const subject = `${e.asset.symbol} in eMode ${name(b, e.eMode)}`;
    for (const [label, bitmap, proposed] of [
      ['Collateral', 'collateralBitmap', e.collateral],
      ['Borrowable', 'borrowableBitmap', e.borrowable],
      ['LTV zero', 'ltvzeroBitmap', e.ltvZero],
    ] as const) {
      if (proposed === undefined) continue;
      if (b && address) expectedBits.set(`${b.eModeCategory}:${bitmap}:${address}`, proposed);
      const unverified = !!fork && !!b && b[bitmap] === undefined;
      push({
        market,
        subject,
        parameter: unverified ? `${label} (not in snapshot)` : label,
        kind: 'bool',
        current: id === undefined ? undefined : bit(b?.[bitmap], id),
        proposed,
        actual: unverified || id === undefined ? undefined : bit(a?.[bitmap], id),
        unverified,
      });
    }
  }

  if (!fork) return;
  // eMode changes the record doesn't ask for
  for (const [key, b] of Object.entries(before)) {
    const a = after[key];
    if (!a) continue;
    const subject = `eMode ${eModeName(b.label)} (id ${b.eModeCategory})`;
    for (const [label, kind, cur, act] of [
      ['Label', 'text', b.label, a.label],
      ['LTV', 'pct', b.ltv, a.ltv],
      ['Liquidation threshold', 'pct', b.liquidationThreshold, a.liquidationThreshold],
      ['Liquidation bonus', 'pct', bonus(b.liquidationBonus), bonus(a.liquidationBonus)],
      ['Isolated', 'bool', b.isolated, a.isolated],
    ] as const)
      if (!planned.get(b.eModeCategory)?.has(label) && !same(kind, cur, act))
        push({
          market,
          subject,
          parameter: label,
          kind,
          current: cur,
          proposed: cur,
          unplanned: true,
          actual: act,
        });
    for (const bitmap of ['collateralBitmap', 'borrowableBitmap', 'ltvzeroBitmap'] as const)
      for (const r of Object.values(fork.after.reserves)) {
        const cur = bit(b[bitmap], r.id);
        const act = bit(a[bitmap], r.id);
        const expected = expectedBits.get(
          `${b.eModeCategory}:${bitmap}:${r.underlying.toLowerCase()}`,
        );
        if (cur === act || expected !== undefined) continue;
        push({
          market,
          subject: `${symbolOf(r.underlying)} in ${subject}`,
          parameter:
            bitmap === 'collateralBitmap'
              ? 'Collateral'
              : bitmap === 'borrowableBitmap'
                ? 'Borrowable'
                : 'LTV zero',
          kind: 'bool',
          current: cur,
          proposed: cur,
          unplanned: true,
          actual: act,
        });
      }
  }
}

// ---------- markdown

const STATUS = (ok?: boolean) => (ok === undefined ? '⚠️' : ok ? '✅' : '❌');

export function renderReport(
  record: RiskParamsRecord,
  revision: Revision,
  rows: Row[],
  errors: string[],
  forks: ForkStatus[],
): string {
  const rev = revision.previous
    ? `v${revision.version} (${revision.previous.label}: v${revision.previous.version}, ${
        revision.previous.paramsChanged ? 'parameters changed' : 'parameters unchanged'
      })`
    : `v${revision.version}`;
  const lines = [
    `### ${record.aip}`,
    '',
    `Risk params record ${rev} by **${record.provider}**, updated ${record.updatedAt} · [forum post](${record.forumPost})`,
    '',
  ];
  for (const f of forks)
    lines.push(
      f.passedIn
        ? `✅ ${f.market}: \`test_defaultProposalExecution\` passed (${f.passedIn}); "After execution" is its fork state.`
        : `❌ ${f.market}: no passing fork test, "After execution" is empty.`,
    );
  if (forks.length) lines.push('');
  lines.push(
    '| Market | Asset | Parameter | Current | Proposed | After execution | |',
    '| --- | --- | --- | --- | --- | --- | --- |',
    ...rows.map(
      (r) =>
        `| ${r.market} | ${r.subject} | ${r.parameter} | ${formatValue(r.kind, r.current)} | ${
          r.unplanned ? 'no change (not in record)' : formatValue(r.kind, r.proposed)
        } | ${formatValue(r.kind, r.actual)} | ${STATUS(r.ok)} |`,
    ),
  );
  const all = [...(revision.error ? [`Revision: ${revision.error}`] : []), ...errors];
  const mismatches = rows.filter((r) => r.ok === false).length;
  if (mismatches) all.push(`${mismatches} value(s) after execution differ from the record`);
  const unverified = rows.filter((r) => r.unverified).length;
  if (unverified)
    lines.push(
      '',
      `⚠️ ${unverified} value(s) are not in the fork snapshot and were not checked: verify them in the payload test.`,
    );
  if (all.length) lines.push('', '**Problems**', '', ...all.map((e) => `- ${e}`));
  return lines.join('\n');
}

export const recordMarkets = (record: RiskParamsRecord) =>
  Object.entries(record.markets) as [string, V3Market][];

/// Reads `library <market>EModes` from the Solidity address book.
export function readEModeIds(addressBookSrc: string, market: string): EModeIds {
  const file = `${addressBookSrc}/${market}.sol`;
  let source: string;
  try {
    source = fs.readFileSync(file, 'utf8');
  } catch {
    return {};
  }
  const lib = source.match(new RegExp(`library ${market}EModes \\{([^}]*)\\}`))?.[1] ?? '';
  return Object.fromEntries(
    [...lib.matchAll(/uint8 internal constant (\w+) = (\d+);/g)].map(([, n, id]) => [
      n,
      Number(id),
    ]),
  );
}
