import fs from 'fs';
import path from 'path';
import {execFileSync} from 'child_process';
import {generateFiles, writeFiles} from '../generator';
import {generateFolderName} from '../common';
import {allModulesFixture, useCasesFixture, baseFixture, Fixture} from '../features/v4/fixtures';
import {resetRegistry} from '../features/v4/labelRegistry';

/// Compiles the generator's smoke-test fixtures. The snapshot specs only diff strings,
/// so a payload or test that does not build (duplicate function names, wrong struct
/// field, missing import) passes them; this writes the fixtures into `src/` where forge
/// resolves them like any other proposal and builds them for real.
const FIXTURES: Record<string, () => Fixture> = {
  allModules: allModulesFixture,
  useCases: useCasesFixture,
  base: baseFixture,
};

async function emit(fixture: () => Fixture): Promise<string> {
  resetRegistry();
  const {options, marketConfigs} = fixture();
  const folder = path.join(process.cwd(), 'src', generateFolderName(options));
  if (fs.existsSync(folder)) throw new Error(`${folder} already exists, refusing to overwrite`);
  await writeFiles({...options, force: true}, await generateFiles(options, marketConfigs));
  return folder;
}

const folders: string[] = [];
try {
  for (const [name, fixture] of Object.entries(FIXTURES)) {
    console.log(`generating ${name}`);
    folders.push(await emit(fixture));
  }
  const sources = folders.flatMap((folder) =>
    fs
      .readdirSync(folder)
      .filter((f) => f.endsWith('.sol'))
      .map((f) => path.join(folder, f)),
  );
  console.log(`building ${sources.length} files`);
  execFileSync('forge', ['build', ...sources], {
    stdio: 'inherit',
    env: {...process.env, FOUNDRY_PROFILE: 'test'},
  });
} finally {
  for (const folder of folders) fs.rmSync(folder, {recursive: true, force: true});
}
