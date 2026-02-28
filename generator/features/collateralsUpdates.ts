import {CodeArtifact, FEATURE, FeatureModule, PoolIdentifier} from '../types';
import {percentInput} from '../prompts';
import {CollateralUpdate, CollateralUpdatePartial} from './types';
import {
  assetsSelectPrompt,
  translateAssetToAssetLibUnderlying,
} from '../prompts/assetsSelectPrompt';
import {numberPrompt, translateJsNumberToSol} from '../prompts/numberPrompt';
import {percentPrompt, translateJsPercentToSol} from '../prompts/percentPrompt';

export async function fetchCollateralUpdate(
  pool: PoolIdentifier,
  required?: boolean,
): Promise<CollateralUpdatePartial> {
  return {
    ltv: await percentPrompt({
      message: 'Loan to value',
      required,
    }),
    liqThreshold: await percentPrompt({
      message: 'Liquidation Threshold',
      required,
    }),
    liqBonus: await percentPrompt({
      message: 'Liquidation bonus',
      required,
    }),
    debtCeiling: await numberPrompt({
      message: 'Debt ceiling (must be 0 for asset out of isolation)',
      required,
    }),
    liqProtocolFee: await percentPrompt({
      message: 'Liquidation protocol fee',
      required,
    }),
  };
}

type CollateralUpdates = CollateralUpdate[];

export const collateralsUpdates: FeatureModule<CollateralUpdates> = {
  value: FEATURE.COLLATERALS_UPDATE,
  description: 'CollateralsUpdates (ltv,lt,lb,debtCeiling,liqProtocolFee,eModeCategory)',
  async cli({pool}) {
    console.log(`Fetching information for Collateral Updates on ${pool}`);

    const response: CollateralUpdates = [];
    const assets = await assetsSelectPrompt({
      message: 'Select the assets you want to amend',
      pool,
    });
    for (const asset of assets) {
      console.log(`collecting info for ${asset}`);

      response.push({asset, ...(await fetchCollateralUpdate(pool))});
    }
    return response;
  },
  build({pool, cfg}) {
    const response: CodeArtifact = {
      code: {
        fn: [
          `function collateralsUpdates() public pure override returns (IAaveV3ConfigEngine.CollateralUpdate[] memory) {
          IAaveV3ConfigEngine.CollateralUpdate[] memory collateralUpdate = new IAaveV3ConfigEngine.CollateralUpdate[](${
            cfg.length
          });

          ${cfg
            .map(
              (cfg, ix) => `collateralUpdate[${ix}] = IAaveV3ConfigEngine.CollateralUpdate({
               asset: ${translateAssetToAssetLibUnderlying(cfg.asset, pool)},
               ltv: ${translateJsPercentToSol(cfg.ltv)},
               liqThreshold: ${translateJsPercentToSol(cfg.liqThreshold)},
               liqBonus: ${translateJsPercentToSol(cfg.liqBonus)},
               debtCeiling: ${translateJsNumberToSol(cfg.debtCeiling)},
               liqProtocolFee: ${translateJsPercentToSol(cfg.liqProtocolFee)}
             });`,
            )
            .join('\n')}

          return collateralUpdate;
        }`,
        ],
      },
    };
    return response;
  },
};
