import {expect, describe, it, vi} from 'vitest';
import {FlashBorrower, flashBorrower} from './flashBorrower';
import {MOCK_OPTIONS} from './mocks/configs';
import {generateFiles} from '../generator';
import {FEATURE, MarketConfigs} from '../types';
import {compileGeneratedFiles} from '../utils/compileGeneratedFiles';
import {addressPrompt} from '../prompts/addressPrompt';

vi.mock('../prompts/addressPrompt', async (importOriginal) => ({
  ...(await importOriginal<typeof import('../prompts/addressPrompt')>()),
  addressPrompt: vi.fn(),
}));

const singleFlashBorrowerConfig: FlashBorrower = {
  address: '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83',
};

const multipleFlashBorrowersConfig: FlashBorrower = {
  addresses: [
    '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83',
    '0xFdFA036213C375808135744E865767FD90897F0A',
    '0x3171FC716942a40DEDe8dD0B7885dd9f44eca176',
  ],
};

function build(cfg: FlashBorrower) {
  return flashBorrower.build({
    options: MOCK_OPTIONS,
    market: 'AaveV3Ethereum',
    cfg,
    cache: {blockNumber: 42},
    configs: {},
  });
}

async function compile(cfg: FlashBorrower) {
  const configs = {[FEATURE.FLASH_BORROWER]: cfg};
  const marketConfigs: MarketConfigs = {
    AaveV3Ethereum: {
      market: 'AaveV3Ethereum',
      artifacts: [build(cfg)],
      configs,
      cache: {blockNumber: 42},
    },
  };

  compileGeneratedFiles(await generateFiles(MOCK_OPTIONS, marketConfigs));
}

describe('feature: flashBorrower', () => {
  describe('single address (legacy config)', () => {
    const output = build(singleFlashBorrowerConfig);

    it('should return reasonable code', () => {
      expect(output).toMatchSnapshot();
    });

    it('keeps the NEW_FLASH_BORROWER constant name', () => {
      expect(output.code?.constants).toHaveLength(1);
      expect(output.code?.constants?.[0]).toContain(
        'address public constant NEW_FLASH_BORROWER = 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83;',
      );
      expect(output.code?.execute).toEqual([
        'AaveV3Ethereum.ACL_MANAGER.addFlashBorrower(NEW_FLASH_BORROWER);',
      ]);
    });

    it('produces the same output as a single entry `addresses` config', () => {
      expect(build({addresses: [singleFlashBorrowerConfig.address]})).toEqual(output);
    });

    it('generates compilable Solidity', async () => {
      await compile(singleFlashBorrowerConfig);
    }, 60_000);
  });

  describe('multiple addresses', () => {
    const output = build(multipleFlashBorrowersConfig);

    it('should return reasonable code', () => {
      expect(output).toMatchSnapshot();
    });

    it('emits one constant and one addFlashBorrower call per address', () => {
      expect(output.code?.constants).toHaveLength(3);
      expect(output.code?.constants?.[0]).toContain(
        'address public constant NEW_FLASH_BORROWER_1 = 0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83;',
      );
      expect(output.code?.constants?.[1]).toContain(
        'address public constant NEW_FLASH_BORROWER_2 = 0xFdFA036213C375808135744E865767FD90897F0A;',
      );
      expect(output.code?.constants?.[2]).toContain(
        'address public constant NEW_FLASH_BORROWER_3 = 0x3171FC716942a40DEDe8dD0B7885dd9f44eca176;',
      );
      expect(output.code?.execute).toEqual([
        'AaveV3Ethereum.ACL_MANAGER.addFlashBorrower(NEW_FLASH_BORROWER_1);',
        'AaveV3Ethereum.ACL_MANAGER.addFlashBorrower(NEW_FLASH_BORROWER_2);',
        'AaveV3Ethereum.ACL_MANAGER.addFlashBorrower(NEW_FLASH_BORROWER_3);',
      ]);
    });

    it('asserts every address is a flash borrower', () => {
      const test = output.test?.fn?.join('\n') ?? '';

      [1, 2, 3].forEach((i) =>
        expect(test).toContain(
          `assertEq(AaveV3Ethereum.ACL_MANAGER.isFlashBorrower(proposal.NEW_FLASH_BORROWER_${i}()), true);`,
        ),
      );
    });

    it('generates compilable Solidity', async () => {
      await compile(multipleFlashBorrowersConfig);
    }, 60_000);
  });

  describe('cli', () => {
    it('keeps prompting for addresses until an empty answer is given', async () => {
      vi.mocked(addressPrompt)
        .mockResolvedValueOnce('0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83')
        .mockResolvedValueOnce('0xFdFA036213C375808135744E865767FD90897F0A')
        .mockResolvedValueOnce('');

      const cfg = await flashBorrower.cli({
        options: MOCK_OPTIONS,
        market: 'AaveV3Ethereum',
        cache: {blockNumber: 42},
        configs: {},
      });

      expect(cfg).toEqual({
        addresses: [
          '0xD2CC30cB0e77B80a34b879ccB6da67799e4ecD83',
          '0xFdFA036213C375808135744E865767FD90897F0A',
        ],
      });
      expect(addressPrompt).toHaveBeenCalledTimes(3);
      expect(vi.mocked(addressPrompt).mock.calls[0][0].required).toBe(true);
      expect(vi.mocked(addressPrompt).mock.calls[1][0].required).toBe(false);
    });
  });
});
