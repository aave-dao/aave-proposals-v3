import {generateFiles} from '../generator';
import {FEATURE} from '../types';
import type {
  ConfigFile,
  FeatureModule,
  Files,
  MarketConfigs,
  MarketIdentifier,
  Options,
} from '../types';
import {rateUpdatesV3} from '../features/rateUpdates';
import {capsUpdates} from '../features/capsUpdates';
import {collateralsUpdates} from '../features/collateralsUpdates';
import {borrowsUpdates} from '../features/borrowsUpdates';
import {priceFeedsUpdates} from '../features/priceFeedsUpdates';
import {assetListing} from '../features/assetListing';
import {eModeCreations} from '../features/eModesCreation';
import {eModeUpdates} from '../features/eModesUpdates';
import {eModeAssets} from '../features/eModesAssets';
import {freezeUpdates} from '../features/freeze';
import {recordFromConfig} from './toRecord';
import {configFromRecord} from './fromRecord';

/// Helpers to check the record against existing configs: config -> record -> config must
/// generate the same payload and tests.

/// A config.ts as found in `src/`. Older ones name markets `pools` and `poolOptions`.
export type PastConfigFile = {
  rootOptions: Omit<Options, 'markets'> & {
    markets?: MarketIdentifier[];
    pools?: MarketIdentifier[];
  };
  marketOptions?: ConfigFile['marketOptions'];
  poolOptions?: ConfigFile['marketOptions'];
};

type Item = Record<string, unknown>;

// each module takes its own config type, picked by `value` below
const MODULES: FeatureModule<any>[] = [
  assetListing,
  collateralsUpdates,
  borrowsUpdates,
  capsUpdates,
  rateUpdatesV3,
  priceFeedsUpdates,
  freezeUpdates,
  eModeCreations,
  eModeUpdates,
  eModeAssets,
];
const ORDER = MODULES.map((m) => m.value as string);

const isUnset = (v: unknown) => v === '' || v === undefined || v === null || v === 'KEEP_CURRENT';
const KEYS = new Set(['asset', 'assetSymbol', 'eModeCategory']);
/// An item where every value is "keep current" does nothing onchain.
const isNoop = (x: Item) =>
  Object.entries(x).every(
    ([k, v]) =>
      KEYS.has(k) ||
      isUnset(v) ||
      (typeof v === 'object' && v !== null && Object.values(v).every(isUnset)),
  );
const sortKey = (x: Item) =>
  `${x.asset ?? x.assetSymbol ?? x.label ?? ''}|${x.eModeCategory ?? ''}`;

/// Same feature order and item order on both sides, so only values can differ.
/// Older configs call markets `pools` and predate some fields (eMode `isolated`, `ltvzero`);
/// they get the value the generator assumed at the time. Pre-3.7 fields are dropped because
/// the current generator no longer renders them.
export function normalizeConfig(cfg: PastConfigFile): ConfigFile {
  const {pools, ...rootOptions} = cfg.rootOptions;
  const out: ConfigFile = structuredClone({
    rootOptions: {...rootOptions, markets: rootOptions.markets ?? pools ?? []},
    marketOptions: cfg.marketOptions ?? cfg.poolOptions ?? {},
  });
  for (const mo of Object.values(out.marketOptions)) {
    const configs = mo.configs as Record<string, Item[]>;
    for (const e of configs[FEATURE.EMODES_UPDATES] || []) e.isolated ??= 'KEEP_CURRENT';
    for (const e of configs[FEATURE.EMODES_CREATION] || []) e.isolated ??= 'DISABLED';
    for (const e of configs[FEATURE.EMODES_ASSETS] || []) e.ltvzero ??= 'KEEP_CURRENT';
    for (const items of Object.values(configs))
      for (const x of Array.isArray(items) ? items : [])
        for (const k of ['debtCeiling', 'borrowableInIsolation', 'withSiloedBorrowing'])
          delete x[k];
    const sorted: Record<string, Item[]> = {};
    for (const f of ORDER) {
      const items = (configs[f] || []).filter((x) => f === FEATURE.ASSET_LISTING || !isNoop(x));
      // listings and new eModes keep their order: it decides reserve and eMode ids onchain
      const keepOrder = f === FEATURE.ASSET_LISTING || f === FEATURE.EMODES_CREATION;
      if (items.length)
        sorted[f] = keepOrder ? items : items.sort((a, b) => sortKey(a).localeCompare(sortKey(b)));
    }
    mo.configs = sorted;
  }
  return out;
}

/// Files the current generator writes for a config (features supported by the record only).
export async function generateFromConfig(cfg: ConfigFile): Promise<Files> {
  const options = {...cfg.rootOptions};
  const marketConfigs: MarketConfigs = {};
  for (const market of options.markets) {
    const mo = cfg.marketOptions[market]!;
    const configs = mo.configs as Record<string, unknown>;
    marketConfigs[market] = {
      configs: mo.configs,
      cache: mo.cache,
      artifacts: Object.keys(configs).map((f) =>
        MODULES.find((m) => m.value === f)!.build({
          options,
          market,
          cfg: configs[f],
          cache: mo.cache,
          configs: mo.configs,
        }),
      ),
    };
  }
  const log = console.log;
  console.log = () => {}; // generateFiles logs progress
  try {
    return await generateFiles(options, marketConfigs);
  } finally {
    console.log = log;
  }
}

/// Payload and test code the current generator writes for a config.
export async function generatePayloads(cfg: ConfigFile): Promise<string> {
  const files = await generateFromConfig(cfg);
  return files.payloads.map((p) => p.payload + '\n' + p.test).join('\n');
}

/// Runs config -> record -> config and normalizes both sides.
export function roundTrip(cfg: PastConfigFile) {
  const original = normalizeConfig(cfg);
  const {record, ops} = recordFromConfig(original);
  const rebuilt = normalizeConfig(configFromRecord(JSON.parse(JSON.stringify(record)), ops));
  return {original, record, rebuilt};
}

/// First line where two generated outputs differ, or undefined when they are the same.
export function diffAt(a: string, b: string) {
  const al = a.split('\n');
  const bl = b.split('\n');
  for (let i = 0; i < Math.max(al.length, bl.length); i++)
    if (al[i] !== bl[i]) return {line: i + 1, a: al[i]?.trim() ?? '', b: bl[i]?.trim() ?? ''};
}

export function firstDiff(a: string, b: string, [la, lb] = ['original', 'roundtrip']) {
  const d = diffAt(a, b);
  if (!d) return '';
  const width = Math.max(la.length, lb.length) + 2;
  return `line ${d.line}\n  ${`${la}:`.padEnd(width)}${d.a}\n  ${`${lb}:`.padEnd(width)}${d.b}`;
}
