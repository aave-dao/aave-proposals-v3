import {
  generateContractName,
  generateFolderName,
  getChainAlias,
  getMarketChain,
  getTestBase,
  isWhitelabelMarket,
} from '../common';
import {Options, MarketConfig, MarketIdentifier} from '../types';
import {prefixWithPragma} from '../utils/constants';
import {prefixWithImports} from '../utils/importsResolver';

/// Two features asking for the exact same test emit it once. Two features emitting the
/// same test name with different bodies means they configure the same entity in
/// conflicting ways, which the payload cannot satisfy either, so it fails here rather
/// than generating a test contract that does not compile.
function dedupeTestFns(fns: string[]): string[] {
  const byName = new Map<string, string>();
  for (const fn of fns) {
    // keyed by the whole block when there is no name to key on, so nothing is dropped
    const name = fn.match(/function\s+(\w+)\s*\(/)?.[1] ?? fn;
    const existing = byName.get(name);
    if (existing === undefined) {
      byName.set(name, fn);
      continue;
    }
    if (existing.trim() !== fn.trim()) {
      throw new Error(
        `conflicting definitions of ${name}: the same entity is configured twice with different values`,
      );
    }
  }
  return [...byName.values()];
}

export const testTemplate = (
  options: Options,
  marketConfig: MarketConfig,
  market: MarketIdentifier,
) => {
  const folderName = generateFolderName(options);
  const chain = getMarketChain(market);
  const isZkSync = chain === 'ZkSync';
  const contractName = generateContractName(options, market);
  const {v4, testBase} = getTestBase(market);
  const isV4Base = v4 && chain === 'Base';

  const functions = dedupeTestFns(
    marketConfig.artifacts
      .map((artifact) => artifact.test?.fn)
      .flat()
      .filter((f): f is string => f !== undefined),
  ).join('\n\n');

  const testBaseImports = [testBase, 'ReserveConfig'];
  if (testBase === 'ProtocolV3TestBase' && functions.includes('ExpectedListing')) {
    testBaseImports.push('ExpectedListing');
  }
  const testBasePath = isZkSync ? 'zksync/src/' : 'src/';

  const testBaseImport = v4
    ? `import {${testBase}} from 'aave-helpers/src/v4-protocol-test/${testBase}.sol';`
    : `import {${testBaseImports.join(', ')}} from 'aave-helpers/${testBasePath}${testBase}.sol';`;

  // Base e2e callers need non-isolated transactions to avoid L1 data-fee funding failures.
  // Keep the snapshot/execution test isolated so payload gas checks remain meaningful.
  const defaultTestCall = isV4Base
    ? `defaultTest({
        reportName: '${contractName}',
        payload: address(proposal),
        runE2E: false,
        testPositionManagers: false,
        runSeatbelt: false
      });`
    : v4
      ? `defaultTest('${contractName}', address(proposal));`
      : `defaultTest('${contractName}', ${market}.POOL, address(proposal) ${isWhitelabelMarket(market) ? ', true, true' : ''});`;

  const baseTestConfig = isV4Base
    ? `
 * Uses the native Base EVM on Cobalt. Payload execution stays isolated for gas checks.
 * E2E isolation is disabled to avoid L1 data fees for unfunded pranked callers.
 * forge-config: default.networks.network = "base"
 * forge-config: default.hardfork = "base:cobalt"
 * forge-config: default.isolate = false`
    : '';
  const baseE2ETest = isV4Base
    ? `
  function test_e2e() public {
    GovV3Helpers.executePayload(vm, address(proposal));
    e2eTestAllSpokes({spokes: _getSpokes(), testPositionManagers: false});
    e2eTestAllTokenizationSpokes(_getTokenizationSpokes());
  }

  `
    : '';

  const updatedAssets = Array.from(
    new Set(
      marketConfig.artifacts
        .map((artifact) => artifact.test?.updatedAssets)
        .flat()
        .filter((asset) => asset !== undefined),
    ),
  );
  const reserveConfigChangesTest =
    testBase === 'ProtocolV3TestBase'
      ? `
  /**
   * @dev checks whether reserve configurations changed or stayed unchanged as expected
   */
  function test_reserveConfigChanges() public {
    address[] memory updatedAssets = new address[](${updatedAssets.length});
    ${updatedAssets.map((asset, ix) => `updatedAssets[${ix}] = ${asset};`).join('\n    ')}
    reserveConfigChangesTest(${market}.POOL, address(proposal), updatedAssets);
  }
`
      : '';

  let template = `
import 'forge-std/Test.sol';
${testBaseImport}
import {${contractName}} from './${contractName}.sol';

/**
 * @dev Test for ${contractName}${baseTestConfig}
 * command: FOUNDRY_PROFILE=${chain === 'ZkSync' ? 'zksync' : 'test'} forge test ${chain === 'ZkSync' ? '--zksync --match-path=zksync/src/' : '--match-path=src/'}${folderName}/${contractName}.t.sol -vv
 */
contract ${contractName}_Test is ${testBase} {
  ${contractName} internal proposal;

  function setUp() public ${chain === 'ZkSync' ? 'override' : ''} {
    vm.createSelectFork(vm.rpcUrl('${getChainAlias(chain)}'), ${marketConfig.cache.blockNumber});
    proposal = new ${contractName}();

    ${chain === 'ZkSync' ? 'super.setUp();' : ''}
  }

  /**
   * @dev ${isV4Base ? 'executes the payload with config snapshots and diff; e2e runs separately' : 'executes the generic test suite including e2e and config snapshots'}
   * forge-config: default.isolate = true
   */
  function test_defaultProposalExecution() public {
    ${defaultTestCall}
  }

  ${baseE2ETest}${reserveConfigChangesTest}
  ${functions}
}`;
  return prefixWithPragma(prefixWithImports(template));
};
