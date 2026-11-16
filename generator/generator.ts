import fs from 'fs';
import path from 'path';
import {generateContractName, generateFolderName, isWhitelabelMarket} from './common';
import {proposalTemplate} from './templates/proposal.template';
import {testTemplate} from './templates/test.template';
import {confirm} from '@inquirer/prompts';
import {ConfigFile, Options, MarketConfigs, MarketIdentifier, Scripts, Files} from './types';
import prettier from 'prettier';
import {generateScript} from './templates/script.template';
import {generateZkSyncScript} from './templates/zksync.script.template';
import {generateAIP} from './templates/aip.template';
import {finalizeV4Artifacts, finalizeV4EntityConstants} from './features/v4/bundleHelpers';
import {snapshot as labelSnapshot} from './features/v4/labelRegistry';

const prettierSolCfg = await prettier.resolveConfig('foo.sol');
const prettierMDCfg = await prettier.resolveConfig('foo.md');
const prettierTsCfg = await prettier.resolveConfig('foo.ts');

/**
 * Generates all the file contents for aip/tests/payloads & script
 * @param options
 * @param marketConfigs
 * @returns
 */
export async function generateFiles(
  options: Options,
  marketConfigs: MarketConfigs,
): Promise<Files> {
  const jsonConfig = await prettier.format(
    `import {ConfigFile} from '../../generator/types';
    export const config: ConfigFile = ${JSON.stringify({
      rootOptions: options,
      marketOptions: (Object.keys(marketConfigs) as MarketIdentifier[]).reduce((acc, market) => {
        const labels = labelSnapshot(market as any);
        acc[market] = {
          configs: marketConfigs[market]!.configs,
          cache: marketConfigs[market]!.cache,
          ...(Object.keys(labels).length > 0 ? {labels} : {}),
        };
        return acc;
      }, {}),
    } as ConfigFile)}`,
    {...prettierTsCfg, filepath: 'foo.ts'},
  );

  async function createPayloadAndTest(options: Options, market: MarketIdentifier) {
    const contractName = generateContractName(options, market);
    // merges the v4 getters (and the tests over them) before the test template reads
    // the artifacts, so a getter fed by several features is asserted once as a whole
    finalizeV4Artifacts(marketConfigs[market]!);
    finalizeV4EntityConstants(marketConfigs[market]!, market);
    const testCode = testTemplate(options, marketConfigs[market]!, market);

    return {
      market,
      payload: await prettier.format(proposalTemplate(options, marketConfigs[market]!, market), {
        ...prettierSolCfg,
        filepath: 'foo.sol',
      }),
      test: await prettier.format(testCode, {
        ...prettierSolCfg,
        filepath: 'foo.sol',
      }),
      contractName: contractName,
    };
  }

  console.log('generating script');
  let scripts: Scripts = {
    defaultScript: await prettier.format(generateScript(options), {
      ...prettierSolCfg,
      filepath: 'foo.sol',
    }),
  };
  if (Object.keys(marketConfigs).includes('AaveV3ZkSync')) {
    scripts.zkSyncScript = await prettier.format(generateZkSyncScript(options), {
      ...prettierSolCfg,
      filepath: 'foo.sol',
    });
  }

  console.log('generating aip');
  const aip = await prettier.format(generateAIP(options, marketConfigs), {
    ...prettierMDCfg,
    filepath: 'foo.md',
  });

  return {
    jsonConfig,
    scripts,
    aip,
    payloads: await Promise.all(
      options.markets.map((market) => createPayloadAndTest(options, market)),
    ),
  };
}

/** Returns false when the user declined to overwrite the file. */
async function askBeforeWrite(options: Options, path: string, content: string) {
  if (!options.force && fs.existsSync(path)) {
    const currentContent = fs.readFileSync(path, {encoding: 'utf8'});
    // skip if content did not change
    if (currentContent === content) return true;
    const force = await confirm({
      message: `A file already exists at ${path} do you want to overwrite`,
      default: false,
    });
    if (!force) return false;
  }
  fs.writeFileSync(path, content);
  return true;
}

/**
 * Writes the files according to defined folder/file format
 * @param options
 * @param param1
 */
export async function writeFiles(
  options: Options,
  {jsonConfig, scripts, aip, payloads, riskParams}: Files,
) {
  const baseName = generateFolderName(options);
  const baseFolder = path.join(process.cwd(), 'src', baseName);
  const zkSyncBaseFolder = path.join(process.cwd(), 'zksync/src', baseName);

  if (fs.existsSync(baseFolder) || (scripts.zkSyncScript && fs.existsSync(zkSyncBaseFolder))) {
    if (!options.force && fs.existsSync(baseFolder)) {
      const force = await confirm({
        message: 'A proposal already exists at that location, do you want to continue?',
        default: false,
      });
      if (!force) return;
    }
  } else {
    fs.mkdirSync(baseFolder, {recursive: true});
    if (scripts.zkSyncScript) fs.mkdirSync(zkSyncBaseFolder, {recursive: true});
  }

  // write config
  const configWritten = await askBeforeWrite(
    options,
    path.join(baseFolder, 'config.ts'),
    jsonConfig,
  );
  // the risk params record follows config.ts, so the two never disagree
  if (riskParams !== undefined && configWritten)
    fs.writeFileSync(path.join(baseFolder, 'riskParams.json'), riskParams);
  // write aip
  if (options.markets.some((market) => !isWhitelabelMarket(market))) {
    await askBeforeWrite(options, path.join(baseFolder, `${options.shortName}.md`), aip);
  }
  // write scripts
  await askBeforeWrite(
    options,
    path.join(baseFolder, `${generateContractName(options)}.s.sol`),
    scripts.defaultScript,
  );
  if (scripts.zkSyncScript) {
    await askBeforeWrite(
      options,
      path.join(zkSyncBaseFolder, `${generateContractName(options)}.s.sol`),
      scripts.zkSyncScript,
    );
  }

  for (const {market, payload, test, contractName} of payloads) {
    await askBeforeWrite(
      options,
      path.join(market === 'AaveV3ZkSync' ? zkSyncBaseFolder : baseFolder, `${contractName}.sol`),
      payload,
    );
    await askBeforeWrite(
      options,
      path.join(market === 'AaveV3ZkSync' ? zkSyncBaseFolder : baseFolder, `${contractName}.t.sol`),
      test,
    );
  }
}
