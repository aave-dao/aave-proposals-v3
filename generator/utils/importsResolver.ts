/**
 * As a payload can consist of multiple features combined it's a mess to manage imports
 * Therefore instead of maintaining imports, we just extract them from the generated code instead.
 */

import {MARKETS} from '../types';

const GovernanceImports = [
  'GovV3Helpers',
  'IPayloadsControllerCore',
  'PayloadsControllerUtils',
] as const;

/**
 * @dev matches the code from known address book imports and generates an import statement satisfying the used libraries
 * @param code
 * @returns
 */
function generateAddressBookImports(code: string) {
  const imports: string[] = [];
  let root = '';
  const V4_SUFFIXES = [
    'Assets',
    'EModes',
    'Hubs',
    'Spokes',
    'SpokePriceFeeds',
    'TokenizationSpokes',
    'PositionManagers',
    'IRStrategies',
    'ExternalLibraries',
    'Getters',
  ];
  const suffixAlt = V4_SUFFIXES.join('|');
  const addressBookRe = new RegExp(`(?<!I)(AaveV[234][A-Za-z]+?)(?:${suffixAlt})?\\.`, 'g');
  for (const m of code.matchAll(addressBookRe)) {
    const base = m[1];
    if (!(MARKETS as readonly string[]).includes(base)) continue;
    const full = m[0].slice(0, -1);
    if (!imports.includes(full)) imports.push(full);
    root = base;
  }
  if (imports.length > 0) return `import {${imports}} from 'aave-address-book/${root}.sol';\n`;
}

function generateEngineImport(code: string) {
  const matches = [...code.matchAll(/Aave(V[234])Payload([A-Za-z]+)/g)].flat();
  if (matches.length > 0)
    return `import {${matches[0]}} from 'aave-helpers/src/${matches[1].toLowerCase()}-config-engine/${
      matches[0]
    }.sol';\n`;
}

function findMatches(code: string, needles: string[] | readonly string[]) {
  return needles.filter((needle) => RegExp(needle, 'g').test(code));
}

function findMatch(code: string, needle: string) {
  return RegExp(needle, 'g').test(code);
}

/**
 * @dev Returns the input string prefixed with imports
 * @param code
 * @returns
 */
export function prefixWithImports(code: string) {
  let imports = '';
  const govMatches = findMatches(code, GovernanceImports);
  // gov related imports
  if (govMatches.length > 0)
    imports += `import {${govMatches}} from 'aave-helpers/src/GovV3Helpers.sol';\n`;
  // address book imports
  const addressBookImports = generateAddressBookImports(code);
  if (addressBookImports) {
    imports += addressBookImports;
  }
  // generic Executor
  if (findMatch(code, 'IProposalGenericExecutor')) {
    imports += `import {IProposalGenericExecutor} from 'aave-helpers/src/interfaces/IProposalGenericExecutor.sol';\n`;
  }
  const configEngineImport = generateEngineImport(code);
  if (configEngineImport) {
    imports += configEngineImport;
  }
  if (findMatch(code, '\\bIConfigEngine\\b')) {
    imports += `import {IAaveV4ConfigEngine as IConfigEngine} from 'aave-address-book/AaveV4.sol';\n`;
    if (findMatch(code, 'EngineFlags')) {
      imports += `import {EngineFlags} from 'aave-v4/config-engine/libraries/EngineFlags.sol';\n`;
    }
  } else if (findMatch(code, 'EngineFlags')) {
    imports += `import {EngineFlags} from 'aave-v3-origin/contracts/extensions/v3-config-engine/EngineFlags.sol';\n`;
  }
  if (findMatch(code, 'IAaveV3ConfigEngine')) {
    imports += `import {IAaveV3ConfigEngine} from 'aave-v3-origin/contracts/extensions/v3-config-engine/IAaveV3ConfigEngine.sol';\n`;
  }
  if (findMatch(code, 'IAaveV2ConfigEngine')) {
    imports += `import {IAaveV2ConfigEngine} from 'aave-helpers/src/v2-config-engine/IAaveV2ConfigEngine.sol';\n`;
  }
  if (findMatch(code, 'IV2RateStrategyFactory')) {
    imports += `import {IV2RateStrategyFactory} from 'aave-helpers/src/v2-config-engine/IV2RateStrategyFactory.sol';\n`;
  }
  if (findMatch(code, '\\bIDefaultInterestRateStrategy\\b')) {
    imports += `import {IDefaultInterestRateStrategy} from 'aave-address-book/AaveV2.sol';\n`;
  }
  if (findMatch(code, '\\bIDefaultInterestRateStrategyV2\\b')) {
    imports += `import {IDefaultInterestRateStrategyV2} from 'aave-v3-origin/contracts/interfaces/IDefaultInterestRateStrategyV2.sol';\n`;
  }
  if (findMatch(code, '\\bIHub\\b')) {
    imports += `import {IHub} from 'aave-v4/hub/interfaces/IHub.sol';\n`;
  }
  if (findMatch(code, '\\bISpoke\\b')) {
    imports += `import {ISpoke} from 'aave-v4/spoke/interfaces/ISpoke.sol';\n`;
  }
  if (findMatch(code, '\\bIAaveOracle\\b')) {
    imports += `import {IAaveOracle} from 'aave-v4/spoke/interfaces/IAaveOracle.sol';\n`;
  }
  if (findMatch(code, '\\bIAssetInterestRateStrategy\\b')) {
    imports += `import {IAssetInterestRateStrategy} from 'aave-v4/hub/interfaces/IAssetInterestRateStrategy.sol';\n`;
  }
  if (findMatch(code, '\\bIAccessManager\\b')) {
    imports += `import {IAccessManager} from 'aave-v4/dependencies/openzeppelin/IAccessManager.sol';\n`;
  }
  if (findMatch(code, '\\bIPositionManagerBase\\b')) {
    imports += `import {IPositionManagerBase} from 'aave-v4/position-manager/interfaces/IPositionManagerBase.sol';\n`;
  }
  if (findMatch(code, '\\bITokenizationSpoke\\b')) {
    imports += `import {ITokenizationSpoke} from 'aave-v4/spoke/interfaces/ITokenizationSpoke.sol';\n`;
  }
  if (findMatch(code, '\\bRoles\\.')) {
    imports += `import {Roles} from 'aave-v4/deployments/utils/libraries/Roles.sol';\n`;
  }
  if (findMatch(code, '\\bV4EngineDefaults\\.')) {
    imports += `import {V4EngineDefaults} from 'aave-helpers/src/v4-config-engine/V4EngineDefaults.sol';\n`;
  }
  if (findMatch(code, '\\bV4RoleWiring\\.')) {
    imports += `import {V4RoleWiring} from 'aave-helpers/src/v4-config-engine/V4RoleWiring.sol';\n`;
  }
  if (findMatch(code, '(?<!I)\\bOwnable\\b')) {
    imports += `import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';\n`;
  }
  // common imports
  if (findMatch(code, '\\bIERC20\\b')) {
    imports += `import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';\n`;
  }
  if (findMatch(code, '\\bIERC20Metadata\\b')) {
    imports += `import {IERC20Metadata} from 'openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol';\n`;
  }
  if (findMatch(code, '\\bDataTypes\\.')) {
    imports += `import {DataTypes} from 'aave-v3-origin/contracts/protocol/libraries/types/DataTypes.sol';\n`;
  }
  if (findMatch(code, '\\bErrors\\.')) {
    imports += `import {Errors} from 'aave-v3-origin/contracts/protocol/libraries/helpers/Errors.sol';\n`;
  }
  if (findMatch(code, 'forceApprove')) {
    imports += `import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';\n`;
  }
  for (const lib of new Set([...code.matchAll(/\bGovernanceV3[A-Za-z]+\b/g)].map((m) => m[0]))) {
    imports += `import {${lib}} from 'aave-address-book/${lib}.sol';\n`;
  }
  if (findMatch(code, 'IEmissionManager')) {
    imports += `import {IEmissionManager} from 'aave-v3-origin/contracts/rewards/interfaces/IEmissionManager.sol';\n`;
  }

  return imports + '\n' + code;
}
