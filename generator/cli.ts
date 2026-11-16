import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import {Command, Option} from 'commander';
import {
  CHAIN_TO_CHAIN_ID,
  getDate,
  getMarketChain,
  isWhitelabelMarket,
  isV2Market,
  isV3Market,
  isV4Market,
  pascalCase,
} from './common';
import {input, checkbox, select} from '@inquirer/prompts';
import {
  CodeArtifact,
  ConfigFile,
  FEATURE,
  FeatureModule,
  Options,
  MARKETS,
  MarketCache,
  MarketConfigs,
  MarketIdentifier,
  VOTING_NETWORK,
} from './types';
import {flashBorrower} from './features/flashBorrower';
import {capsUpdates} from './features/capsUpdates';
import {rateUpdatesV2, rateUpdatesV3} from './features/rateUpdates';
import {collateralsUpdates} from './features/collateralsUpdates';
import {borrowsUpdates} from './features/borrowsUpdates';
import {eModeUpdates} from './features/eModesUpdates';
import {eModeCreations} from './features/eModesCreation';
import {eModeAssets} from './features/eModesAssets';
import {priceFeedsUpdates} from './features/priceFeedsUpdates';
import {freezeUpdates} from './features/freeze';
import {emissionUpdates} from './features/emission';
import {assetListing, assetListingCustom} from './features/assetListing';
import {hubAssetListing} from './features/v4/hub/hubAssetListing';
import {hubAssetConfigUpdate} from './features/v4/hub/hubAssetConfigUpdate';
import {hubSpokeToAssetsAddition} from './features/v4/hub/hubSpokeToAssetsAddition';
import {hubSpokeConfigUpdate} from './features/v4/hub/hubSpokeConfigUpdate';
import {hubAssetHalt} from './features/v4/hub/hubAssetHalt';
import {hubAssetDeactivation} from './features/v4/hub/hubAssetDeactivation';
import {hubAssetCapsReset} from './features/v4/hub/hubAssetCapsReset';
import {hubSpokeDeactivation} from './features/v4/hub/hubSpokeDeactivation';
import {hubSpokeCapsReset} from './features/v4/hub/hubSpokeCapsReset';
import {spokeReserveListing} from './features/v4/spoke/spokeReserveListing';
import {spokeReserveConfigUpdate} from './features/v4/spoke/spokeReserveConfigUpdate';
import {spokeLiquidationConfigUpdate} from './features/v4/spoke/spokeLiquidationConfigUpdate';
import {spokeDynamicReserveConfigAddition} from './features/v4/spoke/spokeDynamicReserveConfigAddition';
import {spokeDynamicReserveConfigUpdate} from './features/v4/spoke/spokeDynamicReserveConfigUpdate';
import {spokePositionManagerUpdate} from './features/v4/spoke/spokePositionManagerUpdate';
import {accessManagerRoleMembership} from './features/v4/access/accessManagerRoleMembership';
import {accessManagerRoleUpdate} from './features/v4/access/accessManagerRoleUpdate';
import {accessManagerTargetFunctionRoleUpdate} from './features/v4/access/accessManagerTargetFunctionRoleUpdate';
import {accessManagerTargetAdminDelayUpdate} from './features/v4/access/accessManagerTargetAdminDelayUpdate';
import {positionManagerSpokeRegistration} from './features/v4/positionManager/positionManagerSpokeRegistration';
import {positionManagerRoleRenouncement} from './features/v4/positionManager/positionManagerRoleRenouncement';
import {onboardAssetToHub} from './features/v4/bundles/onboardAssetToHub';
import {onboardReserveToSpoke} from './features/v4/bundles/onboardReserveToSpoke';
import {tuneSpokeRisk} from './features/v4/bundles/tuneSpokeRisk';
import {tuneReserveRisk} from './features/v4/bundles/tuneReserveRisk';
import {wirePositionManager} from './features/v4/bundles/wirePositionManager';
import {manageRole} from './features/v4/bundles/manageRole';
import {hydrate as hydrateLabels} from './features/v4/labelRegistry';
import {generateFiles, writeFiles} from './generator';
import {configFileFromRecord} from './riskParams/load';
import {getClient} from '@aave-dao/toolbox';
import {getBlockNumber} from 'viem/actions';

const program = new Command();

program
  .name('proposal-generator')
  .description('CLI to generate aave proposals')
  .version('1.0.0')
  .addOption(new Option('-f, --force', 'force creation (might overwrite existing files)'))
  .addOption(new Option('-p, --markets <markets...>').choices(MARKETS))
  .addOption(new Option('-t, --title <string>', 'aip title'))
  .addOption(new Option('-a, --author <string>', 'author'))
  .addOption(new Option('-d, --discussion <string>', 'forum link'))
  .addOption(new Option('-s, --snapshot <string>', 'snapshot link'))
  .addOption(
    new Option(
      '-v, --votingNetwork <votingNetwork>',
      'network where voting should take place for the proposal',
    ).choices(Object.values(VOTING_NETWORK)),
  )
  .addOption(new Option('-c, --configFile <string>', 'path to config file'))
  .addOption(
    new Option('-r, --riskParams <string>', 'path to a risk params record (generator/riskParams)'),
  )
  .addOption(
    new Option('--ops <string>', 'with -r: path to an ops file (decimals, price feeds, seed)'),
  )
  .addOption(new Option('-u, --update', 'when used with -c update block height'))
  .allowExcessArguments(false)
  .parse(process.argv);

let options = program.opts<Options>();
let marketConfigs: MarketConfigs = {};

const PLACEHOLDER_MODULE: FeatureModule<{}> = {
  description: 'Something different not supported by configEngine',
  value: FEATURE.OTHERS,
  cli: async ({}) => {
    return {};
  },
  build: ({}) => {
    const response: CodeArtifact = {
      code: {execute: ['// custom code goes here']},
    };
    return response;
  },
};
const FEATURE_MODULES_V2 = [rateUpdatesV2, PLACEHOLDER_MODULE];
const FEATURE_MODULES_V3 = [
  rateUpdatesV3,
  capsUpdates,
  collateralsUpdates,
  borrowsUpdates,
  flashBorrower,
  priceFeedsUpdates,
  assetListing,
  assetListingCustom,
  eModeCreations,
  eModeUpdates,
  eModeAssets,
  freezeUpdates,
  emissionUpdates,
  PLACEHOLDER_MODULE,
];
const FEATURE_MODULES_V4: FeatureModule[] = [
  hubAssetListing,
  hubAssetConfigUpdate,
  hubSpokeToAssetsAddition,
  hubSpokeConfigUpdate,
  hubAssetHalt,
  hubAssetDeactivation,
  hubAssetCapsReset,
  hubSpokeDeactivation,
  hubSpokeCapsReset,
  spokeReserveListing,
  spokeReserveConfigUpdate,
  spokeLiquidationConfigUpdate,
  spokeDynamicReserveConfigAddition,
  spokeDynamicReserveConfigUpdate,
  spokePositionManagerUpdate,
  accessManagerRoleMembership,
  accessManagerRoleUpdate,
  accessManagerTargetFunctionRoleUpdate,
  accessManagerTargetAdminDelayUpdate,
  positionManagerSpokeRegistration,
  positionManagerRoleRenouncement,
  onboardAssetToHub,
  onboardReserveToSpoke,
  tuneSpokeRisk,
  tuneReserveRisk,
  wirePositionManager,
  manageRole,
  PLACEHOLDER_MODULE,
];

function getFeatureModules(market: MarketIdentifier): FeatureModule[] {
  if (isV2Market(market)) return FEATURE_MODULES_V2;
  if (isV3Market(market)) return FEATURE_MODULES_V3;
  if (isV4Market(market)) return FEATURE_MODULES_V4;
  throw new Error(`unknown market version for ${market}`);
}

async function generateDeterministicMarketCache(market: MarketIdentifier): Promise<MarketCache> {
  const chain = getMarketChain(market);
  const client = getClient(CHAIN_TO_CHAIN_ID[chain], {
    providerConfig: {alchemyKey: process.env.ALCHEMY_API_KEY},
  });
  return {blockNumber: Number(await getBlockNumber(client))};
}

async function fetchMarketOptions(market: MarketIdentifier) {
  marketConfigs[market] = {
    configs: {},
    artifacts: [],
    cache: await generateDeterministicMarketCache(market),
  };

  const modules = getFeatureModules(market);
  const features = await checkbox({
    message: `What do you want to do on ${market}?`,
    choices: modules.map((m) => ({value: m.value, name: m.description})),
  });
  for (const feature of features) {
    const module = modules.find((m) => m.value === feature)!;
    marketConfigs[market]!.configs[feature] = await module.cli({
      options,
      market,
      cache: marketConfigs[market]!.cache,
      configs: marketConfigs[market]!.configs,
    });
    marketConfigs[market]!.artifacts.push(
      module.build({
        options,
        market,
        cfg: marketConfigs[market]!.configs[feature],
        cache: marketConfigs[market]!.cache,
        configs: marketConfigs[market]!.configs,
      }),
    );
  }
}

let cfgFile: ConfigFile | undefined;
const recordPath = options.riskParams;
if (recordPath) {
  const {riskParams: _r, ops, ...cli} = options;
  cfgFile = await configFileFromRecord(recordPath, ops, cli);
  delete options.riskParams;
  delete options.ops;
} else if (options.configFile) {
  ({config: cfgFile} = await import(path.join(process.cwd(), options.configFile)));
}

if (cfgFile) {
  options = {...options, ...cfgFile.rootOptions};
  marketConfigs = cfgFile.marketOptions as any;
  for (const market of options.markets) {
    const modules = getFeatureModules(market);
    if (marketConfigs[market]) {
      hydrateLabels(market as any, marketConfigs[market]!.labels);
      marketConfigs[market]!.artifacts = [];
      for (const feature of Object.keys(marketConfigs[market]!.configs)) {
        const module = modules.find((m) => m.value === feature)!;
        if (options.update) {
          marketConfigs[market]!.cache = await generateDeterministicMarketCache(market);
        }
        marketConfigs[market]!.artifacts.push(
          module.build({
            options,
            market,
            cfg: marketConfigs[market]!.configs[feature],
            cache: marketConfigs[market]!.cache,
            configs: marketConfigs[market]!.configs,
          }),
        );
      }
    } else {
      await fetchMarketOptions(market);
    }
  }
} else {
  if (!options.markets || options.markets.length === 0) {
    options.markets = await checkbox({
      message: 'Markets this proposal targets',
      choices: MARKETS.map((v) => ({name: v, value: v})),
      required: true,
      // validate(input) {
      //   // currently ignored due to a bug
      //   if (input.length == 0) return 'You must target at least one market in your proposal!';
      //   return true;
      // },
    });
  }

  const nonWhitelabelMarkets = options.markets.filter((market) => !isWhitelabelMarket(market));

  if (!options.title) {
    options.title = await input({
      message:
        'Short title of your proposal that will be used as contract name(please refrain from including author or date)',
      validate(input) {
        if (input.length == 0) return "Your title can't be empty";
        // this is no exact math
        // fully qualified identifiers are not allowed to be longer then 300 chars on etherscan api
        // the path is roughly src(3)/date(8)_title/title_date(8):title_date(8), so 3 + 3*8 + 3 title.length
        // so 80 sounds like a reasonable upper bound to stay below 300 character limit
        if (input.trim().length > 80) return 'Your title is to long';
        return true;
      },
    });
  }
  options.shortName = pascalCase(options.title);
  options.date = getDate();

  if (!options.author) {
    options.author = await input({
      message: 'Author of your proposal',
      validate(input) {
        if (input.length == 0) return "Your author can't be empty";
        return true;
      },
    });
  } else if (options.author.includes('TTT')) {
    const author = await input({
      message: 'Skyward proposal, please provide the name this proposal should be attributed to',
      validate(input) {
        if (input.length == 0) return "Author name can't be empty";
        return true;
      },
    });
    options.author = options.author.replace('TTT', author);
  }

  if (!options.discussion && nonWhitelabelMarkets.length > 0) {
    options.discussion = await input({
      message: 'Link to forum discussion',
    });
  }

  if (!options.snapshot && nonWhitelabelMarkets.length > 0) {
    options.snapshot = await input({
      message: 'Link to snapshot',
    });
  }

  if (!options.votingNetwork && nonWhitelabelMarkets.length > 0) {
    options.votingNetwork = await select({
      message: 'Select network where voting should takes place for the proposal',
      choices: Object.values(VOTING_NETWORK).map((v) => ({
        name: v != VOTING_NETWORK.AVALANCHE ? v : VOTING_NETWORK.AVALANCHE + ' (DEFAULT)',
        value: v,
      })),
      default: VOTING_NETWORK.AVALANCHE,
    });
  }

  for (const market of options.markets) {
    await fetchMarketOptions(market);
  }
}

try {
  const files = await generateFiles(options, marketConfigs);
  // keep the record next to config.ts, so the PR shows which version of the params was used
  if (recordPath) files.riskParams = fs.readFileSync(recordPath, 'utf8');
  await writeFiles(options, files);
} catch (e) {
  console.log(JSON.stringify({options, marketConfigs}, null, 2));
  throw e;
}
