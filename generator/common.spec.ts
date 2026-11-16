import {expect, describe, it} from 'vitest';
import {getVersion, getTestBase, toSolidityString} from './common';
import {MarketIdentifier} from './types';

describe('getVersion', () => {
  it('resolves the version per market family', () => {
    expect(getVersion('AaveV2Ethereum')).toBe('V2');
    expect(getVersion('AaveV3Ethereum')).toBe('V3');
    expect(getVersion('AaveV4Ethereum')).toBe('V4');
    expect(getVersion('AaveV4Base')).toBe('V4');
  });

  it('throws for an unknown market instead of defaulting to V3', () => {
    expect(() => getVersion('AaveV9Unknown' as MarketIdentifier)).toThrow();
  });
});

describe('getTestBase', () => {
  it('maps each market family to its test base', () => {
    expect(getTestBase('AaveV2Ethereum')).toEqual({v4: false, testBase: 'ProtocolV2TestBase'});
    expect(getTestBase('AaveV3Ethereum')).toEqual({v4: false, testBase: 'ProtocolV3TestBase'});
    expect(getTestBase('AaveV4Base')).toEqual({v4: true, testBase: 'ProtocolV4TestBaseBase'});
    expect(getTestBase('AaveV4Ethereum')).toEqual({
      v4: true,
      testBase: 'ProtocolV4TestBaseEthereum',
    });
  });

  it('throws for an unknown market', () => {
    expect(() => getTestBase('AaveV9Unknown' as MarketIdentifier)).toThrow();
  });
});

describe('toSolidityString', () => {
  it('escapes text into a Solidity string literal', () => {
    expect(toSolidityString('USDC')).toBe('"USDC"');
    expect(toSolidityString('PT-USDG-25FEB2027')).toBe('"PT-USDG-25FEB2027"');
    expect(toSolidityString('a"b\\c')).toBe('"a\\"b\\\\c"');
    expect(toSolidityString('a\nb\tc\x00')).toBe('"a\\nb\\tc\\x00"');
    expect(toSolidityString('USD₮0')).toBe('unicode"USD₮0"');
  });
});
