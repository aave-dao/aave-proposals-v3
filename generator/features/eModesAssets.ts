import {CodeArtifact, ENGINE_FLAGS, FEATURE, FeatureModule, MarketIdentifier} from '../types';
import {eModeSelect} from '../prompts';
import {AssetEModeUpdate} from './types';
import {
  assetsSelectPrompt,
  getNewListingSymbols,
  translateAssetToAssetLibUnderlying,
} from '../prompts/assetsSelectPrompt';
import {boolPrompt, translateJsBoolToSol} from '../prompts/boolPrompt';

async function subCli(market: MarketIdentifier, additionalAssets: string[]) {
  console.log(`Fetching information for Emode assets on ${market}`);
  const assets = await assetsSelectPrompt({
    message: 'Select the assets you want to amend eMode for',
    market,
    additionalAssets,
  });
  const answers: EmodeAssetUpdates = [];
  for (const asset of assets) {
    console.log(`collecting info for ${asset}`);
    answers.push({
      asset,
      eModeCategory: await eModeSelect({
        message: `Select the eMode you want to assign to ${asset}`,
        disableKeepCurrent: true,
        market,
      }),
      collateral: await boolPrompt({
        message: `Should the asset ${asset} be enabled as collateral inside the EMode?`,
      }),
      borrowable: await boolPrompt({
        message: `Should the asset ${asset} be enabled as borrowable inside the EMode?`,
      }),
      ltvzero: await boolPrompt({
        message: `Should ltvzero be enabled for the asset ${asset} inside the EMode?`,
      }),
    });
  }
  return answers;
}

type EmodeAssetUpdates = AssetEModeUpdate[];

function eModeAssetUpdateTests(
  market: MarketIdentifier,
  cfgs: EmodeAssetUpdates,
  newListings: Set<string>,
): string[] {
  return cfgs.map((cfg, ix) => {
    const asset = translateAssetToAssetLibUnderlying(cfg.asset, market, newListings);
    const isNewListing = newListings.has(cfg.asset);
    const checks = [
      ['Collateral', 'getEModeCategoryCollateralBitmap', cfg.collateral],
      ['Borrowable', 'getEModeCategoryBorrowableBitmap', cfg.borrowable],
      ['Ltvzero', 'getEModeCategoryLtvzeroBitmap', cfg.ltvzero],
    ] as const;
    // A newly listed asset has no reserve (and therefore no reserve id or
    // pre-existing eMode bitmap state) until the payload lists it, so the
    // reserve mask can only be resolved after execution, and KEEP_CURRENT
    // has no prior state to preserve for it.
    const reserveMaskDecl = `uint128 reserveMask = uint128(1) << ${market}.POOL.getReserveData(${asset}).id;`;
    return `function test_eModeAssetUpdate_${ix}() public {
      ${isNewListing ? '' : reserveMaskDecl}
      ${checks
        .filter(([, , value]) => !isNewListing && value === ENGINE_FLAGS.KEEP_CURRENT)
        .map(
          ([name, getter]) =>
            `bool before${name} = (${market}.POOL.${getter}(${cfg.eModeCategory}) & reserveMask) != 0;`,
        )
        .join('\n      ')}

      GovV3Helpers.executePayload(vm, address(proposal));

      ${isNewListing ? reserveMaskDecl : ''}
      ${checks
        .filter(([, , value]) => !isNewListing || value !== ENGINE_FLAGS.KEEP_CURRENT)
        .map(([name, getter, value]) => {
          const expected =
            value === ENGINE_FLAGS.KEEP_CURRENT
              ? `before${name}`
              : String(value === ENGINE_FLAGS.ENABLED);
          return `assertEq(
        (${market}.POOL.${getter}(${cfg.eModeCategory}) & reserveMask) != 0,
        ${expected},
        'unexpected eMode ${name.toLowerCase()} state'
      );`;
        })
        .join('\n      ')}
    }`;
  });
}

export const eModeAssets: FeatureModule<EmodeAssetUpdates> = {
  value: FEATURE.EMODES_ASSETS,
  description: 'assetsEModeUpdates (setting eMode for an asset)',
  async cli({market, configs}) {
    const response: EmodeAssetUpdates = await subCli(market, getNewListingSymbols(configs));
    return response;
  },
  build({market, cfg, configs}) {
    const newListings = new Set(getNewListingSymbols(configs));
    const response: CodeArtifact = {
      code: {
        fn: [
          `function assetsEModeUpdates() public pure override returns (IAaveV3ConfigEngine.AssetEModeUpdate[] memory) {
          IAaveV3ConfigEngine.AssetEModeUpdate[] memory assetEModeUpdates = new IAaveV3ConfigEngine.AssetEModeUpdate[](${
            cfg.length
          });

          ${cfg
            .map(
              (cfg, ix) => `assetEModeUpdates[${ix}] = IAaveV3ConfigEngine.AssetEModeUpdate({
               asset: ${translateAssetToAssetLibUnderlying(cfg.asset, market, newListings)},
               eModeCategory: ${cfg.eModeCategory},
               borrowable: ${translateJsBoolToSol(cfg.borrowable)},
               collateral: ${translateJsBoolToSol(cfg.collateral)},
               ltvzero: ${translateJsBoolToSol(cfg.ltvzero)},
             });`,
            )
            .join('\n')}

          return assetEModeUpdates;
        }`,
        ],
      },
      test: {
        fn: eModeAssetUpdateTests(market, cfg, newListings),
      },
    };
    return response;
  },
};
