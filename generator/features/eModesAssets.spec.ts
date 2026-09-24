import {describe, expect, it} from 'vitest';
import {generateFiles} from '../generator';
import {FEATURE, MarketConfigs} from '../types';
import {compileGeneratedFiles} from '../utils/compileGeneratedFiles';
import {eModeAssets} from './eModesAssets';
import {assetListingConfig, MOCK_OPTIONS} from './mocks/configs';
import {AssetEModeUpdate} from './types';

const eModeAssetUpdates: AssetEModeUpdate[] = [
  {
    asset: 'DAI',
    eModeCategory: 1,
    collateral: 'ENABLED',
    borrowable: 'DISABLED',
    ltvzero: 'KEEP_CURRENT',
  },
];

function buildMarketConfigs(): MarketConfigs {
  const configs = {[FEATURE.EMODES_ASSETS]: eModeAssetUpdates};
  return {
    AaveV3Ethereum: {
      artifacts: [
        eModeAssets.build({
          options: MOCK_OPTIONS,
          market: 'AaveV3Ethereum',
          cfg: eModeAssetUpdates,
          cache: {blockNumber: 42},
          configs,
        }),
      ],
      configs,
      cache: {blockNumber: 42},
    },
  };
}

describe('feature: eModeAssets', () => {
  it('generates assertions for every eMode asset flag', () => {
    const output = eModeAssets.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: eModeAssetUpdates,
      cache: {blockNumber: 42},
      configs: {[FEATURE.EMODES_ASSETS]: eModeAssetUpdates},
    });
    const test = output.test?.fn?.join('\n') ?? '';

    expect(test).toContain('getEModeCategoryCollateralBitmap');
    expect(test).toContain('getEModeCategoryBorrowableBitmap');
    expect(test).toContain('getEModeCategoryLtvzeroBitmap');
    expect(test).toContain('beforeLtvzero');
  });

  it('resolves the reserve mask after execution for a newly listed asset, without a KEEP_CURRENT before-capture', () => {
    const newListingSymbol = assetListingConfig[0].assetSymbol;
    const newListingEModeUpdates: AssetEModeUpdate[] = [
      {
        asset: newListingSymbol,
        eModeCategory: 1,
        collateral: 'ENABLED',
        borrowable: 'DISABLED',
        ltvzero: 'KEEP_CURRENT',
      },
    ];
    const configs = {
      [FEATURE.ASSET_LISTING]: assetListingConfig,
      [FEATURE.EMODES_ASSETS]: newListingEModeUpdates,
    };
    const output = eModeAssets.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: newListingEModeUpdates,
      cache: {blockNumber: 42},
      configs,
    });
    const test = output.test?.fn?.join('\n') ?? '';
    const executeIndex = test.indexOf('GovV3Helpers.executePayload');
    const reserveMaskIndex = test.indexOf('reserveMask =');

    expect(reserveMaskIndex).toBeGreaterThan(-1);
    expect(reserveMaskIndex).toBeGreaterThan(executeIndex);
    expect(test).not.toContain('beforeLtvzero');
    expect(test).toContain(newListingSymbol);
  });

  it('generates compilable Solidity', async () => {
    compileGeneratedFiles(await generateFiles(MOCK_OPTIONS, buildMarketConfigs()));
  }, 60_000);
});
