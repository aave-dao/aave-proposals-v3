import {describe, expect, it} from 'vitest';
import {compileGeneratedFiles} from '../utils/compileGeneratedFiles';
import type {Hex} from 'viem';
import {assertKnownAssets, configFromRecord} from './fromRecord';
import {recordFromConfig} from './toRecord';
import {generateFromConfig, generatePayloads, normalizeConfig, roundTrip} from './compare';
import type {RiskParamsRecord, V3Listing, V3Market} from './types';
import {LPF_INCREASE_ETHEREUM, MULTI_LTV_AND_EMODE_UPDATE, USDE_XLAYER_LISTING} from './fixtures';

const record = () => structuredClone(recordFromConfig(normalizeConfig(USDE_XLAYER_LISTING)));
const xLayer = (r: RiskParamsRecord) => r.markets.AaveV3XLayer as V3Market;

describe('risk params record', () => {
  it.each([
    ['USDe X Layer listing + new eMode', USDE_XLAYER_LISTING],
    ['LPF increase on Ethereum', LPF_INCREASE_ETHEREUM],
    ['multi-market LTV and eMode update', MULTI_LTV_AND_EMODE_UPDATE],
  ])('%s: config -> record -> config generates the same payload', async (_, cfg) => {
    const {original, record, rebuilt} = roundTrip(cfg);
    expect(record).toMatchSnapshot();
    expect(await generatePayloads(rebuilt)).toBe(await generatePayloads(original));
  });

  it('writes the seed amount from ops into the payload and its test', async () => {
    const {record: r, ops} = record();
    ops.markets.AaveV3XLayer.listings!.USDe.seedAmount = '100e18';
    const code = await generatePayloads(normalizeConfig(configFromRecord(r, ops)));
    expect(code).toContain('uint256 public constant USDe_SEED_AMOUNT = 100e18;');
    expect(code).toContain('proposal.USDe_SEED_AMOUNT()');
  });

  it('takes the price feed address from ops when the record names the feed', () => {
    const {record: r, ops} = record();
    const listing = xLayer(r).listings![0];
    const address = listing.priceFeed as Hex;
    listing.priceFeed = 'Capped USDT / USD';
    expect(() => configFromRecord(r, ops)).toThrow(/needs its address in ops/);
    ops.markets.AaveV3XLayer.listings!.USDe.priceFeed = address;
    const cfg = configFromRecord(r, ops);
    expect(cfg.marketOptions.AaveV3XLayer!.configs.ASSET_LISTING![0].priceFeed).toBe(address);
  });

  it('rejects values outside the limits', () => {
    const {record: r, ops} = record();
    xLayer(r).listings![0].rates.slope2 = 300_000; // 3000%
    expect(() => configFromRecord(r, ops)).toThrow(/slope2 must be <= 100000/);
  });

  it('rejects a listing with a missing field', () => {
    const {record: r, ops} = record();
    const listing: Partial<V3Listing> = xLayer(r).listings![0];
    delete listing.reserveFactor;
    expect(() => configFromRecord(r, ops)).toThrow(/must have required property 'reserveFactor'/);
  });

  it('rejects eModeAssets pointing at an eMode created in the same record', () => {
    const {record: r, ops} = record();
    const m = xLayer(r);
    m.eModeAssets!.push({
      asset: {symbol: 'USDe'},
      eMode: {ref: m.eModeCreates![0].ref},
      borrowable: true,
    });
    expect(() => configFromRecord(r, ops)).toThrow(/go in eModeCreates/);
  });

  it('rejects fields and markets the generator does not support', () => {
    const {record: r, ops} = record();
    Object.assign(xLayer(r).listings![0], {debtCeiling: 0});
    expect(() => configFromRecord(r, ops)).toThrow(
      /listings\/0 must NOT have additional properties/,
    );
    const {record: v4} = record();
    Object.assign(v4.markets, {AaveV4Ethereum: {}});
    expect(() => configFromRecord(v4, ops)).toThrow(/property name must be valid/);
  });

  it('keeps the order of listings and new eModes, which decides their ids', () => {
    const cfg = structuredClone(USDE_XLAYER_LISTING);
    const {ASSET_LISTING: listings, EMODES_CREATION: eModes} =
      cfg.marketOptions.AaveV3XLayer!.configs;
    listings!.unshift({...listings![0], assetSymbol: 'ZZZ'});
    eModes!.unshift({...eModes![0], label: 'ZZZ__Stablecoins'});
    const {original, rebuilt} = roundTrip(cfg);
    for (const c of [original, rebuilt]) {
      const configs = c.marketOptions.AaveV3XLayer!.configs;
      expect(configs.ASSET_LISTING!.map((l) => l.assetSymbol)).toEqual(['ZZZ', 'USDe']);
      expect(configs.EMODES_CREATION!.map((e) => e.label)).toEqual([
        'ZZZ__Stablecoins',
        'USDe__Stablecoins',
      ]);
    }
  });

  it('accepts assets that match the address book and assets listed in the same record', () => {
    expect(() => assertKnownAssets(record().record)).not.toThrow();
    expect(() => assertKnownAssets(recordFromConfig(LPF_INCREASE_ETHEREUM).record)).not.toThrow();
  });

  it('rejects an asset address that belongs to another symbol', () => {
    const {record: r} = record();
    xLayer(r).listings![0].asset.address = '0x779Ded0c9e1022225f8E0630b35a9b54bE713736'; // USDT
    expect(() => assertKnownAssets(r)).toThrow(/is USDT in the address book, not USDe/);
  });

  it('rejects a known symbol with another address', () => {
    const {record: r} = record();
    xLayer(r).reserveUpdates = [
      {asset: {symbol: 'USDT', address: '0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34'}, ltv: 0},
    ];
    expect(() => assertKnownAssets(r)).toThrow(
      /USDT is 0x779Ded0c9e1022225f8E0630b35a9b54bE713736/,
    );
  });

  it('rejects updates to an asset the market does not list', () => {
    const {record: r} = record();
    xLayer(r).reserveUpdates = [{asset: {symbol: 'WBTC'}, ltv: 0}];
    expect(() => assertKnownAssets(r)).toThrow(/WBTC is not listed on this market/);
  });

  it('compiles fractional seed literals like 0.001e8', async () => {
    const {record: r, ops} = record();
    ops.markets.AaveV3XLayer.listings!.USDe.seedAmount = '0.001e8';
    // its eMode constants were renamed in the address book since, which is unrelated here
    delete xLayer(r).eModeAssets;
    const files = await generateFromConfig(normalizeConfig(configFromRecord(r, ops)));
    expect(files.payloads[0].payload).toContain('USDe_SEED_AMOUNT = 0.001e8;');
    compileGeneratedFiles(files);
  }, 60_000);
});
