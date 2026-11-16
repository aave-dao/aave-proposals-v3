import fs from 'fs';
import path from 'path';
import {generateContractName} from '../common';
import type {ConfigFile} from '../types';
import {configFromRecord} from './fromRecord';
import {recordFromConfig} from './toRecord';
import {diffAt, generateFromConfig, generatePayloads, normalizeConfig} from './compare';
import type {RiskParamsRecord} from './types';

const diffMessage = (a: string, b: string, [la, lb]: [string, string]) => {
  const d = diffAt(a, b)!;
  return `line ${d.line}: ${la} has \`${d.a}\`, ${lb} has \`${d.b}\``;
};

/// Checks that a proposal folder is what its record generates: the record plus the
/// non-risk values in config.ts give the same payload as config.ts, and config.ts gives the
/// committed payload contracts. Tests and the AIP text are not compared, they are often
/// extended by hand.
export async function checkCommitted(
  folder: string,
  record: RiskParamsRecord,
): Promise<{config?: ConfigFile; errors: string[]}> {
  const configPath = path.resolve(folder, 'config.ts');
  if (!fs.existsSync(configPath)) return {errors: [`${folder}: no config.ts next to the record`]};
  const {config}: {config: ConfigFile} = await import(configPath);
  const errors: string[] = [];

  // record -> config, taking ops (block numbers, decimals, seeds, feed addresses) from config.ts
  let ops;
  try {
    ({ops} = recordFromConfig(normalizeConfig(config)));
  } catch (e) {
    return {
      config,
      errors: [`config.ts can't be checked against the record: ${(e as Error).message}`],
    };
  }
  for (const [market, mo] of Object.entries(config.marketOptions))
    for (const l of mo?.configs.ASSET_LISTING ?? []) {
      const lo = ops.markets[market]?.listings?.[l.assetSymbol];
      if (lo) lo.priceFeed = l.priceFeed;
    }
  try {
    const fromRecord = await generatePayloads(normalizeConfig(configFromRecord(record, ops)));
    const fromConfig = await generatePayloads(normalizeConfig(config));
    if (fromRecord !== fromConfig)
      errors.push(
        `riskParams.json and config.ts generate different payloads, first difference at ${diffMessage(fromConfig, fromRecord, ['config.ts', 'riskParams.json'])}`,
      );
  } catch (e) {
    errors.push(`riskParams.json doesn't generate a payload: ${(e as Error).message}`);
  }

  // config.ts -> committed payload contracts
  const files = await generateFromConfig(config);
  for (const p of files.payloads) {
    const file = path.join(folder, `${generateContractName(config.rootOptions, p.market)}.sol`);
    if (!fs.existsSync(file)) {
      errors.push(`${path.basename(file)} is missing`);
      continue;
    }
    const committed = fs.readFileSync(file, 'utf8');
    if (committed !== p.payload)
      errors.push(
        `${path.basename(file)} is not what config.ts generates, first difference at ${diffMessage(p.payload, committed, ['config.ts generates', 'the committed file'])}`,
      );
  }
  return {config, errors};
}
