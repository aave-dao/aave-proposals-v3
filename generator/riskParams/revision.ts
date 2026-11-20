import type {RiskParamsRecord} from './types';

/// JSON with sorted keys and without `fromPreset`, so key order, whitespace and preset notes
/// don't count as a parameter change. Array order still counts: it decides reserve and eMode ids.
export function canonical(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(canonical).join(',')}]`;
  if (value && typeof value === 'object')
    return `{${Object.entries(value)
      .filter(([k, v]) => k !== 'fromPreset' && v !== undefined)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => `${JSON.stringify(k)}:${canonical(v)}`)
      .join(',')}}`;
  return JSON.stringify(value);
}

export interface Revision {
  version: number;
  /// Version of the record the current one is compared against, if there is one.
  previous?: {version: number; label: string; paramsChanged: boolean};
  error?: string;
}

/// A record whose parameters changed must have a higher `version` than the one it replaces.
/// Edits that leave `markets` unchanged (formatting, notes, links) don't need a bump.
export function checkRevision(
  current: RiskParamsRecord,
  previous: RiskParamsRecord | undefined,
  label: string,
): Revision {
  if (!previous) return {version: current.version};
  const paramsChanged = canonical(current.markets) !== canonical(previous.markets);
  const rev: Revision = {
    version: current.version,
    previous: {version: previous.version, label, paramsChanged},
  };
  if (current.version < previous.version)
    rev.error = `version went down from ${previous.version} (${label}) to ${current.version}`;
  else if (paramsChanged && current.version === previous.version)
    rev.error = `parameters changed since ${label} but version is still ${current.version}: bump it to ${previous.version + 1}`;
  return rev;
}
