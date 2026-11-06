import {CodeArtifact, FEATURE, FeatureModule, MarketIdentifier} from '../types';
import {RateStrategyParams, RateStrategyUpdate} from './types';
import {
  assetsSelectPrompt,
  translateAssetToAssetLibUnderlying,
} from '../prompts/assetsSelectPrompt';
import {percentPrompt, translateJsPercentToSol} from '../prompts/percentPrompt';

function specifiedRateAssertions(
  params: RateStrategyParams,
  strategy: string,
  asset: string,
  v2: boolean,
): string[] {
  const args = v2 ? '' : asset;
  const values = [
    ['optimalUtilizationRate', v2 ? 'OPTIMAL_UTILIZATION_RATE' : 'getOptimalUsageRatio'],
    ['baseVariableBorrowRate', v2 ? 'baseVariableBorrowRate' : 'getBaseVariableBorrowRate'],
    ['variableRateSlope1', v2 ? 'variableRateSlope1' : 'getVariableRateSlope1'],
    ['variableRateSlope2', v2 ? 'variableRateSlope2' : 'getVariableRateSlope2'],
    ...(v2
      ? [
          ['stableRateSlope1', 'stableRateSlope1'],
          ['stableRateSlope2', 'stableRateSlope2'],
        ]
      : []),
  ] as const;

  return values
    .filter(([field]) => params[field] !== '')
    .map(
      ([field, getter]) =>
        `assertEq(${strategy}.${getter}(${args}), ${translateJsPercentToSol(params[field])} * 1e23, '${field} mismatch');`,
    );
}

function rateUpdateTests(
  market: MarketIdentifier,
  cfgs: RateStrategyUpdate[],
  v2: boolean,
): string[] {
  return cfgs.map((cfg, ix) => {
    const asset = translateAssetToAssetLibUnderlying(cfg.asset, market);
    const strategyType = v2 ? 'IDefaultInterestRateStrategy' : 'IDefaultInterestRateStrategyV2';
    const strategyAddress = v2
      ? `${market}.POOL.getReserveData(${asset}).interestRateStrategyAddress`
      : `${market}.AAVE_PROTOCOL_DATA_PROVIDER.getInterestRateStrategyAddress(${asset})`;
    return `function test_rateStrategyUpdate_${ix}() public {
      GovV3Helpers.executePayload(vm, address(proposal));

      ${strategyType} strategy = ${strategyType}(${strategyAddress});
      ${specifiedRateAssertions(cfg.params, 'strategy', asset, v2).join('\n      ')}
    }`;
  });
}

export async function fetchRateStrategyParamsV2(required?: boolean): Promise<RateStrategyParams> {
  return {
    optimalUtilizationRate: await percentPrompt({
      message: 'optimalUtilizationRate',
      required,
    }),
    baseVariableBorrowRate: await percentPrompt({
      message: 'baseVariableBorrowRate',
      required,
    }),
    variableRateSlope1: await percentPrompt({
      message: 'variableRateSlope1',
      required,
    }),
    variableRateSlope2: await percentPrompt({
      message: 'variableRateSlope2',
      required,
    }),
    stableRateSlope1: await percentPrompt({
      message: 'stableRateSlope1',
      required,
    }),
    stableRateSlope2: await percentPrompt({
      message: 'stableRateSlope2',
      required,
    }),
  };
}

export async function fetchRateStrategyParamsV3(required?: boolean) {
  return {
    optimalUtilizationRate: await percentPrompt({
      message: 'optimalUtilizationRate',
      required,
    }),
    baseVariableBorrowRate: await percentPrompt({
      message: 'baseVariableBorrowRate',
      required,
    }),
    variableRateSlope1: await percentPrompt({
      message: 'variableRateSlope1',
      required,
    }),
    variableRateSlope2: await percentPrompt({
      message: 'variableRateSlope2',
      required,
    }),
  };
}

export const rateUpdatesV2: FeatureModule<RateStrategyUpdate[]> = {
  value: FEATURE.RATE_UPDATE_V2,
  description: 'RateStrategiesUpdates',
  async cli({market}) {
    console.log(`Fetching information for RatesUpdate on ${market}`);
    const assets = await assetsSelectPrompt({
      message: 'Select the assets you want to amend',
      market,
    });
    const response: RateStrategyUpdate[] = [];
    for (const asset of assets) {
      console.log(`Fetching info for ${asset}`);
      response.push({asset, params: await fetchRateStrategyParamsV2()});
    }
    return response;
  },
  build({market, cfg}) {
    const response: CodeArtifact = {
      code: {
        fn: [
          `function rateStrategiesUpdates()
          public
          pure
          override
          returns (IAaveV2ConfigEngine.RateStrategyUpdate[] memory)
        {
          IAaveV2ConfigEngine.RateStrategyUpdate[] memory rateStrategies = new IAaveV2ConfigEngine.RateStrategyUpdate[](${
            cfg.length
          });
          ${cfg
            .map(
              (cfg, ix) => `rateStrategies[${ix}] = IAaveV2ConfigEngine.RateStrategyUpdate({
                asset: ${translateAssetToAssetLibUnderlying(cfg.asset, market)},
                params: IV2RateStrategyFactory.RateStrategyParams({
                  optimalUtilizationRate: ${translateJsPercentToSol(
                    cfg.params.optimalUtilizationRate,
                    true,
                  )},
                  baseVariableBorrowRate: ${translateJsPercentToSol(
                    cfg.params.baseVariableBorrowRate,
                    true,
                  )},
                  variableRateSlope1: ${translateJsPercentToSol(
                    cfg.params.variableRateSlope1,
                    true,
                  )},
                  variableRateSlope2: ${translateJsPercentToSol(
                    cfg.params.variableRateSlope2,
                    true,
                  )},
                  stableRateSlope1: ${translateJsPercentToSol(cfg.params.stableRateSlope1, true)},
                  stableRateSlope2: ${translateJsPercentToSol(cfg.params.stableRateSlope2, true)}
                })
              });`,
            )
            .join('\n')}


          return rateStrategies;
        }`,
        ],
      },
      test: {
        fn: rateUpdateTests(market, cfg, true),
      },
    };
    return response;
  },
};

export const rateUpdatesV3: FeatureModule<RateStrategyUpdate[]> = {
  value: FEATURE.RATE_UPDATE_V3,
  description: 'RateStrategiesUpdates',
  async cli({market}) {
    console.log(`Fetching information for RatesUpdate on ${market}`);
    const assets = await assetsSelectPrompt({
      message: 'Select the assets you want to amend',
      market,
    });
    const response: RateStrategyUpdate[] = [];
    for (const asset of assets) {
      console.log(`Fetching info for ${asset}`);
      response.push({asset, params: await fetchRateStrategyParamsV3()});
    }
    return response;
  },
  build({market, cfg}) {
    const response: CodeArtifact = {
      code: {
        fn: [
          `function rateStrategiesUpdates()
          public
          pure
          override
          returns (IAaveV3ConfigEngine.RateStrategyUpdate[] memory)
        {
          IAaveV3ConfigEngine.RateStrategyUpdate[] memory rateStrategies = new IAaveV3ConfigEngine.RateStrategyUpdate[](${
            cfg.length
          });
          ${cfg
            .map(
              (cfg, ix) => `rateStrategies[${ix}] = IAaveV3ConfigEngine.RateStrategyUpdate({
                  asset: ${translateAssetToAssetLibUnderlying(cfg.asset, market)},
                  params: IAaveV3ConfigEngine.InterestRateInputData({
                    optimalUsageRatio: ${translateJsPercentToSol(
                      cfg.params.optimalUtilizationRate,
                    )},
                    baseVariableBorrowRate: ${translateJsPercentToSol(
                      cfg.params.baseVariableBorrowRate,
                    )},
                    variableRateSlope1: ${translateJsPercentToSol(cfg.params.variableRateSlope1)},
                    variableRateSlope2: ${translateJsPercentToSol(cfg.params.variableRateSlope2)}
                  })
                });`,
            )
            .join('\n')}


          return rateStrategies;
        }`,
        ],
      },
      test: {
        fn: rateUpdateTests(market, cfg, false),
      },
    };
    return response;
  },
};
