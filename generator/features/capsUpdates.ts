import {CodeArtifact, FEATURE, FeatureModule} from '../types';
import {CapsUpdate, CapsUpdatePartial} from './types';
import {
  assetsSelectPrompt,
  translateAssetToAssetLibUnderlying,
} from '../prompts/assetsSelectPrompt';
import {numberPrompt, translateJsNumberToSol} from '../prompts/numberPrompt';

export async function fetchCapsUpdate(required?: boolean): Promise<CapsUpdatePartial> {
  return {
    supplyCap: await numberPrompt({
      message: 'New supply cap',
      required,
    }),
    borrowCap: await numberPrompt({
      message: 'New borrow cap (must be 1 for asset not borrowable)',
      required,
    }),
  };
}

type CapsUpdates = CapsUpdate[];

export const capsUpdates: FeatureModule<CapsUpdates> = {
  value: FEATURE.CAPS_UPDATE,
  description: 'CapsUpdates (supplyCap, borrowCap)',
  async cli({pool}) {
    console.log(`Fetching information for CapsUpdates on ${pool}`);
    const assets = await assetsSelectPrompt({
      message: 'Select the assets you want to amend',
      pool,
    });

    const response: CapsUpdates = [];
    for (const asset of assets) {
      console.log(`collecting info for ${asset}`);
      response.push({asset, ...(await fetchCapsUpdate())});
    }
    return response;
  },
  build({pool, cfg}) {
    const response: CodeArtifact = {
      code: {
        fn: [
          `function capsUpdates() public pure override returns (IAaveV3ConfigEngine.CapsUpdate[] memory) {
          IAaveV3ConfigEngine.CapsUpdate[] memory capsUpdate = new IAaveV3ConfigEngine.CapsUpdate[](${
            cfg.length
          });

          ${cfg
            .map(
              (cfg, ix) => `capsUpdate[${ix}] = IAaveV3ConfigEngine.CapsUpdate({
               asset: ${translateAssetToAssetLibUnderlying(cfg.asset, pool)},
               supplyCap: ${translateJsNumberToSol(cfg.supplyCap)},
               borrowCap: ${translateJsNumberToSol(cfg.borrowCap)}
             });`,
            )
            .join('\n')}

          return capsUpdate;
        }`,
        ],
      },
    };
    return response;
  },
};
