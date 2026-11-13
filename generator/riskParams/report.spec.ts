import {describe, expect, it} from 'vitest';
import {buildRows, formatValue, readEModeIds, renderReport} from './report';
import type {ForkResult, Snapshot, SnapshotEMode, SnapshotReserve} from './report';
import {recordFromConfig} from './toRecord';
import {normalizeConfig} from './compare';
import type {RiskParamsRecord, V3Market} from './types';
import {USDE_XLAYER_LISTING} from './fixtures';

const RAY_PER_BPS = 10n ** 23n;
const WBTC = '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599';
const WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
const USDT = '0x779Ded0c9e1022225f8E0630b35a9b54bE713736'; // X Layer
const USDE = '0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34'; // X Layer

function reserve(
  symbol: string,
  id: number,
  underlying: string,
  values: Partial<SnapshotReserve> = {},
) {
  return {
    symbol,
    id,
    underlying,
    ltv: 7300,
    liquidationThreshold: 7800,
    liquidationBonus: 10500,
    liquidationProtocolFee: 2000,
    reserveFactor: 2000,
    supplyCap: 38200,
    borrowCap: 900,
    borrowingEnabled: true,
    isFlashloanable: true,
    isFrozen: false,
    isPaused: false,
    isActive: true,
    oracle: '0x0000000000000000000000000000000000000001',
    ...values,
  };
}
const strategy = (optimal: number, base: number, slope1: number, slope2: number) => ({
  optimalUsageRatio: String(BigInt(optimal) * RAY_PER_BPS),
  baseVariableBorrowRate: String(BigInt(base) * RAY_PER_BPS),
  variableRateSlope1: String(BigInt(slope1) * RAY_PER_BPS),
  variableRateSlope2: String(BigInt(slope2) * RAY_PER_BPS),
});
const eMode = (id: number, label: string, values: Partial<SnapshotEMode> = {}): SnapshotEMode => ({
  eModeCategory: id,
  label,
  ltv: 9000,
  liquidationThreshold: 9300,
  liquidationBonus: 10200,
  isolated: false,
  collateralBitmap: '0',
  borrowableBitmap: '0',
  ...values,
});

const lpfRecord = (): V3Market => ({
  reserveUpdates: [
    {asset: {symbol: 'WBTC'}, liqProtocolFee: 2500, supplyCap: 45_000, borrowCap: 'unlimited'},
    {asset: {symbol: 'WETH'}, rates: {slope1: 250}},
  ],
});
const ethereum = (wbtc: Partial<SnapshotReserve>, wethSlope1 = 220): Snapshot => ({
  reserves: {[WBTC]: reserve('WBTC', 4, WBTC, wbtc), [WETH]: reserve('WETH', 0, WETH)},
  strategies: {[WBTC]: strategy(4500, 0, 400, 30000), [WETH]: strategy(9000, 0, wethSlope1, 800)},
  eModes: {},
});

describe('risk params record: PR table', () => {
  it('formats percentages, caps and rates', () => {
    expect(formatValue('pct', 7500)).toBe('75%');
    expect(formatValue('pct', 750)).toBe('7.5%');
    expect(formatValue('pct', 25)).toBe('0.25%');
    expect(formatValue('cap', 0)).toBe('unlimited');
    expect(formatValue('cap', 100_000_000)).toBe('100,000,000');
    expect(formatValue('rate', 22n * 10n ** 24n)).toBe('2.2%');
    expect(formatValue('rate', 1234n * 10n ** 21n)).toBe('0.1234%');
    expect(formatValue('bool', true)).toBe('yes');
    expect(formatValue('pct', undefined)).toBe('—');
  });

  it('compares the record with the fork result, value by value', () => {
    const fork: ForkResult = {
      before: ethereum({}),
      after: ethereum({liquidationProtocolFee: 2400, supplyCap: 45_000, borrowCap: 0}, 250),
    };
    const {rows, errors} = buildRows('AaveV3Ethereum', lpfRecord(), undefined, fork);
    expect(errors).toEqual([]);
    expect(
      rows.map((r) => [r.subject, r.parameter, r.current, r.proposed, r.actual, r.ok]),
    ).toEqual([
      ['WBTC', 'Liquidation protocol fee', 2000, 2500, 2400, false],
      ['WBTC', 'Supply cap', 38200, 45_000, 45_000, true],
      ['WBTC', 'Borrow cap', 900, 0, 0, true],
      ['WETH', 'Slope 1', 220n * RAY_PER_BPS, 250n * RAY_PER_BPS, 250n * RAY_PER_BPS, true],
    ]);
  });

  it('flags changes the record does not ask for', () => {
    const fork: ForkResult = {
      before: ethereum({}),
      after: ethereum(
        {liquidationProtocolFee: 2500, supplyCap: 45_000, borrowCap: 0, reserveFactor: 3000},
        250,
      ),
    };
    const {rows} = buildRows('AaveV3Ethereum', lpfRecord(), undefined, fork);
    expect(rows.filter((r) => r.unplanned)).toEqual([
      expect.objectContaining({
        subject: 'WBTC',
        parameter: 'Reserve factor',
        current: 2000,
        actual: 3000,
        ok: false,
      }),
    ]);
  });

  it('shows the record without a fork result, marked as not checked', () => {
    const {rows} = buildRows('AaveV3Ethereum', lpfRecord(), undefined, undefined);
    expect(rows.every((r) => r.ok === undefined && r.actual === undefined)).toBe(true);
  });

  it('marks new listings and checks new eModes and eMode assets', () => {
    const {record, ops} = recordFromConfig(normalizeConfig(USDE_XLAYER_LISTING));
    const m = record.markets.AaveV3XLayer as V3Market;
    m.eModeAssets = [
      {asset: {symbol: 'USDe'}, eMode: {label: 'xBTC__USDT_USDG_GHO_USDC'}, borrowable: true},
    ];
    const usde = reserve('USDe', 9, USDE, {
      ltv: 0,
      liquidationThreshold: 0,
      liquidationBonus: 0,
      liquidationProtocolFee: 1000,
      reserveFactor: 2500,
      supplyCap: 100_000_000,
      borrowCap: 20_000_000,
      oracle: m.listings![0].priceFeed,
    });
    const usdt = reserve('USD₮0', 0, USDT);
    // onchain label differs from the address book name, as it did on X Layer
    const before: Snapshot = {
      reserves: {[USDT]: usdt},
      strategies: {[USDT]: strategy(9000, 0, 400, 6000)},
      eModes: {1: eMode(1, 'xBTC / Stablecoins', {borrowableBitmap: '1'})},
    };
    const after: Snapshot = {
      reserves: {[USDT]: usdt, [USDE]: usde},
      strategies: {...before.strategies, [USDE]: strategy(8500, 630, 25, 4500)},
      eModes: {
        1: eMode(1, 'xBTC / Stablecoins', {borrowableBitmap: String(1n | (1n << 9n))}),
        2: eMode(2, 'USDe / Stablecoins', {
          ltv: 9100,
          collateralBitmap: String(1n << 9n),
          borrowableBitmap: '1',
        }),
      },
    };
    m.eModeCreates![0] = {...m.eModeCreates![0], borrowable: [{symbol: 'USDT'}]};
    const {rows, errors} = buildRows(
      'AaveV3XLayer',
      m,
      normalizeConfig(USDE_XLAYER_LISTING),
      {before, after},
      {
        xBTC__USDT_USDG_GHO_USDC: 1,
      },
    );
    expect(errors).toEqual([]);
    expect(rows.filter((r) => r.ok !== true)).toEqual([]);
    expect(rows[0]).toMatchObject({
      subject: 'USDe (new listing)',
      parameter: 'LTV',
      current: undefined,
    });
    expect(rows).toContainEqual(
      expect.objectContaining({
        subject: 'eMode USDe__Stablecoins (id 2, new)',
        parameter: 'Collateral',
        actual: ['USDe'],
      }),
    );
    expect(rows).toContainEqual(
      expect.objectContaining({
        subject: 'USDe in eMode xBTC__Stablecoins (id 1)',
        parameter: 'Borrowable',
        current: false,
        actual: true,
      }),
    );
    expect(ops.markets.AaveV3XLayer).toBeDefined();
  });

  it('reports a listing that is missing after execution', () => {
    const {record} = recordFromConfig(normalizeConfig(USDE_XLAYER_LISTING));
    const empty: Snapshot = {reserves: {}, strategies: {}, eModes: {}};
    const {errors} = buildRows('AaveV3XLayer', record.markets.AaveV3XLayer as V3Market, undefined, {
      before: empty,
      after: empty,
    });
    expect(errors).toContain('AaveV3XLayer: USDe is not a reserve after execution');
    expect(errors).toContain('AaveV3XLayer: eMode USDe__Stablecoins was not created');
  });

  it('puts version, provider and revision in the header', () => {
    const record = {
      aip: 'Test',
      version: 2,
      provider: 'Chaos Labs',
      updatedAt: '2026-11-13',
      forumPost: 'https://x',
    } as RiskParamsRecord;
    const md = renderReport(
      record,
      {version: 2, previous: {version: 1, label: 'previous push', paramsChanged: true}},
      [],
      [],
      [{market: 'AaveV3Ethereum', passedIn: 'test log'}],
    );
    expect(md).toContain(
      'Risk params record v2 (previous push: v1, parameters changed) by **Chaos Labs**',
    );
    expect(md).toContain('✅ AaveV3Ethereum: `test_defaultProposalExecution` passed (test log)');
    expect(renderReport(record, {version: 2}, [], [], [{market: 'AaveV3Ethereum'}])).toContain(
      '❌ AaveV3Ethereum: no passing fork test',
    );
  });

  it('reads eMode ids from the Solidity address book', () => {
    const ids = readEModeIds('lib/aave-helpers/lib/aave-address-book/src', 'AaveV3XLayer');
    expect(ids.NONE).toBe(0);
    expect(Object.keys(ids).length).toBeGreaterThan(1);
    expect(readEModeIds('lib/aave-helpers/lib/aave-address-book/src', 'AaveV3Nowhere')).toEqual({});
  });

  describe('eMode updates', () => {
    const before: Snapshot = {
      reserves: {[USDT]: reserve('USD₮0', 0, USDT)},
      strategies: {},
      eModes: {1: eMode(1, 'xBTC / Stablecoins')},
    };
    const fork = (values: Partial<SnapshotEMode>): ForkResult => ({
      before,
      after: {...before, eModes: {1: eMode(1, 'xBTC / Stablecoins', values)}},
    });
    const update = (fields: object): V3Market => ({
      eModeUpdates: [{eMode: {id: 1}, ...fields}],
    });

    it('flags a field the record does not change on an eMode it updates', () => {
      const {rows} = buildRows(
        'AaveV3XLayer',
        update({ltv: 8000}),
        undefined,
        fork({ltv: 8000, liquidationThreshold: 9000}),
      );
      expect(rows.map((r) => [r.parameter, r.unplanned ?? false, r.ok])).toEqual([
        ['LTV', false, true],
        ['Liquidation threshold', true, false],
      ]);
    });

    it('checks a label update, case included', () => {
      const ok = buildRows(
        'AaveV3XLayer',
        update({label: 'xBTC / USDT'}),
        undefined,
        fork({label: 'xBTC / USDT'}),
      );
      expect(ok.rows).toEqual([expect.objectContaining({parameter: 'Label', ok: true})]);
      const bad = buildRows(
        'AaveV3XLayer',
        update({label: 'xBTC / USDT'}),
        undefined,
        fork({label: 'xbtc / usdt'}),
      );
      expect(bad.rows).toEqual([expect.objectContaining({parameter: 'Label', ok: false})]);
    });

    it('leaves LTV zero unchecked when the snapshot has no bitmap for it', () => {
      const m: V3Market = {
        eModeAssets: [{asset: {symbol: 'USDT'}, eMode: {id: 1}, ltvZero: true}],
      };
      const {rows} = buildRows('AaveV3XLayer', m, undefined, fork({}));
      expect(rows).toEqual([
        expect.objectContaining({
          parameter: 'LTV zero (not in snapshot)',
          actual: undefined,
          ok: undefined,
          unverified: true,
        }),
      ]);
      const md = renderReport(
        {aip: 'X', version: 1} as RiskParamsRecord,
        {version: 1},
        rows,
        [],
        [{market: 'AaveV3XLayer', passedIn: 'this check'}],
      );
      expect(md).toContain('| — | yes | — | ⚠️ |');
      expect(md).toContain('1 value(s) are not in the fork snapshot and were not checked');
    });
  });
});
