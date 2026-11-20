import {CodeArtifact, FEATURE, FeatureModule, MarketIdentifier} from '../types';
import {PriceFeedUpdate, PriceFeedUpdatePartial} from './types';
import {addressPrompt, translateJsAddressToSol} from '../prompts/addressPrompt';
import {
  assetsSelectPrompt,
  translateAssetToAssetLibUnderlying,
} from '../prompts/assetsSelectPrompt';

async function fetchPriceFeedUpdate(): Promise<PriceFeedUpdatePartial> {
  return {
    priceFeed: await addressPrompt({
      message: 'New price feed address',
      required: true,
    }),
  };
}

function priceFeedUpdateTests(market: MarketIdentifier, cfgs: PriceFeedUpdate[]): string[] {
  return cfgs.map(
    (cfg, ix) => `function test_priceFeedUpdate_${ix}() public {
      GovV3Helpers.executePayload(vm, address(proposal));

      assertEq(
        ${market}.ORACLE.getSourceOfAsset(${translateAssetToAssetLibUnderlying(cfg.asset, market)}),
        ${translateJsAddressToSol(cfg.priceFeed)},
        'unexpected price feed'
      );
    }`,
  );
}

export const priceFeedsUpdates: FeatureModule<PriceFeedUpdate[]> = {
  value: FEATURE.PRICE_FEEDS_UPDATE,
  description: 'PriceFeedsUpdates (replacing priceFeeds)',
  async cli({market}) {
    const response: PriceFeedUpdate[] = [];
    const assets = await assetsSelectPrompt({
      message: 'Select the assets you want to amend',
      market,
    });
    for (const asset of assets) {
      console.log(`collecting info for ${asset}`);
      response.push({asset, ...(await fetchPriceFeedUpdate())});
    }
    return response;
  },
  build({market, cfg}) {
    const response: CodeArtifact = {
      code: {
        fn: [
          `function priceFeedsUpdates() public pure override returns (IAaveV3ConfigEngine.PriceFeedUpdate[] memory) {
          IAaveV3ConfigEngine.PriceFeedUpdate[] memory priceFeedUpdates = new IAaveV3ConfigEngine.PriceFeedUpdate[](${
            cfg.length
          });

          ${cfg
            .map(
              (cfg, ix) => `priceFeedUpdates[${ix}] = IAaveV3ConfigEngine.PriceFeedUpdate({
               asset: ${translateAssetToAssetLibUnderlying(cfg.asset, market)},
               priceFeed: ${translateJsAddressToSol(cfg.priceFeed)}
             });`,
            )
            .join('\n')}

          return priceFeedUpdates;
        }`,
        ],
      },
      test: {
        fn: priceFeedUpdateTests(market, cfg),
      },
    };
    return response;
  },
};
