import {generateContractName, generateFolderName} from '../common';
import {Options, PoolConfigs, PoolIdentifier} from '../types';

export function generateAIP(options: Options, configs: PoolConfigs) {
  return `---
title: ${options.title ? `"${options.title}"` : 'TODO'}
author: ${options.author ? `"${options.author}"` : 'TODO'}
discussions: ${options.discussion ? `"${options.discussion}"` : 'TODO'}${
    options.snapshot
      ? options.snapshot.toLowerCase() != 'direct-to-aip'
        ? `\nsnapshot: "${options.snapshot}"\n`
        : ''
      : '\nsnapshot: TODO'
  }
---

## Simple Summary

## Motivation

## Specification

${Object.keys(configs)
  .map((pool) => {
    return configs[pool as keyof typeof configs]!.artifacts.filter(
      (artifact) => artifact.aip?.specification,
    ).map((artifact) => artifact.aip?.specification);
  })
  .filter((a) => a)
  .join('\n\n')}

## References

- Implementation: ${options.pools
    .map(
      (pool) =>
        `[${pool}](https://github.com/aave-dao/aave-proposals-v3/blob/main/${pool === 'AaveV3ZkSync' ? 'zksync/src' : 'src'}/${generateFolderName(
          options,
        )}/${generateContractName(options, pool)}.sol)`,
    )
    .join(', ')}
- Tests: ${options.pools
    .map(
      (pool) =>
        `[${pool}](https://github.com/aave-dao/aave-proposals-v3/blob/main/${pool === 'AaveV3ZkSync' ? 'zksync/src' : 'src'}/${generateFolderName(
          options,
        )}/${generateContractName(options, pool)}.t.sol)`,
    )
    .join(', ')}${
    options.snapshot
      ? options.snapshot.toLowerCase() != 'direct-to-aip'
        ? `\n- [Snapshot](${options.snapshot})`
        : '\n- Snapshot: Direct-to-AIP'
      : '\n[Snapshot](TODO)'
  }
- [Discussion](${options.discussion || 'TODO'})

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).\n`;
}
