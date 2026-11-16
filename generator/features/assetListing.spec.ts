// sum.test.js
import {expect, describe, it} from 'vitest';
import {assetListing, assetListingCustom} from './assetListing';
import {
  MOCK_OPTIONS,
  assetListingConfig,
  assetListingCustomConfig,
  ptListingConfig,
} from './mocks/configs';
import {generateFiles} from '../generator';
import {FEATURE, MarketConfigs} from '../types';
import {compileGeneratedFiles} from '../utils/compileGeneratedFiles';

describe('feature: assetListing', () => {
  it('should return reasonable code', () => {
    const output = assetListing.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: assetListingConfig,
      cache: {blockNumber: 42},
      configs: {},
    });
    expect(output).toMatchSnapshot();
  });

  it('should return reasonable custom code', () => {
    const output = assetListingCustom.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: assetListingCustomConfig,
      cache: {blockNumber: 42},
      configs: {},
    });
    expect(output).toMatchSnapshot();
  });

  it('asserts listings against the onchain symbol', () => {
    const output = assetListing.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: ptListingConfig,
      cache: {blockNumber: 42},
      configs: {},
    });
    expect(output.code?.fn?.join('\n')).toContain('assetSymbol: "PT_sUSDe_TEST"');
    expect(output.test?.fn?.join('\n')).toContain('assetSymbol: "PT-sUSDe-TEST"');
    expect(output.test?.fn?.join('\n')).not.toContain('assetSymbol: "PT_sUSDe_TEST"');
  });

  it('compiles onchain symbols with quotes, backslashes, control and non-ASCII characters', async () => {
    const cfg = [{...ptListingConfig[0], onchainSymbol: 'P"T\\USD₮0\n'}];
    const configs = {[FEATURE.ASSET_LISTING]: cfg};
    const files = await generateFiles(MOCK_OPTIONS, {
      [MOCK_OPTIONS.markets[0]]: {
        artifacts: [
          assetListing.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg,
            cache: {blockNumber: 42},
            configs,
          }),
        ],
        configs,
        cache: {blockNumber: 42},
      },
    });
    expect(files.payloads[0].test).toMatch(/assetSymbol: unicode'P"T\\\\USD₮0\\n'/);
    compileGeneratedFiles(files);
  }, 60_000);

  it('should properly generate files', async () => {
    const marketConfigs: MarketConfigs = {
      [MOCK_OPTIONS.markets[0]]: {
        market: MOCK_OPTIONS.markets[0],
        artifacts: [
          assetListing.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg: assetListingConfig,
            cache: {blockNumber: 42},
            configs: {[FEATURE.ASSET_LISTING]: assetListingConfig},
          }),
        ],
        configs: {[FEATURE.ASSET_LISTING]: assetListingConfig},
        cache: {blockNumber: 42},
      },
    };
    const files = await generateFiles(MOCK_OPTIONS, marketConfigs);
    expect(files).toMatchSnapshot();
  });

  it('generates compilable files for every listing variant', async () => {
    const configs = {
      [FEATURE.ASSET_LISTING]: assetListingConfig,
      [FEATURE.ASSET_LISTING_CUSTOM]: assetListingCustomConfig,
    };
    const marketConfigs: MarketConfigs = {
      [MOCK_OPTIONS.markets[0]]: {
        market: MOCK_OPTIONS.markets[0],
        artifacts: [
          assetListing.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg: assetListingConfig,
            cache: {blockNumber: 42},
            configs,
          }),
          assetListingCustom.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg: assetListingCustomConfig,
            cache: {blockNumber: 42},
            configs,
          }),
        ],
        configs,
        cache: {blockNumber: 42},
      },
    };

    compileGeneratedFiles(await generateFiles(MOCK_OPTIONS, marketConfigs));
  }, 60_000);
});
