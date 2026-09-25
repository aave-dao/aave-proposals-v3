// sum.test.js
import {expect, describe, it} from 'vitest';
import {MOCK_OPTIONS, rateUpdateV2} from './mocks/configs';
import {generateFiles} from '../generator';
import {FEATURE, MarketConfigs} from '../types';
import {rateUpdatesV2, rateUpdatesV3} from './rateUpdates';
import {RateStrategyUpdate} from './types';
import {compileGeneratedFiles} from '../utils/compileGeneratedFiles';

describe('feature: rateUpdatesV2', () => {
  it('should return reasonable code', () => {
    const output = rateUpdatesV2.build({
      options: MOCK_OPTIONS,
      market: 'AaveV2EthereumAMM',
      cfg: rateUpdateV2,
      cache: {blockNumber: 42},
      configs: {},
    });
    expect(output).toMatchSnapshot();
  });

  it('should properly generate files', async () => {
    const marketConfigs: MarketConfigs = {
      ['AaveV2EthereumAMM']: {
        artifacts: [
          rateUpdatesV2.build({
            options: {...MOCK_OPTIONS, markets: ['AaveV2EthereumAMM']},
            market: 'AaveV2EthereumAMM',
            cfg: rateUpdateV2,
            cache: {blockNumber: 42},
            configs: {[FEATURE.RATE_UPDATE_V2]: rateUpdateV2},
          }),
        ],
        configs: {[FEATURE.RATE_UPDATE_V2]: rateUpdateV2},
        cache: {blockNumber: 42},
      },
    };
    const files = await generateFiles(
      {...MOCK_OPTIONS, markets: ['AaveV2EthereumAMM']},
      marketConfigs,
    );
    expect(files).toMatchSnapshot();
  });

  it('generates compilable Solidity', async () => {
    const options = {...MOCK_OPTIONS, markets: ['AaveV2EthereumAMM' as const]};
    const configs = {[FEATURE.RATE_UPDATE_V2]: rateUpdateV2};
    const marketConfigs: MarketConfigs = {
      AaveV2EthereumAMM: {
        artifacts: [
          rateUpdatesV2.build({
            options,
            market: 'AaveV2EthereumAMM',
            cfg: rateUpdateV2,
            cache: {blockNumber: 42},
            configs,
          }),
        ],
        configs,
        cache: {blockNumber: 42},
      },
    };

    compileGeneratedFiles(await generateFiles(options, marketConfigs));
  }, 60_000);
});

describe('feature: rateUpdatesV3', () => {
  const rateUpdateV3: RateStrategyUpdate[] = [
    {
      asset: 'DAI',
      params: {
        optimalUtilizationRate: '80',
        baseVariableBorrowRate: '0',
        variableRateSlope1: '4',
        variableRateSlope2: '60',
      },
    },
  ];

  it('generates assertions for every configured rate parameter', () => {
    const output = rateUpdatesV3.build({
      options: MOCK_OPTIONS,
      market: 'AaveV3Ethereum',
      cfg: rateUpdateV3,
      cache: {blockNumber: 42},
      configs: {[FEATURE.RATE_UPDATE_V3]: rateUpdateV3},
    });
    const test = output.test?.fn?.join('\n') ?? '';

    expect(test).toContain('getOptimalUsageRatio');
    expect(test).toContain('getBaseVariableBorrowRate');
    expect(test).toContain('getVariableRateSlope1');
    expect(test).toContain('getVariableRateSlope2');
  });

  it('generates compilable Solidity', async () => {
    const configs = {[FEATURE.RATE_UPDATE_V3]: rateUpdateV3};
    const marketConfigs: MarketConfigs = {
      AaveV3Ethereum: {
        artifacts: [
          rateUpdatesV3.build({
            options: MOCK_OPTIONS,
            market: 'AaveV3Ethereum',
            cfg: rateUpdateV3,
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
