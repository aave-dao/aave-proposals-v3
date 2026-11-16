import {describe, expect, it} from 'vitest';
import fs from 'fs';
import os from 'os';
import path from 'path';
import {generateContractName} from '../common';
import type {ConfigFile} from '../types';
import {checkCommitted} from './committed';
import {generateFromConfig, normalizeConfig} from './compare';
import {recordFromConfig} from './toRecord';
import type {V3Market} from './types';
import {LPF_INCREASE_ETHEREUM, USDE_XLAYER_LISTING} from './fixtures';

/// Writes a proposal folder the way the generator does: config.ts and the payload contracts.
async function proposal(fixture: ConfigFile) {
  const config = normalizeConfig(fixture);
  const files = await generateFromConfig(config);
  const folder = fs.mkdtempSync(path.join(os.tmpdir(), 'proposal-'));
  fs.writeFileSync(path.join(folder, 'config.ts'), files.jsonConfig);
  const payloads = files.payloads.map((p) =>
    path.join(folder, `${generateContractName(config.rootOptions, p.market)}.sol`),
  );
  files.payloads.forEach((p, i) => fs.writeFileSync(payloads[i], p.payload));
  return {folder, payloads, record: recordFromConfig(config).record};
}

describe('risk params record: committed files', () => {
  it('accepts a folder generated from its record', async () => {
    const {folder, record} = await proposal(LPF_INCREASE_ETHEREUM);
    expect((await checkCommitted(folder, record)).errors).toEqual([]);
  });

  it('resolves a feed the record names through the address in config.ts', async () => {
    const {folder, record} = await proposal(USDE_XLAYER_LISTING);
    (record.markets.AaveV3XLayer as V3Market).listings![0].priceFeed = 'Capped USDT / USD';
    expect((await checkCommitted(folder, record)).errors).toEqual([]);
  });

  it('reports a record that disagrees with config.ts', async () => {
    const {folder, record} = await proposal(LPF_INCREASE_ETHEREUM);
    (record.markets.AaveV3Ethereum as V3Market).reserveUpdates![0].liqProtocolFee = 2500;
    const {errors} = await checkCommitted(folder, record);
    expect(errors).toEqual([
      expect.stringMatching(
        /^riskParams.json and config.ts generate different payloads, first difference at line \d+: config.ts has `liqProtocolFee: 20_00`, riskParams.json has `liqProtocolFee: 25_00`$/,
      ),
    ]);
  });

  it('reports a hand-edited payload', async () => {
    const {folder, payloads, record} = await proposal(LPF_INCREASE_ETHEREUM);
    const code = fs.readFileSync(payloads[0], 'utf8');
    fs.writeFileSync(payloads[0], code.replace('liqProtocolFee: 20_00', 'liqProtocolFee: 24_00'));
    const {errors} = await checkCommitted(folder, record);
    expect(errors).toEqual([
      expect.stringMatching(
        /is not what config.ts generates, first difference at line \d+: config.ts generates has `liqProtocolFee: 20_00`, the committed file has `liqProtocolFee: 24_00`$/,
      ),
    ]);
  });

  it('reports a missing payload contract and a missing config.ts', async () => {
    const {folder, payloads, record} = await proposal(LPF_INCREASE_ETHEREUM);
    fs.rmSync(payloads[0]);
    expect((await checkCommitted(folder, record)).errors).toEqual([
      `${path.basename(payloads[0])} is missing`,
    ]);
    fs.rmSync(path.join(folder, 'config.ts'));
    expect((await checkCommitted(folder, record)).errors).toEqual([
      `${folder}: no config.ts next to the record`,
    ]);
  });
});
