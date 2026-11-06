// sum.test.js
import {expect, describe, it} from 'vitest';
import {MOCK_OPTIONS, priceFeedsUpdateConfig} from './mocks/configs';
import {generateFiles} from '../generator';
import {FEATURE, MarketConfigs} from '../types';
import {priceFeedsUpdates} from './priceFeedsUpdates';
import {compileGeneratedFiles} from '../utils/compileGeneratedFiles';

describe('feature: priceFeedsUpdates', () => {
  it('should return reasonable code', () => {
    const output = priceFeedsUpdates.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: priceFeedsUpdateConfig,
      cache: {blockNumber: 42},
      configs: {},
    });
    expect(output).toMatchSnapshot();
  });

  it('generates an execution assertion for the configured price feed', () => {
    const output = priceFeedsUpdates.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: priceFeedsUpdateConfig,
      cache: {blockNumber: 42},
      configs: {},
    });
    const test = output.test?.fn?.join('\n') ?? '';

    expect(test).toContain('GovV3Helpers.executePayload(vm, address(proposal));');
    expect(test).toContain('getSourceOfAsset');
    expect(test).toContain('unexpected price feed');
  });

  it('should properly generate files', async () => {
    const marketConfigs: MarketConfigs = {
      [MOCK_OPTIONS.markets[0]]: {
        market: MOCK_OPTIONS.markets[0],
        artifacts: [
          priceFeedsUpdates.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg: priceFeedsUpdateConfig,
            cache: {blockNumber: 42},
            configs: {[FEATURE.PRICE_FEEDS_UPDATE]: priceFeedsUpdateConfig},
          }),
        ],
        configs: {[FEATURE.PRICE_FEEDS_UPDATE]: priceFeedsUpdateConfig},
        cache: {blockNumber: 42},
      },
    };
    const files = await generateFiles(MOCK_OPTIONS, marketConfigs);
    expect(files).toMatchSnapshot();
  });

  it('generates compilable Solidity', async () => {
    const configs = {[FEATURE.PRICE_FEEDS_UPDATE]: priceFeedsUpdateConfig};
    const marketConfigs: MarketConfigs = {
      [MOCK_OPTIONS.markets[0]]: {
        market: MOCK_OPTIONS.markets[0],
        artifacts: [
          priceFeedsUpdates.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg: priceFeedsUpdateConfig,
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
