import {afterEach, beforeEach, describe, expect, it, vi} from 'vitest';
import fs from 'fs';
import os from 'os';
import path from 'path';
import {confirm} from '@inquirer/prompts';
import {writeFiles} from './generator';
import {generateFolderName} from './common';
import {MOCK_OPTIONS} from './features/mocks/configs';
import type {Files} from './types';

vi.mock('@inquirer/prompts', () => ({confirm: vi.fn()}));

const files = (lpf: string): Files => ({
  jsonConfig: `config ${lpf}`,
  scripts: {defaultScript: 'script'},
  aip: 'aip',
  payloads: [],
  riskParams: `record ${lpf}`,
});

describe('writeFiles', () => {
  let folder: string;
  const read = (file: string) => fs.readFileSync(path.join(folder, file), 'utf8');

  beforeEach(() => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'generator-'));
    vi.spyOn(process, 'cwd').mockReturnValue(dir);
    vi.mocked(confirm).mockReset();
    folder = path.join(dir, 'src', generateFolderName(MOCK_OPTIONS));
  });
  afterEach(() => vi.restoreAllMocks());

  it('writes the risk params record next to config.ts on a new proposal', async () => {
    await writeFiles(MOCK_OPTIONS, files('20%'));
    expect(read('config.ts')).toBe('config 20%');
    expect(read('riskParams.json')).toBe('record 20%');
    expect(confirm).not.toHaveBeenCalled();
  });

  it('writes no record when the config was not built from one', async () => {
    await writeFiles(MOCK_OPTIONS, {...files('20%'), riskParams: undefined});
    expect(fs.existsSync(path.join(folder, 'riskParams.json'))).toBe(false);
  });

  it('keeps the old record when the user declines to overwrite config.ts', async () => {
    await writeFiles(MOCK_OPTIONS, files('20%'));
    vi.mocked(confirm).mockResolvedValueOnce(true).mockResolvedValueOnce(false);
    await writeFiles(MOCK_OPTIONS, files('30%'));
    expect(read('config.ts')).toBe('config 20%');
    expect(read('riskParams.json')).toBe('record 20%');
  });

  it('keeps every file when the user declines to continue into the existing folder', async () => {
    await writeFiles(MOCK_OPTIONS, files('20%'));
    vi.mocked(confirm).mockResolvedValueOnce(false);
    await writeFiles(MOCK_OPTIONS, files('30%'));
    expect(confirm).toHaveBeenCalledTimes(1);
    expect(read('config.ts')).toBe('config 20%');
    expect(read('riskParams.json')).toBe('record 20%');
  });

  it('updates the record with config.ts when the user accepts', async () => {
    await writeFiles(MOCK_OPTIONS, files('20%'));
    vi.mocked(confirm).mockResolvedValue(true);
    await writeFiles(MOCK_OPTIONS, files('30%'));
    expect(read('config.ts')).toBe('config 30%');
    expect(read('riskParams.json')).toBe('record 30%');
  });

  it('updates the record without asking when config.ts is unchanged', async () => {
    await writeFiles(MOCK_OPTIONS, files('20%'));
    vi.mocked(confirm).mockResolvedValueOnce(true);
    await writeFiles(MOCK_OPTIONS, {...files('20%'), riskParams: 'record 20%, notes edited'});
    expect(confirm).toHaveBeenCalledTimes(1); // only the folder prompt
    expect(read('riskParams.json')).toBe('record 20%, notes edited');
  });

  it('overwrites config.ts and the record without prompts with --force', async () => {
    await writeFiles(MOCK_OPTIONS, files('20%'));
    await writeFiles({...MOCK_OPTIONS, force: true}, files('30%'));
    expect(confirm).not.toHaveBeenCalled();
    expect(read('config.ts')).toBe('config 30%');
    expect(read('riskParams.json')).toBe('record 30%');
  });
});
